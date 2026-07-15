#!/usr/bin/env python3
"""
Sanity check: for each of the 432 model images, compute CLIP cosine similarity
between the ORIGINAL image embedding and the ISOLATED (bg-removed) image embedding.
Items where segmentation FAILED (method == FALLBACK_ORIGINAL) kept the original
image, so their self-similarity should be ~1.0.

Output: analysis/A5_image_self_similarity.csv
"""
import csv
from pathlib import Path
import clip, torch
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
META = ROOT / "data/item_metadata/item_meta_and_model_sim.csv"
ORIG_DIR = ROOT / "stimuli/3_selected_stimuli/images_final2023-11-09"
ISO_DIR = ROOT / "stimuli/_isolated"
LOG = ROOT / "analysis/A5_isolation_log.tsv"
OUT = ROOT / "analysis/A5_image_self_similarity.csv"

# fallback + coverage info from the isolation log
info = {r["word"]: r for r in csv.DictReader(open(LOG), delimiter="\t")}

rows = list(csv.DictReader(open(META)))
words = sorted({r["targetWord"] for r in rows} | {r["answerWord"] for r in rows})

# case-insensitive original filename map
orig_files = {p.stem.lower(): p for p in ORIG_DIR.iterdir()
              if p.suffix.lower() in (".jpg", ".jpeg", ".png") and " 2" not in p.stem}

device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load("ViT-B/32", device=device)

def embed(path):
    img = Image.open(path).convert("RGB")
    with torch.no_grad():
        f = model.encode_image(preprocess(img).unsqueeze(0).to(device))
        return (f / f.norm(dim=-1, keepdim=True)).squeeze(0)

out = []
for w in words:
    e_orig = embed(orig_files[w.lower()])
    e_iso = embed(ISO_DIR / f"{w.lower()}.png")
    meta = info.get(w, {})
    out.append({
        "word": w,
        "method": meta.get("method", "NA"),
        "failed": meta.get("method") != "rembg_u2net",
        "coverage": meta.get("coverage", ""),
        "mean_dist_to_white": meta.get("mean_dist_to_white", ""),
        "self_sim": e_orig @ e_iso,
    })

with open(OUT, "w", newline="") as f:
    wtr = csv.DictWriter(f, fieldnames=["word", "method", "failed", "coverage",
                                        "mean_dist_to_white", "self_sim"])
    wtr.writeheader()
    for r in out:
        r["self_sim"] = f'{float(r["self_sim"]):.6f}'
        wtr.writerow(r)
print(f"wrote {len(out)} rows to {OUT}")
