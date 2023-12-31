#!/usr/bin/env nextflow

// Import subworkflows to be run in the workflow
include { checkInputs                                } from './modules/checkCohort'
include { mutect2                                    } from './modules/mutect2'
include { GatherVcfs                                 } from './modules/GatherVcfs'
include { MergeMutectStats                           } from './modules/MergeMutectStats'
include { LearnReadOrientationModel                  } from './modules/LearnReadOrientationModel'
include { GetPileupSummaries_T; GetPileupSummaries_N } from './modules/GetPileupSummaries'
include{  CalculateContamination                     } from './modules/CalculateContamination'
include { FilterMutectCalls                          } from './modules/FilterMutectCalls'
include { getFilteredVariants                        } from './modules/getFilteredVariants'
   


/// Print a header for your pipeline 

log.info """\

===================================================================
===================================================================
SOMATIC SHORT V - NF 
===================================================================
===================================================================

Created by the Sydney Informatics Hub, University of Sydney

Documentation	@ https://github.com/Sydney-Informatics-Hub/Somatic-shortV-nf

Cite					@ https://doi.org/10.48546/workflowhub.workflow.691.1

Log issues    @ https://github.com/Sydney-Informatics-Hub/Somatic-shortV-nf/issues

All the default parameters are set in `nextflow.config`

=======================================================================================
Workflow run parameters 
=======================================================================================
version           : ${params.version}
input             : ${params.input}
reference         : ${params.ref}
small_exac_common : ${params.small_exac_common}
ponvcf            : ${params.ponvcf}
intervalList_path : ${params.intervalList_path}
outDir            : ${params.outDir}
workDir           : ${workflow.workDir}

=======================================================================================

 """

/// Help function 
// This is an example of how to set out the help function that 
// will be run if run command is incorrect (if set in workflow) 
// or missing/  

def helpMessage() {
    log.info"""
  Usage:   nextflow run main.nf --input samples.csv --ref reference.fasta  --intervalList_path path_to_intervals --ponvcf pon.vcf.gz

  Required Arguments:
    --input		                      Full path and name of sample input file (csv format).
	  --ref			                      Full path and name of reference genome (fasta format).
    --intervalList_path             Full path to the folder containing the interval lists required for Mutect2 step
    --ponvcf                        Full path and name of the Panel of Normals (ponvcf) file
	
  Optional Arguments:
    --outDir                        Specify name of results directory. 

  HPC accounting arguments:
    --whoami                    HPC user name (Setonix or Gadi HPC)
    --gadi_account              Project accounting code for NCI Gadi (e.g. aa00)
  """.stripIndent()
}

/// Main workflow structure. 

workflow {

// Show help message if --help is run or if any required params are not 
// provided at runtime

  if ( params.help == true || params.ref == false || params.input == false || params.ponvcf == false || params.small_exac_common == '' || params.intervalList_path == '')
	{   
        // Invoke the help function above and exit
        helpMessage()
        exit 1
	} 

	else 
	{
	
  // Check inputs file exists
	checkInputs(Channel.fromPath(params.input, checkIfExists: true))
	
  // Split cohort file to collect info for each sample
	bam_pair_ch = checkInputs.out
		.splitCsv(header: true, sep:",")
		.map { row -> tuple(row.sampleID, file(row.bam_N), file(row.bam_T))}
	

	//Run the processes 
	
  // Run mutect2 on a Tumor/Normal sample-pair
  mutect2(bam_pair_ch,params.intervalList,params.ponvcf,params.ponvcf+'.tbi')

  // Gather multiple VCF files from a scatter operation into a single VCF file
	GatherVcfs(mutect2.out[0].collect(),bam_pair_ch)

  // Combine the stats files across the scattered Mutect2 run
	MergeMutectStats(mutect2.out[1].collect(),bam_pair_ch)

  // Run the gatk LearnReadOrientationModel 
	LearnReadOrientationModel(mutect2.out[2].collect(),bam_pair_ch)
  
  // Tabulate pileup metrics for inferring contamination - Tumor samples
  GetPileupSummaries_T(params.small_exac_common,params.small_exac_common+'.tbi', bam_pair_ch)

  // Tabulate pileup metrics for inferring contamination - Normal samples
  GetPileupSummaries_N(params.small_exac_common,params.small_exac_common+'.tbi', bam_pair_ch)
  
  // Calculate the fraction of reads coming from cross-sample contamination
	CalculateContamination(bam_pair_ch,GetPileupSummaries_T.out.collect(),GetPileupSummaries_N.out.collect())

  // Filter somatic SNVs and indels called by Mutect2
	FilterMutectCalls(bam_pair_ch,MergeMutectStats.out[1].collect(),CalculateContamination.out[0].collect(),CalculateContamination.out[1].collect(),GatherVcfs.out[0].collect(),GatherVcfs.out[1].collect(),LearnReadOrientationModel.out.collect(),params.ref)	

  // Select the subset of filtered variants from the VCF file 
	getFilteredVariants(bam_pair_ch,FilterMutectCalls.out.collect(),params.ref)


	}}

workflow.onComplete {
  summary = """
=======================================================================================
Workflow execution summary
=======================================================================================

Duration    : ${workflow.duration}
Success     : ${workflow.success}
workDir     : ${workflow.workDir}
Exit status : ${workflow.exitStatus}
outDir      : ${params.outDir}

=======================================================================================
  """
  println summary

}
