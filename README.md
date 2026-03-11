# 📘 Developmental changes in the precision of visual vocabulary knowledge.

This repository contains analysis scripts, stimuli, and writing files for a developmental psychology project examining how children’s visual word knowledge changes over time. The project includes data from multiple experiments, computational analyses (e.g., CLIP similarity), and a manuscript draft.

---

## 🔍 Project Overview

Children's visual concept knowledge becomes increasingly refined over development. In this project, we assess the precision of visual word knowledge using a forced-choice picture-matching paradigm, where distractors are selected based on semantic similarity via multimodal language models (e.g., CLIP).

The repository includes:

- Preprocessing and analysis scripts in R  
- Documentation of the stimulus generation and item selection 
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



## Reproducing key analyses from original files

1. Open the RStudio project: `vocab-gradient.Rproj` and ensure that you have the required libraries
2. All key analysis are contained in the RMarkdown file in `writing/paper1_visualvocab.Rmd`

Other files (e.g., `analysis/step1_wrangle_datasets.Rmd`) were used to clean and format the raw datasets, and can only be used by the research team with IRB access to these data, but is provided for transparency purposes.



```

