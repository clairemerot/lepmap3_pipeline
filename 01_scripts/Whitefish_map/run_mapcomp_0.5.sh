#!/bin/bash
#SBATCH -J "run_mapcomp_0.5"
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
MISS=0.5 #for filtering step, will filter out markers with missing rate above that fraction
MISS_NAME=50 

module load samtools
module load bwa

for LOD in 11    
	do
	MAP_FILE=08_analyze_maps/04_prepare_map_comp/contig_order_"$MISS"_"$MIN_COV"_"$i"_LOD_"$LOD".LGall.refined6.txt.csv
	NAME1=CorClMISS"$MISS_NAME"LOD"$LOD"

	#préparer la comparaison

	Rscript 01_scripts/Rscripts/format_for_mapcomp_4th_step.R "$MAP_FILE" "../mapcomp/02_data/map_other_sp/cisco_fem_nodup.csv" "$NAME1" "Cisco"
	
	Rscript 01_scripts/Rscripts/format_for_mapcomp_4th_step.R "$MAP_FILE" "../mapcomp/02_data/map_other_sp/coregone_europe.csv" "$NAME1" "CoregoneEUR"
	Rscript 01_scripts/Rscripts/format_for_mapcomp_4th_step.R "$MAP_FILE" "../mapcomp/02_data/map_other_sp/coregone_PA.csv" "$NAME1" "CoregonePA"
	

	cd ../mapcomp
	./01_scripts/00_prepare_input_fasta_file_from_csv.sh 02_data/"$NAME1"vsCisco.csv
	./mapcomp
	cp 03_mapped/wanted_loci.info 05_results/"$NAME1"vsCisco.csv
	
	./01_scripts/00_prepare_input_fasta_file_from_csv.sh 02_data/"$NAME1"vsCoregoneEUR.csv
	./mapcomp
	cp 03_mapped/wanted_loci.info 05_results/"$NAME1"vsCoregoneEUR.csv
	
	./01_scripts/00_prepare_input_fasta_file_from_csv.sh 02_data/"$NAME1"vsCoregonePA.csv
	./mapcomp
	cp 03_mapped/wanted_loci.info 05_results/"$NAME1"vsCoregonePA.csv
	
	cd ../lepmap3_pipeline

	done
	
