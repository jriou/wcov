# run simulations
scp /home/julien/Dropbox/Unibe/wcov/wcov/runsim.R \
    /home/julien/Dropbox/Unibe/wcov/wcov/sb_runsim.sh \
    UBELIX:projects/wcov/.

# concatenate simulations on server
allcontr = NULL
for(i in 1:1000) {
  if(file.exists(paste0("wcov_sims_2020-01-22_18499363_",i,".Rdata"))) {
    load(paste0("wcov_sims_2020-01-22_18499363_",i,".Rdata"))
  contr$idsim = i
  allcontr = rbind(allcontr,contr)
  cat(i," ")
  }
}
save(allcontr,file="wcov_allsims_2020-01-22_18499363.Rdata")
# >>>
scp UBELIX:projects/wcov/wcov_allsims_2020-01-22_18499363.Rdata /home/julien/Dropbox/Unibe/wcov/wcov/.

allcontr = NULL
for(i in 1:1000) {
  if(file.exists(paste0("wcov_sims_2020-01-22_18482752_",i,".Rdata"))) {
    load(paste0("wcov_sims_2020-01-22_18482752_",i,".Rdata")) 
  contr$idsim = i
  allcontr = rbind(allcontr,contr)
  cat(i," ")
  }
}
save(allcontr,file="wcov_allsims_2020-01-22_18482752.Rdata")
# >>>
scp UBELIX:projects/wcov/wcov_allsims_2020-01-22_18482752.Rdata /home/julien/Dropbox/Unibe/wcov/wcov/.

# run postprocessing
scp /home/julien/Dropbox/Unibe/wcov/wcov/postprocessing.R \
/home/julien/Dropbox/Unibe/wcov/wcov/sb_postprocessing.sh \
UBELIX:projects/wcov/.

# append postprocessing
pp_allsims = NULL
for(i in 1:10) {
  load(paste0("wcoc_ppsims_2020-01-23_18588999_",i,".Rdata"))
  pp_allsims = rbind(pp_allsims,pp_sims)
  cat(i)
}
j = 10
for(i in 1:100) {
  if(j<100) {
    if(file.exists(paste0("wcoc_ppsims_2020-01-23_18602567_",i,".Rdata"))) {
      load(paste0("wcoc_ppsims_2020-01-23_18602567_",i,".Rdata"))
      pp_allsims = rbind(pp_allsims,pp_sims)
      j = j+1
      cat(j," ")
    }
  }
}
save(pp_allsims,file="wcoc_ppsims_2020-01-23.Rdata")
