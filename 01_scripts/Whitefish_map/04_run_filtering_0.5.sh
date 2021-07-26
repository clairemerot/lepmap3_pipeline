#!/bin/bash
#SBATCH -J "LM3_Filtering0.5"
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

##step 4: Filtering
#this step will determine the markers actually use in the map.
# the number id of each marker in the final map comes from the output of this stage

#variables t
#parameters to adjust if needed
D="dataTolerance=0.000000000000000000000001" #use a lower tolerance when running on several families
#MAF="MAFLimit=0.20" #unsure about how useful that parameter is for a single family : in one family min MAf should be 25% for all alleles

#compulsory (file names)
IN_FILE="03_parent_call_data/data_call_"$MIN_COV"_"$i".gz"
OUT_FILE="04_filtering/data_f_"$MISS"_"$MIN_COV"_"$i".gz"


#run the module
zcat $IN_FILE | java -cp bin/ Filtering2 data=- removeNonInformative=1 missingLimit=$MISS $D  | gzip > $OUT_FILE

#extract the marker list
echo "extracting the markerlist and formating it in R"
zcat $OUT_FILE | awk '{print $1}' > "04_filtering/contig_"$MISS"_"$MIN_COV"_"$i".txt"
zcat $OUT_FILE | awk '{print $2}' > "04_filtering/pos_"$MISS"_"$MIN_COV"_"$i".txt"
Rscript 01_scripts/Rscripts/make_markerlist.R "$MISS" "$MIN_COV" "$i"


