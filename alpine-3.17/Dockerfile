FROM alpine:3.17

RUN apk update && apk add curl gcc g++

ARG RELEASE_URL
ARG ARCH
ARG VERSION

WORKDIR /app
RUN curl -O -L ${RELEASE_URL}/apk-${ARCH}/${ARCH}/apache-pulsar-client-${VERSION}-r0.apk
RUN curl -O -L ${RELEASE_URL}/apk-${ARCH}/${ARCH}/apache-pulsar-client-dev-${VERSION}-r0.apk
RUN apk add --allow-untrusted ./apache-pulsar-client-*.apk

COPY example.cc /app/
RUN g++ -o dynamic.out -std=c++11 ./example.cc -Wl,-rpath=/usr/lib -lpulsar
RUN g++ -o static.out -std=c++11 ./example.cc /usr/lib/libpulsarwithdeps.a -lpthread -ldl
