# ==================================================================
# module list
# ------------------------------------------------------------------
# python        3.6    (apt)
# torch         latest (git)
# jupyter       latest (pip)
# paddle        latest (pip)
# pytorch       latest (pip)
# tensorflow    latest (pip)
# jupyterlab    latest (pip)
# keras         latest (pip)
# opencv        4.4.0  (git)
# caffe         latest (git)
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
    GIT_CLONE="git clone --depth 10" && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        build-essential \
        apt-utils \
        ca-certificates \
        wget \
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
    echo 'root:admin' | chpasswd && \
    /etc/init.d/ssh start
# ==================================================================
# cmake
# ------------------------------------------------------------------
RUN GIT_CLONE="git clone --depth 10" && \
    $GIT_CLONE https://github.com.cnpmjs.org/Kitware/CMake.git ~/cmake && \
    # $GIT_CLONE https://github.com/Kitware/CMake ~/cmake && \
    cd ~/cmake && \
    ./bootstrap && \
    make -j"$(nproc)" install
# ==================================================================
# python
# ------------------------------------------------------------------
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    GIT_CLONE="git clone --depth 10" && \
    PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        software-properties-common \
        && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        python3.6 \
        python3.6-dev \
        python3-distutils-extra \
        && \
    wget -O ~/get-pip.py \
        https://bootstrap.pypa.io/get-pip.py && \
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
# torch
# ------------------------------------------------------------------
#RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
#    GIT_CLONE="git clone --depth 10" && \
#    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
#        sudo \
#        && \
#
#    $GIT_CLONE https://hub.fastgit.org/torch/distro.git ~/torch --recursive && \
#    cd ~/torch && \
#    bash install-deps && \
#    sed -i 's/${THIS_DIR}\/install/\/usr\/local/g' ./install.sh && \
#    ./install.sh
# ==================================================================
# boost
# ------------------------------------------------------------------
#RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
#    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
#        libboost-all-dev
# ==================================================================
# jupyter pytorch tensorflow jupyterlab keras
# ------------------------------------------------------------------
RUN PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    $PIP_INSTALL \
        jupyter \
	&& \
#    $PIP_INSTALL \
#        future \
#        numpy \
#        protobuf \
#        enum34 \
#        pyyaml \
#        typing \
#        && \
#    $PIP_INSTALL \
#        --pre torch torchvision -f \
#        https://download.pytorch.org/whl/nightly/cu101/torch_nightly.html \
#	&& \
    $PIP_INSTALL \
        jupyterlab \
	&& \
    $PIP_INSTALL \
        h5py \
        keras
# ==================================================================
# tensorflow
# ------------------------------------------------------------------
#RUN PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
#	$PIP_INSTALL \
#        tensorflow-gpu
RUN pip install tensorflow-gpu -i https://pypi.doubanio.com/simple
# ==================================================================
# opencv
# ------------------------------------------------------------------
#RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
#    GIT_CLONE="git clone --depth 10" && \
#    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
#        libatlas-base-dev \
#        libgflags-dev \
#        libgoogle-glog-dev \
#        libhdf5-serial-dev \
#        libleveldb-dev \
#        liblmdb-dev \
#        libprotobuf-dev \
#        libsnappy-dev \
#        protobuf-compiler \
#        && \
#    $GIT_CLONE --branch 4.4.0 https://github.com.cnpmjs.org/opencv/opencv.git ~/opencv && \
#    mkdir -p ~/opencv/build && cd ~/opencv/build && \
#    cmake -D CMAKE_BUILD_TYPE=RELEASE \
#          -D CMAKE_INSTALL_PREFIX=/usr/local \
#          -D WITH_IPP=OFF \
#          -D WITH_CUDA=OFF \
#          -D WITH_OPENCL=OFF \
#          -D BUILD_TESTS=OFF \
#          -D BUILD_PERF_TESTS=OFF \
#          -D BUILD_DOCS=OFF \
#          -D BUILD_EXAMPLES=OFF \
#         .. && \
#    make -j"$(nproc)" install && \
#    ln -s /usr/local/include/opencv4/opencv2 /usr/local/include/opencv2

# ==================================================================
# caffe
# ------------------------------------------------------------------
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        caffe-cuda
# ==================================================================
# jupyterhub & notebook
# ------------------------------------------------------------------
RUN pip install --upgrade jupyterhub notebook
# ==================================================================
# npm config  & cleanup
# ------------------------------------------------------------------
RUN apt install -y npm nodejs && \
    npm config set registry http://registry.npm.taobao.org && \
    npm install -g configurable-http-proxy && \
    ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*
EXPOSE 8000 22