
#### Function to Generate Data
gen_hill <- function(
  seed = set.seed(123),
  n = 500,              # N of Sim observations
  u_min_par = c(2,20),   # μ_min  - Base Lysis when U = 0
  u_max_alpha = c(20,2), # μ_max  - Max Lysis when U = inf
  K  = c(log(1500),0.5), # K      - E (ED₅₀)
  ni = c(3,1),           # ni     - Slope
  phi = c(2,0.1)         # phi    - precision
  ){

  #### Hill Equation μ = μ_min + (μ_max - μ_min) / [1 + (K/U)ⁿ] ####

  #### Priors for the parameters ####
  u_min <- rbeta(1, u_min_par[1], u_min_par[2])
  u_max <- rbeta(1, shape1 = u_max_alpha[1], shape2 = u_max_alpha[2])
  K <- rlnorm(1, meanlog = K[1],sdlog = K[2])
  ni <- rgamma(1, shape = ni[1], rate = ni[2])
  phi <- rgamma(1, shape = phi[1], rate = phi[2])

  #### Input Data ####
  E <- seq(from = 750 , to = 1850, length.out = n)

  #### Calculate the u where y∼Beta(μ⋅ϕ, (1−μ)⋅ϕ) and u is the result of the Hill equation ####
  mu_i <- u_min + (u_max - u_min) / (1 + (K/E)^ni)

  #### Sample from the Beta Distribution  y∼Beta(μ⋅ϕ, (1−μ)⋅ϕ ####
  hemolysis <- rbeta(
    n = n,
    shape1 = mu_i * phi,
    shape2 = (1 - mu_i) * phi
    )

  ## Combine into Dataframe ##
  gen_data <- data.frame(
    Electric_field_V_cm = E,
    H_percent = hemolysis * 100
  )

  #### Return ####
  return(gen_data)
}
