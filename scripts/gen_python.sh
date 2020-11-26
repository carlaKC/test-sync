#!/bin/bash

virtualenv lnd
source lnd/bin/activate

pip install grpcio grpcio-tools googleapis-common-protos
git clone https://github.com/googleapis/googleapis.git

for i in "$@"
do
    cd "$i"
    python -m grpc_tools.protoc --proto_path=googleapis:. --python_out=. --grpc_python_out=. "$i"
    cd ..
done


