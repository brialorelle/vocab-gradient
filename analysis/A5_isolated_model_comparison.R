#!/usr/bin/env Rscript
# Compare the reported "big model" (exploratory_model_fit) using image-similarity
# metrics computed on ORIGINAL images vs. BACKGROUND-ISOLATED images.
suppressPackageStartupMessages({
  library(tidyverse); library(lmerTest); library(MuMIn); library(here)
})

load(here("data/preprocessed/dist_by_4afc_by_item_by_age.RData"))
d <- dist_by_4afc_by_item_by_age

iso <- read_csv(here("data/item_metadata/vv_clip_similarities_isolated.csv"),
                show_col_types = FALSE)

# join isolated metrics by target + distractor-type (wordPairing)
d2 <- d %>% left_join(iso %>% select(targetWord, wordPairing,
                                     iso_sim_img_img, iso_sim_img_txt),
                      by = c("targetWord", "wordPairing"))
stopifnot(sum(is.na(d2$iso_sim_img_img)) == 0)

# semantic residual: semantic (txt-txt) after regressing out visual (img-img)
d2$sem_resid     <- resid(lm(sim_txt_txt ~ sim_img_img,     data = d2))
d2$sem_resid_iso <- resid(lm(sim_txt_txt ~ iso_sim_img_img, data = d2))

# ---- reported big model, ORIGINAL images (reproduces exploratory_model_fit) ----
m_orig <- lmer(prop ~ scale(AoA_Est_Word1) + scale(AoA_Est_Word2) +
                 scale(sim_img_txt) + scale(sem_resid)*scale(age_group) +
                 scale(phon_sim) + scale(log_freq_target_word) +
                 scale(log_freq_answer_word) + scale(concreteness_target_word) +
                 scale(total_num_errors) + (1 | targetWord),
               data = d2, REML = FALSE)

# ---- same model, ISOLATED images (swap the two image-based metrics) ----
m_iso <- lmer(prop ~ scale(AoA_Est_Word1) + scale(AoA_Est_Word2) +
                scale(iso_sim_img_txt) + scale(sem_resid_iso)*scale(age_group) +
                scale(phon_sim) + scale(log_freq_target_word) +
                scale(log_freq_answer_word) + scale(concreteness_target_word) +
                scale(total_num_errors) + (1 | targetWord),
              data = d2, REML = FALSE)

tidy_fx <- function(m, tag) {
  cf <- summary(m)$coefficients
  tibble(term = rownames(cf), beta = cf[,"Estimate"], se = cf[,"Std. Error"],
         t = cf[,"t value"], p = cf[,"Pr(>|t|)"]) %>%
    mutate(model = tag)
}

norm_term <- function(x) x %>%
  str_replace("iso_sim_img_txt","sim_img_txt") %>%
  str_replace("sem_resid_iso","sem_resid")

cmp <- bind_rows(tidy_fx(m_orig,"original"), tidy_fx(m_iso,"isolated")) %>%
  mutate(term = norm_term(term))

cat("\n=== FIXED EFFECTS: original vs isolated (key image predictors starred) ===\n")
wide <- cmp %>%
  select(term, model, beta, p) %>%
  pivot_wider(names_from = model, values_from = c(beta, p)) %>%
  mutate(term = str_remove_all(term, "scale\\(|\\)")) %>%
  arrange(term)
print(as.data.frame(wide), digits = 3)

cat("\n=== MODEL FIT ===\n")
fit <- tibble(
  model = c("original","isolated"),
  AIC   = c(AIC(m_orig), AIC(m_iso)),
  R2m   = c(r.squaredGLMM(m_orig)[1,"R2m"], r.squaredGLMM(m_iso)[1,"R2m"]),
  R2c   = c(r.squaredGLMM(m_orig)[1,"R2c"], r.squaredGLMM(m_iso)[1,"R2c"]))
print(as.data.frame(fit), digits = 4)

cat("\n=== Correlation of the two image metrics (item level, distractors only) ===\n")
dd <- d2 %>% distinct(targetWord, wordPairing, sim_img_img, iso_sim_img_img,
                      sim_img_txt, iso_sim_img_txt)
cat(sprintf("visual (img-img):   r = %.3f\n", cor(dd$sim_img_img, dd$iso_sim_img_img)))
cat(sprintf("multimodal (img-txt): r = %.3f\n", cor(dd$sim_img_txt, dd$iso_sim_img_txt)))

saveRDS(list(orig = m_orig, iso = m_iso, data = d2),
        here("analysis/A5_isolated_model_fits.rds"))
cat("\nsaved fits -> analysis/A5_isolated_model_fits.rds\n")
