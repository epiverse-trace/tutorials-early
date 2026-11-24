library(simulist)
library(epiparameter)
library(tidyverse)

## delays ----

contact_distribution <- epiparameter(
  disease = "Ebola",
  epi_name = "contact distribution",
  prob_distribution = create_prob_distribution(
    prob_distribution = "pois",
    prob_distribution_params = c(mean = 4)
  )
)

infectious_period <- epiparameter(
  disease = "Ebola",
  epi_name = "infectious period",
  prob_distribution = create_prob_distribution(
    prob_distribution = "gamma",
    prob_distribution_params = c(shape = 2.3, scale = 3.5)
  )
)

onset_to_hosp <- epiparameter(
  disease = "Ebola",
  epi_name = "onset to hospitalisation",
  prob_distribution = create_prob_distribution(
    prob_distribution = "gamma",
    prob_distribution_params = c(shape = 1.2103668, scale = 1/0.1709325)
  )
)

# get onset to death from {epiparameter} database
onset_to_death <- epiparameter_db(
  disease = "Ebola",
  epi_name = "onset to death",
  single_epiparameter = TRUE
)

hosp_to_death <- epiparameter_db(
  disease = "Ebola",
  epi_name = "hospitalisation to death",
  single_epiparameter = TRUE
)

onset_to_recovery <- epiparameter_db(
  disease = "Ebola",
  epi_name = "onset to discharge",
  single_epiparameter = TRUE
)

reporting_delay <- function(n) {
  stats::rlnorm(
    n = n,
    meanlog = 2,
    sdlog = 0.5
  )
}

### structure ---------

age_struct <- data.frame(
  age_limit = c(1, 25, 60, 75),
  proportion = c(0.6, 0.2, 0.1, 0.1)
)
age_struct


## death-risk -----

age_dep_hosp_death_risk <- data.frame(
  age_limit = c(1, 35, 60),
  risk = c(0, 0, 0.9)
)
age_dep_hosp_death_risk

## simulate -----

set.seed(1)

linelist_deathriskstr_pre <- sim_linelist(
  contact_distribution = contact_distribution,
  infectious_period = infectious_period,
  prob_infection = 0.5,
  # onset_to_hosp = onset_to_hosp,
  onset_to_death = onset_to_death,
  onset_to_recovery = onset_to_recovery,
  reporting_delay = reporting_delay,
  hosp_death_risk = age_dep_hosp_death_risk,
  population_age = age_struct,
  outbreak_size = c(100,300)
) %>% 
  tibble::as_tibble()

## write ----------

linelist_deathriskstr_pre %>%
  simulist::messy_linelist(
    inconsistent_id = FALSE,
    inconsistent_dates = TRUE,
    prop_missing = 0.2,
    missing_value = cleanepi::common_na_strings
  ) %>%
  dplyr::select(-id) %>%
  tibble::rownames_to_column(var = "id") %>% 
  readr::write_csv("episodes/data/ebola_simulist_messy.csv")

linelist_deathriskstr <- linelist_deathriskstr_pre %>%
  # Categorize the age numerical variable
  dplyr::mutate(
    age_category = base::cut(
      x = age,
      breaks = c(0, 20, 35, 60, 100), # replace with max value if known
      include.lowest = TRUE,
      right = FALSE
    )
  )

linelist_deathriskstr %>% 
  readr::write_rds("episodes/data/ebola_simulist.rds")

## for everyone -------------



linelist_deathriskstr %>% glimpse()

### delay ---------------

linelist_deathriskstr_d1 <- linelist_deathriskstr %>% 
  cleanepi::timespan(
    target_column = "date_onset",
    end_date = "date_reporting",
    span_unit = "days",
    span_column_name = "delay_reporting"
  )

linelist_deathriskstr_d2 <- linelist_deathriskstr %>% 
  dplyr::mutate(delay_reporting = date_reporting - date_onset)

linelist_deathriskstr_d1 %>% 
  skimr::skim(delay_reporting)

linelist_deathriskstr_d1 %>% 
  ggplot(aes(delay_reporting)) +
  geom_histogram(binwidth = 1) +
  xlim(0,30)

### incidence2 -----------

incidence_deathriskstr <- linelist_deathriskstr %>% 
  incidence2::incidence_(
    date_index = c(date_onset, date_outcome),
    #groups = sex,
    groups = c(age_category),
    interval = "day"
  )

### plot ----------

incidence_deathriskstr %>% plot()
incidence_deathriskstr %>% plot(fill = "age_category")
