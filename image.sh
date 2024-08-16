#!/bin/bash

# 操作系统名字和链接，按需自行拓展和更新
declare -A os_images=(
    ["2000,ubuntu2204-jammy"]="https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/jammy/current/jammy-server-cloudimg-amd64.img"
    ["2001,debian12-bookworm"]="https://cloud.debian.org/images/cloud/bookworm/20230612-1409/debian-12-generic-amd64-20230612-1409.qcow2"
    ["2002,debian11-bullseye"]="https://cloud.debian.org/images/cloud/bullseye/20230601-1398/debian-11-generic-amd64-20230601-1398.qcow2"
    ["2003,almalinux8"]="https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
    ["2004,almalinux9"]="https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
    ["2005,rockylinux9"]="https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
    ["2006,rockylinux8"]="https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud-Base.latest.x86_64.qcow2"
)
















echo "------------------------"
echo "Auto image maker by iVampireSP.com"
echo "Leaflow 利飞 https://www.leaflow.cn"
echo "------------------------"

echo "全部镜像:"
for os in "${!os_images[@]}"; do
    IFS=',' read -r vmid os_name <<< "$os"
    echo "$os_name"
done

echo "------------------------"




# 下载操作系统镜像并创建虚拟机
download_image_and_create_vm() {
    local os=$1
    local image_url=$2

    local image_file="${download_dir}/$(basename "$image_url")"

    echo "下载镜像: $os"
    wget -c "$image_url" -O "$image_file"

    # 检查是否存在同名的虚拟机，如果存在则删除
    local template_name="Template-$os"
    # local existing_vmid=$(qm list | grep "$template_name" | awk '{print $1}')
    # if [ -n "$existing_vmid" ]; then
    #     echo "删除之前的虚拟机: $template_name"
    #     qm stop "$existing_vmid"
    #     qm destroy "$existing_vmid"
    # fi

    qm stop "$vmid"
    qm destroy "$vmid" --destroy-unreferenced-disks=1  --purge=1

    # 创建虚拟机
    qm create "$vmid" --name "$template_name" --memory 1024 --net0 virtio,bridge=$vmbr
    qm disk import "$vmid" "$image_file" "$storage"

    qm set "$vmid" --ostype l26 --ciuser="$user" --cipassword="$password" --virtio0 "$storage:vm-$vmid-disk-0" --boot c --bootdisk virtio0 --ide2 "$storage:cloudinit" --scsihw virtio-scsi-pci --serial0 socket --vga serial0

    # 转换为模板
    qm template "$vmid"

    # 启动虚拟机
    # qm start "$vmid"

    echo "镜像制作完成: $os"
    echo "虚拟机创建完成！"
}



# 检查参数
if [ $# -lt 3 ]; then
    echo "使用方法: $0 storage vmbr [user] [password] [image]"
    exit 1
fi

vmid=""
storage=$1
vmbr=$2
user=$3
password=$4
image=$5



# 如果没有指定存储，则使用默认存储
if [ -z "$storage" ]; then
    storage="local-lvm"
fi

# 如果没有指定用户，则使用默认用户
if [ -z "$user" ]; then
    user="root"
fi

# 如果没有指定密码，则使用默认密码
if [ -z "$password" ]; then
    password="password"
fi

# 如果没有指定 vmbr，则使用默认 vmbr0
if [ -z "$vmbr" ]; then
    vmbr="vmbr0"
fi

echo "默认存储: $storage"
echo "默认用户: $user"
echo "默认密码: $password"
echo "默认网桥: $vmbr"


# 检查镜像下载目录是否存在，如果不存在则创建
download_dir="/tmp/images_cache"
mkdir -p "$download_dir"

# 制作全部镜像或特定类型的镜像
if [ -z "$image" ]; then
    # 制作全部镜像
    for os in "${!os_images[@]}"; do
        IFS=',' read -r vmid os_name <<< "$os"
        echo "制作镜像: $os_name"
        download_image_and_create_vm "$os_name" "${os_images[$os]}"
    done
else
    # 制作特定类型的镜像
    if [ -z "${os_images[$image]}" ]; then
        echo "没有找到镜像: $image"
        exit 1
    fi

    IFS=',' read -r vmid os_name <<< "$image"
    download_image_and_create_vm "$os_name" "${os_images[$image]}"
fi
