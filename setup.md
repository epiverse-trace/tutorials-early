---
title: Setup
---

## Software Setup

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: instructor

Setup instructions live in this document. Please specify the tools and the data sets the learner needs to have installed. If you want to hide different setup instructions, you can use a `solution` tag.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

### Install R and RStudio

R and RStudio are two separate pieces of software: 

* **R** is a programming language and software used to run code written in R.
* **RStudio** is an integrated development environment (IDE) that makes using R easier. In this tutorial, we use RStudio to interact with R. 

If you don't already have `R` and `RStudio` installed, follow the instructions for your operating system at <https://posit.co/download/rstudio-desktop/>.

### Update R and RStudio

This tutorial requires R version 4.0.0 or later. 

If you already have R and RStudio installed, first check if your R version is up to date:

* When you open RStudio your R version will be printed in the console on the [console window](https://docs.posit.co/ide/user/ide/guide/code/console.html). Alternatively, you can type `sessionInfo()` into the console. 

* If your version of R is older than the one required, download and install the latest version of R from the [R project website](https://cran.rstudio.com/) for your operating system. 

* After installing a new version of R, you will have to reinstall all your packages with the new version. For Windows, there is a package called `installr` that can help you with upgrading your R version and migrating your package library. 

* To update RStudio to the latest version, open RStudio and click on 
`Help > Check for Updates`. If a new version is available follow the 
instructions on the screen. By default, RStudio will also automatically notify you 
of new versions every once in a while.

::::::::::::::::::::::::::::: callout

While this may sound scary, it is **far more common** to run into issues due to using out-of-date versions of R or R packages. Keeping up with the latest versions of R, RStudio, and any packages you regularly use is a good practice.

:::::::::::::::::::::::::::::

### Install required R packages

During the tutorial, we will need a number of R packages. Packages contain useful R code written by other people. We will use packages from the [Epiverse-TRACE](https://epiverse-trace.github.io/). 

To try to install these packages, open RStudio and copy and paste the following code chunk into the [console window](https://docs.posit.co/ide/user/ide/guide/code/console.html), then press the <kbd>Enter</kbd> (Windows and Linux) or <kbd>Return</kbd> (MacOS) to execute the command.

```r
if(!require("pak")) install.packages("pak")

new_packages <- c(
  "EpiNow2",
  "epiverse-trace/epiparameter",
  "tidyverse
)

pak::pak(new_packages)
```

You should update **all of the packages** required for the tutorial, even if you installed them relatively recently. New versions bring improvements and important bug fixes.

When the installation has finished, you can try to load the packages by pasting the following code into the console:

```r
library(EpiNow2)
library(epiparameter)
library(tidyverse)
```

If you do NOT see an error like `there is no package called ‘...’` you are good to go! If you do, [contact us](#your-questions)!

## Data sets

### Download the data

We will download the data directly from R during the tutorial. However, if you are expecting problems with the network, it may be better to download the data beforehand and store it on your machine.

The data files for the tutorial can be downloaded manually here: 

- <https://epiverse-trace.github.io/tutorials/data/ebola_cases.csv>

## Your Questions

If you need any assistance installing the software or have any other questions about this tutorial, please send an email to <andree.valle-campos@lshtm.ac.uk>
