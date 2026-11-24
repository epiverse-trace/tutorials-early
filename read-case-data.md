---
title: 'Read case data'
teaching: 20
exercises: 10
    # jarl-ignore string_boundary: <reason>
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
  from = "genome-mysql.soe.ucsc.edu",
  type = "MySQL",
  user_name = "genome",
  password = "",
  driver_name = "",
  db_name = "hgFixed",
  port = 3306
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

- `from`: The database server address (`genome-mysql.soe.ucsc.edu`)
- `type`: The type of database system ("MySQL")
- `user_name`: The username for authentication ("genome")
- `password`: The password (empty string "" indicates no password required for this public test database)
- `driver_name`: The database driver (empty string uses the default driver)
- `db_name`: The specific database to connect to ("hgFixed")
- `port`: The port number for the connection (3306)

The function returns a connection object stored in variable `rdbms_login`, which can then be used to query and retrieve data from the database.

:::::::::::::::: callout

Note: This example uses a public test database from the University of California, Santa Cruz (UCSC) Genome Browser project, which is why no password is required. It uses the standard MySQL port (3306), so it is less likely to be blocked than test servers on non-standard ports, but access could still be limited by strict organizational network restrictions.

::::::::::::::::

### 2. Access the list of tables from the database

The `readepi::show_tables()` function retrieves the full list of table names from a database:


``` r
# get the table names
tables <- readepi::show_tables(login = rdbms_login)

tables[1:5]
```

``` output
[1] "affy10KDetails"  "affy120KDetails" "affyExps"        "affyGenoDetails"
[5] "arbFlyLifeAll"  
```

In a relational database, you typically have multiple tables. Each table represents a specific entity (e.g., patients, care units, treatments). Tables are linked through common identifiers called primary keys or foreign keys.

### 3. Read data from a table in a database

You can read the data from the `author` table using `dplyr::tbl()`. This table lists
authors of GenBank sequence submissions, with each `name` stored as `"LastName,F.I."`.


``` r
# import data from the 'author' table using an SQL query
dat <- rdbms_login %>%
  dplyr::tbl(from = "author") %>%
  dplyr::filter(stringr::str_sub(string = name, start = 1, end = 1) == "A") %>%
  dplyr::slice_sample(n = 20) %>% 
  dplyr::arrange(desc(id))

dat
```

``` output
# A query:    ?? x 3
# Database:   mysql 5.5.5-10.11.8-MariaDB [@genome-mysql.soe.ucsc.edu:/hgFixed]
# Ordered by: desc(id)
       id name                                                               crc
    <int> <chr>                                                            <dbl>
 1 330871 Amal H, Gong G, Gjoneska E, Lewis SM, Wishnok JS, Tsai LH and … 3.58e9
 2 322312 Asman,A.K.M., Curtis,B.A. and Archibald,J.M.                    2.54e9
 3 305353 Abe H, Jitsuki S, Nakajima W, Murata Y, Jitsuki-Takahashi A, K… 3.98e9
 4 296021 Almeida FF, Tenno M, Brzostek J, Li JL, Allies G, Hoeffel G, S… 1.32e9
 5 265798 Ando A, Shigenari A, Kulski JK, Renard C, Chardon P, Shiina T … 3.51e9
 6 261910 Albuquerque,L., Rainey,F.A., Chung,A.P., Sunna,A., Nobre,M.F.,… 3.22e9
 7 251016 Aldea,D., Jones,J. and Mead,J.                                  3.86e9
 8 199440 Adams,I.P. and Braidwood,L.A.                                   2.60e9
 9 184303 Abd El Hamid,M.I., El Zeedy,S.A., El Sanousi,A.A. and Reda,I.M. 5.99e8
10 179410 Amaral,H.A., Soares,R.M., Cortez,A., Durigon,E.L., Funada,M.R.… 2.39e9
11 173094 Abo Hatab,E.M., Hussein,H.A., El-Sabagh,I.M. and Saber,M.S.     2.40e9
12 172335 Auguste,A.J., Adams,A.P., Arrigo,N.C., Martinez,R., Travassos … 9.99e8
13 158962 Akhtar,I., Gold,J.P., Pan,L.Y., Ferrara,J.L., Yang,X.D., Kim,J… 1.50e8
14 141323 Aiba,Y.                                                         4.07e5
15 121053 Achen,M.G., Jeltsch,M., Kukk,E., Makinen,T., Vitali,A., Wilks,… 3.99e9
16  48262 Adams,T.E.                                                      2.58e7
17  47806 Adams,T.E., Baker,L., Fiddes,R.J. and Brandon,M.R.              3.92e9
18  32880 Abalde,S., Tenorio,M.J., Afonso,C.M. and Zardoya,R.             2.40e9
19  15737 Asadulina,A., Panzera,A., Veraszto,C., Liebig,C. and Jekely,G.  2.75e9
20  12187 Alliegro,M.A., Henry,J.J. and Alliegro,M.C.                     2.77e9
```

