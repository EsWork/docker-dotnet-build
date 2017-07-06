[![Build Status](https://travis-ci.org/EsWork/docker-dotnet-build.svg?branch=master)](https://travis-ci.org/EsWork/docker-dotnet-build)  

[![](https://images.microbadger.com/badges/version/eswork/dotnet-build.svg)](https://microbadger.com/images/eswork/dotnet-build "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/eswork/dotnet-build.svg)](https://microbadger.com/images/eswork/dotnet-build "Get your own image badge on microbadger.com")  
[![](https://images.microbadger.com/badges/version/eswork/dotnet-build:1.1.1.svg)](https://microbadger.com/images/eswork/dotnet-build:1.1.1 "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/eswork/dotnet-build:1.1.1.svg)](https://microbadger.com/images/eswork/dotnet-build:1.1.1 "Get your own image badge on microbadger.com")  
[![](https://images.microbadger.com/badges/version/eswork/dotnet-build:1.1.2.svg)](https://microbadger.com/images/eswork/dotnet-build:1.1.2 "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/eswork/dotnet-build:1.1.2.svg)](https://microbadger.com/images/eswork/dotnet-build:1.1.2 "Get your own image badge on microbadger.com")


Supported tags and respective `Dockerfile` links
---

- [`latest` , `1.1.2`  (1.1.2/Dockerfile)](https://github.com/EsWork/docker-dotnet-build/blob/master/Dockerfile)

Introduction
---

基于`docker image`编译.NET应用程序
- .NET Core SDK
- Nodejs
- Yarn
- bower
- glup
- webpack

Quickstart
---

一个`build.sh`工程构建脚本

```bash
#!/bin/sh
set -e
basepath=$(cd `dirname $0`; pwd)
dotnet restore ${basepath}
dotnet build ${basepath}
dotnet pack -c release ${basepath}
```

定义`docker-build.sh`脚本,挂载到容器上执行`build.sh`操作

```bash
basepath=$(cd `dirname $0`; pwd)
docker run --rm \
-v ${basepath}:/dotnet-build \
eswork/dotnet-build \
sh -c "chmod 755 /dotnet-build/build.sh && /dotnet-build/build.sh "
```


