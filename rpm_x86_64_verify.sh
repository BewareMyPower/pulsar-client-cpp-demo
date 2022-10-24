#!/usr/bin/bash
set -e
cd `dirname $0`

if [[ $(id -u) -ne 0  ]]; then
    echo "This script must be run with root"
    exit 1
fi

yum update -y
yum install -y curl gcc gcc-c++ make which

download() {
    curl -O -L $1
}

URL_PATH="https://dist.apache.org/repos/dist/dev/pulsar/pulsar-client-cpp-3.0.0-candidate-3/rpm-x86_64/x86_64"
download $URL_PATH/apache-pulsar-client-3.0.0-1.x86_64.rpm
download $URL_PATH/apache-pulsar-client-3.0.0-1.x86_64.rpm.asc
download $URL_PATH/apache-pulsar-client-3.0.0-1.x86_64.rpm.sha512
download $URL_PATH/apache-pulsar-client-3.0.0-1.x86_64.rpm
download $URL_PATH/apache-pulsar-client-3.0.0-1.x86_64.rpm.asc
download $URL_PATH/apache-pulsar-client-3.0.0-1.x86_64.rpm.sha512
download $URL_PATH/apache-pulsar-client-debuginfo-3.0.0-1.x86_64.rpm
download $URL_PATH/apache-pulsar-client-debuginfo-3.0.0-1.x86_64.rpm.asc
download $URL_PATH/apache-pulsar-client-debuginfo-3.0.0-1.x86_64.rpm.sha512
download $URL_PATH/apache-pulsar-client-devel-3.0.0-1.x86_64.rpm
download $URL_PATH/apache-pulsar-client-devel-3.0.0-1.x86_64.rpm.asc
download $URL_PATH/apache-pulsar-client-devel-3.0.0-1.x86_64.rpm.sha512
set +e
rpm -ivh apache-pulsar-client-*.rpm
set -e

CXX_FLAGS="-DINSIDE_DOCKER -std=c++11"
set -x

# Link to libpulsar.so
g++ example.cc $CXX_FLAGS -Wl,-rpath=/usr/lib -lpulsar
./a.out

# Link to libpulsarwithdeps.a
g++ example.cc $CXX_FLAGS /usr/lib/libpulsarwithdeps.a -lpthread -ldl
./a.out

# TODO: the default boost-devel seems not work 
echo "There is something wrong with libpulsar.a build"
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
download https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_1_1_1q.tar.gz
tar zxf OpenSSL_1_1_1q.tar.gz
cd openssl-OpenSSL_1_1_1q/
./Configure -fPIC linux-x86_64
make -j4 && make install
cd -

# Link to libpulsar.a
g++ example.cc $CXX_FLAGS /usr/lib/libpulsar.a \
    -I /usr/local/include \
    -lboost_regex -lboost_system \
    -L /usr/local/lib \
    -lz -lzstd -lsnappy -lprotobuf -lcurl \
    -L /usr/local/lib64 -Wl,-rpath=/usr/local/lib64:/usr/local/lib \
    -lssl -lcrypto \
    -lpthread -ldl
