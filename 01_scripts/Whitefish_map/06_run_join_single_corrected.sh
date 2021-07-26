#!/bin/bash
#SBATCH -J "LM3_joinsingle"
#SBATCH -o log_%j
#SBATCH -c 1 
#SBATCH -p medium
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=7-00:00
#SBATCH --mem=1G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR


#variables
i="coregonus"
MIN_COV=cov3 #coverage use to filter in genotyping step
MISS="0.5" #for filtering step, will filter out markers with missing rate above that fraction
CPU=1
LOD=8


#variables 
#compulsory (file names)
IN_FILE="04_filtering/data_f_"$MISS"_"$MIN_COV"_"$i".gz"

#MAP_FILE="05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".txt"
MAP_FILE="05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD"_improved_corrected.txt"
MARKER_TO_GENOME="04_filtering/data_f_"$MISS"_"$MIN_COV"_"$i"_to_Cor_EUR.noheader.sam"

#other parameters (adjust if needed)
D="distortionLod=1 " #to remove markers with H-W distortion in a single family
#LODDIFF="lodDifference=1" #requires a difference of LOD # not understood: is it between LG?
#RECOMB_1="maleTheta=0.1" # for species with non-recoùmbining male adjust recombination rate to 0
#RECOMB_2="femaleTheta=0.5" # 

LOD_J=8
LOD_diff=2
OUT_FILE="06_joinsingle/map"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J"_corr.txt"

#run the module
zcat $IN_FILE | java -cp bin/ JoinSingles2All data=- lodLimit=$LOD_J lodDifference=$LOD_diff numThreads=$CPU iterate=20 $RECOMB_1 $RECOMB_2 map=$MAP_FILE > $OUT_FILE

awk '{print $1}' $OUT_FILE | sort -n | uniq -c 
awk '{print $1}' $OUT_FILE | sort -n | uniq -c > $OUT_FILE".repartition"

cut -f 1 $OUT_FILE > $OUT_FILE"2"
Rscript 01_scripts/Rscripts/match_marker_to_other_genome.R $OUT_FILE"2" $MARKER_TO_GENOME


LOD_J=7
OUT_FILE="06_joinsingle/map"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J"_corr.txt"

#run the module
zcat $IN_FILE | java -cp bin/ JoinSingles2All data=- lodLimit=$LOD_J lodDifference=$LOD_diff numThreads=$CPU iterate=20 $RECOMB_1 $RECOMB_2 map=$MAP_FILE > $OUT_FILE
awk '{print $1}' $OUT_FILE | sort -n | uniq -c 
awk '{print $1}' $OUT_FILE | sort -n | uniq -c > $OUT_FILE".repartition"

cut -f 1 $OUT_FILE > $OUT_FILE"2"
Rscript 01_scripts/Rscripts/match_marker_to_other_genome.R $OUT_FILE"2" $MARKER_TO_GENOME


LOD_J=6
OUT_FILE="06_joinsingle/map"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J"_corr.txt"

#run the module
zcat $IN_FILE | java -cp bin/ JoinSingles2All data=- lodLimit=$LOD_J lodDifference=$LOD_diff numThreads=$CPU iterate=20 $RECOMB_1 $RECOMB_2 map=$MAP_FILE > $OUT_FILE
awk '{print $1}' $OUT_FILE | sort -n | uniq -c 
awk '{print $1}' $OUT_FILE | sort -n | uniq -c > $OUT_FILE".repartition"

cut -f 1 $OUT_FILE > $OUT_FILE"2"
Rscript 01_scripts/Rscripts/match_marker_to_other_genome.R $OUT_FILE"2" $MARKER_TO_GENOME


LOD_J=5
OUT_FILE="06_joinsingle/map"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J"_corr.txt"

#run the module
zcat $IN_FILE | java -cp bin/ JoinSingles2All data=- lodLimit=$LOD_J lodDifference=$LOD_diff numThreads=$CPU iterate=20 $RECOMB_1 $RECOMB_2 map=$MAP_FILE > $OUT_FILE
awk '{print $1}' $OUT_FILE | sort -n | uniq -c 
awk '{print $1}' $OUT_FILE | sort -n | uniq -c > $OUT_FILE".repartition"

cut -f 1 $OUT_FILE > $OUT_FILE"2"
Rscript 01_scripts/Rscripts/match_marker_to_other_genome.R $OUT_FILE"2" $MARKER_TO_GENOME


LOD_J=4
OUT_FILE="06_joinsingle/map"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J"_corr.txt"

#run the module
zcat $IN_FILE | java -cp bin/ JoinSingles2All data=- lodLimit=$LOD_J lodDifference=$LOD_diff numThreads=$CPU iterate=20 $RECOMB_1 $RECOMB_2 map=$MAP_FILE > $OUT_FILE
awk '{print $1}' $OUT_FILE | sort -n | uniq -c 
awk '{print $1}' $OUT_FILE | sort -n | uniq -c > $OUT_FILE".repartition"

cut -f 1 $OUT_FILE > $OUT_FILE"2"
Rscript 01_scripts/Rscripts/match_marker_to_other_genome.R $OUT_FILE"2" $MARKER_TO_GENOME

LOD_J=3
OUT_FILE="06_joinsingle/map"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J"_corr.txt"

#run the module
zcat $IN_FILE | java -cp bin/ JoinSingles2All data=- lodLimit=$LOD_J lodDifference=$LOD_diff numThreads=$CPU iterate=20 $RECOMB_1 $RECOMB_2 map=$MAP_FILE > $OUT_FILE
awk '{print $1}' $OUT_FILE | sort -n | uniq -c 
awk '{print $1}' $OUT_FILE | sort -n | uniq -c > $OUT_FILE".repartition"

cut -f 1 $OUT_FILE > $OUT_FILE"2"
Rscript 01_scripts/Rscripts/match_marker_to_other_genome.R $OUT_FILE"2" $MARKER_TO_GENOME


