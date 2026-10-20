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
 1 357812 ANDERSON,D.G., WESSELHOEFT,R.A. and KOWALSKI,P.S.               2.78e9
 2 316945 Antony C, Huchet M, Changeux JP and Cartaud J.                  2.45e8
 3 316090 Arakaki AKS, Pan WA, Lin H and Trejo J.                         3.77e9
 4 313214 Atanes P, Ruz-Maldonado I, Hawkes R, Liu B, Zhao M, Huang GC, … 9.93e8
 5 255289 Audic,S., Lescot,M., Claverie,J.M., Cloeckaert,A. and Zygmunt,… 4.03e9
 6 254388 Arand,M., Friedberg,T., Wieser,R.J. and Oesch.F.                4.18e8
 7 240722 Al-Sa'ady,A.T., Alkhafaji,Z.A. and Shibly,K.                    5.99e8
 8 237145 Amemiya,C.T. and Litman,G.W.                                    9.90e8
 9 227535 Aztatzi-Aguilar,O.G., Perez-Nunez,M.T., Albores-Medina,A. and … 3.04e9
10 218177 Andeol,Y., Lefresne,J., Simard,C., Seguin,C., Mouton,C. and Si… 9.96e8
11 212573 Agwu,A., Lindsey,J.C., Ferguson,K., Zhang,H., Spector,S., Rudy… 2.40e9
12 170109 Avettand-Fenoel,V., Hocqueloux,L., Muller-Trutwin,M., Prazuck,… 9.98e8
13 151418 Adachi,T., Kojima,K., Fukuoka,S., Ogawa,H. and Matsumoto,I.     3.95e9
14 143616 Azim,A.C., Kim,A.C., Lutchman,M., Andrabi,S., Peters,L.L. and … 3.92e9
15 131685 Aso,T., Haque,D., Fukudome,K., Brower,C.S., Conaway,J.W. and C… 3.92e9
16 115822 Allcock,R.J., Christiansen,F.T. and Price,P.                    3.10e9
17  95062 Azoulay-Shemer,T., Harpaz-Saad,S., Cohen-Peer,R., Mett,A., Spi… 1.92e9
18  91118 Ahn,K., Grishina,G., Bardina,L., Beyer,K. and Sampson,H.A.      3.98e9
19  63845 Adhin,M.R., Hirashima,A. and van Duin,J.                        1.03e9
20     46 Agematu,H., Matsumoto,N., Fujii,Y., Kabumoto,H., Doi,S., Machi… 2.39e9
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
 1 366032 Aprato J, Sock E, Weider M, Elsesser O, Frob F and Wegner M.   1.67 e9
 2 362282 Acharya S, Dutta S, Chopra S and Bose K.                       1.93 e9
 3 361717 An X, Liu X, Ma G and Li C.                                    2.73 e9
 4 361608 An HJ, Ryu M, Jeong HJ, Kang M, Jeon HM, Lee JO, Kim YS and L… 3.03 e7
 5 336519 Abe K, Cox A, Takamatsu N, Velez G, Laxer RM, Tse SML, Mahaja… 3.50 e9
 6 333458 Arunkumar,G., Shilpa,C., Kavitha,K., Sudheesh,N., Sabeena,S.,… 4.18 e8
 7 323985 Askari M, Kordi-Tamandani DM, Almadani N, McElreavey K and To… 1.000e9
 8 286024 Arvaniti M, Jensen MM, Soni N, Wang H, Klein AB, Thiriet N, P… 9.97 e8
 9 281561 Amiri-Yekta A, Coutton C, Kherraf ZE, Karaouzene T, Le Tanno … 3.90 e9
