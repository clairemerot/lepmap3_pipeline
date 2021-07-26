#!/bin/bash
#SBATCH -J "prepare_mapcomp"
#SBATCH -o log_%j
#SBATCH -c 1 
#SBATCH -p small
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=1-00:00
#SBATCH --mem=1G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR



#this is a short pipeline in itself,
#first use R to format the map into en entry file for the .py that extracts a sequence around a given position
#then run the .py to extract the sequence,
#then use R to format for mapcomp


ls 08_analyze_maps/01_maps/ | while read i
	do 
	echo $i
	Rscript 01_scripts/Rscripts/format_for_mapcomp_1st_step.R "$i"
	python 01_scripts/utilities/01_extract_snp_variants_with_flanking_claire.py ../align_reads_map/04_reference/Cclu_Normal_QM.mPH_pilon.fasta "08_analyze_maps/04_prepare_map_comp/"$i".snplist" 100 "08_analyze_maps/04_prepare_map_comp/"$i".seq"
	Rscript 01_scripts/Rscripts/format_for_mapcomp_3rd_step.R "$i"
	done
	
	
	
	
	
	#perl -pe 's/\\*//' "08_analyze_maps/04_prepare_map_comp/"$i".snplist" > "08_analyze_maps/04_prepare_map_comp/"$i".snplist" #remove stars on sex markers