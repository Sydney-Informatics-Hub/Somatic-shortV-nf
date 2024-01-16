#!/usr/bin/env nextflow


process annotateWithSnpEff {

        tag "annotate_with_snpEff $bam_id"
	publishDir "${params.outDir}", mode:'copy'


        input:
            tuple val(bam_id) , file(bam_N), file(bam_T)
            path("${bam_id}-T_${bam_id}-N.filtered_only.vcf.gz")
	    path("GRCh38.86")
        
        output:
            path("${bam_id}-T_${bam_id}-N.filtered_only.ann.vcf")


shell:

'''
# https://pcingola.github.io/SnpEff/download/

#snpEff download -dataDir /scratch/er01/ndes8648/pipeline_work/nextflow/INFRA-83-Somatic-ShortV/singularity_cache/ GRCh38.86
#quay.io/biocontainers/snpeff:5.2--hdfd78af_0

java -jar /scratch/er01/ndes8648/pipeline_work/nextflow/INFRA-83-Somatic-ShortV/Somatic-shortV-nf_noEmit/Somatic-shortV-nf_start_2024_main/installtions/snpEff/snpEff.jar  -v -o gatk -stats !{bam_id}-T_!{bam_id}-N.filtered_only.ann.html GRCh38.86 -dataDir /scratch/er01/ndes8648/pipeline_work/nextflow/INFRA-83-Somatic-ShortV/singularity_cache/ !{bam_id}-T_!{bam_id}-N.filtered_only.vcf.gz > !{bam_id}-T_!{bam_id}-N.filtered_only.ann.vcf
'''

}