When you apply `{dplyr}` verbs to this database table, they are automatically translated into SQL queries:


``` r
# Show the SQL queries translated
dat %>%
  dplyr::show_query()
```

``` output
<SQL>
SELECT `id`, `name`, `crc`
FROM (
  SELECT
    *,
    CASE
WHEN (NOT(((RAND()) IS NULL))) THEN ROW_NUMBER() OVER (PARTITION BY (CASE WHEN (((RAND()) IS NULL)) THEN 1 ELSE 0 END) ORDER BY RAND())
END AS `col01`
  FROM `author`
  WHERE (SUBSTR(`name`, 1, 1) = 'A')
) AS `q01`
WHERE (`col01` <= 20)
ORDER BY `id` DESC
```

Alternatively, you can use the `readepi::read_rdbms()` function to import data from a database table. It accepts either an SQL query or a list of query parameters.

### 4. Extract data from the database

Use `dplyr::collect()` to force computation of a database query and extract the output to your local computer.


``` r
# Pull all data down to a local tibble
dat %>%
  dplyr::collect()
```

``` output
# A tibble: 20 × 3
       id name                                                               crc
    <int> <chr>                                                            <dbl>
 1 361723 Andergassen D, Smith ZD, Lewandowski JP, Gerhardinger C, Meiss… 3.30e9
 2 335333 Alici,E.                                                        1.65e6
 3 333001 Ali,M.R., Alam,A.S.M.R.U., Amin,M.A., Siddique,M.A., Sultana,M… 3.95e9
 4 330823 Aydin HA, Toptas T, Bozkurt S, Aydin A, Erdogan G, Pestereli E… 1.40e9
 5 329222 Amin,A.K., Tanaka,M., Al-Saari,N., Feng,G., Mino,S., Ogura,Y.,… 3.82e9
 6 282424 Abrol N, de Tombe PP and Robia SL.                              6.23e7
 7 259256 Albuquerque,L., Tiago,I., Nobre,M.F., Verissimo,A. and da Cost… 3.22e9
 8 246757 Adomas,A., Sun,H. and Asiegbu,F.O.                              3.92e9
 9 246327 Adhikari,B.N., Wall,D.H. and Adams,B.J.                         2.39e9
10 234551 Arocas,V., Castro,H.C., Zingali,R.B., Guillin,M.C., Jandrot-Pe… 2.75e9
11 233315 Avdic,S. and Broady,K.W.                                        9.81e8
12 182243 Adkar-Purushothama,C.R., Kanchepalli,P.R., Yanjarappa,S.M., Zh… 6.41e8
13 161114 Amor-Gueret,M. and Levi-Strauss,M.                              3.91e9
14  96026 Assarehzadegan,M.A., Sankian,M., Jabbari,F., Tehrani,M. and Va… 9.98e8
15  89908 Asturias,J.A., Ibarrola,I., Fernandez,J., Arilla,M.C., Gonzale… 9.89e8
16  85051 Appel,M., Burger,A.L. and Bellstedt,D.U.                        2.43e9
17  73579 Adnan,S., Susan,L. and Weiss,D.                                 3.10e9
18  53129 Aartsma-rus,A., Platenburg,G.J., Kimpe,J.J.D., Deutekom,J.C.T.… 3.97e9
19  47967 Abdul,F., Filleton,F., Gerossier,L., Paturel,A., Hall,J., Stru… 2.39e9
20  23845 Adell,T. and Muller,W.E.                                        9.93e8
```

Ideally, after specifying a set of queries, we can reduce the size of the input dataset to use in the environment of our R session.

:::::::::::::::::::::: challenge

