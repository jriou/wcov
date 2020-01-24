# get simulation number
args = as.numeric(commandArgs(trailingOnly=TRUE))

# lib
library(tidyverse)

# load sim
load("wcov_allsims_2020-01-22_18499363.Rdata")
allsims = tbl_df(allcontr)

# controls
start_date_range = as.Date(c("2019-11-20","2019-12-04"))
incidence_range = c(1000,9700)
incidence_date = as.Date("2020-01-18")
set_duration = as.numeric(as.Date("2020-01-18") - start_date_range[1])
set_delays = seq(1,as.numeric(start_date_range[2]-start_date_range[1]),by=1) - 1
set_seeds = c(1,10,20,30,40,50)
set_R0 = unique(allsims$R0)[1:22]
set_k = unique(allsims$k)
set_sigma = unique(allsims$sigma)
set_replicates = args[[1]]

# sampling
pp_sims = expand.grid(R0=set_R0,k=set_k,sigma=set_sigma,seed=set_seeds,n=set_replicates,total_incidence=NA)
for(i in  1:nrow(pp_sims)) {
  p_R0 = pp_sims[i,"R0"]
  p_k = pp_sims[i,"k"]
  p_sigma = pp_sims[i,"sigma"]
  p_seed = pp_sims[i,"seed"]
  inc = filter(allsims,R0==p_R0,k==p_k,sigma==p_sigma) %>%
    sample_n(p_seed,replace=TRUE) %>%
    mutate(delay=sample(set_delays,size=p_seed,replace=TRUE)) %>% 
    gather("day","incidence",6:95) %>%
    arrange(idsim) %>%
    mutate(day=delay-1+as.numeric(gsub("X","",day))) %>%
    filter(day==set_duration) %>%
    summarise(total_incidence=sum(incidence))
  pp_sims[i,"total_incidence"] = unlist(inc)
  cat(i," ")
}
save(pp_sims,file=paste0("wcoc_ppsims_2020-01-23_",args[[2]],"_",args[[1]],".Rdata"))
