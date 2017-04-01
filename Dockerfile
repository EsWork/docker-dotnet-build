FROM buildpack-deps:jessie-curl
LABEL maintainer "v.la@live.cn"

ENV DOTNET_SDK_VERSION=1.0.1 \
    NUGET_XMLDOC_MODE=skip \  
    NODE_VERSION=6.10.1 \
    NPM_CONFIG_LOGLEVEL=info \
    NODE_PATH="/user/local/lib/node_modules;/usr/local/lib/node_external_module" \
    DOTNET_SETUP_DIR=/usr/src/dotnet-build
    
ARG BUILD_CHINA=false

COPY setup/ ${DOTNET_SETUP_DIR}/

RUN bash ${DOTNET_SETUP_DIR}/install.sh
