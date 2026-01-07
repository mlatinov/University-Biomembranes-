
#### Function to Compare and Explore Generative and Experimental Data ####
explore_erythrocyte_lysis <- function(sample_data,gen_data) {

  #### Libraries ####
  library(patchwork)

  #### Plot Themes ####
  theme_set(theme_minimal())

  #### Sample plot ####
  sample_plot <-
    ggplot(data = sample_data,aes(x = Electric_field_V_cm,y = H_percent))+
    geom_point()+
    geom_smooth(se = FALSE)+
    labs(
      title = "Experimental Data",
      x = "E(Volt/cm)",
      y = "Hemolysis (percent)"
      )

  #### Generative Plot ####
  gen_plot <-
    ggplot(data = gen_data,aes(x = Electric_field_V_cm,y = H_percent))+
    geom_point()+
    geom_smooth(se = FALSE)+
    labs(
      title = "Generative Data",
      x = "E(Volt/cm)",
      y = "Hemolysis (percent)"
    )

  #### Combine Side By Side ####
  combine_plot <- sample_plot + gen_plot

  #### Return ####
  return(combine_plot)

}
