# CLIP word-level similarity for THINGS items

This folder contains a utility script for **item selection**.

`get_item_clip_similarities.py` computes **word-level similarity across the full THINGS dataset** by:

1. Loading concept words from `data/item_metadata/things_concepts.tsv`.
2. Encoding each word with a running `clip-as-service` server.
3. Computing an item-by-item correlation matrix from those embeddings.
4. Writing the output to `stimuli/0_get_CLIP_similarities/things_dataset_item_embeddings.csv`.

## Run

From the repository root:

```bash
python3 -m clip_server
python3 stimuli/0_get_CLIP_similarities/get_item_clip_similarities.py
```

## Notes

- This script computes pairwise similarity for **all THINGS words** (not just a small subset).
- The generated matrix is used upstream to help choose semantically graded distractors/items.
