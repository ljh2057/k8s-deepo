# ==================================================================
# module list
# ------------------------------------------------------------------
# python        3.6    (apt)
# jupyter       latest (pip)
# paddle        latest (pip)
# pytorch       latest (pip)
# tensorflow    latest (pip)
# jupyterhub    latest (pip)
# jupyterlab    latest (pip)
# keras         latest (pip)
# ssh           (apt)
# ==================================================================
FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
ENV LANG C.UTF-8
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && \
    rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get update
# ==================================================================
# tools
# ------------------------------------------------------------------
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        build-essential \
        apt-utils \
        ca-certificates \
        git \
        vim \
        libssl-dev \
        curl \
        unzip \
        unrar \
        openssh-server \
	nodejs \
        && \
    echo PermitRootLogin  yes >>/etc/ssh/sshd_config && \
    echo 'root:admin' | chpasswd
# ==================================================================
# cmake
# ------------------------------------------------------------------
ADD package/cmake.tar.gz /root/
RUN cd ~/CMake && \
    ./bootstrap && \
    make -j"$(nproc)" install
# ==================================================================
# python
# ------------------------------------------------------------------
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        software-properties-common \
        && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        python3.6 \
        python3.6-dev \
        python3-distutils-extra
ADD package/get-pip.py /root/
RUN PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    python3.6 ~/get-pip.py && \
    ln -s /usr/bin/python3.6 /usr/local/bin/python3 && \
    ln -s /usr/bin/python3.6 /usr/local/bin/python && \
    pip config set global.index-url https://pypi.doubanio.com/simple && \
    $PIP_INSTALL \
        setuptools \
        && \
    $PIP_INSTALL \
        numpy \
        scipy \
        pandas \
        cloudpickle \
        scikit-image>=0.14.2 \
        scikit-learn \
        matplotlib \
        Cython \
        tqdm 
# ==================================================================
# jupyter
# ------------------------------------------------------------------
RUN PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    $PIP_INSTALL \
        jupyter
# ==================================================================
# pytorch
# ------------------------------------------------------------------
RUN PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    $PIP_INSTALL \
        future \
        numpy \
        protobuf \
        enum34 \
        pyyaml \
        typing \
        && \
    $PIP_INSTALL \
	torch==1.6.0+cu101 torchvision==0.7.0+cu101 -f https://download.pytorch.org/whl/torch_stable.html
# 	--pre torch torchvision torchaudio -f https://download.pytorch.org/whl/nightly/cu101/torch_nightly.html
# ==================================================================
# tensorflow
# ------------------------------------------------------------------
RUN pip install tensorflow-gpu -i https://pypi.doubanio.com/simple
# ==================================================================
# jupyterlab keras jupyterhub  notebook
# ------------------------------------------------------------------
RUN PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    $PIP_INSTALL \
	jupyterhub \
	notebook \
        jupyterlab \
        && \
    $PIP_INSTALL \
        h5py \
        keras
# ==================================================================
# opencv
# ------------------------------------------------------------------
ADD package/opencv.tar.gz /root/
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        libatlas-base-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        && \
    mkdir -p ~/opencv/build && cd ~/opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_IPP=OFF \
          -D WITH_CUDA=OFF \
          -D WITH_OPENCL=OFF \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          -D BUILD_DOCS=OFF \
          -D BUILD_EXAMPLES=OFF \
         .. && \
    make -j"$(nproc)" install && \
    ln -s /usr/local/include/opencv4/opencv2 /usr/local/include/opencv2
# ==================================================================
# caffe
# ------------------------------------------------------------------
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        caffe-cuda
# ==================================================================
# boost
# ------------------------------------------------------------------
# RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
#    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
#        libboost-all-dev
# ==================================================================
# npm config  & cleanup
# ------------------------------------------------------------------
RUN apt-get update && \
    apt install -y npm nodejs && \
    npm config set registry http://registry.npm.taobao.org && \
    npm install -g configurable-http-proxy && \
    ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*
EXPOSE 8000 22
