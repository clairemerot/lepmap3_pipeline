# lepmap3_pipeline
###LepMap 3

##step 0 : install Lepmap
#https://sourceforge.net/p/lep-map3/wiki/LM3%20Home/
#download the binaries from https://sourceforge.net/projects/lep-map3/files/ 
#unzip /bin into the lepmap_pipeline folder
#everything should now be run by "java -cp bin/ Modulename"

# step 1 : prepare input files
#- Genotypes
#post.gz coming from preparing script for lepmap, based on bam files. Run scripts from lepmap pre-processing pipeine (see wiki)
#in pileupParser2.awk, on line 21, we cna adjust the minimum coverage for filtering
#The sequencing data processing pipeline for Lep-MAP3 is based on "SAMtools mpileup" and custom scripts
#pileupParser2.awk and pileup2posterior.awk, provided in scripts.zip. 

samtools mpileup -q 10 -Q 10 -s $(cat sorted_bams)|awk -f pileupParser2.awk|awk -f pileup2posterior.awk|gzip >post.gz

#as posterior names, we used ready_for_lepmap3_"covX"_"family".gz (X is the minimum coverage given as filter)


#- Pedigree 
#id of the samples and order should match the genotype file
#using the sample list (= first line of post.gz file), prepare a pedigree.txt file with 6 lines and n+2 tab-sep columns
#line 1: family_name
#line 2: ind_name
#line 3 : father_name (0 if not available)
#line 4: mother_name 
#line 5 sex (male=1, fem=2)
#line 6: phenotype (just put 0

#- family file
#because I am building two maps separately for the two families I have two pedigree files (pedigree_"family".txt) and two genotype files.
#their name includes the family name which I give in families.txt.
#remember that all families can also be put together in the geno and pedigree files to make a single map.

# step 2 : edit the 01_config.sh
#parameter to set : missing value filter level, nb of CPU, LOD and size limit for chromosome clusterin, path of the family file, etc..


# step 3 : Parental call module
#run the parental call 
#one can edit the SEX variable to precise XY or ZW system or don't bother about sex-linked markers.
#one can also use vcf entry file at that step using special arguments. Not tried
#the parental call has also put the pedigree as header of the genotype data.
#avoid using the "outputParentPosterior=1" even if one parent has poor data. It messed up with my data and markers. Providing grands parents is better.

./01_scripts/03_run_parentcall.sh


# step 4 : Filtering 
#adjust MISS parameter to filter for missing data (for instance missingLimit=0.9 represent 90% of progeny with data)

#caution: for single family data use dataTolerance like 0.001 or 0.0001 but subsequent distortionLod=1 in SeparateChromosomes2 and JoinSingles2All

#this step will determine the markers actually use in the map.
#the number id of each marker in the final map comes from the output of this stage
#therefore the final steps of the script calls a Rscript to build the marker list.

./01_scripts/04_run_filtering.sh

# step5: separate markers into chromosome (LG linkage groups)
#this step splits the markers into LG.
#the most important parameter to adjust is the LOD in the 01_config.sh
#to see the output and the number of markers per chromosome, see the file .repartition

./01_scripts/05_run_sep_chromosome

# step6 join single 
#if there are many markers not placed into LG, this module can put them on the LG with a smaller LOD limit
#not run because I had less than 1 % of the markers out of the LG
./01_scripts/06_run_join_single

#if this step is relevant, remember to change in the 01_order_marker the path to the map to make it use the map with joinsingle

# step7 order marker
#this step is the longest : it orders the marker within each LG
#it is supposed to use several iterations (variable ITE set to 5)
#it can re-order a previous order, to improve the likelihood. 
#This is the REFINE_STEPS variable. In practice, I do not observe an improve in the likelihood value 
#but I have not checked whether the marker order has changed.

#the last part of the script makes a link with the marker list extracted at step 4 and return the map with all the chromosome together  and #each marker with its coresponding identification (scaffold position)

#it can also filters to remove the repetitive lines (positin on which there are more than 200 markers)-> output file with f

#there is a possibility to phase which might be useful for QTL mapping. Yet, I am not fully sure how this works and how translate the 0/1 #of the phase into the AA/AB of RQTL etc...

./01_scripts/07_run_order_marker

#one may edit REFINE_STEPS variable, now set to 2 (a total of 3 ordering steps of 5 iterations each

# step8 look at the maps
#in th e08 folder, one can find the output of the map with contig/position name and the plot of marker position
#there are several Rfiles to do a summary

#the 08_format_for_mapcomp.sh will prepare entry files for mapcomp
#the 08_format_for_chromonomer.sh will prepare entry files for chromonomer (a .tsv with the position on the map , and a fasta with sequence associated with each marker)
