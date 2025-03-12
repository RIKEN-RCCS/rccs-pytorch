# rccs-pytorch

## はじめに

本書では、「富岳」におけるAIフレームワークPyTorch v2.3系のビルド手順および標準的なテストデータ(mnist)を用いた動作確認の手順について述べる。

## AIプレームワークPyTorchのバージョンアップ

### PyTorchおよび主要モジュールの版数

ビルド対象であるPyTorchおよび主要モジュールの版数を示す。本作業では、Python v3.9、PyTorch v2.3.1、Numpy v1.22.4、Scipy v1.10.1、OneDNN v3.3.6、Horovod v0.26.1を採用することとした。

| モジュール名 | 版数 |
| --- | --- |
| Python | v3.9 |
| PyTorch | v2.3.1 |
| Numpy | v1.22.4 |
| Scipy | v1.10.3 |
| oneDNN | v3.3.6 |
|Horovod | v0.26.1 |

### ビルド環境の整備

Pytorch v2.3.1の「富岳」向けビルドでは、富士通Githubで公開されている” 富士通 Supercomputer PRIMEHPC FX1000/FX700 上の PyTorch 構築手順”から入手可能なPytorch v1.13.1向けのビルド用スクリプトを利用する。言語環境としては、「富岳」にインストールされているllvm-v19.1.0を用いた。なお、現行の富士通製コンパイラはPytorch v2.3.1をビルドするために必要なC++言語規格要件を満たさない。

#### (1) 富士通GithubからPyTorchをクローンする。

```
$ git clone https://github.com/fujitsu/pytorch.git
```

#### (2) pytorch/ディレクトリへ移動し、公式PyTorchのリポジトリを認識する。

```
$ PYTORCH_TOP=$(cd $(dirname ${BASH_SOURCE:-$0})/pytorch && pwd)
$ PATCH_DIR=$(cd $(dirname ${BASH_SOURCE:-$0})/patch && pwd
$ cd ${PYTORCH_TOP}
$ git remote add upstream https://github.com/pytorch/pytorch.git
$ git fetch upstream v2.3.1
```

#### (3) 公式v2.3.1をベースに新しいブランチを作成する。

```
$ git checkout -b r2.3.1_for_a64fx FETCH_HEAD
```

#### (4) 富士通PyTorch v1.13.1から、ビルド用スクリプト一式を取り込む。

```
$ git cherry-pick 17afed104f0a2ac47bab78aebf584fb3c578e707
$ git reset --mixed HEAD^
$ git add scripts/fujitsu --all
$ git commit -m "add scripts/fujitsu"
```

#### (5) パッチを適用する。
```
$ cd ${PYTORCH_TOP} && patch -p 1 < ${PATCH_DIR}/pytorch.patch 
$ cp ${PATCH_DIR}/numpy.patch ${PYTORCH_TOP}/scripts/fujitsu
$ cp ${PATCH_DIR}/tensorpipe.patch ${PYTORCH_TOP}/scripts/fujitsu
```


### ビルド手順
ビルド環境の整備後、計算ノード上にて以下のように実行する。なお、すべてのscriptを実行するのには7時間程度を要する。
```
$ cd ${PYTORCH_TOP}/pytorch/scripts/fujitsu
$ . ./env.src
$ bash 1_python.sh
$ bash 3_venv.sh
$ bash 4_numpy_scipy.sh
$ bash 5_pytorch.sh
$ bash 6_vision.sh 
$ bash 7_horovod.sh 
$ bash 8_libtcmalloc.sh
```

