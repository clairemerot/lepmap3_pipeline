#!/bin/bash
#SBATCH -J "LM3_SepCHR"
#SBATCH -o log_%j
#SBATCH -c 1 
#SBATCH -p small
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=1-00:00
#SBATCH --mem=1G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR


#variables
i="coregonus"
MIN_COV=cov3 #coverage use to filter in genotyping step

MISS="0.5" #for filtering step, will filter out markers with missing rate above that fraction
SIZEL="20"
CPU=1
LOD=8 #The most important parameter to change is the LOD value and maybe the sizeLimit (minimum nb of chromosome to count it as a LG) or loop



##step 5: Separate chromosome
#this step will look for markers with relative linkage to split them into chromosome

#variables 
#other parameters (adjust if needed)
D="distortionLod=1" #to remove markers with H-W distortion in a single family~
#RECOMB_1="maleTheta=0.1" # for species with non-recoùmbining male adjust recombination rate to 0
#RECOMB_2="femaleTheta=0.5" # 

#compulsory (file names)
IN_FILE="04_filtering/data_f_"$MISS"_"$MIN_COV"_"$i".gz"
MARKER_TO_GENOME="04_filtering/data_f_"$MISS"_"$MIN_COV"_"$i"_to_Cor_EUR.noheader.sam"

#for LOD in 8 10 12    
#do

OUT_FILE="05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".txt"
#run the module
zcat $IN_FILE | java -cp bin/ SeparateChromosomes2 data=- lodLimit=$LOD numThreads=$CPU sizeLimit=$SIZEL $RECOMB_1 $RECOMB_2 $D > $OUT_FILE

#evaluate chromosome repartition 
#typically if there is just one big chromosome -> raise LOD
#if there are plenty of chromosome (more than expected -> lower LOD
#if there are X big chromosome and plenty of chromosome with very few markers, raise SizeLimit and then rather use joinsingle with smalle LOD
awk '{print $1}' $OUT_FILE | sort -n | uniq -c 
awk '{print $1}' $OUT_FILE | sort -n | uniq -c > "05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".repartition"
Rscript 01_scripts/Rscripts/match_marker_to_other_genome.R $OUT_FILE $MARKER_TO_GENOME
#done


#refine: this will take the previous map and split the chromosome given in lg= with a new alue of LOD
#splitLG2
LOD_R=9
OUT_FILE2="05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD"_ref_"$LOD_R"_lg2.txt"
zcat $IN_FILE | java -cp bin/ SeparateChromosomes2 data=- lodLimit=$LOD_R numThreads=$CPU sizeLimit=$SIZEL $RECOMB_1 $RECOMB_2 $D map=$OUT_FILE lg=2 renameLGs=0 > $OUT_FILE2
awk '{print $1}' $OUT_FILE2 | sort -n | uniq -c 
Rscript 01_scripts/Rscripts/match_marker_to_other_genome.R $OUT_FILE2 $MARKER_TO_GENOME

#split LG1
LOD_R=11
OUT_FILE1="05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD"_ref_"$LOD_R"_lg1.txt"
zcat $IN_FILE | java -cp bin/ SeparateChromosomes2 data=- lodLimit=$LOD_R numThreads=$CPU sizeLimit=$SIZEL $RECOMB_1 $RECOMB_2 $D map=$OUT_FILE2 lg=1 renameLGs=0 > $OUT_FILE1
awk '{print $1}' $OUT_FILE1 | sort -n | uniq -c 
Rscript 01_scripts/Rscripts/match_marker_to_other_genome.R $OUT_FILE1 $MARKER_TO_GENOME

#split LG3
LOD_R=11
OUT_FILE3="05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD"_ref_"$LOD_R"_lg3.txt"
zcat $IN_FILE | java -cp bin/ SeparateChromosomes2 data=- lodLimit=$LOD_R numThreads=$CPU sizeLimit=$SIZEL $RECOMB_1 $RECOMB_2 $D map=$OUT_FILE1 lg=3 renameLGs=0 > $OUT_FILE3
awk '{print $1}' $OUT_FILE3 | sort -n | uniq -c 
Rscript 01_scripts/Rscripts/match_marker_to_other_genome.R $OUT_FILE3 $MARKER_TO_GENOME

#save final map
REFINED_MAP="05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD"_improved.txt"
cp $OUT_FILE3 $REFINED_MAP

awk '{print $1}' $REFINED_MAP | sort -n | uniq -c 
awk '{print $1}' $REFINED_MAP | sort -n | uniq -c > "05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD"_improved.repartition"
Rscript 01_scripts/Rscripts/match_marker_to_other_genome.R $REFINED_MAP $MARKER_TO_GENOME
#done


#split LG4 # ne sert pas
#LOD_R=11
#OUT_FILE4="05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD"_ref_"$LOD_R"_lg4.txt"
#zcat $IN_FILE | java -cp bin/ SeparateChromosomes2 data=- lodLimit=$LOD_R numThreads=$CPU sizeLimit=$SIZEL $RECOMB_1 $RECOMB_2 $D map=$OUT_FILE3 lg=4 renameLGs=0 > $OUT_FILE4
#awk '{print $1}' $OUT_FILE4 | sort -n | uniq -c 
#Rscript 01_scripts/Rscripts/match_marker_to_other_genome.R $OUT_FILE4 $MARKER_TO_GENOME
