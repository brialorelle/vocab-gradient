# Preprocessed Data Dictionary (Column-Spec)

This dictionary documents preprocessed data artifacts for this project at **column-spec level** (name, type, meaning, units, allowed values, missingness notes), based on the preprocessing and analysis code.

## Global conventions

- **Scope**: all preprocessed structures referenced in analysis (`data/preprocessed/*`) and preprocessed model-output tables in `data/item_metadata/*`.
- **`age_group`**: computed as floor of age in years; **`25` denotes adults**.
- **`correct`**: may be represented as either logical (`TRUE/FALSE`) or numeric (`1/0`) depending on source/merge path.
- **`rt`**: reaction time in **milliseconds**.
- **`clip_cor`**: cosine similarity between target and answer words; for target identity rows (`targetWord == answerWord`), value is `1`.
- **Bootstrap intervals**: confidence intervals are **95%** CIs.
- **Format requested**: Markdown only.
- **Data sharing constraint**: `data/raw/all_trial_data.Rdata` contains non-shareable school trial data and is not public; `data/preprocessed/all_trial_data_noschools.Rdata` is the shareable counterpart (same structure with school cohort rows removed).


## Data sharing and source-trial relationship

- **Non-public source file**: `data/raw/all_trial_data.Rdata` includes school-partnership trial-level records that cannot be publicly shared.
- **Public/shareable file**: `data/preprocessed/all_trial_data_noschools.Rdata` is the same trial-level structure with `cohort == "schools"` rows removed.
- This relation is implemented in preprocessing by filtering `df.4AFC.trials.clean` to exclude `schools` before saving `df.4AFC.trials.clean.noschools`.

---

## 1) `data/preprocessed/all_trial_data_noschools.Rdata`

### Object: `df.4AFC.trials.clean.noschools`
**Grain**: one row per trial-level participant response (4AFC), excluding `schools` cohort.

| Column | Type | Meaning | Allowed/Typical values | Units | Missingness notes |
|---|---|---|---|---|---|
| `pid` | character | Participant/session identifier | cohort-specific string IDs | — | Should be non-missing |
| `answerWord` | character | Response option selected by participant | vocabulary item strings | — | Should be non-missing |
| `targetWord` | character | Target word presented on trial | vocabulary item strings | — | Should be non-missing |
| `numAFC` | integer | Number of response alternatives | expected `4` | options count | Should be non-missing |
| `correct` | logical or numeric | Whether selected response matched target | `TRUE/FALSE` or `1/0` | — | Should be non-missing |
| `rt` | numeric | Reaction time to respond | positive numeric | milliseconds | May vary by source but unit is ms |
| `wordPairing` | factor/character | Distractor relation class of `answerWord` to `targetWord` | `target`, `hard`, `easy`, `distal` | — | Expected non-missing after cleaning |
| `age_group` | integer | Age bin used in analyses | floored age in years; `25` adults | years | Should be non-missing post-clean |
| `clip_cor` | numeric | Cosine similarity for (`targetWord`, `answerWord`) | typically [0,1]; target rows `1` | cosine similarity | Can be missing pre-join; expected present in clean output |
| `cohort` | factor/character | Data source cohort label | e.g., `garden`, `bing`, `adults_*` (excluding `schools` in this file) | — | Non-missing expected |

---

## 2) `data/preprocessed/summary_by_distractor.Rdata`

### Object: `df.4AFC.distractor.summary.byAge.clean`
**Grain**: one row per (`targetWord`, `answerWord`, `age_group`) in full 4AFC item structure.

