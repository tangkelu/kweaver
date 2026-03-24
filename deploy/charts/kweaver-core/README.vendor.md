# KWeaver Core Vendor Chart Workflow

这个目录当前使用本地 vendor 依赖，而不是远端 OCI 仓库。

## 依赖来源

- 发布 chart 来源：`/code/kweaver/helm-repo/packages`
- 依赖选择清单：`/code/kweaver/kweaver/deploy/charts/subCharts/selection.yaml`
- vendor 解包目录：`/code/kweaver/kweaver/deploy/charts/subCharts`

## 重新构建

```bash
helm dependency build /code/kweaver/kweaver/deploy/charts/kweaver-core
```

## 本地验证

```bash
helm lint /code/kweaver/kweaver/deploy/charts/kweaver-core \
  -f /code/kweaver/kweaver/deploy/conf/products-values.yaml \
  --set modules.isf.enabled=false

helm template kweaver-core /code/kweaver/kweaver/deploy/charts/kweaver-core \
  -f /code/kweaver/kweaver/deploy/conf/products-values.yaml \
  --set modules.isf.enabled=false >/tmp/kweaver-core.render.yaml
```

## 打包

```bash
mkdir -p /tmp/kweaver-core-package
helm package /code/kweaver/kweaver/deploy/charts/kweaver-core -d /tmp/kweaver-core-package
```

## 说明

- `subCharts` 是一次性本地 vendor 工作区，不回写 `helm-repo`
- 当前先跳过 ISF chart 模板改造，验证时使用 `modules.isf.enabled=false`
- 为了适配 1 核测试机，vendor chart 的 `resources.requests.cpu` 已统一下调为 `0.01`
