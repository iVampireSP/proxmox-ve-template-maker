# 自动镜像制作

此脚本可以很方便的制作 Cloud init 系统模板，用于快速创建以及配置虚拟机

## 使用方法

此脚本有以下几个参数。

storage: 存储池名称

vmbr: 虚拟机网桥名称

可选：user: Cloud init 用户名

可选：password: Cloud init 密码

可选：image

## 举例

下载并创建全部镜像到 local-lvm 中，网桥为 vmbr0，默认用户名 root，密码 123456。

```bash
bash image.sh local-lvm vmbr0 root 123456
```

下载 2000,ubuntu2204-jammy 镜像，存储是 local-lvm, 网桥为 vmbr1，默认用户名 root，密码 123456。

```bash
bash image.sh local-lvm vmbr1 root 123456 2000,ubuntu2204-jammy
```

## 更新镜像

重新执行脚本即可，此脚本会删除原来的虚拟机模板，然后重新执行 wget 并创建虚拟机模板。

## 添加镜像

编辑 image.sh，在最上面的 os_images 变量中添加镜像即可。

格式为 vmid,os_name。

比如 `2000,ubuntu2204-jammy`，其中 `2000` 是虚拟机模板的 `vmid`，`ubuntu2204-jammy` 是镜像名称。

创建后的虚拟机模板名字是 `Template-ubuntu2204-jammy`。
