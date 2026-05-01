# PyTorch v1.13.1<a href="#pytorch-v1-13-1" class="headerlink"
title="Link to this heading">¶</a>

実行環境については、PyTorch v2.9.1と同様の手順で作成を行った。 PyTorch
v1.13.1では、シングルプロセス学習においてmkltensorに対応できるため、
test\_train.pyに与えている実行時オプションとして、mkltensorとcpu\_nomklの2通りを実行した。
また、マルチプロセス学習においてもoneDNNに対応する。
そのため、Pythonプログラムpytorch\_synthetic\_benchmark.py
をv2.1以降と同様に修正した場合と修正しない場合の2通りを実行した。
