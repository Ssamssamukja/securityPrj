import os
import argparse
import numpy as np
from PIL import Image
from torchvision import transforms
import torch

# 모델은 modules/models2.py에 정의되어 있으므로 KNOWN_MODELS에서 불러옵니다
from modules.models2 import KNOWN_MODELS

from utils import l2_norm


def extract_feature(model, image_path, transform, device):
    image = Image.open(image_path).convert('RGB')
    image = transform(image).unsqueeze(0).to(device)

    ocr_emb = torch.zeros((1, 512)).to(device)

    with torch.no_grad():
        feature = model(image, ocr_emb)
        feature = l2_norm(feature)  # 정규화
    return feature.cpu().numpy().squeeze()


def main(logo_dir, output_dir):
    device = 'cuda' if torch.cuda.is_available() else 'cpu'

    # 모델 선택 및 로딩
    model = KNOWN_MODELS['BiT-M-R50x1'](head_size=277).to(device)
    checkpoint = torch.load('models/ocr_siamese.pth.tar', map_location=device)
    model.load_state_dict(checkpoint['model'])
    model.eval()

    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor()
    ])

    logo_feats = []
    logo_files = []

    for root, _, files in os.walk(logo_dir):
        for file in files:
            if file.endswith('.png'):
                image_path = os.path.join(root, file)
                print(f"Processing {image_path}")
                feat = extract_feature(model, image_path, transform, device)
                logo_feats.append(feat)
                logo_files.append(os.path.join(root, file))

    np.save(os.path.join(output_dir, 'LOGO_FEATS.npy'), np.array(logo_feats))
    np.save(os.path.join(output_dir, 'LOGO_FILES.npy'), np.array(logo_files))
    print("Saved features and file names!")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--logo_dir', type=str, required=True)
    parser.add_argument('--output_dir', type=str, required=True)
    args = parser.parse_args()
    main(args.logo_dir, args.output_dir)
