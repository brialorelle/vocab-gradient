#!/usr/bin/env python3
"""
Compute CLIP img-img and img-txt similarities for every model pair, on BOTH the
original images and the isolated images, using ONE identical code path (fp32/CPU,
ViT-B/32). This removes the fp16-vs-fp32 numerical confound so that before/after
differences reflect ONLY background segmentation.

Output: data/item_metadata/vv_clip_sims_orig_vs_iso.csv
"""
import csv
from pathlib import Path
import clip, torch
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
META = ROOT / "data/item_metadata/item_meta_and_model_sim.csv"
ORIG_DIR = ROOT / "stimuli/3_selected_stimuli/images_final2023-11-09"
ISO_DIR = ROOT / "stimuli/_isolated"
OUT = ROOT / "data/item_metadata/vv_clip_sims_orig_vs_iso.csv"

rows = list(csv.DictReader(open(META)))
words = sorted({r["targetWord"] for r in rows} | {r["answerWord"] for r in rows})
targets = sorted({r["targetWord"] for r in rows})
orig_files = {p.stem.lower(): p for p in ORIG_DIR.iterdir()
              if p.suffix.lower() in (".jpg", ".jpeg", ".png") and " 2" not in p.stem}

device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load("ViT-B/32", device=device)

def embed_images(paths):
    batch = torch.stack([preprocess(Image.open(p).convert("RGB")) for p in paths]).to(device)
    with torch.no_grad():
        f = model.encode_image(batch)
        return f / f.norm(dim=-1, keepdim=True)

def embed_texts(txts):
    with torch.no_grad():
        f = model.encode_text(clip.tokenize(txts, truncate=True).to(device))
        return f / f.norm(dim=-1, keepdim=True)

orig_img = dict(zip(words, embed_images([orig_files[w.lower()] for w in words])))
iso_img  = dict(zip(words, embed_images([ISO_DIR / f"{w.lower()}.png" for w in words])))
txt = dict(zip(targets, embed_texts(targets)))

out = []
for r in rows:
    t, a = r["targetWord"], r["answerWord"]
    out.append({
        "targetWord": t, "answerWord": a, "wordPairing": r.get("wordPairing", ""),
        "orig_img_img": (orig_img[a] @ orig_img[t]).item(),
        "iso_img_img":  (iso_img[a]  @ iso_img[t]).item(),
        "orig_img_txt": (orig_img[a] @ txt[t]).item(),
        "iso_img_txt":  (iso_img[a]  @ txt[t]).item(),
    })

with open(OUT, "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(out[0].keys()))
    w.writeheader(); w.writerows(out)
print(f"wrote {len(out)} rows to {OUT}")
