# rccs-pytorch<a href="#rccs-pytorch" class="headerlink" title="Link to this heading">¶</a>

「富岳」向けPyTorch
v2.9.1に対するサンプル問題(Resnet)の動作環境の構築と性能確認、及び従来バージョンとの性能比較について述べる。

## Branches
- [Ver.2.1  : https://github.com/RIKEN-RCCS/rccs-pytorch/tree/r2.1_for_a64fx](https://github.com/RIKEN-RCCS/rccs-pytorch/tree/r2.1_for_a64fx)
- [Ver.2.3.1: https://github.com/RIKEN-RCCS/rccs-pytorch/tree/r2.3.1_for_a64fx](https://github.com/RIKEN-RCCS/rccs-pytorch/tree/r2.3.1_for_a64fx)
- [Ver.2.9.1: https://github.com/RIKEN-RCCS/rccs-pytorch/tree/r2.9.1_for_a64fx](https://github.com/RIKEN-RCCS/rccs-pytorch/tree/r2.9.1_for_a64fx)

## Contents

- <a href="chap_build_prepare/prepare.md"
  class="reference internal">ビルド環境の整備</a>
  - <a href="chap_build_prepare/chap_v291_llvm21.md"
    class="reference internal">PyTorch v2.9.1(llvm21.1.0)</a>
  - <a href="chap_build_prepare/chap_v291_llvm19.md"
    class="reference internal">PyTorch v2.9.1(llvm19.1.4)</a>
  - <a href="chap_build_prepare/chap_v231.md"
    class="reference internal">PyTorch v2.3.1</a>
  - <a href="chap_build_prepare/chap_v21.md"
    class="reference internal">PyTorch v2.1</a>
  - <a href="chap_build_prepare/chap_v1131.md"
    class="reference internal">PyTorch v1.13.1</a>
- <a href="chap_build/build.md"
  class="reference internal">ビルド手順</a>
  - <a href="chap_build/chap_v291_llvm21.md"
    class="reference internal">PyTorch v2.9.1(llvm21.1.0)</a>
  - <a href="chap_build/chap_v291_llvm19.md"
    class="reference internal">PyTorch v2.9.1(llvm19.1.4)</a>
  - <a href="chap_build/chap_v231.md" class="reference internal">PyTorch
    v2.3.1</a>
  - <a href="chap_build/chap_v21.md" class="reference internal">PyTorch
    v2.1</a>
  - <a href="chap_build/chap_v1131.md" class="reference internal">PyTorch
    v1.13.1</a>
- <a href="chap_run-env/resnet.md"
  class="reference internal">Resnetの実行環境の構築</a>
  - <a href="chap_run-env/chap_v291_llvm21.md"
    class="reference internal">PyTorch v2.9.1(llvm21.1.0)</a>
  - <a href="chap_run-env/chap_v291_llvm19.md"
    class="reference internal">PyTorch v2.9.1(llvm19.1.4)</a>
  - <a href="chap_run-env/chap_v231.md" class="reference internal">PyTorch
    v2.3.1</a>
  - <a href="chap_run-env/chap_v21.md" class="reference internal">PyTorch
    v2.1</a>
  - <a href="chap_run-env/chap_v1131.md"
    class="reference internal">PyTorch v1.13.1</a>
- <a href="chap_perf/perf.md"
  class="reference internal">バージョン間の性能比較</a>
  - <a href="chap_perf/chap_run.md"
    class="reference internal">Resnetの実行</a>
  - <a href="chap_perf/chap_perf_single.md"
    class="reference internal">シングルプロセスの性能比較</a>
  - <a href="chap_perf/chap_perf_multi.md"
    class="reference internal">マルチプロセスの性能比較</a>
