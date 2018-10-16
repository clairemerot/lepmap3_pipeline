
#I have tried different filtering option for coverage in the pre-processing files
MIN_COV=cov3


#because I map the two families separately (different inversion rearrangement - marker order is not expected to be the same)
#, I create here a loop with family name
# note that lepmap allow several families to build the map together, they can all be put together in the pedigree file
#this file can have just one line if there is only one family or pool of families
FAMILY="02_raw_data/families.txt" #list of families names (there can be just one name)

#for separatechromosome step
LOD=15 #(play with that)
SIZEL=5 # to exclude chromosome with less than X markers (adjust depending on the data)


#for filtering step, will filter out markers with missing rate above that fraction
MISS="0.2" #main parameter to be adjusted

#to parrallelize longer steps (separate chromosomes and order markers)
CPU=8