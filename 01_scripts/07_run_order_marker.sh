
##step 7: Order markers within LG
#this step is the longest and might necessitate several iteration before being accurate

#A parameter we can change
#to refine further the order
REFINE_STEPS=2

#edit on which config file one want to work
source 01_scripts/01_config6.sh

#because I map the two families separately (different inversion rearrangement - marker order is not expected to be the same)
#, I create here a loop with family name
# note that lepmap allow several families to build the map together, they can all be put together in the pedigree file
cat $FAMILY | while read i
do
echo "family" $i

#variables 
#compulsory (file names)
IN_FILE="04_filtering/data_f_"$MISS"_"$MIN_COV"_"$i".gz"
MAP_FILE="05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".txt" 
#MAP_FILE="06_joinsingle/map.js_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".txt" # or use the map resulting from joinsingle 
NB_CHR=$[$(wc -l "05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".repartition" | cut -d " " -f 1)-2] #nb of linkage groups from step 5


#other parameters (adjust if needed)
ITE="numMergeIterations=5" #will merge several iterations
RECOMB_1="recombination1=0" # for species with non-recoùmbining male adjust recombination rate to 0
#PHASE="outputPhasedData=1" #if we want phased data as output. may be useful for QTL?

#run the module once for intitial order
for j in $(seq $NB_CHR)
do
echo "assessing marker order for LG" $j "1st step"
OUT_FILE="07_order_LG/order_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".LG"$j".1.txt"
zcat $IN_FILE | java -cp bin/ OrderMarkers2 map=$MAP_FILE numThreads=$CPU data=- $ITE $RECOMB_1 $PHASE chromosome=$j > $OUT_FILE
	for k in $(seq $REFINE_STEPS)
	 	do
 	IT=$[$k + 1]
	echo "assessing marker order for LG" $j "refining step" $IT
 	OUT_FILE="07_order_LG/order_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".LG"$j"."$IT".txt"
	ORDER_FILE="07_order_LG/order_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".LG"$j"."$k".txt"
 	zcat $IN_FILE | java -cp bin/ OrderMarkers2 evaluateOrder=$ORDER_FILE  numThreads=$CPU data=- $ITE $RECOMB_1 $PHASE chromosome=$j > $OUT_FILE
	done
done

Rscript 01_scripts/Rscripts/match_marker_map.R "$MISS" "$MIN_COV" "$i" "$LOD" "$REFINE_STEPS" "$NB_CHR"

done