### Run SQL queries in R using {dbplyr}

Create one table containing:

- the column `name` from table `author`,
- the column `acc` from table `gbCdnaInfo`, and
- using the author's `id` as primary key or common identifier.

Following these steps:

- Use `{dplyr}` verbs to select column and join tables,
- Print the relational database SQL queries, and
- Pull out data to your local session.

::::::::::::::: hint

Join columns from two different tables:

- From the table `author`, select `id` and `name`, keeping only a handful of rows
  (e.g. authors whose surname starts with `"A"`) — `gbCdnaInfo` covers every GenBank
  submission ever made, so narrowing `author` down first keeps the join fast.
- From the table `gbCdnaInfo`, select `author` (the foreign key to `author$id`) and `acc`.
- Join to the table `author` the table `gbCdnaInfo` using `dplyr::left_join()`, matching
  `author$id` to `gbCdnaInfo$author` — note the join columns have **different names**, so
  you'll need `by = c("id" = "author")` rather than relying on a shared column name.
- Print the SQL query using `dplyr::show_query()`
- collect the joined output using `dplyr::collect()`

:::::::::::::::

::::::::::::::: solution


``` r
# SELECT FEW COLUMNS FROM ONE TABLE AND LEFT JOIN WITH ANOTHER TABLE
author <- rdbms_login %>%
  dplyr::tbl(from = "author") %>%
  dplyr::filter(stringr::str_sub(string = name, start = 1, end = 1) == "A") %>%
  dplyr::slice_sample(n = 5) %>%
  dplyr::select(id, name)

gb_cdna_info <- rdbms_login %>%
  dplyr::tbl(from = "gbCdnaInfo") %>%
  dplyr::select(author, acc)

dplyr::left_join(
  x = author,
  y = gb_cdna_info,
  by = c("id" = "author"),
  keep = TRUE
) %>%
  dplyr::show_query()
```

``` output
<SQL>
SELECT `LHS`.*, `author`, `acc`
FROM (
  SELECT `id`, `name`
  FROM (
    SELECT
      *,
      CASE
WHEN (NOT(((RAND()) IS NULL))) THEN ROW_NUMBER() OVER (PARTITION BY (CASE WHEN (((RAND()) IS NULL)) THEN 1 ELSE 0 END) ORDER BY RAND())
END AS `col01`
    FROM `author`
    WHERE (SUBSTR(`name`, 1, 1) = 'A')
  ) AS `q01`
  WHERE (`col01` <= 5)
) AS `LHS`
LEFT JOIN `gbCdnaInfo`
  ON (`LHS`.`id` = `gbCdnaInfo`.`author`)
```

``` r
dplyr::left_join(
  x = author,
  y = gb_cdna_info,
  by = c("id" = "author"),
  keep = TRUE
) %>%
  dplyr::collect()
```

``` output
# A tibble: 25 × 4
       id name                                                      author acc  
    <int> <chr>                                                      <dbl> <chr>
 1 293148 Alvarez E, Zhou W, Witta SE and Freed CR.                 293148 NM_0…
 2 146496 An,G., Dong,N., Shao,B., Zhu,M. and Ruan,C.               146496 AF35…
 3 146496 An,G., Dong,N., Shao,B., Zhu,M. and Ruan,C.               146496 AF35…
 4 143958 Airenne,T., Lin,Y., Olsson,M., Ekblom,P., Vainio,S. and … 143958 AF10…
 5 211525 Azizi,A., Couto,N., Banister,K. and Diaz-Mitoma,F.        211525 EF61…
 6 361395 Armenteros-Monterroso E, Zhao L, Gasparoli L, Brooks T, … 361395 NM_0…
 7 361395 Armenteros-Monterroso E, Zhao L, Gasparoli L, Brooks T, … 361395 NM_0…
 8 361395 Armenteros-Monterroso E, Zhao L, Gasparoli L, Brooks T, … 361395 NM_0…
 9 361395 Armenteros-Monterroso E, Zhao L, Gasparoli L, Brooks T, … 361395 NR_1…
10 361395 Armenteros-Monterroso E, Zhao L, Gasparoli L, Brooks T, … 361395 NM_0…
# ℹ 15 more rows
```

