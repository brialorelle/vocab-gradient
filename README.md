# vocab-gradient

Repository for analyses, stimuli construction, and manuscript assets for a developmental psychology project on how children’s visual word knowledge becomes more semantically precise with age.
# 📘 Developmental changes in the precision of visual vocabulary knowledge.

This repository contains analysis scripts, stimuli, and writing files for a developmental psychology project examining how children’s visual word knowledge changes over time. The project includes data from multiple experiments, computational analyses (e.g., CLIP similarity), and a manuscript draft.

## What this repository contains

This project combines:
- **Stimulus engineering** (item selection + distractor construction).
- **Behavioral trial data wrangling** across child/adult cohorts.
- **Item-level metadata integration** (CLIP similarities, phonological similarity, AoA/typicality/frequency features).
- **Manuscript-ready plots and model summaries**.

Primary analysis language is **R** (with `renv` lockfile support), plus a small Python script used for CLIP-based similarity extraction.
Children's visual concept knowledge becomes increasingly refined over development. In this project, we assess the precision of visual word knowledge using a forced-choice picture-matching paradigm, where distractors are selected based on semantic similarity via multimodal language models (e.g., CLIP).

The repository includes:

- Preprocessing and analysis scripts in R  
- Documentation of the stimulus generation and item selection 
- Embedding similarity computations  
- Drafts and figures for associated publications  

---

## Repository layout

```text
.
├── analysis/
│   ├── step0_merge_metadata.R
│   ├── step1_wrangle_datasets.Rmd
│   └── _old/
├── data/
│   ├── item_metadata/
│   └── preprocessed/
├── stimuli/
│   ├── 0_get_CLIP_similarities/
│   ├── 1_select_items/
│   └── exp3_garden/
├── writing/
│   ├── paper1_visualvocab.Rmd
│   └── figures/
├── renv.lock
└── vocab-gradient.Rproj
```

### Folder-by-folder purpose

- `analysis/`
  Core data pipelines:
  - `step0_merge_metadata.R`: builds combined item metadata table.
  - `step1_wrangle_datasets.Rmd`: merges cohorts, computes trial/distractor summaries, writes analysis-ready `.Rdata` outputs.

- `data/item_metadata/`
  Item-level feature tables (stimulus definitions, CLIP similarity outputs, phonological features, joined metadata).

- `data/preprocessed/`
  Precomputed analysis objects (`.Rdata/.RData`) used by downstream modeling and manuscript scripts.

- `stimuli/`
  Stimulus-generation workflow and final experiment assets.
  - `0_get_CLIP_similarities/`: CLIP-based similarity matrix creation.
  - `1_select_items/`: RMarkdown notebooks for subset/item-pair selection.
  - `exp3_garden/`: finalized trial table plus image/audio assets used in garden experiment deployment.

- `writing/`
  Main manuscript source (`paper1_visualvocab.Rmd`) and exported figure files.

---

## Data structures (raw + derived)

> Note: Some **raw participant-level source files** are referenced in scripts under `data/raw/` but are not fully included in this repository snapshot.

## 1) Raw / source-like structures

### A. Trial design file (garden)
- **File**: `stimuli/exp3_garden/all_trials_garden_final2023-11-09.csv`
- **Role**: final trial list for experiment deployment.
- **Columns**:
  - `Word1`: target word
  - `Word2`: option word (target or distractor)
  - `wordPairing`: relationship label (e.g., target/similarity tier)
  - `source`: source set/provenance
  - `itemGroup`: grouping label (e.g., test/filler)
  - `distractorId`: distractor slot identifier

### B. Pairwise CLIP similarity matrix (THINGS concepts)
- **File**: `stimuli/0_get_CLIP_similarities/things_dataset_item_embeddings.csv`
- **Role**: very wide matrix used for selecting semantically graded distractors.
- **Structure**:
  - `Word` identifies row concept.
  - Remaining columns correspond to pairwise similarity scores against many concepts.
  - Used upstream for controlled distractor difficulty.

