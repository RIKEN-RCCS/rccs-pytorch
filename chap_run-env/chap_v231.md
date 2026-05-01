# PyTorch v2.3.1<a href="#pytorch-v2-3-1" class="headerlink"
title="Link to this heading">¶</a>

実行環境については、PyTorch v2.9.1と同様の手順で作成を行った。 PyTorch
v2.9.1と同様にPyTorch
v2.3.1でもシングルプロセス学習においてmkltensorに対応できていないため、
submit\_train.sh内でtest\_train.pyに与えている実行時オプションのmkltensorをcpu\_nomklに修正する。
また、マルチプロセス学習においても同様にoneDNNに対応できていない可能性がある。
そのため、Pythonプログラムpytorch\_synthetic\_benchmark.pyをPyTorch
v2.9.1の場合と同様に修正する。
