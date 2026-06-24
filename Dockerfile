FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    g++ \
    clang \
    ninja-build \
    libx11-dev \
    libxcursor-dev \
    libxi-dev \
    libxrandr-dev \
    libgl1-mesa-dev \
    libfontconfig1-dev \
    curl \
    unzip \
    ca-certificates \
    gpg \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://apt.kitware.com/keys/kitware-archive-latest.asc \
    | gpg --dearmor - > /usr/share/keyrings/kitware-archive-keyring.gpg \
    && echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' \
    > /etc/apt/sources.list.d/kitware.list \
    && apt-get update && apt-get install -y cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
