

library(tidyverse)

# Load all metadata we'll need for the items
test_corpus <- read_csv(here::here("data/item_metadata/test_items.csv")) %>%
  filter(!Word1 %in% c('honey','scrabble')) # manually excluded after piloting


# Load clip correlations
item_meta_data <- read_csv(here::here("data/raw/exp1_all_trials2023-04-11.csv")) %>%
  select(Word1, Word2, trial_type, AoA_Est_Word2, AoA_Est_Word1) %>%
  rename(wordPairing = trial_type, targetWord = Word1, answerWord = Word2) %>%
  filter(targetWord %in% unique(test_corpus$Word1))  %>%
  ungroup() %>%
  mutate(AoA_Bin = ntile(AoA_Est_Word1,3)) %>%
  mutate(AoA_Bin_Name = factor(AoA_Bin,  levels = c('1','2','3'), labels = c("Easy Words", "Harder Words", "Difficult Words"))) 





# Join with metadata about the text/image/multimodal simialrities
item_meta_and_model_sim = read_csv(file=here::here('data/item_metadata/vv_clip_similarities.csv')) %>%
  rename(targetWord = target, answerWord = image)  %>%
  filter(answerWord != targetWord)  %>%
  right_join(item_meta_data)


write_csv(item_meta_and_model_sim, file=here::here('data/item_metadata/item_meta_and_model_sim.csv'))
