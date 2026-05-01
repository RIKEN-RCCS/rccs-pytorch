:::: {.body role="main"}
::: {#pytorch-v2-3-1 .section}
# PyTorch v2.3.1[¶](#pytorch-v2-3-1 "Link to this heading"){.headerlink}

実行環境については、PyTorch v2.9.1と同様の手順で作成を行った。 PyTorch
v2.9.1と同様にPyTorch
v2.3.1でもシングルプロセス学習においてmkltensorに対応できていないため、
submit_train.sh内でtest_train.pyに与えている実行時オプションのmkltensorをcpu_nomklに修正する。
また、マルチプロセス学習においても同様にoneDNNに対応できていない可能性がある。
そのため、Pythonプログラムpytorch_synthetic_benchmark.pyをPyTorch
v2.9.1の場合と同様に修正する。
:::
::::
