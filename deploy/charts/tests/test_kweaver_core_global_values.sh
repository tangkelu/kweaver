#!/usr/bin/env bash
set -euo pipefail

CHART_PATH="${1:-/code/kweaver/kweaver/deploy/charts/kweaver-core-0.5.0-alpha.1.tgz}"
VALUES_PATH="${2:-/code/kweaver/kweaver/deploy/conf/kweaver-values.yaml}"

rendered="$(mktemp)"
trap 'rm -f "$rendered"' EXIT

assert_no_raw_global_reads_in_dependency_templates() {
  python - <<'PY'
import re
import sys
from pathlib import Path
import yaml

root = Path("/code/kweaver/kweaver")
chart = yaml.safe_load((root / "deploy/charts/kweaver-core/Chart.yaml").read_text())
subcharts = root / "deploy/charts/subCharts"
pattern = re.compile(r"\.Values\.(depServices|env|accessAddress|image\.registry|replicaCount|ingressClassName|mode)\b")
violations = []

for dep in chart["dependencies"]:
    chart_dir = subcharts / dep["name"] / "templates"
    if not chart_dir.exists():
        continue
    for path in sorted(chart_dir.rglob("*")):
        if not path.is_file():
            continue
        if path.name in {"_helpers.tpl", "helpers.tpl"}:
            continue
        for lineno, line in enumerate(path.read_text(errors="ignore").splitlines(), 1):
            if pattern.search(line):
                violations.append(f"{path}:{lineno}:{line.strip()}")

if violations:
    print("found raw global reads in dependency templates:", file=sys.stderr)
    for item in violations:
        print(item, file=sys.stderr)
    sys.exit(1)
PY
}

helm template kweaver-core "$CHART_PATH" -f "$VALUES_PATH" \
  --show-only charts/hydra/templates/deployment.yaml \
  --show-only charts/hydra/templates/janitor-cron-job.yaml \
  --show-only charts/hydra/templates/secrets-dsn.yaml \
  --show-only charts/agent-backend/templates/configmap-executor.yaml \
  --show-only charts/agent-backend/templates/configmap-memory.yaml \
  --show-only charts/agent-backend/templates/secret.yaml \
  --show-only charts/agent-backend/templates/deployment.yaml \
  --show-only charts/audit-log/templates/secret.yaml \
  --show-only charts/audit-log/templates/configmap.yaml \
  --show-only charts/user-management/templates/configmap.yaml \
  --show-only charts/user-management/templates/secret.yaml \
  --show-only charts/user-management/templates/deployment.yaml \
  --show-only charts/authentication/templates/configmap.yaml \
  --show-only charts/authorization/templates/configmap.yaml \
  --show-only charts/dataflow/templates/deployment.yaml \
  --show-only charts/sharemgnt/templates/configmap.yaml \
  --show-only charts/sharemgnt-single/templates/configmap.yaml \
  --show-only charts/policy-management/templates/configmap.yaml \
  --show-only charts/policy-management/templates/secret.yaml \
  --show-only charts/policy-management/templates/deployment.yaml \
  --show-only charts/eacp/templates/secret.yaml \
  --show-only charts/eacp/templates/configmap.yaml \
  --show-only charts/dataflow/templates/ecron-management/secret.yaml \
  --show-only charts/dataflow/templates/ecron-management/configmap.yaml \
  --show-only charts/dataflow/templates/flow-automation/configmap.yaml \
  --show-only charts/dataflow/templates/stream-data-pipeline/configmap.yaml \
  >"$rendered"

assert_contains() {
  local expected="$1"
  if ! grep -Fq "$expected" "$rendered"; then
    echo "missing expected content: $expected" >&2
    exit 1
  fi
}

assert_not_contains() {
  local unexpected="$1"
  if grep -Fq "$unexpected" "$rendered"; then
    echo "found unexpected content: $unexpected" >&2
    exit 1
  fi
}

assert_no_empty_mq_config() {
  if awk '
    /mq_config.yaml: \|/ {
      getline
      if ($0 ~ /^    \{\}$/) {
        exit 1
      }
    }
  ' "$rendered"; then
    return 0
  fi

  echo "found empty mq_config.yaml block" >&2
  exit 1
}

assert_contains 'image: "swr.cn-east-3.myhuaweicloud.com/kweaver-ai/as/hydra:0.4.0-4661ce5-20260313.1"'
assert_not_contains 'image: "as/hydra:0.4.0-4661ce5-20260313.1"'

assert_contains 'db_host: "mariadb.resource.svc.cluster.local"'
assert_not_contains 'db_host: "127.0.0.1"'

assert_contains 'mqHost: kafka.resource.svc.cluster.local'
assert_no_empty_mq_config
assert_contains 'db_addr: "mariadb.resource.svc.cluster.local"'
assert_contains 'MQ_HOST: "kafka.resource.svc.cluster.local"'
assert_contains 'DM=(mariadb.resource.svc.cluster.local)'
assert_not_contains 'mariadb-mariadb-master.resource'
assert_not_contains 'kafka-headless.resource'
assert_not_contains 'proton-mq-nsq-nsqd.resource'
assert_not_contains 'proton-mq-nsq-nsqlookupd.resource'

assert_contains 'db_user = adp'
assert_contains 'db_password = adp@123456'
assert_contains 'db_host = mariadb.resource.svc.cluster.local'
assert_not_contains 'db_host = 127.0.0.1'
assert_not_contains 'db_read_host = 127.0.0.1'
assert_contains 'name: agent-backend-factory-secret-yaml'
assert_contains 'name: agent-backend-executor-yaml'
assert_contains 'name: agent-backend-memory-yaml'
assert_contains 'secretName: agent-backend-factory-secret-yaml'
assert_not_contains 'secretName: agent-factory-secret-yaml'
assert_not_contains '# 从老Chart复制，修改name为固定值apiVersion: v1'
assert_contains 'configMapRef:'
assert_contains 'name: policy-management'
assert_not_contains '                name: kweaver-core'
assert_contains 'name: dataflow'
assert_not_contains 'name: kweaver-core-dataflow'
assert_no_raw_global_reads_in_dependency_templates

echo "kweaver-core global values regression checks passed"
