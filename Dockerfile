FROM buildpack-deps:jessie-curl
LABEL maintainer "v.la@live.cn"

ENV DOTNET_SDK_VERSION=1.0.1 \
    NUGET_XMLDOC_MODE=skip \  
    NODE_VERSION=8.0.0 \
    NPM_CONFIG_LOGLEVEL=info \
    YARN_VERSION=0.24.6 \
    NODE_PATH="/usr/local/lib/node_modules;/usr/local/lib/node_external_module" \
    DOTNET_SETUP_DIR=/usr/src/dotnet-build
    
ARG BUILD_CHINA=false

COPY setup/ ${DOTNET_SETUP_DIR}/

RUN bash ${DOTNET_SETUP_DIR}/install.sh
