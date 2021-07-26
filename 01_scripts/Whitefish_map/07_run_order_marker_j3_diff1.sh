#!/bin/bash
#SBATCH -J "LM3_order_lodj3"
#SBATCH -o log_%j
#SBATCH -c 4 
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
CPU=4
LOD=8 #The most important parameter to change is the LOD value and maybe the sizeLimit (minimum nb of chromosome to count it as a LG)
REFINE_STEPS=2 #A parameter we can changeto refine further the order
LOD_J=4

##step 7: Order markers within LG
#this step is the longest and might necessitate several iteration before being accurate

#variables 
#compulsory (file names)
IN_FILE="04_filtering/data_f_"$MISS"_"$MIN_COV"_"$i".gz"

#MAP_FILE="05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".txt" 
MAP_FILE="06_joinsingle/map"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J"_diff1.txt" # or use the map resulting from joinsingle 
#other parameters (adjust if needed)
ITE="numMergeIterations=5" #will merge several iterations
RECOMB_1="recombination1=0.0005" # for species with non-recoùmbining male adjust recombination rate to 0
RECOMB_2="recombination2=0.0025" 
#PHASE="outputPhasedData=1" #if we want phased data as output. may be useful for QTL?


#NB_CHR=$[$(wc -l "05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".repartition" | cut -d " " -f 1)-2] #nb of linkage groups from step 5

NB_CHR=$[$(wc -l "05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD"_improved.repartition" | cut -d " " -f 1)-2] #nb of linkage groups from step 5


#run the module once for intitial order
for j in $(seq $NB_CHR)
do
echo "assessing marker order for LG" $j "1st step"
OUT_FILE="07_order_LG/order_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J".LG"$j".1.txt"
zcat $IN_FILE | java -cp bin/ OrderMarkers2 map=$MAP_FILE numThreads=$CPU data=- $ITE $RECOMB_1 $RECOMB_2 $PHASE chromosome=$j > $OUT_FILE
	for k in $(seq $REFINE_STEPS)
	 	do
 	IT=$[$k + 1]
	echo "assessing marker order for LG" $j "refining step" $IT
 	OUT_FILE="07_order_LG/order_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J".LG"$j"."$IT".txt"
	ORDER_FILE="07_order_LG/order_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J".LG"$j"."$k".txt"
 	zcat $IN_FILE | java -cp bin/ OrderMarkers2 evaluateOrder=$ORDER_FILE  numThreads=$CPU data=- $ITE $RECOMB_1 $RECOMB_2 $PHASE chromosome=$j > $OUT_FILE
	done
done

Rscript 01_scripts/Rscripts/match_marker_map.R "$MISS" "$MIN_COV" "$i" "$LOD" "$REFINE_STEPS" "$NB_CHR" "$LOD_J"


