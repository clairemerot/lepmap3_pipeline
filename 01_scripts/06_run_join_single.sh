
##step 5: Separate chromosome
#this step will look for markers with relative linkage to split them into chromosome

#The most important parameter to change
#try different values, the number of LG should be constant above a certain point
LOD=7


source 01_scripts/01_config10.sh

#because I map the two families separately (different inversion rearrangement - marker order is not expected to be the same)
#, I create here a loop with family name
# note that lepmap allow several families to build the map together, they can all be put together in the pedigree file
cat $FAMILY | while read i
do
echo "family" $i

#variables 
#compulsory (file names)
IN_FILE="04_filtering/data_f_"$MISS"_"$MIN_COV"_"$i".gz"
OUT_FILE="06_joinsingle/map.js_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".txt"
MAP_FILE="05_map_chr/map_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".txt"

#other parameters (adjust if needed)
D="distortionLod=1 " #to remove markers with H-W distortion in a single family
LODDIFF="lodDifference=1" #requires a difference of LOD # not understood: is it between LG?
RECOMB_1="maleTheta=0" # for species with non-recoùmbining male adjust recombination rate to 0
RECOMB_2="femaleTheta=0.03" # 


#run the module
zcat $IN_FILE | java -cp bin/ JoinSingles2All data=- lodLimit=$LOD numThreads=$CPU iterate=1  $SIZEL $RECOMB_1 $RECOMB_2 map=$MAP_FILE > $OUT_FILE


#evaluate chromosome repartition 
#typically if there is just one big chromosome -> raise LOD
#if there are plenty of chromosome (more than expected -> lower LOD
#if there are X big chromosome and plenty of chromosome with very few markers, raise SizeLimit and then rather use joinsingle with smalle LOD
awk '{print $1}' $OUT_FILE | sort -n | uniq -c 
awk '{print $1}' $OUT_FILE | sort -n | uniq -c > "06_joinsingle/map.js_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".repartition"

done