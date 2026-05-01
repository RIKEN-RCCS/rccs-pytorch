:::::: {.body role="main"}
::::: {#resnet .section}
# Resnetの実行[¶](#resnet "Link to this heading"){.headerlink}

Resnetの実行環境に対して、以下の手順で実行する。
なお、バージョン間で実行手順に相違はなく、同じ手順で下記の通り実行を行う。

:::: {.highlight-default .notranslate}
::: highlight
    $ cd {PyTorch環境}/pytorch/scripts/Fujitsu/01_resnet
    $ pjsub submit_train.sh
    $ pjsub submit_val.sh
    $ pjsub submit_train_multi.sh
    $ pjsub submit_val_multi.sh
:::
::::
:::::
::::::