| Column | Type | Meaning | Allowed/Typical values | Units | Missingness notes |
|---|---|---|---|---|---|
| `targetWord` | character | Trial target word | vocabulary item strings | — | Non-missing expected |
| `answerWord` | character | Candidate/selected response word in structure | vocabulary item strings | — | Non-missing expected |
| `wordPairing` | factor/character | Pairing category | `target`, `hard`, `easy`, `distal` | — | Non-missing expected |
| `age_group` | integer | Age bin | floored years; `25` adults | years | Non-missing expected |
| `numAFC` | integer | Number of response alternatives | `4` | options count | Non-missing expected |
| `clip_cor` | numeric | Cosine similarity for target-answer pair | target row = `1` | cosine similarity | Expected non-missing |
| `AoA_Est_Word1` | numeric | Estimated AoA for target word | positive numeric | years (estimated) | May be missing for some items |
| `AoA_Est_Word2` | numeric | Estimated AoA for answer word | positive numeric | years (estimated) | May be missing for some items |
| `AoA_Bin` | integer | Tercile bin of target AoA | `1`, `2`, `3` | bin index | Derived; may be NA if AoA missing |
| `AoA_Bin_Name` | factor | Label for AoA bin | `Early AoA`, `Med AoA`, `Late AOA` | — | Derived; may be NA if AoA missing |
| `n` | integer | Number of times answer was chosen | nonnegative integer | count | NA for unseen target-by-age combinations |
| `medianRT` | numeric | Median RT for observed selections | positive numeric | milliseconds | NA when no observed selections |
| `totalAttempts` | integer | Number of attempts for target in age bin | nonnegative integer | count | NA when target unseen in that age |
| `perc` | numeric | Selection proportion (`n/totalAttempts`) | [0,1] | proportion | **0** for seen-but-never-chosen distractors; **NA** for truly unseen target-age |

---

## 3) `data/preprocessed/descriptives_data_structures.RData`

Contains objects: `n_by_age_group`, `trials_by_participant`, `longitudinal_participants`, `by_cohort`, `accuracy_by_cohort_by_age`.

### 3a) Object: `n_by_age_group`
**Grain**: one row per age group.

| Column | Type | Meaning | Allowed/Typical values |
|---|---|---|---|
| `age_group` | integer | Floored age in years (`25` adults) | positive integers + 25 |
| `num_participants` | integer | Unique participant count in age group | nonnegative integer |

### 3b) Object: `trials_by_participant`
**Grain**: one row per participant.

| Column | Type | Meaning | Allowed/Typical values |
|---|---|---|---|
| `pid` | character | Participant/session identifier | string IDs |
| `mean_pc` | numeric | Mean proportion correct across trials | [0,1] |
| `num_trials` | integer | Number of distinct target-word trials | positive integer |

### 3c) Object: `longitudinal_participants`

| Field | Type | Meaning |
|---|---|---|
| value | integer scalar | Count of participants with `num_trials > 80` |

### 3d) Object: `by_cohort`
**Grain**: one row per cohort.

| Column | Type | Meaning | Allowed/Typical values |
|---|---|---|---|
| `cohort` | factor/character | Cohort label | `schools`, `garden`, `bing`, `adults_monolingual`, `adults_ell`, etc. |
| `num_participants` | integer | Unique participant count in cohort | nonnegative integer |

### 3e) Object: `accuracy_by_cohort_by_age`
**Grain**: one row per (`school_type`, `age_group`) summary row.

| Column | Type | Meaning | Allowed/Typical values |
|---|---|---|---|
| `school_type` | factor/character | School/cohort type used for plotting | source labels |
| `age_group` | integer | Floored age in years (`25` adults) | positive integers + 25 |
| `mean` | numeric | Bootstrapped mean accuracy estimate | [0,1] |
| `ci_lower` | numeric | 95% CI lower bound | [0,1] |
| `ci_upper` | numeric | 95% CI upper bound | [0,1] |
| *(possible extras)* | — | Additional columns may appear from bootstrap helper | e.g., count columns |

---

## 4) `data/preprocessed/dist_by_cond_by_age.RData`

Contains objects: `dist_by_cond_by_age_count`, `dist_by_cond_by_age`.

### 4a) Object: `dist_by_cond_by_age_count`
**Grain**: one row per (`age_group`, error condition).

| Column | Type | Meaning | Allowed/Typical values |
|---|---|---|---|
| `age_group` | integer | Floored age in years (`25` adults) | positive integers + 25 |
| `wordPairing` | factor/character | Error condition key | `prop_hard`, `prop_easy`, `prop_distal` (or relabeled equivalent) |
| `num_errors` | integer | Total errors observed in bin | nonnegative integer |

### 4b) Object: `dist_by_cond_by_age`
**Grain**: one row per (`age_group`, error condition) with bootstrap summary.

