
##step 3: Parental call module
#it will also join the pedigree and the genotype data together

source 01_scripts/01_config3.sh

#because I map the two families separately (different inversion rearrangement - marker order is not expected to be the same)
#, I create here a loop with family name
# note that lepmap allow several families to build the map together, they can all be put together in the pedigree file
cat $FAMILY | while read i
do
echo "family" $i

#variables 
#compulsory (file names)
GENO_FILE="02_raw_data/ready_for_lepmap3_"$MIN_COV"_"$i".gz"
PEDIGREE_FILE="02_raw_data/pedigree_"$i".txt"
OUT_FILE="03_parent_call_data/data_call_"$MIN_COV"_"$i".gz"

#parameters
SEX="XLimit=2" #to call marker on sex chromosome in a XY system (use Zlimit=2 in a ZW system or nothing if we don't want sex-chromosome markers)

#run the module
zcat $GENO_FILE | java -cp bin/ ParentCall2 data=$PEDIGREE_FILE $SEX posteriorFile=- removeNonInformative=1 | gzip > $OUT_FILE

#the parental call has also put the pedigree as header of the genotype data. To visualize:
echo "these are the first 8 columns & 10 lines of the output file"
zcat $OUT_FILE | cut -f 1-8 | head -n 10

done