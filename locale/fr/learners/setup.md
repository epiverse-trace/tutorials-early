---
title: Mise en place
---

## Motivation

**Éclosions** de maladies infectieuses peuvent apparaître à cause de différents agents pathogènes et dans différents contextes, mais elles conduisent généralement à des questions de santé publique similaires, allant de la compréhension des schémas de transmission et de gravité à l'examen de l'effet des mesures de contrôle ([Cori et al. 2017](https://royalsocietypublishing.org/doi/10.1098/rstb.2016.0371#d1e605)). Nous pouvons relier chacune de ces questions de santé publique à une série de tâches d'analyse des données relatives aux épidémies. Plus ces tâches sont efficaces et fiables, plus nous pouvons répondre rapidement et avec précision aux questions sous-jacentes.

Epiverse-TRACE vise à fournir un écosystème logiciel pour [**l'analyse des épidémies**](reference.md#outbreakanalytics) grâce à des logiciels intégrés, généralisables et évolutifs pilotés par la communauté. Nous soutenons le développement de nouveaux progiciels R, nous aidons à relier les outils existants pour les rendre plus conviviaux et nous contribuons à une communauté de pratique composée d'épidémiologistes de terrain, de scientifiques des données, de chercheurs de laboratoire, d'analystes d'agences de santé, d'ingénieurs en logiciel et bien d'autres encore.

### Tutoriels Epiverse-TRACE

Nos tutoriels sont construits autour d'un pipeline d'analyse d'épidémies divisé en trois étapes : **Tâches préliminaires**, **Tâches intermédiaires** et **Tâches tardives**. Les résultats des tâches accomplies au cours des étapes précédentes alimentent généralement les tâches requises pour les étapes ultérieures.

![Aperçu des thèmes abordés dans le cadre du tutorat](https://epiverse-trace.github.io/task_pipeline-minimal.svg)

Chaque tâche a son site web de tutorat et chaque site web de tutorat consiste en un ensemble d'épisodes couvrant différents sujets.

| [Tutoriels pour les premières tâches ➠](https://epiverse-trace.github.io/tutorials-early/)                                                                                                                                | [Didacticiels pour les tâches intermédiaires ➠](https://epiverse-trace.github.io/tutorials-middle)                                                                                                                                          | [Travaux dirigés tardifs ➠](https://epiverse-trace.github.io/tutorials-late/)                                                                   | 
| ------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| Lire et nettoyer les données de l'affaire, et établir une liste de contrôle                                                     | Analyse et prévision en temps réel                                                                                                        | Modélisation de scénarios                                          | 
| Lire, nettoyer et valider les données des cas, convertir les données de la liste des lignes en incidence pour la visualisation. | Accéder aux distributions des retards et estimer les paramètres de transmission, prévoir les cas, estimer la gravité et la superposition. | Simulez la propagation de la maladie et étudiez les interventions. | 

Chaque épisode contient :

- **Vue d'ensemble** Cet épisode décrit les questions auxquelles il sera répondu et les objectifs de l'épisode.
- **Conditions préalables** La description des épisodes/paquets qui doivent idéalement être couverts avant l'épisode en cours.
- **Exemple de code R** Le site web de la Commission européenne contient des exemples de code R afin que vous puissiez travailler sur les épisodes sur votre propre ordinateur.
- **Défis** Les défis : des défis à relever pour tester votre compréhension.
- **Explicatifs** Les Explicateurs sont des boîtes qui vous permettent de mieux comprendre les concepts mathématiques et de modélisation.

Consultez également le site [glossaire](./reference.md) pour connaître les termes qui ne vous sont pas familiers.

### Paquets Epiverse-TRACE R

Notre stratégie consiste à incorporer progressivement des **R spécial** dans un pipeline d'analyse traditionnel. Ces progiciels devraient combler les lacunes dans les tâches spécifiques à l'épidémiologie en réponse aux épidémies.

![Dans le cadre de l'analyse de l'épidémie de grippe aviaire, le **R** l'unité fondamentale du code partageable est le **paquet**. Un paquetage regroupe du code, des données, de la documentation et des tests et est facile à partager avec d'autres ([Wickham et Bryan, 2023](https://r-pkgs.org/introduction.html))](episodes/fig/pkgs-hexlogos-2.png)

:::::::::::::::::::::::::::: prereq

Ce contenu suppose une connaissance intermédiaire de R. Ces tutoriels sont pour vous si :

- Vous savez lire des données dans R, les transformer et les remodeler, et créer une grande variété de graphiques.
- Vous connaissez les fonctions de `{dplyr}`, `{tidyr}` et `{ggplot2}`
- Vous pouvez utiliser le tube magrittr `%>%` et/ou le tuyau natif `|>`.

Nous attendons des apprenants qu'ils soient familiarisés avec les concepts de base de la statistique, des mathématiques et de la théorie des épidémies, mais PAS avec une connaissance intermédiaire ou experte de la modélisation.

::::::::::::::::::::::::::::

## Configuration du logiciel

Suivez ces deux étapes :

### 1\. Installez ou mettez à jour R et RStudio

R et RStudio sont deux logiciels distincts :

- **R** est un langage de programmation et un logiciel utilisé pour exécuter du code écrit en R.
- **RStudio** est un environnement de développement intégré (IDE) qui facilite l'utilisation de R. Nous vous recommandons d'utiliser RStudio pour interagir avec R.

Pour installer R et RStudio, suivez les instructions suivantes <https://posit.co/download/rstudio-desktop/>.

::::::::::::::::::::::::::::: callout

### Déjà installé ?

Ne perdez pas de temps : C'est le moment idéal pour vous assurer que votre installation R est à jour.

Ce tutoriel nécessite **R version 4.0.0 ou ultérieure**.

:::::::::::::::::::::::::::::

Pour vérifier si votre version de R est à jour :

- Dans RStudio, votre version de R sera imprimée en [la fenêtre de la console](https://docs.posit.co/ide/user/ide/guide/code/console.html). Ou exécutez `sessionInfo()`.

- **Pour mettre à jour R** téléchargez et installez la dernière version à partir du site [site web du projet R](https://cran.rstudio.com/) pour votre système d'exploitation.
  
  - Après l'installation d'une nouvelle version, vous devrez réinstaller tous vos paquets avec la nouvelle version.
  
  - Pour Windows, l'option `{installr}` peut mettre à jour votre version de R et migrer votre bibliothèque de paquets.

- **Pour mettre à jour RStudio** ouvrez RStudio et cliquez sur
  `Help > Check for Updates`. Si une nouvelle version est disponible, suivez les instructions suivantes
  instructions à l'écran.

::::::::::::::::::::::::::::: callout

### Vérifiez régulièrement les mises à jour

Bien que cela puisse paraître effrayant, c'est **bien plus courant** de rencontrer des problèmes dus à l'utilisation de versions obsolètes de R ou de paquets R. Il est donc recommandé de se tenir au courant des dernières versions de R, de RStudio et de tous les paquets que vous utilisez régulièrement.

:::::::::::::::::::::::::::::

### 2\. Installez les paquets R requis

Ouvrez RStudio et **copiez et collez** le morceau de code suivant dans la fenêtre [fenêtre de la console](https://docs.posit.co/ide/user/ide/guide/code/console.html) puis appuyez sur la touche <kbd>Entrer</kbd> (Windows et Linux) ou <kbd>Retour</kbd> (MacOS) pour exécuter la commande :

```r
# for episodes on read, clean, validate and visualize linelist

if(!require("pak")) install.packages("pak")

new_packages <- c(
  "epiverse-trace/readepi@readepi_no_his_spc_deps",
  "cleanepi@1.1.0",
  "reactable",
  "rio",
  "here",
  "DBI",
  "RSQLite",
  "dbplyr",
  "linelist",
  "simulist",
  "incidence2",
  "epiverse-trace/tracetheme",
  "tidyverse"
)

pak::pkg_install(new_packages)
```

Ces étapes d'installation peuvent vous demander `? Do you want to continue (Y/n)` écrire `Y` et d'appuyer sur <kbd>Entrez</kbd>.

::::::::::::::::::::::::::::: spoiler

### obtenez-vous une erreur avec les paquets epiverse-trace ?

Si vous obtenez un message d'erreur lors de l'installation de {simulist} essayez ce code alternatif :

```r
# for simulist
install.packages("simulist", repos = c("https://epiverse-trace.r-universe.dev"))

# for tracetheme
install.packages("tracetheme", repos = c("https://epiverse-trace.r-universe.dev"))
```

:::::::::::::::::::::::::::::

::::::::::::::::::::::::::::: spoiler

### obtenez-vous un message d'erreur avec un autre paquet ?

Essayez d'utiliser la fonction de code classique pour installer un paquet, par exemple :

```r
install.packages("rio")
```

:::::::::::::::::::::::::::::

::::::::::::::::::::::::::: spoiler

### Que faire si une erreur persiste ?

Si le mot-clé du message d'erreur contient une chaîne de caractères comme `Personal access token (PAT)` vous devrez peut-être [configurer votre jeton GitHub](https://epiverse-trace.github.io/git-rstudio-basics/02-setup.html#set-up-your-github-token).

Installez d'abord ces paquets R :

```r
if(!require("pak")) install.packages("pak")

new <- c("gh",
         "gitcreds",
         "usethis")

pak::pak(new)
```

Ensuite, suivez ces trois étapes pour [configurer votre jeton GitHub (lisez ce guide étape par étape)](https://epiverse-trace.github.io/git-rstudio-basics/02-setup.html#set-up-your-github-token):

```r
# Generate a token
usethis::create_github_token()

# Configure your token 
gitcreds::gitcreds_set()

# Get a situational report
usethis::git_sitrep()
```

Réessayez d'installer {epiparameter}:

```r
if(!require("remotes")) install.packages("remotes")
remotes::install_github("epiverse-trace/epiparameter")
```

Si l'erreur persiste, [contactez-nous](#your-questions)!

:::::::::::::::::::::::::::

Vous devez mettre à jour **tous les paquets** nécessaires au tutoriel, même si vous les avez installés relativement récemment. Les nouvelles versions apportent des améliorations et d'importantes corrections de bogues.

Lorsque l'installation est terminée, vous pouvez essayer de charger les paquets en collant le code suivant dans la console :

```r
# for episodes on read, clean, validate and visualize linelist

library(readepi)
library(cleanepi)
library(reactable)
library(rio)
library(here)
library(DBI)
library(RSQLite)
library(dbplyr)
library(linelist)
library(simulist)
library(incidence2)
library(tracetheme)
library(tidyverse)
```

Si vous ne voyez PAS d'erreur comme `there is no package called '...'` vous êtes prêt à partir ! Si c'est le cas, [contactez-nous](#your-questions)!

### 3\. Créez un projet et un dossier RStudio

Nous vous suggérons d'utiliser les projets RStudio.

::::::::::::::::::::::::::::::::: checklist

#### Suivez les étapes suivantes

- **Créer un projet RStudio**. Si nécessaire, suivez cette procédure [guide pratique sur "Hello RStudio Projects"](https://docs.posit.co/ide/user/ide/get-started/#hello-rstudio-projects) pour créer un nouveau projet dans un nouveau répertoire.
- **Créez** l'entreprise `data/` dans le projet RStudio ou dans le répertoire correspondant. Utilisez l'option `data/` pour **enregistrer** les ensembles de données à télécharger.

Le répertoire d'un projet RStudio nommé par exemple `training` devrait ressembler à ceci :

```
training/
|__ data/
|__ training.Rproj
```

**Projets RStudio** vous permet d'utiliser *fichier relatif* relatifs par rapport à l'élément `R` projet,
ce qui rend votre code plus portable et moins sujet aux erreurs.
Évite d'utiliser `setwd()` avec *chemins absolus*
comme `"C:/Users/MyName/WeirdPath/training/data/file.csv"`.

:::::::::::::::::::::::::::::::::

### 4\. Créez un compte GitHub

Nous pouvons utiliser [GitHub](https://github.com) comme plateforme de collaboration pour communiquer sur les problèmes liés aux paquets et s'engager dans des projets de développement. [discussions au sein de la communauté](https://github.com/orgs/epiverse-trace/discussions).

::::::::::::::::::::::::::::::::: checklist

#### Suivez toutes ces étapes

1. Allez à l'adresse suivante <https://github.com> et suivez le lien "S'inscrire" en haut à droite de la fenêtre.
2. Suivez les instructions pour créer un compte.
3. Vérifiez votre adresse électronique auprès de GitHub.

<Configurez l'authentification multi-facteurs (voir ci-dessous).

:::::::::::::::::::::::::::::::::

## Jeux de données

### Téléchargez les données

Nous téléchargerons les données directement à partir de R au cours du tutoriel. Cependant, si vous vous attendez à des problèmes de réseau, il peut être préférable de télécharger les données à l'avance et de les stocker sur votre machine.

Les fichiers de données pour le tutoriel peuvent être téléchargés manuellement ici :

- <https://epiverse-trace.github.io/tutorials-early/data/ebola_cases_2.csv>
- <https://epiverse-trace.github.io/tutorials-early/data/Marburg.zip>
- <https://epiverse-trace.github.io/tutorials-early/data/simulated_ebola_2.csv>
- <https://epiverse-trace.github.io/tutorials-early/data/delta_full-messy.csv>
- <https://epiverse-trace.github.io/tutorials-early/data/linelist-date_of_birth.csv>

## Vos questions

Si vous avez besoin d'aide pour installer le logiciel ou si vous avez d'autres questions concernant ce tutoriel, veuillez envoyer un courriel à l'adresse suivante [andree.valle-campos@lshtm.ac.uk](mailto:andree.valle-campos@lshtm.ac.uk)


