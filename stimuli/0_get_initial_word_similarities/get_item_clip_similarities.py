"""Compute word-level CLIP similarity across the THINGS dataset.

This script encodes each THINGS concept word using a running clip-as-service
server and writes an item-by-item correlation matrix used for distractor/item
selection.
"""

from pathlib import Path

from clip_client import Client
import numpy as np
import pandas as pd


REPO_ROOT = Path(__file__).resolve().parents[2]
THINGS_CONCEPTS_PATH = REPO_ROOT / "data" / "item_metadata" / "things_concepts.tsv"
OUTPUT_PATH = Path(__file__).resolve().parent / "things_dataset_item_embeddings.csv"


def main() -> None:
    # Start server first, e.g. `python3 -m clip_server`.
    client = Client("grpc://0.0.0.0:51000")

    items = pd.read_csv(THINGS_CONCEPTS_PATH, sep="\t")
    if "Word" not in items.columns:
        raise ValueError(f"Expected a 'Word' column in {THINGS_CONCEPTS_PATH}")

    all_items = items["Word"].dropna().astype(str).tolist()
    item_embeddings = client.encode(all_items)

    # Keep these for sanity/debugging when run interactively.
    n_items = np.size(item_embeddings, 0)
    embedding_dim = np.size(item_embeddings, 1)
    print(f"Encoded {n_items} items with embedding dim {embedding_dim}.")

    item_correlations = np.corrcoef(item_embeddings)
    similarity_df = pd.DataFrame(item_correlations, index=all_items, columns=all_items)
    similarity_df.to_csv(OUTPUT_PATH, index_label="Word")
    print(f"Wrote similarity matrix to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
