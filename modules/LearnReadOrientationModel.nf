#!/usr/bin/env nextflow

process LearnReadOrientationModel {

        tag "LearnReadOrientationModel $bam_id"
        publishDir "${params.outDir}/${bam_id}/LearnReadOrientationModel", mode:'copy'

        input:
                path ('*') 
                tuple val(bam_id) , file(bam_N), file(bam_T)
                
        output:
                path ("${bam_id}-T_${bam_id}-N.read-orientation-model.tar.gz")

        shell:
        // Run the gatk LearnReadOrientationModel 

        '''        
        ls !{bam_id}*f1r2.*.tar.gz > !{bam_id}-T_!{bam_id}-N.unfiltered_f1r2.args
        

        gatk LearnReadOrientationModel --java-options "-Xmx10g" \
                --input !{bam_id}-T_!{bam_id}-N.unfiltered_f1r2.args \
                -O !{bam_id}-T_!{bam_id}-N.read-orientation-model.tar.gz

        '''


}

