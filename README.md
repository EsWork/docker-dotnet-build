[![Build Status](https://travis-ci.org/EsWork/docker-dotnet-build.svg?branch=master)](https://travis-ci.org/EsWork/docker-dotnet-build)

Introduction
---

.NET Core 构建镜像
- .NET Core SDK 1.0.1
- Nodejs 6.10.1
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


