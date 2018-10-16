
##step 4: Filtering
#this step will determine the markers actually use in the map.
# the number id of each marker in the final map comes from the output of this stage

source 01_scripts/01_config3.sh #remember to adjust here for misisng rate

#because I map the two families separately (different inversion rearrangement - marker order is not expected to be the same)
#, I create here a loop with family name
# note that lepmap allow several families to build the map together, they can all be put together in the pedigree file

cat $FAMILY | while read i
do
echo "family" $i

#variables t
#parameters to adjust if needed
D="dataTolerance=0.001" #use a lower tolerance when running on several families
MAF="MAFLimit=0.20" #unsure about how useful that parameter is for a single family : in one family min MAf should be 25% for all alleles

#compulsory (file names)
IN_FILE="03_parent_call_data/data_call_"$MIN_COV"_"$i".gz"
OUT_FILE="04_filtering/data_f_"$MISS"_"$MIN_COV"_"$i".gz"


#run the module
zcat $IN_FILE | java -cp bin/ Filtering2 data=- removeNonInformative=1 missingLimit=$MISS $MAF $D  | gzip > $OUT_FILE

#extract the marker list
echo "extracting the markerlist and formating it in R"
zcat $OUT_FILE | awk '{print $1}' > "04_filtering/contig_"$MISS"_"$MIN_COV"_"$i".txt"
zcat $OUT_FILE | awk '{print $2}' > "04_filtering/pos_"$MISS"_"$MIN_COV"_"$i".txt"
Rscript 01_scripts/Rscripts/make_markerlist.R "$MISS" "$MIN_COV" "$i"


done