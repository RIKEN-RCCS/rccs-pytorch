:::::::::::::: {.body role="main"}
::::::::::::: {#pytorch-v2-9-1-llvm19-1-4 .section}
# PyTorch v2.9.1(llvm19.1.4)[¶](#pytorch-v2-9-1-llvm19-1-4 "Link to this heading"){.headerlink}

Pytorch v2.9.1の「富岳」向けビルドでは、富士通Githubで公開されている"
富士通 Supercomputer PRIMEHPC FX1000/FX700 上の PyTorch
構築手順"から入手可能なPytorch
v1.13.1向けのビルド用スクリプトに対し必要な修正を施したものを利用した。言語環境としては、「富岳」にインストールされているllvm-v19.1.4を用いた。なお、現行の富士通製コンパイラはPytorch
v2.9.1をビルドするために必要なC++言語規格要件を満たさない。

1.  富士通GithubからPyTorchをクローンする。

:::: {.highlight-default .notranslate}
::: highlight
    $ git clone https://github.com/fujitsu/pytorch.git
:::
::::

2.  pytorchディレクトリへ移動し、公式PyTorchのリポジトリを認識する。

:::: {.highlight-default .notranslate}
::: highlight
    $ PYTORCH_TOP=$(cd $(dirname ${BASH_SOURCE:-$0})/pytorch && pwd)
    $ PATCH_DIR=$(cd $(dirname ${BASH_SOURCE:-$0})/patch && pwd
    $ cd ${PYTORCH_TOP}
    $ git remote add upstream https://github.com/pytorch/pytorch.git
    $ git fetch upstream v2.9.1
:::
::::

3.  公式v2.3.1をベースに新しいブランチを作成する。

:::: {.highlight-default .notranslate}
::: highlight
    $ git checkout -b r2.9.1_for_a64fx FETCH_HEAD
:::
::::

4.  富士通PyTorch v1.13.1から、ビルド用スクリプト一式を取り込む。

:::: {.highlight-default .notranslate}
::: highlight
    $ git cherry-pick 17afed104f0a2ac47bab78aebf584fb3c578e707
    $ git reset --mixed HEAD^
    $ git add scripts/fujitsu --all
    $ git commit -m "add scripts/fujitsu"
:::
::::

5.  pytorchに対するパッチを適用し、numpyおよびtensorpipeに対するパッチを所定のディレクトリに置く。

:::: {.highlight-default .notranslate}
::: highlight
    $ cd ${PYTORCH_TOP} && patch -p 1 < ${PATCH_DIR}/pytorch.patch
    $ cp ${PATCH_DIR}/numpy.patch ${PYTORCH_TOP}/scripts/fujitsu
    $ cp ${PATCH_DIR}/tensorpipe.patch ${PYTORCH_TOP}/scripts/fujitsu
:::
::::
:::::::::::::
::::::::::::::
