# PyTorch v2.3.1<a href="#pytorch-v2-3-1" class="headerlink"
title="Link to this heading">¶</a>

ビルド環境の整備後、計算ノード上にて以下のように実行する。なお、すべてのscriptを実行するのには9時間程度を要する。

    $ cd ${PYTORCH_TOP}/scripts/fujitsu
    $ . ./env.src
    $ bash 1_python.sh
    $ bash 3_venv.sh
    $ bash 4_numpy_scipy.sh
    $ bash 5_pytorch.sh
    $ bash 6_vision.sh
    $ bash 7_horovod.sh
    $ bash 8_libtcmalloc.sh

ビルド用のスクリプトの実行後に出力されるpip3
list(pip3\_list.txt)の内容を示す。

    Package            Version
    ------------------ ------------------
    astunparse         1.6.3
    attrs              25.4.0
    beniget            0.4.2.post1
    certifi            2026.1.4
    cffi               2.0.0
    charset-normalizer 3.4.4
    cloudpickle        3.1.2
    Cython             0.29.37
    exceptiongroup     1.3.1
    expecttest         0.3.0
    filelock           3.19.1
    fsspec             2025.10.0
    gast               0.6.0
    horovod            0.26.1
    hypothesis         6.141.1
    idna               3.11
    iniconfig          2.1.0
    Jinja2             3.1.6
    lark               1.3.1
    MarkupSafe         3.0.3
    mpmath             1.3.0
    networkx           3.2.1
    numpy              1.22.4
    optree             0.18.0
    packaging          25.0
    Pillow             8.0.1
    pip                24.2
    pluggy             1.6.0
    ply                3.11
    psutil             7.2.1
    pybind11           3.0.1
    pycparser          2.23
    Pygments           2.19.2
    pytest             8.4.2
    pythran            0.18.1
    PyYAML             6.0.3
    requests           2.32.5
    scipy              1.10.1
    setuptools         59.5.0
    six                1.17.0
    sortedcontainers   2.4.0
    sympy              1.14.0
    tomli              2.4.0
    torch              2.3.0a0+gite395b8f
    torchvision        0.18.1a0+126fc22
    types-dataclasses  0.6.6
    typing_extensions  4.15.0
    urllib3            2.6.3
    wheel              0.45.1