10 236788 Akashi,H.D., Saito,S., Cadiz Diaz,A., Makino,T., Tominaga,M. … 5.99 e8
11 233349 Aguilar,A., Edwards,S.V., Smith,T.B. and Wayne,R.K.            2.40 e9
12 204458 Anis,E., Wilkes,R.P., Needle,D.B., Stevens,B.A. and Dubovi,E.… 9.83 e8
13 196059 Alam,S.T., Vaidya,S.R., Kamble,M. and Rabha,D.                 3.37 e9
14 190799 Alves-Freitas,D.M., Pinheiro-Lima,B., Faria,J.C., Lacorte,C.,… 2.75 e9
15 157418 Arce Vargas,F., Furness,A.J., Litchfield,K., Joshi,K., Rosent… 3.99 e9
16 135157 Albertsen,H.M., Smith,S.A., Mazoyer,S., Fujimoto,E., Stevens,… 2.80 e9
17  98593 Ali,M., Ji,W., Baloch,G.M. and Baloch,G.A.                     9.76 e8
18  85121 Abe,I., Naito,K., Takagi,Y. and Noguchi,H.                     2.40 e9
19  47967 Abdul,F., Filleton,F., Gerossier,L., Paturel,A., Hall,J., Str… 2.39 e9
20  43072 Amills,M., Sulas,C., Sanchez,A., Bertoni,G., Zanoni,R. and Ob… 3.24 e9
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
# A tibble: 18 × 4
       id name                                                      author acc  
    <int> <chr>                                                      <dbl> <chr>
 1 310700 Andrews MT, Squire TL, Bowen CM and Rollins MB.           310700 NM_0…
 2 190053 Aghamolai,A., Nasrollanejad,S. and Mostafavi Neishaburi,… 190053 KR90…
 3 168300 Abid,K., Quadri,R., Veuthey,A.L., Hadengue,A. and Negro,… 168300 AF21…
 4 168300 Abid,K., Quadri,R., Veuthey,A.L., Hadengue,A. and Negro,… 168300 AF21…
 5 168300 Abid,K., Quadri,R., Veuthey,A.L., Hadengue,A. and Negro,… 168300 AF21…
 6 168300 Abid,K., Quadri,R., Veuthey,A.L., Hadengue,A. and Negro,… 168300 AF21…
 7 168300 Abid,K., Quadri,R., Veuthey,A.L., Hadengue,A. and Negro,… 168300 AF21…
 8 168300 Abid,K., Quadri,R., Veuthey,A.L., Hadengue,A. and Negro,… 168300 AF21…
 9 168300 Abid,K., Quadri,R., Veuthey,A.L., Hadengue,A. and Negro,… 168300 AF21…
10 168300 Abid,K., Quadri,R., Veuthey,A.L., Hadengue,A. and Negro,… 168300 AF21…
11 168300 Abid,K., Quadri,R., Veuthey,A.L., Hadengue,A. and Negro,… 168300 AF21…
12 168300 Abid,K., Quadri,R., Veuthey,A.L., Hadengue,A. and Negro,… 168300 AF21…
13 168300 Abid,K., Quadri,R., Veuthey,A.L., Hadengue,A. and Negro,… 168300 AF21…
14 168300 Abid,K., Quadri,R., Veuthey,A.L., Hadengue,A. and Negro,… 168300 AF21…
15 262715 Augustin R, Franke A, Khalturin K, Kiko R, Siebert S, He… 262715 NM_0…
16 262715 Augustin R, Franke A, Khalturin K, Kiko R, Siebert S, He… 262715 NM_0…
17 316274 Aouini A, Matsukura C, Ezura H and Asamizu E.             316274 NM_0…
18 316274 Aouini A, Matsukura C, Ezura H and Asamizu E.             316274 NM_0…
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

dhis2_login
```

``` output
<httr2_response>
GET https://play.im.dhis2.org/stable-2-42-6/api/me
Status: 200 OK
Content-Type: application/json
Body: In memory (12468 bytes)
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

# print tables
tibble::as_tibble(programs)
```

``` output
# A tibble: 14 × 3
   displayName                                         id          type     
   <chr>                                               <chr>       <chr>    
 1 Antenatal care visit                                lxAQ7Zs9VYR aggregate
 2 Child Programme                                     IpHINAT79UW tracker  
 3 Contraceptives Voucher Program                      kla3mAPgvCH aggregate
 4 Information Campaign                                q04UBOqq3rp aggregate
 5 Inpatient morbidity and mortality                   eBAyeGv0exc aggregate
 6 Malaria case diagnosis, treatment and investigation qDkgAbB5Jlk tracker  
 7 Malaria case registration                           VBqh0ynB2wv aggregate
 8 Malaria focus investigation                         M3xtLkYBlKI tracker  
 9 Malaria testing and surveillance                    bMcwwoVnbSR aggregate
