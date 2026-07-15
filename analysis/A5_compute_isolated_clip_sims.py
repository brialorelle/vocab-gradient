#!/usr/bin/env python3
"""
Recompute CLIP visual (img-img) and multimodal (img-txt) similarities on the
BACKGROUND-ISOLATED images (stimuli/_isolated/*.png), for exactly the
target-distractor pairs used in the reported model.

Anchor: data/item_metadata/item_meta_and_model_sim.csv
  108 targetWords x 3 distractors = 324 rows (answerWord = distractor/option).

Procedure mirrors stimuli/2_get_all_clip_similarities/compute_clip_similarities.py:
  ViT-B/32, cosine similarity on L2-normalized embeddings.
  - iso_sim_img_img = cos(isolated distractor image, isolated target image)
  - iso_sim_img_txt = cos(target-word text,          isolated distractor image)
(sim_txt_txt is text-only and unchanged, so not recomputed here.)

Output: data/item_metadata/vv_clip_similarities_isolated.csv
"""
import csv
from pathlib import Path

import clip
import torch
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
META = ROOT / "data/item_metadata/item_meta_and_model_sim.csv"
ISO = ROOT / "stimuli/_isolated"
OUT = ROOT / "data/item_metadata/vv_clip_similarities_isolated.csv"


def iso_path(word: str) -> Path:
    return ISO / f"{word.lower()}.png"


def main():
    rows = list(csv.DictReader(open(META, newline="", encoding="utf-8")))

    # every unique image we need = all targetWords + all answerWords
    words = sorted({r["targetWord"] for r in rows} | {r["answerWord"] for r in rows})
    missing = [w for w in words if not iso_path(w).exists()]
    if missing:
        raise SystemExit(f"Missing isolated images for: {missing}")

    device = "cuda" if torch.cuda.is_available() else "cpu"
    model, preprocess = clip.load("ViT-B/32", device=device)

    # ---- encode every isolated image once ----
    img_feat = {}
    batch, order = [], []
    for w in words:
        img = Image.open(iso_path(w)).convert("RGB")   # already white-composited
        batch.append(preprocess(img))
        order.append(w)
    with torch.no_grad():
        feats = model.encode_image(torch.stack(batch).to(device))
        feats = feats / feats.norm(dim=-1, keepdim=True)
    for w, f in zip(order, feats):
        img_feat[w] = f

    # ---- encode the target-word texts ----
    targets = sorted({r["targetWord"] for r in rows})
    tok = clip.tokenize(targets, truncate=True).to(device)
    with torch.no_grad():
        tfeats = model.encode_text(tok)
        tfeats = tfeats / tfeats.norm(dim=-1, keepdim=True)
    txt_feat = {w: f for w, f in zip(targets, tfeats)}

    # ---- per-pair similarities ----
    out = []
    for r in rows:
        tgt, ans = r["targetWord"], r["answerWord"]
        out.append({
            "targetWord": tgt,
            "answerWord": ans,
            "wordPairing": r.get("wordPairing", ""),
            "iso_sim_img_img": (img_feat[ans] @ img_feat[tgt]).item(),
            "iso_sim_img_txt": (img_feat[ans] @ txt_feat[tgt]).item(),
        })

    with open(OUT, "w", newline="", encoding="utf-8") as f:
        wtr = csv.DictWriter(
            f, fieldnames=["targetWord", "answerWord", "wordPairing",
                           "iso_sim_img_img", "iso_sim_img_txt"])
        wtr.writeheader()
        wtr.writerows(out)
    print(f"wrote {len(out)} rows to {OUT}")


if __name__ == "__main__":
    main()
