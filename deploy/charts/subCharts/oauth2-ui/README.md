# web 客户端 oauth2-ui

# oauth2-ui

oauth2-ui 服务

## 简介

本 Chart 用于客户端 oauth2-ui 服务。

## 准备

### 添加镜像源

```shell
helm repo add as https://acr.aishu.cn/chartrepo/as
```

### 拉取镜像

```shell
docker pull acr.aishu.cn/as/oauth2-ui:mission
```

### 下载 Helm Chart 包

```shell

helm repo add as https://acr.aishu.cn/chartrepo/as

helm fetch as/oauth2-ui --version 0.0.0-mission
```

### 安装

```shell
helm install ./oauth2-ui-0.0.0-mission.tgz \
--name oauth2-ui \
--namespace oauth2-ui \
--set image.registry=acr.aishu.cn \
--set image.repository=as/oauth2-ui \
--set image.tag=7.0.0-mission \
--set depServices.eacp.publicHttpHost=10.2.180.88 \
--set depServices.eacp.publicHttpPort=443 \
--set depServices.eacp.privateHttpHost=10.2.180.88 \
--set depServices.eacp.privateHttpPort=9080
```

### 验证

```shell
kubectl -n oauth2-ui get pod
```

### 卸载

```shell
helm del --purge oauth2-ui
```

## 配置

下属表格列出了 Chart 定义的配置以及其默认值

| Paramter                           |    Description     |            Default | Required |
| :--------------------------------- | :----------------: | -----------------: | -------: |
| `name`                             |      服务名称      | `无,推荐oauth2-ui` |     `是` |
| `namespace`                        |      命名空间      |        `oauth2-ui` |     `否` |
| `image.registry`                   |   服务端镜像名称   |     `acr.aishu.cn` |       `` |
| `image.repository`                 |   服务端镜像名称   |    `/as/oauth2-ui` |     `是` |
| `image.tag`                        |   服务端镜像 Tag   |    `7.0.0-mission` |     `是` |
| `image.pullPolicy`                 | 服务端镜像拉取策略 |     `IfNotPresent` |     `否` |
| `service.type`                     |      运行模式      |         `NodePort` |     `否` |
| `service.port`                     |      服务端口      |            `30015` |     `否` |
| `service.logger`                   |    打印日志方式    |           `stdout` |     `否` |
| `env.language`                     |      容器语言      |    `Asia/Shanghai` |     `否` |
| `env.timezone`                     | 服务端镜像拉取策略 |     `IfNotPresent` |     `否` |
| `env.publicProtocol`               |    外部访问协议    |            `https` |     `否` |
| `env.privateProtocol`              |    内部访问协议    |             `http` |     `否` |
| `depServices.eacp.publicHttpHost`  |    外部访问 ip     |        `127.0.0.1` |     `是` |
| `depServices.eacp.publicHttpPort`  |    外部访问端口    |              `443` |     `是` |
| `depServices.eacp.publicProtocol`  |    外部访问协议    |            `https` |     `是` |
| `depServices.eacp.privateHttpHost` |    内部访问 ip     |        `127.0.0.1` |     `是` |
| `depServices.eacp.privateHttpPor`  |    内部访问端口    |             `9080` |     `是` |
| `depServices.eacp.privateProtocol` |    内部访问协议    |             `http` |     `是` |
| `depServices.hydra.administrativePrefix`| hydra的privateApi的pathname前缀  |  `/admin` （7.0.4.7新增）  |     `否` |
