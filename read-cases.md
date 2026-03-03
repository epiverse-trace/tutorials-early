---
title: 'Read case data'
teaching: 20
exercises: 10
editor_options: 
  chunk_output_type: inline
---

:::::::::::::::::::::::::::::::::::::: questions 

- Where do you usually store outbreak data?
- What data formats do you commonly use for analysis? 
- Can you import data directly from servers and health information systems? 
::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Identify common sources of outbreak data. 
- Import outbreak data from multiple formats into  `R` environment.
- Access and retrieve data from remote servers and health information systems using APIs.
::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: prereq

## Prerequisites

This episode requires you to be familiar with **Data science**: [Basic tasks with R](https://www.epirhandbook.com/en/new_pages/basics.html).


:::::::::::::::::::::::::::::::::

## Introduction

The first step in outbreak analysis is importing your dataset into the `R` environment. Data can come from local sources, like files on your computer, or external sources, like databases and health information systems (HIS). 

Outbreak data takes many forms. It may be sorted as a flat file in various formats, housed in relational database management systems (RDBMS), or managed through specialized HIS like  [SORMAS](https://sormas.org/) and [DHIS2](https://dhis2.org/). These HISs offer application programming interfaces (APIs) that allow authorized users to modify and retrieve data entries efficiently, making them particularly valuable for large-scale institutional health data collection and storage.

This episode demonstrates how to read case data from each of these sources. Let's begin by loading the packages we'll need. We will use `{rio}` to read data stored in files and `{readepi}` to access data from RDBMS and HIS. We will also load `{here}` to locate file paths within your project directory, and `{tidyverse}`, which includes `{magrittr}` (providing the pipe operator `%>%`) and `{dplyr}` (for data manipulation). The pipe operator allows us to chain functions together seamlessly.


``` r
# Load packages
library(tidyverse) # for {dplyr} functions and the pipe %>%
library(rio) # for importing data from files
library(here) # for easy file referencing
library(readepi) # for importing data directly from RDBMS or HIS
library(dbplyr) # for a database backend for {dplyr}
```

::::::::::::::::::: checklist

### The double-colon (`::`) operator

The double-colon `::` in `R` lets you call a specific function from a package without loading the entire package. For example, `dplyr::filter(data, condition)` uses the `filter()` function from the `{dplyr}` package, without requiring `library(dplyr)`.

This notation serves two purposes: it makes code more readable by explicitly showing which package each function comes from, and it prevents namespace conflicts that occur when multiple packages contain functions with the same name.

:::::::::::::::::::


:::::::::: prereq

### Setup a project and folder

- Create an RStudio project. If needed, follow this [how-to guide on "Hello RStudio Projects"](https://docs.posit.co/ide/user/ide/get-started/#hello-rstudio-projects) to create one.
- Inside the RStudio project, create a `data/` folder.
- Download [ebola_cases_2.csv](https://epiverse-trace.github.io/tutorials-early/data/ebola_cases_2.csv) and [marburg.zip](https://epiverse-trace.github.io/tutorials-early/data/Marburg.zip) CSV files, and save them inside the `data/` folder.

::::::::::

## Reading from files 

Several packages are available for importing outbreak data stored in individual files into `R`. These include [{rio}](https://gesistsa.github.io/rio/), [{readr}](https://readr.tidyverse.org/) from the `{tidyverse}`, [{io}](https://bitbucket.org/djhshih/io/src/master/), [{ImportExport}](https://cran.r-project.org/web/packages/ImportExport/index.html), and [{data.table}](https://rdatatable.gitlab.io/data.table/). Together, these packages offer methods to read single or multiple files in a wide range of formats.

The below example shows how to import a `csv` file into `R` environment using the `{rio}` package. We use the `{here}` package to tell R to look for the file in the `data/` folder of your project, and `dplyr::as_tibble()` to convert into a tidier format for subsequent analysis in R.


``` r
# read data
# e.g., if the path to our file is "data/raw-data/ebola_cases_2.csv" then:
ebola_confirmed <- rio::import(
  here::here("data", "raw-data", "ebola_cases_2.csv")
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

You can use the same approach to import other file formats such as `tsv`, `xlsx`, and more.

:::::::::::::::::::: checklist

### Why should we use the {here} package?

The `{here}` package is designed to simplify file referencing in R projects by providing a reliable way to construct file paths relative to the project root. The main reason to use is for **cross-environment compatibility**.

It works across different operating systems (Windows, Mac, Linux) without needing to adjust file paths. 

- On Windows, paths are written using backslashes ( `\` ) as the separator between folder names: `"data\raw-data\file.csv"` .
- On Unix based operating systems such as macOS or Linux the forward slash ( `/` ) is used as the path separator: `"data/raw-data/file.csv"`.

The `{here}` package reinforces the reproducibility of your work across multiple operating systems. If you are interested in reproducibility, we invite you to read this tutorial to increase the [openess, sustainability, and reproducibility of your epidemic analysis with R](https://epiverse-trace.github.io/research-compendium/)

::::::::::::::::::::

::::::::::::::::::::::::::::::::: challenge

###  Reading compressed data 

Can you read data from a compressed file in `R`?

Download this [zip file](https://epiverse-trace.github.io/tutorials-early/data/Marburg.zip) containing Marburg outbreak data and then import it to your `R` environment.

::::::::::::::::: hint

You can check the [full list of supported file formats](https://gesistsa.github.io/rio/#supported-file-formats) 
in the `{rio}` package on the package website. To see the list of supported formats in `{rio}`, run:



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

The `{readepi}` library contains functions that allow you to import data directly from RDBMS.
The `readepi::read_rdbms()` function supports importing data from servers such as Microsoft SQL, MySQL, PostgreSQL, and SQLite. It build on the [{DBI}](https://dbi.r-dbi.org/) package, which provides a general interface for interacting RDBMS.

::::::::::::: discussion

### Advantages of reading data directly from a database?

Importing data directly from a database optimizes the memory usage in the R session. By processing the database with "queries" (e.g., SELECT, FILTER, GROUP BY) before extraction, you reduce the memory load in our RStudio session. In contrast, loading an entire dataset into R for manipulation can consume more RAM than your local machine can handle, potentially causing RStudio to slow down or freeze.

RDBMS also enable multiple users to access, store, and analyze parts of the dataset simultaneously without transferring individual files. This eliminates the version control problems that arise when multiple file copies circulate among users.

:::::::::::::

### 1. Connect with a database

You can use the `readepi::login()` function to establish a connection to the database, as shown below:


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

The function parameters are:

- `from`: The database server address (`mysql-rfam-public.ebi.ac.uk`)
- `type`: The type of database system ("MySQL")
- `user_name`: The username for authentication ("rfamro")
- `password`: The password (empty string "" indicates no password required for this public test database)
- `driver_name`: The database driver (empty string uses the default driver)
- `db_name`: The specific database to connect to ("Rfam")
- `port`: The port number for the connection (4497)

The function returns a connection object stored in variable `rdbms_login`, which can then be used to query and retrieve data from the database.

:::::::::::::::: callout

Note: This example uses a public test database from the European Bioinformatics Institute, which is why no password is required.  Access to it may be limited by organizational network restrictions, but it should work normally on home networks.

::::::::::::::::

### 2. Access the list of tables from the database

The `readepi::show_tables()` function retrieves the full list of table names from a database:


``` r
# get the table names
tables <- readepi::show_tables(login = rdbms_login)

tables
```

In a relational database, you typically have multiple tables. Each table represents a specific entity (e.g., patients, care units, treatments). Tables are linked through common identifiers called primary keys or foreign keys.

### 3. Read data from a table in a database

Use the `readepi::read_rdbms()` function to import data from a database table. It accepts either an SQL query or a list of query parameters, as demonstrated in the code chunk below.


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

Alternatively, you can read the data from the `author` table using `dplyr::tbl()`.


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
# Database:   mysql 8.0.32-24 [@mysql-rfam-public.ebi.ac.uk:/Rfam]
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

When you apply `{dplyr}` verbs to this database table, they are automatically translated into SQL queries:


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

### Run SQL queries in R using {dbplyr}

Practice how to make relational database SQL queries using multiple `{dplyr}` verbs like `dplyr::left_join()` among tables before pulling out data to your local session with `dplyr::collect()`! 

You can also review the `{dbplyr}` R package. But for a step-by-step tutorial about SQL, we recommend you this [tutorial about data management with SQL for Ecologist](https://datacarpentry.org/sql-ecology-lesson/).

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
# A tibble: 5,029 × 4
   author_id.x name         author_id.y rfam_acc
         <int> <chr>              <int> <chr>   
 1           1 Ames T                 1 RF01831 
 2           2 Argasinska J           2 RF02554 
 3           2 Argasinska J           2 RF02555 
 4           2 Argasinska J           2 RF02722 
 5           2 Argasinska J           2 RF02720 
 6           2 Argasinska J           2 RF02719 
 7           2 Argasinska J           2 RF02721 
 8           2 Argasinska J           2 RF02670 
 9           2 Argasinska J           2 RF02718 
10           2 Argasinska J           2 RF02668 
# ℹ 5,019 more rows
```


:::::::::::::::

::::::::::::::::::::::



## Reading from HIS APIs

Health data is increasingly stored in specialized HIS such as **Fingertips**, **GoData**, **REDCap**, **DHIS2**, **SORMAS**, etc. The current version of the `{readepi}` library allows importing data from **DHIS2** and **SORMAS**. The subsections below demonstrate how to import data from these two systems.

### Importing data from DHIS2

[DHIS2](https://dhis2.org/about/) (District Health Information System) is an open-source software that has revolutionized global health information management. The `readepi::read_dhis2()` function imports data from the DHIS2 [Tracker](https://dhis2.org/tracker-in-action/) system via its API.

To successfully import data from DHIS2, you need to:

1. Connect to the system using the `readepi::login()` function
2. Provide the name or ID of the target program and organization unit

You can retrieve the IDs and names of available programs and organization units using the `get_programs()` and `get_organisation_units()` functions, respectively.


``` r
# establish the connection to the system
dhis2_login <- readepi::login(
  type = "dhis2",
  from = "https://smc.moh.gm/dhis",
  user_name = "test",
  password = "Gambia@123"
)

# get the names and IDs of the programs
programs <- readepi::get_programs(login = dhis2_login)
tibble::as_tibble(programs)
```

``` output
# A tibble: 2 × 3
  displayName                       id          type     
  <chr>                             <chr>       <chr>    
1 "Child Registration & Treatment " E5IUQuHg3Mg tracker  
2 "Daily Drug Reconciliations"      I3bZrR6fLt8 aggregate
```




``` r
# get the names and IDs of the organisation units
org_units <- readepi::get_organisation_units(login = dhis2_login)
tibble::as_tibble(org_units)
```

``` output
# A tibble: 872 × 10
   National_name National_id Regional_name Regional_id District_name District_id
   <chr>         <chr>       <chr>         <chr>       <chr>         <chr>      
 1 Gambia        jvQPTsCLwPh Central Rive… gsMpbz5DQsM "Upper fulla… srjR5LWAoBD
 2 Gambia        jvQPTsCLwPh Western Regi… D18zNdCbRfO "Foni Jarrol… kAxFyJFfYV8
 3 Gambia        jvQPTsCLwPh Upper River … SHRxQEqOPJa "Sandu"       iZQOFwckdXL
 4 Gambia        jvQPTsCLwPh Central Rive… gsMpbz5DQsM "Upper fulla… srjR5LWAoBD
 5 Gambia        jvQPTsCLwPh Upper River … SHRxQEqOPJa "Basse (Full… Ug7sj97icMt
 6 Gambia        jvQPTsCLwPh Upper River … SHRxQEqOPJa "Basse (Full… Ug7sj97icMt
 7 Gambia        jvQPTsCLwPh Central Rive… gsMpbz5DQsM "Sami"        ZZNUH1LhS7k
 8 Gambia        jvQPTsCLwPh Western Regi… D18zNdCbRfO "Foni Jarrol… kAxFyJFfYV8
 9 Gambia        jvQPTsCLwPh Central Rive… gsMpbz5DQsM "Niamina Dan… T55lst07vTj
10 Gambia        jvQPTsCLwPh Upper River … SHRxQEqOPJa "Tumana"      xGYsUdiJb4L
# ℹ 862 more rows
# ℹ 4 more variables: `Operational Zone_name` <chr>,
#   `Operational Zone_id` <chr>, `Town/Village_name` <chr>,
#   `Town/Village_id` <chr>
```

After retrieving organization units and program names from the DHIS2 database, we can import data using either names or coded IDs, as demonstrated in the code chunk below


``` r
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


``` r
# import data from DHIS2 using names
# import data from DHIS2 using IDs
data <- readepi::read_dhis2(
  login = dhis2_login,
  org_unit = "GcLhRNAFppR",
  program = "E5IUQuHg3Mg"
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

Note that not all organization units are registered for a specific program. To find which organization units are running a particular program, use the `get_program_org_units()` function as shown below:


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

:::::::::::::::: callout

Note: This example uses a DHIS2 system provided by the Ministry of Health of The Gambia for testing and development purposes. In practice, you should customize the parameters for your own DHIS2 instance. 

::::::::::::::::


:::::::::::::::::::::: challenge

### Reading from Demo DHIS2 sever

The DHIS2 organization provides demo servers for development and testing. One of
these is called **stable-242-4**, available at the link
("https://play.im.dhis2.org/stable-2-42-4"), and accessible with username "admin" and password "district". Log into this server, list all available programs and organization units, and read data from one of these programs.

::::::::::::::: solution


``` r
# establish the connection to the system
demo_login <- readepi::login(
  type = "dhis2",
  from = "https://play.im.dhis2.org/stable-2-42-4",
  user_name = "admin",
  password = "district"
)

# get the names and IDs of the programs
demo_programs <- readepi::get_programs(login = demo_login)
tibble::as_tibble(demo_programs)
```

``` output
# A tibble: 15 × 3
   displayName                                         id          type     
   <chr>                                               <chr>       <chr>    
 1 Antenatal care visit                                lxAQ7Zs9VYR aggregate
 2 Child Programme                                     IpHINAT79UW tracker  
 3 Contraceptives Voucher Program                      kla3mAPgvCH aggregate
 4 Information Campaign                                q04UBOqq3rp aggregate
 5 Inpatient morbidity and mortality                   eBAyeGv0exc aggregate
 6 Into the Realm of Yuggoth                           YEqwML0PmmJ tracker  
 7 Malaria case diagnosis, treatment and investigation qDkgAbB5Jlk tracker  
 8 Malaria case registration                           VBqh0ynB2wv aggregate
 9 Malaria focus investigation                         M3xtLkYBlKI tracker  
10 Malaria testing and surveillance                    bMcwwoVnbSR aggregate
11 MNCH / PNC (Adult Woman)                            uy2gU8kT1jF tracker  
12 Provider Follow-up and Support Tool                 fDd25txQckK tracker  
13 TB program                                          ur1Edk5Oe2n tracker  
14 WHO RMNCH Tracker                                   WSGAb5XwJ3Y tracker  
15 XX MAL RDT - Case Registration                      MoUd5BTQ3lY aggregate
```


``` r
# get the names and IDs of the organisation units
demo_units <- readepi::get_organisation_units(login = demo_login)
tibble::as_tibble(demo_units)
```

``` output
# A tibble: 1,166 × 8
   National_name National_id District_name District_id Chiefdom_name Chiefdom_id
   <chr>         <chr>       <chr>         <chr>       <chr>         <chr>      
 1 Sierra Leone  ImspTQPwCqd Western Area  at6UHUQatSo Rural Wester… qtr8GGlm4gg
 2 Sierra Leone  ImspTQPwCqd Western Area  at6UHUQatSo Rural Wester… qtr8GGlm4gg
 3 Sierra Leone  ImspTQPwCqd Bo            O6uvpzGd5pu Kakua         U6Kr7Gtpidn
 4 Sierra Leone  ImspTQPwCqd Kambia        PMa2VCrupOd Magbema       QywkxFudXrC
 5 Sierra Leone  ImspTQPwCqd Tonkolili     eIQbndfxQMb Yoni          NNE0YMCDZkO
 6 Sierra Leone  ImspTQPwCqd Port Loko     TEQlaapDQoK Kaffu Bullom  vn9KJsLyP5f
 7 Sierra Leone  ImspTQPwCqd Koinadugu     qhqAxPSTUXp Nieni         J4GiUImJZoE
 8 Sierra Leone  ImspTQPwCqd Western Area  at6UHUQatSo Freetown      C9uduqDZr9d
 9 Sierra Leone  ImspTQPwCqd Western Area  at6UHUQatSo Freetown      C9uduqDZr9d
10 Sierra Leone  ImspTQPwCqd Kono          Vth0fbpFcsO Gbense        TQkG0sX9nca
# ℹ 1,156 more rows
# ℹ 2 more variables: Facility_name <chr>, Facility_id <chr>
```

:::::::::::::::

::::::::::::::::::::::


### Importing data from SORMAS

The [SORMAS](https://sormas.org/) (Surveillance Outbreak Response Management and Analysis System) is an open-source e-health system that optimizes infectious disease surveillance and outbreak response processes. The `readepi::read_sormas()` function allows you to import data from SORMAS via its API.

In the current version of the `{readepi}` package, the `read_sormas()` function returns data for the following columns: **case_id, person_id, sex, date_of_birth, case_origin, country, city, lat, long, case_status, date_onset, date_admission, date_last_contact, date_first_contact, outcome, date_outcome**, and **Ct_values**.

The code chunk below demonstrates how to import data from a demo SORMAS system:


``` r
# CONNECT TO THE SORMAS SYSTEM
sormas_login <- readepi::login(
  type = "sormas",
  from = "https://demo.sormas.org/sormas-rest",
  user_name = "SurvSup",
  password = "Lk5R7JXeZSEc"
)

# FETCH ALL COVID (Corona virus) CASES FROM THE TEST SORMAS INSTANCE
covid_cases <- readepi::read_sormas(
  login = sormas_login,
  disease = "coronavirus",
)
tibble::as_tibble(covid_cases)
```

``` output
# A tibble: 1 × 15
  case_id             person_id date_onset case_origin case_status outcome sex  
  <chr>               <chr>     <date>     <chr>       <chr>       <chr>   <chr>
1 VPMCMM-YUZENC-P3JN… U2BJQK-M… 2025-11-01 IN_COUNTRY  SUSPECT     DECEAS… <NA> 
# ℹ 8 more variables: date_of_birth <chr>, country <chr>, city <chr>,
#   latitude <chr>, longitude <chr>, contact_id <chr>,
#   date_last_contact <date>, Ct_values <chr>
```

A key parameter is the disease name. To ensure correct syntax, you can retrieve the list of available disease names using the `sormas_get_diseases()` function.


``` r
# get the list of all disease names
disease_names <- readepi::sormas_get_diseases(
  login = sormas_login
)

tibble::as_tibble(disease_names)
```

``` output
# A tibble: 67 × 2
   disease            active
   <chr>              <chr> 
 1 AFP                TRUE  
 2 CHOLERA            TRUE  
 3 CONGENITAL_RUBELLA TRUE  
 4 DENGUE             TRUE  
 5 EVD                TRUE  
 6 GUINEA_WORM        TRUE  
 7 LASSA              TRUE  
 8 MEASLES            TRUE  
 9 MONKEYPOX          TRUE  
10 NEW_INFLUENZA      TRUE  
# ℹ 57 more rows
```


:::::::::::::::::::::: challenge
### Reading from Demo SORMAS sever

The SORMAS organization also provides demo servers for development and testing. One of
these is called **clinical surveillance**, available at the link
("https://demo.sormas.org/sormas-rest"), and accessible with username "CaseSup" and password "SJgFKffPDmr7". Log into this server, list all available diseases, and import cases related to the monkeypox (mpox) disease.

::::::::::::::: solution


``` r
# establish the connection to the system
sormas_demo <- readepi::login(
  type = "sormas",
  from = "https://demo.sormas.org/sormas-rest",
  user_name = "CaseSup",
  password = "SJgFKffPDmr7"
)

# List the names of all disease
demo_diseases <- readepi::sormas_get_diseases(login = sormas_demo)
tibble::as_tibble(demo_diseases)
```

``` output
# A tibble: 67 × 2
   disease            active
   <chr>              <chr> 
 1 AFP                TRUE  
 2 CHOLERA            TRUE  
 3 CONGENITAL_RUBELLA TRUE  
 4 DENGUE             TRUE  
 5 EVD                TRUE  
 6 GUINEA_WORM        TRUE  
 7 LASSA              TRUE  
 8 MEASLES            TRUE  
 9 MONKEYPOX          TRUE  
10 NEW_INFLUENZA      TRUE  
# ℹ 57 more rows
```


``` r
# get the list of all disease names
mpox_cases <- readepi::read_sormas(
  login = sormas_demo,
  disease = "monkeypox",
)
```

``` warning
Warning in as.POSIXct(as.numeric(x), origin = "1970-01-01"): NAs introduced by
coercion
```

``` r
tibble::as_tibble(mpox_cases)
```

``` output
# A tibble: 1 × 15
  case_id             person_id date_onset case_origin case_status outcome sex  
  <chr>               <chr>     <date>     <chr>       <chr>       <chr>   <chr>
1 WQLS6O-ZEZ562-MAGM… WVADAF-S… NA         IN_COUNTRY  PROBABLE    NO_OUT… <NA> 
# ℹ 8 more variables: date_of_birth <chr>, country <chr>, city <chr>,
#   latitude <chr>, longitude <chr>, contact_id <chr>,
#   date_last_contact <date>, Ct_values <chr>
```

:::::::::::::::

::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::: keypoints 

- Use `{rio}`, `{io}`, `{readr}` or `{ImportExport}` to read data from individual files.
- Use `{readepi}` to read data from RDBMS and HIS.
- The {rio} package supports a wide range of file formats including `CSV`, `TSV`, `XLSX`, and compressed files.
- Use `readepi::login()` to establish connections to RDBMS, DHIS2, or SORMAS systems.
- The `{readepi}` package currently supports importing data from DHIS2 and SORMAS health information systems.

::::::::::::::::::::::::::::::::::::::::::::::::
