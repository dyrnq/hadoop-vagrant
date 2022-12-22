#!/usr/bin/env bash


sed -i "s@http://.*archive.ubuntu.com@http://mirrors.sustech.edu.cn@g" /etc/apt/sources.list
sed -i "s@http://.*security.ubuntu.com@http://mirrors.sustech.edu.cn@g" /etc/apt/sources.list


while true ; do
    apt update -y && \
    apt install -y xfsprogs lvm2 && \
    break
done


if fdisk -l | grep vg ; then
    :
else
disk="/dev/sda"

(echo n; echo p; echo 1; echo ; echo ; echo w) | fdisk "${disk}"

fdisk -l "${disk}"

(echo t; echo 8e; echo w) | fdisk "${disk}"

fdisk -l "${disk}"

pvcreate "${disk}"1
vgcreate vg1 "${disk}"1


lvcreate --size 200G --name lv1 vg1
lvcreate --size 280G --name lv2 vg1

mkfs.xfs /dev/vg1/lv1
mkfs.xfs /dev/vg1/lv2

{
    echo "/dev/vg1/lv1 /var/lib/docker/                     xfs     defaults        0 0"
    echo "/dev/vg1/lv2 /data                                xfs     defaults        0 0"
} >> /etc/fstab


mkdir -p /var/lib/docker
mkdir -p /data
mount --all


fi