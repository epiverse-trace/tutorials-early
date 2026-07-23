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
 1 280516 Alves MM, Burzynski G, Delalande JM, Osinga J, van der Goot A,… 9.86e8
 2 271687 Alfonso-Pecchio A, Garcia M, Leonardi R and Jackowski S.        3.94e9
 3 269783 Araujo MA, Marques TE, Octacilio-Silva S, Arroxelas-Silva CL, … 2.89e9
 4 254096 Ambegaonkar,A., Vershon,A. and Mead,J.                          2.18e9
 5 222253 Avaron,F., Hoffman,L., Guay,D. and Akimenko,M.A.                2.76e9
 6 208729 Amedee,A.M., Rychert,J.A. and Lacour,N.                         5.99e8
 7 169840 Andriamandimby,S.F., Randrianarivo-Solofoniaina,A.E., Jeanmair… 9.95e8
 8 169585 Adkar-Purushothama,C.R., Quaglino,F., Casati,P. and Bianco,P.A. 9.78e8
 9 160063 Angelotti,T. and Hofmann,F.                                     2.39e9
10 133462 An,G., Huang,T.H., Tesfaigzi,J., Garcia-Heras,J., Ledbetter,D.… 2.50e9
11 128322 Ahmed,Z.M., Riazuddin,S., Aye,S., Ali,R.A., Venselaar,H., Anwa… 2.87e9
12 126974 Altenberger,T., Bilban,M., Auer,M., Knosp,E., Wolfsberger,S., … 3.10e9
13  89341 Al-Babili,S., Hugueney,P., Schledz,M., Welsch,R., Frohnmeyer,H… 3.91e9
14  83564 Asif,M.H., Dhawan,P. and Nath,P.                                3.19e9
15  65345 Ashida,Y., Watanabe,J., Matsushima,A. and Hirata,T.             5.98e8
16  65145 Asawatreratanakul,K., Zhang,Y.W., Wititsuwannakul,R. and Koyam… 1.67e9
17  50659 Atabekov,J., Korpela,T., Dorokhov,Y., Ivanov,P., Skulachev,M.,… 2.39e9
18  39509 Antonini,S.                                                     1.07e8
19  39402 Argov,N. and Sklan,D.                                           3.64e9
20  12546 Aich,A. and Shaha,C.                                            1.50e8
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
 1 364672 Ahn,J.H., Lim,J.M., Kim,S.J., Song,J., Kwon,S.W. and Weon,H.Y.  2.75e9
 2 301229 Aijaz S, Sanchez-Heras E, Balda MS and Matter K.                1.94e9
 3 272284 Angelopoulou K, Prassas I and Yousef GM.                        1.32e9
 4 271440 Anderson KE, Kielkowska A, Durrant TN, Juvin V, Clark J, Steph… 9.83e8
 5 260571 An,D.S., Kim,S.G., Ten,L.N. and Cho,C.H.                        1.49e9
 6 250769 Asi,S., Marushak,T. and Mead,J.                                 2.39e8
 7 242927 Avrova,A.O., Venter,E., Birch,P.R.J. and Whisson,S.C.           4.00e9
 8 192414 Alexandre,M.A.V., Duarte,L.M.L., Rodrigues,L.K., Ramos,A.F. an… 9.83e8
 9 185984 Aguilar,J.M., Hernandez-Gallardo,M.D., Cenis,J.L., Lacasa,A. a… 9.79e8
