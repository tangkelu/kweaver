# audit-log

文档库同步调度服务

## 简介

本 Chart 用于文档同步调度的服务端。

## 部署

1. 创建数据库 doc_sync_scheduler
2. 安装应用

## 安装

```shell
helm repo add acr https://acr.aishu.cn/chartrepo/as
mkdir audit-log
cd audit-log
vi deploy.yaml
helm install --name audit-log acr/audit-log
```

## 升级

```shell
helm upgrade --reuse-values audit-log acr/audit-log
```

## 配置

下属表格列出了 Chart 所有使用的配置以及其默认值

| Paramter                      |                     Description                     |                                                         Default |
| :---------------------------- | :-------------------------------------------------: | --------------------------------------------------------------: |
| `image.repository`            |                   服务端镜像名称                    |                                     `acr.aishu.cn/as/audit-log` |
| `image.tag`                   |                   服务端镜像 Tag                    |                                                        `latest` |
| `image.pullPolicy`            |                 服务端镜像拉取策略                  |                                                  `IfNotPresent` |
| `service.type`                |                    主机网络运行                     |                                                          `true` |
| `service.port`                |                      服务端口                       |                                                          `9605` |
| `service.debug`               |                服务端 Debug 模式开关                |                                                         `false` |
| `service.sharemgnt`           |              ShareMgnt Thrift 接口地址              |                                                     `127.0.0.1` |
| `depServices.rds.fromFile`    | 从配置文件`/sysvol/conf/cluster.conf`读取数据库配置 |                                                          `true` |
| `depServices.rds.user`        |                     数据库账号                      |                                                          `root` |
| `depServices.rds.password`    |                     数据库密码                      |                                                            `""` |
| `depServices.rds.host`        |                     数据库地址                      |                                                     `127.0.0.1` |
| `depServices.rds.port`        |                     数据库端口                      |                                                          `3320` |
| `depServices.rds.name`        |                     数据库名称                      |                                            `doc_sync_scheduler` |
| `service.logger.dir`          |                 服务端日志保存路径                  |                                                     `/var/log/` |
| `service.logger.filename`     |                     日志文件名                      |                                                    `server.log` |
| `service.logger.max_size`     |                    日志分割大小                     |                                                            `2M` |
| `service.logger.backup_count` |                  日志分割保留数量                   |                                                             `5` |
| `service.logger.formatter`    |                      日志格式                       | `%(asctime)s %(levelname)s %(pathname)s:%(lineno)d %(message)s` |
