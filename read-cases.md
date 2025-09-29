---
title: 'Read case data'
teaching: 20
exercises: 10
editor_options: 
  chunk_output_type: inline
---

:::::::::::::::::::::::::::::::::::::: questions 

- Where do you usually store your outbreak data?
- How many different data formats can you use for analysis? 
- Can you import data from servers and health information systems? 
::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain how to import outbreak data from different sources into `R` 
environment.
::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: prereq

## Prerequisites

This episode requires you to be familiar with: **Data science** : Basic tasks with R.
:::::::::::::::::::::::::::::::::

## Introduction

The initial step in outbreak analysis typically involves importing the target dataset into the `R` environment from either a local source (like a file on your computer) or external source (like a database). Outbreak data can be stored in diverse formats, relational database management systems (RDBMS), or health information systems (HIS), such as [REDCap](https://www.project-redcap.org/) and [DHIS2](https://dhis2.org/), which provide application program interfaces (APIs) to the database systems so verified users can easily add and access data entries. The latter option is particularly well-suited for collecting and storing large-scale institutional health data. This episode will elucidate the process of reading cases from these sources.

Let's start by loading the package `{rio}` to read data and the package `{here}` to easily find a file path within your RStudio project. We'll use the pipe operator (`%>%`) from the `{magrittr}` package to easily connect some of their functions, including functions from the data formatting package `{dplyr}`. We'll therefore call the tidyverse package, which includes both `{magrittr}` and `{dplyr}`:


``` r
# Load packages
library(tidyverse) # for {dplyr} functions and the pipe %>%
library(rio) # for importing data from files
library(here) # for easy file referencing
library(readepi) # for importing data directly from RDBMS or HIS
library(dbplyr) # for a database backend for {dplyr}
```

::::::::::::::::::: checklist

### The double-colon

The double-colon `::` in R lets you call a specific function from a package without loading the entire package into the current environment. 

For example, `dplyr::filter(data, condition)` uses `filter()` from the `{dplyr}` package, without having to use `library(dplyr)` at the start of a script.

This help us remember package functions and avoid namespace conflicts (i.e. when two different packages include functions with the same name, so R does not know which to use).

:::::::::::::::::::


:::::::::: prereq

### Setup a project and folder

- Create an RStudio project. If needed, follow this [how-to guide on "Hello RStudio Projects"](https://docs.posit.co/ide/user/ide/get-started/#hello-rstudio-projects) to create one.
- Inside the RStudio project, create a `data/` folder.
- Inside the `data/` folder, save the [ebola_cases_2.csv](https://epiverse-trace.github.io/tutorials-early/data/ebola_cases_2.csv) and [marburg.zip](https://epiverse-trace.github.io/tutorials-early/data/Marburg.zip) CSV files.

::::::::::

## Reading from files 

Several packages are available for importing outbreak data stored in individual files into `R`. These include [{rio}](https://gesistsa.github.io/rio/), [{readr}](https://readr.tidyverse.org/) from the `{tidyverse}`, [{io}](https://bitbucket.org/djhshih/io/src/master/), [{ImportExport}](https://cran.r-project.org/web/packages/ImportExport/index.html), and [{data.table}](https://rdatatable.gitlab.io/data.table/). Together, these packages offer methods to read single or multiple files in a wide range of formats.

The below example shows how to import a `csv` file into `R` environment using the `{rio}` package. We use the `{here}` package to tell R to look for the file in the `data/` folder of your project, and `dplyr::as_tibble()` to convert into a tidier format for subsequent analysis in R.


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
- On Unix based operating systems such as macOS or Linux the forward slash ( `/` ) is used as the path separator: `"data/raw-data/file.csv"`

The `{here}` package reinforces the reproducibility of your work across multiple operating systems. If you are interested in reproducibility, we invite you to [read this tutorial to increase the openess, sustainability, and reproducibility of your epidemic analysis with R](https://epiverse-trace.github.io/research-compendium/)

::::::::::::::::::::

::::::::::::::::::::::::::::::::: challenge

###  Reading compressed data 

Can you read data from a compressed file in `R`?

Download this [zip file](https://epiverse-trace.github.io/tutorials-early/data/Marburg.zip) containing data for Marburg outbreak and then import it to your working environment.

::::::::::::::::: hint

You can check the [full list of supported file formats](https://gesistsa.github.io/rio/#supported-file-formats) 
in the `{rio}` package on the package website. To expand {rio} to the full range of supported formats run:



``` r
rio::install_formats()
```

::::::::::::::::::::::

::::::::::::::::: solution


``` r
rio::import(here::here("data", "Marburg.zip"))
```
::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::


## Reading from databases

The `{readepi}` library contains functions that allow you to import data directly from RDBMS or HIS (through their APIs). 
The `readepi::read_rdbms()` function allows you to import data from servers such as Microsoft SQL, MySQL, PostgreSQL, and SQLite. It is primarily based on the [{DBI}](https://dbi.r-dbi.org/) library, which serves as a general-purpose interface for interacting with relational database management systems (RDBMS).

::::::::::::: discussion

### When to read directly from a database?

Importing data directly from a database optimizes the memory usage in the R session. If we process the database with "queries" (e.g., select, filter, summarise) before extraction, we can reduce the memory load in our RStudio session. Conversely, conducting all data manipulation outside the database management system by loading the full dataset into R can use up much more computer memory (i.e. RAM) than is feasible on a local machine, which can lead RStudio to slow down or even freeze.

Relational database management systems (RDBMS) also have the advantage that multiple users can access, store and analyse parts of the dataset simultaneously, without having to transfer individual files, which would make it very difficult to track which version is up-to-date.

:::::::::::::

### 1. Connect with a database

You can use the `readepi::login()` function to establish a connection to the database as shown below.


``` r
# establish the connection to a test MySQL database
rdbms_login <- readepi::login(
  from = "mysql-rfam-public.ebi.ac.uk",
  type = "MySQL",
  user_name = "rfamro",
  password = "",
  driver_name = "",
  db_name = "Rfam",
  port = 4497
)
```

``` output
✔ Logged in successfully!
```

``` r
rdbms_login
```

``` output
<Pool> of MySQLConnection objects
  Objects checked out: 0
  Available in pool: 1
  Max size: Inf
  Valid: TRUE
```

:::::::::::::::: callout

For this example, access may be limited by organizational network restrictions, but it should work normally on home networks.

::::::::::::::::

### 2. Access the list of tables from the database

The `readepi::show_tables()` function can be used to access the full list of table names from a database.


``` r
# get the table names
tables <- readepi::show_tables(login = rdbms_login)

tables
```

In a database framework, you can have more than one table. Each table can belong to a specific `entity` (e.g., patients, care units, jobs). All tables will be related by a common ID or `primary key`.

### 3. Read data from a table in a database

Use the `readepi::read_rdbms()` function to import data from a table in a database. It can take an SQL query or a list of query parameters as demonstrated in the code chuk below.


``` r
# import data from the 'author' table using an SQL query
dat <- readepi::read_rdbms(
  login = rdbms_login,
  query = "select * from author"
)

# import data from the 'author' table using a list of parameters
dat <- readepi::read_rdbms(
  login = rdbms_login,
  query = list(table = "author", fields = NULL, filter = NULL)
)
```

Alternativelly, we can read the data from the `author` table using `dplyr::tbl()`.


``` r
# import data from the 'author' table using an SQL query
dat <- rdbms_login %>%
  dplyr::tbl(from = "author") %>%
  dplyr::filter(initials == "A") %>%
  dplyr::arrange(desc(author_id))

dat
```

``` output
# Source:     SQL [?? x 6]
# Database:   mysql 5.6.36-log [@mysql-rfam-public.ebi.ac.uk:/Rfam]
# Ordered by: desc(author_id)
  author_id name           last_name    initials orcid                 synonyms
      <int> <chr>          <chr>        <chr>    <chr>                 <chr>   
1        46 Roth A         Roth         A        ""                    ""      
2        42 Nahvi A        Nahvi        A        ""                    ""      
3        32 Machado Lima A Machado Lima A        ""                    ""      
4        31 Levy A         Levy         A        ""                    ""      
5        27 Gruber A       Gruber       A        "0000-0003-1219-4239" ""      
6        13 Chen A         Chen         A        ""                    ""      
7         6 Bateman A      Bateman      A        "0000-0002-6982-4660" ""      
```

If we apply `{dplyr}` verbs to this database SQLite table, these verbs will be translated to SQL queries.


``` r
# Show the SQL queries translated
dat %>%
  dplyr::show_query()
```

``` output
<SQL>
SELECT `author`.*
FROM `author`
WHERE (`initials` = 'A')
ORDER BY `author_id` DESC
```

### 4. Extract data from the database

Use `dplyr::collect()` to force computation of a database query and extract the output to your local computer.


``` r
# Pull all data down to a local tibble
dat %>%
  dplyr::collect()
```

``` output
# A tibble: 7 × 6
  author_id name           last_name    initials orcid                 synonyms
      <int> <chr>          <chr>        <chr>    <chr>                 <chr>   
1        46 Roth A         Roth         A        ""                    ""      
2        42 Nahvi A        Nahvi        A        ""                    ""      
3        32 Machado Lima A Machado Lima A        ""                    ""      
4        31 Levy A         Levy         A        ""                    ""      
5        27 Gruber A       Gruber       A        "0000-0003-1219-4239" ""      
6        13 Chen A         Chen         A        ""                    ""      
7         6 Bateman A      Bateman      A        "0000-0002-6982-4660" ""      
```

Ideally, after specifying a set of queries, we can reduce the size of the input dataset to use in the environment of our R session.

:::::::::::::::::::::: challenge

### Run SQL queries in R using dbplyr

Practice how to make relational database SQL queries using multiple `{dplyr}` verbs like `dplyr::left_join()` among tables before pulling down data to your local session with `dplyr::collect()`! 

You can also review the `{dbplyr}` R package. But for a step-by-step tutorial about SQL, we recommend you this [tutorial about data management with SQL for Ecologist](https://datacarpentry.org/sql-ecology-lesson/). You will find close to `{dplyr}`!

::::::::::::::: hint


``` r
# SELECT FEW COLUMNS FROM ONE TABLE AND LEFT JOIN WITH ANOTHER TABLE
author <- rdbms_login %>%
  dplyr::tbl(from = "author") %>%
  dplyr::select(author_id, name)

family_author <- rdbms_login %>%
  dplyr::tbl(from = "family_author") %>%
  dplyr::select(author_id, rfam_acc)

dplyr::left_join(author, family_author, keep = TRUE) %>%
  dplyr::show_query()
```

``` output
Joining with `by = join_by(author_id)`
```

``` output
<SQL>
SELECT
  `author`.`author_id` AS `author_id.x`,
  `name`,
  `family_author`.`author_id` AS `author_id.y`,
  `rfam_acc`
FROM `author`
LEFT JOIN `family_author`
  ON (`author`.`author_id` = `family_author`.`author_id`)
```

``` r
dplyr::left_join(author, family_author, keep = TRUE) %>%
  dplyr::collect()
```

``` output
Joining with `by = join_by(author_id)`
```

``` output
# A tibble: 4,874 × 4
   author_id.x name         author_id.y rfam_acc
         <int> <chr>              <int> <chr>   
 1          44 Osuch I               44 RF01571 
 2           2 Argasinska J           2 RF02588 
 3           2 Argasinska J           2 RF02587 
 4           2 Argasinska J           2 RF02586 
 5           2 Argasinska J           2 RF02585 
 6           2 Argasinska J           2 RF02549 
 7           8 Boursnell C            8 RF02002 
 8          56 Weinberg Z            56 RF01741 
 9          39 Moxon SJ              39 RF00496 
10          39 Moxon SJ              39 RF00469 
# ℹ 4,864 more rows
```


:::::::::::::::

::::::::::::::::::::::



## Reading from HIS APIs

Health data is increasingly stored in specialized HIS such as **Fingertips**, **GoData**, **REDCap**, **DHIS2**, **SORMAS**, etc. The current version of the `{readepi}` library allows importing data from **DHIS2** and **SORMAS**.

### Importing data from DHIS2

The District Health Information System [DHIS2](https://dhis2.org/about/) is an open-source software that has revolutionized global health information management. The `readepi::read_dhis2()` function allows you to import data from the DHIS2 [Tracker](https://dhis2.org/tracker-in-action/) system via their API.

To successfully import the data from DHIS2, you will need to connect to the system using the `readepi::login()` function, then provide the **name** or **ID** of the target program and organisation unit.

For a given system, you can access the IDs and names of the programs and organisation units using the `get_programs()` and `get_organisation_units()` functions, respectively.


``` r
# establish the connection to the system
dhis2_login <- readepi::login(
  from = "https://smc.moh.gm/dhis",
  user_name = "test",
  password = "Gambia@123"
)
```

``` output
✔ Logged in successfully!
```

``` r
# get the names and IDs of the programs
programs <- readepi::get_programs(login = dhis2_login)

# get the names and IDs of the organisation units
org_units <- readepi::get_organisation_units(login = dhis2_login)
```


``` r
# import data from DHIS2 using IDs
data <- readepi::read_dhis2(
  login = dhis2_login,
  org_unit = "GcLhRNAFppR",
  program = "E5IUQuHg3Mg"
)

# import data from DHIS2 using names
data <- readepi::read_dhis2(
  login = dhis2_login,
  org_unit = "Keneba",
  program = "Child Registration & Treatment "
)

tibble::as_tibble(data)
```

``` output
# A tibble: 1,116 × 69
   event   tracked_entity org_unit ` SMC-CR Scan QR Code` SMC-CR Did the child…¹
   <chr>   <chr>          <chr>    <chr>                  <chr>                 
 1 bgSDQb… yv7MOkGD23q    Keneba   SMC23-0510989          1                     
 2 y4MKmP… nibnZ8h0Nse    Keneba   SMC2021-018089         1                     
 3 yK7VG3… nibnZ8h0Nse    Keneba   SMC2021-018089         1                     
 4 EmNflz… nibnZ8h0Nse    Keneba   SMC2021-018089         1                     
 5 UF96ms… nibnZ8h0Nse    Keneba   SMC2021-018089         1                     
 6 guQTwc… FomREQ2it4n    Keneba   SMC23-0510012          1                     
 7 jbkRkL… FomREQ2it4n    Keneba   SMC23-0510012          1                     
 8 AEeype… FomREQ2it4n    Keneba   SMC23-0510012          1                     
 9 R30SPs… E5oAWGcdFT4    Keneba   koika-smc-22897        1                     
10 nr03Qy… E5oAWGcdFT4    Keneba   koika-smc-22897        1                     
# ℹ 1,106 more rows
# ℹ abbreviated name: ¹​`SMC-CR Did the child  previously received a card?`
# ℹ 64 more variables: `SMC-CR Child First Name1` <chr>,
#   `SMC-CR Child Last Name` <chr>, `SMC-CR Date of Birth` <chr>,
#   `SMC-CR Select Age Category  ` <chr>, `SMC-CR Child gender1` <chr>,
#   `SMC-CR Mother/Person responsible full name` <chr>,
#   `SMC-CR Mother/Person responsible phone number1` <chr>, …
```

It is important to know that not all organisation units are registered for a specific program. To find out which organisation units are running a particular program, use the `get_program_org_units()` function as shown in the example below.


``` r
# get the list of organisation units that run the program "E5IUQuHg3Mg"
target_org_units <- readepi::get_program_org_units(
  login = dhis2_login,
  program = "E5IUQuHg3Mg",
  org_units = org_units
)

tibble::as_tibble(target_org_units)
```

``` output
# A tibble: 26 × 3
   org_unit_ids levels            org_unit_names
   <chr>        <chr>             <chr>         
 1 UrLrbEiWk3J  Town/Village_name Sare Sibo     
 2 wlVsFVeHSTx  Town/Village_name Jawo Kunda    
 3 kp0ZYUEqJE8  Town/Village_name Chewal        
 4 Wr3htgGxhBv  Town/Village_name Madinayel     
 5 psyHoqeN2Tw  Town/Village_name Bolibanna     
 6 MGBYonFM4y3  Town/Village_name Sare Mala     
 7 GcLhRNAFppR  Town/Village_name Keneba        
 8 y1Z3KuvQyhI  Town/Village_name Brikama       
 9 W3vH9yBUSei  Town/Village_name Gidda         
10 ISbNWYieHY8  Town/Village_name Song Kunda    
# ℹ 16 more rows
```

### Importing data from SORMAS

The Surveillance Outbreak Response Management and Analysis System [SORMAS](https://sormas.org/) is an open-source e-health system that optimizes infectious disease surveillance and outbreak response processes. The `readepi::read_sormas()` function allows you to import data from SORMAS via its API.

In the current version of the `readepi` package, the `read_sormas()` function returns data for the following columns: **case_id, person_id, sex, date_of_birth, case_origin, country, city, lat, long, case_status, date_onset, date_admission, date_last_contact, date_first_contact, outcome, date_outcome, Ct_values**.

One of the fundamental arguments is the name of the disease for which the user wants to get data. To ensure the correct syntax to use when calling the function, you can get the list of disease names through the `sormas_get_diseases()` function.


``` r
# get the list of all disease names
disease_names <- readepi::sormas_get_diseases(
  base_url = "https://demo.sormas.org/sormas-rest",
  user_name = "SurvSup",
  password = "Lk5R7JXeZSEc"
)

tibble::as_tibble(disease_names)
```

``` output
# A tibble: 65 × 2
   disease            active
   <chr>              <chr> 
 1 AFP                TRUE  
 2 CHOLERA            TRUE  
 3 CONGENITAL_RUBELLA TRUE  
 4 CSM                TRUE  
 5 DENGUE             TRUE  
 6 EVD                TRUE  
 7 GUINEA_WORM        TRUE  
 8 LASSA              TRUE  
 9 MEASLES            TRUE  
10 MONKEYPOX          TRUE  
# ℹ 55 more rows
```

``` r
# import COVID-19 cases from SORMAS
covid_cases <- readepi::read_sormas(
  base_url = "https://demo.sormas.org/sormas-rest",
  user_name = "SurvSup",
  password = "Lk5R7JXeZSEc",
  disease = "coronavirus"
)

tibble::as_tibble(covid_cases)
```

``` output
# A tibble: 6 × 16
  case_id    person_id date_onset date_admission case_origin case_status outcome
  <chr>      <chr>     <date>     <date>         <chr>       <chr>       <chr>  
1 QFC5QI-GC… XNQZBX-W… NA         NA             IN_COUNTRY  NOT_CLASSI… NO_OUT…
2 UOZL3G-4M… UGBWTB-B… 2025-05-27 NA             IN_COUNTRY  SUSPECT     NO_OUT…
3 SRO72L-LY… UOAAIQ-Z… NA         NA             IN_COUNTRY  NOT_CLASSI… NO_OUT…
4 XV7RQ3-ZY… XP2SJX-W… 2025-07-03 NA             IN_COUNTRY  NOT_CLASSI… NO_OUT…
5 SMUIMI-ZI… TMWNQS-O… NA         NA             IN_COUNTRY  CONFIRMED   NO_OUT…
6 SZ3GHH-RJ… V2XMXK-K… NA         NA             IN_COUNTRY  NOT_CLASSI… NO_OUT…
# ℹ 9 more variables: sex <chr>, date_of_birth <chr>, country <chr>,
#   city <chr>, latitude <chr>, longitude <chr>, contact_id <chr>,
#   date_last_contact <date>, Ct_values <chr>
```

::::::::::::::::::::::::::::::::::::: keypoints 
- Use `{rio}`, `{io}`, `{readr}` and `{ImportExport}` to read data from individual files.
- Use `{readepi}` to read data form HIS APIs and RDBMS.
::::::::::::::::::::::::::::::::::::::::::::::::
