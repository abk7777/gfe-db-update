#!/bin/bash
IDX=1
for DEV in /dev/disk/by-id/nvme-Amazon_EC2_NVMe_Instance_Storage_*-ns-1; do
    mkfs.xfs ${DEV}
    mkdir -p /local${IDX}
    echo ${DEV} /local${IDX} xfs defaults,noatime 1 2 >> /etc/fstab
    IDX=$((${IDX} + 1))
done
mount -a
sudo yum update -y
sudo amazon-linux-extras install python3.8
sudo yum install git -y
cd /local1
chown -R ec2-user .
git clone https://github.com/abk7777/gfe-db.git
cd gfe-db
git checkout fix/optimize-build
python3.8 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -r requirements.txt



