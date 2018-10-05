set GOOS=linux
set GOARCH=amd64

pushd src

pushd hello
go build -o ../../build/hello main.go
popd

pushd bye
go build -o ../../build/bye main.go
popd

popd

build-lambda-zip -o build/hello.zip build/hello
build-lambda-zip -o build/bye.zip build/bye