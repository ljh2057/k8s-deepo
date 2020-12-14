# k8s-deepo

## Deepo

[Deepo](https://github.com/ufoym/deepo) 是一个包含几乎所有主流深度学习框架的 Docker 镜像，拥有一个完整的可复制的深度学习环境。它涵盖的深度学习框架包括：[Theano](https://github.com/Theano/Theano), [TensorFlow](http://www.tensorflow.org/), [Sonnet](https://github.com/deepmind/sonnet), [PyTorch](http://pytorch.org/), [Keras](https://keras.io/), [Lasagne](http://lasagne.readthedocs.io/en/latest/), [MXNet](http://mxnet.incubator.apache.org/), [CNTK](https://www.microsoft.com/en-us/cognitive-toolkit/), [Chainer](https://chainer.org/), [Caffe](http://caffe.berkeleyvision.org/), [Caffe2](https://caffe2.ai/)， [Torch](http://torch.ch/), [Paddle](https://github.com/PaddlePaddle/Paddle)，[Darknet](https://pjreddie.com/darknet/) 等。
它的主要特征有：

- 允许我们快速配置深度学习环境
- 支持几乎所有常见的深度学习框架
- 支持 GPU 加速（包括 CUDA 和 cuDNN）, 同样在 CPU 中运行良好
- 支持 Linux（CPU 版和 GPU 版）、OS X（CPU 版）、Windows（CPU 版）

Deepo 的 Dockerfile 生成器主要有以下特征：

- 允许使用类似乐高那样的模块自定义环境
- 自动解决依赖项问题

Deepo 除了提供的可用深度学习框架的标准镜像，也可以自定义自己的环境，以 GPU 版本 TensorFlow 为例，对应的镜像 tag 如 `deepo:tensorflow-py36-cu101`，考虑到日常团队开发中不同成员可能擅长于不同的深度学习框架，也可使用 Deepo 的 All-in-One 镜像，对应 tag 为 deepo:all-cu101，但不建议这么做，因为 All-in-One 镜像过于臃肿，当然 Deepo 也提供了脚本（[Build your own customized image](https://github.com/ufoym/deepo)） 生成特定 Dockerfile 以提供自定义的环境。


## k8s-deepo

k8s-deepo 便是基于该脚本生成的自定义深度学习平台，并且我们将其运行于 [Kubernetes ](https://kubernetes.io/)平台上，实现易于管理、扩容、运维、多用户使用的 GPU 深度学习环境。当然你可以认为它是一个运行在 Kubernetes 上的 Deepo。


k8s-deepo 实现了基于 IDE（如 PyCharm） 远程开发和 Jupyter Notebook 进行开发的多用户共享 GPU 深度学习环境。涵盖了以下深度学习框架（平台），并开启了 SSH 服务。

- python    3.6
- opencv    4.4.0
- jupyter    latest 
- jupyterhub    latest
- jupyterlab    latest
- caffe    latest
- keras    latest
- pytorch    1.6.0+cu101
- tensorflow-gpu    latest

k8s-deepo 提供了基于 yaml 部署和使用 Helm 进行部署两种方式。


### Installation

### Step 1. 获取 k8s-deepo

```git
git clone https://github.com/ljh2057/k8s-deepo.git
cd k8s-deepo
```

### Step 2. 部署

#### Step 2-1. 基于 yaml 部署

1. 创建 Namepsace。

```bash
kubectl create namespace k8s-deeplearning
```

2. 创建 ConfigMap 、Deployment、Service。

```bash
kubectl apply -f k8s-deepo-ConfigMap.yaml
kubectl apply -f k8s-deepo-Deployment.yaml
kubectl apply -f k8s-deepo-Service.yaml
```


#### Step 2-2. 基于 Helm 部署

```bash
helm install helm-k8s-deepo ./helm-k8s-deepo/
```

### Step 2. 访问

#### Step 3-1. 通过 Jupyterhub 访问（端口为 30088）

```bash
# Get the jupyterhub URL by running these commands:
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[1].nodePort}" services helm-k8s-deepo)
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```

#### Step 3-2. 通过 SSH 访问（端口为 30022）

```bash
# Get the jupyterhub URL by running these commands:
export SSH_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services helm-k8s-deepo)
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
ssh -p $SSH_PORT root@$NODE_IP
# passwd of root is "admin" which can modify  Deployment.spec.containers.args if you use step 2-1 or values.containers.args. 
```

