# lib
library(tidyverse)
library(cowplot)

# load sim
load("wcov_allsims_2020-01-21.Rdata")
allcontr = tbl_df(allcontr) %>%
  filter(!(idsim %in% c(902,904,905)))

# controls
start_date_range = as.Date(c("2019-11-20","2019-12-04"))
incidence_range = c(1000,9700)
incidence_date = as.Date("2020-01-18")
set_duration = as.numeric(as.Date("2020-01-18") - start_date_range[1])
set_delays = seq(1,as.numeric(start_date_range[2]-start_date_range[1]),by=1) - 1
set_seeds = c(1,10,20,30,40,50)
set_R0 = unique(allcontr$R0)
set_k = unique(allcontr$k)
set_sigma = unique(allcontr$sigma)
set_replicates = 10

# sampling
pp_sims = expand.grid(R0=set_R0,k=set_k,sigma=set_sigma,seed=set_seeds,n=1:set_replicates,total_incidence=NA)
for(i in  36023:nrow(pp_sims)) {
  p_R0 = pp_sims[i,"R0"]
  p_k = pp_sims[i,"k"]
  p_sigma = pp_sims[i,"sigma"]
  p_seed = pp_sims[i,"seed"]
  inc = filter(allcontr,R0==p_R0,k==p_k,sigma==p_sigma) %>%
    sample_n(p_seed,replace=TRUE) %>%
    mutate(delay=sample(set_delays,size=p_seed,replace=TRUE)) %>% 
    gather("day","incidence",6:95) %>%
    arrange(idsim) %>%
    mutate(day=delay+as.numeric(gsub("X","",day))) %>%
    filter(day==set_duration) %>%
    summarise(total_incidence=sum(incidence))
  pp_sims[i,"total_incidence"] = unlist(inc)
  cat(i," ")
}
save(pp_sims,file="wcoc_ppsims_2020-01-21.Rdata")
