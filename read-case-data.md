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
# Source:     SQL [?? x 3]
# Database:   mysql 5.5.5-10.11.8-MariaDB [@genome-mysql.soe.ucsc.edu:/hgFixed]
# Ordered by: desc(id)
       id name                                                               crc
    <int> <chr>                                                            <dbl>
 1 353104 Ahn J, Suh Y and Lee K.                                         3.93e9
 2 266006 Averdam A, Kuhl H, Sontag M, Becker T, Hughes AL, Reinhardt R … 5.99e8
 3 251641 Auslander,J., Furman,M. and Mead,J.                             2.99e9
 4 224864 Ahn,S.J., Bak,H.J., Park,J.H., Kim,S.A., Kim,N.Y., Lee,J.Y., S… 6.87e8
 5 220917 Aegerter,S., Jalabert,B. and Bobe,J.                            1.04e8
 6 212073 Alexandersen,S., Wernery,U., Nagy,P., Frederiksen,T. and Norma… 2.40e9
 7 164658 Aarnink,A., Jacquelin,B., Dauba,A., Hebrard,S., Moureaux,E., M… 9.79e8
 8 160011 Asano,K., Hershey,J.W.B. and Hinnebusch,A.G.                    3.05e9
 9 159998 Alam,M.R., Caldwell,B.D., Johnson,R.C., Darlington,D.N., Mains… 9.82e8
10 124685 Aldrich,T.L. and Morris,A.E.                                    9.92e8
11 122404 Agrimi,G., Di Noia,M.A., Marobbio,C.M., Fiermonte,G., Lasorsa,… 9.91e8
12 103980 Albani,M.C., Castaings,L., Wotzel,S., Mateos,J.L., Wunder,J., … 9.82e8
13  76157 Albani,D., Hammond-Kosack,M.C., Smith,C., Conlan,S., Colot,V.,… 2.39e9
14  58333 Altman,S., Bothwell,A. and Mamoum,C.                            5.99e8
15  53048 Araki,H. and Inoue,M.                                           2.03e9
16  38837 Adachi,N., Singh,D. and Shinohara,T.                            3.98e9
17  35427 Averof,M. and Cohen,S.M.                                        2.39e9
18  31262 Addison,W.R., Gillam,I.C., Hayashi,S. and Tener,G.M.            2.40e9
19  24814 Autry,B., Cooling,G.T., Franke,M.C., Johnson,K.M., Leveille,A.… 1.67e9
20   4346 Asada,A., Orii,H., Watanabe,K. and Tsubaki,M.                   2.40e9
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
  SELECT `author`.*, ROW_NUMBER() OVER (ORDER BY RAND()) AS `col01`
  FROM `author`
  WHERE (SUBSTR(`name`, 1, 1) = 'A')
) `q01`
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
 1 351082 Aiello FA, Palma A, Malacaria E, Zheng L, Campbell JL, Shen B,… 3.97e9
 2 341783 Amit M, Na'ara S, Fridman E, Vladovski E, Wasserman T, Milman … 1.07e9
 3 292017 Adachi W, Ulanovsky H, Li Y, Norman B, Davis J and Piatigorsky… 3.40e9
 4 291500 Aikins MJ, Schooley DA, Begum K, Detheux M, Beeman RW and Park… 7.92e8
 5 252133 Arden,N., Healey,M. and Mead,J.                                 1.92e9
 6 250439 Athwal,N., Peretz,S. and Mead,J.                                3.39e9
 7 248032 Aguilar,A.                                                      2.63e7
 8 246550 Armant,O., Collins,J.E., Hunt,P., Oliver,K., McLaren,S., Chalk… 2.40e9
 9 240070 Aberger,F., Schmidt,G. and Richter,K.                           2.40e9
