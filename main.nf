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

params.bgen_filebase = "genotype_100markers"
params.bgen_path = "."
params.bgen_dir = "."
params.sampleFile = "samplefileforbgen_10000samples.txt"
params.varianceRatio = "varianceRatio"
params.rda = "test"
params.vcfField = "GT"
params.minMAC = "3"
params.minMAF = "0.0001"
/*params.chrom = ['1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','X'] */
params.chrom = ['1','2']

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
sampleFile        :  ${params.sampleFile}
vcfField          :  ${params.vcfField}
minMAC            :  ${params.minMAC}
minMAF            :  ${params.minMAF}
"""

/* Include processes from saige_processes.nf */
include { saige_step1_bin; saige_step2_spa; prepare_files; create_report } from './saige_processes'

workflow {

   Channel
      .fromFilePairs("${params.grm_plink_input}", size:3, flat : true, checkExists: true)
      .ifEmpty { exit 1, "PLINK files not found: ${params.grm_plink_input}.\nPlease specify a valid --grm_plink_input value. eg. testdata/*.{bed,bim,fam}" }
      .set { plink_input_ch }

   Channel
      .fromPath(params.phenoFile)
      .ifEmpty { exit 1, "Cannot find pheno_File file : ${params.phenoFile}" } 
      .set{ phenoFile_ch }
   
   saige_step1_bin(plink_input_ch , phenoFile_ch, params.phenoCol, params.covarColList, params.sampleIDcol) 

   saige_step2_spa(saige_step1_bin.out.step1_out,
                  params.chrom,
                  params.bgen_filebase, 
                  params.bgen_path ,
                  params.sampleFile,
                  params.vcfField ,
                  params.minMAC,
                  params.minMAF)

   saige_step2_spa.out.assoc_res
      .groupTuple()
      .set{ tuple_assoc }

   prepare_files(tuple_assoc)

   prepare_files.out.chr_files
      .groupTuple()
      .set{ saige_res }

   saige_res.view()

   Channel
      .fromPath(params.gwas_cat)
      .ifEmpty { exit 1, "Cannot find GWAS catalogue CSV  file : ${params.gwas_cat}" }
      .set { ch_gwas_cat }

   create_report(saige_res,ch_gwas_cat)


}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone!" : "Oops .. something went wrong" )
}