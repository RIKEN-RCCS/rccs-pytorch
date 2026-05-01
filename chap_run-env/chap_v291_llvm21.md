:::::::::::: {.body role="main"}
::::::::::: {#pytorch-v2-9-1-llvm21-1-0 .section}
# PyTorch v2.9.1(llvm21.1.0)[¶](#pytorch-v2-9-1-llvm21-1-0 "Link to this heading"){.headerlink}

PyTorch v2.3.1におけるResnetの実行には、「富岳」で提供されているPyTorch
v1系向けの実行環境を流用する。

:::: {.highlight-default .notranslate}
::: highlight
    $ cd ${PYTORCH_TOP}/scripts/Fujitsu
    $ cp -rp /vol0004/apps/oss/PyTorch-1.7.0/example/01_resnet/ .
:::
::::

コピーした環境の内、性能評価として4つの実行用スクリプトと3つのPythonプログラムを用いる。

  ファイル名              処理内容               ノード数   プロセス数   スレッド数/プロセス
  ----------------------- ---------------------- ---------- ------------ ---------------------
  submit_train.sh         シングルプロセス学習   1          1            48
  submit_val.sh           シングルプロセス推論   1          1            48
  submit_train_multi.sh   マルチプロセス学習     1          4            12
  submit_val_multi.sh     マルチプロセス推論     1          4            12

  : [実行用スクリプト]{.caption-text}[¶](#id1 "Link to this table"){.headerlink}
  {#id1 .docutils .align-default}

  ファイル名                       用途
  -------------------------------- ----------------------------------------------
  test_train.py                    シングルプロセス学習
  pytorch_synthetic_benchmark.py   マルチプロセス学習
  test_eval.py                     シングルプロセス推論およびマルチプロセス推論

  : [Pythonプログラム]{.caption-text}[¶](#id2 "Link to this table"){.headerlink}
  {#id2 .docutils .align-default}

ここで、submit_train.shとsubmit_val.shの".
../env.src"の直後にvenvのactivateを実行する以下の行を追加する。

:::: {.highlight-default .notranslate}
::: highlight
    . ../env.src
    . ${VENV_PATH}/bin/activate
:::
::::

PyTorch
v2.9.1ではシングルプロセス学習においてmkltensorに対応できていないため、
submit_train.sh内でtest_train.pyに与えている実行時オプションのmkltensorをcpu_nomklに修正する。

:::: {.highlight-default .notranslate}
::: highlight
    LD_PRELOAD=libtcmalloc.so python3 -u test_train.py --batch 256 --type cpu_nomkl
:::
::::

また、マルチプロセス学習においてもoneDNNに対応できていない可能性がある。そのため、Pythonプログラムpytorch_synthetic_benchmark.py
43行目を次のように変更する。 .. code-block:

:::: {.highlight-default .notranslate}
::: highlight
    mkl_enable = False
:::
::::
:::::::::::
::::::::::::
