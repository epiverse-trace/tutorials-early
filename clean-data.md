---
title: 'Clean case data'
teaching: 20
exercises: 10
---

:::::::::::::::::::::::::::::::::::::: questions 

- How to clean and standardize case data?
::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain how to clean, curate, and standardize case data using `{cleanepi}` package
- Perform essential data-cleaning operations to be performed in a raw case dataset.

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::: prereq

This episode requires you to:

- Download the [simulated_ebola_2.csv](https://epiverse-trace.github.io/tutorials-early/data/simulated_ebola_2.csv)
- Save it in the `data/` folder.

:::::::::::::::::::::

## Introduction
In the process of analyzing outbreak data, it's essential to ensure that the dataset is clean, curated, standardized, 
and valid to facilitate accurate and reproducible analysis.
 This episode focuses on cleaning epidemics and outbreaks data using the 
 [cleanepi](https://epiverse-trace.github.io/cleanepi/) package,
   For demonstration purposes, we'll work with a simulated dataset of Ebola cases.

Let's start by loading the package `{rio}` to read data and the package `{cleanepi}` 
to clean it. We'll use the pipe `%>%` to connect some of their functions, including others from 
the package `{dplyr}`, so let's also call to the tidyverse package:


``` r
# Load packages
library(tidyverse) # for {dplyr} functions and the pipe %>%
library(rio) # for importing data
library(here) # for easy file referencing
library(cleanepi)
```

::::::::::::::::::: checklist

### The double-colon

The double-colon `::` in R let you call a specific function from a package without loading the entire package into the 
current environment. 

For example, `dplyr::filter(data, condition)` uses `filter()` from the `{dplyr}` package.

This help us remember package functions and avoid namespace conflicts.

:::::::::::::::::::


The first step is to import the dataset into working environment, which can be done by following the guidelines 
outlined in the [Read case data](../episodes/read-cases.Rmd) episode. This involves loading 
 the dataset into `R` environment and view its structure and content. 


``` r
# Read data
# e.g.: if path to file is data/simulated_ebola_2.csv then:
raw_ebola_data <- rio::import(
  here::here("data", "simulated_ebola_2.csv")
) %>%
  dplyr::as_tibble() # for a simple data frame output
```




``` r
# Print data frame
raw_ebola_data
```

``` output
# A tibble: 15,003 × 9
      V1 `case id` age     gender status `date onset` `date sample` lab   region
   <int>     <int> <chr>   <chr>  <chr>  <chr>        <chr>         <lgl> <chr> 
 1     1     14905 90      1      "conf… 03/15/2015   06/04/2015    NA    valdr…
 2     2     13043 twenty… 2      ""     Sep /11/13   03/01/2014    NA    valdr…
 3     3     14364 54      f       <NA>  09/02/2014   03/03/2015    NA    valdr…
 4     4     14675 ninety  <NA>   ""     10/19/2014   31/ 12 /14    NA    valdr…
 5     5     12648 74      F      ""     08/06/2014   10/10/2016    NA    valdr…
 6     5     12648 74      F      ""     08/06/2014   10/10/2016    NA    valdr…
 7     6     14274 sevent… female ""     Apr /05/15   01/23/2016    NA    valdr…
 8     7     14132 sixteen male   "conf… Dec /29/Y    05/10/2015    NA    valdr…
 9     8     14715 44      f      "conf… Apr /06/Y    04/24/2016    NA    valdr…
10     9     13435 26      1      ""     09/07/2014   20/ 09 /14    NA    valdr…
# ℹ 14,993 more rows
```

::::::::::::::::: discussion

Let's **diagnose** the data frame. List all the characteristics in the data frame above that are problematic for data
 analysis.

Are any of those characteristics familiar with any previous data analysis you performed?

::::::::::::::::::::::::::::

::::::::::::::::::: instructor

Mediate a short discussion to relate the diagnosed characteristic with required cleaning operations. 

You can use these terms to **diagnose characteristics**: 

- *Codification*, like sex and age entries using numbers, letters, and words. Also dates in different arrangement 
("dd/mm/yyyy" or "yyyy/mm/dd") and formats. Less visible, but also the column names.
- *Missing*, how to interpret an entry like "" in status or "-99" in another column? do we have a data dictionary from 
the data collection process?
- *Inconsistencies*, like having a date of sample before the date of onset.
- *Non-plausible values*, like outlier observations with dates outside of an expected timeframe.
- *Duplicates*, are all observations unique?

You can use these terms to relate to **cleaning operations**:

- Standardize column name
- Standardize categorical variables like sex/gender
- Standardize date columns
- Convert from character to numeric values
- Check the sequence of dated events

::::::::::::::::::::::::::::::

##  A quick inspection

Quick exploration and inspection of the dataset are crucial before diving into any analysis tasks. The `{cleanepi}` 
package simplifies this process with the `scan_data()` function. Let's take a look at how you can use it:


``` r
cleanepi::scan_data(raw_ebola_data)
```

``` output
  Field_names missing numeric   date character logical
1         age  0.0646  0.8348 0.0000    0.1006       0
2      gender  0.1578  0.0472 0.0000    0.7950       0
3      status  0.0535  0.0000 0.0000    0.9465       0
4  date onset  0.0001  0.0000 0.9159    0.0840       0
5 date sample  0.0001  0.0000 0.9999    0.0000       0
6      region  0.0000  0.0000 0.0000    1.0000       0
```


The results provide an overview of the content of every column, including column names, and the percent of some data 
types per column.
You can see that the column names in the dataset are descriptive but lack consistency, as some they are composed of 
multiple words separated by white spaces. Additionally, some columns contain more than one data type, and there are 
missing values in others.

## Common operations

This section  demonstrate how to perform some common data cleaning operations using the `{cleanepi}` package.

### Standardizing column names

For this example dataset, standardizing column names typically involves removing spaces and connecting different words 
with “_”. This practice helps maintain consistency and readability in the dataset. However, the function used for 
standardizing column names offers more options. Type `?cleanepi::standardize_column_names` for more details.


``` r
sim_ebola_data <- cleanepi::standardize_column_names(raw_ebola_data)
names(sim_ebola_data)
```

``` output
[1] "v1"          "case_id"     "age"         "gender"      "status"     
[6] "date_onset"  "date_sample" "lab"         "region"     
```

If you want to maintain certain column names without subjecting them to the standardization process, you can utilize 
the `keep` argument of the function `cleanepi::standardize_column_names()`. This argument accepts a vector of column 
names that are intended to be kept unchanged.

::::::::::::::::::::::::::::::::::::: challenge

- What differences you can observe in the column names?

- Standardize the column names of the input dataset, but keep the first column names as it is.

::::::::::::::::: hint

You can try `cleanepi::standardize_column_names(data = raw_ebola_data, keep = "V1")`

::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::

### Removing irregularities

Raw data may contain irregularities such as **duplicated** rows, **empty** rows and columns, or **constant** columns 
(where all entries have the same value.) Functions from `{cleanepi}` like `remove_duplicates()` and `remove_constants()`
 remove such irregularities as demonstrated in the below code chunk. 


``` r
# Remove constants
sim_ebola_data <- cleanepi::remove_constants(sim_ebola_data)
```

Now, print the output to identify what constant column you removed!


``` r
# Remove duplicates
sim_ebola_data <- cleanepi::remove_duplicates(sim_ebola_data)
```

``` output
Found 5 duplicated rows in the dataset. Please consult the report for more details.
```

<!-- Note that, our simulated Ebola does not contain duplicated nor constant rows or columns.  -->

::::::::::::::::::::: spoiler

#### How many rows you removed? What rows where removed?

You can get the number and location of the duplicated rows that where found. Run `cleanepi::print_report()`, 
wait for the report to open in your browser, and find the "Duplicates" tab.


``` r
# Print a report
cleanepi::print_report(sim_ebola_data)
```

:::::::::::::::::::::

::::::::::::::::::::: challenge

In the following data frame:


``` output
# A tibble: 6 × 5
   col1  col2 col3  col4  col5  
  <dbl> <dbl> <chr> <chr> <date>
1     1     1 a     b     NA    
2     2     3 a     b     NA    
3    NA    NA a     <NA>  NA    
4    NA    NA a     <NA>  NA    
5    NA    NA a     <NA>  NA    
6    NA    NA <NA>  <NA>  NA    
```

What columns or rows are:

- duplicates?
- empty?
- constant?

::::::::::::::: hint

Duplicates mostly refers to replicated rows. Empty rows or columns can be a subset within the set of constant rows 
or columns.

:::::::::::::::

:::::::::::::::::::::

::::::::::::::: instructor

- duplicated rows: 3, 4, 5
- empty rows: 6
- empty cols: 5
- constant rows: 6
- constant cols: 5

Notice to learners that the user can create new constant columns or rows after removing some initial ones.


``` r
df %>%
  cleanepi::remove_constants()
```

``` output
Constant data was removed after 2 iterations. See the report for more details.
```

``` output
# A tibble: 2 × 2
   col1  col2
  <dbl> <dbl>
1     1     1
2     2     3
```

``` r
df %>%
  cleanepi::remove_constants() %>%
  cleanepi::remove_constants()
```

``` output
Constant data was removed after 2 iterations. See the report for more details.
```

``` output
# A tibble: 2 × 2
   col1  col2
  <dbl> <dbl>
1     1     1
2     2     3
```


:::::::::::::::


### Replacing missing values

In addition to the regularities, raw data can contain missing values that may be encoded by different strings, 
including the empty. To ensure robust analysis, it is a good practice to replace all missing values by `NA` in the 
entire dataset. Below is a code snippet demonstrating how you can achieve this in `{cleanepi}`:


``` r
sim_ebola_data <- cleanepi::replace_missing_values(
  data = sim_ebola_data,
  na_strings = ""
)

sim_ebola_data
```

``` output
# A tibble: 15,000 × 8
      v1 case_id age         gender status    date_onset date_sample row_id
   <int>   <int> <chr>       <chr>  <chr>     <chr>      <chr>        <int>
 1     1   14905 90          1      confirmed 03/15/2015 06/04/2015       1
 2     2   13043 twenty-five 2      <NA>      Sep /11/13 03/01/2014       2
 3     3   14364 54          f      <NA>      09/02/2014 03/03/2015       3
 4     4   14675 ninety      <NA>   <NA>      10/19/2014 31/ 12 /14       4
 5     5   12648 74          F      <NA>      08/06/2014 10/10/2016       5
 6     6   14274 seventy-six female <NA>      Apr /05/15 01/23/2016       7
 7     7   14132 sixteen     male   confirmed Dec /29/Y  05/10/2015       8
 8     8   14715 44          f      confirmed Apr /06/Y  04/24/2016       9
 9     9   13435 26          1      <NA>      09/07/2014 20/ 09 /14      10
10    10   14816 thirty      f      <NA>      06/29/2015 06/02/2015      11
# ℹ 14,990 more rows
```

<!-- idea: after solving issue with multiple na_string, add a challenge about it + add them to the raw data set! -->

### Validating subject IDs

Each entry in the dataset represents a subject and should be distinguishable by a specific column formatted in a 
particular way, such as falling within a specified range, containing certain prefixes and/or suffixes, containing a 
specific number of characters. The `{cleanepi}` package offers the function `check_subject_ids()` designed precisely 
for this task as shown in the below code chunk. This function validates whether they are unique and meet the required 
criteria.



``` r
sim_ebola_data <-
  cleanepi::check_subject_ids(
    data = sim_ebola_data,
    target_columns = "case_id",
    range = c(0, 15000)
  )
```

``` output
Found 1957 duplicated rows in the subject IDs. Please consult the report for more details.
```

Note that our simulated  dataset does contain duplicated subject IDS.

::::::::::::::::: spoiler

#### How to correct the subject IDs?

Let's print a preliminary report with `cleanepi::print_report(sim_ebola_data)`. Focus on the "Unexpected subject ids" 
tab to identify what IDs require an extra treatment. 

After finishing this tutorial, we invite you to explore the package reference guide of `{cleanepi}` to find the 
function that can fix this situation.

:::::::::::::::::::::::::

### Standardizing dates

Certainly, an epidemic dataset contains date columns for different events, such as the date of infection, 
date of symptoms onset, etc. These dates can come in different date formats, and it is good practice to standardize them.
 The `{cleanepi}` package provides functionality for converting date columns of epidemic datasets into ISO format, 
 ensuring consistency across the different date columns. Here's how you can use it on our simulated dataset:


``` r
sim_ebola_data <- cleanepi::standardize_dates(
  sim_ebola_data,
  target_columns = c(
    "date_onset",
    "date_sample"
  )
)

sim_ebola_data
```

``` output
# A tibble: 15,000 × 8
      v1 case_id age         gender status    date_onset date_sample row_id
   <int> <chr>   <chr>       <chr>  <chr>     <date>     <date>       <int>
 1     1 14905   90          1      confirmed 2015-03-15 2015-06-04       1
 2     2 13043   twenty-five 2      <NA>      2013-09-11 2014-03-01       2
 3     3 14364   54          f      <NA>      2014-09-02 2015-03-03       3
 4     4 14675   ninety      <NA>   <NA>      2014-10-19 2031-12-14       4
 5     5 12648   74          F      <NA>      2014-08-06 2016-10-10       5
 6     6 14274   seventy-six female <NA>      2015-04-05 2016-01-23       7
 7     7 14132   sixteen     male   confirmed NA         2015-05-10       8
 8     8 14715   44          f      confirmed NA         2016-04-24       9
 9     9 13435   26          1      <NA>      2014-09-07 2020-09-14      10
10    10 14816   thirty      f      <NA>      2015-06-29 2015-06-02      11
# ℹ 14,990 more rows
```

This function converts the values in the target columns, or will automatically figure out the date columns within 
the dataset (if `target_columns = NULL`) and convert them into the **Ymd**  format.

::::::::::::::::::: discussion

#### How is this possible?

We invite you to find the key package that works internally by reading the Details section of the 
[Standardize date variables reference manual](https://epiverse-trace.github.io/cleanepi/reference/standardize_dates.html#details)!

:::::::::::::::::::

### Converting to numeric values

In the raw dataset, some column can come with mixture of character and numerical values, and you want to convert the 
character values explicitly into numeric. For example, in our simulated data set, in the age column some entries are 
written in words. In `{cleanepi}` the function `convert_to_numeric()` does such conversion as illustrated in the below 
code chunk.

``` r
sim_ebola_data <- cleanepi::convert_to_numeric(sim_ebola_data,
  target_columns = "age"
)

sim_ebola_data
```

``` output
# A tibble: 15,000 × 8
      v1 case_id   age gender status    date_onset date_sample row_id
   <int> <chr>   <dbl> <chr>  <chr>     <date>     <date>       <int>
 1     1 14905      90 1      confirmed 2015-03-15 2015-06-04       1
 2     2 13043      25 2      <NA>      2013-09-11 2014-03-01       2
 3     3 14364      54 f      <NA>      2014-09-02 2015-03-03       3
 4     4 14675      90 <NA>   <NA>      2014-10-19 2031-12-14       4
 5     5 12648      74 F      <NA>      2014-08-06 2016-10-10       5
 6     6 14274      76 female <NA>      2015-04-05 2016-01-23       7
 7     7 14132      16 male   confirmed NA         2015-05-10       8
 8     8 14715      44 f      confirmed NA         2016-04-24       9
 9     9 13435      26 1      <NA>      2014-09-07 2020-09-14      10
10    10 14816      30 f      <NA>      2015-06-29 2015-06-02      11
# ℹ 14,990 more rows
```

::::::::::::::::: callout

### Multiple language support

Thanks to the `{numberize}` package, we can convert numbers written as English, French or Spanish words to positive 
integer values!

:::::::::::::::::::::::::

## Epidemiology related operations

In addition to common data cleansing tasks, such as those discussed in the above section, the `{cleanepi}` package offers 
additional functionalities tailored specifically for processing and analyzing outbreak and epidemic data. This section 
covers some of these specialized tasks.

### Checking sequence of dated-events

Ensuring the correct order and sequence of dated events is crucial in epidemiological data analysis, especially 
when analyzing infectious diseases where the timing of events like symptom onset and sample collection is essential. 
The `{cleanepi}` package provides a helpful function called `check_date_sequence()` precisely for this purpose.

Here's an example code chunk demonstrating the usage of the function `check_date_sequence()` in our simulated Ebola dataset


``` r
sim_ebola_data <- cleanepi::check_date_sequence(
  data = sim_ebola_data,
  target_columns = c("date_onset", "date_sample")
)
```

This functionality is crucial for ensuring data integrity and accuracy in epidemiological analyses, as it helps identify 
any inconsistencies or errors in the chronological order of events, allowing you to address them appropriately.

::::::::::::::::: spoiler

#### What are the incorrect date sequences?

Let's print another preliminary report with `cleanepi::print_report(sim_ebola_data)`. Focus on the 
"Incorrect date sequence" tab to identify what IDs had this issue. 

:::::::::::::::::::::::::


### Dictionary-based substitution

In the realm of data pre-processing, it's common to encounter scenarios where certain columns in a dataset, 
such as the “gender” column in our simulated Ebola dataset, are expected to have specific values or factors. 
However, it's also common for unexpected or erroneous values to appear in these columns, which need to be replaced with
appropriate values. The `{cleanepi}` package offers support for dictionary-based substitution, a method that allows you 
to replace values in specific columns based on mappings defined in a dictionary. 
This approach ensures consistency and accuracy in data cleaning.

Moreover, `{cleanepi}` provides a built-in dictionary specifically tailored for epidemiological data. The example 
dictionary below includes mappings for the “gender” column.


``` r
test_dict <- base::readRDS(
  system.file("extdata", "test_dict.RDS", package = "cleanepi")
) %>%
  dplyr::as_tibble() # for a simple data frame output

test_dict
```

``` output
# A tibble: 6 × 4
  options values grp    orders
  <chr>   <chr>  <chr>   <int>
1 1       male   gender      1
2 2       female gender      2
3 M       male   gender      3
4 F       female gender      4
5 m       male   gender      5
6 f       female gender      6
```

Now, we can use this dictionary to standardize values of the the “gender” column according to predefined categories. 
Below is an example code chunk demonstrating how to utilize this functionality:


``` r
sim_ebola_data <- cleanepi::clean_using_dictionary(
  sim_ebola_data,
  dictionary = test_dict
)

sim_ebola_data
```

``` output
# A tibble: 15,000 × 8
      v1 case_id   age gender status    date_onset date_sample row_id
   <int> <chr>   <dbl> <chr>  <chr>     <date>     <date>       <int>
 1     1 14905      90 male   confirmed 2015-03-15 2015-06-04       1
 2     2 13043      25 female <NA>      2013-09-11 2014-03-01       2
 3     3 14364      54 female <NA>      2014-09-02 2015-03-03       3
 4     4 14675      90 <NA>   <NA>      2014-10-19 2031-12-14       4
 5     5 12648      74 female <NA>      2014-08-06 2016-10-10       5
 6     6 14274      76 female <NA>      2015-04-05 2016-01-23       7
 7     7 14132      16 male   confirmed NA         2015-05-10       8
 8     8 14715      44 female confirmed NA         2016-04-24       9
 9     9 13435      26 male   <NA>      2014-09-07 2020-09-14      10
10    10 14816      30 female <NA>      2015-06-29 2015-06-02      11
# ℹ 14,990 more rows
```

This approach simplifies the data cleaning process, ensuring that categorical data in epidemiological datasets is 
accurately categorized and ready for further analysis.


:::::::::::::::::::::::::: spoiler

#### How to create your own data dictionary?

Note that, when the column in the dataset contains values that are not in the dictionary, the function 
`cleanepi::clean_using_dictionary()` will raise an error. 

You can start a custom dictionary with a data frame inside or outside R. You can use the function 
`cleanepi::add_to_dictionary()` to include new elements in the dictionary. For example:


``` r
new_dictionary <- tibble::tibble(
  options = "0",
  values = "female",
  grp = "sex",
  orders = 1L
) %>%
  cleanepi::add_to_dictionary(
    option = "1",
    value = "male",
    grp = "sex",
    order = NULL
  )

new_dictionary
```

``` output
# A tibble: 2 × 4
  options values grp   orders
  <chr>   <chr>  <chr>  <int>
1 0       female sex        1
2 1       male   sex        2
```

You can read more details in the section about "Dictionary-based data substituting" in the package 
["Get started" vignette](https://epiverse-trace.github.io/cleanepi/articles/cleanepi.html#dictionary-based-data-substituting).

::::::::::::::::::::::::::


### Calculating time span between different date events

In epidemiological data analysis, it is also useful to track and analyze time-dependent events, such as the progression 
of a disease outbreak (i.e., the time difference between today and the first case reported) or the duration between 
sample collection and analysis (i.e., the time difference between today and the sample collection). The most common 
example is to calculate the age of all the subjects given their date of birth (i.e., the time difference between today 
and the date of birth).

The `{cleanepi}` package offers a convenient function for calculating the time elapsed between two dated events at 
different time scales. For example, the below code snippet utilizes the function `cleanepi::timespan()` to compute the 
time elapsed since the date of sample for the case identified
 until the date this document was generated (2025-03-04).
 

``` r
sim_ebola_data <- cleanepi::timespan(
  sim_ebola_data,
  target_column = "date_sample",
  end_date = Sys.Date(),
  span_unit = "years",
  span_column_name = "years_since_collection",
  span_remainder_unit = "months"
)

sim_ebola_data %>%
  dplyr::select(case_id, date_sample, years_since_collection, remainder_months)
```

``` output
# A tibble: 15,000 × 4
   case_id date_sample years_since_collection remainder_months
   <chr>   <date>                       <dbl>            <dbl>
 1 14905   2015-06-04                       9                8
 2 13043   2014-03-01                      11                0
 3 14364   2015-03-03                      10                0
 4 14675   2031-12-14                      -6               -9
 5 12648   2016-10-10                       8                4
 6 14274   2016-01-23                       9                1
 7 14132   2015-05-10                       9                9
 8 14715   2016-04-24                       8               10
 9 13435   2020-09-14                       4                5
10 14816   2015-06-02                       9                9
# ℹ 14,990 more rows
```

After executing the function `cleanepi::timespan()`, two new columns named `years_since_collection` and 
`remainder_months` are added to the **sim_ebola_data** dataset, containing the calculated time elapsed since the date 
of sample collection for each case, measured in years, and the remaining time measured in months.

::::::::::::::::::::::::::::::::::::::::::::::: challenge

Age data is useful in any downstream analysis. You can categorize it to generate stratified estimates.

Read the `test_df.RDS` data frame within the `{cleanepi}` package:


``` r
dat <- readRDS(
  file = system.file("extdata", "test_df.RDS", package = "cleanepi")
) %>%
  dplyr::as_tibble()
```

Calculate the age in years of the subjects with date of birth, and the remainder time un months. Clean and standardize the required elements to get this done.

:::::::::::::::::::::::::::: hint

Before calculating the age, you may need to:

- standardize column names 
- standardize dates columns
- replace missing as strings to a valid missing entry

::::::::::::::::::::::::::::

:::::::::::::::::::::::::: solution

In the solution we add `date_first_pcr_positive_test` given that it will provide the temporal scale for descriptive and statistical downstream analysis of the disease outbreak.


``` r
dat_clean <- dat %>%
  # standardize column names and dates
  cleanepi::standardize_column_names() %>%
  cleanepi::standardize_dates(
    target_columns = c("date_of_birth", "date_first_pcr_positive_test")
  ) %>%
  # replace from strings to a valid missing entry
  cleanepi::replace_missing_values(
    target_columns = "sex",
    na_strings = "-99"
  ) %>%
  # calculate the age in 'years' and return the remainder in 'months'
  cleanepi::timespan(
    target_column = "date_of_birth",
    end_date = Sys.Date(),
    span_unit = "years",
    span_column_name = "age_in_years",
    span_remainder_unit = "months"
  )
```

Now, How would you categorize a numerical variable?

::::::::::::::::::::::::::

:::::::::::::::::::::::::: solution

The simplest alternative is using `Hmisc::cut2()`. You can also use `dplyr::case_when()` however, this requires more lines of code and is more appropriate for custom categorizations. Here we provide one solution using `base::cut()`:


``` r
dat_clean %>%
  # select to conveniently view timespan output
  dplyr::select(
    study_id,
    sex,
    date_first_pcr_positive_test,
    date_of_birth,
    age_in_years
  ) %>%
  # categorize the age numerical variable [add as a challenge hint]
  dplyr::mutate(
    age_category = base::cut(
      x = age_in_years,
      breaks = c(0, 20, 35, 60, Inf), # replace with max value if known
      include.lowest = TRUE,
      right = FALSE
    )
  )
```

``` output
# A tibble: 10 × 6
   study_id   sex date_first_pcr_posit…¹ date_of_birth age_in_years age_category
   <chr>    <int> <date>                 <date>               <dbl> <fct>       
 1 PS001P2      1 2020-12-01             1972-06-01              52 [35,60)     
 2 PS002P2      1 2021-01-01             1952-02-20              73 [60,Inf]    
 3 PS004P2…    NA 2021-02-11             1961-06-15              63 [60,Inf]    
 4 PS003P2      1 2021-02-01             1947-11-11              77 [60,Inf]    
 5 P0005P2      2 2021-02-16             2000-09-26              24 [20,35)     
 6 PS006P2      2 2021-05-02             NA                      NA <NA>        
 7 PB500P2      1 2021-02-19             1989-11-03              35 [35,60)     
 8 PS008P2      2 2021-09-20             1976-10-05              48 [35,60)     
 9 PS010P2      1 2021-02-26             1991-09-23              33 [20,35)     
10 PS011P2      2 2021-03-03             1991-02-08              34 [20,35)     
# ℹ abbreviated name: ¹​date_first_pcr_positive_test
```

You can investigate the maximum values of variables using `skimr::skim()`. Instead of `base::cut()` you can also use 
`Hmisc::cut2(x = age_in_years,cuts = c(20,35,60))`, which gives calculate the maximum value and do not require more 
arguments. 

::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::

## Multiple operations at once

Performing data cleaning operations individually can be time-consuming and error-prone. The `{cleanepi}` package 
simplifies this process by offering a convenient wrapper function called `clean_data()`, which allows you to perform 
multiple operations at once.

The `clean_data()` function applies a series of predefined data cleaning operations to the input dataset. Here's an 
example code chunk illustrating how to use `clean_data()` on a raw simulated Ebola dataset:


Further more, you can combine multiple data cleaning tasks via the pipe operator in "%>%", as shown in the below code 
snippet. 


``` r
# Perfom the cleaning operations using the pipe (%>%) operator
cleaned_data <- raw_ebola_data %>%
  cleanepi::standardize_column_names() %>%
  cleanepi::remove_constants() %>%
  cleanepi::remove_duplicates() %>%
  cleanepi::replace_missing_values(na_strings = "") %>%
  cleanepi::check_subject_ids(
    target_columns = "case_id",
    range = c(1, 15000)
  ) %>%
  cleanepi::standardize_dates(
    target_columns = c("date_onset", "date_sample")
  ) %>%
  cleanepi::convert_to_numeric(target_columns = "age") %>%
  cleanepi::check_date_sequence(
    target_columns = c("date_onset", "date_sample")
  ) %>%
  cleanepi::clean_using_dictionary(dictionary = test_dict) %>%
  cleanepi::timespan(
    target_column = "date_sample",
    end_date = Sys.Date(),
    span_unit = "years",
    span_column_name = "years_since_collection",
    span_remainder_unit = "months"
  )
```




## Cleaning report

The `{cleanepi}` package generates a comprehensive report detailing the findings and actions of all data cleansing 
operations conducted during the analysis. This report is presented as a webpage with multiple sections. Each section 
corresponds to a specific data cleansing operation, and clicking on each section allows you to access the results of 
that particular operation. This interactive approach enables users to efficiently review and analyze the outcomes of 
individual cleansing steps within the broader data cleansing process.

You can view the report using the function `cleanepi::print_report(cleaned_data)`. 
<p><figure>
    <img src="fig/report_demo.png"
         alt="Data cleaning report" 
         width="600"/> 
    <figcaption>
            <p>Example of data cleaning report generated by `{cleanepi}`</p>
    </figcaption>
</figure>



::::::::::::::::::::::::::::::::::::: keypoints 

- Use `{cleanepi}` package to clean and standardize epidemic and outbreak data
- Understand how to use `{cleanepi}` to perform common data cleansing tasks and epidemiology related operations
- View the data cleaning report in a browser, consult it and make decisions. 

:::::::::::::::::::::::::::::::::::::


