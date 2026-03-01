---
title: 'Validate case data'
teaching: 20
exercises: 10
---


:::::::::::::::::::::::::::::::::::::: questions 

- How can a raw case data be converted into a `linelist` object?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Demonstrate how to covert case data into `linelist` object
- Demonstrate how to tag and validate data to improve the reliability of downstream analysis


::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::: prereq

This episode requires you to:

- Download the [cleaned_data.csv](https://epiverse-trace.github.io/tutorials-early/data/cleaned_data.csv) file
- and save it in the `data/` folder.

:::::::::::::::::::::

## Introduction

In outbreak analysis, once you have completed the initial steps of reading and cleaning the case data, it's essential to establish an additional fundamental layer to ensure the integrity and reliability of subsequent analyses. Without this step, you may encounter issues later, for example, variables may be be unintentionally modified or removed, or their data types (e.g., `<date>`, `<chr>`), may change during processing. This additional layer typically involves two key steps:

1. **tagging**: Verifying that required columns are present in the dataset and confirming that they have the correct data types.
2. **validation**: Implementing safeguards to ensure that tagged columns are not accidentally deleted or altered during subsequent data manipulation steps.


This episode focuses on creating linelist object using the [linelist](https://epiverse-trace.github.io/linelist/) package, which natively supports tagging and validating outbreak data o ensure data integrity throughout the analysis workflow. Let's start by loading the package `{rio}` to read data and the `{linelist}` package
to create a linelist object. We'll use the pipe operator (`%>%`) to connect some of their functions, including others from the package `{dplyr}`. For this reason, we will also load the {tidyverse} package.



``` r
# Load packages
library(tidyverse) # to access {dplyr} functions and the pipe %>% operator
# from {magrittr}
library(rio) # for importing data
library(here) # for easy file referencing
library(linelist) # for tagging and validating
```

::::::::::::::::::: checklist

### The double-colon (`::`) operator

The`::` in R lets you access functions or objects from a specific package without attaching the entire package to the search path. It offers several important
advantages including the followings:

* Telling explicitly which package a function comes from, reducing ambiguity and potential conflicts when several packages have functions with the same name.
* Allowing to call a function from a package without loading the whole package
with library().

For example, the command `dplyr::filter(data, condition)` means we are calling
the `filter()` function from the `{dplyr}` package.

:::::::::::::::::::

Import the dataset following the guidelines outlined in the [Read case data](../episodes/read-cases.Rmd) episode. This involves loading the dataset into the working environment and view its structure and content.


``` r
# Read data
# e.g.: if path to file is data/simulated_ebola_2.csv then:
cleaned_data <- rio::import(
  here::here("data", "cleaned_data.csv")
) %>%
  dplyr::as_tibble() # for a simple data frame output
```


``` output
# A tibble: 15,000 × 9
      v1 case_id   age gender status    date_onset date_sample
   <int>   <int> <dbl> <chr>  <chr>     <IDate>    <IDate>    
 1     1   14905    90 male   confirmed 2015-03-15 2015-04-06 
 2     2   13043    25 female <NA>      2013-09-11 2014-01-03 
 3     3   14364    54 female <NA>      2014-02-09 2015-03-03 
 4     4   14675    90 <NA>   <NA>      2014-10-19 2014-12-31 
 5     5   12648    74 female <NA>      2014-06-08 2016-10-10 
 6     6   14274    76 female <NA>      2015-04-05 2016-01-23 
 7     7   14132    16 male   confirmed NA         2015-10-05 
 8     8   14715    44 female confirmed NA         2016-04-24 
 9     9   13435    26 male   <NA>      2014-07-09 2014-09-20 
10    10   14816    30 female <NA>      2015-06-29 2015-02-06 
# ℹ 14,990 more rows
# ℹ 2 more variables: years_since_collection <int>, remainder_months <int>
```

:::::::::::::::::::::::: discussion

<!-- Have you ever experienced an unexpected change in the input data set when running an analysis during an outbreak? How do you safeguard your analysis from this inconvenience? -->

### An unexpected change

You are in an emergency response situation. You need to generate daily situation reports. You automated your analysis to read data directly from the online server :grin:.  However, the people in charge of the data collection/administration needed to **remove/rename/reformat** one variable you found helpful :disappointed:!

How can you detect if the input data is **still valid** to replicate the analysis code you wrote the day before?

::::::::::::::::::::::::

:::::::::::::::::::::::: instructor

If learners do not have an experience to share, we as instructors can share one.

A scenario like this usually happens when the institution doing the analysis is not the same as the institution collecting the data. The later can make decisions about the data structure that can affect downstream processes, impacting the time or the accuracy of the analysis results.

::::::::::::::::::::::::

## Creating a linelist and tagging columns

Once the data is loaded and cleaned, it can be converted  into a `linelist` object using `{linelist}` package, as illustrated in the code chunk below.


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
# A tibble: 15,000 × 9
      v1 case_id   age gender status    date_onset date_sample
   <int>   <int> <dbl> <chr>  <chr>     <IDate>    <IDate>    
 1     1   14905    90 male   confirmed 2015-03-15 2015-04-06 
 2     2   13043    25 female <NA>      2013-09-11 2014-01-03 
 3     3   14364    54 female <NA>      2014-02-09 2015-03-03 
 4     4   14675    90 <NA>   <NA>      2014-10-19 2014-12-31 
 5     5   12648    74 female <NA>      2014-06-08 2016-10-10 
 6     6   14274    76 female <NA>      2015-04-05 2016-01-23 
 7     7   14132    16 male   confirmed NA         2015-10-05 
 8     8   14715    44 female confirmed NA         2016-04-24 
 9     9   13435    26 male   <NA>      2014-07-09 2014-09-20 
10    10   14816    30 female <NA>      2015-06-29 2015-02-06 
# ℹ 14,990 more rows
# ℹ 2 more variables: years_since_collection <int>, remainder_months <int>

// tags: id:case_id, date_onset:date_onset, gender:gender 
```

The `{linelist}` package provides predefined tags for common epidemiological variables, along with the appropriate data types for each. You can view all available tags and their corresponding acceptable data types using the `linelist::tags_types()` function.

::::::::::::::::::::::::::::::::::::: challenge

Let's now **tag** additional variables. In some datasets, variable names may not exactly match the predefined tag names. In these cases, you can map them based on how the variables were defined during data collection. You need to:

- **Explore** the available tag names in `{linelist}`.
- **Find** what other variables in the input dataset can be associated with any of these available tags.
- **Tag** those variables as shown above using the `linelist::make_linelist()`
function.

:::::::::::::::::::: hint

Your can get access to the list of available tag names in `{linelist}` using:

``` r
# Get a list of available tags names and data types
linelist::tags_types()

# Get a list of names only
linelist::tags_names()
```
:::::::::::::::::::

::::::::::::::::::::: solution


``` r
linelist::make_linelist(
  x = cleaned_data,
  id = "case_id",
  date_onset = "date_onset",
  gender = "gender",
  age = "age",
  # same name in default list and dataset
  date_reporting = "date_sample" # different names but related
)
```


Are the additional tags visible in the output?

Do you want to see a display of available and tagged variables? You can explore the function `linelist::tags()` and read its [reference documentation](https://epiverse-trace.github.io/linelist/reference/tags.html).

:::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::


## Validation

To validate that all tagged variables are standardized and have the correct data
types, use the `linelist::validate_linelist()` function, as shown in the example below:


``` r
linelist::validate_linelist(linelist_data)
```

``` output
'linelist_data' is a valid linelist object
```

If your dataset requires a new tag other than those defined in the `{linelist}` 
package, use `allow_extra = TRUE` when creating the linelist object with its 
corresponding datatype using the `linelist::make_linelist()` function.


::::::::::::::::::::::::: challenge

## Changes in Variable Types During Linelist Validation
Let's assume the following scenario during an ongoing outbreak. You notice at some point that the data stream you have been relying on has a set of new entries (i.e., rows or observations), and the data type of one variable has changed.

Let's consider the example where the type `age` variable has changed from a double (`<dbl>`) to character (`<chr>`).

To simulate this situation:

- **Change** the data type of the variable,

- **Tag** the variable into a linelist, and then

- **Validate** it.

Describe how `linelist::validate_linelist()` reacts when there is a change in the data type of one variable of the input data.


:::::::::::::::::::::::::: hint

We can use `dplyr::mutate()` to change the variable type before tagging for validation. For example:

``` r
# nolint start

cleaned_data %>%
  # simulate a change of data type in one variable
  dplyr::mutate(age = as.character(age)) %>%
  # tag one variable
  linelist::.... %>%
  # validate the linelist
  linelist::...

# nolint end
```

Please run the code line by line, focusing only on the parts before the pipe (`%>%`). After each step, observe the output before moving to the next line.


``` r
cleaned_data %>%
  # simulate a change of data type in one variable
  dplyr::mutate(age = as.character(age)) %>%
  # tag one variable
  linelist::make_linelist(age = "age") %>%
  # validate the linelist
  linelist::validate_linelist()
```

``` error
Error:
! Some tags have the wrong class:
  - age: Must inherit from class 'numeric'/'integer', but has class 'character'
```

::::::::::::::::::::::::::

Why are we getting an `Error` message?

Should we have a `Warning` message instead? Explain why.

Explore other situations to understand this behavior by converting:-`date_onset` from `<date>` to character (`<chr>`), -`gender` character (`<chr>`) to integer (`<int>`).

Then tag them into a linelist for validation. Does the `Error` message suggest a fix to the issue?

Why are we getting an `Error` message?
Should we have a `Warning` message instead? Explain why?
Explore other situations to understand this behavior by converting:-`date_onset` from `<date>` to character (`<chr>`), -`gender` character (`<chr>`) to integer (`<int>`).

Then tag them into a linelist for validation. Does the `Error` message suggest a fix to the issue?

::::::::::::::::::::::::: solution


``` r
# Change 2
# Run this code line by line to identify changes
cleaned_data %>%
  # simulate a change of data type
  dplyr::mutate(date_onset = as.character(date_onset)) %>%
  # tag
  linelist::make_linelist(date_onset = "date_onset") %>%
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
  linelist::make_linelist(gender = "gender") %>%
  # validate
  linelist::validate_linelist()
```

We get `Error` messages because the default type of these variable in  `linelist::tags_types()` is different from the one we set them at.

The `Error` message inform us that in order to **validate** our linelist, we must fix the input variable type to fit the expected tag type. In a data analysis script, we can do this by adding one cleaning step into the pipeline.
:::::::::::::::::::::::::

::::::::::::::::::::::::::::: challenge

Beyond tagging and validating the linelist object, what extra step do we needed when building the object?

:::::::::::::::::::::::::: solution

Let's simulate a scenario about losing a variable :


``` r
cleaned_data %>%
  # remove the variable 'age'
  select(-age) %>%
  # tag variable 'age' that no longer exist
  linelist::make_linelist(
    age = "age"
  )
```

``` error
Error in `base::tryCatch()`:
! 1 assertions failed:
 * Variable 'tag': Must be element of set
 * {'v1','case_id','gender','status','date_onset','date_sample','years_since_collection','remainder_months'},
 * but is 'age'.
```

::::::::::::::::::::::::::

:::::::::::::::::::::::::::::

::::::::::::::::::::::::


## Safeguarding

Safeguarding is implicitly built into the linelist objects. If you try to delete or modify any of the tagged columns, you will receive an error or warning message, as shown in the example below.


``` r
new_df <- linelist_data %>%
  dplyr::select(case_id, gender)
```

``` warning
Warning: The following tags have lost their variable:
 date_onset:date_onset
```

This `Warning`  is the default option when we lose tags in a `linelist` object. However, it can be changed to an `Error` message using the `linelist::lost_tags_action()` function.


::::::::::::::::::::::::::::::::::::: challenge

## Exploring Safeguarding Behavior for Lost Tags

Let's test the implications of changing the **safeguarding** configuration from a `Warning` to an `Error` message.

- First, run this code to count the frequency of each category within a categorical variable:

``` r
linelist_data %>%
  dplyr::select(case_id, gender) %>%
  dplyr::count(gender)
```

- Set the behavior for lost tags in a `linelist` to "error" as follows:


``` r
# set behavior to "error"
linelist::lost_tags_action(action = "error")
```

- Now, re - run the above code chunk with `dplyr::count()`.

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

::::::::::::::::::::::::::::::::::::: 

A `linelist` object resembles a data frame but offers richer features
and functionalities. Packages that are linelist - aware can leverage these
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
 3 14364 2014-02-09 female
 4 14675 2014-10-19 <NA>  
 5 12648 2014-06-08 female
 6 14274 2015-04-05 female
 7 14132 NA         male  
 8 14715 NA         female
 9 13435 2014-07-09 male  
10 14816 2015-06-29 female
# ℹ 14,990 more rows
```

This allows for the use of tagged variables only in downstream analysis, which will be useful for the next episode!

:::::::::::::::::::::::::::::::::::: checklist

### When should I use `{linelist}`?

Data analysis during an outbreak response or mass - gathering surveillance demands a different set of "data safeguards" if compared to usual research situations. For example, your data will change or be updated over time (e.g. new entries, new variables, renamed variables).

`{linelist}` is more appropriate for this type of ongoing or long - lasting analysis. Check the "Get started" vignette section about
[When I should consider using `{linelist}`? ](https://epiverse-trace.github.io/linelist/articles/linelist.html#should-i-use-linelist) for more information.

::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::: keypoints

- Use the `{linelist}` package to tag,
validate,
and prepare case data for downstream analysis.
- Explore and map dataset variables to predefined tags for standardization.
- Understand how warnings vs. errors affect the data processing workflow.

::::::::::::::::::::::::::::::::::::::::::::::::


