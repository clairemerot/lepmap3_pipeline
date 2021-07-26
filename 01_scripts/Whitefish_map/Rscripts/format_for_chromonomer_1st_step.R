#this R script use the map with contig pos info to output a file with 5 columns tab-sep
#CHR(contig) position marker_id N N
#this is the entry file for the .py that extracts 200 bp around the snp pos.


argv <- commandArgs(T)
MAP1 <- argv[1]

map<-read.table(paste0("08_analyze_maps/01_maps/", MAP1), header=T, stringsAsFactors=F)
map_snp_pos<-cbind(map[,c(5,6,2)], rep("N", dim(map)[1]), rep("N", dim(map)[1]))
head (map_snp_pos)
map_snp_pos[,2]<-gsub("\\*","",map_snp_pos[,2]) # replace the stars by nothing in the sex marker
write.table (map_snp_pos, paste0("08_analyze_maps/05_prepare_chromonomer/",MAP1,".snplist"), col.names=F, row.names=F, quote=F, sep="\t")