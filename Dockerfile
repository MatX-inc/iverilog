# Run as
#   docker build --build-arg REV=$(git rev-parse --short v12-branch) -t iverilog .
#   docker create --name temp_container iverilog
#   docker cp temp_container:/iverilog-9efd54caf.tgz iverilog-$(git rev-parse --short v12-branch).tgz
#   docker rm temp_container

FROM ubuntu:22.04

ARG REV

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt update -qq && \
    apt install -y make g++ git bison flex gperf libreadline-dev autoconf python3-sphinx

WORKDIR /iverilog

COPY . /iverilog
RUN autoconf
RUN ./configure --prefix=/iverilog-$REV
RUN make -j check
RUN make install
RUN make check
RUN cd / && tar zcf /iverilog-$REV.tgz /iverilog-$REV
