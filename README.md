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

**2. cmake/Modules/FindOpenMP.cmakeの修正**
- 262、266、278行目を削除

