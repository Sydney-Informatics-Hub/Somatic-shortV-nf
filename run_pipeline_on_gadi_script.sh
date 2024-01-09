#!/bin/bash
  
#PBS -P er01 
#PBS -N Somatic-shortV
#PBS -l walltime=02:00:00
#PBS -l ncpus=1
#PBS -l mem=60GB
#PBS -W umask=022
#PBS -q copyq
#PBS -e Somatic-shortV-nf.e
#PBS -o Somatic-shortV-nf.o
#PBS -l wd
#PBS -l storage=scratch/er01+gdata/er01
#PBS -l jobfs=10GB

# Load singularity and nextflow modules
module load nextflow/22.04.3
module load singularity

export NXF_SINGULARITY_CACHEDIR=/scratch/$PROJECT/$(whoami)/singularity

# Fill in these variables for your run
samples=/scratch/er01/ndes8648/pipeline_work/nextflow/INFRA-83-Somatic-ShortV/test_files_for_Georgie/samples.csv
ponvcf=/scratch/er01/ndes8648/pipeline_work/nextflow/INFRA-83-Somatic-ShortV/test_files_for_Georgie/pon.vcf.gz
ref=/g/data/er01/SIH-HPC-WGS/Reference/hs38DH.fasta
small_exac_common=/g/data/er01/SIH-HPC-WGS/Reference/gatk-best-practices/somatic-hg38/small_exac_common_3.hg38.vcf.gz
intervalList_path=/scratch/er01/ndes8648/pipeline_work/nextflow/INFRA-83-Somatic-ShortV/test_files_for_Georgie/interval_files
outDir=results


# Select one of the following options
	# (A)  
	# - Generate optimised number of intervals based on your chosen genome and its size
	# - Please do the following:
		# - Hash to inactivate the `number_of_intervals` variable below
		# - You will also need to provide path to reference genome .dict file
			dict=/g/data/er01/SIH-HPC-WGS/Reference/hs38DH.dict

	# OR 

	# (B) 
	# Generate an arbitrary number of intervals between 2 and 100 based on your system resources
		#number_of_intervals=50



# Run the pipeline 
nextflow run main.nf \
        --input ${samples} \
        -profile gadi \
        --whoami $(whoami) --gadi_account $PROJECT \
        --ref ${ref} --dict ${dict}\
	    --small_exac_common ${small_exac_common}\
        --ponvcf ${ponvcf} \
        --outDir ${outDir} \
        --number_of_intervals ${number_of_intervals} 
