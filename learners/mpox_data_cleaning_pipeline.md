# Introduction

In this document, we use the
[{cleanepi}](https://epiverse-trace.github.io/cleanepi/) package to
clean and standardize a messy mpox (formerly known as Monkeypox) dataset
obtained from the [global.health](https://global.health/) platform. The
dataset is in a `csv` format available on this
[link](https://mpox-2024.s3.eu-central-1.amazonaws.com/latest.csv).

We begin by importing the data into R and then utilize {cleanepi}
functionalities to perform the following operations in a streamlined
manner:

-   Replace missing data with `NA`.
-   Remove constant columns, empty rows, and columns.
-   Detect and remove duplicate rows.
-   Standardize the date columns by ensuring all date values follow the
    format `YYYY-MM-DD` (e.g., `2024-12-01` for December 1st, 2024).

All these operations can be efficiently performed in a few lines as
demonstrated in the following pipeline:

``` r
cleaned_data <- data.table::fread(
  "https://mpox-2024.s3.eu-central-1.amazonaws.com/latest.csv") |>
  cleanepi::replace_missing_values(na_strings = "") |>
  cleanepi::remove_constants() |>
  cleanepi::standardize_dates(error_tolerance = 1) |>
  cleanepi::remove_duplicates()
```

In the sections below, we provide a detailed explanation of how these
cleaning operations work.

## Installing the required packages

We will need the following four packages:

-   `{data.table}` for fast import of large dataset. If you have a
    smaller dataset you can use `readr::read_csv()` or `read.csv()`
    instead.
-   `{cleanepi}` for data cleaning and standardization.
-   `{wakefield}` for data visualization. For smaller datasets, you can
    use the `{visdat}` package.
-   `{kableExtra}` for tabular visualization.

The below code chunk installs these packages (if not already installed).

``` r
# install the packages if not already done
if (!require("wakefield")) pak::pak("wakefield")
if (!require("cleanepi")) pak::pak("cleanepi")
if (!require("kableExtra")) pak::pak("kableExtra")
if (!require("data.table")) pak::pak("data.table")

# load the libraries
library(wakefield)
library(cleanepi)
library(kableExtra)
library(data.table)
```

## Data laoding and inspection

## Data download

The data file is quite large ( ∼ 17 MB) and may fail to download using
`read.csv()` due to time limits. As such, we recommend to import the
data using the `data.table::fread()` function or download it on your
computer.

We load the dataset using the `data.table::fread()` function and
visualize it with both `View()` and `wakefield::table_heat()` functions
to understand the distribution of missing values within the dataset.

``` r
# import the data
data_in <- data.table::fread(
  "https://mpox-2024.s3.eu-central-1.amazonaws.com/latest.csv"
)

# Visualise the distribution of the different types as well as missing data
# across the dataset
wakefield::table_heat(data_in, palette = "Set3", flip = TRUE, print = TRUE)
```

![](mpox_data_cleaning_pipeline_files/figure-markdown_github/unnamed-chunk-2-1.png)

As show in the above figure, the dataset contains 45 columns and 64215
rows. Approximately 81.04% of the values are missing, of which around
53.08% is represented by empty strings.

## Use `NA` for missing data

Missing values appear as empty strings in the data. To ensure
consistency with the R language, we will standardize these missing
values as `NA` using the `replace_missing_values()` function from
`{cleanepi}`.

``` r
# Replace empty characters ("") with NA
data_in <- data_in |>
  cleanepi::replace_missing_values(na_strings = "")
```

After replacing the empty characters with `NA`, the dataset is now
composed of 81.04% missing values. The new distribution of missing
values is shown in the below figure.

``` r
# Visualise the new distribution of the different data types as well as missing 
# data across the dataset
wakefield::table_heat(data_in, palette = "Set3", flip = TRUE, print = TRUE)
```

![](mpox_data_cleaning_pipeline_files/figure-markdown_github/unnamed-chunk-4-1.png)

## Scan through character columns

To determine which potential data cleaning operations could be applied
to this dataset, we can examine all the content of the character columns
by assessing the proportion of the various data types. This can be
accomplished using the `scan_data()` function from the `{cleanepi}`
package.

``` r
# Scan with cleanepi
scan_result <- cleanepi::scan_data(data_in)
```

In the below code chunk, we make sure to color in red any row where
there are multiple data types found by the `scan_data()` function.

``` r
# detect rows with multiple data types
df <- scan_result |>
  dplyr::mutate(highlight = ((numeric > 0) & (date > 0)) |
           ((numeric > 0) & (character > 0)) |
           ((numeric > 0) & (logical > 0)) |
           ((date > 0) & (character > 0)) |
           ((date > 0) & (logical > 0)) |
           ((character > 0) & (logical > 0))
         )
highlight_rows <- which(df$highlight)

scan_result |>
  kableExtra::kable() |>
  kableExtra::kable_paper("striped", font_size = 14, full_width = TRUE) |>
  kableExtra::scroll_box(height = "200px", width = "100%",
                         box_css = "border: 1px solid #ddd; padding: 5px;",
                         extra_css = NULL,
                         fixed_thead = TRUE) |>
  kableExtra::row_spec(highlight_rows, bold = TRUE, background = "red", color = "white")
```

<table class=" lightable-paper lightable-striped" style="font-size: 14px; font-family: &quot;Arial Narrow&quot;, arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
Field_names
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
missing
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
numeric
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
date
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
character
</th>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
logical
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Pathogen_name
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
1.0000
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Case_status
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
1.0000
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Location_Admin0
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
1.0000
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Location_Admin1
</td>
<td style="text-align:right;">
0.9756
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0244
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Location_Admin2
</td>
<td style="text-align:right;">
0.9993
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0007
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Location_Admin3
</td>
<td style="text-align:right;">
1.0000
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Age
</td>
<td style="text-align:right;">
0.9991
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0009
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Gender
</td>
<td style="text-align:right;">
0.9991
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0009
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Occupation
</td>
<td style="text-align:right;">
0.9998
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0002
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Symptoms
</td>
<td style="text-align:right;">
0.9994
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0006
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Pre_existing_condition
</td>
<td style="text-align:right;">
0.9998
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0002
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Hospitalised
</td>
<td style="text-align:right;">
0.9994
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0006
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Isolated
</td>
<td style="text-align:right;">
0.9996
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0004
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Outcome
</td>
<td style="text-align:right;">
0.9987
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0013
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Contact_with_case
</td>
<td style="text-align:right;">
0.9998
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0002
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Contact_setting
</td>
<td style="text-align:right;">
0.9999
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0001
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Transmission
</td>
<td style="text-align:right;">
1.0000
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Travel_history
</td>
<td style="text-align:right;">
0.9993
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0007
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Travel_history_start
</td>
<td style="text-align:right;">
0.9999
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1e-04
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Travel_history_location
</td>
<td style="text-align:right;">
0.9996
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0004
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Genomics_Metadata
</td>
<td style="text-align:right;">
0.9997
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0003
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Confirmation_method
</td>
<td style="text-align:right;">
0.9998
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0002
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Source_I
</td>
<td style="text-align:right;">
0.0000
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
1.0000
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Source_I_Government
</td>
<td style="text-align:right;">
0.0001
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.9999
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Source_II
</td>
<td style="text-align:right;">
0.9295
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0705
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Source_III
</td>
<td style="text-align:right;">
0.9947
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0053
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Source_IV
</td>
<td style="text-align:right;">
0.9956
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0044
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Source_V
</td>
<td style="text-align:right;">
0.9992
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0008
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:left;">
Source_VI
</td>
<td style="text-align:right;">
0.9999
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0e+00
</td>
<td style="text-align:right;">
0.0001
</td>
<td style="text-align:right;">
0
</td>
</tr>
</tbody>
</table>

In the table above, each row represents a column from the original
dataset, while the columns indicate different data types. If a row has a
non-zero percentage in more than one data type (excluding missing
values), its corresponding column in the original dataset needs to be
standardized.

## Remove constant columns

The dataset may contain constant columns (i.e. columns with the same
value across all rows) and empty rows and columns (i.e. rows or columns
with only `NA` values). To remove these non-informative rows and
columns, we use the `remove_constants()` function from the `{cleanepi}`
package.

``` r
# Remove constant columns, empty rows and columns
data_in <- data_in |>
  cleanepi::remove_constants()
```

This resulted in the removal of 11 columns — 5 empty columns and 6
constant columns — while no empty rows were removed, as shown in the
table below.

``` r
# display the set of constant data
constant_data <- cleanepi::print_report(data_in, "constant_data")
constant_data |>
  kableExtra::kbl() |>
  kableExtra::kable_paper("striped", font_size = 14, full_width = TRUE) %>%
  kableExtra::scroll_box(height = "200px", width = "100%",
                         box_css = "border: 1px solid #ddd; padding: 5px; ",
                         extra_css = NULL,
                         fixed_thead = TRUE)
```

<table class=" lightable-paper lightable-striped" style="font-size: 14px; font-family: &quot;Arial Narrow&quot;, arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;">
iteration
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
empty_columns
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
empty_rows
</th>
<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">
constant_columns
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:left;">
Treatment_antiviral, Treatment_antiviral_name, Vaccination,
Vaccine_name, Vaccine_date
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
Pathogen_name, Pre_existing_condition, Isolated, Date_isolation,
Contact_with_case, Transmission
</td>
</tr>
</tbody>
</table>

## Remove duplicates

We can detect and remove duplicates using the `remove_duplicates()`
function from the `{cleanepi}` package. In this case, we do not specify
any target column, i.e., we look for duplicates across all columns.

``` r
data_in <- data_in |>
  cleanepi::remove_duplicates()
```

    ## ℹ No duplicates were found.

Fortunately (or unfortunately!) there are no duplicate entries in this
dataset.

## Standardise dates

Some character columns seem to contain actual Date values. We will apply
the `standardize_dates()` function from the `{cleanepi}` package to
ensure all date columns are in ISO8601 format. First, we’ll identify the
potential Date columns from the results of the `scan_data()` function,
and then use those columns for standardization.

``` r
# Identify potential Date columns from the scanning results. Columns with
# %date > 0 are likely to be of type Date
potential_dates <- scan_result |>
  dplyr::filter(date > 0)
target_columns <- potential_dates$Field_names

# Standardise the selected columns
data_in <- data_in |>
  cleanepi::standardize_dates(
    target_columns = target_columns,
    error_tolerance = 1
  )
```

    ## ! Detected no values that comply with multiple formats and no values that are
    ##   outside of the specified time frame.
    ## ℹ Enter `print_report(data = dat, "date_standardization")` to access them,
    ##   where "dat" is the object used to store the output from this operation.

## Removing columns with excessive `NA` Values

After applying the above mentioned rudimentary cleaning operations, the
dataset still contains several columns with a high proportion of `NA`
values. These columns provide limited analytical value, and thus less
informative.

To remove such columns from the dataset and exclude them from further
downstream analysis, we can use the `remove_constant()` function from
`{cleanepi}`, setting the `cutoff` parameter to an appropriate value.

For example, the below code chunk could be used to exclude columns where
more than **90%** of the values are `NA`.

``` r
df <- data_in |> 
  cleanepi::remove_constants(cutoff = 0.9)

# Visualise the new distribution of missing data across the dataset
wakefield::table_heat(df, palette = "Set3", flip = TRUE, print = TRUE)
```

## Conclusion

Data cleaning is an essential task for robust downstream statistical
analysis. However, it can be tedious and time-consuming. By leveraging
the efficient functionalities of `{cleanepi}`, users can clean and
standardize their input datasets quickly and effectively, using minimal
and concise code.
