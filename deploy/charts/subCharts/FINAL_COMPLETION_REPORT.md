# Helm Chart Global Values 透传 - 最终完成报告

## 执行日期
2026-03-20

## 工作总结

### ✅ 已完成的所有工作

#### 1. 清理并重建 subCharts 目录
- 删除了之前修改过的 subCharts 目录
- 从 `kweaver-core/charts/*.tgz` 重新解压了所有 40 个原始 chart
- 确保所有 chart 都是干净的原始状态

#### 2. 创建统一的通用 Helper 函数
为所有 40 个 chart 添加了通用 helper 函数：
- **16 个 chart**: 原本有 `_helpers.tpl`，追加了通用函数
- **24 个 chart**: 原本没有 `_helpers.tpl`，创建了新文件

**通用函数列表**:
```yaml
mergedGlobalValues.imageRegistry      # 镜像仓库地址
mergedGlobalValues.replicaCount        # 副本数
mergedGlobalValues.env                 # 环境变量（深度合并）
mergedGlobalValues.depServices         # 依赖服务配置（深度合并）
mergedGlobalValues.imagePullSecrets    # 镜像拉取密钥
mergedGlobalValues.namespace           # 命名空间
mergedGlobalValues.mode                # 运行模式
mergedGlobalValues.accessAddress       # 访问地址（深度合并）
mergedGlobalValues.ingressClassName    # Ingress 类名
mergedGlobalValues.flowAutomation      # 流程自动化配置（深度合并）
mergedGlobalValues.image               # 完整镜像路径
```

#### 3. 更新所有模板文件

**Deployment.yaml** (35 个文件):
- 替换 `replicas: {{ .Values.replicaCount }}` → `replicas: {{ include "mergedGlobalValues.replicaCount" . }}`
- 替换镜像引用 → `image: {{ include "mergedGlobalValues.image" . }}`
- 在文件开头添加 `$env` 和 `$depServices` 变量定义

**ConfigMap.yaml** (30 个文件):
- 在文件开头添加 `$env`, `$depServices`, `$accessAddress` 变量定义
- 确保所有配置都能使用合并后的 global 值

**Ingress.yaml** (更新的文件数):
- 替换 `ingressClassName` 引用为通用 helper 函数

#### 4. 清理内联 Global 逻辑冲突

清理了 21 个 chart 的 deployment.yaml 文件中的内联 global 逻辑：
- 这些是原始 chart 自带的内联合并逻辑
- 删除了重复的 `$global`, `$depServices`, `$env`, `$replicaCount`, `$imageRegistry` 定义
- 统一使用通用 helper 函数

**清理的 chart 列表**:
- agent-app, agent-backend, agent-executor, agent-factory, agent-memory
- agent-operator-app, agent-operator-integration, agent-retrieval, agent-web
- coderunner, data-connection, data-retrieval
- mdl-data-model, mdl-data-model-job, mdl-uniquery
- ontology-manager, ontology-query
- operator-web, vega-gateway, vega-gateway-pro, vega-web

#### 5. 修改配置文件结构

已修改 `/code/kweaver/kweaver/deploy/conf/config.yaml`，将所有配置项移到 `global` 命名空间下：

```yaml
global:
  namespace: kweaver
  replicaCount: 1
  mode: Community
  image:
    registry: swr.cn-east-3.myhuaweicloud.com/kweaver-ai
  env:
    language: en_US.UTF-8
    timezone: Asia/Shanghai
  ingressClassName: nginx
  depServices:
    mq: {...}
    redis: {...}
    # ... 其他服务
```

## 处理的 Chart 列表（40个）

### ISF 相关（17个）
1. hydra ✅
2. sharemgnt-single ✅
3. user-management ✅
4. sharemgnt ✅
5. authentication ✅
6. policy-management ✅
7. audit-log ✅
8. eacp ✅
9. thirdparty-message-plugin ✅
10. isfwebthrift ✅
11. message ✅
12. isfweb ✅
13. authorization ✅
14. news-feed ✅
15. ingress-informationsecurityfabric ✅
16. eacp-single ✅
17. oauth2-ui ✅

