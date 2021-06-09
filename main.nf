#!/usr/bin/env nextflow

/* Author : Florian Wuennemann */

/* Enable DSL2 syntax */
nextflow.enable.dsl=2

/* Define parameters */
params.grm_plink_input = "plink_files"
params.phenoFile = "phenoFile"
params.outdir = "results"


/* log info */
log.info """\
 NEXTFLOW - DSL2 - SAIGE - P I P E L I N E
 ===================================
grm_plink_input    :   ${params.grm_plink_input}
phenoFile          :   ${params.phenoFile}
outdir             :   ${params.outdir}
"""

/* Include processes from saige_processes.nf */
include { saige_step1_bin } from './saige_processes'

workflow {

    plink_input_ch = Channel
        .fromFilePairs("${params.grm_plink_input}", size:3, flat : true, checkExists: true)
        .ifEmpty { exit 1, "PLINK files not found: ${params.grm_plink_input}.\nPlease specify a valid --grm_plink_input value. eg. testdata/*.{bed,bim,fam}" }

     phenoFile_ch = Channel
        .fromPath(params.phenoFile)
        .ifEmpty { exit 1, "Cannot find pheno_File file : ${params.phenoFile}" } 

    saige_step1_bin(plink_input_ch , phenoFile_ch)
/*     saige_step2_bin() */
}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone!" : "Oops .. something went wrong" )
}