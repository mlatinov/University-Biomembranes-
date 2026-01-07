
#### General function to plot Bayesian Model ####
plot_bayes_general <- function(
    draws,
    data,
    y = sample_data$H_percent / 100,
    pars_diag = c("u_min","u_max","K","ni","phi"),         # Parameters to check
    pars_summarize_general = c("u_min","u_max","ni","K"),  # Parameters to get the Posterior summary
    pars_summarize_specific = c("delta_mu","hill_slope","effective_range"),
    pars_summarize_group = c("E_target[2]","E_target[3]","E_target[4]"))
    {

  #### Libraries and Themes ####
  library(bayesplot)
  library(posterior)

  color_scheme_set("gray")
  bayesplot_theme_set(new = theme_minimal())

  # Convert to array format for plots
  draws_plot <- as_draws_array(draws)

  #### Convergents Diagnostics ####

  ## Trace plots ##
  trace_plot <- mcmc_trace(
    x = draws_plot,
    pars = pars_diag
    )

  ## Autocorrelation ##
  auto_chains <- mcmc_acf(
    x = draws_plot,
    pars = pars_diag
    )

  #### Posterior Predictive Checks ####

  ## Collect samples from the Posterior Predictive Distribution
  y_rep <- draws %>%
    as_draws_df() %>%
    dplyr::select(starts_with("y_rep")) %>%
    as.matrix()

  ## Posterior Predictive Density Plot ###
  pp_dens_plot <- ppc_dens_overlay(y = y,yrep = y_rep[1:200, ])

  #### Sumarize Posterior ####

  ## Posterior Histograms of the General Parameters
  posterior_histogram_general <- mcmc_hist(
    x = draws_plot,
    pars = pars_summarize_general
    )

  ## Posterior Histogram of Specific Derived Metrics
  posterior_histogram_specific <- list()

  for(i in seq_along(pars_summarize_specific)){
    posterior_histogram_specific[[i]] <- mcmc_hist(
      x = draws_plot,
      pars = pars_summarize_specific[i]
    )
  }

  # Name the List
  names(posterior_histogram_specific) <- pars_summarize_specific

  ## If we declare specific group parameters
  if(!is.null(pars_summarize_group)){
    posterior_histogram_group <- mcmc_intervals(
      x = draws_plot,
      pars = pars_summarize_group
      )
  } else {
    posterior_histogram_group <- NULL
  }

  #### Conditional Effect ####

  ## Create a grid for E values
  E_grid <- seq(from = 750, to = 1850, length.out = 100)

  ## For Every point in the Grid Calculate u(E)
  mu_post <- lapply(1:nrow(draws), function(i){
    u_min <- draws$u_min[i]
    u_max <- draws$u_max[i]
    K_val <- draws$K[i]
    ni <- draws$ni[i]
    sapply(E_grid, function(E) u_min + (u_max - u_min)/(1 + (K_val/E)^ni))
  })

  ## Convert to Dataframe for ploting
  mu_post_df <- as.data.frame(do.call(rbind, mu_post))
  mu_post_df_long <- pivot_longer(
    mu_post_df, cols = everything(),
    names_to = "E_index", values_to = "mu")

  mu_post_df_long$E <- rep(E_grid, times = nrow(draws))

  ## Summarize the Results
  mu_summary <- mu_post_df_long %>%
    group_by(E) %>%
    summarise(
      median = median(mu),
      lower = quantile(mu, 0.05),
      upper = quantile(mu, 0.95)
    )

  ## Plot the Conditional Effect
  conditional_effect <-
    ggplot(mu_summary, aes(x = E, y = median)) +
    geom_smooth(color = "red") +
    geom_smooth(
      data = data,
      mapping = aes(x = Electric_field_V_cm,y = H_percent/100),
      se = FALSE)+
    geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2, fill = "gray4") +
    labs(
      title = "Очаквана хемолиза μ(E) с 90% доверителен интервал",
      x = "Електрично поле (V/cm)",
      y = "Очаквана хемолиза μ(E)"
    )

  #### Retrun ####
  return(list(
    diagnostics = list(
      Trace_plot = trace_plot,
      Autocorrelation_of_the_chains = auto_chains,
      Posterior_Predictive_Density_plot = pp_dens_plot
      ),
    posterior_summary = list(
      conditional_effect_plot = conditional_effect,
      Posterior_Histograms_General_Parameters = posterior_histogram_general,
      Posterior_Histogram_Specific_Parameters = posterior_histogram_specific,
      Posterior_Intervals_Group_Parameters = posterior_histogram_group
    )
  ))
}


