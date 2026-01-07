
// Input Data
data {
  int N <lower = 1>;                 // Number of observations
  vector[N] E;                       // Electric_field_V_cm
  vector[N]<lower = 0,upper = 1> H;  // Hemolysis procent
}

// Parameters
parameters {
  real u_min;  //  Base Lysis when E = 0
  real u_max;  //  Max Lysis when E = inf
  real K;      //  Half effect point ED50
  real ni;     //  Hill coefficient
  real phi;    //  Precision
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
  u_min ~ beta(2,20);
  u_max ~ beta(20,2);
  K ~ lognormal(log(1500),0.5);
  ni ~ gamma(3,1);
  phi ~ gamma(2,0.1);

  // Model Likelihoood
  for (i in 1:N) {
    H[i] ~ beta(mu_i[i] * phi, (1 - mu_i[i]) * phi);
    }
}

// Additional Calculations
generated quantities {

  // Dymanic Range
  real delta_mu = u_max - u_min;

  // Effective range (10%–90%)
  real E_low  = K * pow( (1 / 0.1) - 1, 1 / ni );
  real E_high = K * pow( (1 / 0.9) - 1, 1 / ni );
  real effective_range = E_high - E_low;

  //  Threshold field (minimal detectable effect)

  // E-values for specific % hemolysis
  vector[5] H_values; // Hemolysis Vector
  H_values[1] = 0.1;
  H_values[2] = 0.25;
  H_values[3] = 0.5;
  H_values[4] = 0.75;
  H_values[5] = 0.9;

  vector[5] E_target;  // 10,25,50,75,90%
  // Loop over E_values and for every one compute the E for the Specific % Hemolysis
  for (j in 1:5) {
    E_target[j] = K * pow( (1 / H_values[j]) - 1, 1 / ni );
    }

  // Slope at half-max (Hill slope)
  real hill_slope = (u_max - u_min) * ni / (4 * K);

}














