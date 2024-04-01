---
title: Setup
---

## Motivation

**Outbreaks** appear with different diseases and in different contexts, but what all of them have in common is the key public health **questions** ([Cori et al. 2017](https://royalsocietypublishing.org/doi/10.1098/rstb.2016.0371#d1e605)). We can relate these key public health questions to outbreak data analysis **tasks**.

Epiverse-TRACE aims to provide a software ecosystem for [**outbreak analytics**](reference.md#outbreakanalytics) with integrated, generalisable and scalable community-driven software. We support the development of R packages, make the existing ones interoperable for the user experience, and stimulate a community of practice.

### Epiverse-TRACE tutorials

The tutorials are built around an outbreak analysis pipeline split into three stages: **Early tasks**, **Middle tasks** and **Late tasks**.

![An overview of the tutorial topics](https://epiverse-trace.github.io/task_pipeline-minimal.svg)

Each task has its tutorial website. Each tutorial website consists of a set of episodes.

| [Early task tutorials ➠](https://epiverse-trace.github.io/tutorials-early/) | [Middle task tutorials ➠](https://epiverse-trace.github.io/tutorials-middle) | [Late task tutorials ➠](https://epiverse-trace.github.io/tutorials-late/) |
|---|---|---|
| Reading and cleaning case data | Real-time analysis and forecasting | Scenario modelling |
| Read and clean linelist data, Access delay distributions, and Estimate transmission metrics. | Forecast cases, Estimate severity, and Estimate superspreading. | Simulate disease spread and Investigate interventions. |

Each episode contains:

+ **Overview** : describes what questions will be answered and what are the objectives of the episode.
+ **Prerequisites**: describes what episodes/packages need to be covered before the current episode.
+ **Example R code** : work through the episodes on your own computer using the example R code.
+ **Challenges** : complete challenges to test your understanding.
+ **Explainers** : add to your understanding of mathematical and modelling concepts with the explainer boxes.

Also check out the [glossary](../reference.md) for any terms you may be unfamiliar with.

### Epiverse-TRACE R packages

Our strategy is to gradually incorporate specialised **R packages** into our traditional analysis pipeline. These packages should fill the gaps in these epidemiology-specific tasks in response to outbreaks.

![In **R**, the fundamental unit of shareable code is the **package**. A package bundles together code, data, documentation, and tests and is easy to share with others ([Wickham and Bryan, 2023](https://r-pkgs.org/introduction.html))](episodes/fig/pkgs-hexlogos.png)

:::::::::::::::::::::::::::: prereq

This course assumes intermediate R knowledge. This workshop is for you if:

- You can use the magrittr pipe `%>%` and/or native pipe `|>`
- You are familiar with functions from `{dplyr}`, `{tidyr}`, and `{ggplot2}`
- You can read data into R, transform and reshape data, and make a wide variety of graphs

We expect participants to have some exposure to basic Statistical, Mathematical and Epidemic theory concepts, but NOT intermediate or expert familiarity with modeling.

::::::::::::::::::::::::::::

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
  "incidence2",
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
library(incidence2)
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
