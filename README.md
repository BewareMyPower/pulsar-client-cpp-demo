# pulsar-client-cpp-examples

The examples of [Pulsar C++ Client](https://github.com/apache/pulsar-client-cpp).

## Windows (MSVC)

See [README.md](./pulsar-windows/README.md).

## Linux

Make sure there is a Pulsar service listened on `localhost:6650`. Then build the [./example.cc](example.cc) inside the Linux docker containers.

This project provides some Dockerfiles to:
- Install the official released Linux packages into system paths
- Build `dynamic.out` from [`example.cc`](./example.cc) by linking dynamically to `libpulsar.so`
- Build `static.out` from [`example.cc`](./example.cc) by linking statically to `libpulsarwithdeps.a`

### RPM

Verify the official RPM packages inside a CentOS 7 docker container.

```bash
docker build . -f ./centos-7/Dockerfile \
  --build-arg RELEASE_URL=https://dist.apache.org/repos/dist/dev/pulsar/pulsar-client-cpp/pulsar-client-cpp-3.1.0-candidate-1/ \
  --build-arg ARCH=x86_64 \
  --build-arg VERSION=3.1.0 \
  -t pulsar-cpp-centos7
docker run -it --rm centos7-pulsar-cpp /app/dynamic.out pulsar://172.17.0.1:6650
docker run -it --rm centos7-pulsar-cpp /app/static.out pulsar://172.17.0.1:6650
```

> **NOTE**
>
> If your host system is Windows or macOS, use `host.docker.internal` instead of `172.17.0.1` to access the host from the container.
