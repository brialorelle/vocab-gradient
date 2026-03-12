#!/usr/bin/env python3
"""
Compute CLIP similarities from data/manifest.csv and write vv_clip_similarities.csv.
Uses openai/clip for image and text embeddings.
"""

import csv
from pathlib import Path

import clip
import torch
from PIL import Image


def main():
    manifest_path = Path("data/manifest.csv")
    output_path = Path("vv_clip_similarities.csv")
    base_dir = Path("data")

    device = "cuda" if torch.cuda.is_available() else "cpu"
    model, preprocess = clip.load("ViT-B/32", device=device)

    with open(manifest_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        manifest_rows = list(reader)

    all_image_paths = []
    all_image_names = []

    all_texts = []
    for row in manifest_rows:
        image1_path = base_dir / row["image1"]
        image2_path = base_dir / row["image2"]
        image3_path = base_dir / row["image3"]
        image4_path = base_dir / row["image4"]
        paths = (image1_path, image2_path, image3_path, image4_path)
        for path in paths:
            all_image_paths.append(path)
            all_image_names.append(path.stem)
        all_texts.extend([all_image_names[-4], all_image_names[-3], all_image_names[-2], all_image_names[-1]])

    # encode text
    text_tokens = clip.tokenize(all_texts, truncate=True).to(device)
    with torch.no_grad():
        text_features = model.encode_text(text_tokens)
        text_features = text_features / text_features.norm(dim=-1, keepdim=True)

    images_tensor = []
    for path in all_image_paths:
        img = Image.open(path).convert("RGB")
        images_tensor.append(preprocess(img))
    images_batch = torch.stack(images_tensor).to(device)

    # encode images
    with torch.no_grad():
        image_features = model.encode_image(images_batch)
        image_features = image_features / image_features.norm(dim=-1, keepdim=True)

    # compute similarities
    TEXTS_PER_TRIAL = 4
    out_rows = []
    for trial_idx, row in enumerate(manifest_rows, start=1):
        text1 = row["text1"].strip()
        start_idx = (trial_idx - 1) * 4
        tgt_idx = start_idx + 1
        text_start = ((tgt_idx - 1) // 4) * TEXTS_PER_TRIAL

        tgt_text_feat = text_features[text_start]  # image1 name == text1
        tgt_image_feat = image_features[start_idx]

        for option in range(4):
            img_idx_1based = start_idx + option + 1
            option_name = f"image{option + 1}"
            image_name = all_image_names[start_idx + option]

            img_feat = image_features[start_idx + option]
            img_name_feat = text_features[text_start + option]

            sim_img_img = (img_feat @ tgt_image_feat).item()
            sim_img_txt = (img_feat @ tgt_text_feat).item()
            sim_txt_txt = (img_name_feat @ tgt_text_feat).item()

            out_rows.append({
                "target": text1,
                "trial": trial_idx,
                "option": option_name,
                "image": image_name,
                "img_idx": img_idx_1based,
                "tgt_idx": tgt_idx,
                "sim_img_img": sim_img_img,
                "sim_img_txt": sim_img_txt,
                "sim_txt_txt": sim_txt_txt,
            })

    fieldnames = [
        "target", "trial", "option", "image", "img_idx", "tgt_idx",
        "sim_img_img", "sim_img_txt", "sim_txt_txt",
    ]
    with open(output_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(out_rows)

if __name__ == "__main__":
    main()