10 180275 Afifi,M.A., Zaki,M.M., ABoZeid,H.H. and El-Kady,M.F.            3.91e9
11 177605 Alexandre,M.A.V., Duarte,L.M.L., Ramos,A.F. and Harakava,R.     9.83e8
12 171661 Ar Gouilh,M., Puechmaille,S.J., Gonzalez,J.-P.J., Teeling,E., … 2.69e9
13 153780 Azim,S., Banday,A.R. and Tabish,M.                              1.67e9
14 128930 Aksenova,V., Khotin,M., Turoverova,L., Barlev,N., Magnusson,K.… 2.40e9
15 118320 Ahmad,F., Gonzalez,O., Ramagli,L., Xu,J., Siciliano,M.J., Bach… 2.40e9
16 110990 Ali,B., Sohail,Y., Mumtaz,A.S. and Berndt,R.                    2.75e9
17  97114 Aslam,M., Anandhan,S., Singh,R.K. and Ahmed,Z.                  6.86e8
18  52134 Aurias,A., Chibon,F. and Mariani,O.                             2.39e9
19  45713 Azhar,M. and Somashekhar,R.                                     3.74e9
20  31554 Atkinson,N.S., Robertson,G.A. and Ganetzky,B.                   9.82e8
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
# A tibble: 15 × 4
       id name                                                      author acc  
    <int> <chr>                                                      <dbl> <chr>
 1 361044 Amatya N, Wales TE, Kwon A, Yeung W, Joseph RE, Fulton D… 361044 NM_0…
 2 361044 Amatya N, Wales TE, Kwon A, Yeung W, Joseph RE, Fulton D… 361044 NM_0…
 3 361044 Amatya N, Wales TE, Kwon A, Yeung W, Joseph RE, Fulton D… 361044 NM_0…
 4 200680 Ahmad,A., Azmai,M.N.A. and Abdullah,A.                    200680 MG58…
 5 200680 Ahmad,A., Azmai,M.N.A. and Abdullah,A.                    200680 MG58…
 6 200680 Ahmad,A., Azmai,M.N.A. and Abdullah,A.                    200680 MG58…
 7 200680 Ahmad,A., Azmai,M.N.A. and Abdullah,A.                    200680 MG58…
 8 200680 Ahmad,A., Azmai,M.N.A. and Abdullah,A.                    200680 MG58…
 9 200680 Ahmad,A., Azmai,M.N.A. and Abdullah,A.                    200680 MG58…
10 200680 Ahmad,A., Azmai,M.N.A. and Abdullah,A.                    200680 MG58…
11 200680 Ahmad,A., Azmai,M.N.A. and Abdullah,A.                    200680 MG58…
12 200680 Ahmad,A., Azmai,M.N.A. and Abdullah,A.                    200680 MG58…
13 115745 Abdelgadir,S.E., Roselli,C.E., Choate,J.V. and Resko,J.A. 115745 AF09…
14    408 Astashkin,E.I., Knyazeva,A.I., Kartsev,N.N. and Fursova,…    408 KJ46…
15 334026 Ash,S., Marrone,P. and Mead,J.                            334026 JZ98…
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
Body: In memory (12749 bytes)
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
# A tibble: 28 × 3
   displayName                             id          type     
   <chr>                                   <chr>       <chr>    
 1 "ANC Registry (AI QA)"                  nwRVCEXbrzR tracker  
 2 "ANC risk factor "                      BrA9KDpAfWW aggregate
 3 "Antenatal care visit"                  lxAQ7Zs9VYR aggregate
 4 "Cause of death (registration)"         ogrOUKoSaWA tracker  
 5 "CDC Bottle"                            BfW7UmisRmz aggregate
 6 "Child Programme"                       IpHINAT79UW tracker  
 7 "Contraceptives Voucher Program"        kla3mAPgvCH aggregate
 8 "Daily Spray Operator Form"             nppSwI94Yva aggregate
 9 "Diabetes Care & Complications Tracker" mN7SYIvl0DW tracker  
10 "Information Campaign"                  q04UBOqq3rp aggregate
# ℹ 18 more rows
```


``` r
# get the names and IDs of the organisation units
org_units <- readepi::get_organisation_units(login = dhis2_login)

# print tables
tibble::as_tibble(org_units)
```

``` output
# A tibble: 1,161 × 8
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
# ℹ 1,151 more rows
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
# A tibble: 1,161 × 3
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
# ℹ 1,151 more rows
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
# A tibble: 2 × 15
  case_id             person_id date_onset case_origin case_status outcome sex  
  <chr>               <chr>     <date>     <chr>       <chr>       <chr>   <chr>
1 UZWZTD-BFNG4C-VXMD… QYLUZS-S… NA         IN_COUNTRY  NOT_CLASSI… NO_OUT… <NA> 
2 ULMPMT-PBQOQ2-ETGY… WVP6NB-J… 2026-05-31 IN_COUNTRY  NOT_CLASSI… NO_OUT… <NA> 
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
