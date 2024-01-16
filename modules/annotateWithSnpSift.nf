#!/usr/bin/env nextflow


process annotateWithSnpSift {

        tag "annotate_with_snpSift $bam_id"
	publishDir "${params.outDir}", mode:'copy'

	input:
		tuple val(bam_id) , file(bam_N), file(bam_T)
		path("${bam_id}-T_${bam_id}-N.filtered_only.vcf.gz")
		path("clinvar.vcf.gz")
		path("clinvar.vcf.gz.tbi")					
		path ("${bam_id}-T_${bam_id}-N.filtered_only.ann.vcf")


	output:
            path("${bam_id}-T_${bam_id}-N.filtered_only.ann_clinvar.vcf")

shell:

'''
java -jar /scratch/er01/ndes8648/pipeline_work/nextflow/INFRA-83-Somatic-ShortV/Somatic-shortV-nf_noEmit/Somatic-shortV-nf_start_2024_main/installtions/snpEff/SnpSift.jar annotate clinvar.vcf.gz !{bam_id}-T_!{bam_id}-N.filtered_only.ann.vcf > !{bam_id}-T_!{bam_id}-N.filtered_only.ann_clinvar.vcf

'''


}
