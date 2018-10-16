#merge two csv-prepare-for-map-comp files from two map to be compared against each other
#Rscript 01_scripts/Rscripts/format_for_mapcomp_comparison.R "08_analyze_maps/04_prepare_map_comp/contig_order_0.2_cov10_aa_LOD_10.LGall.refined3.txt.csv" "08_analyze_maps/04_prepare_map_comp/contig_order_0.2_cov10_bb_LOD_10.LGall.refined3.txt.csv" "cov10aa" "cov10bb"

argv <- commandArgs(T)
MAP1 <- argv[1] #path to map 1 csv
MAP2 <- argv[2] #path to map 2 csv
name1 <- argv[3] #shortname of map1
name2 <-argv[4] #shortname of map2

map1<-read.table(MAP1, header=F, sep=",")
map1[,1]<-rep(name1, dim(map1)[1])
map2<-read.table(MAP2, header=F, sep=",")
map2[,1]<-rep(name2, dim(map2)[1])

map<-rbind(map1, map2)
write.table(map, paste0("../mapcomp/02_data/",name1, "vs", name2, ".csv"), sep=",", col.names=F, row.names=F, quote=F)
