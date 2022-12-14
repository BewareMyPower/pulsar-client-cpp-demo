# pulsar-client-cpp-examples

The examples of [Pulsar C++ Client](https://github.com/apache/pulsar-client-cpp).

It's also helpful for verifying the official releases of the C++ client.

## Verify the signature

You must first import the KEY file first. For example:

```bash
curl -O -L https://dist.apache.org/repos/dist/dev/pulsar/KEYS
gpg --import KEYS
```

Then, for any file, you can use [verify.sh](./verify.sh) to verify the release. For example:

```bash
./verify.sh https://dist.apache.org/repos/dist/dev/pulsar/pulsar-client-cpp/pulsar-client-cpp-3.1.0-candidate-3/apache-pulsar-client-cpp-3.1.0.tar.gz
```

You will see the following outputs if there is nothing wrong:

```
[OK] GPG verified
[OK] SHA512 verified
```

## Windows (MSVC)

See [README.md](./windows/README.md).

## Linux

Make sure there is a Pulsar service listened on `localhost:6650`. Then build the [./example.cc](example.cc) inside the Linux docker containers.

This project provides some Dockerfiles to:
- Install the official released Linux packages into system paths
- Build `dynamic.out` from [`example.cc`](./example.cc) by linking dynamically to `libpulsar.so`
- Build `static.out` from [`example.cc`](./example.cc) by linking statically to `libpulsarwithdeps.a`

The executable accepts an argument that represents the service URL of Pulsar. If your host system is Linux, use `pulsar://172.17.0.1:6650`. If your host system is Windows or macOS, use `pulsar://host.docker.internal:6650`.

### RPM

Verify the official RPM packages inside a CentOS 7 docker container.

```bash
docker build . -f ./centos-7/Dockerfile \
  --build-arg RELEASE_URL=https://dist.apache.org/repos/dist/dev/pulsar/pulsar-client-cpp/pulsar-client-cpp-3.1.0-candidate-1/ \
  --build-arg ARCH=x86_64 \
  --build-arg VERSION=3.1.0 \
  -t pulsar-cpp-centos7
docker run -it --rm pulsar-cpp-centos7 /app/dynamic.out pulsar://172.17.0.1:6650
docker run -it --rm pulsar-cpp-centos7 /app/static.out pulsar://172.17.0.1:6650
```

### DEB

Verify the official DEB packages inside a Ubuntu 20.04 docker container.

```bash
docker build . -f ./ubuntu-20.04/Dockerfile \
  --build-arg RELEASE_URL=https://dist.apache.org/repos/dist/dev/pulsar/pulsar-client-cpp/pulsar-client-cpp-3.1.0-candidate-1/ \
  --build-arg ARCH=x86_64 \
  -t pulsar-cpp-ubuntu-20.04
docker run -it --rm pulsar-cpp-ubuntu-20.04 /app/dynamic.out pulsar://172.17.0.1:6650
docker run -it --rm pulsar-cpp-ubuntu-20.04 /app/static.out pulsar://172.17.0.1:6650
```

### APK

Verify the official APK packages inside a Alpine 3.17 docker container.

```bash
# Here we add --network=host to reuse the proxy on host.
# See https://github.com/gliderlabs/docker-alpine/issues/445
docker build . -f ./alpine-3.17/Dockerfile \
  --network=host \
  --build-arg RELEASE_URL=https://dist.apache.org/repos/dist/dev/pulsar/pulsar-client-cpp/pulsar-client-cpp-3.1.0-candidate-1/ \
  --build-arg ARCH=x86_64 \
  --build-arg VERSION=3.1.0 \
  -t pulsar-cpp-alpine-3.17
docker run -it --rm pulsar-cpp-alpine-3.17 /app/dynamic.out pulsar://172.17.0.1:6650
docker run -it --rm pulsar-cpp-alpine-3.17 /app/static.out pulsar://172.17.0.1:6650
```
