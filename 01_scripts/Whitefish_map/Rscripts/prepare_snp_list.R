#this R script use the map with contig pos info to output a file with 5 columns tab-sep
#CHR(contig) position marker_id N N
#this is the entry file for the .py that extracts 200 bp around the snp pos.


argv <- commandArgs(T)
INPUT <- argv[1]

map<-read.table(INPUT, header=T, stringsAsFactors=F)
map_snp_pos<-cbind(map[,c(2,3,1)], rep("N", dim(map)[1]), rep("N", dim(map)[1]))
head (map_snp_pos)
write.table (map_snp_pos, paste0(INPUT,".snplist"), col.names=FALSE, row.names=FALSE, quote=FALSE, sep="\t")