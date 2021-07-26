#this script is can be run after 09 phasing
#it uses marker list to give scaffold info to markers


library(dplyr)


#argv <- commandArgs(T)
MISS <- "0.5" #argv[1]
MIN_COV <- "cov3" #argv[2]
i <- "coregonus" #argv[3]
LOD <-"8" #argv[4]
#REFINE_STEPS<-as.numeric(argv[5])
NB_CHR<-40 #argv[6]

Nmax<-20 #nb maximum of marker above which we consider it is a plateau and remove it


marker_list<-read.table (paste0("04_filtering/data_f_",MISS,"_",MIN_COV,"_",i,".markerlist"), stringsAsFactors=F, header=T)
pedigree<-read.table(paste0("02_raw_data/pedigree_",i,".txt"), header=F, stringsAsFactors=F)
n_progeny<-dim(pedigree)[2]-4

map_all_LG<-matrix(ncol=n_progeny+3)
colnames(map_all_LG)=c( "id_contig_pos", "CHR", "female_pos",seq(1:n_progeny))

for (j in 1 : NB_CHR)
{
	
	#read genotype file
	order<-read.table(paste0("09_phased_map/genotype_rqtl_intercross_",MISS,"_",MIN_COV,"_",i,"_LOD_",LOD,".js_3.LG",j,".11.txt"))
	colnames(order)<-c( "marker_id", "useless", "male_pos","female_pos", seq(1:n_progeny))
	head(order)
	
	#remove flat area of the map	
	plateau<-which(table(factor(order$female_pos))>=Nmax)
	order_filtered<-order
	if (length(plateau)>=1)
		{
		for (k in 1:length(names(plateau)))
	 		{
		 	order_filtered<-order_filtered[-which(order_filtered$female_pos==names(plateau)[k]),]
	 		}
		}
	
	head(order_filtered)
	
	#put scaffold and pos name and make LG and pos column
	order_LG<-cbind(order_filtered[,1],rep(j, dim(order_filtered)[1]), order_filtered[,4])
	colnames(order_LG)<-c( "marker_id", "CHR", "female_pos")
	head (order_LG)
	
	order_LG_marker<-left_join(as.data.frame(order_LG), marker_list)
	head(order_LG_marker)
	
	id_contig_pos<-paste(order_LG_marker$marker_id, order_LG_marker$contig_pos, sep="_")
	final_order_filtered<-cbind(id_contig_pos, order_LG[,2:3], order_filtered[,5:(dim(order_filtered)[2])])
	head(final_order_filtered)
	
	#put all LG below each other
	map_all_LG<-rbind(map_all_LG, final_order_filtered)

}
	#add pedigree info -> tis is for Rqtl
	pedigree[5,which(pedigree[5,]==2)]<-0
	pedigree_rqtl<-cbind(rbind(c("id",j,0),c("sex",j,0),c("pheno",j,0)),pedigree[c(2,5,6),5:(dim(pedigree)[2])])
	colnames(pedigree_rqtl)<-colnames(map_all_LG)
	pedigree_rqtl$female_pos<-as.numeric(as.character(pedigree_rqtl$female_pos))
	pedigree_rqtl$CHR<-as.numeric(as.character(pedigree_rqtl$CHR))
	map_filter_pedigree<-rbind(pedigree_rqtl, map_all_LG[2:(dim(map_all_LG)[1]),])
	map_filter_pedigree[1:10,1:10]
	write.table(t(map_filter_pedigree), paste0("09_phased_map/map_genotype/geno_phased_",MISS,"_",MIN_COV,"_",i,"_LOD_",LOD,"js3.LGall.filtered_",Nmax,".forqtl.csv") , col.names=F, row.names=F,quote=F, sep="," )


	#save format for Limborg
	map_filter<- map_all_LG[2:(dim(map_all_LG)[1]),]
	colnames(map_filter)[c(1:3)]<-c("Locus_name","Lg","cM")
	write.table(t(map_filter), paste0("09_phased_map/map_genotype/geno_phased_",MISS,"_",MIN_COV,"_",i,"_LOD_",LOD,"js3.LGall.filtered_",Nmax,".forlimborg.csv") , col.names=F, row.names=T,quote=F, sep="," )

