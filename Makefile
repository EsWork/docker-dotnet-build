all: build

build:
	@docker build --tag=eswork/dotnet-build .

release: build
	@docker build --tag=eswork/dotnet-build:$(shell cat VERSION) .
