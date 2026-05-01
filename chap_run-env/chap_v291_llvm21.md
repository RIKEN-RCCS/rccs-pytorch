# PyTorch v2.9.1(llvm21.1.0)<a href="#pytorch-v2-9-1-llvm21-1-0" class="headerlink"
title="Link to this heading">¶</a>

PyTorch v2.3.1におけるResnetの実行には、「富岳」で提供されているPyTorch
v1系向けの実行環境を流用する。

    $ cd ${PYTORCH_TOP}/scripts/Fujitsu
    $ cp -rp /vol0004/apps/oss/PyTorch-1.7.0/example/01_resnet/ .

コピーした環境の内、性能評価として4つの実行用スクリプトと3つのPythonプログラムを用いる。

<table id="id1" class="docutils align-default">
<caption><span class="caption-text">実行用スクリプト</span><a
href="#id1" class="headerlink"
title="Link to this table">¶</a></caption>
<thead>
<tr class="row-odd">
<th class="head"><p>ファイル名</p></th>
<th class="head"><p>処理内容</p></th>
<th class="head"><p>ノード数</p></th>
<th class="head"><p>プロセス数</p></th>
<th class="head"><p>スレッド数/プロセス</p></th>
</tr>
</thead>
<tbody>
<tr class="row-even">
<td><p>submit_train.sh</p></td>
<td><p>シングルプロセス学習</p></td>
<td><p>1</p></td>
<td><p>1</p></td>
<td><p>48</p></td>
</tr>
<tr class="row-odd">
<td><p>submit_val.sh</p></td>
<td><p>シングルプロセス推論</p></td>
<td><p>1</p></td>
<td><p>1</p></td>
<td><p>48</p></td>
</tr>
<tr class="row-even">
<td><p>submit_train_multi.sh</p></td>
<td><p>マルチプロセス学習</p></td>
<td><p>1</p></td>
<td><p>4</p></td>
<td><p>12</p></td>
</tr>
<tr class="row-odd">
<td><p>submit_val_multi.sh</p></td>
<td><p>マルチプロセス推論</p></td>
<td><p>1</p></td>
<td><p>4</p></td>
<td><p>12</p></td>
</tr>
</tbody>
</table>

<table id="id2" class="docutils align-default">
<caption><span class="caption-text">Pythonプログラム</span><a
href="#id2" class="headerlink"
title="Link to this table">¶</a></caption>
<thead>
<tr class="row-odd">
<th class="head"><p>ファイル名</p></th>
<th class="head"><p>用途</p></th>
</tr>
</thead>
<tbody>
<tr class="row-even">
<td><p>test_train.py</p></td>
<td><p>シングルプロセス学習</p></td>
</tr>
<tr class="row-odd">
<td><p>pytorch_synthetic_benchmark.py</p></td>
<td><p>マルチプロセス学習</p></td>
</tr>
<tr class="row-even">
<td><p>test_eval.py</p></td>
<td><p>シングルプロセス推論およびマルチプロセス推論</p></td>
</tr>
</tbody>
</table>

ここで、submit\_train.shとsubmit\_val.shの”.
../env.src”の直後にvenvのactivateを実行する以下の行を追加する。

    . ../env.src
    . ${VENV_PATH}/bin/activate

PyTorch
v2.9.1ではシングルプロセス学習においてmkltensorに対応できていないため、
submit\_train.sh内でtest\_train.pyに与えている実行時オプションのmkltensorをcpu\_nomklに修正する。

    LD_PRELOAD=libtcmalloc.so python3 -u test_train.py --batch 256 --type cpu_nomkl

また、マルチプロセス学習においてもoneDNNに対応できていない可能性がある。そのため、Pythonプログラムpytorch\_synthetic\_benchmark.py
43行目を次のように変更する。 .. code-block:

    mkl_enable = False
