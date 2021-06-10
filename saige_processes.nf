process saige_step1_bin {
    tag "$grm_plink_input"
    publishDir "${params.outdir}/SAIGE_gwas_1_fit_null_glmm", mode: 'copy'

    input:
    tuple val(grm_plink_input), path(bed), path(bim), path(fam)
    each path(phenoFile)
    val phenoCol
    val covarColList
    val sampleIDcol

    output:
    path "step1_${phenoFile.baseName}_out.rda", emit: rda
    path "step1_${phenoFile.baseName}.varianceRatio.txt", emit: varRatio

    script:
    """
    step1_fitNULLGLMM.R \
      --plinkFile=${grm_plink_input} \
      --phenoFile="${phenoFile}" \
      --phenoCol=${phenoCol} \
      --covarColList=${covarColList} \
      --sampleIDColinphenoFile=${sampleIDcol} \
      --traitType=binary \
      --outputPrefix="step1_${phenoFile.baseName}_out" \
      --outputPrefix_varRatio="step1_${phenoFile.baseName}" \
      --nThreads=${task.cpus} \
      --LOCO=FALSE \
      --IsOverwriteVarianceRatioFile=TRUE
    """
  }

process saige_step2_spa {
  tag "chr${chrom}.${phenoFile.baseName}"
  publishDir "${params.outdir}/SAIGE_gwas_2_spa_tests/${phenoFile.baseName}_saige_step2", mode: 'copy'

  input:
  val(bgen_filebase)
  val(bgen_path)
  each chrom
  path(rda)
  path(varianceRatio)
  path(sampleFile)
  val vcfField
  val minMAC
  val minMAF
  each path(phenoFile)

  output:
  path "*"
  path("${phenoFile.baseName}.chr${chrom}.SAIGE.gwas.txt"), emit: assoc_res

  script:
  """
  step2_SPAtests.R \
    --bgenFile=${bgen_path}/${bgen_filebase}.chr${chrom}.bgen \
    --bgenFileIndex=${bgen_path}/${bgen_filebase}.chr${chrom}.bgen.bgi \
    --chrom=${chrom} \
    --minMAC=${minMAC} \
    --minMAF=${minMAF} \
    --sampleFile=${sampleFile} \
    --GMMATmodelFile=${rda} \
    --varianceRatioFile=${varianceRatio} \
    --SAIGEOutputFile=${phenoFile.baseName}.chr${chrom}.SAIGE.gwas.txt \
    --numLinesOutput=2 \
    --IsOutputAFinCaseCtrl=TRUE \
    --IsDropMissingDosages=FALSE \
    --IsOutputNinCaseCtrl=TRUE \
    --IsOutputHetHomCountsinCaseCtrl=TRUE \
    --LOCO=FALSE
  """
}

process merge_chr_files {
  tag "merge_assoc_files"
  publishDir "${params.outdir}/merged_SAIGE_results/", mode: 'copy'

  input:
  each assoc_res

  output:
  set file("*top_n.csv"), file("*${params.output_tag}.csv")

  script:

  """
  # creates 2 .csv files, saige_results_<params.output_tag>.csv, saige_results_top_n.csv
  concat_chroms.R \
    --saige_output_name='saige_results' \
    --filename_pattern='${params.saige_filename_pattern}' \
    --output_tag='${params.output_tag}' \
    --top_n_sites=${params.top_n_sites} \
    --max_top_n_sites=${params.max_top_n_sites}
  """
}