# kweaver-core-local

本地联调用 umbrella chart。

用途：
- 直接引用 `/code/kweaver` 下已 checkout 的本地子 chart
- 验证 `global.*` 是否能从父 chart 透传到本地子 chart
- 不改正式的 `kweaver-core` OCI 依赖定义
- 默认不执行真实 `db-init`；如手工开启，也只会运行 busybox 占位日志 Job

当前接入的本地 chart：
- `agent-operator-integration`
- `operator-web`
- `agent-retrieval`
- `agent-backend`
- `agent-web`
- `coderunner`
- `dataflow`
- `ontology-query`
- `vega-web`
- `data-connection`
- `vega-gateway`
- `vega-gateway-pro`
- `mdl-data-model`
- `mdl-uniquery`
- `mdl-data-model-job`

未接入：
- `isf`
- `sandbox`
- 本地缺失源码的 `data-retrieval`、`agent-operator-app`、`ontology-manager`

## 用法

```bash
cd /code/kweaver/kweaver/deploy/charts/kweaver-core-local

helm dependency build
helm lint .
helm template kweaver-core-local . \
  -f /code/kweaver/kweaver/deploy/conf/products-values.yaml
```

如果只想看某一组模块：

```bash
helm template kweaver-core-local . \
  -f /code/kweaver/kweaver/deploy/conf/products-values.yaml \
  --set modules.agentoperator.enabled=true \
  --set modules.dataagent.enabled=false \
  --set modules.ontology.enabled=false
```

更新了本地子 chart 后，建议先清理再重建依赖：

```bash
rm -rf /code/kweaver/kweaver/deploy/charts/kweaver-core-local/charts \
       /code/kweaver/kweaver/deploy/charts/kweaver-core-local/Chart.lock
helm dependency build /code/kweaver/kweaver/deploy/charts/kweaver-core-local
```
