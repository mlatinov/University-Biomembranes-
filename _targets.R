
#### Libraries ####
library(targets)
library(stantargets)
library(tidyverse)

#### Source Functions ####
tar_source("functions/")

## Pipeline ##
list(

  #### 1 Electroinduced erythrocyte lysis ####

  ##### 1.1 Load Experimental Data #####
  tar_target(
    name = erythrocyte_lysis_data,
    command = read_csv("data/erythrocyte_lysis_data.csv")
    ),

  ##### 1.2 Generative Model ####
  tar_target(
    name = gen_erythrocyte_lysis_hill,
    command = gen_hill(n = 200)
  ),

  ##### 1.3 Exploratory Data Analysis and Gen Comparison #####
  tar_target(
    name = eda_erythrocyte_lysis,
    command = explore_erythrocyte_lysis(
      sample_data = erythrocyte_lysis_data,
      gen_data = gen_erythrocyte_lysis_hill
      )
  ),

  ##### 1.4 Stan Hill Model Parameter Recovery #####
  tar_stan_mcmc(
    name = hill_recover,
    stan_files = "stan_scripts/erythrocyte_lysis_model_hill.stan",
    data = list(
      N = nrow(gen_erythrocyte_lysis_hill),
      E = gen_erythrocyte_lysis_hill$Electric_field_V_cm,
      H_percent = gen_erythrocyte_lysis_hill$H_percent
    ),
    chains = 4,
    iter_sampling = 4000,
    seed = 123
    ),

  ##### 1.5 Stan Hill Model with Experimental data #####
  tar_stan_mcmc(
    name = hill,
    stan_files = "stan_scripts/erythrocyte_lysis_model_hill.stan",
    data = list(
      N = nrow(erythrocyte_lysis_data),
      E = erythrocyte_lysis_data$Electric_field_V_cm,
      H_percent = erythrocyte_lysis_data$H_percent
    ),
    chains = 4,
    iter_sampling = 4000,
    seed = 123
  ),

  ##### 1.6 Bayesian Plots ####
  tar_target(
    name = bayes_plot_erythrocyte_lysis_hill,
    command = plot_bayes_general(
      draws = hill_draws_erythrocyte_lysis_model_hill,
      y = erythrocyte_lysis_data$H_percent,
      data = erythrocyte_lysis_data
    )
  ),

  ##### 1.7 Plot Pre-processing for Paper ####
  tar_target(
    name = erythrocyte_lysis_hill_paper_plots,
    command = prep_hill_paper_plots(
      plots = bayes_plot_erythrocyte_lysis_hill$posterior_summary
      )
  )

)









