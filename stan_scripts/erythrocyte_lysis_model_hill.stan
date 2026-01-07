
// Input Data
data {
  int <lower=1> N;                         // Number of observations
  vector[N] E;                             // Electric_field_V_cm
  vector<lower=0, upper=100>[N] H_percent;  // Hemolysis procent
}

// Input data Transformation
transformed data{
  // Convert percent 99... back into 0.99
  vector<lower=0, upper=1>[N] H_model;
  H_model = H_percent / 100;
}

// Parameters
parameters {
  real<lower=1e-6, upper=1-1e-6> u_min;   // Base Lysis (0-1)
  real<lower=1e-6, upper=1-1e-6> u_max;   // Max Lysis (0-1)
  real<lower=0> K;                        // Half effect point (V/cm)
  real<lower=1e-6, upper=1-1e-6> phi;     // Precision parameter
  real<lower=0.1, upper=10> ni;           // Hill coefficient
}

// Transform parameters
transformed parameters{
  // Declare mu_i as equal to the Hill Equation
  vector[N] mu_i;
  for(i in 1:N){
    mu_i[i]  = u_min + (u_max - u_min) / (1 + pow(K / E[i], ni)); // Hill Equation
  }
}

// Model Definition
model {
  // Priors
  u_min ~ beta(2, 20);
  u_max ~ beta(20, 2);
  K ~ lognormal(log(1500), 0.5);
  ni ~ gamma(3, 1);
  phi ~ gamma(2, 0.1);

  // Model Likelihoood
  for (i in 1:N) {
    H_model[i] ~ beta(mu_i[i] * phi, (1 - mu_i[i]) * phi);
    }
}

// Additional Calculations
generated quantities {

  // Posterior Predictive Distribution
  vector[N] y_rep;
  for(i in 1:N){
     y_rep[i] = beta_rng(mu_i[i] * phi, (1 - mu_i[i]) * phi);
  }

  // Dymanic Range
  real delta_mu = u_max - u_min;

  // Effective range (10%–90%)
  real E_low  = K * pow( (1 / 0.1) - 1, 1 / ni );
  real E_high = K * pow( (1 / 0.9) - 1, 1 / ni );
  real effective_range = E_low - E_high;

  // Find E-values for specific % hemolysis
  vector[4] H_values;  // Hemolysis Vector
  vector[4] E_target;  // 10,25,50,75%
  H_values[1] = 0.1;
  H_values[2] = 0.25;
  H_values[3] = 0.5;
  H_values[4] = 0.75;

  // Loop over E_values and for every one compute the E for the Specific % Hemolysis
  for (j in 1:4) {
    E_target[j] = K * pow( (1 / H_values[j]) - 1, 1 / ni );
    }

  // Slope at half-max (Hill slope) for 100 E
  real hill_slope = ((u_max - u_min) * ni / (4 * K)) * 100;

}














