#!/bin/bash
set -e

DOTNET_SDK_DOWNLOAD_URL="https://go.microsoft.com/fwlink/?LinkID=809130"

RUNTIME_DEPENDENCIES="libc6 \
        libcurl3 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu52 \
        liblttng-ust0 \
        libssl1.0.0 \
        libstdc++6 \
        libunwind8 \
        libuuid1 \
        zlib1g "
BUILD_DEPENDENCIES="xz-utils "

${BUILD_CHINA} && {
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cat > /etc/apt/sources.list <<EOF
  deb http://mirrors.aliyun.com/debian/ jessie main non-free contrib
  deb http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib
  deb-src http://mirrors.aliyun.com/debian/ jessie main non-free contrib
  deb-src http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib

EOF

cp /etc/apt/sources.list.bak /etc/apt/sources.list
rm /etc/apt/sources.list.bak
}

apt-get update 
apt-get install --no-install-recommends --no-install-suggests -y ${RUNTIME_DEPENDENCIES} ${BUILD_DEPENDENCIES}

##### ##### ##### ##### ##### ##### ##### ##### ##### #####
#                           
#               Install .Net Core SDK   
#
#  ${DOTNET_SETUP_DIR}/project.json文件主要用来下载类库到本地
#  预先下载相应的依赖类库,可以加快每次编译需要的下载时间  
#  PS：还可以挂载到宿主机类库到/root/.nuget/package目录下
#                          
##### ##### ##### ##### ##### ##### ##### ##### ##### #####
wget -cq ${DOTNET_SDK_DOWNLOAD_URL} -O "${DOTNET_SETUP_DIR}/dotnet.tar.gz"
mkdir -p /usr/share/dotnet
tar -zxf "${DOTNET_SETUP_DIR}/dotnet.tar.gz" -C /usr/share/dotnet
ln -sf /usr/share/dotnet/dotnet /usr/bin/dotnet
#缓存基础依赖类库到本地
dotnet restore ${DOTNET_SETUP_DIR}
rm -rf /tmp/NuGetScratch

##### ##### ##### ##### ##### ##### ##### ##### ##### #####
#                           
#            Install Front Building Support
# 
#  1.初始安装的包将会存放在/user/local/lib/node_modules
#  2.外部挂载地址存放在/usr/local/lib/node_external_module
#                       
##### ##### ##### ##### ##### ##### ##### ##### ##### #####
for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

cd ${DOTNET_SETUP_DIR}/
wget -cq "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" -P ${DOTNET_SETUP_DIR}/
wget -cq "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" -P ${DOTNET_SETUP_DIR}/
gpg --batch --decrypt --output "SHASUMS256.txt" "SHASUMS256.txt.asc"
grep "node-v$NODE_VERSION-linux-x64.tar.xz\$" "SHASUMS256.txt" | sha256sum -c -
tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip=1

mkdir -p /usr/local/lib/node_external_module

#安装必要包
${BUILD_CHINA} && {
  NPM_REGISTRY="--registry=https://registry.npm.taobao.org"
}
npm install npm --loglevel warn -g ${NPM_REGISTRY}
npm install $(cat ${DOTNET_SETUP_DIR}/npm.txt) --loglevel warn -g ${NPM_REGISTRY}

# cleanup
apt-get purge -y --auto-remove ${BUILD_DEPENDENCIES}
rm -rf /var/lib/apt/lists/*
rm -rf ${DOTNET_SETUP_DIR}/
