go get -u github.com/aws/aws-lambda-go/cmd/build-lambda-zip

pushd src

pushd hello
go get
popd

popd