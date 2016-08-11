#FROM microsoft/dotnet:1.0.0-preview2-sdk
FROM johnwu/debian:jessie
MAINTAINER JohnWu "v.la@live.cn"

ENV DOTNET_SDK_VERSION=1.0.0-preview2 \
    NUGET_XMLDOC_MODE=skip \  
    NODE_VERSION=4.4.7 \
    NPM_CONFIG_LOGLEVEL=info \
    DOTNET_SETUP_DIR=/usr/src/dotnet-build

ARG NPM_REGISTRY="--registry=https://registry.npm.taobao.org"

COPY setup/ ${DOTNET_SETUP_DIR}/

RUN bash ${DOTNET_SETUP_DIR}/install.sh
