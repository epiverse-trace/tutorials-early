---
title: Descriptive analysis with epikinetics data
---

# Descriptive analysis

```r

#' goal:
#' vaccination incidence stratified by vaccine type
#' observation incidence stratified by censoring status

# load packages -----------------------------------------------------------

library(tidyverse)
library(cleanepi)
library(datatagr) # a generalization of {linelist}
library(incidence2)

# read data ---------------------------------------------------------------

# rawdata <- "data-raw/delta.csv"
# rawdata <- "https://raw.githubusercontent.com/seroanalytics/epikinetics/refs/heads/main/inst/delta_full.rds"
rawdata <- "data-out/delta_full-messy.csv" # fix this path

dat <- read_csv(rawdata)

dat #%>% glimpse()

# dat %>% 
#   # arrange columns
#   dplyr::select(
#     pid, infection_history, exp_num, last_exp_date, last_vax_type,
#     dplyr::everything()
#   ) %>% 
#   # arrange rows
#   dplyr::arrange(
#     pid, infection_history, exp_num, last_exp_date, last_vax_type, date
#   ) %>% 
#   write_csv("data-out/delta_full-messy.csv")

# datatagr 

# datatagr::lost_labels_action()
# datatagr::get_lost_labels_action()
# # datatagr::lost_labels_action(action = "error")

# cleanepi ----------------------------------------------------------------

# check sequence of events

dat_clean <- dat %>% 
  # cleanepi
  cleanepi::standardize_column_names() %>% 
  cleanepi::standardize_dates(target_columns = "date") %>%
  cleanepi::convert_to_numeric(target_columns = "exp_num") %>% 
  cleanepi::check_date_sequence(
    target_columns = c("last_exp_date", "date")
  ) %>% 
  # cleanepi::print_report()
  cleanepi::timespan(
    target_column = "last_exp_date",
    end_date = "date",
    span_unit = "days",
    span_column_name = "t_since_last_exp",
    span_remainder_unit = "days"
    ) %>% 
  # extra wrangling
  mutate(
    last_vax_type = forcats::fct_infreq(last_vax_type),
    exp_num = forcats::as_factor(exp_num),
    titre_type = forcats::fct_relevel(titre_type,"Ancestral", "Alpha"),
    censored = forcats::as_factor(censored)
  ) %>% 
  # tag with {linelist}
  linelist::make_linelist( # ISSUE: make_linelist can rearrange columns
    id = "pid",
    allow_extra = TRUE,
    infection_history = "infection_history",
    exp_num = "exp_num",
    last_exp_date = "last_exp_date",
    last_vax_type = "last_vax_type",
    date = "date",
    titre_type = "titre_type",
    value = "value",
    censored = "censored",
    # last_vax_type = "last_vax_type", # ISSUE: can tolerate replicates
    t_since_last_exp = "t_since_last_exp" # it is possible to pass validation without tagging?
  ) %>% 
  # validate 
  linelist::validate_linelist(
    allow_extra = TRUE,
    ref_types = linelist::tags_types(
      infection_history = c("character"),
      exp_num = c("factor"),
      last_exp_date = c("Date"),
      last_vax_type = c("factor"),
      date = c("Date"),
      titre_type = c("factor"),
      value = c("numeric"),
      censored = c("factor"),
      t_since_last_exp = c("numeric"),
      allow_extra = TRUE
    )
  ) %>% 
  # keep tags data frame
  linelist::tags_df()

dat_clean

# distribution of the time from the last vaccine to first observation
dat_clean %>% 
  group_by(id) %>% 
  filter(date == min(date)) %>% 
  slice(1) %>% 
  ungroup() %>% 
  ggplot(aes(t_since_last_exp)) + 
  geom_histogram()

# what these columns mean? ------------------------------------------------

#' data dictionary: https://seroanalytics.org/epikinetics/articles/data.html
#' reference paper: https://www.thelancet.com/journals/laninf/article/PIIS1473-3099(24)00484-5/fulltext
#' location: https://github.com/seroanalytics/epikinetics/tree/main/inst

# 335 subjects where followed up
dat_clean %>% count(pid)


## what "titre type" means? -------------------------------------------------

#' In the time series, 
#' each subject had monthly serum measurements 
#' for three types of antigens ("titre_type").
#' 
#' Serum samples where challenged against Ancestral, Alpha and Delta antigens.
#' 
#' The column "value" measures the titre of 
#' the neutralizing effect of each sample against each antigen 

dat_clean %>%
  dplyr::filter(id == 2) %>% 
  dplyr::arrange(date) #%>% 
  # # select time invariant columns
  # dplyr::select(
  #   id, infection_history, exp_num, last_exp_date, last_vax_type,
  #   dplyr::everything()
  # )

## what "censored" means? ----------------------------------------------------

# context: censored regression model
# the "value" as the outcome is censored above or below
# because the it was measured outside the limits of detection
# threshold limit below: 5
# threshold limit above: 2560

dat_clean %>% 
  ggplot(aes(value, fill = as.factor(censored))) + 
  geom_histogram()


## subject table -----------------------------------------------------------

# subject time-invariant data
dat_subject <- dat_clean %>% 
  # {datatagr} reacts with dplyr::select() but not with dplyr::count() when losing tags
  dplyr::select(id, infection_history, exp_num, last_exp_date, last_vax_type) %>% 
  dplyr::count(id, infection_history, exp_num, last_exp_date, last_vax_type)
  
# table 1: time-invariant columns
dat_subject %>% 
  compareGroups::compareGroups(
    data = .,
    formula = ~infection_history + exp_num + last_exp_date + last_vax_type 
  ) %>% 
  compareGroups::createTable()

# table 2: were vaccine type differently applied between naive and non-naive?
dat_subject %>% 
  compareGroups::compareGroups(
    data = .,
    formula = last_vax_type~infection_history,
    byrow = TRUE
  ) %>% 
  compareGroups::createTable(show.all = TRUE)

# vaccinations ------------------------------------------------------------

## by vaccine type ---------------------------------------------

dat_subject %>% 
  # aggregate
  incidence2::incidence(
    date_index = "last_exp_date", # change: "date" or "last_exp_date"
    groups = ("last_vax_type"), # change: "titre_type" or "infection_history" or "last_vax_type" or c("infection_history", "titre_type")
    interval = "month", # change: "day" or "week" or "epiweek" or "month"
    # complete_dates = TRUE, # relevant to downstream analysis [time-series data]
  ) %>% 
  # transform to cumulative per group (optional display)
  # incidence2::cumulate() %>% 
  # plot
  incidence2:::plot.incidence2(
    fill = "last_vax_type" # change: "infection_history", "titre_type", or "last_vax_type"
  )

# observations ------------------------------------------------------------

# by history-variants
# not required, this reflect the proportion of "infection_history" in the cohort

## by censored -----------------------------------------------

dat_clean %>% count(censored)

dat_clean %>% 
  incidence2::incidence(
    date_index = "date", # change: "date" or "last_exp_date"
    groups = "censored", # change: "censored" or "titre_type" or "infection_history" or "last_vax_type" or c("infection_history", "titre_type")
    interval = "month", # change: "day", "week", "month"
    # complete_dates = TRUE # relevant to downstream analysis [time-series data]
  ) %>% 
  incidence2:::plot.incidence2(
    fill = "censored" # change: "censored" or "infection_history", "titre_type", or "last_vax_type"
  )

```
