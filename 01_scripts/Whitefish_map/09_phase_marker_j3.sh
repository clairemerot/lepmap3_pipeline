#!/bin/bash
#SBATCH -J "phase_marker"
#SBATCH -o log_%j
#SBATCH -c 4 
#SBATCH -p medium
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=4-00:00
#SBATCH --mem=1G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR


#variables
i="coregonus"
MIN_COV=cov3 #coverage use to filter in genotyping step
MISS="0.5" #for filtering step, will filter out markers with missing rate above that fraction
CPU=4
LOD=8 #The most important parameter to change is the LOD value and maybe the sizeLimit (minimum nb of chromosome to count it as a LG)
LOD_J=3
ITE="numMergeIterations=5" #will merge several iterations
RECOMB_1="recombination1=0.0005" # for species with non-recoùmbining male adjust recombination rate to 0
RECOMB_2="recombination2=0.0025" 
PHASE="outputPhasedData=1" #if we want phased data as output. may be useful for QTL?

NB_CHR=$[$(wc -l "05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD"_improved_corrected.repartition" | cut -d " " -f 1)-2] #nb of linkage groups from step 5
IN_FILE="04_filtering/data_f_"$MISS"_"$MIN_COV"_"$i".gz"

#run the module for phasing
for j in $(seq $NB_CHR)
do
echo "phasing markers for LG" $j
	
	#phase with parents only
 	OUT_FILE="09_phased_map/order_phase_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J".LG"$j".11.txt"
	
	ORDER_FILE="07_order_LG/order_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J".LG"$j".11.txt"
	
 	zcat $IN_FILE | java -cp bin/ OrderMarkers2 evaluateOrder=$ORDER_FILE  numThreads=$CPU data=- $ITE $RECOMB_1 $RECOMB_2 $PHASE chromosome=$j > $OUT_FILE
	
	
	OUT_FILE4="09_phased_map/genotype_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J".LG"$j".11.txt"
	awk -f 01_scripts/utilities/map2genotypes.awk $OUT_FILE > $OUT_FILE4
	
	OUT_FILE5="09_phased_map/genotype_rqtl_intercross_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".js_"$LOD_J".LG"$j".11.txt"
	perl -pe "s/1 1/AC/g" $OUT_FILE4 > $OUT_FILE5"1"
	perl -pe "s/1 2/AD/g" $OUT_FILE5"1" > $OUT_FILE5"2"
	perl -pe "s/2 1/BC/g" $OUT_FILE5"2" > $OUT_FILE5"3"
	perl -pe "s/2 2/BD/g" $OUT_FILE5"3" > $OUT_FILE5
	rm $OUT_FILE5"1"
	rm $OUT_FILE5"2"
	rm $OUT_FILE5"3"
	
done

