# run simulations
scp /home/julien/Dropbox/Unibe/wcov/wcov/runsim.R \
    /home/julien/Dropbox/Unibe/wcov/wcov/sb_runsim.sh \
    UBELIX:projects/wcov/.

# concatenate simulations on server
allcontr = NULL
for(i in 1:1000) {
  if(file.exists(paste0("wcov_sims_2020-21-01_",i,".Rdata"))) {
    load(paste0("wcov_sims_2020-21-01_",i,".Rdata"))
  } else {
    load(paste0("wcov_sims_2020-21-01_",i,"j.Rdata"))
  }
  contr[,6:95] = contr[,5:94]
  contr$idsim = i
  allcontr = rbind(allcontr,contr)
  cat(i)
}
save(allcontr,"wcov_allsims_2020-01-21.Rdata")