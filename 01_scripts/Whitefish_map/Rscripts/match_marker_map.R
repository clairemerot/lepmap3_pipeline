#this script is called by 07_run_order_marker
#it uses the marker list from 04_filtering to assign a contig & pos to the marker id given by lepmap, 
#it makes the map more easily explorable, and correspondance with the genome used to align the markers
#last step also output a plot with the female position which allow looking at the repartition of markers along each LG
#Rscript 01_scripts/Rscripts/match_marker_map.R "0.1" "cov6" "aa" "10" "2" "7"



library(dplyr)
argv <- commandArgs(T)
MISS <- argv[1]
MIN_COV <- argv[2]
i <- argv[3]
LOD <-argv[4]
REFINE_STEPS<-as.numeric(argv[5])
NB_CHR<-argv[6]
LOD_J<-argv[7]

Nmax<-20 #nb maximum of marker above which we consider it is a plateau and remove it


marker_list<-read.table (paste0("04_filtering/data_f_",MISS,"_",MIN_COV,"_",i,".markerlist"), stringsAsFactors=F, header=T)
contig_map<-matrix(ncol=7)
contig_map_filtered<-matrix(ncol=7)
colnames(contig_map)=colnames(contig_map_filtered)=c("CHR", "marker_id", "male_pos", "female_pos", "contig", "pos", "contig_pos")

for (j in 1 : NB_CHR)
{
order<-read.table(paste0("07_order_LG/order_",MISS,"_",MIN_COV,"_",i,"_LOD_",LOD,".js_",LOD_J,".LG",j,".",(REFINE_STEPS + 1),".txt"), stringsAsFactors=F) [,1:3]
head(order)
order_LG<-cbind(rep(paste0("LG", j), dim(order)[1]), order)
colnames(order_LG)<-c("CHR", "marker_id", "male_pos", "female_pos")
head ( order_LG)

order_LG_marker<-left_join(order_LG, marker_list)
head(order_LG_marker)
contig_map<-rbind(contig_map, order_LG_marker)
#write.table(order_LG_marker, paste0("07_order_LG/contig_order_",MISS,"_",MIN_COV,"_",i,"_LOD_",LOD,".LG",j,".",(REFINE_STEPS + 1),".txt"), row.names=F, quote=F, sep="\t")


plateau<-which(table(factor(order_LG_marker$female_pos))>=Nmax)
order_LG_marker_filtered<-order_LG_marker
if (length(plateau)>=1)
	{
for (k in 1:length(names(plateau)))
	 {
		 order_LG_marker_filtered<-order_LG_marker_filtered[-which(order_LG_marker_filtered$female_pos==names(plateau)[k]),]
	 }
	}
contig_map_filtered<-rbind(contig_map_filtered, order_LG_marker_filtered)
		
}

write.table(contig_map[2: dim(contig_map)[1],], paste0("08_analyze_maps/01_maps/",i,"_",MISS,"_",MIN_COV,"_LOD_",LOD,".js_",LOD_J,".LGall.ref",(REFINE_STEPS + 1),".txt") , row.names=F,quote=F, sep="\t")
write.table(contig_map_filtered[2: dim(contig_map_filtered)[1],], paste0("08_analyze_maps/01_maps/",i,"_",MISS,"_",MIN_COV,"_LOD_",LOD,".js_",LOD_J,".LGall.ref",(REFINE_STEPS + 1),".f.txt") , row.names=F,quote=F, sep="\t")

jpeg(paste0("08_analyze_maps/02_plot/",i,"_",MISS,"_",MIN_COV,"_LOD_",LOD,".js_",LOD_J,".LGall.ref",(REFINE_STEPS + 1),".jpeg"))
plot(contig_map[2:dim(contig_map)[1],4], ylab="female_pos")
dev.off()
	 
jpeg(paste0("08_analyze_maps/02_plot/",i,"_",MISS,"_",MIN_COV,"_LOD_",LOD,".js_",LOD_J,".LGall.ref",(REFINE_STEPS + 1),".f.jpeg"))
plot(contig_map_filtered[2:dim(contig_map_filtered)[1],4], ylab="female_pos")
dev.off()