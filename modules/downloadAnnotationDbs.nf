#!/usr/bin/env nextflow

process downloadAnnotationDbs {

        tag "downloadAnnotationDbs $bam_id"
	publishDir "${params.outDir}", mode:'copy'


        input:
            path interval_path
        
	output:
	    path("GRCh38.86")
	    path("clinvar.vcf.gz")
	    path("clinvar.vcf.gz.tbi")		        

shell:

'''
#destination_path=/scratch/er01/ndes8648/pipeline_work/nextflow/INFRA-83-Somatic-ShortV/Somatic-shortV-nf_noEmit/Somatic-shortV-nf_with_autointerval_inputs/annotate_dbs
#destination_path=${PWD}/!{params.outDir}
destination_path=${PWD}



# Check if the folder already exists in the destination path
if [ -e "$destination_path/GRCh38.86" ]; then
    echo "File already exists. Skipping download."
else
    # Download the file using wget
    #snpEff download -dataDir /scratch/er01/ndes8648/pipeline_work/nextflow/INFRA-83-Somatic-ShortV/Somatic-shortV-nf_noEmit/Somatic-shortV-nf_with_autointerval_inputs/annotate_dbs GRCh38.86 
    snpEff download -dataDir ${destination_path} GRCh38.86

    # Check if the download was successful
    if [ $? -eq 0 ]; then
        echo "Download successful."
    else
        echo "Download failed. Please check the URL and try again."
    fi
fi

# Check if the clinvar already exists in the destination path
if [ -e "$destination_path/clinvar.vcf.gz" ]; then
    echo "File already exists. Skipping download."
else
    # Download the file using wget
    #wget -P /scratch/er01/ndes8648/pipeline_work/nextflow/INFRA-83-Somatic-ShortV/Somatic-shortV-nf_noEmit/Somatic-shortV-nf_with_autointerval_inputs/annotate_dbs https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/clinvar.vcf.gz
    #wget -P /scratch/er01/ndes8648/pipeline_work/nextflow/INFRA-83-Somatic-ShortV/Somatic-shortV-nf_noEmit/Somatic-shortV-nf_with_autointerval_inputs/annotate_dbs https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/clinvar.vcf.gz.tbi

    wget -P ${destination_path} https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/clinvar.vcf.gz
    wget -P ${destination_path} https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/clinvar.vcf.gz.tbi


    # Check if the download was successful
    if [ $? -eq 0 ]; then
        echo "Download successful."
    else
        echo "Download failed. Please check the URL and try again."
    fi
fi



'''

}
