#! /bin/bash

set -euo pipefail

script_basedir=$(cd $(dirname $0); pwd)
source $script_basedir/env.src
[ -v VENV_PATH ] && source $VENV_PATH/bin/activate

set -x

#export OMP_PROC_BIND=false
export OMP_NUM_THREADS=48

# For oneDNN debug
# Output debug message (CSV) to stdout.
# The message begin with 'dnnl_verbose,' which is the first entry in CSV.
#export DNNL_VERBOSE=1			#  0: (no output), 1: (exec), 2: (1 + cache hit/miss)
#export DNNL_VERBOSE_TIMESTAMP=1

ulimit -s 8192

if [ ${PMIX_RANK:-0} -eq 0 ]; then
    env
    pip3 list
    KMP_SETTINGS=1 python3 -c "import torch; print(torch.__version__); print(torch.__config__.show()); print(torch.__config__.parallel_info())"
fi

LD_PRELOAD=$PREFIX/lib/libtcmalloc.so python3 -u mnist.py --epoch 2 --no-cuda --no-mps
