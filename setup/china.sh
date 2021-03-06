#!/usr/bin/env sh
set -e

cp /etc/apt/sources.list /etc/apt/sources.list.bak
cat > /etc/apt/sources.list <<EOF
  deb http://mirrors.aliyun.com/debian/ jessie main non-free contrib
  deb http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib
  deb-src http://mirrors.aliyun.com/debian/ jessie main non-free contrib
  deb-src http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib
EOF

export NPM_REGISTRY="--registry=https://registry.npm.taobao.org"

exit 0