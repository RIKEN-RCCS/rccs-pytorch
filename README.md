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

### (7) scripts/fujitsu/env.srcを修正する。
- 46行目を有効化し、コンパイラの版数としてtcsds-1.2.38を指定する。
- 47行目をコメントアウトする。
- 48、49行目のvenvとprefixのパスを適宜修正する。

### (8) scripts/fujitsu/3_venv.shを修正する。
```
$ sed -i -e "s/pip future six wheel/pip/g" 3_venv.sh
```

### (9) scripts/fujitsu/4_numpy_scipy.shを修正する。
```
$ sed -i -e "s/Cython>=0.29.30/Cython>=0.29.30,<3.0/g" 4_numpy_scipy.sh
```

### (10) scripts/fujitsu/5_pytorch.shを修正する。
```
$ sed -i -e "s/ONEDNN_VER=v2.7/ONEDNN_VER=v3.1.1/g" 5_pytorch.sh
$ sed -i -e "s%/third_party/oneDNN%%g" 5_pytorch.sh
$ sed -i -e "s/CFLAGS=-O3/WITH_BLAS=ssl2 CFLAGS='-O3 -Kopenmp'/g" 5_pytorch.sh
```

### (11) 富士通コンパイラでのエラー回避のためpatch(pytorch21_q8gemm_sparse.ptach)を適用する。
```
$ pwd
(somewhere)/ pytorch
$ cd aten/src/ATen/native/quantized/cpu/qnnpack/src/q8gemm_sparse
$ patch -p1 -i (somewhere)/pytorch21_q8gemm_sparse.ptach
```

### (12) scripts/fujitsu/6_vision.shを修正する。PyTorchの版数に合わせてVisionをv1.16.0に変更する。
```
$ sed -i -e "s/TORCHVISION_VER=v0.14.1/TORCHVISION_VER=v0.16.0/g" 6_vision.sh
```

### (13) Visionの版数の変更に伴い、scripts/fujitsu/vision.patchを以下の通り修正する。
- vision.patchの修正前
```
144 -   // we want to precalculate indices and weights shared by all chanels,
```
- vision.patchの修正後
```
144 -   // we want to precalculate indices and weights shared by all channels,
```

### (14) scripts/fujitsu/horovod.patchを以下の通り、C++17向けのパッチをmpi_ops.pyの行の間に挿入する。
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

## ビルド手順
