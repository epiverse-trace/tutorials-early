---
title: 'Read case data'
teaching: 20
exercises: 10
editor_options: 
  chunk_output_type: inline
---

:::::::::::::::::::::::::::::::::::::: questions 

- Where do you usually store your outbreak data?
- How many different data formats can I read? 
- Is it possible to import data from databases and health APIs? 
::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain how to import outbreak data from different sources into `R` 
environment.
::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: prereq

## Prerequisites

This episode requires you to be familiar with:

**Data science** : Basic programming with R.
:::::::::::::::::::::::::::::::::

## Introduction

The initial step in outbreak analysis involves importing the target dataset into the `R` environment from various sources. Outbreak data is typically stored in files of diverse formats, relational database management systems (RDBMS), or health information system (HIS) application program interfaces (APIs) such as [REDCap](https://www.project-redcap.org/), [DHIS2](https://dhis2.org/), etc. The latter  option is particularly well-suited for storing institutional health data. This episode will elucidate the process of reading cases from these sources.

Let's start by loading the package `{rio}` to read data and the package `{here}` to easily find a file path within your RStudio project. We'll use the pipe `%>%` to connect some of their functions, including others from the package `{dplyr}`, so let's also call to the tidyverse package:


``` r
# Load packages
library(tidyverse) # for {dplyr} functions and the pipe %>%
library(rio) # for importing data
library(here) # for easy file referencing
```

::::::::::::::::::: checklist

### The double-colon

The double-colon `::` in R let you call a specific function from a package without loading the entire package into the current environment. 

For example, `dplyr::filter(data, condition)` uses `filter()` from the `{dplyr}` package.

This help us remember package functions and avoid namespace conflicts.

:::::::::::::::::::


:::::::::: prereq

### Setup a project and folder

- Create an RStudio project. If needed, follow this [how-to guide on "Hello RStudio Projects"](https://docs.posit.co/ide/user/ide/get-started/#hello-rstudio-projects) to create one.
- Inside the RStudio project, create the `data/` folder.
- Inside the `data/` folder, save the [ebola_cases_2.csv](https://epiverse-trace.github.io/tutorials-early/data/ebola_cases_2.csv) and [marburg.zip](https://epiverse-trace.github.io/tutorials-early/data/Marburg.zip) files.

::::::::::

## Reading from files 

Several packages are available for importing outbreak data stored in individual files into `R`. These include [rio](https://gesistsa.github.io/rio/), [readr](https://readr.tidyverse.org/) from the `tidyverse`, [io](https://bitbucket.org/djhshih/io/src/master/), [ImportExport](https://cran.r-project.org/web/packages/ImportExport/index.html), and [data.table](https://rdatatable.gitlab.io/data.table/). Together, these packages offer methods to read single or multiple files in a wide range of formats.

The below example shows how to import a `csv` file into `R` environment using `{rio}` package.


``` r
# read data
# e.g., the path to our file is data/raw-data/ebola_cases_2.csv then:
ebola_confirmed <- rio::import(
  here::here("data", "ebola_cases_2.csv")
) %>%
  dplyr::as_tibble() # for a simple data frame output

# preview data
ebola_confirmed
```



``` output
# A tibble: 120 × 4
    year month   day confirm
   <int> <int> <int>   <int>
 1  2014     5    18       1
 2  2014     5    20       2
 3  2014     5    21       4
 4  2014     5    22       6
 5  2014     5    23       1
 6  2014     5    24       2
 7  2014     5    26      10
 8  2014     5    27       8
 9  2014     5    28       2
10  2014     5    29      12
# ℹ 110 more rows
```

Similarly, you can import files of other formats such as `tsv`, `xlsx`, ... etc.

:::::::::::::::::::: checklist

### Why should we use the {here} package?

The `{here}` package is designed to simplify file referencing in R projects by providing a reliable way to construct file paths relative to the project root. The main reason to use it is **Cross-Environment Compatibility**.

It works across different operating systems (Windows, Mac, Linux) without needing to adjust file paths. 

- On Windows, paths are written using backslashes ( `\` ) as the separator between folder names: `"data\raw-data\file.csv"` 
- On Unix based operating system such as macOS or Linux the forward slash ( `/` ) is used as the path separator: `"data/raw-data/file.csv"`

The `{here}` package is ideal for adding one more layer of reproducibility to your work. If you are interested in reproducibility, we invite you to [read this tutorial to increase the openess, sustainability, and reproducibility of your epidemic analysis with R](https://epiverse-trace.github.io/research-compendium/)

::::::::::::::::::::

::::::::::::::::::::::::::::::::: challenge

###  Reading compressed data 

Take 1 minute:
Can you read data from a compressed file in `R`? Download this [zip file](https://epiverse-trace.github.io/tutorials-early/data/Marburg.zip) containing data for Marburg outbreak and then import it to your working environment.

::::::::::::::::: hint

You can check the [full list of supported file formats](https://gesistsa.github.io/rio/#supported-file-formats) 
in the `{rio}` package on the package website. To expand {rio} to the full range of support for import and export formats run:



``` r
rio::install_formats()
```

You can use this template to read the file: 

`rio::import(here::here("some", "where", "downto", "path", "file_name.zip"))`

::::::::::::::::::::::

::::::::::::::::: solution


``` r
rio::import(here::here("data", "Marburg.zip"))
```
::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::


## Reading from databases

The [DBI](https://dbi.r-dbi.org/) package serves as a versatile interface for interacting with database management 
systems (DBMS) across different back-ends or servers. It offers a uniform method for accessing and retrieving data from various database systems.

::::::::::::: discussion

### When to read directly from a database?

We can use database interface packages to optimize memory usage. If we process the database with "queries" (e.g., select, filter, summarise) before extraction, we can reduce the memory load in our RStudio session. Conversely, conducting all data manipulation outside the database management system can lead to occupying more disk space than desired running out of memory.

:::::::::::::

The following code chunk demonstrates in four steps how to create a temporary SQLite database in memory, store the `ebola_confirmed` as a table on it, and subsequently read it:

### 1. Connect with a database

First, we establish a connection to an SQLite database created in memory using `DBI::dbConnect()`. 


``` r
library(DBI)
library(RSQLite)

# Create a temporary SQLite database in memory
db_connection <- DBI::dbConnect(
  drv = RSQLite::SQLite(),
  dbname = ":memory:"
)
```

::::::::::::::::: callout

A real-life connection would look like this:

```r
# in real-life
db_connection <- DBI::dbConnect(
  RSQLite::SQLite(), 
  host = "database.epiversetrace.com",
  user = "juanito",
  password = epiversetrace::askForPassword("Database password")
)
```

:::::::::::::::::

### 2. Write a local data frame as a table in a database

Then, we can write the `ebola_confirmed` into a table named `cases` within the database using the `DBI::dbWriteTable()` function.


``` r
# Store the 'ebola_confirmed' dataframe as a table named 'cases'
# in the SQLite database
DBI::dbWriteTable(
  conn = db_connection,
  name = "cases",
  value = ebola_confirmed
)
```

In a database framework, you can have more than one table. Each table can belong to a specific `entity` (e.g., patients, care units, jobs). All tables will be related by a common ID or `primary key`.

### 3. Read data from a table in a database

<!-- Subsequently, we reads the data from the `cases` table using `DBI::dbReadTable()`. -->

<!-- ```{r,warning=FALSE,message=FALSE} -->
<!-- # Read data from the 'cases' table -->
<!-- extracted_data <- DBI::dbReadTable( -->
<!--   conn = db_connection, -->
<!--   name = "cases" -->
<!-- ) -->
<!-- ``` -->

Subsequently, we reads the data from the `cases` table using `dplyr::tbl()`.


``` r
# Read one table from the database
mytable_db <- dplyr::tbl(src = db_connection, "cases")
```

If we apply `{dplyr}` verbs to this database SQLite table, these verbs will be translated to SQL queries.


``` r
# Show the SQL queries translated
mytable_db %>%
  dplyr::filter(confirm > 50) %>%
  dplyr::arrange(desc(confirm)) %>%
  dplyr::show_query()
```

``` output
<SQL>
SELECT `cases`.*
FROM `cases`
WHERE (`confirm` > 50.0)
ORDER BY `confirm` DESC
```

### 4. Extract data from the database

Use `dplyr::collect()` to force computation of a database query and extract the output to your local computer.


``` r
# Pull all data down to a local tibble
extracted_data <- mytable_db %>%
  dplyr::filter(confirm > 50) %>%
  dplyr::arrange(desc(confirm)) %>%
  dplyr::collect()
```

The `extracted_data` object represents the extracted, ideally after specifying queries that reduces its size.


``` r
# View the extracted_data
extracted_data
```

``` output
# A tibble: 3 × 4
   year month   day confirm
  <int> <int> <int>   <int>
1  2014     9    16      84
2  2014     9    15      68
3  2014     9    17      56
```

:::::::::::::::::::::: callout

### Run SQL queries in R using dbplyr

Practice how to make relational database SQL queries using multiple `{dplyr}` verbs like `dplyr::left_join()` among tables before pulling down data to your local session with `dplyr::collect()`! 

You can also review the `{dbplyr}` R package. But for a step-by-step tutorial about SQL, we recommend you this [tutorial about data management with SQL for Ecologist](https://datacarpentry.org/sql-ecology-lesson/). You will find close to `{dplyr}`!

::::::::::::::::::::::


### 5. Close the database connection

Finally, we can close the database connection with `dbDisconnect()`.


``` r
# Close the database connection
DBI::dbDisconnect(conn = db_connection)
```

## Reading from HIS APIs

Health related data are also increasingly stored in specialized HIS APIs like **Fingertips**, **GoData**, **REDCap**, and **DHIS2**. In such case one can resort to [readepi](https://epiverse-trace.github.io/readepi/) package, which enables reading  data from HIS-APIs.  
-[TBC]

::::::::::::::::::::::::::::::::::::: keypoints 
- Use `{rio}, {io}, {readr}` and `{ImportExport}` to read data from individual files.
- Use `{readepi}` to read data form HIS APIs and RDBMS.
::::::::::::::::::::::::::::::::::::::::::::::::