---
title: Solutions using epikinetics data and package
---

# Statistical analysis

```r

#' goal:
#' model the kinetics of neutralising-antibody titres after antigenic SARS-CoV-2 exposure?

# load packages -----------------------------------------------------------

library(tidyverse)
library(cleanepi)
library(datatagr) # a generalization of {linelist}
# library(epikinetics)

# read data ---------------------------------------------------------------

# rawdata <- "data-raw/delta.csv"
rawdata <- "https://raw.githubusercontent.com/seroanalytics/epikinetics/refs/heads/main/inst/delta_full.rds"

dat <- read_csv(rawdata)

dat %>% glimpse()

# what these columns mean? ------------------------------------------------

#' data dictionary: https://seroanalytics.org/epikinetics/articles/data.html
#' reference paper: https://www.thelancet.com/journals/laninf/article/PIIS1473-3099(24)00484-5/fulltext
#' location: https://github.com/seroanalytics/epikinetics/tree/main/inst

# 335 subjects where followed up
dat %>% count(pid)

## what "titre type" means? -------------------------------------------------

#' In the time series, 
#' each subject had monthly serum measurements 
#' for three types of antigens ("titre_type").
#' 
#' Serum samples where challenged against Ancestral, Alpha and Delta antigens.
#' 
#' The column "value" measures the titre of 
#' the neutralizing effect of each sample against each antigen 

dat %>%
  dplyr::filter(pid == 2) %>% 
  dplyr::arrange(date) %>% 
  # select time invariant columns
  dplyr::select(
    pid, infection_history, exp_num, last_exp_date, last_vax_type,
    dplyr::everything()
  )

## what "censored" means? ----------------------------------------------------

# context: censored regression model
# the "value" as the outcome is censored above or below
# because the it was measured outside the limits of detection
# threshold limit below: 5
# threshold limit above: 2560

dat %>% 
  ggplot(aes(value, fill = as.factor(censored))) + 
  geom_histogram()

# datatagr ----------------------------------------------------------------

datatagr::lost_labels_action()
datatagr::get_lost_labels_action()
# datatagr::lost_labels_action(action = "error")

# cleanepi ----------------------------------------------------------------

# check sequence of events

dat_clean <- dat %>% 
  # arrange columns
  dplyr::select(
    pid, infection_history, exp_num, last_exp_date, last_vax_type,
    dplyr::everything()
  ) %>% 
  # arrange rows
  dplyr::arrange(
    pid, infection_history, exp_num, last_exp_date, last_vax_type, date
  ) %>% 
  # cleanepi
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
    # censored = forcats::as_factor(censored) # in {epikinetics} censored needs to be numeric
  ) %>% 
  # tag with {datatagr}
  datatagr::make_datatagr(
    pid = "subject id",
    infection_history = "subject infection history",
    exp_num = "number of vaccine exposures",
    last_exp_date = "date of last exposure",
    last_vax_type = "type of vaccine in the last exposure",
    date = "date of observation of titre in serum sample",
    titre_type = "type of antigen challenged against serum sample",
    value = "titre value",
    censored = "censored titre value out of limit of detection [5 - 2560] bellow (-1) or above (+1)",
    t_since_last_exp = "time interval between last vaccine exposure and observed serum sample titre"
  ) %>% 
  # validate with {datatagr}
  datatagr::validate_datatagr(
    pid = "numeric",
    infection_history = "character",
    exp_num = "factor",
    last_exp_date="Date",
    last_vax_type = "factor",
    date = "Date",
    titre_type = "factor",
    value = "numeric",
    censored = "numeric",
    t_since_last_exp = "numeric"
  ) %>% 
  # datatagr::labels_df() %>% # this extract labels as column names [affects downstream] 
  identity()

dat_clean


# visualization: data to model --------------------------------------------

dat_clean %>% 
  mutate(log2_value = log2(value)) %>% 
  filter(censored == "0") %>% 
  # skimr::skim(log2_value)
  ggplot(aes(x = t_since_last_exp, y = value)) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(trans = "log2") +
  facet_wrap(~infection_history+titre_type) +
  xlim(0,150)


# model -------------------------------------------------------------------

#' In this vignette we use a dataset representing the Delta wave 
#' which is installed with this package, 
#' specifying a regression model that 
#' just looks at the effect of infection history.
#' 
#' Figure 2 from the paper shows population level fits for each wave, 
#' disaggregated by infection history and titre type. 
#' Here we reproduce the facets for the Delta wave. 
#' Once the model has been fitted, 
#' simulate population trajectories using the fitted population parameters.

dat_clean %>% class()

mod <- epikinetics::biokinetics$new(
  data = dat_clean %>% data.table::as.data.table(), 
  covariate_formula = ~0 + infection_history
)

# WAIT this takes 14 minutes
# tictoc::tic()
delta <- mod$fit(
  parallel_chains = 4,
  iter_warmup = 50,
  iter_sampling = 200,
  threads_per_chain = 4
)
# tictoc::toc()

# this takes 10 seconds
# tictoc::tic()
res <- mod$simulate_population_trajectories()
head(res)
# tictoc::toc()

# visualize output --------------------------------------------------------

plot_data <- res

plot_data[, titre_type := forcats::fct_relevel(
  titre_type,
  c("Ancestral", "Alpha", "Delta"))]

ggplot(data = plot_data) +
  geom_line(aes(x = t,
                y = me,
                colour = titre_type)) +
  geom_ribbon(aes(x = t,
                  ymin = lo,
                  ymax = hi,
                  fill = titre_type), alpha = 0.65) +
  scale_y_continuous(trans = "log2") +
  labs(x = "Time since last exposure (days)",
       y = expression(paste("Titre (IC"[50], ")"))) +
  facet_wrap(infection_history ~ titre_type)
```

