# pulsar-client-cpp-examples

The examples of [Pulsar C++ Client](https://github.com/apache/pulsar-client-cpp).

## Before running

Make sure there is a Pulsar service listened on `localhost:6650`, the simplest way is to start a Pulsar standalone. Otherwise, you have to change the [config.h](./config.h).

## How to build on Linux or macOS

These examples only require a C++ compiler that supports C++11.

Assuming your Pulsar C++ Client library was installed under `$PULSAR_CPP`, like:

```bash
$ tree -L 2 $PULSAR_CLIENT_CPP
├── include
│   └── pulsar
└── lib
    ├── libpulsar.a
    └── libpulsar.so
```

You only needs to build the example code (e.g. `example.cc`) with the following command:

```bash
g++ example.cc -std=c++11 -I $PULSAR_CLIENT_CPP/include -L $PULSAR_CLIENT_CPP/lib -Wl,-rpath=$PULSAR_CLIENT_CPP/lib -lpulsar
```

If the application was built inside a docker while your Pulsar service ran on the host machine, you should add a macro like:

```bash
g++ example.cc -DINSIDE_DOCKER -std=c++11 -I $PULSAR_CLIENT_CPP/include -L $PULSAR_CLIENT_CPP/lib -Wl,-rpath=$PULSAR_CLIENT_CPP/lib -lpulsar
```

It would be much easier if the Pulsar C++ Client library was installed to the system path. In this case, you don't need to add the `-I` or `-L` option. The `-Wl,-rpath` option is still needed except the `libpulsar.so` exists on the `PATH` environment variables.

## Verify the RPM packages

Run a `centos:7` container:

```bash
docker run -v $PWD:/app -itd centos:7
```

Then login the container, and run `./rpm_x86_64_verify.sh`, which downloads the RPM packages and build applications with the given libraries:
- libpulsar.so
- libpulsar.a
- libpulsarwithdeps.a

## Windows (MSVC)

See [README.md](./pulsar-windows/README.md).
