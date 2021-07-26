#!/bin/bash
#SBATCH -J "LM3_ParentCall"
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
MIN_COV=cov3 

#or use a config file
#source 01_scripts/01_config_cov3_miss0.3_LOD10.sh

##step 3: Parental call module
#it will also join the pedigree and the genotype data together



#variables 
#compulsory (file names)
GENO_FILE="02_raw_data/ready_for_lepmap3_"$MIN_COV"_"$i".gz"
PEDIGREE_FILE="02_raw_data/pedigree_"$i".txt"
OUT_FILE="03_parent_call_data/data_call_"$MIN_COV"_"$i".gz"

#parameters
#SEX="XLimit=2" #to call marker on sex chromosome in a XY system (use Zlimit=2 in a ZW system or nothing if we don't want sex-chromosome markers)

#run the module
zcat $GENO_FILE | java -cp bin/ ParentCall2 data=$PEDIGREE_FILE posteriorFile=- removeNonInformative=1 | gzip > $OUT_FILE

#the parental call has also put the pedigree as header of the genotype data. To visualize:
echo "these are the first 8 columns & 10 lines of the output file"
zcat $OUT_FILE | cut -f 1-8 | head -n 10


