#!/bin/bash

set -e -u -x

export GOPATH=$PWD/gopath          
export PATH=$PWD/gopath/bin:$PATH

cd code/services/$SERVICE

echo
echo "Building $SERVICE..."
go build -o main .