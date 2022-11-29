# Aloha-Client

## 所需环境
* GIT
* Docker-Compose
* Node
* npm

## 下载nodejs依赖

```sh
npm install
```

## 在本地运行RChain节点

在aloha-client目录下面运行terminal

整个流程由[package.json](package.json)中的预定义指令操纵

通过`aloha-install`运行Aloha、RChain、Postgresql镜像

```sh
npm run aloha-install
```

查看镜像日志

```sh
# 查看所有镜像日志
npm run dc -- logs -f

# 仅查看boot镜像日志
npm run dc -- logs -f boot
```

### 联系管理员修改服务器配置文件

### 检查镜像是否运行成功

RNode: [http://localhost:40403/status](http://localhost:40403/status)

（若运行出错可查看日志排查错误原因）

## 注册账号

向管理员说明镜像运行成功，管理员会给你发送注册账号的邀请链接。

## 部署智能合约

```sh
npm run data-sync
```
将输出的uri赋值给[**.env**](.env)文件的 __DATA_SYNC_URI__ 

_提示: 每次重新运行`data-sync` 重新部署时需要重新更新 __.env__ 文件。_

## 链接Aloha服务器与RChain节点

```sh
npm start
```
