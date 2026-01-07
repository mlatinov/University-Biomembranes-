
#### Function to prepoc Posterior Viz for the Final Paper ####
prep_hill_paper_plots <- function(plots){

  #### Posterior_Histograms_General_Parameters ####
  posterior_general_parameters <- plots$Posterior_Histograms_General_Parameters +
    ggtitle("Вероятностно разпределение на параметерите на Hill Equation")+
    labs(
      y = "Плътност"
    )

  #### Posterior_Intervals_Group_Parameters ####
  posterior_intervals <- plots$Posterior_Intervals_Group_Parameters +
    scale_y_discrete(
      labels = c(
        "E_target[4]" = "25% хемолиза",
        "E_target[3]" = "50% хемолиза",
        "E_target[2]" = "75% хемолиза"
      )
    )+
    labs(
      title = "Електрично поле, необходимо за достигане на фиксирани нива на хемолиза",
      subtitle = "Постериорни интервали за E при 25%, 50% и 75% хемолиза",
      x = "Електрично поле (V/cm)"
    )

  #### Delta Mu ####
  posterior_delta_mu <- plots$Posterior_Histogram_Specific_Parameters$delta_mu +
    labs(
      title = "Динамичен диапазон на очакваната хемолиза (Δμ)",
      subtitle = "Постериорно разпределение на разликата между μ_max и μ_min",
      x = "Δμ",
      y = "Плътност"
    )

  #### Hill Slope ####
  posterior_hill_slope <- plots$Posterior_Histogram_Specific_Parameters$hill_slope +
    labs(
      title = "Стръмнина на кривата електрично поле–хемолиза",
      subtitle = "Постериорно разпределение на наклона при половин максимален ефект за 100 Е",
      x = "Hill slope (Δμ * n / 4K)",
      y = "Плътност"
    )

  #### Return Plots ####
  return(list(
    posterior_general_parameters = posterior_general_parameters,
    posterior_intervals = posterior_intervals,
    posterior_delta_mu = posterior_delta_mu,
    posterior_hill_slope = posterior_hill_slope
  ))
}
