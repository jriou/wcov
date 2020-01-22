# Simulating 2019-nCoV epidemics
# Christian L. Althaus & J. Riou, 21 January 2019

# get simulation number
args = as.numeric(commandArgs(trailingOnly=TRUE))

# prepare controls
contr = expand.grid(R0=seq(from=0.8,to=8, by=0.2),
                    k=10^seq(log10(0.01),log10(10),length.out = 20),
                    sigma=7:14)
nsim = dim(contr)[[1]]
contr$n = 1:nsim
contr$idsim = (args[[1]]-1)*nsim+contr$n
incidence = data.frame(matrix(0,nrow=nsim,ncol=90))
contr = cbind(contr,incidence)
contr$total_incidence = NA
contr$stopped = NA

# set limits
seed = 1
gamma_shape = 2
max_time = 90
max_cases = 5e4

# simulate
for(n in 1:nsim) {
  # initialize
  it_R0 = contr[n,"R0"]
  it_k = contr[n,"k"]
  it_sigma = contr[n,"sigma"]
  cases = seed
  t = rep(0, seed)
  times = t
  tmax = 0
  while(cases > 0 & length(times) < max_cases) {
    secondary = rnbinom(cases, size=it_k, mu=it_R0)
    t.new = numeric()
    for(j in 1:length(secondary)) {
      t.new = c(t.new, t[j] + rgamma(secondary[j], shape = gamma_shape, rate = gamma_shape/it_sigma))
    }
    t.new = t.new[t.new < max_time]
    cases = length(t.new)
    t = t.new
    times = c(times, t.new)
  }
  epicurve = cumsum(hist(times, breaks = 0:max_time,plot=FALSE)$counts)
  contr[n,6:95] = epicurve
  contr[n,"stopped"] = length(times) >= max_cases
  contr[n,"total_incidence"] = length(times)
  print(paste0(n,"/",nsim))
}

# save
save(contr, file=paste0("wcov_sims_2020-01-22_",args[[2]],"_",args[[1]],".Rdata"))
