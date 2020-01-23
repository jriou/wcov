# lib
library(tidyverse)
library(cowplot)

# load sim
load("wcov_allsims_2020-01-21.Rdata")
allcontr = tbl_df(allcontr) %>%
  filter(!(idsim %in% c(902,904,905)))

# controls
start_date_range = as.Date(c("2019-11-20","2019-12-04"))
incidence_range = c(427,4471)
incidence_date = as.Date("2020-01-12")
set_durations = incidence_date - start_date_range
set_seeds = c(1,10,20,30,40,50)

# SARS and MERS
other_diseases = rbind(
  c("MERS","MERS",.47,.29,.8,.26,.09,1.24),
  c("SARS","SARS - Singapore",2.55,.5,4.5,.21,.15,1000),
  c("SARS","SARS - Beijing",1.88,.41,3.32,.12,.078,.42),
  c("Influenza","1918 Influenza",1.77,1.61,1.95,.94,.59,1.72)
) %>%
  as.data.frame()
names(other_diseases)=c("virus","label","R0","R0_min","R0_max","k","k_min","k_max")

SARS_MERS  = data.frame(cov=c("MERS","SARS"),
                        
                        R0=c(.8,2.5),
                        R0_min=c(.8,2),
                        R0_max=c(1.13,3),
                        k=c(.26,0.16),
                        k_min=c(.11,.11),
                        k_max=c(.87,.64))

# plot one epidemic
duration = 45
comb = 1265
filter(allcontr,n==comb) 

tmp = filter(allcontr,n==comb) %>%
  mutate_(total_incidence=paste0("X",45))


summarise(tmp,mean(total_incidence>1))
summarise(tmp,mean(total_incidence>=incidence_range[1]&total_incidence<=incidence_range[2]))

tmp %>%
  gather("day","cum_inc",6:95) %>%
  mutate(day=as.numeric(gsub("X","",day)),
         within_range=total_incidence>=incidence_range[1]&total_incidence<=incidence_range[2]) %>% 
  ggplot() +
  geom_ribbon(aes(x=day),ymin=incidence_range[1],ymax=incidence_range[2],fill="orange",alpha=.1) +
  geom_line(aes(x=day,y=cum_inc,group=idsim),alpha=.2) +
  scale_colour_manual(values=c("black","orange"),guide=FALSE) +
  coord_cartesian(xlim=c(0,duration),ylim=c(0,2*incidence_range[2])) +
  labs(x="Time (days)",y="Cumulative incidence")


# load post-processed data
load("wcoc_ppsims_2020-01-21.Rdata")
pp_sims = pp_sims %>%
  mutate(within_range=total_incidence>=incidence_range[1]&total_incidence<=incidence_range[2])

# fig1: k ~ R0
tmp = pp_sims %>%
  group_by(R0,k) %>%
  summarise(within_range=mean(within_range))
  
ggplot(tmp) +
  geom_raster(data=tmp,aes(x=k,y=R0,fill=within_range),alpha=.8) +
  scale_x_continuous(trans="log10",breaks=c(0.001,.01,.1,1,10),expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0),breaks=c(1,3,5,7)) +
  scale_fill_gradient(low="grey90",high="red") +
  labs(x="Dispersion parameter, k",y=expression(R[0]),fill=NULL) +
  
  geom_point(data=SARS_MERS,aes(x=k,y=R0)) +
  geom_errorbar(data=SARS_MERS,aes(x=k,ymin=R0_min,ymax=R0_max),width=0) +
  geom_errorbarh(data=SARS_MERS,aes(y=R0,xmin=k_min,xmax=k_max),height=0) +

  theme(legend.position="bottom",
        legend.direction = "horizontal",
        legend.key.width = unit(70,"pt"))

# ABC



