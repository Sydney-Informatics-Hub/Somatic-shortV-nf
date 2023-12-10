#!/usr/bin/env nextflow

/// To use DSL-2 will need to include this
nextflow.enable.dsl=2

//container "${params.gatk4__container}"

process GatherVcfs_step {

        tag "GatherVcfs_step $bam_id"
        publishDir "${params.outDir}", mode:'copy'


        input:
                path ('*')
                tuple val(bam_id) , file(bam_N), file(bam_T)
                

        output:
                path ("${bam_id}-T_${bam_id}-N.unfiltered.vcf.gz") 
                path ("${bam_id}-T_${bam_id}-N.unfiltered.vcf.gz.tbi")

        
        script:

        """
        

        # GatherVcfs requires intervals in order
        ls ${bam_id}-T_${bam_id}-N.unfiltered.*.vcf.gz   >${bam_id}_gathered_vcfs_across_subintervals.list
 
        gatk GatherVcfs \
                -I  ${bam_id}_gathered_vcfs_across_subintervals.list \
                -O  ${bam_id}-T_${bam_id}-N.unfiltered_unsorted.vcf.gz

        #Sort
        gatk SortVcf \
                -I ${bam_id}-T_${bam_id}-N.unfiltered_unsorted.vcf.gz \
                -O ${bam_id}-T_${bam_id}-N.unfiltered.vcf.gz

        """

}

