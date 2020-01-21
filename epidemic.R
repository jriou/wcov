# Simulating 2019-nCoV epidemics
# Christian L. Althaus, 21 January 2019

# Set seed
set.seed(65135)

# Initialize simulation
runs <- 1e2
seed <- 10
R0 <- 1.88
dispersion <- 0.12
generation_time <- 10
gamma_shape <- 2

max_time <- 45
max_cases <- 2e3

# Initialize plot
plot(NA,
	 xlim = c(0, 45), ylim = c(0, max_cases),
	 xlab = "Time since spillover (days)", ylab = "Cumulative number of 2019-nCoV cases",
	 frame = FALSE)

# Set color scheme for different trajectories
cols <- sample(terrain.colors(runs))

# Simulate outbreak trajectories
for(i in 1:runs) {
    cases <- seed
	t <- rep(0, seed)
	t.new <- t
	times <- t
	while(cases > 0) {
		secondary <- rnbinom(cases, size = dispersion, mu = R0)
        t.new <- numeric()
		for(j in 1:length(secondary)) {
			t.new <- c(t.new, t[j] + rgamma(secondary[j], shape = gamma_shape, rate = gamma_shape/generation_time))
		}
        t.new <- t.new[t.new < max_time]
		cases <- length(t.new)
		t <- t.new
		times <- c(times, t.new)
	}
	lines(sort(times), 1:length(times), col = cols[i], lwd = 1)
	points(max(times), length(times), col = cols[i], pch = 16)
}
