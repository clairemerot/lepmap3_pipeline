#this R script use the file with marker sequence from python script & the map (LG female pos)
#it outputs the file formatted for mapcomp in csv, comma delimited file with 6 colmuns
# map name, LG, pfemale_position, 0, marker_id, marker seq



argv <- commandArgs(T)
MAP1 <- argv[1]

map<-read.table(paste0("08_analyze_maps/01_maps/", MAP1), header=T, stringsAsFactors=F)
map_LG_pos<-cbind(rep(MAP1, dim(map)[1]),map[c(1,4)],rep("0", dim(map)[1]), map$marker_id)
map_LG_pos[,2]<-gsub("LG","",map_LG_pos[,2]) # replace the "LG" by nothing in the CHR column
colnames(map_LG_pos)<-c("map", "LG", "female_pos", "zeroes", "marker_id")
head (map_LG_pos)

marker_seq<-read.table(paste0("08_analyze_maps/04_prepare_map_comp/",MAP1,".seq"), stringsAsFactors=F)[,3:4]
colnames(marker_seq)<-c( "marker_id", "seq")
head(marker_seq)																									 

library(dplyr)
map_LG_pos_seq<-left_join(map_LG_pos, marker_seq)
head(map_LG_pos_seq)

write.table (map_LG_pos_seq, paste0("08_analyze_maps/04_prepare_map_comp/",MAP1,".csv"), col.names=F, row.names=F, quote=F, sep=",")