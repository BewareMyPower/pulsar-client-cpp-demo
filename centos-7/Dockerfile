FROM centos:7

ARG RELEASE_URL
ARG ARCH
ARG VERSION

RUN yum update -y && yum install -y curl gcc gcc-c++ make which

WORKDIR /app
RUN curl -O -L ${RELEASE_URL}/rpm-${ARCH}/${ARCH}/apache-pulsar-client-${VERSION}-1.${ARCH}.rpm
RUN curl -O -L ${RELEASE_URL}/rpm-${ARCH}/${ARCH}/apache-pulsar-client-debuginfo-${VERSION}-1.${ARCH}.rpm
RUN curl -O -L ${RELEASE_URL}/rpm-${ARCH}/${ARCH}/apache-pulsar-client-devel-${VERSION}-1.${ARCH}.rpm
RUN rpm -ivh apache-pulsar-client-*.rpm

COPY example.cc /app/
RUN g++ -o dynamic.out -std=c++11 ./example.cc -Wl,-rpath=/usr/lib -lpulsar
RUN g++ -o static.out -std=c++11 ./example.cc /usr/lib/libpulsarwithdeps.a -lpthread -ldl
