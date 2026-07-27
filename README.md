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
- `error_by4afc_for_glmer.RData`: participant-level error structure behind manuscript Table 2.
- `descriptives_data_structures.RData`: participant descriptives; also carries the
  repeat-participant count the supplement needs, so the manuscript must be knitted
  before the supplement (see the reproducibility guide below).
- `model_output.RData`: fitted Table 2 model, retained for reference. The manuscript
  refits from `error_by4afc_for_glmer.RData` rather than restoring this object.

---

## End-to-end workflow

1. **Generate candidate similarities** from THINGS concepts using CLIP utilities in `stimuli/0_get_CLIP_similarities/`.
2. **Select and curate item sets** in `stimuli/1_select_items/` notebooks.
3. **Merge item metadata** with lexical/phonological/model features via `analysis/step0_merge_metadata.R`.
4. **Wrangle participant trial data** and compute age/item summaries in `analysis/step1_wrangle_datasets.Rmd`.
5. **Run manuscript analyses/figures** from `writing/visual_vocab_manuscript_r4.Rmd` using saved preprocessed objects.

---

# Reproducibility guide

**Everything reported in the manuscript is computed at knit time.** No statistic,
sample size, or model coefficient is typed as a literal — each is produced by
inline R against the data. Re-knitting the two documents below regenerates every
number, table, and data-bearing figure panel.

## Quick start

```bash
# 1. Restore the recorded package environment
R -q -e "install.packages('renv'); renv::restore(prompt = FALSE)"

# 2. Render the manuscript, then the supplement (order matters — see below)
Rscript -e "rmarkdown::render('writing/visual_vocab_manuscript_r4.Rmd')"
Rscript -e "rmarkdown::render('writing/visual_vocab_supplement_r4.Rmd')"
```

Outputs land beside the sources as `visual_vocab_manuscript_r4.docx` and
`visual_vocab_supplement_r4.docx`.

## The two documents

| File | Contents |
|---|---|
| `writing/visual_vocab_manuscript_r4.Rmd` | Main manuscript: Tables 1–2, Figures 1–4 |
| `writing/visual_vocab_supplement_r4.Rmd` | Supplement: Tables 1–3, Figures 1–4 |
| `writing/REPRODUCIBILITY_NOTES.md` | Verification record and audit trail |

`writing/visual_vocab_manuscript_r3.Rmd` is the previous revision, retained for
history. It hardcodes some values and should not be used for reproduction.

## `RAW_DATA`: which data you have

Near the top of each `.Rmd` is a switch:

```r
RAW_DATA <- TRUE   # recompute from trial-level data (research team only)
RAW_DATA <- FALSE  # use the shareable preprocessed summaries
```

**Outside the research team, set `RAW_DATA <- FALSE`.** Trial-level data for the
school cohort is governed by district data-sharing agreements and FERPA and is
not in this repository. The `FALSE` branch reads the preprocessed summaries in
`data/preprocessed/`, which *are* included.

Both paths produce **identical reported values**. This was verified by moving
`data/raw/` out of the tree entirely and re-rendering: 349 numeric tokens in the
manuscript and 207 in the supplement, with no differences between modes.

### Ordering constraint

The manuscript writes `data/preprocessed/descriptives_data_structures.RData`,
which the supplement reads. **Render the manuscript first.** If that file is
missing or stale, the supplement stops with an explanatory message rather than
producing wrong numbers.

### Files the `RAW_DATA = FALSE` path needs

All are committed:

```
data/preprocessed/summary_by_distractor.Rdata
data/preprocessed/descriptives_data_structures.RData
data/preprocessed/dist_by_cond_by_age.RData
data/preprocessed/error_by4afc_for_glmer.RData
data/preprocessed/dist_by_4afc_by_item_by_age.RData
data/item_metadata/item_meta_and_model_sim.csv
```

## Determinism

`set.seed(42)` is set once at the top of each document. Bootstrapped confidence
intervals and the 50 cross-validation splits behind Figure 4C reproduce exactly
under the package versions in `renv.lock`. The environment used for the
verification run:

```
R 4.3.1           papaja 0.1.4        tidyverse 2.0.0     lme4 1.1.34
lmerTest 3.1.3    MuMIn 1.47.5        langcog 0.1.9001    broom.mixed 0.2.9.4
car 3.1.2         ggthemes 4.2.4      viridis 0.6.4       knitr 1.51
rmarkdown 2.30    here 1.0.1          assertthat 0.2.1    kableExtra 1.4.0
```

`langcog` is not on CRAN: `remotes::install_github("langcog/langcog")`.

## Built-in self-checks

The documents assert their own claims and **fail the knit** rather than emitting
a wrong number if any of these break:

- Cohort sample sizes sum to the reported total
- Every example word cited in the text is present in the figure it refers to
- Figure 3A displays exactly the number of items its caption states
- Multimodal similarity remains the strongest single predictor in Figure 4C,
  with a confidence interval that does not overlap the runner-up
- Supplemental Table 1's participant column reconciles with the total sample

## Figures

Figures 1–4 are composites assembled in Illustrator. The `.Rmd` regenerates the
data-bearing panels into `writing/figures/` on every knit (`REGEN_PANELS <- TRUE`),
so a change shows up in `git diff`, but **the composites themselves must be
rebuilt by hand** — the `.Rmd` displays the finished `.png`. If a panel changes,
update the corresponding `.ai` file.

## Known limitation

`writing/number_tables.lua` repairs table-caption numbering. papaja's docx filter
assumes pandoc's caption inlines have no leading anchor `Span`; because one is
present, its rewrite overwrites the table number and captions render as a bare
"Table". The filter removes that span to restore the expected alignment. Keep it
wired in via `pandoc_args` or the tables lose their numbers.

## Caveat on full end-to-end regeneration

Stimulus construction (`stimuli/`) and the initial data wrangling
(`analysis/step1_wrangle_datasets.Rmd`) require raw exports that are not in this
repository. They are provided for transparency but can only be run by the
research team with IRB access. Reproducing the *manuscript* does not require
them — the preprocessed summaries are sufficient.

---

## License

MIT License. See `LICENSE`.
