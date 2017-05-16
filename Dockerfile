FROM ubuntu:latest
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    gawk \
    git \
    lsof \
    qemu-user-static \
    realpath \
    sudo \
    unzip \
    zip
WORKDIR /octopi
COPY . /octopi
ENTRYPOINT ["/octopi/src/build"]
