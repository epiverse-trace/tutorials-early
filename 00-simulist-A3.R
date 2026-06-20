library(simulist)
library(tidyverse)

## delays ------

reporting_delay <- function(n) {
  stats::rlnorm(
    n = n,
    meanlog = 1,
    sdlog = 0.5
  )
}

## simulate -----

set.seed(1)

linelist_sexdiff_pre <- simulist::sim_linelist(
  outbreak_size = c(1000, 1500),
  reporting_delay = reporting_delay, 
  config = simulist::create_config(prob_male = 0.7)
) %>% 
  tibble::as_tibble()

## write ----------

linelist_sexdiff_pre %>%
  simulist::messy_linelist(
    inconsistent_id = FALSE,
    inconsistent_dates = TRUE,
    prop_missing = 0.2,
    missing_value = cleanepi::common_na_strings
  ) %>%
  dplyr::select(-id) %>%
  tibble::rownames_to_column(var = "id") %>% 
  readr::write_csv("episodes/data/unknown_simulist_messy.csv")

linelist_sexdiff <- linelist_sexdiff_pre %>%
  # Categorize the age numerical variable
  dplyr::mutate(
    age_category = base::cut(
      x = age,
      breaks = c(0, 20, 35, 60, 100), # replace with max value if known
      include.lowest = TRUE,
      right = FALSE
    )
  )

linelist_sexdiff %>% 
  readr::write_rds("episodes/data/unknown_simulist.rds")

## for everyone -------------

linelist_sexdiff %>% glimpse()

### delay ---------------

linelist_sexdiff_d1 <- linelist_sexdiff %>% 
  cleanepi::timespan(
    target_column = "date_onset",
    end_date = "date_reporting",
    span_unit = "days",
    span_column_name = "delay_reporting"
  )

linelist_sexdiff_d2 <- linelist_sexdiff %>% 
  dplyr::mutate(delay_reporting = date_reporting - date_onset)

linelist_sexdiff_d1 %>% 
  skimr::skim(delay_reporting)

linelist_sexdiff_d1 %>% 
  ggplot(aes(delay_reporting)) +
  geom_histogram(binwidth = 1) +
  xlim(0,30)

### incidence2 -----------

incidence_sexdiff <- linelist_sexdiff %>%
  incidence2::incidence_(
    date_index = date_onset,
    interval = "month",
    groups = c(sex, age_category),
  )

### plot ----------

incidence_sexdiff %>% plot()
incidence_sexdiff %>% plot(fill = "age_category",angle = 45)
incidence_sexdiff %>% plot(fill = "sex",nrow = 1)
