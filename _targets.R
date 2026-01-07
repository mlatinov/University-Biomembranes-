
#### Libraries ####
library(targets)
library(stantargets)
library(tidyverse)

#### Source Functions ####
tar_source("functions/")

## Pipeline ##
list(

  #### Electroinduced erythrocyte lysis ####

  ##### Load Experimental Data #####
  tar_target(
    name = erythrocyte_lysis_data,
    command = read_csv("data/erythrocyte_lysis_data.csv")
    ),

  ##### Generative Model ####
  tar_target(
    name = gen_erythrocyte_lysis_hill,
    command = gen_hill(n = 1000)
  ),

  ##### Exploratory Data Analysis and Gen Comparison #####
  tar_target(
    name = eda_erythrocyte_lysis,
    command = explore_erythrocyte_lysis(
      sample_data = erythrocyte_lysis_data,
      gen_data = gen_erythrocyte_lysis_hill
      )
  ),

  #### Prior Predictive Checks ####
  tar_stan_mcmc(
    name = erythrocyte_lysis_model,
    stan_files = "stan_scripts/erythrocyte_lysis_model_hill.stan",
    data = list(),
    chains = 4,
    iter_sampling = 1000,
    seed = 123
    )

)









