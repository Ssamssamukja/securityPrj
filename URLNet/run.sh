#!/bin/bash

docker build -t phishing-tf .

docker run -it --rm \
  -v $(pwd):/app \
  -w /app \
  phishing-tf \
  python test.py \
    --model.emb_mode 5 \
    --data.data_dir data/phishing_urls.txt \
    --log.checkpoint_dir output_5/checkpoints/model-2430 \
    --log.output_dir results/output.txt \
    --data.word_dict_dir output_5/words_dict.p \
    --data.char_dict_dir output_5/chars_dict.p \
    --data.subword_dict_dir output_5/subwords_dict.p