### C. Raw datasets expected by analysis scripts (not all versioned here)
The wrangling pipeline in `analysis/step1_wrangle_datasets.Rmd` expects:
- `data/raw/multiAFC_4AFC_clean_combined_data_20251203.csv`
- `data/raw/all_bing_data_for_item_info.csv`
- `data/raw/all_garden_roar_data_with_age.csv`
- `data/raw/multi-afc-april28.csv`
- `data/raw/exp1_all_trials2023-04-11.csv`

and produces:
- `data/raw/all_trial_data.Rdata` (intermediate combined trial-level object)

## 2) Item metadata tables (`data/item_metadata/`)

### `test_items.csv`
Stimulus mapping table (target + option definitions and group labels).

### `vv_clip_similarities.csv`
Core multimodal similarity outputs used in modeling item relationships:
- `target`, `image`, `trial`, `option`
- index columns (`img_idx`, `tgt_idx`)
- similarity features (`sim_img_img`, `sim_img_txt`, `sim_txt_txt`)

### `phon_sim.csv`
Phonological similarity metadata:
- target/response words + IPA columns
- edit-distance fields (`lev_dist`, `max_len`)
- normalized score (`phon_sim`)

### `item_meta_and_model_sim.csv`
Joined feature table produced by `analysis/step0_merge_metadata.R`; combines:
- CLIP-based similarity features
- trial pairing metadata
- AoA bins
- phonological similarity
- lexical covariates (frequency, concreteness, superordinate category, typicality)

### `preprocessed_model_outputs.csv`
Model-facing compact summary for target/distractor predictions including clip probabilities/logits and language/visual correlations.

## 3) Analysis-ready preprocessed objects (`data/preprocessed/`)

These `.RData/.Rdata` objects are saved artifacts used by manuscript analyses:
- `all_trial_data_noschools.Rdata`: trial-level cleaned dataset excluding school cohort.
- `summary_by_distractor.Rdata`: distractor-choice summary by item/age pairing.
- `dist_by_cond_by_age.RData`, `dist_by_4afc_by_item_by_age.RData`: distributional summaries for plotting/modeling.
- `error_by4afc_by_item_for_glmer.RData`: item-level error structure for mixed-effects models.
- `descriptives_data_structures.RData`, `model_output.RData`: manuscript descriptive/model outputs.

---

## End-to-end workflow

1. **Generate candidate similarities** from THINGS concepts using CLIP utilities in `stimuli/0_get_CLIP_similarities/`.
2. **Select and curate item sets** in `stimuli/1_select_items/` notebooks.
3. **Merge item metadata** with lexical/phonological/model features via `analysis/step0_merge_metadata.R`.
4. **Wrangle participant trial data** and compute age/item summaries in `analysis/step1_wrangle_datasets.Rmd`.
5. **Run manuscript analyses/figures** from `writing/paper1_visualvocab.Rmd` using saved preprocessed objects.
## Reproducing key analyses from original files

1. Open the RStudio project: `vocab-gradient.Rproj` and ensure that you have the required libraries
2. All key analysis are contained in the RMarkdown file in `writing/paper1_visualvocab.Rmd`

Other files (e.g., `analysis/step1_wrangle_datasets.Rmd`) were used to clean and format the raw datasets, and can only be used by the research team with IRB access to these data, but is provided for transparency purposes.


## Environment
- R project file: `vocab-gradient.Rproj`
- Dependency lock: `renv.lock`

If R is available locally:


```bash
R -q -e "install.packages('renv'); renv::restore(prompt = FALSE)"
Rscript -e "rmarkdown::render('analysis/step1_wrangle_datasets.Rmd')"
Rscript -e "rmarkdown::render('writing/paper1_visualvocab.Rmd')"
```

## Important caveat
Because some raw input files under `data/raw/` are not included in this snapshot, complete end-to-end regeneration may require access to private/internal source exports.

---

## License

MIT License. See `LICENSE`.
