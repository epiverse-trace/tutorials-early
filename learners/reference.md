---
title: 'Glossary of Terms: Epiverse-TRACE'
---

## A

[Airborne transmission]{#airborne}
: Individuals become infected via contact with infectious particles in the air. Examples include influenza and COVID-19. Atler et al. (2023) discuss about [factors and management procedures](https://www.ncbi.nlm.nih.gov/books/NBK531468/) of airborne transmission.

## B
[Basic reproduction number]{#basic}
: A measure of the transmissibility of a disease. Defined as the average number of secondary cases arising from an initial infected case in an entirely susceptible population. [More information on the basic reproduction number](https://en.wikipedia.org/wiki/Basic_reproduction_number).  

[Bayesian inference]{#bayesian}
: A type of statistical inference where prior beliefs are updated using observed data. 
[More information on Bayesian inference](https://en.wikipedia.org/wiki/Bayesian_inference).  


## C

[Contact matrix]{#contact}
: The contact matrix is a square matrix consisting of rows/columns equal to the number age groups. Each element represents the frequency of contacts between age groups. If we believe that transmission of an infection is driven by contact, and that contact rates are very different for different age groups, then specifying a contact matrix allows us to account for age specific rates of transmission. 

[C++]{#cplusplus}
: C++ is a high-level programming language that can be used within R to speed up sections of code. To learn more about C++ check out these [tutorials](https://cplusplus.com/doc/tutorial/) and learn more about the integration of C++ and R [here](https://www.rcpp.org/).
[Censoring]{#censoring}
: 
Means that we know an event happened, but we do not know exactly when it happened. Most epidemiological data are “doubly censored” because there is uncertainty surrounding both primary and secondary event times. Not accounting for censoring can lead to biased estimates of the delay’s standard deviation ([Park et al., in progress](https://github.com/parksw3/epidist-paper)).
Different sampling approaches can generate biases given left and right censoring in the estimation of the serial interval that can propagate bias to the estimation of the [incubation period](#incubation) and generation time ([Chen et al., 2022](https://www.nature.com/articles/s41467-022-35496-8/figures/2))

## D

[Deterministic model]{#deterministic}
: Models that will always have the same trajectory for given initial conditions and parameter values. Examples include ordinary differential equations and difference equations. 

[Direct transmission]{#direct}
: Individuals become infected via direct contact with other infected humans. Airborne transmitted infections are often modelled as directly transmitted infections as they require close contact with infected individuals for successful transmission. 

## E

[Effective reproduction number]{#effectiverepro}
: The time-varying or effective reproduction number ($Rt$) is similar to the [Basic reproductive number](#basic) ($R0$), but $Rt$ measures the number of persons infected by infectious person when some portion of the population has already been infected. Read more about the [etymology of Reproduction number by Sharma et al, 2023](https://wwwnc.cdc.gov/eid/article/29/8/22-1445_article).

<!-- ## F -->

## G
[Generation time]{#generationtime}
:  Time between the onset of infectiousness of an index case and its secondary case. This always needs to be positive.
The generation time distribution is commonly estimated from data on the [serial interval](#serialinterval) distribution of an infection ([Cori et al. 2017](https://royalsocietypublishing.org/doi/10.1098/rstb.2016.0371)).

<!-- This can produced biased estimates. ([Knight et al., 2020](https://www.sciencedirect.com/science/article/pii/S2468042720300634)) -->

[Growth rate]{#growth}
: The exponential growth rate tells us how much cases are increasing or decreasing at the start of an epidemic. It gives us a measure of speed of transmission, see [Dushoff & Park, 2021](https://royalsocietypublishing.org/doi/full/10.1098/rspb.2020.1556).

<!-- ## H -->

## I 

[Incubation period]{#incubation}
: The time between becoming infected and the onset of symptoms. 
[More information on the incubation period](https://en.wikipedia.org/wiki/Latent_period_(epidemiology)#Incubation_period). 
This can be different to the [latent period](#latent) as shown in Figure 4 from ([Xiang et al. (2021)](https://www.sciencedirect.com/science/article/pii/S2468042721000038#fig4)).
The relationship between the incubation period and the [serial interval](#serialinterval) helps to define the type of infection transmission (symptomatic or pre-symptomatic) ([Nishiura et al. (2020)](https://www.ijidonline.com/article/S1201-9712(20)30119-3/fulltext#gr2)).

[Indirect transmission]{#indirect}
: Indirectly transmitted infections are passed on to humans via contact with vectors, animals or contaminated environment. Vector-borne infections, zoonoses and water-borne infections are modelled as indirectly transmitted. 

[Initial conditions]{#initial}
: In [ODEs](#ordinary), the initial conditions are the values of the state variables at the start of the model simulation (at time 0). For example, if there is one infectious individual in a population of 1000 in an Susceptible-Infectious-Recovered model, the initial conditions would be $S(0) = 999$, $I(0) = 1$, $R(0) = 0$.  

[Infectious period]{#infectiousness}
: Also known as Duration of infectiousness. Time period between the onset and end of infectious [viral shedding](#viralshedding). 
Viral load and detection of infectious virus are the two key parameters for estimating infectiousness ([Puhach et al., 2022](https://www.nature.com/articles/s41579-022-00822-w) and [Hakki et al, 2022](https://www.thelancet.com/journals/lanres/article/PIIS2213-2600(22)00226-0/fulltext)](fig/infectiousness-covid19.jpg)).

<!-- ## J -->

<!-- ## K -->

## L

[Latent period]{#latent}
: The time between becoming infected and the onset of infectiousness. 
This can be different to the [incubation period](#incubation) as shown in Figure 4 from ([Xiang et al, 2021](https://www.sciencedirect.com/science/article/pii/S2468042721000038#fig4))

## M
[Model parameters (ODEs)]{#parsode}
: The model parameters are used in [ordinary differential equation](#ordinary) models to describe the flow between disease states. For example, a transmission rate $\beta$ is a model parameter that can be used to describe the flow between susceptible and infectious states. 


## N

[Natural history of disease]{#naturalhistory} 
: Refers to the development of disease from beginning to end without any treatment or intervention. In fact, given the harmfulness of an epidemic, treatment or intervention measures are inevitable. Therefore, it is difficult for the natural history of a disease to be unaffected by the various coupling factors. ([Xiang et al, 2021](https://www.sciencedirect.com/science/article/pii/S2468042721000038))

[Non-pharmaceutical interventions]{#NPIs}
: Non-pharmaceutical interventions (NPIs) are measures put in place to reduce transmission that do not include the administration of drugs or vaccinations. [More information on NPIs](https://www.gov.uk/government/publications/technical-report-on-the-covid-19-pandemic-in-the-uk/chapter-8-non-pharmaceutical-interventions).

## O
[Ordinary differential equations]{#ordinary}
: Ordinary differential equations (ODEs) can be used to represent the rate of change of one variable (e.g. number of infected individuals) with respect to another (e.g. time). Check out this introduction to [ODEs](https://mathinsight.org/ordinary_differential_equation_introduction). ODEs are widely used in infectious disease modelling to model the flow of individuals between different disease states. 

[Offspring distribution]{#offspringdist}
: Distribution of the number of secondary cases caused by a particular infected individual. ([Lloyd-Smith et al., 2005](https://www.nature.com/articles/nature04153), [Endo et al., 2020](https://wellcomeopenresearch.org/articles/5-67/v3))

[Outbreak analytics]{#outbreakanalytics}
: A specialized field within data science that focuses on the technological and methodological aspects of the outbreak data pipeline. This includes the systematic collection, analysis, modeling, and reporting of data to inform outbreak response ([Polonsky et al., 2019](https://royalsocietypublishing.org/doi/full/10.1098/rstb.2018.0276)).

## P

[(Dynamical or Epidemic) Phase bias]{#phasebias}
: Accounts for population susceptibility at the times transmission pairs are observed.
It is a type of sampling bias. It affects backward-looking data and is related to the phase of the epidemic: during the exponential growth phase, cases that developed symptoms recently are over-represented in the observed data, while during the declining phase, these cases are underrepresented, leading to the estimation of shorter and longer delay intervals, respectively. ([Park et al., in progress](https://github.com/parksw3/epidist-paper))

<!-- ## Q -->

## R

[Reporting delay]{#reportingdelay}
: Delay or lag between the time an event occurs (e.g. symptom onset) and the time it is reported ([Lawless, 1994](https://www.jstor.org/stable/3315820)). We can quantify it by comparing the linelist with successive versions of it or up-to-date reported aggregated case counts ([Cori et al. 2017](https://royalsocietypublishing.org/doi/10.1098/rstb.2016.0371)).

## S

[State variables]{#state}
: The state variables in a model represented by [ordinary differential equations](#ordinary) are the disease states that individuals can be in e.g. if individuals can be susceptible, infectious or recovered the state variables are $S$, $I$ and $R$. There is an ordinary differential equation for each state variable. 

[Serial interval]{#serialinterval}
: The time delay between the onset of symptoms between a primary case and a secondary case.
This can be negative when pre-symptomatic infection occurs.
Most commonly, the serial interval distribution of an infection is used to estimate the [generation time](#generationtime) distribution ([(Cori et al., 2017)](https://royalsocietypublishing.org/doi/10.1098/rstb.2016.0371)).
The relationship between the serial interval and the [incubation period](#incubation) helps to define the type of infection transmission (symptomatic or pre-symptomatic) ([Nishiura et al. (2020)](https://www.ijidonline.com/article/S1201-9712(20)30119-3/fulltext#gr2)).

[Stochastic model]{#stochastic}
: A model that includes some stochastic process resulting in variation in model simulations for the same initial conditions and parameter values. Examples include stochastic differential equations and branching process models. For more detail see [Allen (2017)](https://doi.org/10.1016/j.idm.2017.03.001).


## T

[(Right) Truncation]{#truncation}
: Type of sampling bias related to the data collection process. It arises because only cases that have been reported can be observed. Not accounting for right truncation during the growth phase of an epidemic can lead to underestimation of the mean delay ([Park et al., in progress](https://github.com/parksw3/epidist-paper)).

<!-- ## U -->

## V

[Vector-borne transmission]{#vectorborne}
: Vector-borne transmission means an infection can be passed from a vector (e.g. mosquitoes) to humans. Examples of vector-borne diseases include malaria and dengue. The World Health Organization have a [Fact sheet about Vector-borne diseases](https://www.who.int/news-room/fact-sheets/detail/vector-borne-diseases) with key information and a list of them according to their vector.

[Viral shedding]{#viralshedding}
: The process of releasing a virus from a cell or body into the environment where it can infect other people. ([Cambridge Dictionary, 2023](https://dictionary.cambridge.org/us/dictionary/english/shedding))

<!-- ## W -->

<!-- ## X -->

<!-- ## Y -->

<!-- ## Z -->