| Column | Type | Meaning | Allowed/Typical values |
|---|---|---|---|
| `age_group` | integer | Floored age in years (`25` adults) | positive integers + 25 |
| `wordPairing` | factor | Error condition label | `High sim. dist`, `Med sim. dist.`, `Low sim. dist.` |
| `mean` | numeric | Bootstrapped mean error proportion | [0,1] |
| `ci_lower` | numeric | 95% CI lower bound | [0,1] |
| `ci_upper` | numeric | 95% CI upper bound | [0,1] |
| `num_errors` | integer | Joined count of total errors | nonnegative integer |

---

## 5) `data/preprocessed/error_by4afc_by_item_for_glmer.RData`

### Object: `error_by4afc_by_item_for_glmer`
**Grain**: one row per (`targetWord`, `age_group`) with wide-format error counts.

| Column | Type | Meaning | Allowed/Typical values |
|---|---|---|---|
| `targetWord` | character | Target item identifier | vocabulary item strings |
| `age_group` | integer | Floored age in years (`25` adults) | positive integers + 25 |
| `hard` | integer | Count of high-similarity distractor errors | nonnegative integer |
| `easy` | integer | Count of medium-similarity distractor errors | nonnegative integer |
| `distal` | integer | Count of low-similarity distractor errors | nonnegative integer |
| `total_num_errors` | integer | `hard + easy + distal` | nonnegative integer |
| `AoA_Est_Word1` | numeric | Estimated AoA for target item | positive numeric |

---

## 6) `data/preprocessed/model_output.RData`

### Object: `model`
**Type**: fitted `lm` object.

| Field | Type | Meaning |
|---|---|---|
| `model` | `lm` | Linear model fit for `prop_hard ~ scale(age_group) + scale(total_num_errors)` |

**Source data semantics**: `prop_hard` is derived as `hard / total_num_errors` at participant level in analysis code.

---

## 7) `data/preprocessed/dist_by_4afc_by_item_by_age.RData`

### Object: `dist_by_4afc_by_item_by_age`
**Grain**: one row per (`targetWord`, `age_group`, `wordPairing`) with item-level covariates.

| Column | Type | Meaning | Allowed/Typical values | Units |
|---|---|---|---|---|
| `targetWord` | character | Target item identifier | vocabulary item strings | — |
| `age_group` | integer | Floored age in years (`25` adults) | positive integers + 25 | years |
| `wordPairing` | factor/character | Error category | `hard`, `easy`, `distal` | — |
| `prop` | numeric | Proportion of errors in category | [0,1] | proportion |
| `total_num_errors` | integer | Total errors for target-age bin | nonnegative integer | count |
| `AoA_Est_Word1` | numeric | Estimated AoA of target word | positive numeric | years (estimated) |
| `AoA_Est_Word2` | numeric | Estimated AoA of answer word | positive numeric | years (estimated) |
| `sim_img_img` | numeric | Visual similarity (image-image) | continuous | cosine similarity |
| `sim_img_txt` | numeric | Cross-modal similarity (image-text) | continuous | cosine similarity |
| `sim_txt_txt` | numeric | Linguistic similarity (text-text) | continuous | cosine similarity |
| `phon_sim` | numeric | Phonological similarity | continuous | similarity metric |
| `log_freq_target_word` | numeric | Log word frequency (target) | continuous | log-frequency |
| `log_freq_answer_word` | numeric | Log word frequency (answer) | continuous | log-frequency |
| `concreteness_target_word` | numeric | Concreteness rating of target | continuous | rating scale |

---

## 8) `data/item_metadata/preprocessed_model_outputs.RData`
## 9) `data/item_metadata/preprocessed_model_outputs.csv`

These are preprocessed model-output artifacts in metadata space; include them in final data inventories.

### Minimum documented schema fields

| Column | Type | Meaning |
|---|---|---|
| `targetWord` | character | Target item identifier |
| `answerWord` | character | Paired distractor/answer item |
| `wordPairing` | factor/character | Pairing category |
| `sim_txt_txt` | numeric | Linguistic cosine similarity |
| `sim_img_img` | numeric | Visual cosine similarity |
| `sim_img_txt` | numeric | Cross-modal cosine similarity |

> If you want, I can add a second pass that fully enumerates every column in these two files once we confirm they are the intended canonical source for model-output metadata.
