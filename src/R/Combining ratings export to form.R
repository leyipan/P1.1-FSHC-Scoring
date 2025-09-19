# Load required packages
getwd()
install.packages("readr")
install.packages("dplyr")
library(readr)
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

# Read in the CSV files
dwa_ratings <- read_csv(proc_file("dwa_ratings.csv"))
dwa_fshc <- read_csv(proc_file("DWA_for_FSHC_rating.csv"))

# Replace the FSHC_Rating column with the ratings column (rows 1:2087)
dwa_fshc$FSHC_Rating[1:2087] <- dwa_ratings$ratings[1:2087]

# Write the updated data frame back to CSV
write_csv(dwa_fshc, out_file("DWA_for_FSHC_rating_updated.csv"))
