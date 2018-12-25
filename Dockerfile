FROM ubuntu:18.04

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libpng-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-dev \
        rsync \
        software-properties-common \
        unzip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip --no-cache-dir install \
        Pillow \
        h5py \
        ipykernel \
        jupyter \
        keras_applications \
        keras_preprocessing \
        matplotlib \
        numpy \
        pandas \
        scipy \
        sklearn \
        && \
    python -m ipykernel.kernelspec

# Install TensorFlow CPU version from central repo
RUN pip --no-cache-dir install \
    https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.8.0-cp27-none-linux_x86_64.whl

RUN apt-get update && apt-get install -y git

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN curl -fsSL https://dl.google.com/go/go1.11.1.linux-amd64.tar.gz -o golang.tar.gz && \
    echo "2871270d8ff0c8c69f161aaae42f9f28739855ff5c5204752a8d92a1c9f63993 golang.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -xzf golang.tar.gz && \
    rm golang.tar.gz && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR "/go"

ENV TENSORFLOW_LIB_GZIP libtensorflow-cpu-linux-x86_64-1.8.0.tar.gz
ENV TARGET_DIRECTORY /usr/local
RUN  curl -fsSL "https://storage.googleapis.com/tensorflow/libtensorflow/$TENSORFLOW_LIB_GZIP" -o $TENSORFLOW_LIB_GZIP && \
     tar -C $TARGET_DIRECTORY -xzf $TENSORFLOW_LIB_GZIP && \
     rm -Rf $TENSORFLOW_LIB_GZIP
ENV LD_LIBRARY_PATH $TARGET_DIRECTORY/lib
ENV LIBRARY_PATH $TARGET_DIRECTORY/lib
RUN go get -d github.com/tensorflow/tensorflow/tensorflow/go

RUN cd $GOPATH/src/github.com/tensorflow/tensorflow/tensorflow/go && git checkout r1.8

RUN apt-get -y update && \
    apt-get -y install build-essential checkinstall libx11-dev libxext-dev zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev wget && \
    cd /tmp && wget http://www.imagemagick.org/download/ImageMagick-7.0.8-20.tar.gz && \
    tar xvzf ImageMagick-7.0.8-20.tar.gz && cd ImageMagick-7.0.8-20 && \
    touch configure && ./configure && make && make install && \
    ldconfig /usr/local/lib && \
    rm -rf /tmp/ImageMagick*
