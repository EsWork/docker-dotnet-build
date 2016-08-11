all: build

build:
	@docker build --tag=johnwu/dotnet-build .

release: build
	@docker build --tag=johnwu/dotnet-build:$(shell cat VERSION) .
