#!/usr/bin/env nextflow

/* Author : Florian Wuennemann */

/* Enable DSL2 syntax */
nextflow.enable.dsl=2

/* Define parameters */
params.grm_plink_input = "plink_files"
params.phenoFile = "phenoFile"
params.outdir = "results"
params.phenoCol = "test"
params.covarColList = "234"
params.sampleIDcol = "IID"

params.bgen_list = "test_bgen_list.csv"
params.bgen_dir = "."
params.sampleFile = "samplefileforbgen_10000samples.txt"
params.varianceRatio = "varianceRatio"
params.rda = "test"
params.vcfField = "GT"
params.minMAC = "3"
params.minMAF = "0.0001"

/* log info */
log.info """\
 NEXTFLOW - DSL2 - SAIGE - P I P E L I N E
 ===================================

Step1 parameters
===================================
grm_plink_input   :  ${params.grm_plink_input}
phenoFile         :  ${params.phenoFile}
outdir            :  ${params.outdir}
phenoCol          :  ${params.phenoCol}
covarColList      :  ${params.covarColList}
sampleIDcol       :  ${params.sampleIDcol}

Step2 parameters
===================================
bgen_list         :  ${params.bgen_list}
sampleFile        :  ${params.sampleFile}
vcfField          :  ${params.vcfField}
minMAC            :  ${params.minMAC}
minMAF            :  ${params.minMAF}
"""

/* Include processes from saige_processes.nf */
include { saige_step1_bin; saige_step2_spa } from './saige_processes'

workflow {

    plink_input_ch = 
    Channel
        .fromFilePairs("${params.grm_plink_input}", size:3, flat : true, checkExists: true)
        .ifEmpty { exit 1, "PLINK files not found: ${params.grm_plink_input}.\nPlease specify a valid --grm_plink_input value. eg. testdata/*.{bed,bim,fam}" }

     phenoFile_ch = 
     Channel
        .fromPath(params.phenoFile)
        .ifEmpty { exit 1, "Cannot find pheno_File file : ${params.phenoFile}" } 

    saige_step1_bin(plink_input_ch , phenoFile_ch, phenoCol = params.phenoCol, covarColList = params.covarColList, sampleIDcol =  params.sampleIDcol)
    
    bgen_files = 
      Channel
         .fromPath(params.bgen_list)
         .ifEmpty { exit 1, "Cannot find CSV bgen file : ${params.bgen_list}" }
         .splitCsv(skip:1)
         .map { chr, bgen_dir, bgen, index, bgen_file, bgen_index_file -> [file(bgen).simpleName, chr, file(bgen_file), file(bgen_index_file)] }

     saige_step2_spa(bgen_files, rda = saige_step1_bin.out.rda, varianceRatio = saige_step1_bin.out.varRatio,  sampleFile = channel.fromPath(params.sampleFile), vcfField = params.vcfField , minMAC = params.minMAC, minMAF = params.minMAF)
}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone!" : "Oops .. something went wrong" )
}