10 MNCH / PNC (Adult Woman)                            uy2gU8kT1jF tracker  
11 Provider Follow-up and Support Tool                 fDd25txQckK tracker  
12 TB program                                          ur1Edk5Oe2n tracker  
13 WHO RMNCH Tracker                                   WSGAb5XwJ3Y tracker  
14 XX MAL RDT - Case Registration                      MoUd5BTQ3lY aggregate
```


``` r
# get the names and IDs of the organisation units
org_units <- readepi::get_organisation_units(login = dhis2_login)

# print tables
tibble::as_tibble(org_units)
```

``` output
# A tibble: 1,166 × 8
   National_name National_id District_name District_id Chiefdom_name Chiefdom_id
   <chr>         <chr>       <chr>         <chr>       <chr>         <chr>      
 1 Sierra Leone  ImspTQPwCqd Kenema        kJq2mPyFEHo Nongowa       KIUCimTXf8Q
 2 Sierra Leone  ImspTQPwCqd Western Area  at6UHUQatSo Rural Wester… qtr8GGlm4gg
 3 Sierra Leone  ImspTQPwCqd Western Area  at6UHUQatSo Rural Wester… qtr8GGlm4gg
 4 Sierra Leone  ImspTQPwCqd Bo            O6uvpzGd5pu Kakua         U6Kr7Gtpidn
 5 Sierra Leone  ImspTQPwCqd Kambia        PMa2VCrupOd Magbema       QywkxFudXrC
 6 Sierra Leone  ImspTQPwCqd Tonkolili     eIQbndfxQMb Yoni          NNE0YMCDZkO
 7 Sierra Leone  ImspTQPwCqd Port Loko     TEQlaapDQoK Kaffu Bullom  vn9KJsLyP5f
 8 Sierra Leone  ImspTQPwCqd Koinadugu     qhqAxPSTUXp Nieni         J4GiUImJZoE
 9 Sierra Leone  ImspTQPwCqd Western Area  at6UHUQatSo Freetown      C9uduqDZr9d
10 Sierra Leone  ImspTQPwCqd Western Area  at6UHUQatSo Freetown      C9uduqDZr9d
# ℹ 1,156 more rows
# ℹ 2 more variables: Facility_name <chr>, Facility_id <chr>
```

After retrieving organization units and program names from the DHIS2 database, we can import data using either names or coded IDs, as demonstrated in the code chunks below:


``` r
# import data from DHIS2 using names
data_name <- readepi::read_dhis2(
  login = dhis2_login,
  org_unit = "Bucksal Clinic",
  program = "Child Programme"
)

tibble::as_tibble(data_name)
```

``` output
# A tibble: 30 × 26
   event      tracked_entity org_unit Gender `First name` `Last name` enrollment
   <chr>      <chr>          <chr>    <chr>  <chr>        <chr>       <chr>     
 1 RrWEjrd84… yzhEctxhPiL    Bucksal… Female Karen        Alvarez     WKgHJZ3Ue…
 2 JgPqmTcG0… G3hZ9gN7UYD    Bucksal… Female Ruby         Warren      Rth5aVYua…
 3 Sz2U8t3YA… G3hZ9gN7UYD    Bucksal… Female Ruby         Warren      Rth5aVYua…
 4 VEvcoYpWF… RyPuD70zgE9    Bucksal… Male   Earl         Mason       COU4sScB6…
 5 BNZA0qyfC… KfXae2GB6Fb    Bucksal… Male   Mark         Jacobs      x4vAlqBJl…
 6 wGMKQ3SBb… KfXae2GB6Fb    Bucksal… Male   Mark         Jacobs      x4vAlqBJl…
 7 FoCWOlstb… aXaALEYwQNV    Bucksal… Female Lillian      Mccoy       VkZrYFMCK…
 8 HFQQUGE9O… aXaALEYwQNV    Bucksal… Female Lillian      Mccoy       VkZrYFMCK…
 9 pVmIV0EyY… rdo8mO4Jifk    Bucksal… Female Denise       Henderson   iwYMBJgiQ…
