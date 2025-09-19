# libs
library(dplyr)
library(tidyr)
library(stringr)
library(readxl)
library(janitor)

# Set file paths
if (!requireNamespace("here", quietly = TRUE)) install.packages("here")
library(here)
# For raw inputs
raw_file <- function(filename) {
  here("data", "raw", filename)
}

# For processed data
proc_file <- function(filename) {
  here("data", "processed", filename)
}

# For output files
out_file <- function(filename) {
  here("output", filename)
}

# -----------------------------
# Inputs
# -----------------------------
tasks <- read_excel(raw_file("Task Ratings.xlsx")) %>%
  clean_names()

# 0) Prepare FT, RT, IM
category <- read_excel(raw_file("Task Categories.xlsx")) %>%
  clean_names()

## check if any task id is linked to multiple occupations
tasks %>%
  group_by(task_id) %>%
  summarize(n_occ = n_distinct(o_net_soc_code)) %>%
  filter(n_occ != 1)  

# Filter FT rows and compute
ft <- tasks %>%
  filter(scale_id == "FT") %>%   # keep Frequency-of-Task rows
  mutate(category = as.numeric(category),
         data_value = as.numeric(data_value)) %>%
  group_by(task_id) %>%
  summarize(
    # If percentages don’t sum to exactly 100 (rounding), use the actual sum in the denominator.
    pct_sum = sum(data_value, na.rm = TRUE),
    FT_score = ifelse(pct_sum > 0,
                      sum(category * data_value, na.rm = TRUE) / pct_sum,
                      NA_real_),
    .groups = "drop"
  )
# FT_score is on the 1–7 scale (expected category)

# RT rows are typically 0–100
rt <- tasks %>%
  filter(scale_id == "RT") %>%
  group_by(task_id) %>%
  summarize(RT_score = mean(as.numeric(data_value), na.rm = TRUE), .groups = "drop")

# IM rows are typically a single 1–5 mean rating per Task_ID
im <- tasks %>%
  filter(scale_id == "IM") %>%
  group_by(task_id) %>%
  summarize(IM_score = mean(as.numeric(data_value), na.rm = TRUE), .groups = "drop")

# Merge to a single task-level table
task_table <- ft %>%
  left_join(rt, by = "task_id") %>%
  left_join(im, by = "task_id")



# -----------------------------
# 1) Prepare PCA matrix
# -----------------------------
pca_vars <- task_table %>%
  select(task_id, FT_score, RT_score) %>%
  # keep only complete cases for PCA fit
  filter(!is.na(FT_score), !is.na(RT_score))

X <- pca_vars %>% select(FT_score, RT_score)

# -----------------------------
# 2) PCA on standardized FT & RT
# -----------------------------
pca_fit <- prcomp(X, center = TRUE, scale. = TRUE)  # PCA on correlation matrix

# Inspect
summary(pca_fit)        # variance explained
pca_fit$rotation[, 1]   # loadings for PC1 on FT and RT

# -----------------------------
# 3) Extract PC1 task scores
# -----------------------------
pc_scores <- tibble(task_id = pca_vars$task_id,
                    PC1 = pca_fit$x[,1])

# Ensure higher FT/RT → higher weight (flip sign if necessary)
c1 <- cor(pc_scores$PC1, pca_vars$FT_score)
c2 <- cor(pc_scores$PC1, pca_vars$RT_score)
if (isTRUE(c1 < 0) || isTRUE(c2 < 0)) {
  pc_scores$PC1 <- -pc_scores$PC1
}

# Normalize to [0,1]
rng <- range(pc_scores$PC1, na.rm = TRUE)
task_weights <- pc_scores %>%
  mutate(TaskWeight01 = (PC1 - rng[1]) / (rng[2] - rng[1]))

# Output
write.csv(task_weights, proc_file("task_weights.csv"))


