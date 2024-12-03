---
title: 'Validate case data'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- How to convert raw dataset into a `linelist` object?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Demonstrate how to covert case data to `linelist` data 
- Demonstrate how to validate data

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::: prereq

This episode requires you to:

- Download the [cleaned_data.csv](https://epiverse-trace.github.io/tutorials-early/data/cleaned_data.csv)
- Save it in the `data/` folder.

:::::::::::::::::::::

## Introduction

In outbreak analysis, once you have completed the initial steps of reading and cleaning the case data,
it's essential to establish an additional foundation layer to ensure the integrity and reliability of subsequent
analyses. Specifically, this involves verifying the presence and correct data type of certain  columns within
your dataset, a process commonly referred to as "tagging." Additionally. it's crucial to implement measures to 
validate that these tagged columns are not inadvertently deleted during further data processing steps.


This episode focuses tagging and validate outbreak data using the [linelist](https://epiverse-trace.github.io/linelist/)
 package. Let's start by loading the package `{rio}` to read data and the package `{linelist}` 
to create a linelist. We'll use the pipe `%>%` to connect some of their functions, including others from 
the package `{dplyr}`, so let's also call to the tidyverse package:


``` r
# Load packages
library(tidyverse) # for {dplyr} functions and the pipe %>%
library(rio) # for importing data
library(here) # for easy file referencing
library(linelist) # for taggin and validating
```

::::::::::::::::::: checklist

### The double-colon

The double-colon `::` in R let you call a specific function from a package without loading the entire package into the 
current environment. 

For example, `dplyr::filter(data, condition)` uses `filter()` from the `{dplyr}` package.

This help us remember package functions and avoid namespace conflicts.

:::::::::::::::::::



Import the dataset following the guidelines outlined in the [Read case data](../episodes/read-cases.Rmd) episode.
 This involves loading the dataset into the working environment and view its structure and content. 


``` r
# Read data
# e.g.: if path to file is data/simulated_ebola_2.csv then:
cleaned_data <- rio::import(
  here::here("data", "cleaned_data.csv")
) %>%
  dplyr::as_tibble() # for a simple data frame output
```


``` output
# A tibble: 15,000 × 10
      v1 case_id   age gender status    date_onset date_sample row_id
   <int>   <int> <dbl> <chr>  <chr>     <IDate>    <IDate>      <int>
 1     1   14905    90 male   confirmed 2015-03-15 2015-06-04       1
 2     2   13043    25 female <NA>      2013-09-11 2014-03-01       2
 3     3   14364    54 female <NA>      2014-09-02 2015-03-03       3
 4     4   14675    90 <NA>   <NA>      2014-10-19 2031-12-14       4
 5     5   12648    74 female <NA>      2014-08-06 2016-10-10       5
 6     6   14274    76 female <NA>      2015-04-05 2016-01-23       7
 7     7   14132    16 male   confirmed NA         2015-05-10       8
 8     8   14715    44 female confirmed NA         2016-04-24       9
 9     9   13435    26 male   <NA>      2014-09-07 2020-09-14      10
10    10   14816    30 female <NA>      2015-06-29 2015-06-02      11
# ℹ 14,990 more rows
# ℹ 2 more variables: years_since_collection <int>, remainder_months <int>
```

:::::::::::::::::::::::: discussion

<!-- Have you ever experienced an unexpected change in the input data set when running an analysis during an emergency? How do you safeguard your analysis from this inconvenience? -->

### An unexpected change

You are in an emergency response situation. You need to generate daily situation reports. You automated your analysis to read data directly from the online server :grin:.  However, the people in charge of the data collection/administration needed to **remove/rename/reformat** one variable you found helpful :disappointed:!

How can you detect if the data input is **still valid** to replicate the analysis code you wrote the day before?

::::::::::::::::::::::::

:::::::::::::::::::::::: instructor

If learners do not have an experience to share, we as instructors can share one.

An scenario like this usually happens when the institution doing the analysis is not the same as the institution collecting the data. The later can make decisions about the data structure that can affect downstream processes, impacting the time or the accuracy of the analysis results.

::::::::::::::::::::::::

## Creating a linelist and tagging elements

Then we convert the cleaned case data into a `linelist` object using `{linelist}` package, see the 
below code chunk.


``` r
# Create a linelist object from cleaned data
linelist_data <- linelist::make_linelist(
  x = cleaned_data,         # Input data
  id = "case_id",            # Column for unique case identifiers
  date_onset = "date_onset", # Column for date of symptom onset
  gender = "gender"          # Column for gender
)

# Display the resulting linelist object
linelist_data
```

``` output

// linelist object
# A tibble: 15,000 × 10
      v1 case_id   age gender status    date_onset date_sample row_id
   <int>   <int> <dbl> <chr>  <chr>     <IDate>    <IDate>      <int>
 1     1   14905    90 male   confirmed 2015-03-15 2015-06-04       1
 2     2   13043    25 female <NA>      2013-09-11 2014-03-01       2
 3     3   14364    54 female <NA>      2014-09-02 2015-03-03       3
 4     4   14675    90 <NA>   <NA>      2014-10-19 2031-12-14       4
 5     5   12648    74 female <NA>      2014-08-06 2016-10-10       5
 6     6   14274    76 female <NA>      2015-04-05 2016-01-23       7
 7     7   14132    16 male   confirmed NA         2015-05-10       8
 8     8   14715    44 female confirmed NA         2016-04-24       9
 9     9   13435    26 male   <NA>      2014-09-07 2020-09-14      10
10    10   14816    30 female <NA>      2015-06-29 2015-06-02      11
# ℹ 14,990 more rows
# ℹ 2 more variables: years_since_collection <int>, remainder_months <int>

// tags: id:case_id, date_onset:date_onset, gender:gender 
```

The `{linelist}` package supplies tags for common epidemiological variables 
and a set of appropriate data types for each. You can view the list of available tags by the variable name
and their acceptable data types for each using `linelist::tags_types()`.


::::::::::::::::::::::::::::::::::::: challenge 

Let's **tag** more variables. In new datasets, it will be frequent to have variable names different to the available tag names. However, we can associate them based on how variables were defined for data collection.

Now:

- **Explore** the available tag names in {linelist}.
- **Find** what other variables in the cleaned dataset can be associated with any of these available tags.
- **Tag** those variables as above using `linelist::make_linelist()`.

:::::::::::::::::::: hint

Your can get access to the list of available tag names in {linelist} using:


``` r
# Get a list of available tags by name and data types
linelist::tags_types()

# Get a list of names only
linelist::tags_names()
```

:::::::::::::::::::::::

::::::::::::::::: solution


``` r
linelist::make_linelist(
  x = cleaned_data,
  id = "case_id",
  date_onset = "date_onset",
  gender = "gender",
  age = "age", # same name in default list and dataset
  date_reporting = "date_sample" # different names but related
)
```

How these additional tags are visible in the output? 

<!-- Do you want to see a display of available and tagged variables? You can explore the function `linelist::tags()` and read its [reference documentation](https://epiverse-trace.github.io/linelist/reference/tags.html). -->

::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::


## Validation

To ensure that all tagged variables are standardized and have the correct data 
types, use the `linelist::validate_linelist()`, as 
shown in the example below:

```r
linelist::validate_linelist(linelist_data)
```

<!-- If your dataset requires a new tag, set the argument -->
<!-- `allow_extra = TRUE` when creating the linelist object with its corresponding-->
<!-- datatype. -->



::::::::::::::::::::::::: challenge

Let's **validate** tagged variables. Let's simulate that in an ongoing outbreak; the next day, your data has a new set of entries (i.e., rows or observations) but one variable change of data type. 

For example, let's make the variable `age` change of type from a double (`<dbl>`) variable to character (`<chr>`).

To simulate it:

- **Change** the variable data type,
- **Tag** the variable into a linelist, and then 
- **Validate** it.

Describe how `linelist::validate_linelist()` reacts when input data has a different variable data type.

:::::::::::::::::::::::::: hint

We can use `dplyr::mutate()` to change the variable type before tagging for validation. For example:


``` r
cleaned_data %>%
  # simulate a change of data type in one variable
  dplyr::mutate(age = as.character(age)) %>%
  # tag one variable
  linelist::... %>%
  # validate the linelist
  linelist::...
```

::::::::::::::::::::::::::

:::::::::::::::::::::::::: hint

> Please run the code line by line, focusing only on the parts before the pipe (`%>%`). After each step, observe the output before moving to the next line.

If the `age` variable changes from double (`<dbl>`) to character (`<chr>`) we get the following:


``` r
cleaned_data %>%
  # simulate a change of data type in one variable
  dplyr::mutate(age = as.character(age)) %>%
  # tag one variable
  linelist::make_linelist(
    age = "age"
  ) %>%
  # validate the linelist
  linelist::validate_linelist()
```

``` error
Error: Some tags have the wrong class:
  - age: Must inherit from class 'numeric'/'integer', but has class 'character'
```

Why are we getting an `Error` message?

<!-- Should we have a `Warning` message instead? Explain why. -->

Explore other situations to understand this behavior. Let's try these additional changes to variables:

- `date_onset` changes from a `<date>` variable to character (`<chr>`), 
- `gender` changes from a character (`<chr>`) variable to integer (`<int>`).

Then tag them into a linelist for validation. Does the `Error` message propose to us the solution?

::::::::::::::::::::::::::

::::::::::::::::::::::::: solution


``` r
# Change 2
# Run this code line by line to identify changes
cleaned_data %>%
  # simulate a change of data type
  dplyr::mutate(date_onset = as.character(date_onset)) %>%
  # tag
  linelist::make_linelist(
    date_onset = "date_onset"
  ) %>%
  # validate
  linelist::validate_linelist()
```



``` r
# Change 3
# Run this code line by line to identify changes
cleaned_data %>%
  # simulate a change of data type
  dplyr::mutate(gender = as.factor(gender)) %>%
  dplyr::mutate(gender = as.integer(gender)) %>%
  # tag
  linelist::make_linelist(
    gender = "gender"
  ) %>%
  # validate
  linelist::validate_linelist()
```

We get `Error` messages because of the mismatch between the predefined tag type (from `linelist::tags_types()`) and the tagged variable class in the linelist.

The `Error` message inform us that in order to **validate** our linelist, we must fix the input variable type to fit the expected tag type. In a data analysis script, we can do this by adding one cleaning step into the pipeline.

::::::::::::::::::::::::: 

:::::::::::::::::::::::::

::::::::::::::::::::::::: challenge

What step along the `{linelist}` workflow of tagging and validating would response to the absence of a variable?

:::::::::::::::::::::::::: solution

About losing variables, you can simulate this scenario:


``` r
cleaned_data %>%
  # simulate a change of data type in one variable
  select(-age) %>%
  # tag one variable
  linelist::make_linelist(
    age = "age"
  )
```

``` error
Error in base::tryCatch(base::withCallingHandlers({: 1 assertions failed:
 * Variable 'tag': Must be element of set
 * {'v1','case_id','gender','status','date_onset','date_sample','row_id','years_since_collection','remainder_months'},
 * but is 'age'.
```

::::::::::::::::::::::::::

:::::::::::::::::::::::::


## Safeguarding

Safeguarding is implicitly built into the linelist objects. If you try to drop any of the tagged 
columns, you will receive an error or warning message, as shown in the example below.


``` r
new_df <- linelist_data %>%
  dplyr::select(case_id, gender)
```

``` warning
Warning: The following tags have lost their variable:
 date_onset:date_onset
```

This `Warning` message above is the default output option when we lose tags in a `linelist` object. However, it can be changed to an `Error` message using `linelist::lost_tags_action()`. 

::::::::::::::::::::::::::::::::::::: challenge 

Let's test the implications of changing the **safeguarding** configuration from a `Warning` to an `Error` message.

- First, run this code to count the frequency per category within a categorical variable:


``` r
linelist_data %>%
  dplyr::select(case_id, gender) %>%
  dplyr::count(gender)
```

- Set behavior for lost tags in a `linelist` to "error" as follows:


``` r
# set behavior to "error"
linelist::lost_tags_action(action = "error")
```
- Now, re-run the above code segment with `dplyr::count()`.

Identify:

- What is the difference in the output between a `Warning` and an `Error`?
- What could be the implications of this change for your daily data analysis pipeline during an outbreak response?

:::::::::::::::::::::::: solution

Deciding between `Warning` or `Error` message will depend on the level of attention or flexibility you need when losing tags. One will alert you about a change but will continue running the code downstream. The other will stop your analysis pipeline and the rest will not be executed. 

A data reading, cleaning and validation script may require a more stable or fixed pipeline. An exploratory data analysis may require a more flexible approach. These two processes can be isolated in different scripts or repositories to adjust the safeguarding according to your needs.

Before you continue, set the configuration back again to the default option of `Warning`:


``` r
# set behavior to the default option: "warning"
linelist::lost_tags_action()
```

``` output
Lost tags will now issue a warning.
```

::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::

A  `linelist` object resembles a data frame but offers richer features 
and functionalities. Packages that are linelist-aware can leverage these 
features. For example, you can extract a data frame of only the tagged columns 
using the `linelist::tags_df()` function, as shown below:


``` r
linelist::tags_df(linelist_data)
```

``` output
# A tibble: 15,000 × 3
      id date_onset gender
   <int> <IDate>    <chr> 
 1 14905 2015-03-15 male  
 2 13043 2013-09-11 female
 3 14364 2014-09-02 female
 4 14675 2014-10-19 <NA>  
 5 12648 2014-08-06 female
 6 14274 2015-04-05 female
 7 14132 NA         male  
 8 14715 NA         female
 9 13435 2014-09-07 male  
10 14816 2015-06-29 female
# ℹ 14,990 more rows
```

This allows, the extraction of use tagged-only columns in downstream analysis, which will be useful for the next episode!

:::::::::::::::::::::::::::::::::::: checklist

### When should I use `{linelist}`?

Data analysis during an outbreak response or mass-gathering surveillance demands a different set of "data safeguards" if compared to usual research situations. For example, your data will change or be updated over time (e.g. new entries, new variables, renamed variables).

`{linelist}` is more appropriate for this type of ongoing or long-lasting analysis.
Check the "Get started" vignette section about
[When you should consider using {linelist}?](https://epiverse-trace.github.io/linelist/articles/linelist.html#should-i-use-linelist) for more information.

:::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::: keypoints 

- Use `{linelist}` package to tag, validate, and prepare case data for downstream analysis.

::::::::::::::::::::::::::::::::::::::::::::::::
