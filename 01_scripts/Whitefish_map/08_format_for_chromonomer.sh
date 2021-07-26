#this is a short pipeline in itself,
#first use R to format the map into en entry file for the .py that extracts a sequence around a given position
#then run the .py to extract the sequence,
#the 3rd one use R again on the original map file to format for chromocomer


ls 08_analyze_maps/01_maps/ | while read i
	do 
	echo $i
	Rscript 01_scripts/Rscripts/format_for_chromonomer_1st_step.R "$i"
	python 01_scripts/utilities/01_extract_snp_variants_with_flanking_claire_into_fasta.py ../align_reads_map/04_reference/Cclu_Normal_QM.mPH_pilon.fasta "08_analyze_maps/05_prepare_chromonomer/"$i".snplist" 100 "08_analyze_maps/05_prepare_chromonomer/"$i".fasta"
	Rscript 01_scripts/Rscripts/format_for_chromonomer_3rd_step.R "$i"
	done
	
	
	
	
	
