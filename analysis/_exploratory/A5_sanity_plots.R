#!/usr/bin/env Rscript
# Exploratory sanity-check plots for the segmentation pipeline.
suppressPackageStartupMessages({
  library(tidyverse); library(ggthemes); library(here)
})

OUT <- here("analysis/A5_figs"); dir.create(OUT, showWarnings = FALSE)

# CVD-safe categorical pair (blue = segmented, orange = kept original/failed)
col_seg  <- "#3897bc"; col_fail <- "#e4ab24"
pal_fail <- c("segmented (rembg)" = col_seg, "kept original (failed)" = col_fail)

# ---------- data ----------
self <- read_csv(here("analysis/A5_image_self_similarity.csv"), show_col_types = FALSE) %>%
  mutate(method_lab = if_else(failed, "kept original (failed)", "segmented (rembg)"),
         coverage = as.numeric(coverage))

fb <- self %>% filter(failed) %>% pull(word)   # 27 fallback words

# both original & isolated computed by ONE identical pipeline (no fp16/fp32 confound)
pairs <- read_csv(here("data/item_metadata/vv_clip_sims_orig_vs_iso.csv"), show_col_types = FALSE) %>%
  rename(sim_img_img = orig_img_img, iso_sim_img_img = iso_img_img,
         sim_img_txt = orig_img_txt, iso_sim_img_txt = iso_img_txt) %>%
  filter(sim_img_img < 0.999) %>%                       # drop target-vs-self identity rows
  mutate(distractor_kept = answerWord %in% fb,
         both_kept = (answerWord %in% fb) & (targetWord %in% fb))

th <- theme_few(base_size = 12) +
  theme(legend.position = "top", legend.title = element_blank(),
        panel.grid.major = element_line(color = "grey92"))

# ---------- Plot 1: per-image self-similarity by method (THE headline check) ----------
set.seed(1)
p1 <- ggplot(self, aes(method_lab, self_sim, color = method_lab)) +
  geom_hline(yintercept = 1, linetype = 2, color = "grey60") +
  geom_jitter(width = .18, height = 0, alpha = .5, size = 1.4) +
  stat_summary(fun = median, geom = "crossbar", width = .45,
               color = "grey20", fatten = 1.4) +
  scale_color_manual(values = pal_fail, guide = "none") +
  labs(x = NULL, y = "CLIP cosine( original , isolated )",
       title = "Per-image embedding change from segmentation",
       subtitle = "All 27 failed items sit exactly at 1.0 (image unchanged); segmented items move down") +
  th
ggsave(file.path(OUT, "01_self_similarity_by_method.png"), p1, width = 7, height = 5, dpi = 150)

# ---------- Plot 2: self-similarity vs coverage ----------
p2 <- ggplot(self, aes(coverage, self_sim, color = method_lab)) +
  geom_point(alpha = .6, size = 1.5) +
  scale_color_manual(values = pal_fail) +
  labs(x = "foreground coverage (from isolation log)",
       y = "CLIP cosine( original , isolated )",
       title = "More background removed -> larger embedding change",
       subtitle = "Failed items have coverage ~1.0 (nothing removed) and self-sim = 1.0") +
  th
ggsave(file.path(OUT, "02_selfsim_vs_coverage.png"), p2, width = 7, height = 5, dpi = 150)

# ---------- Plot 3: before/after multimodal (img->txt), distractor-image driven ----------
r_it <- cor(pairs$sim_img_txt, pairs$iso_sim_img_txt)
p3 <- ggplot(pairs, aes(sim_img_txt, iso_sim_img_txt,
                        color = distractor_kept)) +
  geom_abline(slope = 1, intercept = 0, linetype = 2, color = "grey60") +
  geom_point(alpha = .6, size = 1.5) +
  scale_color_manual(values = c(`FALSE` = col_seg, `TRUE` = col_fail),
                     labels = c("distractor segmented","distractor kept original"),
                     name = NULL) +
  coord_equal() +
  labs(x = "original  (word - distractor image)", y = "isolated",
       title = "Multimodal similarity: before vs after",
       subtitle = sprintf("r = %.3f; failed-distractor pairs (orange) on identity line", r_it)) +
  th
ggsave(file.path(OUT, "03_beforeafter_multimodal.png"), p3, width = 6, height = 6.4, dpi = 150)

# ---------- Plot 4: before/after visual (img-img) ----------
r_ii <- cor(pairs$sim_img_img, pairs$iso_sim_img_img)
p4 <- ggplot(pairs, aes(sim_img_img, iso_sim_img_img, color = both_kept)) +
  geom_abline(slope = 1, intercept = 0, linetype = 2, color = "grey60") +
  geom_point(alpha = .6, size = 1.5) +
  scale_color_manual(values = c(`FALSE` = col_seg, `TRUE` = col_fail),
                     labels = c("=1 image segmented","both images kept original"),
                     name = NULL) +
  coord_equal() +
  labs(x = "original  (distractor image - target image)", y = "isolated",
       title = "Visual similarity: before vs after",
       subtitle = sprintf("r = %.3f; isolated > original (shared white bg inflates it)", r_ii)) +
  th
ggsave(file.path(OUT, "04_beforeafter_visual.png"), p4, width = 6, height = 6.4, dpi = 150)

# ---------- residual check: unchanged pairs must have ~0 before-after difference ----------
cat("=== residual sanity (|before - after|) ===\n")
pairs %>% summarise(
  img_txt_distractor_kept_maxabs = max(abs(sim_img_txt - iso_sim_img_txt)[distractor_kept]),
  img_txt_segmented_meanabs      = mean(abs(sim_img_txt - iso_sim_img_txt)[!distractor_kept]),
  img_img_both_kept_maxabs       = ifelse(any(both_kept), max(abs(sim_img_img - iso_sim_img_img)[both_kept]), NA),
  img_img_segmented_meanabs      = mean(abs(sim_img_img - iso_sim_img_img)[!both_kept]),
  n_distractor_kept = sum(distractor_kept), n_both_kept = sum(both_kept)
) %>% as.data.frame() %>% print()

cat("\nsaved 4 PNGs to analysis/A5_figs/\n")
