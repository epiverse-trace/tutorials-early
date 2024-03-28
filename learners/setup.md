---
title: Setup
---

## Software Setup

Follow these two steps:

### 1. Install or upgrade R and RStudio

R and RStudio are two separate pieces of software: 

* **R** is a programming language and software used to run code written in R.
* **RStudio** is an integrated development environment (IDE) that makes using R easier. We recommend to use RStudio to interact with R. 

To install R and RStudio, follow these instructions <https://posit.co/download/rstudio-desktop/>.

::::::::::::::::::::::::::::: callout

### Already installed? 

Hold on: This is a great time to make sure your R installation is current.

This tutorial requires **R version 4.0.0 or later**. 

:::::::::::::::::::::::::::::

To check if your R version is up to date:

- In RStudio your R version will be printed in [the console window](https://docs.posit.co/ide/user/ide/guide/code/console.html). Or run `sessionInfo()` there.

- **To update R**, download and install the latest version from the [R project website](https://cran.rstudio.com/) for your operating system.

  - After installing a new version, you will have to reinstall all your packages with the new version. 

  - For Windows, the `{installr}` package can upgrade your R version and migrate your package library.

- **To update RStudio**, open RStudio and click on 
`Help > Check for Updates`. If a new version is available follow the 
instructions on the screen.

::::::::::::::::::::::::::::: callout

### Check for Updates regularly

While this may sound scary, it is **far more common** to run into issues due to using out-of-date versions of R or R packages. Keeping up with the latest versions of R, RStudio, and any packages you regularly use is a good practice.

:::::::::::::::::::::::::::::

### 2. Install the required R packages

<!--
During the tutorial, we will need a number of R packages. Packages contain useful R code written by other people. We will use packages from the [Epiverse-TRACE](https://epiverse-trace.github.io/). 
-->

Open RStudio and **copy and paste** the following code chunk into the [console window](https://docs.posit.co/ide/user/ide/guide/code/console.html), then press the <kbd>Enter</kbd> (Windows and Linux) or <kbd>Return</kbd> (MacOS) to execute the command:

```r
if(!require("pak")) install.packages("pak")

new_packages <- c(
  "EpiNow2",
  "epiverse-trace/epiparameter",
  "tidyverse"
)

pak::pak(new_packages)
```

These installation steps could ask you `? Do you want to continue (Y/n)` write `Y` and press <kbd>Enter</kbd>.

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
