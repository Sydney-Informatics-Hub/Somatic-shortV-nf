#!/usr/bin/env nextflow

process mutect2 {

        
        // where to publish the outputs
        tag "$bam_id $splitIntervalNumber"
        publishDir "${params.outDir}", mode:'copy'
        
        
        
        input:
                tuple val(bam_id) , file(bam_N), file(bam_T)
                each splitIntervalNumber
		path pon_vcf
                path pon_vcf_index
                path interval_path
                
        output:
                path ("${bam_id}-T_${bam_id}-N.unfiltered.${splitIntervalNumber}.vcf.gz") 
                path ("${bam_id}-T_${bam_id}-N.unfiltered.${splitIntervalNumber}.vcf.gz.stats") 
                path ("${bam_id}-T_${bam_id}-N.f1r2.${splitIntervalNumber}.tar.gz")

        
        script:
        // Run mutect2 on a Tumor/Normal sample-pair

        """
        

        echo "The values: $bam_id $bam_N $bam_T"

        gatk Mutect2 --java-options '-DGATK_STACKTRACE_ON_USER_EXCEPTION=true' \
             -R ${params.ref} \
             -I ${bam_T} \
             -I ${bam_N} \
             --panel-of-normals ${pon_vcf} \
             -normal ${bam_id}-N \
             --f1r2-tar-gz ${bam_id}-T_${bam_id}-N.f1r2.${splitIntervalNumber}.tar.gz \
             -XL chrM \
             -L ${interval_path}/${splitIntervalNumber}-scattered.interval_list \
	     -O ${bam_id}-T_${bam_id}-N.unfiltered.${splitIntervalNumber}.vcf.gz

        #-XL !{params.exclude_intervals} \

        """




}


