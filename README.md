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
