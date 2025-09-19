# Load required packages
install.packages("readxl")
install.packages("dplyr")
library(readxl)
library(dplyr)

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

# Read the Excel file
dwa_data <- read_excel(raw_file("DWA Reference.xlsx"))

# Extract distinct DWA ID–Title pairs
dwa_list <- dwa_data %>%
  select(`DWA ID`, `DWA Title`) %>%
  distinct()

# Add empty FSHC_Rating column
dwa_list$FSHC_Rating <- NA  # Placeholder for GenAI rating

# Save to CSV
write.csv(dwa_list, proc_file("DWA_for_FSHC_rating.csv"), row.names = FALSE)

# Prompt Generation
# Define the base prompt
base_prompt <- "===PROMPT_START===

Firm-specific human capital (FSHC) refers to the knowledge, skills, and abilities that employees acquire through work experience and training in a particular firm which enhance productivity primarily within that particular firm and have limited or no value in external labor markets, whether in the same industry or not. FSHC arises from investments, often jointly made by both employer and employee, in tasks, routines, systems, or relationships that are unique to a firm’s operations. It is characterized by low transferability, contributes to sustained competitive advantage when valuable and hard to imitate, and requires effective retention strategies to ensure that source firms appropriate the value it generates.
We are interested in assessing the potential for a worker to develop FSHC in a particular job/occupation. To do so, we have identified a list of activities, per occupation, from O*NET that underlie the tasks performed in these occupations.

Rate the following job activity from 1 to 5 based on how much firm-specific human capital (FSHC) it is likely to require. Use this scale:

1 – Fully General: Universally transferable; no firm customization.
2 – Mostly General: Standard activity with minor firm-specific elements.
3 – Moderately Firm-Specific: Requires knowledge of firm-specific systems or routines.
4 – Mostly Firm-Specific: Deeply embedded in the firm’s internal logic or workflows.
5 – Fully Firm-Specific: Entirely tailored to the firm’s systems, strategy, or client relationships.

Activity: \"<DWA Title>\"

Respond only with the number 1, 2, 3, 4, or 5.
"
# Insert DWA title into each prompt
dwa_list$Prompt <- mapply(
  function(title) gsub("<DWA Title>", title, base_prompt, fixed = TRUE),
  dwa_list$`DWA Title`
)
# Export to a text file (one prompt per line)
writeLines(dwa_list$Prompt, proc_file("FSHC_prompts_with_titles.txt"))
