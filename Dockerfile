FROM buildpack-deps:jessie-curl
LABEL maintainer "v.la@live.cn"

ENV DOTNET_SDK_VERSION=1.1.0 \
    NUGET_XMLDOC_MODE=skip \  
    NODE_VERSION=8.4.0 \
    NPM_CONFIG_LOGLEVEL=info \
    NODE_PATH="/usr/local/lib/node_modules;/usr/local/lib/node_external_module" \
    DOTNET_SETUP_DIR=/usr/src/dotnet-build 

ARG BUILD_CHINA=false

COPY setup/ ${DOTNET_SETUP_DIR}/

RUN if [ ${BUILD_CHINA} ];then \
       chmod +x ${DOTNET_SETUP_DIR}/china.sh; \
       ${DOTNET_SETUP_DIR}/china.sh; \
    fi

RUN RUNTIME_DEPENDENCIES="libc6 \
        libcurl3 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu52 \
        liblttng-ust0 \
        libssl1.0.0 \
        libstdc++6 \
        libunwind8 \
        libuuid1 \
        zlib1g \
        python" \
&& BUILD_DEPENDENCIES="xz-utils " \
&& apt-get update \
&& apt-get install --no-install-recommends --no-install-suggests -y ${RUNTIME_DEPENDENCIES} ${BUILD_DEPENDENCIES}

##### ##### ##### ##### ##### ##### ##### ##### ##### #####
#                           
#               Install .Net Core SDK   
#
#  预先下载相应的依赖类库,可以加快每次编译需要的下载时间  
#  PS：还可以挂载到宿主机类库到指定目录下执行dotnet restore --packages <PACKAGES_DIRECTORY>
#                          
##### ##### ##### ##### ##### ##### ##### ##### ##### #####
RUN echo " Install .Net Core SDK  " \

&& cd "${DOTNET_SETUP_DIR}/" \
&& DOTNET_SDK_DOWNLOAD_URL="https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-dev-debian-x64.$DOTNET_SDK_VERSION.tar.gz" \
&& wget -cq ${DOTNET_SDK_DOWNLOAD_URL} -O "${DOTNET_SETUP_DIR}/dotnet.tar.gz" \
&& mkdir -p /usr/share/dotnet \
&& tar -zxf "${DOTNET_SETUP_DIR}/dotnet.tar.gz" -C /usr/share/dotnet \
&& ln -sf /usr/share/dotnet/dotnet /usr/bin/dotnet \

#缓存基础依赖类库到本地
&& dotnet restore ${DOTNET_SETUP_DIR} \
&& mkdir "${DOTNET_SETUP_DIR}/warmup" \
&& dotnet new mvc -o ${DOTNET_SETUP_DIR}/warmup \
&& rm -rf /tmp/NuGetScratch 

##### ##### ##### ##### ##### ##### ##### ##### ##### #####
#                           
#            Install Front Building Support
# 
#  1.初始安装的包将会存放在/usr/local/lib/node_modules
#  2.外部挂载地址存放在/usr/local/lib/node_external_module
#                       
##### ##### ##### ##### ##### ##### ##### ##### ##### #####
RUN echo "  Install Front Building Support " \
&& NPM_DEFAULT_PACKAGE="gulp-cli grunt-cli bower markdown-styles yarn gulp" \
&& cd "${DOTNET_SETUP_DIR}/" \
# gpg keys listed at https://github.com/nodejs/node#release-team
&& gpg --keyserver pool.sks-keyservers.net --recv-keys 94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
&& gpg --keyserver pool.sks-keyservers.net --recv-keys FD3A5288F042B6850C66B31F09FE44734EB7990E \
&& gpg --keyserver pool.sks-keyservers.net --recv-keys 71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
&& gpg --keyserver pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
&& gpg --keyserver pool.sks-keyservers.net --recv-keys C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \ 
&& gpg --keyserver pool.sks-keyservers.net --recv-keys B9AE9905FFD7803F25714661B63B535A4C206CA9 \
&& gpg --keyserver pool.sks-keyservers.net --recv-keys 56730D5401028683275BD23C23EFEFE93C4CFFFE \

&& wget -cq "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" -P ${DOTNET_SETUP_DIR}/ \
&& wget -cq "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" -P ${DOTNET_SETUP_DIR}/ \
&& gpg --batch --decrypt --output "SHASUMS256.txt" "SHASUMS256.txt.asc" \
&& grep "node-v$NODE_VERSION-linux-x64.tar.xz\$" "SHASUMS256.txt" | sha256sum -c - \
&& tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip=1 \
&& ln -s /usr/local/bin/node /usr/local/bin/nodejs \
&& mkdir -p /usr/local/lib/node_external_module \


&& echo " install npm. " \
#fix permission denied
&& chown -R $(whoami):root $(npm config get prefix)/{lib/node_modules,bin,share} \
&& npm install npm --loglevel warn -g ${NPM_REGISTRY} \

&& echo "install npm package.." \
&& npm install $NPM_DEFAULT_PACKAGE --loglevel warn -g ${NPM_REGISTRY} \

# cleanup
&& apt-get purge -y --auto-remove ${BUILD_DEPENDENCIES} \
&& rm -rf /var/lib/apt/lists/* \
&& cd / && rm -rf ${DOTNET_SETUP_DIR}/
