# rccs-pytorch

## はじめに

本書では、「富岳」におけるAIフレームワークPyTorch v2のビルド手順および標準的なテストデータ(mnist)を用いた動作確認の手順について述べる。

## AIプレームワークPyTorchのバージョンアップ

### PyTorchおよび主要モジュールの版数

ビルド対象であるPyTorchおよび主要モジュールの版数を示す。本作業では、Python v3.9.18、PyTorch v2.1、Numpy v1.22.4、Scipy v1.7.3、OneDNN v3.1.1、Horovod v0.26.1を採用することとした。

| モジュール名 | 版数 |
| --- | --- |
| Python | v3.9.18 |
| PyTorch | v2.1 |
| Numpy | v1.22.4 |
| Scipy | v1.7.3 |
| oneDNN | v3.1.1 |
|Horovod | v0.26.1 |

### ビルド環境の整備

[200~Pytorch v2.1の「富岳」向けビルドでは、富士通Githubで公開されている” 富士通 Supercomputer PRIMEHPC FX1000/FX700 上の PyTorch 構築手順”から入手可能なPytorch v1.13.1向けのビルド用スクリプトを利用する。また、PyTorch v1.13.1における富士通言語環境向けの修正を取り込む。
本作業においては、言語環境としてtcsds-1.2.38を用いた。

#### (1) 富士通GithubからPyTorchをクローンする。

```
$ git clone https://github.com/fujitsu/pytorch.git
```

#### (2) pytorch/ディレクトリへ移動し、公式PyTorchのリポジトリを認識する。

```
$ cd pytorch
$ git remote add upstream https://github.com/pytorch/pytorch.git
$ git fetch upstream v2.1.0
```

#### (3) 公式v2.1.0をベースに新しいブランチを作成する。

```
$ git checkout -b r2.1.0_for_a64fx FETCH_HEAD
```

#### (4) 富士通PyTorch v1.13.1から、ビルド用スクリプト一式を取り込む。

```
$ git cherry-pick 17afed104f0a2ac47bab78aebf584fb3c578e707
$ git reset --mixed HEAD^
$ git add scripts/fujitsu --all
$ git commit -m "add fujitsu/script"
```

#### (5) ２つの富士通コンパイラ向けのブランチをcherry-pickする。
１つ目では、8x8c1x4-dq-packedA-aarch64-neon.Sへの修正を取り込む。
```
$ git cherry-pick e81f6c00acef2cebaaca9e5085fa6a2b0181ecd4
$ git checkout --theirs aten/src/ATen/native/quantized/cpu/qnnpack/src/q8gemm_sparse/8x8c1x4-dq-packedA-aarch64-neon.S
$ git add aten/src/ATen/native/quantized/cpu/qnnpack/src/q8gemm_sparse/8x8c1x4-dq-packedA-aarch64-neon.S
$ git cherry-pick --continue 
  # ファイル編集画面が開くが、編集せず終了する。
```

2つ目では、cmakeへの修正を取り込む。
```
$ git cherry-pick 2f85b96ce569a8e60eb1627746fba3ee8ba12a57
$ git status
  # マージされていない2つのファイルを修正する。
```

git statusで出力されるマージされていない2つのファイルを以下の通り修正する。

**1. cmake/Dependencies.cmakeの修正**
- 238、243、258行目を削除
- 281行目の”OR FlexiBLAS_FOUND”の後に” OR SSL2_FOUND”を追加する
- 280、282、283、284行目を削除
- 修正後のcmake/Dependencies.cmake
```
237   set(BLAS_LIBRARIES ${vecLib_LINKER_LIBS})
238 elseif(BLAS STREQUAL "FlexiBLAS")
239   find_package(FlexiBLAS REQUIRED)
240   include_directories(SYSTEM ${FlexiBLAS_INCLUDE_DIR})
241   list(APPEND Caffe2_DEPENDENCY_LIBS ${FlexiBLAS_LIB})
242 elseif(BLAS STREQUAL "SSL2")
243   if(CMAKE_CXX_COMPILER MATCHES ".*/FCC$"
244       AND CMAKE_C_COMPILER MATCHES ".*/fcc$")
245     message(STATUS "SSL2 Selected BLAS library")
246     list(APPEND Caffe2_PUBLIC_DEPENDENCY_LIBS "fjlapackexsve.so")
247     set(SSL2_FOUND ON)
248     message(STATUS "set CMAKE_SHARED_LINKER_FLAGS: -SSL2 --linkfortran")
249     set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -SSL2 --linkfortran")
250     set(WITH_BLAS "ssl2")
251   else()
252     message(STATUS "Not built using fcc and FCC.")
253     message(STATUS "CMAKE_C_COMPILER: ${CMAKE_C_COMPILER}")
254     message(STATUS "CMAKE_CXX_COMPILER: ${CMAKE_CXX_COMPILER}")
255   endif()
                               :
273 if(NOT INTERN_BUILD_MOBILE)
274   set(AT_MKL_ENABLED 0)
275   set(AT_MKL_SEQUENTIAL 0)
276   set(USE_BLAS 1)
277   if(NOT (ATLAS_FOUND OR BLIS_FOUND OR GENERIC_BLAS_FOUND OR MKL_FOUND OR OpenBLAS_FOUND OR VECLIB_FOUND OR FlexiBLAS_FOUND OR SSL2_FOUND))
278     message(WARNING "Preferred BLAS (" ${BLAS} ") cannot be found, now searching for a general BLAS library")
279     find_package(BLAS)
280     if(NOT BLAS_FOUND)
281       set(USE_BLAS 0)
282     endif()
283   endif()
```

**2. cmake/Modules/FindOpenMP.cmakeの修正**
- 262、266、278行目を削除
- 修正後のcmake/Modules/FindOpenMP.cmake
```
261         set(OpenMP_libomp_LIBRARY "${MKL_OPENMP_LIBRARY}" CACHE STRING "libomp location for OpenMP")
262         if("-fopenmp=libiomp5" IN_LIST OpenMP_${LANG}_FLAG_CANDIDATES)
263           set(OPENMP_FLAG "-fopenmp=libiomp5")
264         endif()
265       elseif(CMAKE_${LANG}_COMPILER MATCHES ".*/fcc$" OR
266           CMAKE_${LANG}_COMPILER MATCHES ".*/FCC$")
                                 :
275         endif()
276       else()
```

#### (6) 修正した２つのファイルをgit addする。
```
$ git add cmake/Dependencies.cmake cmake/Modules/FindOpenMP.cmake
$ git cherry-pick --continue
  # ファイル編集画面が開くが、編集せず終了する。
```

#### (7) scripts/fujitsu/env.srcを修正する。
- 46行目を有効化し、コンパイラの版数としてtcsds-1.2.38を指定する。
- 47行目をコメントアウトする。
- 48、49行目のvenvとprefixのパスを適宜修正する。

#### (8) scripts/fujitsu/3_venv.shを修正する。
```
$ sed -i -e "s/pip future six wheel/pip/g" 3_venv.sh
```

#### (9) scripts/fujitsu/4_numpy_scipy.shを修正する。
```
$ sed -i -e "s/Cython>=0.29.30/Cython>=0.29.30,<3.0/g" 4_numpy_scipy.sh
```

#### (10) scripts/fujitsu/5_pytorch.shを修正する。
```
$ sed -i -e "s/ONEDNN_VER=v2.7/ONEDNN_VER=v3.1.1/g" 5_pytorch.sh
$ sed -i -e "s%/third_party/oneDNN%%g" 5_pytorch.sh
$ sed -i -e "s/CFLAGS=-O3/WITH_BLAS=ssl2 CFLAGS='-O3 -Kopenmp'/g" 5_pytorch.sh
```

#### (11) 富士通コンパイラでのエラー回避のためpatch(pytorch21_q8gemm_sparse.ptach)を適用する。
```
$ pwd
(somewhere)/ pytorch
$ cd aten/src/ATen/native/quantized/cpu/qnnpack/src/q8gemm_sparse
$ patch -p1 -i (somewhere)/pytorch21_q8gemm_sparse.ptach
```

#### (12) scripts/fujitsu/6_vision.shを修正する。PyTorchの版数に合わせてVisionをv1.16.0に変更する。
```
$ sed -i -e "s/TORCHVISION_VER=v0.14.1/TORCHVISION_VER=v0.16.0/g" 6_vision.sh
```

#### (13) Visionの版数の変更に伴い、scripts/fujitsu/vision.patchを以下の通り修正する。
- vision.patchの修正前
```
144 -   // we want to precalculate indices and weights shared by all chanels,
```
- vision.patchの修正後
```
144 -   // we want to precalculate indices and weights shared by all channels,
```

#### (14) scripts/fujitsu/horovod.patchを以下の通り、C++17向けのパッチをmpi_ops.pyの行の間に挿入する。
- horovod.patchの修正後
```
62
63 diff --git a/horovod/torch/CMakeLists.txt b/horovod/torch/CMakeLists.txt
64 index eecd198..b1bdee1 100644
65 --- a/horovod/torch/CMakeLists.txt
66 +++ b/horovod/torch/CMakeLists.txt
67 @@ -63,7 +63,9 @@ endif()
68  parse_version(${Pytorch_VERSION} VERSION_DEC)
69  add_definitions(-DPYTORCH_VERSION=${VERSION_DEC} -DTORCH_API_INCLUDE_EXTENSION_H=1)
70  set(Pytorch_CXX11 ${Pytorch_CXX11} PARENT_SCOPE)
71 -if(NOT Pytorch_VERSION VERSION_LESS "1.5.0")
72 +if(NOT Pytorch_VERSION VERSION_LESS "2.1.0")
73 +    set(CMAKE_CXX_STANDARD 17)
74 +elseif(NOT Pytorch_VERSION VERSION_LESS "1.5.0")
75      set(CMAKE_CXX_STANDARD 14)
76  endif()
77
78 diff --git a/horovod/torch/mpi_ops.py b/horovod/torch/mpi_ops.py
```

### ビルド手順
2.2 ビルド環境の整備が完了後、会話型ジョブにより以下の手順でビルドする。
```
$ cd (somewhere)/pytorch/scripts/fujitsu

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
attrs              23.2.0
beniget            0.4.1
certifi            2024.2.2
cffi               1.16.0
charset-normalizer 3.3.2
cloudpickle        3.0.0
Cython             0.29.37
exceptiongroup     1.2.0
expecttest         0.2.1
filelock           3.13.1
fsspec             2024.2.0
gast               0.5.4
horovod            0.26.1
hypothesis         6.99.6
idna               3.6
iniconfig          2.0.0
Jinja2             3.1.3
MarkupSafe         2.1.5
mpmath             1.3.0
networkx           3.2.1
numpy              1.22.4
packaging          24.0
Pillow             7.2.0
pip                23.0.1
pluggy             1.4.0
ply                3.11
psutil             5.9.8
pybind11           2.11.1
pycparser          2.21
pytest             8.1.1
pythran            0.15.0
PyYAML             6.0.1
requests           2.31.0
SciPy              1.7.3
setuptools         69.2.0
six                1.16.0
sortedcontainers   2.4.0
sympy              1.12
tomli              2.0.1
torch              2.1.0a0+gitd886a2e
torchvision        0.16.0+fbb4cc5
types-dataclasses  0.6.6
typing_extensions  4.10.0
urllib3            2.2.1
wheel              0.43.0
```

### 標準的なテストデータ(mnist)を用いた動作確認 

ビルドしたPyTorch v2.1の動作確認では、機械学習の画像認識の学習においてサンプルデータ
としてよく利用される「mnist」を用いた。
mnistを実行するコードは公式PyTorchのgithubのexamplesから入手した。
(https://github.com/pytorch/examples/blob/main/mnist/main.py)
また、mnistのコードを実行するスクリプトにはscripts/fujitsu/run1proc.shを流用した。

#### mnistの実行環境の構築

scripts/fujitsu/配下に以下のmnistコード(mnist.py)と実行用スクリプト(run1proc_mnist.sh)を作る。

- mnist.py
```
from __future__ import print_function
import argparse
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torchvision import datasets, transforms
from torch.optim.lr_scheduler import StepLR


class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        self.conv1 = nn.Conv2d(1, 32, 3, 1)
        self.conv2 = nn.Conv2d(32, 64, 3, 1)
        self.dropout1 = nn.Dropout(0.25)
        self.dropout2 = nn.Dropout(0.5)
        self.fc1 = nn.Linear(9216, 128)
        self.fc2 = nn.Linear(128, 10)

    def forward(self, x):
        x = self.conv1(x)
        x = F.relu(x)
        x = self.conv2(x)
        x = F.relu(x)
        x = F.max_pool2d(x, 2)
        x = self.dropout1(x)
        x = torch.flatten(x, 1)
        x = self.fc1(x)
        x = F.relu(x)
        x = self.dropout2(x)
        x = self.fc2(x)
        output = F.log_softmax(x, dim=1)
        return output


def train(args, model, device, train_loader, optimizer, epoch):
    model.train()
    for batch_idx, (data, target) in enumerate(train_loader):
        data, target = data.to(device), target.to(device)
        optimizer.zero_grad()
        output = model(data)
        loss = F.nll_loss(output, target)
        loss.backward()
        optimizer.step()
        if batch_idx % args.log_interval == 0:
            print('Train Epoch: {} [{}/{} ({:.0f}%)]\tLoss: {:.6f}'.format(
                epoch, batch_idx * len(data), len(train_loader.dataset),
                100. * batch_idx / len(train_loader), loss.item()))
            if args.dry_run:
                break


def test(model, device, test_loader):
    model.eval()
    test_loss = 0
    correct = 0
    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            output = model(data)
            test_loss += F.nll_loss(output, target, reduction='sum').item()  # sum up batch loss
            pred = output.argmax(dim=1, keepdim=True)  # get the index of the max log-probability
            correct += pred.eq(target.view_as(pred)).sum().item()

    test_loss /= len(test_loader.dataset)

    print('\nTest set: Average loss: {:.4f}, Accuracy: {}/{} ({:.0f}%)\n'.format(
        test_loss, correct, len(test_loader.dataset),
        100. * correct / len(test_loader.dataset)))


def main():
    # Training settings
    parser = argparse.ArgumentParser(description='PyTorch MNIST Example')
    parser.add_argument('--batch-size', type=int, default=64, metavar='N',
                        help='input batch size for training (default: 64)')
    parser.add_argument('--test-batch-size', type=int, default=1000, metavar='N',
                        help='input batch size for testing (default: 1000)')
    parser.add_argument('--epochs', type=int, default=14, metavar='N',
                        help='number of epochs to train (default: 14)')
    parser.add_argument('--lr', type=float, default=1.0, metavar='LR',
                        help='learning rate (default: 1.0)')
    parser.add_argument('--gamma', type=float, default=0.7, metavar='M',
                        help='Learning rate step gamma (default: 0.7)')
    parser.add_argument('--no-cuda', action='store_true', default=False,
                        help='disables CUDA training')
    parser.add_argument('--no-mps', action='store_true', default=False,
                        help='disables macOS GPU training')
    parser.add_argument('--dry-run', action='store_true', default=False,
                        help='quickly check a single pass')
    parser.add_argument('--seed', type=int, default=1, metavar='S',
                        help='random seed (default: 1)')
    parser.add_argument('--log-interval', type=int, default=10, metavar='N',
                        help='how many batches to wait before logging training status')
    parser.add_argument('--save-model', action='store_true', default=False,
                        help='For Saving the current Model')
    args = parser.parse_args()
    use_cuda = not args.no_cuda and torch.cuda.is_available()
    use_mps = not args.no_mps and torch.backends.mps.is_available()

    torch.manual_seed(args.seed)

    if use_cuda:
        device = torch.device("cuda")
    elif use_mps:
        device = torch.device("mps")
    else:
        device = torch.device("cpu")

    train_kwargs = {'batch_size': args.batch_size}
    test_kwargs = {'batch_size': args.test_batch_size}
    if use_cuda:
        cuda_kwargs = {'num_workers': 1,
                       'pin_memory': True,
                       'shuffle': True}
        train_kwargs.update(cuda_kwargs)
        test_kwargs.update(cuda_kwargs)

    transform=transforms.Compose([
        transforms.ToTensor(),
        transforms.Normalize((0.1307,), (0.3081,))
        ])
    dataset1 = datasets.MNIST('../data', train=True, download=True,
                       transform=transform)
    dataset2 = datasets.MNIST('../data', train=False,
                       transform=transform)
    train_loader = torch.utils.data.DataLoader(dataset1,**train_kwargs)
    test_loader = torch.utils.data.DataLoader(dataset2, **test_kwargs)

    model = Net().to(device)
    optimizer = optim.Adadelta(model.parameters(), lr=args.lr)

    scheduler = StepLR(optimizer, step_size=1, gamma=args.gamma)
    for epoch in range(1, args.epochs + 1):
        train(args, model, device, train_loader, optimizer, epoch)
        test(model, device, test_loader)
        scheduler.step()

    if args.save_model:
        torch.save(model.state_dict(), "mnist_cnn.pt")


if __name__ == '__main__':
    main()
```

- run1proc_mnist.sh
```
#! /bin/bash

set -euo pipefail

script_basedir=$(cd $(dirname $0); pwd)
source $script_basedir/env.src
[ -v VENV_PATH ] && source $VENV_PATH/bin/activate

set -x

#export OMP_PROC_BIND=false
export OMP_NUM_THREADS=48

# For oneDNN debug
# Output debug message (CSV) to stdout.
# The message begin with 'dnnl_verbose,' which is the first entry in CSV.
#export DNNL_VERBOSE=1                  #  0: (no output), 1: (exec), 2: (1 + cache hit/miss)
#export DNNL_VERBOSE_TIMESTAMP=1

ulimit -s 8192

if [ ${PMIX_RANK:-0} -eq 0 ]; then
    env
    pip3 list
    KMP_SETTINGS=1 python3 -c "import torch; print(torch.__version__); print(torch.__config__.show()); print(torch.__config__.parallel_info())"
fi

LD_PRELOAD=$PREFIX/lib/libtcmalloc.so python3 -u mnist.py --epoch 2 --no-cuda --no-mps
```

#### mnistの実行
対話型ジョブにより計算ノードから以下のコマンドでmnistを実行する。
```
$ cd (somewhere)/pytorch/scripts/Fujitsu
$ bash run1proc_mnist.sh
```

以下の出力によりmnistがPyTorch v2.1で正常に動作していることを確認した。

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
Train Epoch: 1 [2560/60000 (4%)]        Loss: 0.438659
Train Epoch: 1 [3200/60000 (5%)]        Loss: 0.272091
                            :
Train Epoch: 1 [56960/60000 (95%)]      Loss: 0.028683
Train Epoch: 1 [57600/60000 (96%)]      Loss: 0.158729
Train Epoch: 1 [58240/60000 (97%)]      Loss: 0.003202
Train Epoch: 1 [58880/60000 (98%)]      Loss: 0.009425
Train Epoch: 1 [59520/60000 (99%)]      Loss: 0.003038

Test set: Average loss: 0.0458, Accuracy: 9840/10000 (98%)

Train Epoch: 2 [0/60000 (0%)]   Loss: 0.024910
Train Epoch: 2 [640/60000 (1%)] Loss: 0.025748
Train Epoch: 2 [1280/60000 (2%)]        Loss: 0.074290
Train Epoch: 2 [1920/60000 (3%)]        Loss: 0.184948
Train Epoch: 2 [2560/60000 (4%)]        Loss: 0.053342
Train Epoch: 2 [3200/60000 (5%)]        Loss: 0.025564
                            :
Train Epoch: 2 [56960/60000 (95%)]      Loss: 0.032589
Train Epoch: 2 [57600/60000 (96%)]      Loss: 0.136949
Train Epoch: 2 [58240/60000 (97%)]      Loss: 0.031606
Train Epoch: 2 [58880/60000 (98%)]      Loss: 0.005720
Train Epoch: 2 [59520/60000 (99%)]      Loss: 0.002099

Test set: Average loss: 0.0370, Accuracy: 9870/10000 (99%)
```
