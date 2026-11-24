## age-strutured population

library(simulist)
library(epiparameter)
library(tidyverse)

### delays ----------

contact_distribution <- epiparameter(
  disease = "COVID-19",
  epi_name = "contact distribution",
  prob_distribution = create_prob_distribution(
    prob_distribution = "pois",
    prob_distribution_params = c(mean = 2)
  )
)

infectious_period <- epiparameter(
  disease = "COVID-19",
  epi_name = "infectious period",
  prob_distribution = create_prob_distribution(
    prob_distribution = "gamma",
    prob_distribution_params = c(shape = 1, scale = 1)
  )
)

# get onset to hospital admission from {epiparameter} database
onset_to_hosp <- epiparameter_db(
  disease = "COVID-19",
  epi_name = "onset to hospitalisation",
  single_epiparameter = TRUE
)

# get onset to death from {epiparameter} database
onset_to_death <- epiparameter_db(
  disease = "COVID-19",
  epi_name = "onset to death",
  single_epiparameter = TRUE
)

reporting_delay <- function(n) {
  stats::rlnorm(
    n = n,
    meanlog = 1.5,
    sdlog = 0.5
  )
}

### structure ---------

age_struct <- data.frame(
  age_limit = c(1, 10, 30, 60, 75),
  proportion = c(0.4, 0.3, 0.2, 0.1, 0)
)
age_struct

### simulate --------

set.seed(1)

linelist_agestructure_pre <- sim_linelist(
  contact_distribution = contact_distribution,
  infectious_period = infectious_period,
  prob_infection = 0.45,
  onset_to_hosp = onset_to_hosp,
  onset_to_death = onset_to_death,
  reporting_delay = reporting_delay,
  population_age = age_struct,
  outbreak_size = c(100, 1e4)
) %>% 
  tibble::as_tibble()

## write ----------

linelist_agestructure_pre %>%
  simulist::messy_linelist(
    inconsistent_id = FALSE,
    inconsistent_dates = TRUE,
    prop_missing = 0.2,
    missing_value = cleanepi::common_na_strings
  ) %>%
  dplyr::select(-id) %>%
  tibble::rownames_to_column(var = "id") %>% 
  readr::write_csv("episodes/data/covid_simulist_messy.csv")

linelist_agestructure <- linelist_agestructure_pre %>%
  # Categorize the age numerical variable
  dplyr::mutate(
    age_category = base::cut(
      x = age,
      breaks = c(0, 20, 35, 60, 100), # replace with max value if known
      include.lowest = TRUE,
      right = FALSE
    )
  )

linelist_agestructure %>% 
  readr::write_rds("episodes/data/covid_simulist.rds")

## for everyone -------------

linelist_agestructure %>% glimpse()

### delay ---------------

linelist_agestructure_d1 <- linelist_agestructure %>% 
  cleanepi::timespan(
    target_column = "date_onset",
    end_date = "date_reporting",
    span_unit = "days",
    span_column_name = "delay_reporting"
  )

linelist_agestructure_d2 <- linelist_agestructure %>% 
  dplyr::mutate(delay_reporting = date_reporting - date_onset)

linelist_agestructure_d1 %>% 
  skimr::skim(delay_reporting)

linelist_agestructure_d1 %>% 
  ggplot(aes(delay_reporting)) +
  geom_histogram(binwidth = 1) +
  xlim(0,30)

### incidence2 -----------

incidence_agestructure <- linelist_agestructure %>% 
  incidence2::incidence_(
    date_index = c(date_onset,date_outcome),
    #groups = sex,
    groups = age_category,
    interval = "day"
  )

### plot ----------

incidence_agestructure %>% plot()
incidence_agestructure %>% plot(fill = "age_category")

