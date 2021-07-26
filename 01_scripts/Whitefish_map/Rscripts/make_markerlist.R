argv <- commandArgs(T)
MISS <- argv[1]
MIN_COV <- argv[2]
i <- argv[3]



contig<-read.table(paste0("04_filtering/contig_",MISS,"_",MIN_COV,"_",i,".txt"), stringsAsFactors=F )
pos<-read.table(paste0("04_filtering/pos_",MISS,"_",MIN_COV,"_",i,".txt"), header=T, stringsAsFactors=F)
marker_list<-cbind(c(1:(dim(contig)[1]-6)), contig[7:dim(contig)[1],1], pos[7:dim(contig)[1],1], paste(contig[7:dim(contig)[1],1], pos[7:dim(contig)[1],1], sep="_"))
head(marker_list)
colnames(marker_list)<-c("marker_id", "contig", "pos", "contig_pos")
print(paste("after filtering, there are", dim(marker_list)[1], "markers in the family", i))
write.table( marker_list, paste0("04_filtering/data_f_",MISS,"_",MIN_COV,"_",i,".markerlist"), row.names=F, quote=F)