10 226862 Alvares,L.E., Winterbottom,F.L., Rodrigues Sobreira,D., Xavier… 9.80e8
11 223927 Ahn,S.J., Sung,J.H., Kim,N.Y., Lee,A.R., Jeon,S.J., Lee,J.S., … 6.87e8
12 220033 Andre,S., Guillet,F., Charlemagne,J. and Fellah,J.S.            9.82e8
13 109548 Azzarina,A.B. and Mohamed,R.                                    2.40e9
14  83848 Ashworth,V.E.T.M.                                               2.96e9
15  83550 Amaya,I., Ratcliffe,O.J. and Bradley,D.J.                       3.92e9
16  76665 Aguirre,P.J. and Smith,A.G.                                     2.40e9
17  54503 ADAI,A.T., SZAFRANSKA-SCHWARZBACH,A.E., ANDRUSS,B.F., MAITRA,A… 3.82e9
18  38755 Alonso,C., Miskin,J., Hernaez,B., Fernandez-Zapatero,P., Soto,… 2.84e9
19  22685 Arler,L., Cazzamali,G. and Grimmelikhuijzen,C.J.P.              6.76e8
20   5853 Anderson,T.D., Jin-Clark,Y., Begum,K., Starkey,S.R. and Zhu,K.… 2.57e9
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
    SELECT `author`.*, ROW_NUMBER() OVER (ORDER BY RAND()) AS `col01`
    FROM `author`
    WHERE (SUBSTR(`name`, 1, 1) = 'A')
  ) `q01`
  WHERE (`col01` <= 5)
) `LHS`
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
# A tibble: 7 × 4
      id name                                                       author acc  
   <int> <chr>                                                       <dbl> <chr>
1 151619 Alabouch,S., Kurose,K., Tohkin,M., Bani,M.H., Fukuhara,M.… 151619 D869…
2 128876 Akimzhanov,A.M., Wang,X., Sun,J. and Boehning,D.           128876 GU32…
3 142519 Abedin,Z.R., Moser,A.J., Roslyn,J.J. and Abedin,M.Z.       142519 AF01…
4 142519 Abedin,Z.R., Moser,A.J., Roslyn,J.J. and Abedin,M.Z.       142519 AF01…
5 269865 Aghnatios,R., Cayrou,C., Garibal,M., Robert,C., Azza,S., … 269865 NR_1…
6  16593 Abdelall,M.F.M., Khalil,S., Abdelkreem,A., Roe,M. and Sal…  16593 KC96…
7  16593 Abdelall,M.F.M., Khalil,S., Abdelkreem,A., Roe,M. and Sal…  16593 KC96…
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
Error in `poolCheckout()`:
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
  from = "https://play.im.dhis2.org/stable-2-42-5-1",
  user_name = "admin",
  password = "district"
)

dhis2_login
```

``` output
<httr2_response>
GET https://play.im.dhis2.org/stable-2-42-5-1/api/me
Status: 200 OK
Content-Type: application/json
Body: In memory (12502 bytes)
```

If the step above fails, check for others available in the list of [DHIS2 Demo Instances](https://im.dhis2.org/public/instances), all accessible with username `"admin"` and password `"district"`. Just replace `stable-2-42-5-1` in the URL string. The only conditions is that it must be of version equal or lower than `2.42`.

::::::: caution

Avoid publishing your USER NAME and PASSWORD. You could use `{rstudioapi}`:


``` r
dhis2_login <- readepi::login(
  type = "dhis2",
  from = "https://play.im.dhis2.org/stable-2-42-5-1",
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
# A tibble: 15 × 3
   displayName                                         id          type     
   <chr>                                               <chr>       <chr>    
 1 ANC Registry (AI QA)                                nwRVCEXbrzR tracker  
 2 Antenatal care visit                                lxAQ7Zs9VYR aggregate
 3 Child Programme                                     IpHINAT79UW tracker  
 4 Contraceptives Voucher Program                      kla3mAPgvCH aggregate
 5 Information Campaign                                q04UBOqq3rp aggregate
 6 Inpatient morbidity and mortality                   eBAyeGv0exc aggregate
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
org_units <- readepi::get_organisation_units(login = dhis2_login)

# print tables
tibble::as_tibble(org_units)
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
```

``` warning
Warning in as.POSIXct(as.numeric(date_last_contact), origin = "1970-01-01"):
NAs introduced by coercion
```

``` r
tibble::as_tibble(covid_cases)
```

``` output
# A tibble: 2 × 16
  case_id             person_id date_onset case_origin case_status outcome sex  
  <chr>               <chr>     <date>     <chr>       <chr>       <chr>   <chr>
1 UZWZTD-BFNG4C-VXMD… QYLUZS-S… NA         IN_COUNTRY  NOT_CLASSI… NO_OUT… <NA> 
2 ULMPMT-PBQOQ2-ETGY… WVP6NB-J… 2026-05-31 IN_COUNTRY  NOT_CLASSI… NO_OUT… <NA> 
# ℹ 9 more variables: date_of_birth <chr>, country <chr>, city <chr>,
#   latitude <chr>, longitude <chr>, contact_id <chr>,
#   date_last_contact <date>, date_first_contact <date>, Ct_values <chr>
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

``` error
Error in `sormas_get_cases_data()`:
✖ No cases found for the supplied disease.
ℹ Please run `sormas_get_diseases()` to check if you provided the correct
  disease name.
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
