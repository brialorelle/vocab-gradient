#!/usr/bin/env Rscript
# Fig 4C analysis (cross-validated variance explained) on ORIGINAL vs ISOLATED
# image-similarity metrics. Same 50 stratified 80% splits used for both versions
# (paired comparison). Children only (age_group < 25), per the manuscript.
suppressPackageStartupMessages({
  library(tidyverse); library(lmerTest); library(MuMIn); library(here)
})
options(dplyr.summarise.inform = FALSE)

load(here("data/preprocessed/dist_by_4afc_by_item_by_age.RData"))
iso <- read_csv(here("data/item_metadata/vv_clip_similarities_isolated.csv"),
                show_col_types = FALSE)

d <- dist_by_4afc_by_item_by_age %>%
  left_join(iso %>% select(targetWord, wordPairing, iso_sim_img_img, iso_sim_img_txt),
            by = c("targetWord", "wordPairing"))
stopifnot(sum(is.na(d$iso_sim_img_img)) == 0)

# semantic residual (semantic txt-txt after regressing out visual img-img)
d$sem_resid     <- resid(lm(sim_txt_txt ~ sim_img_img,     data = d))
d$sem_resid_iso <- resid(lm(sim_txt_txt ~ iso_sim_img_img, data = d))

data_all <- d %>% filter(age_group < 25)

R2c <- function(m) suppressWarnings(r.squaredGLMM(m))[2]   # conditional R^2
ctrl <- "scale(age_group) + scale(AoA_Est_Word1) + scale(total_num_errors) + (1 | targetWord)"
f <- function(pred, inter = TRUE) {
  as.formula(paste0("prop ~ scale(", pred, ")",
                    if (inter) "*scale(age_group)" else " + scale(age_group)",
                    " + scale(AoA_Est_Word1) + scale(total_num_errors) + (1 | targetWord)"))
}
fit <- function(form, dat) suppressMessages(suppressWarnings(
  lmer(form, data = dat, control = lmerControl(calc.derivs = FALSE))))

N <- 50
rows <- list()
set.seed(20260715)
for (i in 1:N) {
  sampled <- data_all %>% group_by(targetWord) %>% sample_frac(.8) %>% ungroup()
  held    <- suppressMessages(anti_join(data_all, sampled))

  # ---- text-based models (shared by both versions) ----
  m_phon <- fit(f("phon_sim"),    sampled)
  m_lang <- fit(f("sim_txt_txt"), sampled)

  # ---- image-based models: ORIGINAL ----
  m_vis_o  <- fit(f("sim_img_img"), sampled)
  m_mul_o  <- fit(f("sim_img_txt"), sampled)
  m_res_o  <- fit(f("sem_resid"),   sampled)
  m_all_o  <- fit(as.formula("prop ~ scale(sim_img_txt)*scale(age_group) + scale(sim_img_img) + scale(phon_sim) + scale(sem_resid) + scale(AoA_Est_Word1) + scale(total_num_errors) + (1 | targetWord)"), sampled)

  # ---- image-based models: ISOLATED ----
  m_vis_i  <- fit(f("iso_sim_img_img"), sampled)
  m_mul_i  <- fit(f("iso_sim_img_txt"), sampled)
  m_res_i  <- fit(f("sem_resid_iso"),   sampled)
  m_all_i  <- fit(as.formula("prop ~ scale(iso_sim_img_txt)*scale(age_group) + scale(iso_sim_img_img) + scale(phon_sim) + scale(sem_resid_iso) + scale(AoA_Est_Word1) + scale(total_num_errors) + (1 | targetWord)"), sampled)

  hp <- function(m) cor(predict(m, newdata = held), held$prop)  # held-out predictive r

  rows[[i]] <- tibble(
    iter = i,
    model = c("phonological","semantic (txt-txt)","visual (img-img)","multimodal (img-txt)","semantic residual","all predictors"),
    # R2c
    orig_R2c = c(R2c(m_phon), R2c(m_lang), R2c(m_vis_o), R2c(m_mul_o), R2c(m_res_o), R2c(m_all_o)),
    iso_R2c  = c(R2c(m_phon), R2c(m_lang), R2c(m_vis_i), R2c(m_mul_i), R2c(m_res_i), R2c(m_all_i)),
    # held-out predictive correlation
    orig_r   = c(hp(m_phon), hp(m_lang), hp(m_vis_o), hp(m_mul_o), hp(m_res_o), hp(m_all_o)),
    iso_r    = c(hp(m_phon), hp(m_lang), hp(m_vis_i), hp(m_mul_i), hp(m_res_i), hp(m_all_i)))
  cat(sprintf("iter %d/%d\n", i, N))
}
res <- bind_rows(rows)
write_csv(res, here("analysis/A5_fig4c_crossval_raw.csv"))

ci <- function(x) sprintf("%.3f [%.3f, %.3f]", mean(x), quantile(x,.025), quantile(x,.975))
summ <- res %>% group_by(model) %>%
  summarise(orig_R2c = ci(orig_R2c), iso_R2c = ci(iso_R2c),
            orig_heldout_r = ci(orig_r), iso_heldout_r = ci(iso_r)) %>%
  mutate(model = factor(model, levels = c("all predictors","multimodal (img-txt)",
    "semantic (txt-txt)","visual (img-img)","semantic residual","phonological"))) %>%
  arrange(model)

cat("\n=== Fig 4C: conditional R^2 (mean [95% CI]) over", N, "subsamples ===\n")
cat("   (semantic & phonological are text-based => identical across versions)\n\n")
print(as.data.frame(summ %>% select(model, orig_R2c, iso_R2c)), row.names = FALSE)
cat("\n=== Held-out predictive correlation (mean [95% CI]) ===\n\n")
print(as.data.frame(summ %>% select(model, orig_heldout_r, iso_heldout_r)), row.names = FALSE)
cat("\nsaved raw -> analysis/A5_fig4c_crossval_raw.csv\n")
