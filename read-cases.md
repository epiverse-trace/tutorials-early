---
title: 'Read case data'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- how many different data formats can I read? 
- is it possible to import data from database and health APIs? 
::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain how read/import outbreak data from different sources into `R` 
environment for analysis.
::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::: prereq

## Prerequisites

This episode requires you to be familiar with:

**Data science** : Basic programming with R.
:::::::::::::::::::::::::::::::::

# Introduction

The initial step in outbreak analysis involves importing the target dataset into the `R` environment from various sources. Outbreak data is typically stored in files of diverse formats, within relational database management systems (RDBMS), and health information system APIs (HIS). The latter two options are particularly well-suited for storing institutional data. This episode will elucidate the process of reading cases from these sources.

## Reading from files

Several packages are available for importing outbreak data stored in individual files into `R`. These include [rio](http://gesistsa.github.io/rio/), [readr](https://readr.tidyverse.org/) from the `tidyverse`, [io](https://bitbucket.org/djhshih/io/src/master/), and [ImportExport](https://cran.r-project.org/web/packages/ImportExport/index.html). Together, these packages offer methods to read single or multiple files in a wide range of formats.

The below example shows how to import a `csv` file into `R` environment using `rio` package.

```r
library("rio")
case_data = rio::import("./data/ebola_cases.csv", format = "csv")
```
Similarly, you can import files of other formats such as "tsv", "xlsx", ...etc.

::::::::::::::::::::::::::::::::: challenge

###  Reading compressed data 
Take 1 minute:

- Is it possible to read compressed data in `R`?

::::::::::::::::: hint

You can check the supported file formats in the `{rio}` package as follows:

```r
library("rio")
rio::install_formats()
```

::::::::::::::::::::::

::::::::::::::::: solution


```r
library("rio")
rio::import("/path_name/file_name.zip")
```

::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::


## Reading from databases


## Reading from HIS APIs


::::::::::::::::::::::::::::::::::::: keypoints 
- Use `{rio}, {io}, {readr}` and `{ImportExport}` to read data from individual files.
- Use `{DBI}` to read data from databases.
- Use `{readepi}` to read data form HIS APIs.
::::::::::::::::::::::::::::::::::::::::::::::::

