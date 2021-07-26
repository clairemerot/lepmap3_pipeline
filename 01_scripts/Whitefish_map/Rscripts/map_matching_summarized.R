# this script can be call with Rscript
#Rscript 01_scripts/Rscripts/map_matching_summarized.R MAP1 MAP2 "name"
#it calculates the mean position of a contig for each LG, make the correspondance between two maps in a file
#it also outputs a plot for each LG (as named in map1) showing the mean position of the contig in the two maps 

argv <- commandArgs(T)
MAP1 <- argv[1] #path to map1
MAP2 <- argv[2] #path to map 2
name <- argv[3] #short name we want to give to the comparative files

NB_CHR<-6 #may need to be edited

library(dplyr)

map1<-read.table(MAP1, header=T)
head(map1)
 
summary_by_contig1<-aggregate(map1$female_pos ~ map1$contig * map1$CHR, FUN="mean")
colnames(summary_by_contig1)<-c("contig", "LG_1", "pos_1")
head(summary_by_contig1)

map2<-read.table(MAP2, header=T)
head(map2)
 
summary_by_contig2<-aggregate(map2$female_pos ~ map2$contig * map2$CHR, FUN="mean")
colnames(summary_by_contig2)<-c("contig", "LG_2", "pos_2")
head(summary_by_contig2)

summary_by_contig_map12<-inner_join(summary_by_contig1, summary_by_contig2)

write.table(summary_by_contig_map12, paste0("08_analyze_maps/03_summary_contig/",name, ".txt"), row.names=F, quote=F)

jpeg(paste0("08_analyze_maps/03_summary_contig/",name,".jpeg"))
par(mfrow=c(2,(NB_CHR/2)))
for (i in 1:NB_CHR)
	{ 
	lg<-paste0("LG",i)
	plot(summary_by_contig_map12[summary_by_contig_map12$LG_1==lg,3],
		 summary_by_contig_map12[summary_by_contig_map12$LG_1==lg,5], 
		 main=lg, xlab="mean contig position in map1", ylab="mean contig position in map2", pch=20)
	}
dev.off()
