# lib ------------------------------------------------------------
library(tidyverse)
library(cowplot)
library(egg)

# load sim ------------------------------------------------------------
load("wcov_allsims_2020-01-21.Rdata")
allcontr = tbl_df(allcontr) %>%
  filter(!(idsim %in% c(902,904,905)))

# controls ------------------------------------------------------------
start_date_range = as.Date(c("2019-11-20","2019-12-04"))
incidence_range = c(1000,9700)
incidence_date = as.Date("2020-01-18")
set_durations = incidence_date - start_date_range
set_seeds = c(1,10,20,30,40,50)

# load post-processed data ------------------------------------------------------------
load("wcoc_ppsims_2020-01-23.Rdata")
pp_sims = pp_allsims %>%
  mutate(within_range=total_incidence>=incidence_range[1]&total_incidence<=incidence_range[2]) %>%
  tbl_df()

# fig1: k ~ R0 -----------------------------------------------

# SARS and MERS
other_diseases = rbind(
  c("MERS","MERS-CoV",.47,.29,.8,.26,.09,1.24,.23,.65),
  c("SARS","SARS-CoV - Singapore",2.55,.5,4.5,.21,.15,1000,3.2,.77),
  c("SARS","SARS-CoV - Beijing",1.88,.41,3.32,.12,.078,.42,2.4,.03),
  c("Influenza","1918 Influenza",1.77,1.61,1.95,.94,.59,1.72,1.2,3)) %>%
  as.data.frame() 
names(other_diseases)=c("virus","label","R0","R0_min","R0_max","k","k_min","k_max","label.y","label.x")
for(i in 3:10) other_diseases[,i] = as.numeric(as.character(other_diseases[,i]))

# summarise samples
tmp = pp_simes %>%
  group_by(R0,k) %>%
  summarise(within_range=mean(within_range))
  
# plot
ggplot(tmp) +
  geom_raster(data=tmp,aes(x=k,y=R0,fill=within_range),alpha=.8) +
  scale_x_continuous(trans="log10",breaks=c(0.001,.01,.1,1,10),expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0),breaks=c(1,2,3,4,5),labels = c(1,2,3,4,5)) +
  scale_fill_gradient(low="white",high="red") +
  coord_cartesian(xlim=c(0.01,10),ylim=c(0,5)) +
  labs(x="Dispersion parameter, k",y=expression(R[0]),fill=NULL) +
  geom_hline(yintercept=1,linetype=2) +
  
  geom_point(data=other_diseases,aes(x=k,y=R0),size=3) +
  geom_errorbar(data=other_diseases,aes(x=k,ymin=R0_min,ymax=R0_max),width=0) +
  geom_errorbarh(data=other_diseases,aes(y=R0,xmin=k_min,xmax=k_max),height=0) +
  
  geom_segment(data=other_diseases,aes(x=label.x,y=label.y,xend=k,yend=R0),linetype=3) +
  geom_label(data=other_diseases,aes(x=label.x,y=label.y,label=label)) +

  scale_colour_manual(values=c("steelblue","seagreen","purple"),guide=FALSE) +
  scale_shape_discrete(guide=FALSE) +
  
  theme(legend.position="right",
        legend.justification = "center",
        legend.key.height = unit(60,"pt"))
ggsave(file="figure/fig1.pdf",height=6,width=9)


# ABC ------------------------------------------------------------
within = filter(pp_sims,within_range==TRUE)

library(HDInterval)
summary(within$R0)
hdi(within$R0,credMass=.90)
summary(within$k)
hdi(within$k,credMass=.90)


plot(density(within$sigma,adjust=3))
plot(density(within$seed,adjust=3))



g1 = ggplot() +
  geom_ribbon(data=pp_sims,aes(R0,ymin=0,ymax=1/(5-.8)),colour="black",fill="grey50",alpha=.5) +
  # geom_density(data=pp_sims,aes(R0),colour="black",fill="grey50",alpha=.5) +
  geom_density(data=within,aes(R0),fill="lightblue",alpha=.8,adjust=3) +
  scale_x_continuous(expand=c(0,0),breaks=1:8,limits=c(0.8,5)) +
  scale_y_continuous(expand=c(0,0),limits=c(0,.8)) +
  labs(x=expression(R[0]),y="density")
g2 = ggplot(within) +
  geom_ribbon(aes(k,ymin=0,ymax=1/3),fill="grey50",colour="black",alpha=.5) +
  # geom_density(data=pp_sims,aes(k),fill="grey50",colour="black",alpha=.5) +
  geom_density(aes(k),fill="lightblue",alpha=.8,adjust=3) +
  scale_x_continuous(trans="log10",limits=c(0.01,10),expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0),limits=c(0,.8))+
  labs(x="Dispersion parameter, k",y="density")

plot_grid(g1,g2,ncol=2)
ggsave(file="figure/fig2c.pdf",height=3,width=6)

# plot one combination -------------------------------------------
chosen = ungroup(tmp) %>%
  filter(within_range==max(within_range))

