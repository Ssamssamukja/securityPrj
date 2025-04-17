#!/bin/bash

docker build -t phishpedia-docker .

docker run -it --rm \
  -v $(pwd):/workspace/Phishpedia \
  -w /workspace/Phishpedia \
  phishpedia-docker \
  bash -c "apt update && apt install -y dos2unix && dos2unix setup.sh && source /opt/miniconda/etc/profile.d/conda.sh && bash setup.sh && conda activate phishpedia && python phishpedia.py --folder ./datasets/test_sites"
