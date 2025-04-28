#!/bin/bash
set -e

# Check ENV_NAME
if [ -z "$ENV_NAME" ]; then
  echo "ENV_NAME is not set!"
  exit 1
fi

CONDA_BASE=$(conda info --base)
source "$CONDA_BASE/etc/profile.d/conda.sh"

# Create or activate environment
if conda info --envs | grep -q "^$ENV_NAME "; then
  echo "Activating existing env: $ENV_NAME"
  conda activate "$ENV_NAME"
else
  echo "Creating env: $ENV_NAME"
  conda create -y -n "$ENV_NAME" python=3.9
  conda activate "$ENV_NAME"
fi

# Install pip packages
pip install --upgrade pip
pip install -r requirements.txt
pip install "numpy<2"

# Install PyTorch and detectron2
OS=$(uname -s)

if [[ "$OS" == "Darwin" ]]; then
  echo "Installing for macOS"
  pip install torch==1.9.0 torchvision==0.10.0 torchaudio==0.9.0
  pip install 'git+https://github.com/facebookresearch/detectron2.git'
else
  if command -v nvidia-smi &> /dev/null; then
    echo "Installing for CUDA"
    pip install torch==1.9.0+cu111 torchvision==0.10.0+cu111 torchaudio==0.9.0 -f https://download.pytorch.org/whl/torch_stable.html
    pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu111/torch1.9/index.html
  else
    echo "Installing CPU-only version"
    pip install torch==1.9.0+cpu torchvision==0.10.0+cpu torchaudio==0.9.0 -f https://download.pytorch.org/whl/torch_stable.html
    pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cpu/torch1.9/index.html
  fi
fi

# Model download
mkdir -p models
cd models

download_with_retry() {
  local file_id="$1"
  local file_name="$2"
  local count=0

  until [ $count -ge 3 ]; do
    gdown --id "$file_id" -O "$file_name" && break
    count=$((count+1))
    echo "Retry $count for $file_name..."
    sleep 1
  done

  if [ $count -ge 3 ]; then
    echo "Failed to download $file_name"
    exit 1
  fi
}

declare -A MODEL_FILES=(
  ["rcnn_bet365.pth"]="1tE2Mu5WC8uqCxei3XqAd7AWaP5JTmVWH"
  ["faster_rcnn.yaml"]="1Q6lqjpl4exW7q_dPbComcj0udBMDl8CW"
  ["resnetv2_rgb_new.pth.tar"]="1H0Q_DbdKPLFcZee8I14K62qV7TTy7xvS"
  ["expand_targetlist.zip"]="1fr5ZxBKyDiNZ_1B6rRAfZbAHBBoUjZ7I"
  ["domain_map.pkl"]="1qSdkSSoCYUkZMKs44Rup_1DPBxHnEKl1"
  ["layout_detector.pth"]="1HWjE5Fv-c3nCDzLCBc7I3vClP1IeuP_I"
  ["crp_classifier.pth.tar"]="1igEMRz0vFBonxAILeYMRWTyd7A9sRirO"
  ["crp_locator.pth"]="1_O5SALqaJqvWoZDrdIVpsZyCnmSkzQcm"
  ["ocr_siamese.pth.tar"]="1BxJf5lAcNEnnC0In55flWZ89xwlYkzPk"
  ["ocr_pretrained.pth.tar"]="15pfVWnZR-at46gqxd50cWhrXemP8oaxp"
)

for file_name in "${!MODEL_FILES[@]}"; do
  file_id="${MODEL_FILES[$file_name]}"
  if [ -f "$file_name" ]; then
    echo "$file_name exists, skipping."
  else
    download_with_retry "$file_id" "$file_name"
  fi
done

# Unzip expand_targetlist
unzip -o expand_targetlist.zip -d expand_targetlist

echo "Setup completed successfully!"
