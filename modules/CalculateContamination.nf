#!/usr/bin/env nextflow

nextflow.enable.dsl=2


process CalculateContamination {

        tag "CalculateContamination $bam_id"
        publishDir "${params.outDir}", mode:'copy'

        input:
		tuple val(bam_id) , file(bam_N), file(bam_T)
                path pileupsTable_T
                path pileupsTable_N

        output:
                path ("${bam_id}-T_${bam_id}-N_contamination.table")
                path ("${bam_id}-T_segments.table")

        shell:
        '''
        
        gatk  --java-options "-Xmx16g" \
                CalculateContamination \
                -I !{bam_id}-T.pileups.table \
                -tumor-segmentation !{bam_id}-T_segments.table \
                -matched !{bam_id}-N.pileups.table \
                -O !{bam_id}-T_!{bam_id}-N_contamination.table
        '''

        }