ビルド用のスクリプトの実行後に出力されるpip3 list(pip3_list.txt)の内容を示す。
```
Package            Version
------------------ ------------------
astunparse         1.6.3
attrs              25.1.0
beniget            0.4.2.post1
certifi            2025.1.31
cffi               1.17.1
charset-normalizer 3.4.1
cloudpickle        3.1.1
Cython             0.29.37
exceptiongroup     1.2.2
expecttest         0.3.0
filelock           3.17.0
fsspec             2025.2.0
gast               0.6.0
horovod            0.26.1
hypothesis         6.127.6
idna               3.10
iniconfig          2.0.0
Jinja2             3.1.5
lark               1.2.2
MarkupSafe         3.0.2
mpmath             1.3.0
networkx           3.2.1
numpy              1.22.4
optree             0.14.1
packaging          24.2
Pillow             8.0.1
pip                24.2
pluggy             1.5.0
ply                3.11
psutil             7.0.0
pybind11           2.13.6
pycparser          2.22
pytest             8.3.5
pythran            0.17.0
PyYAML             6.0.2
requests           2.32.3
scipy              1.10.1
setuptools         59.5.0
six                1.17.0
sortedcontainers   2.4.0
sympy              1.13.3
tomli              2.2.1
torch              2.3.0a0+git007aa5a
torchvision        0.18.1a0+126fc22
types-dataclasses  0.6.6
typing_extensions  4.12.2
urllib3            2.3.0
wheel              0.45.1
```

### 標準的なテストデータ(mnist)を用いた動作確認 

ビルドしたPyTorch v2.3.1の動作確認では、機械学習の画像認識の学習においてサンプルデータ
としてよく利用される「mnist」を用いた。
mnistを実行するコードは公式PyTorchのgithubのexamplesから入手した。
(https://github.com/pytorch/examples/blob/main/mnist/main.py)
また、mnistのコードを実行するスクリプトにはscripts/fujitsu/run1proc.shを流用した。

#### mnistの実行環境の構築

run/ディレクトリに格納されている以下の2つのファイルをscripts/fujitsu/配下にコピーする。
- mnist.py
- run1proc_mnist.sh

#### mnistの実行
mnistをジョブ実行する。
```
$ cd ${PYTORCH_TOP}/pytorch/scripts/Fujitsu
$ pjsub ./run1proc_mnist.sh
```

以下の出力によりmnistがPyTorch v2.3.1で正常に動作していることを確認した。

```
Downloading http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz
Downloading http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz to ../data/MNIST/raw/train-images-idx3-ubyte.gz
100.0%
Extracting ../data/MNIST/raw/train-images-idx3-ubyte.gz to ../data/MNIST/raw
　　　　　　　　　　　　　　:
Extracting ../data/MNIST/raw/t10k-labels-idx1-ubyte.gz to ../data/MNIST/raw

Train Epoch: 1 [0/60000 (0%)]   Loss: 2.329474
Train Epoch: 1 [640/60000 (1%)] Loss: 1.425025
Train Epoch: 1 [1280/60000 (2%)]        Loss: 0.797880
Train Epoch: 1 [1920/60000 (3%)]        Loss: 0.536058
Train Epoch: 1 [2560/60000 (4%)]        Loss: 0.438753
Train Epoch: 1 [3200/60000 (5%)]        Loss: 0.274102
                            :
Train Epoch: 1 [56960/60000 (95%)]      Loss: 0.048289
Train Epoch: 1 [57600/60000 (96%)]      Loss: 0.124155
Train Epoch: 1 [58240/60000 (97%)]      Loss: 0.006653
Train Epoch: 1 [58880/60000 (98%)]      Loss: 0.003714
Train Epoch: 1 [59520/60000 (99%)]      Loss: 0.002787

Test set: Average loss: 0.0499, Accuracy: 9825/10000 (98%)

Train Epoch: 2 [0/60000 (0%)]   Loss: 0.028963
Train Epoch: 2 [640/60000 (1%)] Loss: 0.031012
Train Epoch: 2 [1280/60000 (2%)]        Loss: 0.083007
Train Epoch: 2 [1920/60000 (3%)]        Loss: 0.191689
Train Epoch: 2 [2560/60000 (4%)]        Loss: 0.034225
Train Epoch: 2 [3200/60000 (5%)]        Loss: 0.019088
                            :
Train Epoch: 2 [56960/60000 (95%)]      Loss: 0.027415
Train Epoch: 2 [57600/60000 (96%)]      Loss: 0.133146
Train Epoch: 2 [58240/60000 (97%)]      Loss: 0.007183
Train Epoch: 2 [58880/60000 (98%)]      Loss: 0.015789
Train Epoch: 2 [59520/60000 (99%)]      Loss: 0.001672

Test set: Average loss: 0.0386, Accuracy: 9875/10000 (99%)
```