# controls
start_date_range = as.Date(c("2019-11-20","2019-12-04"))
incidence_range = c(1000,9700)
incidence_date = as.Date("2020-01-18")
set_duration = as.numeric(as.Date("2020-01-18") - start_date_range[1])
set_delays = seq(1,as.numeric(start_date_range[2]-start_date_range[1]),by=1) - 1
set_seeds = c(1,10,20,30,40,50)
set_R0 = chosen$R0
set_k = unique(allcontr$k)[14]
set_sigma = unique(allcontr$sigma)
set_replicates = 10

# sampling
chosen_pp = expand.grid(R0=set_R0,k=set_k,sigma=set_sigma,seed=set_seeds,n=1:set_replicates,total_incidence=NA)
inc = NULL
for(i in  1:nrow(chosen_pp)) {
  p_R0 = chosen_pp[i,"R0"]
  p_k = chosen_pp[i,"k"]
  p_sigma = chosen_pp[i,"sigma"]
  p_seed = chosen_pp[i,"seed"]
  inc = filter(allcontr,R0==p_R0,k==p_k,sigma==p_sigma) %>%
    sample_n(p_seed,replace=TRUE) %>%
    mutate(delay=sample(set_delays,size=p_seed,replace=TRUE)) %>% 
    gather("day","incidence",6:95) %>%
    arrange(idsim) %>%
    mutate(day=delay-1+as.numeric(gsub("X","",day))) %>%
      filter(day<=set_duration) %>%
    group_by(R0,k,sigma,day) %>%
    summarise(incidence=sum(incidence)) %>%
    mutate(seed=p_seed,it=i) %>%
    bind_rows(inc)
  cat(i," ")
}

t_inc = inc %>%
  mutate(day2=day+start_date_range[1]) %>%
  group_by(it) %>%
  mutate(total_incidence=max(incidence),
         within=total_incidence>=incidence_range[1]&total_incidence<=incidence_range[2])
ungroup(t_inc) %>%
  summarise(mean=mean(within))

g1 = ggplot(t_inc) +
  geom_line(aes(x=day2,y=incidence,group=it,colour=within),alpha=.2) +
  
  annotate("errorbarh",y=800,xmin=start_date_range[1],xmax=start_date_range[2],size=1,height=300) +
  annotate("segment",x=mean(start_date_range)+8,y=3000,xend=mean(start_date_range),yend=800) +
  annotate("label",x=mean(start_date_range)+8,y=3000,label="Uncertainty on starting date") +
  
  annotate("errorbar",x=incidence_date+1,ymin=incidence_range[1],ymax=incidence_range[2],size=1) +
  annotate("segment",x=incidence_date-25,y=8000,xend=incidence_date+1,yend=mean(incidence_range)) +
  annotate("label",x=incidence_date-25,y=8000,label="Uncertainty on epidemic\nsize on Jan. 18th") +
  
  annotate("errorbar",x=start_date_range[1]-1,ymin=1,ymax=50,size=1) +
  annotate("segment",x=start_date_range[1],y=4500,xend=start_date_range[1]-1,yend=50) +
  annotate("label",x=start_date_range[1]+1,y=4500,label="Uncertainty on\ninitial seed") +
  
  # annotate("rect",x=start_date_range[1]-1,xend=start_date_range[2]+1,y=0,yend=200) +
  
  scale_color_manual(values=c("black","red"),guide=FALSE) +
  scale_x_date(breaks=as.Date(c("2019-11-15","2019-12-01","2019-12-15","2020-01-01","2020-01-15")),
               labels=c("Nov. 15","Dec 1","Dec 15","Jan 1","Jan 15")) +
  
  coord_cartesian(ylim=c(0,12000)) +
  
  labs(x="Time",y="Cumulative incidence")


g1
ggsave(file="figure/fig3.pdf",height=6,width=9)



g1b = g1 + 
  annotate("errorbarh",y=7900,xmin=as.Date("2019-11-25")+.7,xmax=as.Date("2019-12-13"),size=1,height=300) +
  annotate("segment",x=mean(start_date_range)+8,y=3000,xend=mean(start_date_range)+8,yend=7900) +
  annotate("label",x=mean(start_date_range)+8,y=3000,label="Uncertainty on starting date")

t_inc2 = t_inc %>%
  mutate(incidence2=incidence-lag(incidence,default=0)) %>%
  filter(day2<=start_date_range[2]+10)
g2 = ggplot(t_inc2) +
  geom_line(aes(x=day2,y=incidence2,group=it),alpha=.1)+
  scale_color_manual(values=c("black","red"),guide=FALSE) +
  scale_x_date(breaks=as.Date(c("2019-11-20","2019-11-27","2019-12-04","2019-12-11")),
               labels=c("Nov 20","Nov 27","Dec 4","Dec 11")) +
  
  # coord_cartesian(xlim=c(start_date_range[1]-1,start_date_range[2]+1)) +
  
  labs(x=NULL,y="Daily incidence") +
  theme(axis.title.y = element_text(size=12))
g1 + annotation_custom(
    ggplotGrob(g2), 
    xmin = as.Date("2019-11-18"), xmax = as.Date("2019-12-16"), ymin = 8000, ymax = 12000
  )
ggsave(file="figure/fig3b.pdf",height=6,width=9)

