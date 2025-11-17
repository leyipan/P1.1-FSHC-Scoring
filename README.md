# FSHC-Scoring

Code for ongoing project on firm-specific human capital measurement using O*NET occupational data and Large Language Models (LLMs). Results preliminary.

## Overview

This project measures Firm-Specific Human Capital (FSHC) across occupations by analyzing O*NET task descriptions and other occupational characteristics. The methodology leverages LLMs to evaluate the degree of firm-specificity in occupational tasks, providing a quantitative measure of how transferable skills and knowledge are across different employers.

## Project Structure

```
P1.1-FSHC-Scoring/
├── data/
│   ├── Raw/              # Original O*NET and related datasets
│   └── Processed/        # Cleaned and transformed data files
├── notebooks/            # Jupyter/R Markdown notebooks for exploration and analysis
├── output/               # Generated results, figures, and tables
└── src/
    ├── Python/
    │   └── API interaction scripts for sending prompts to LLMs
    └── R/
        ├── Data cleaning scripts
        ├── Prompt generation utilities
        ├── Score extraction and processing
        └── Principal Component Analysis (PCA)
```