10 Dee74ydRn… rdo8mO4Jifk    Bucksal… Female Denise       Henderson   iwYMBJgiQ…
# ℹ 20 more rows
# ℹ 19 more variables: program <chr>, program_stage <chr>, event_date <chr>,
#   `MCH Infant Feeding` <chr>, `MCH OPV dose` <chr>, `MCH BCG dose` <chr>,
#   `MCH ARV at birth` <chr>, `MCH Apgar Score` <chr>, `MCH Weight (g)` <chr>,
#   `MCH Infant Weight  (g)` <chr>, `MCH Vit A` <chr>,
#   `MCH Infant HIV Test Result` <chr>, `MCH HIV Test Type` <chr>,
#   `MCH IPT dose` <chr>, `MCH DPT dose` <chr>, `MCH Child ARVs` <chr>, …
```


``` r
# import data from DHIS2 using IDs
data_id <- readepi::read_dhis2(
  login = dhis2_login,
  org_unit = "vRC0stJ5y9Q",
  program = "IpHINAT79UW"
)

identical(data_id, data_name)
```

``` output
[1] TRUE
```

Note that not all organization units are registered for a specific program. To find which organization units are running a particular program, use the `get_program_org_units()` function as shown below:


``` r
# get the list of organisation units that run the program "IpHINAT79UW"
target_org_units <- readepi::get_program_org_units(
  login = dhis2_login,
  program = "IpHINAT79UW",
  org_units = org_units
)

tibble::as_tibble(target_org_units)
```

``` output
# A tibble: 1,166 × 3
   org_unit_ids levels        org_unit_names              
   <chr>        <chr>         <chr>                       
 1 vRC0stJ5y9Q  Facility_name Bucksal Clinic              
 2 simyC07XwnS  Facility_name Maforay MCHP                
 3 E9oBVjyEaCe  Facility_name Gbanja Town MCHP            
 4 ZpE2POxvl9P  Facility_name Faabu CHP                   
 5 yTMrs5kClCv  Facility_name Condama MCHP                
 6 FO1Tq8vUa62  Facility_name EPI Headquarter             
 7 jGYT5U5qJP6  Facility_name Gbaiima CHC                 
 8 LaxJ6CD2DHq  Facility_name EM&BEE Maternity Home Clinic
 9 WerHl8SDtRU  Facility_name Mandema CHP                 
10 CTnuuI55SOj  Facility_name Manewa MCHP                 
# ℹ 1,156 more rows
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
tibble::as_tibble(covid_cases)
```

``` output
# A tibble: 3 × 15
  case_id             person_id date_onset case_origin case_status outcome sex  
  <chr>               <chr>     <date>     <chr>       <chr>       <chr>   <chr>
1 TYG7I3-2GONYO-JDJP… QJXOUU-6… NA         IN_COUNTRY  SUSPECT     NO_OUT… <NA> 
2 ULMPMT-PBQOQ2-ETGY… WVP6NB-J… 2026-05-31 IN_COUNTRY  NOT_CLASSI… NO_OUT… <NA> 
3 W3RLN3-LNPNMV-ETUQ… R6HELZ-O… NA         IN_COUNTRY  NOT_CLASSI… NO_OUT… <NA> 
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
# A tibble: 69 × 2
   disease            active
   <chr>              <chr> 
 1 AFP                TRUE  
 2 CHOLERA            TRUE  
 3 CONGENITAL_RUBELLA TRUE  
 4 DENGUE             TRUE  
 5 EVD                TRUE  
 6 GUINEA_WORM        TRUE  
 7 LASSA              TRUE  
 8 MONKEYPOX          TRUE  
 9 NEW_INFLUENZA      TRUE  
10 PLAGUE             TRUE  
# ℹ 59 more rows
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
tibble::as_tibble(demo_diseases)
```

``` output
# A tibble: 69 × 2
   disease            active
   <chr>              <chr> 
 1 AFP                TRUE  
 2 CHOLERA            TRUE  
 3 CONGENITAL_RUBELLA TRUE  
 4 DENGUE             TRUE  
 5 EVD                TRUE  
 6 GUINEA_WORM        TRUE  
 7 LASSA              TRUE  
 8 MONKEYPOX          TRUE  
 9 NEW_INFLUENZA      TRUE  
10 PLAGUE             TRUE  
# ℹ 59 more rows
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
1 TU75PT-MMBE3I-OEJN… XQFYXH-R… NA         IN_COUNTRY  NOT_CLASSI… NO_OUT… <NA> 
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
