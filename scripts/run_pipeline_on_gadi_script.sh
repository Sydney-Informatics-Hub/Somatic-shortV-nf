#!/bin/bash
  
#PBS -P  
#PBS -N Somatic-shortV
#PBS -l walltime=02:00:00
#PBS -l ncpus=
#PBS -l mem=
#PBS -W umask=022
#PBS -q copyq
#PBS -e Somatic-shortV-nf.e
#PBS -o Somatic-shortV-nf.o
#PBS -l wd
#PBS -l storage=
#PBS -l jobfs=

# Load singularity and nextflow modules
module load nextflow/22.04.3
module load singularity

export NXF_SINGULARITY_CACHEDIR=/scratch/$PROJECT/$(whoami)/singularity

# Fill in these variables for your run
samples=
ponvcf=
ref=
small_exac_common=
intervalList_path=
outDir=



# Run the pipeline 
nextflow run main.nf \
        --input ${samples} \
        -profile gadi \
        --whoami $(whoami) --gadi_account $PROJECT \
        --ref ${ref} --small_exac_common ${small_exac_common}\
        --intervalList_path ${intervalList_path} \
        --ponvcf ${ponvcf} \
        --outDir ${outDir} 
