set GOOS=linux
set GOARCH=amd64

pushd src

pushd hello
go build -o ../../build/hello main.go
popd

popd

build-lambda-zip -o build/hello.zip build/hello