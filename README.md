# 📘 vocab-gradient

This repository contains analysis scripts, stimuli, and writing files for a developmental psychology project examining how children’s visual word knowledge changes over time. The project includes multiple experiments, computational analyses (e.g., CLIP similarity), and manuscript drafts.

---

## 🔍 Project Overview

Children's visual concept knowledge becomes increasingly refined over development. In this project, we assess the **semantic precision of visual word knowledge** using a forced-choice picture-matching paradigm, where distractors are selected based on semantic similarity via multimodal language models (e.g., CLIP).

The repository includes:

- Preprocessing and analysis scripts in R  
- Stimulus generation and item selection  
- Embedding similarity computations  
- Drafts and figures for associated publications  

---

## 🛠 Setup

### Requirements

- R (≥ 4.1.0)  
- Recommended: RStudio  
- R packages used include (but are not limited to):
  - `tidyverse`
  - `knitr`
  - `ggplot2`
  - `magrittr`


## Preferred method: Run from command line using `renv` and notebook

All necessary packages will be loaded using the `renv` environment lockfile.

```bash
R -q -e "install.packages('renv'); renv::restore(prompt=FALSE)"
Rscript -e "rmarkdown::render('writing/paper1_visualvocab.Rmd')"
````



## Option 2: Reproducing key analyses from original files

1. Open the RStudio project: `vocab-gradient.Rproj` and ensure that you have the required libraries
2. Start with `analysis/step1_wrangle_datasets.Rmd` to clean and format the datasets (not required)
3. Run key analysis using the RMarkdown files in `writing/paper1_visualvocab.Rmd`

---

## 📜 License

This project is licensed under the MIT License. See `LICENSE` for details.

```

