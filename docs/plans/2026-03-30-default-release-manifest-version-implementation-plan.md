# Default Release Manifest Version Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make `deploy.sh` default aggregate installs/downloads to the latest embedded release manifest version when `--version` is omitted.

**Architecture:** Add shared release-manifest version discovery in `deploy/scripts/lib/common.sh`, then call it from aggregate product services before manifest and SQL resolution. Keep fallback behavior unchanged when no embedded manifest exists.

**Tech Stack:** Bash, Helm-based deploy scripts, shell test script

---

### Task 1: Add failing tests for implicit latest manifest resolution

**Files:**
- Modify: `/code/kweaver/kweaver/deploy/scripts/tests/test-version-manifest.sh`

**Step 1: Write the failing test**

Add tests that expect:

- `resolve_latest_embedded_release_version "kweaver-core"` returns `0.5.0`
- `download_core` sets `HELM_CHART_VERSION=0.5.0` and `CORE_VERSION_MANIFEST_FILE=.../0.5.0/kweaver-core.yaml` when no version is passed
- `resolve_versioned_sql_dir "kweaver-core" ""` continues to resolve to the same default release version path

**Step 2: Run test to verify it fails**

Run: `bash deploy/scripts/tests/test-version-manifest.sh`

Expected: FAIL because the new resolver behavior does not exist yet.

### Task 2: Implement shared latest-version discovery

**Files:**
- Modify: `/code/kweaver/kweaver/deploy/scripts/lib/common.sh`

**Step 1: Write minimal implementation**

Add helpers that:

- list release-manifest version directories
- filter to ones containing `<product>.yaml`
- sort semantic versions
- return the latest version

**Step 2: Run tests**

Run: `bash deploy/scripts/tests/test-version-manifest.sh`

Expected: Some tests still fail until service scripts start using the resolver.

### Task 3: Wire aggregate services to implicit latest release version

**Files:**
- Modify: `/code/kweaver/kweaver/deploy/scripts/services/core.sh`
- Modify: `/code/kweaver/kweaver/deploy/scripts/services/isf.sh`
- Modify: `/code/kweaver/kweaver/deploy/scripts/services/dip.sh`

**Step 1: Write minimal implementation**

Before auto-resolving embedded manifest files, fill `HELM_CHART_VERSION` from the latest embedded release version when:

- `HELM_CHART_VERSION` is empty
- the service-specific manifest override file is empty

**Step 2: Run tests**

Run: `bash deploy/scripts/tests/test-version-manifest.sh`

Expected: PASS

### Task 4: Update documentation

**Files:**
- Modify: `/code/kweaver/kweaver/deploy/README.md`
- Modify: `/code/kweaver/kweaver/deploy/README.zh.md`

**Step 1: Document behavior**

Explain that aggregate installs/downloads default to the latest embedded release manifest version when `--version` is omitted, and note the fallback when no manifest exists.

**Step 2: Re-run verification**

Run: `bash deploy/scripts/tests/test-version-manifest.sh`

Expected: PASS

### Task 5: Commit

**Step 1: Commit changes**

```bash
git add docs/plans deploy/scripts/lib/common.sh deploy/scripts/services/core.sh deploy/scripts/services/isf.sh deploy/scripts/services/dip.sh deploy/scripts/tests/test-version-manifest.sh deploy/README.md deploy/README.zh.md
git commit -m "feat(deploy): default to latest embedded release version"
```