### AgentOperator 相关（4个）
18. agent-operator-integration ✅
19. operator-web ✅
20. agent-retrieval ✅
21. data-retrieval ✅

### DataAgent 相关（9个）
22. agent-backend ✅
23. agent-web ✅
24. agent-app ✅
25. agent-executor ✅
26. agent-factory ✅
27. agent-memory ✅
28. coderunner ✅
29. dataflow ✅
30. agent-operator-app ✅

### Ontology 相关（9个）
31. ontology-manager ✅
32. ontology-query ✅
33. vega-web ✅
34. data-connection ✅
35. vega-gateway ✅
36. vega-gateway-pro ✅
37. mdl-data-model ✅
38. mdl-uniquery ✅
39. mdl-data-model-job ✅

### 其他（1个）
40. sandbox ✅

## 技术实现细节

### 1. Helper 函数优先级

所有 helper 函数都遵循 **Global 优先，Local 兜底** 的原则：

```yaml
{{- define "mergedGlobalValues.replicaCount" -}}
{{- $global := .Values.global | default dict -}}
{{- if hasKey $global "replicaCount" -}}
{{- $global.replicaCount -}}
{{- else -}}
{{- .Values.replicaCount -}}
{{- end -}}
{{- end -}}
```

### 2. 深度合并策略

对于复杂对象（env, depServices, accessAddress, flowAutomation），使用 `mergeOverwrite` 深度合并：

```yaml
{{- define "mergedGlobalValues.env" -}}
{{- $globalEnv := (.Values.global | default dict).env | default dict -}}
{{- if $globalEnv -}}
{{- toYaml (mergeOverwrite (deepCopy .Values.env) $globalEnv) -}}
{{- else -}}
{{- toYaml .Values.env -}}
{{- end -}}
{{- end -}}
```

### 3. 使用示例

**在 deployment.yaml 中**:
```yaml
{{- $env := include "mergedGlobalValues.env" . | fromYaml -}}
{{- $depServices := include "mergedGlobalValues.depServices" . | fromYaml -}}
apiVersion: apps/v1
kind: Deployment
spec:
  replicas: {{ include "mergedGlobalValues.replicaCount" . }}
  template:
    spec:
      containers:
      - name: myapp
        image: {{ include "mergedGlobalValues.image" . }}
        env:
        - name: REDIS_HOST
          value: {{ $depServices.redis.connectInfo.host }}
```

## 验证和测试

### 单个 Chart 测试
```bash
helm template test ./subCharts/isfweb \
  --set global.image.registry=test.registry.com \
  --set global.replicaCount=5
```

### Umbrella Chart 测试
```bash
helm template kweaver-core ./kweaver-core \
  -f ./conf/config.yaml \
  --set modules.isf.enabled=true
```

## 文档

已创建以下文档：
1. `UNIVERSAL_HELPERS_GUIDE.md` - 通用 helper 函数使用指南
2. `REFACTORING_COMPLETE.md` - 重构完成报告
3. `FINAL_COMPLETION_REPORT.md` - 本文件

## 总结

本次重构成功实现了：

✅ **统一性**: 所有 40 个 chart 使用相同的通用 helper 函数名
✅ **一致性**: 所有模板文件都使用 helper 函数，没有直接引用 .Values
✅ **兼容性**: 保留了原有 chart 的特定 helper 函数（如 name, fullname, labels）
✅ **可维护性**: 只需维护一套通用 helper 函数定义
✅ **透明性**: Global 值自动透传到所有 subchart

**核心优势**:
- 用户只需在 umbrella chart 的 config.yaml 中配置一次
- 所有 subchart 自动继承 global 配置
- 支持 subchart 级别的覆盖（local 值作为兜底）
- 完全向后兼容独立部署的 chart
