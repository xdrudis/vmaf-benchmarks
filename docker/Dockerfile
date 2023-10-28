FROM nvidia/cuda:12.1.1-devel-ubuntu22.04 AS build

RUN apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y -qq install --no-install-recommends \
      ninja-build \
      wget \
      doxygen \
      autoconf \
      automake \
      cmake \
      g++ \
      gcc \
      git \
      libdav1d-dev \
      pkg-config \
      make \
      nasm \
      xxd \
      curl \
      cuda-compat-12-1 \
      python3 python3-dev python3-distutils \
      yasm && \
   rm -fR /var/lib/apt/lists/*

RUN curl -sL https://bootstrap.pypa.io/get-pip.py | python3
RUN pip3 install meson

# af31e4c latest commit as of Oct'23
RUN mkdir -p /var/tmp/vmaf && \
   curl -sL  https://github.com/Netflix/vmaf/archive/af31e4c.tar.gz | tar xz -C /var/tmp/vmaf --strip-components=1 && \
   cd /var/tmp/vmaf && \
   meson setup libvmaf libvmaf/build --buildtype release --libdir="/usr/local/lib" -Denable_float=true -Denable_cuda=true ; \
   ninja -vC libvmaf/build install && \
   cp -r model /usr/local/share && \
   rm -fR /var/tmp/vmaf

# Latest master commit as of Oct'23 (cuda 12.0)
RUN mkdir -p /var/tmp/nv-codec-headers && \
    curl -sL https://github.com/FFmpeg/nv-codec-headers/archive/22441b5.tar.gz | tar xz -C /var/tmp/nv-codec-headers --strip-components=1 && \
    cd /var/tmp/nv-codec-headers && \
    make -j$(nproc) && \
    make install && \
    rm -fR /var/tmp/nv-codec-headers

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/cuda-12.1/compat
# latest commit as of Oct'23
RUN mkdir -p /var/tmp/ffmpeg && \
   curl -sL https://github.com/FFmpeg/FFmpeg/archive/1ad7bd0.tar.gz | tar xz -C /var/tmp/ffmpeg --strip-components=1 && \
   cd /var/tmp/ffmpeg && \
   ./configure --enable-libvmaf --enable-version3 --enable-shared --enable-libdav1d \
        --enable-cuda --enable-cuda-nvcc --enable-cuvid --enable-nonfree \
        --disable-doc --disable-ffplay --disable-network \
        --extra-ldflags="-L/usr/local/cuda/lib64" && \
   make -j$(nproc) || (cat ffbuild/config.log; exit 1) && \
   make install && \
   rm -fR /var/tmp/ffmpeg


#
# Runtime image
#
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

RUN apt-get -qq update && \
   DEBIAN_FRONTEND=noninteractive apt-get -y -qq install --no-install-recommends dav1d time jq parallel && \
   rm -fR /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/lib/"
COPY --from=build /usr/local /usr/local/