You can also review the `{dbplyr}` R package. But for a step-by-step tutorial about SQL, we recommend you this [tutorial about data management with SQL for Ecologist](https://datacarpentry.org/sql-ecology-lesson/).

:::::::::::::::

::::::::::::::::::::::

We can close the connection to the database with:


``` r
pool::poolClose(rdbms_login)
```

:::::::::: spoiler

You can confirm the connection closed running the created objects in console:


``` r
rdbms_login
```

``` output
<Pool> of MySQLConnection objects
  Objects checked out: 0
  Available in pool: 0
  Max size: Inf
  Valid: FALSE
```

``` r
dat
```

``` error
Error in `poolCheckout()` at pool/R/pool-methods.R:136:3:
! The pool has been closed.
```

::::::::::

## Reading from HIS APIs

Health data is increasingly stored in specialized HIS such as **Fingertips**, **GoData**, **REDCap**, **DHIS2**, **SORMAS**, etc. The current version of the `{readepi}` library allows importing data from **DHIS2** and **SORMAS**. The subsections below demonstrate how to import data from these two systems.

### Importing data from DHIS2

[DHIS2](https://dhis2.org/about/) (District Health Information System 2) is an open-source software that has revolutionized global health information management. The `readepi::read_dhis2()` function imports data from the DHIS2 [Tracker](https://dhis2.org/tracker-in-action/) system via its API.

To successfully import data from DHIS2, you need to:

1. Connect to the system using the `readepi::login()` function
2. Provide the name or ID of the target program and organization unit

You can retrieve the IDs and names of available programs and organization units using the `get_programs()` and `get_organisation_units()` functions, respectively.


``` r
# establish the connection to the system
dhis2_login <- readepi::login(
  type = "dhis2",
  from = "https://play.im.dhis2.org/stable-2-42-6",
  user_name = "admin",
  password = "district"
)
```

``` error
Error in `httr2::req_perform()` at readepi/R/read_dhis2-helpers.R:57:3:
! HTTP 404 Not Found.
```

``` r
dhis2_login
```

``` output
function(base_url,
                        user_name,
                        password) {
  target_url <- file.path(base_url, "api", "me")
  resp <- httr2::request(target_url) |>
    httr2::req_auth_basic(user_name, password) |>
    httr2::req_perform()
  cli::cli_alert_success("Logged in successfully!")
  return(invisible(resp))
}
<bytecode: 0x5623a17df818>
<environment: namespace:readepi>
```

If the step above fails, check for others available in the list of [DHIS2 Demo Instances](https://im.dhis2.org/public/instances), all accessible with username `"admin"` and password `"district"`. Just replace `stable-2-42-6` in the URL string. The only conditions is that it must be of version equal or lower than `2.42`.

::::::: caution

Avoid publishing your USER NAME and PASSWORD. You could use `{rstudioapi}`:


``` r
dhis2_login <- readepi::login(
  type = "dhis2",
  from = "https://play.im.dhis2.org/stable-2-42-6",
  user_name = rstudioapi::askForPassword("Database username"),
  password = rstudioapi::askForPassword("Database password")
)
```

Your can read further from this blogpost on [How to Avoid Publishing Credentials in Your Code](https://rviews.rstudio.com/2019/03/21/how-to-avoid-publishing-credentials-in-your-code/)

:::::::


``` r
# get the names and IDs of the programs
programs <- readepi::get_programs(login = dhis2_login)
```

``` error
Error in `login[["url"]]`:
! object of type 'closure' is not subsettable
```

``` r
# print tables
tibble::as_tibble(programs)
```

``` error
Error:
! object 'programs' not found
```


``` r
# get the names and IDs of the organisation units
org_units <- readepi::get_organisation_units(login = dhis2_login)
```

``` error
Error in `login[["url"]]`:
! object of type 'closure' is not subsettable
```

``` r
# print tables
tibble::as_tibble(org_units)
```

``` error
Error:
! object 'org_units' not found
```

After retrieving organization units and program names from the DHIS2 database, we can import data using either names or coded IDs, as demonstrated in the code chunks below:


``` r
# import data from DHIS2 using names
data_name <- readepi::read_dhis2(
  login = dhis2_login,
  org_unit = "Bucksal Clinic",
  program = "Child Programme"
)
```

``` error
Error in `readepi::read_dhis2()`:
! Assertion on 'login' failed: Must inherit from class 'httr2_response', but has class 'function'.
```

``` r
tibble::as_tibble(data_name)
```

``` error
Error:
! object 'data_name' not found
```


``` r
# import data from DHIS2 using IDs
data_id <- readepi::read_dhis2(
  login = dhis2_login,
  org_unit = "vRC0stJ5y9Q",
  program = "IpHINAT79UW"
)
```

``` error
Error in `readepi::read_dhis2()`:
! Assertion on 'login' failed: Must inherit from class 'httr2_response', but has class 'function'.
```

``` r
identical(data_id, data_name)
```

``` error
Error:
! object 'data_id' not found
```

Note that not all organization units are registered for a specific program. To find which organization units are running a particular program, use the `get_program_org_units()` function as shown below:


``` r
# get the list of organisation units that run the program "IpHINAT79UW"
target_org_units <- readepi::get_program_org_units(
  login = dhis2_login,
  program = "IpHINAT79UW",
  org_units = org_units
)
```

``` error
Error in `login[["url"]]`:
! object of type 'closure' is not subsettable
```

``` r
tibble::as_tibble(target_org_units)
```

``` error
Error:
! object 'target_org_units' not found
```

<!-- :::::::::::::::: callout

Note: This example uses a demo system provided by DHIS2 [organization](https://test.e2e.dhis2.org/) for testing and development purposes. In practice, you should customize the parameters for your own DHIS2 instance. 

:::::::::::::::: -->

:::::::::::::::::::::: challenge

### Reading from a DHIS2 sever

Test `{readepi}` by accessing to a DHIS2 server with your credentials.

Do the following:

- Log into a different server,
- List all available programs and organization units, 
- Read data from one of these programs,
- Optional: Reproduce one descriptive figure.

::::::::: hint

Try using `rstudioapi::askForPassword()` for `user_name` and `password`.

If you get errors, please fill an issue in the [`readepi` GitHub repository](https://github.com/epiverse-trace/readepi/issues/).

:::::::::

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
```

``` error
Error in `httr2::req_perform()` at readepi/R/read_sormas-helpers.R:28:3:
! HTTP 503 Service Unavailable.
```

``` r
tibble::as_tibble(covid_cases)
```

``` error
Error:
! object 'covid_cases' not found
```

A key parameter is the disease name. To ensure correct syntax, you can retrieve the list of available disease names using the `sormas_get_diseases()` function.


``` r
# get the list of all disease names
disease_names <- readepi::sormas_get_diseases(
  login = sormas_login
)
```

``` error
Error in `httr2::req_perform()` at readepi/R/read_sormas-helpers.R:28:3:
! HTTP 503 Service Unavailable.
```

``` r
tibble::as_tibble(disease_names)
```

``` error
Error:
! object 'disease_names' not found
```


:::::::::::::::::::::: challenge
### Reading from Demo SORMAS sever

<!-- 
The SORMAS organization also provides demo servers for development and testing. One of
these is called **clinical surveillance**, available at the link
("https://demo.sormas.org/sormas-rest"), and accessible with username "CaseSup" and password "SJgFKffPDmr7". 
-->

Log into this server, list all available diseases, and import cases related to the monkeypox (mpox) disease.

::::::::::::::: solution


``` r
# establish the connection to the system
sormas_demo <- readepi::login(
  type = "sormas",
  from = "https://demo.sormas.org/sormas-rest",
  user_name = "SurvSup",
  password = "Lk5R7JXeZSEc"
)

# List the names of all disease
demo_diseases <- readepi::sormas_get_diseases(login = sormas_demo)
```

``` error
Error in `httr2::req_perform()` at readepi/R/read_sormas-helpers.R:28:3:
! HTTP 503 Service Unavailable.
```

``` r
tibble::as_tibble(demo_diseases)
```

``` error
Error:
! object 'demo_diseases' not found
```


``` r
# get the list of all disease names
mpox_cases <- readepi::read_sormas(
  login = sormas_demo,
  disease = "monkeypox",
)
```

``` error
Error in `httr2::req_perform()` at readepi/R/read_sormas-helpers.R:28:3:
! HTTP 503 Service Unavailable.
```

``` r
tibble::as_tibble(mpox_cases)
```

``` error
Error:
! object 'mpox_cases' not found
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
