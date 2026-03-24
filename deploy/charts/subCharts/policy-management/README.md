# policy-management

策略管理服务

## 简介

本 Chart 用于策略管理的服务端。

## 部署

1. 创建数据库policy_mgnt
2. 安装应用

## 安装

```shell
helm repo add acr https://acr.aishu.cn/chartrepo/as
mkdir policy-management
cd policy-management
vi deploy.yaml
helm install --name policy-management acr/policy-management
```

## 升级

```shell
helm upgrade --reuse-values policy-management acr/policy-management
```

## 配置

下属表格列出了 Chart 所有使用的配置以及其默认值

| Paramter              |                     Description                     |                                                         Default |
| :-------------------- | :-------------------------------------------------: | --------------------------------------------------------------: |
| `image.repository`    |                   服务端镜像名称                    |                               `acr.aishu.cn:80/as/policy-management` |
| `image.tag`           |                   服务端镜像 Tag                    |                                                  `1.0.0` |
| `image.pullPolicy`    |                 服务端镜像拉取策略                  |                                                  `IfNotPresent` |
| `service.type`         |                    主机网络运行                     |                                                          `NodePort` |
| `service.port`                |                      服务端口                       |                                                          `9603` |
| `service.debug`               |                 服务端Debug模式开关                 |                                                         `false` |
| `service.sharemgnt`           |              ShareMgnt Thrift 接口地址              |                                                     `127.0.0.1` |
| `service.logger.dir`          |                 服务端日志保存路径                  |                                                     `/var/log/` |
| `service.logger.filename`     |                     日志文件名                      |                                                    `server.log` |
| `service.logger.max_size`     |                    日志分割大小                     |                                                            `2M` |
| `service.logger.backup_count` |                  日志分割保留数量                   |                                                             `5` |
| `service.logger.formatter`    |                      日志格式                       | `%(asctime)s %(levelname)s %(pathname)s:%(lineno)d %(message)s` |
| `service.networkPolicy.syncInterval`          |                 bundle文件定期推送到策略引擎周期                  |                                                     `600` |
| `service.networkPolicy.topic`          |                 提供给策略引擎的topic                  |                                                     `policy-data-topic` |
| `service.networkPolicy.message`          |                 提供给策略引擎的message                      |                                                     `{"policy_source_service": "policy-management"}` |
| `depServices.rds.fromFile`   | 从配置文件`/sysvol/conf/cluster.conf`读取数据库配置 |                                                          `true` |
| `depServices.rds.user`       |                     数据库账号                      |                                                          `root` |
| `depServices.rds.password`   |                     数据库密码                      |                                                            `""` |
| `depServices.rds.host`       |                     数据库地址                      |                                                     `127.0.0.1` |
| `depServices.rds.port`       |                     数据库端口                      |                                                          `3320` |
| `depServices.rds.name`       |                     数据库名称                      |                                                   `policy_mgnt_go` |
| `depServices.protonMQ.protocol`       |                     nsq使用的协议                      |                 `http` |
| `depServices.protonMQ.host`       |                     nsq的host                      |                                                     `127.0.0.1` |
| `depServices.protonMQ.producerPort`       |                     nsq的生产者连接的port                      |                                                    `4151` |
| `depServices.protonMQ.consumerPort`       |                     nsq的消费者连接的port                      |                                                    `4161` |
