

library(tidyverse)

# Load all metadata we'll need for the items
test_corpus <- read_csv(here::here("data/item_metadata/test_items.csv")) %>%
  filter(!Word1 %in% c('honey','scrabble')) # manually excluded after piloting

# load things dataset for item 1
things_meta_word_1 <- read_tsv(here::here("data/item_metadata/things_concepts.tsv")) %>%
  filter(Word %in% c(test_corpus$Word1)) %>%
  mutate(log_freq_target_word = log1p(`SUBTLEX freq`)) %>%
  mutate(concreteness_target_word = `Concreteness (M)`) %>%
  mutate(superordinate_category_target_word = `Top-down Category (manual selection)`) %>%
  select(Word, log_freq_target_word, superordinate_category_target_word, concreteness_target_word)

things_meta_word_2 <- read_tsv(here::here("data/item_metadata/things_concepts.tsv")) %>%
  filter(Word %in% c(test_corpus$Word2)) %>%
  mutate(log_freq_answer_word = log1p(`SUBTLEX freq`)) %>%
  mutate(concreteness_answer_word = `Concreteness (M)`) %>%
  mutate(superordinate_category_answer_word = `Top-down Category (manual selection)`) %>%
  select(Word, log_freq_answer_word,superordinate_category_answer_word, concreteness_answer_word)


# load things typicality for item 1
things_typ_word_1 <- read_tsv(here::here("data/item_metadata/things_typicality.tsv")) %>%
  filter(Word %in% c(test_corpus$Word1)) %>%
  group_by(Word) %>%
  summarize(mean_typicality = mean(typicality_score))

things_typ_word_2 <- read_tsv(here::here("data/item_metadata/things_typicality.tsv")) %>%
  filter(Word %in% c(test_corpus$Word2)) %>%
  group_by(Word) %>%
  summarize(mean_typicality = mean(typicality_score))


# Load clip correlations
item_meta_data <- read_csv(here::here("data/raw/exp1_all_trials2023-04-11.csv")) %>%
  select(Word1, Word2, trial_type, AoA_Est_Word2, AoA_Est_Word1) %>%
  rename(wordPairing = trial_type, targetWord = Word1, answerWord = Word2) %>%
  filter(targetWord %in% unique(test_corpus$Word1))  %>%
  ungroup() %>%
  mutate(AoA_Bin = ntile(AoA_Est_Word1,3)) %>%
  mutate(AoA_Bin_Name = factor(AoA_Bin,  levels = c('1','2','3'), labels = c("Easy Words", "Harder Words", "Difficult Words"))) 



# load item data about phonological similarity
phonological_sim = read_csv(file=here::here('data/item_metadata/phon_sim.csv')) %>%
  rename(targetWord = target, answerWord = word)  %>%
  filter(answerWord != targetWord)  %>%
  select(targetWord, answerWord, phon_sim) %>% 
  filter(targetWord %in% test_corpus$Word1) %>%
  filter(answerWord %in% test_corpus$Word2) 


# Join with metadata about the text/image/multimodal simialrities
item_meta_and_model_sim = read_csv(file=here::here('data/item_metadata/vv_clip_similarities.csv')) %>%
  rename(targetWord = target, answerWord = image)  %>%
  filter(answerWord != targetWord)  %>%
  right_join(item_meta_data) %>%
  left_join(phonological_sim) %>%
  left_join(things_meta_word_1, by=c('targetWord'='Word')) %>%
  left_join(things_meta_word_2, by=c('answerWord'='Word'))  %>%
  left_join(things_typ_word_1, by=c('targetWord'='Word')) 
  
# should match the number of trials * 3 distractors
assert_that(length(item_meta_and_model_sim$targetWord)==108*3)

write_csv(item_meta_and_model_sim, file=here::here('data/item_metadata/item_meta_and_model_sim.csv'))
