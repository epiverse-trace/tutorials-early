
# description -------------------------------------------------------------

#' aim: bind rOpenSci and Epiverse-TRACE glossaries
#'
#' notes:
#'
#' We need to check for duplicates.
#' We opted to use dplyr::duplicate() to keep the first entry.
#' This currently gives priority to rOpenSci over Epiverse-TRACE terms

# set up ------------------------------------------------------------------

library(tidyverse)
library(babeldown)

Sys.setenv("DEEPL_API_URL" = "https://api.deepl.com")
# first time user
# 1. create a Free Api account
# 2. copy the API key and paste it as a password in:
# keyring::key_set("deepl")
Sys.setenv(DEEPL_API_KEY = keyring::key_get("deepl"))

# read and bind files -----------------------------------------------------

# rOpenSci glossary
# https://translationguide.ropensci.org/es/specific_guidelines.es.html#glosario-es
filename <- "https://raw.githubusercontent.com/ropensci-review-tools/glossary/refs/heads/master/glossary.csv"

epiverse_trace_glossary <-
  googlesheets4::read_sheet(
    ss = "https://docs.google.com/spreadsheets/d/16adappC6r9UFCmQoEeCEwQwe5uxT6UJxBP7woRMGwJ4/edit?usp=sharing") %>%
  # group_by(english) %>%
  # filter(n()>1)
  distinct()

# file contents for info
readr::read_csv(filename, show_col_types = FALSE) %>%
  bind_rows(epiverse_trace_glossary) %>%
  # group_by(english) %>%
  # filter(n()>1)
  distinct() %>%
  readr::write_csv("locale/es/mixed_glossary.csv")

# use babeldown -----------------------------------------------------------

mixed_glossary <- here::here("locale/es/mixed_glossary.csv")

# create (or update) glossary
babeldown::deepl_upsert_glossary(
  mixed_glossary,
  glossary_name = "rstats-glosario",
  target_lang = "spanish",
  source_lang = "english"
)

babeldown::deepl_translate(
  path = "episodes/read-cases.Rmd",
  out_path = "locale/es/read-cases.Rmd",
  source_lang = "EN",
  target_lang = "ES",
  formality = "less",
  glossary = "rstats-glosario"
)
