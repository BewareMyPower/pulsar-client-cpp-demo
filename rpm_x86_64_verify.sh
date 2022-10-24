#!/usr/bin/bash
set -e
cd `dirname $0`

if [[ $(id -u) -ne 0  ]]; then
    echo "This script must be run with root"
    exit 1
fi

yum update -y
yum install -y curl gcc gcc-c++ make

CURL=$(which curl)

download() {
    $CURL -O -L $1
}

PATH="https://dist.apache.org/repos/dist/dev/pulsar/pulsar-client-cpp-3.0.0-candidate-3/rpm-x86_64/x86_64"
download $PATH/apache-pulsar-client-3.0.0-1.x86_64.rpm
download $PATH/apache-pulsar-client-3.0.0-1.x86_64.rpm.asc
download $PATH/apache-pulsar-client-3.0.0-1.x86_64.rpm.sha512
download $PATH/apache-pulsar-client-3.0.0-1.x86_64.rpm
download $PATH/apache-pulsar-client-3.0.0-1.x86_64.rpm.asc
download $PATH/apache-pulsar-client-3.0.0-1.x86_64.rpm.sha512
download $PATH/apache-pulsar-client-debuginfo-3.0.0-1.x86_64.rpm
download $PATH/apache-pulsar-client-debuginfo-3.0.0-1.x86_64.rpm.asc
download $PATH/apache-pulsar-client-debuginfo-3.0.0-1.x86_64.rpm.sha512
download $PATH/apache-pulsar-client-devel-3.0.0-1.x86_64.rpm
download $PATH/apache-pulsar-client-devel-3.0.0-1.x86_64.rpm.asc
download $PATH/apache-pulsar-client-devel-3.0.0-1.x86_64.rpm.sha512

CXX_FLAGS="-DINSIDE_DOCKER -std=c++11"

# Link to libpulsar.so
g++ example.cc $CXX_FLAGS -Wl,-rpath=/usr/lib -lpulsar
./a.out

# Link to libpulsarwithdeps.a
g++ example.cc $CXX_FLAGS
g++ example.cc $CXX_FLAGS /usr/lib/libpulsarwithdeps.a -lpthread -ldl
./a.out

# TODO: the default boost-devel seems not work 
echo "There is something wrong with libpulsar.a build"
exit 0
# Install dependencies to link to libpulsar.a
# zstd, snappy and protobuf must be built from source on CentOS 7
yum install -y curl-devel openssl-devel zlib-devel boost-devel
download https://github.com/facebook/zstd/releases/download/v1.5.2/zstd-1.5.2.tar.gz
tar zxf zstd-1.5.2.tar.gz
cd zstd-1.5.2
make -j4 && make install
cd -
download https://github.com/Kitware/CMake/releases/download/v3.24.2/cmake-3.24.2-linux-x86_64.tar.gz
tar zxf cmake-3.24.2-linux-x86_64.tar.gz
download https://github.com/google/snappy/archive/refs/tags/1.1.9.tar.gz
tar zxf 1.1.9.tar.gz
cd snappy-1.1.9/
../cmake-3.24.2-linux-x86_64/bin/cmake . -DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF
make -j4 && make install
cd -
download https://github.com/protocolbuffers/protobuf/releases/download/v3.20.3/protobuf-cpp-3.20.3.tar.gz
tar zxf protobuf-cpp-3.20.3.tar.gz
cd protobuf-3.20.3/
./configure && make -j4 && make install
cd -

# Link to libpulsar.a
g++ example.cc $CXX_FLAGS /usr/lib/libpulsar.a -lpthread -ldl -lprotobuf -lz -lzstd -lsnappy -lboost_regex -lboost_system -lssl -lcrypto -lcurl
