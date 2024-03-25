---
title: 'Describe cases'
teaching: 1
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 
- How to convert case data to incidence? 
- How to visualize incidence cases?
- What is the person, place, time distribution of cases?
- What is the growth rate of the epidemic?
<<<<<<< HEAD
- How do you visualize incidence cases?
- what is the growth rate of the epidemic?
- what is the person, place, time distribution of cases?
- what are the epidemiological characteristics of the infection?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives
- Convert case data to incidence 
- Convert case data to incidence data
- Create incidence curves
- Estimate the growth rate from incidence curves
- Create quick descriptive and comparison tables

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction
A comprehensive description of data is pivotal for conducting insightful explanatory and exploratory analyses. This episode focuses describing and visualizing epidemic data, with a particular focus on a **Covid-19 case data from England**, which comes with the [outbreaks](http://www.reconverse.org/outbreaks/) package. The initial step involves reading this dataset, and we recommend utilizing the [readr](../links.md#readr) package for this purpose (or employing alternative methods as outlined in the [Read case data](../episodes/read-cases.Rmd)).


```r
requireNamespace("outbreaks")
covid19_eng_case_data <- outbreaks::covid19_england_nhscalls_2020
utils::head(covid19_eng_case_data, 5)
```

```{.output}
  site_type       date    sex     age  ccg_code
1       111 2020-03-18 female missing e38000062
2       111 2020-03-18 female missing e38000163
3       111 2020-03-18 female    0-18 e38000001
4       111 2020-03-18 female    0-18 e38000002
5       111 2020-03-18 female    0-18 e38000004
                                ccg_name count postcode
1                nhs_gloucestershire_ccg     1   gl34fe
2                 nhs_south_tyneside_ccg     1  ne325nn
3 nhs_airedale_wharfedale_and_craven_ccg     8   bd57jr
4                        nhs_ashford_ccg     7  tn254ab
5           nhs_barking_and_dagenham_ccg    35   rm13ae
                nhs_region day      weekday
1               South West   0 rest_of_week
2 North East and Yorkshire   0 rest_of_week
3 North East and Yorkshire   0 rest_of_week
4               South East   0 rest_of_week
5                   London   0 rest_of_week
```
## Incidence cases

Downstream analysis involves working with aggregated data rather than individual cases. The  [incidence2]((https://www.reconverse.org/incidence2/articles/incidence2.html){.external target="_blank"}) package offers essential functions for grouping case data, usually centered around dated occurrences and/or other factors.  The code chunk provided below demonstrates the creation of an `incidence2` object from the `covid19_eng_case_data` based on the  date of sample.


```r
requireNamespace("incidence2")
requireNamespace("ggplot2")
covid19_eng_incidence_data <- incidence2::incidence(covid19_eng_case_data,
                                                    date_index = "date")
utils::head(covid19_eng_incidence_data, 5)
```

```{.output}
# incidence:  5 x 3
# count vars: date
  date_index count_variable count
* <date>     <chr>          <int>
1 2020-03-18 date            2579
2 2020-03-19 date            2602
3 2020-03-20 date            2615
4 2020-03-21 date            2588
5 2020-03-22 date            2603
```

The `incidence2` object can be visualized using the plot function of base R package. 

```r
base::plot(covid19_eng_incidence_data) + labs(x = "Date", y = " Cases") +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust = 1))
```

```{.error}
Error in labs(x = "Date", y = " Cases"): could not find function "labs"
```

Moreover, `Incidence2` can also aggregate case data based on a dated event and other factors such as  what is the person and place. For example the code chunk groups weekly counts of Covid-19 cases in England based on  `sex` type.


```r
weekly_covid19_eng_incidence <- incidence2::incidence(covid19_eng_case_data,
                                                      date_index = "date",
                                                      interval = "week",
                                                      groups = "sex")
base::plot(weekly_covid19_eng_incidence) + labs(x = "Date", y = "Cases") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
```

```{.error}
Error in labs(x = "Date", y = "Cases"): could not find function "labs"
```


::::::::::::::::::::::::::::::::::::: challenge 

- Using the above `covid91_eng_case_data`  dataset, produce monthly epi-curves for Covid-19 cases in England based on  regional places in England?

::::::::::::::::::::::::::::::::::::::::::::::::

#### Analyzing the trend in case data

Aggregated case data over a specific time unit, or incidence data, typically represent the number of cases occurring within that time frame. These data can often be assumed to follow either a Poisson distribution or a negative binomial distribution, depending on the specific characteristics of the data and the underlying processes generating them.

When analyzing such data, one common approach is to examine the trend over time by computing the rate of change, which can indicate whether there is exponential growth or decay in the number of cases. Exponential growth implies that the number of cases is increasing at an accelerating rate over time, while exponential decay suggests that the number of cases is decreasing at a decelerating rate.

Understanding the trend in case data is crucial for various purposes, such as forecasting future case counts, implementing public health interventions, and assessing the effectiveness of control measures. By analyzing the trend, policymakers and public health experts can make informed decisions to mitigate the spread of diseases and protect public health.

The `i2extras` package provides methods for modelling the trend in case data, calculating moving averages, and exponential growth or decay rate. The code chunk below computes the Covid-19 trend in UK within first 3 months using negative binomial distribution. 


```r
requireNamespace("i2extras")
# This line loads the i2extras package, which  provides methods for modeling
# trends in case data.
df <- base::subset(covid19_eng_case_data,
                   covid19_eng_case_data$date <= min(covid19_eng_case_data$date)
                   + 90)
# This code subset the covid19_eng_case_data to include only the first 3 months
# of data.
df_incid <- incidence2::incidence(df, date_index = "date", groups = "sex")
# This line uses the incidence function from the incidence2 package to
# compute the incidence data. It groups the data by sex.
out <- i2extras::fit_curve(df_incid, model  = "negbin", alpha = 0.05)
# Here, the fit_curve function from i2extras is used to fit a curve to the
# incidence data. The model chosen is the negative binomial distribution with a
# significance level (alpha) of 0.05.
base::plot(out, angle = 45) + ggplot2::labs(x = "Date", y = "Cases")
```

<img src="fig/describe-cases-rendered-unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

```r
# This code plots the results using the plot function.
#This line uses the incidence function from the incidence2 package to compute the
#incidence data. It groups the data by sex.
fitted_curve <- i2extras::fit_curve(df_incid, model  = "negbin", alpha = 0.05)
# Here, the fit_curve function from i2extras is used to fit a curve to the incidence data.
# The model chosen is the negative binomial distribution with a significance level (alpha) of 0.05.
base::plot(fitted_curve, angle = 45)+ ggplot2::labs(x = "Date", y ="Cases")
```

<img src="fig/describe-cases-rendered-unnamed-chunk-5-2.png" style="display: block; margin: auto;" />
The rate of exponential growth or decay can be extracted from the fitted curve via `growth_rate` function.


```r
library("tidyverse")
rates <- i2extras::growth_rate(fitted_curve)
rates <- base::as.data.frame(rates)
rates %>%select(sex, r, r_lower, r_upper )
```

```{.output}
      sex            r      r_lower      r_upper
1  female -0.008241228 -0.009182635 -0.007300403
2    male -0.008346783 -0.009316775 -0.007377392
3 unknown -0.023703987 -0.028179436 -0.019299926
```

::::::::::::::::::::::::::::::::::::: challenge 

- What is the trend of cases in the above example, is it increasing or decreasing?
- Using  `covid91_eng_case_data`  dataset, model and visualize the trend of  Covid-19 in England in the first six months cases via Poisson distribution?
- Determine the exponential growth or decay rate?

::::::::::::::::::::::::::::::::::::::::::::::::

A moving average, which shows the trend of cases in specified time period, also can be calculate using the `add_rolling_average` function in `i2extras` package, as illustrated in the below code chunk.


```r
moving_Avg <- i2extras::add_rolling_average(df_incid, n = 7L)
base::plot(moving_Avg, border_colour = "white", angle = 45) +
    ggplot2::geom_line(aes(x = date_index, y = rolling_average, color="red"))+
    ggplot2::labs(x = "Date", y= "Cases")
```

<img src="fig/describe-cases-rendered-unnamed-chunk-7-1.png" style="display: block; margin: auto;" />

::::::::::::::::::::::::::::::::::::: challenge 

- Calculate and visualize monthly moving average of Covid-19 cases in England?

::::::::::::::::::::::::::::::::::::::::::::::::

Aggregated case data over a specific time unit, or incidence data, typically represent the number of cases occurring within that time frame. These data can often be assumed to follow either a Poisson distribution or a negative binomial distribution, depending on the specific characteristics of the data and the underlying processes generating them.

When analyzing such data, one common approach is to examine the trend over time by computing the rate of change, which can indicate whether there is exponential growth or decay in the number of cases. Exponential growth implies that the number of cases is increasing at an accelerating rate over time, while exponential decay suggests that the number of cases is decreasing at a decelerating rate.

Understanding the trend in case data is crucial for various purposes, such as forecasting future case counts, implementing public health interventions, and assessing the effectiveness of control measures. By analyzing the trend, policymakers and public health experts can make informed decisions to mitigate the spread of diseases and protect public health.


The `i2extras` package provides methods for modelling the trend in case data, calculating moving averages, and exponential growth or decay rate. The code chunk below computes the Covid-19 trend in UK within first 3 months using negative binomial distribution. 



```r
requireNamespace("i2extras")
# This line loads the i2extras package, which provides methods for modeling
# trends in case data.
df <- base::subset(covid19_eng_case_data,
                   covid19_eng_case_data$date <= min(covid19_eng_case_data$date)
                   + 90)
# This code subset the covid19_eng_case_data to include only the first
# 3 months of data.
df_incid <- incidence2::incidence(df, date_index = "date", groups = "sex")
# This line uses the incidence function from the incidence2 package
# to compute the incidence data. It groups the data by sex.
fitted_curve <- i2extras::fit_curve(df_incid, model  = "negbin", alpha = 0.05)
# Here, the fit_curve function from i2extras is used to fit a curve to the
# incidence data. The model chosen is the negative binomial distribution with
# a significance level (alpha) of 0.05.
base::plot(fitted_curve, angle = 45) + ggplot2::labs(x = "Date", y = "Cases")
```

<img src="fig/describe-cases-rendered-unnamed-chunk-8-1.png" style="display: block; margin: auto;" />

### Exponential growth or decay rate

The rate of exponential growth or decay can be extracted from the fitted curve via `growth_rate` function.


```r
library("tidyverse")
rates <- i2extras::growth_rate(fitted_curve)
rates <- base::as.data.frame(rates)
rates %>% select(sex, r, r_lower, r_upper)
```

```{.output}
      sex            r      r_lower      r_upper
1  female -0.008241228 -0.009182635 -0.007300403
2    male -0.008346783 -0.009316775 -0.007377392
3 unknown -0.023703987 -0.028179436 -0.019299926
```

### Peak time
Peak time--the date which the highest number of cases observed-- can be estimeated using the `estimate_peak` function

```r
peaks <- i2extras::estimate_peak((df_incid), progress = FALSE)
peaks %>% select(-c(count_variable, bootstrap_peaks))
```

```{.output}
# A data frame: 3 × 6
  sex     observed_peak observed_count lower_ci   median     upper_ci  
  <chr>   <date>                 <int> <date>     <date>     <date>    
1 female  2020-03-26              1314 2020-03-18 2020-03-22 2020-03-30
2 male    2020-03-27              1299 2020-03-18 2020-03-25 2020-03-30
3 unknown 2020-04-10                32 2020-03-24 2020-04-10 2020-04-20
```

### Moving average

A moving average, which shows the trend of cases in specified time period, also can be calculate using the `add_rolling_average` function in `i2extras` package, as illustrated in the below code chunk.


```r
moving_Avg <- i2extras::add_rolling_average(df_incid, n = 7L)
base::plot(moving_Avg, border_colour = "white", angle = 45) +
  ggplot2::geom_line(aes(x = date_index, y = rolling_average, color = "red")) +
  ggplot2::labs(x = "Date", y = "Cases")
```

<img src="fig/describe-cases-rendered-unnamed-chunk-11-1.png" style="display: block; margin: auto;" />

::::::::::::::::::::::::::::::::::::: challenge 

- What is the trend of cases in the above example, is it increasing or decreasing?
- Using  `covid91_eng_case_data` dataset for the first six months cases perform the following:
  - model and visualize the epi cure via Poisson distribution?
  - Determine the exponential growth or decay rate?
  - Estimate peak time?
  - Calculate and visualize monthly moving average?
- Use `{incidence2}` to aggregate case data based on a date event.  
- Use `{i2extras}` to fit epi curve,  calculate exponential growth or decline of cases, estimate pick size and peak time, and computing moving average of cases in specified time window.
- Use `{compareGroups}`

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: keypoints 

- Use `{incidence2}` to aggregate case data based on a date event.  
- Use `{i2extras}` to fit epi curve,  calculate exponential growth or decline of cases, find peak time, and computing moving average of cases in specified time window.
::::::::::::::::::::::::::::::::::::::::::::::::

