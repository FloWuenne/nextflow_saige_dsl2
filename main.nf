#!/usr/bin/env nextflow

/* Author : Florian Wuennemann */

/* Enable DSL2 syntax */
nextflow.enable.dsl=2

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
bgen_prefix       :  ${params.bgen_prefix}
bgen_suffix       :  ${params.bgen_suffix}
bgen_path         :  ${params.bgen_path}
chromosomes       :  ${params.chrom}
sampleFile        :  ${params.sampleFile}
vcfField          :  ${params.vcfField}
minMAC            :  ${params.minMAC}
minMAF            :  ${params.minMAF}
"""

/* Include processes from saige_processes.nf */
include { saige_step1_bin; saige_step2_spa; prepare_files; create_plots } from './saige_processes'

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
                  params.bgen_prefix, 
                  params.bgen_suffix, 
                  params.bgen_path ,
                  params.sampleFile,
                  params.vcfField ,
                  params.minMAC,
                  params.minMAF)

   saige_step2_spa.out.assoc_res
      .groupTuple()
      .set{ tuple_assoc }

   prepare_files(tuple_assoc)

   Channel
      .fromPath(params.gwas_cat)
      .ifEmpty { exit 1, "Cannot find GWAS catalogue CSV  file : ${params.gwas_cat}" }
      .set { ch_gwas_cat }

   prepare_files.out.merged_out
      .join(prepare_files.out.top_hits)
      .combine(ch_gwas_cat)
      .set{ saige_res }

   create_plots(saige_res)


}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone!" : "Oops .. something went wrong" )
}