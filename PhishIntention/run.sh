#!/bin/bash

docker build -t phishintention-docker .

docker run -it --rm \
  -v $(pwd):/workspace/PhishIntention \
  -w /workspace/PhishIntention \
  phishintention-docker \
  bash -c "
    source /opt/miniconda/etc/profile.d/conda.sh && \
    export ENV_NAME=phishintention && \
    bash setup.sh && \
    source /opt/miniconda/etc/profile.d/conda.sh && \
    conda activate phishintention && \
    python phishintention.py --folder ./datasets/test_sites --output_txt ./test.txt
  "
