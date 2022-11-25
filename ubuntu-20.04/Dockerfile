FROM ubuntu:20.04

RUN apt-get update -y && apt-get install -y curl gcc g++

ARG RELEASE_URL
ARG ARCH

WORKDIR /app
RUN curl -O -L ${RELEASE_URL}/deb-${ARCH}/apache-pulsar-client.deb
RUN curl -O -L ${RELEASE_URL}/deb-${ARCH}/apache-pulsar-client-dev.deb
RUN apt-get install ./apache-pulsar-client*.deb

COPY example.cc /app/
RUN g++ -o dynamic.out -std=c++11 ./example.cc -Wl,-rpath=/usr/lib -lpulsar
RUN g++ -o static.out -std=c++11 ./example.cc /usr/lib/libpulsarwithdeps.a -lpthread -ldl
