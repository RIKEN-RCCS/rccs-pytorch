# Resnetの実行<a href="#resnet" class="headerlink" title="Link to this heading">¶</a>

Resnetの実行環境に対して、以下の手順で実行する。
なお、バージョン間で実行手順に相違はなく、同じ手順で下記の通り実行を行う。

    $ cd {PyTorch環境}/pytorch/scripts/Fujitsu/01_resnet
    $ pjsub submit_train.sh
    $ pjsub submit_val.sh
    $ pjsub submit_train_multi.sh
    $ pjsub submit_val_multi.sh
