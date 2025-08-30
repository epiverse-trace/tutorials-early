---
title: Mise en place
---

## Motivation

**Des épidémies** de maladies infectieuses peuvent apparaître à cause de
différents agents pathogènes et dans différents contextes. Cependant, elles
aboutissent généralement à des questions de santé publique similaires, allant
de la compréhension des dynamiques de transmission et de la gravité clinique à
l'examen de l'effet des mesures de contrôle ([Cori et al. 2017](https://royalsocietypublishing.org/doi/10.1098/rstb.2016.0371#d1e605)).
Nous pouvons relier chacune de ces questions de santé publique à une série de
tâches d'analyse des données épidémidémiologiques. L'efficacité et la
fiabilité de ces tâches peuvent améliorer la rapidité et la précision de la
réponse aux questions sous-jacentes.

Epiverse-TRACE vise à fournir un écosystème logiciel pour
**l'analyse des épidémies**, avec des logiciels communautaires intégrés,
généralisables et évolutifs. Nous:

* soutenons le développement de nouveaux packages R,
* facilitons l'interconnexion des outils existants pour les rendre plus
conviviaux et
* contribuons à une communauté de pratique regroupant épidémiologistes de
terrain, data scientists, chercheurs en laboratoire, analystes d'agences de
santé, ingénieurs logiciels, etc.

### Tutoriels Epiverse-TRACE

Nos tutoriels s'articulent autour d'un pipeline d'analyse de données
épidémiologiques divisé en trois étapes: tâches initiales (au début de
l'épidémie), tâches intermédiaires (quelques semaine après le début de
l'épidémie) et tâches tardives (en pleine épidémie). Les résultats des tâches
réalisées au début de l'épidémie servent généralement de données d'entrée pour
les tâches requises au cours des étapes suivantes.

![Aperçu des thèmes abordés dans le cadre de ce tutoriel](https://epiverse-trace.github.io/task_pipeline-minimal.svg)

Nous avons conçu un site Web pour chaque tâche de ce tutoriel. Chaque site Web
est composé d'un ensemble d'épisodes couvrant différents sujets.

| [Tutoriels pour les premières tâches ➠](https://epiverse-trace.github.io/tutorials-early/)                                                                                                                                | [Didacticiels pour les tâches intermédiaires ➠](https://epiverse-trace.github.io/tutorials-middle)                                                                                                                                          | [Travaux dirigés tardifs ➠](https://epiverse-trace.github.io/tutorials-late/)                                                                   | 
| ------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| Lire et nettoyer les données épidémiologiques, et concevoir un object de la classe {linelist}                                                    | Analyse et prévision en temps réel                                                                                                        | Modélisation de scénarios                                          | 
| Lire, nettoyer et valider les données épidémiologiques, convertir un linelist en incidence pour la visualisation. | Accéder aux distributions des délais épidémiologiques et estimer les paramètres de transmission, prédire le nombre de cas, estimer la gravité clinique et la super-propagation. | Simulez la propagation de la maladie et étudiez les interventions. | 

Chaque épisode contient les sections suivantes:

- **Vue d'ensemble:** décrit les questions auxquelles nous allons répondre
et les objectifs de l'épisode.
- **Conditions préalables:** décrit les épisodes qui doivent idéalement être
complétés au préalable. Elle décrit aussi les librairies qui vont être utilisées
au cours de l'épisode.
- **Exemple de code R:** des exemples de code R afin que vous puissiez
reproduire les analyses sur votre propre ordinateur.
- **Défis:** des défis à relever pour tester votre compréhension.
- **Explicatifs:** des boîtes qui vous permettent de mieux comprendre les
concepts mathématiques et de modélisation.

Consultez également le site [glossaire](./reference.md) pour connaître les
termes qui ne vous sont pas familiers.

### Les Packages R de Epiverse-TRACE

Notre stratégie consiste à intégrer progressivement des **packages R**
spécialisés à un pipeline traditionnel d'analyse de données. Ces librairies
devraient combler les lacunes notées dans ces pipelines d'analyse
épidémiologiques qui sont conçus en vue d'apporter des réponses aux épidémies.

![L'unité fondamentale de partage de code dans **R** est le **package**. Un package regroupe du code, des données, de la documentation et des tests et est facile à partager avec d'autres ([Wickham et Bryan, 2023](https://r-pkgs.org/introduction.html))](../../../episodes/fig/pkgs-hexlogos-2.png)

:::::::::::::::::::::::::::: prereq

Ce contenu suppose une connaissance intermédiaire de R. Ces épisodes sont pour
vous si :

- Vous savez lire des données dans R, les transformer et les reformater, et créer une variété de graphiques.
- Vous connaissez les fonctions de `{dplyr}`, `{tidyr}` et `{ggplot2}`
- Vous pouvez utiliser les opérateurs pipe de `{magrittr}` (`%>%`) et/ou celui
de la librairie de base de R (`|>`).

Nous supposons que les apprenants se sont familiarisés avec les concepts de base
de la statistique, des mathématiques et de la théorie des épidémies, mais NE
DISPOSENT PAS FORCÉMENT de connaissances intermédiaires ou expertes en
modélisation mathématique des maladies infectieuses.

::::::::::::::::::::::::::::

## Configuration des logiciels

Suivez ces deux étapes :

### 1. Installez ou mettez à jour R et RStudio

R et RStudio sont deux logiciels distincts :

- **R** est un langage de programmation et un logiciel utilisé pour exécuter du
code écrit en R.
- **RStudio** est un environnement de développement intégré (IDE) qui facilite
l'utilisation de R. Nous vous recommandons d'utiliser RStudio pour interagir
avec R.

Pour installer R et RStudio, suivez les instructions suivantes
<https://posit.co/download/rstudio-desktop/>.

::::::::::::::::::::::::::::: callout

### Déjà installé ?

Ne perdez pas de temps : C'est le moment idéal pour vous assurer que votre
version de R est à jour.

Ce tutoriel nécessite **la version 4.0.0 de R ou des versions plus récentes**.

:::::::::::::::::::::::::::::

Pour vérifier si votre version de R est à jour :

- Dans RStudio, votre version de R sera imprimée dans
[la fenêtre de la console](https://docs.posit.co/ide/user/ide/guide/code/console.html).
Vous pouvez également exécuter `sessionInfo()`.

- **Pour mettre à jour R** téléchargez et installez la dernière version à partir
du [site web du projet R](https://cran.rstudio.com/) pour votre système
d'exploitation.

  - Après l'installation d'une nouvelle version, vous devrez réinstaller tous vos librairies avec la nouvelle version.
  
  - Pour Windows, la librairie `{installr}` permet de mettre à jour votre version de R et migrer votre bibliothèque de librairies.

- **Pour mettre à jour RStudio** ouvrez RStudio et cliquez sur
`Help > Check for Updates`. Si une nouvelle version est disponible, suivez les
instructions qui s'affichent à l'écran.

::::::::::::::::::::::::::::: callout

### Vérifiez régulièrement les mises à jour

Bien que cela puisse paraître effrayant, il est **plus courant** de
rencontrer des problèmes à cause de l'utilisation de versions obsolètes de R ou
de librairies R. Il est donc recommandé de mettre à jour les versions de R, de
RStudio et de tous les packages que vous utilisez régulièrement.

:::::::::::::::::::::::::::::

### 2. Vérifier et installer les outils de compilation

Certains paquets nécessitent un ensemble d'outils complémentaires pour être compilés.
Ouvrez RStudio et **copiez-collez** le bloc de code suivant dans la 
[fenêtre de console](https://docs.posit.co/ide/user/ide/guide/code/console.html),
puis appuyez sur <kbd>Enter</kbd> (Windows et Linux) ou <kbd>Return</kbd> (MacOS) pour exécuter la commande :

```r
if(!require("pkgbuild")) install.packages("pkgbuild")
pkgbuild::check_build_tools(debug = TRUE)
```

Nous attendons un message similaire à celui ci-dessous :

```output
Your system is ready to build packages!
```

Si les outils de compilation ne sont pas disponibles, cela déclenchera une installation automatique.

1. Exécutez la commande dans la console.
2. Ne l'interrompez pas, attendez que R affiche le message de confirmation.
3. Une fois cela fait, redémarrez votre session R (ou redémarrez simplement RStudio) pour vous assurer que les modifications prennent effet.

Si l'installation automatique **ne fonctionne pas**, vous pouvez les installer manuellement en fonction de votre système d'exploitation.

::::::::::::::::::::::::::::: tab

### Windows

Les utilisateurs Windows auront besoin d'une installation fonctionnelle de `Rtools` afin de compiler le paquet à partir du code source.  
`Rtools` n'est pas un paquet R, mais un logiciel que vous devez télécharger et installer.
Nous vous suggérons de suivre les étapes suivantes :

- **Installez `Rtools`**. Téléchargez le programme d'installation de `Rtools` à partir de <https://cran.r-project.org/bin/windows/Rtools/>. Installez-le en conservant les sélections par défaut.
- Fermez et rouvrez RStudio afin qu'il puisse reconnaître la nouvelle installation.

### Mac

Les utilisateurs Mac doivent suivre deux étapes supplémentaires, comme indiqué dans ce [guide de configuration de la chaîne d'outils C pour Mac](https://github.com/stan-dev/rstan/wiki/Configuring-C---Toolchain-for-Mac) :

- Installez et utilisez [macrtools](https://mac.thecoatlessprofessor.com/macrtools/) pour configurer la chaîne d'outils C++
- Activez certaines optimisations du compilateur.

### Linux

Les utilisateurs Linux doivent suivre des instructions spécifiques à leur distribution. Vous les trouverez dans ce [guide de configuration de la chaîne d'outils C pour Linux](https://github.com/stan-dev/rstan/wiki/Configuring-C-Toolchain-for-Linux).

:::::::::::::::::::::::::::::

::::::::::::: callout

### Vérification de l'environnement

Cette étape nécessite des privilèges d'administrateur pour installer le logiciel.

Si vous ne disposez pas des droits d'administrateur dans votre environnement actuel :  

- Essayez d'exécuter le tutoriel sur votre **ordinateur personnel** auquel vous avez un accès complet.  
- Utilisez un **environnement de développement préconfiguré** (par exemple, [Posit Cloud](https://posit.cloud/)).  
- Demandez à votre **administrateur système** d'installer les logiciels requis pour vous.  

:::::::::::::

### 3. Installez les librairies R requises

Ouvrez RStudio et **copiez et collez** le morceau de code suivant dans la
[fenêtre de la console](https://docs.posit.co/ide/user/ide/guide/code/console.html)
puis appuyez sur la touche <kbd>Entrer</kbd> (Windows et Linux) ou
<kbd>Retour</kbd> (MacOS) pour exécuter la commande :

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

Ces étapes d'installation peuvent vous demander `? Do you want to continue (Y/n)`
écrivez `Y` et d'appuyer sur <kbd>Entrez</kbd>.

::::::::::::::::::::::::::::: spoiler

### obtenez-vous un message d'erreur lors de l'installation d'une librairie de epiverse-trace ?

Si vous rencontrez des difficultés pour installer `{tracetheme}`, essayer
d'utiliser le code suivant.
```r
install.packages("tracetheme", repos = c("https://epiverse-trace.r-universe.dev"))
```

:::::::::::::::::::::::::::::

::::::::::::::::::::::::::::: spoiler

### obtenez-vous un message d'erreur lors de l'installation de d'autres librairies ?

Vous pouvez utiliser la function `install.packages()` de la librairie de base de
R.

```r
install.packages("rio")
```

:::::::::::::::::::::::::::::

::::::::::::::::::::::::::: spoiler

### Que faire si une erreur persiste ?

Si le mot-clé du message d'erreur contient ceci: `Personal access token (PAT)`,
vous devrez peut-être [configurer votre token GitHub](https://epiverse-trace.github.io/git-rstudio-basics/02-setup.html#set-up-your-github-token).

Installez d'abord ces librairies :

```r
if(!require("pak")) install.packages("pak")

new <- c("gh",
         "gitcreds",
         "usethis")

pak::pak(new)
```

Ensuite, suivez ces trois étapes pour [configurer votre token GitHub (lisez ce guide étape par étape)](https://epiverse-trace.github.io/git-rstudio-basics/02-setup.html#set-up-your-github-token):

```r
# creer un token
usethis::create_github_token()

# configurer votre token 
gitcreds::gitcreds_set()

# obtenir un rapport de votre situation
usethis::git_sitrep()
```

Puis Réessayez d'installer {tracetheme} par example:

```r
if(!require("remotes")) install.packages("remotes")
remotes::install_github("epiverse-trace/tracetheme")
```

Si l'erreur persiste, [contactez-nous](#your-questions)!

:::::::::::::::::::::::::::

Vous devez mettre à jour **toutes les librairies** nécessaires à ce tutoriel,
même si vous les avez installés récemment. Les nouvelles versions contiennent
des améliorations et d'importantes corrections de bugs.

Lorsque l'installation est terminée, vous pouvez essayer de charger les packages
en copiant et collant le code suivant dans la console :

```r
# pour les episodes on lire, nettoyer, valider and visualiser les donnnees

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

Si vous ne voyez PAS d'erreur comme `there is no package called '...'` vous êtes
prêt à commencer ! Si c'est le cas, [contactez-nous](#your-questions)!

### 4. Créez un projet et un dossier RStudio

Nous vous suggérons d'utiliser les projets RStudio.

::::::::::::::::::::::::::::::::: checklist

#### Suivez les étapes suivantes

- **Créer un projet RStudio**. Si nécessaire, suivez cette procédure [guide pratique sur "Hello RStudio Projects"](https://docs.posit.co/ide/user/ide/get-started/#hello-rstudio-projects) pour créer un nouveau projet dans un nouveau répertoire.
- **Créez** le dossier `data/` dans le projet RStudio. **Sauvegarder**
l'ensemble de données à télécharger dans ce dossier `data/`. 

Le répertoire d'un projet RStudio nommé par exemple `training` devrait
ressembler à ceci :

```
training/
|__ data/
|__ training.Rproj
```

**Projets RStudio** vous permet d'utiliser *des chemin d'accès relatifs* par
rapport au répertoire contenant le projet. Ce qui rend votre code plus portable
et moins sujet aux erreurs.
Évite d'utiliser `setwd()` avec des *chemins absolus* comme
`"C:/Users/MyName/WeirdPath/training/data/file.csv"`.

:::::::::::::::::::::::::::::::::

### 5. Créez un compte GitHub

Nous pouvons utiliser [GitHub](https://github.com) comme plateforme de
collaboration pour communiquer sur les problèmes liés aux librairies et
s'engager dans des [discussions au sein de la communauté](https://github.com/orgs/epiverse-trace/discussions).

::::::::::::::::::::::::::::::::: checklist

#### Suivez toutes ces étapes

1. Allez dans <https://github.com> et suivez le lien "S'inscrire" en haut à
droite de la fenêtre.
2. Suivez les instructions pour créer un compte.
3. Vérifiez votre adresse électronique auprès de GitHub.

:::::::::::::::::::::::::::::::::

## Les jeux de données

### Téléchargez les données

Nous téléchargerons les données directement à partir de R au cours du tutoriel.
Cependant, si vous vous attendez à des problèmes de réseau, il peut être
préférable de télécharger les données à l'avance et de les stocker sur votre
machine.

Les fichiers contenant les données pour le tutoriel peuvent être téléchargés
manuellement à partir d'ici :

- <https://epiverse-trace.github.io/tutorials-early/data/ebola_cases_2.csv>
- <https://epiverse-trace.github.io/tutorials-early/data/Marburg.zip>
- <https://epiverse-trace.github.io/tutorials-early/data/simulated_ebola_2.csv>
- <https://epiverse-trace.github.io/tutorials-early/data/delta_full-messy.csv>
- <https://epiverse-trace.github.io/tutorials-early/data/linelist-date_of_birth.csv>

## Vos questions

Si vous avez besoin d'aide pour installer les logiciels et les librairies ou si
vous avez d'autres questions concernant ce tutoriel, veuillez envoyer un
courriel à l'adresse suivante
[andree.valle-campos@lshtm.ac.uk](mailto:andree.valle-campos@lshtm.ac.uk)


