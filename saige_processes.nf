process saige_step1_bin {
    tag "$grm_plink_input"
    publishDir "${params.outdir}/gwas_1_fit_null_glmm", mode: 'copy'

    input:
    tuple val(grm_plink_input), path(bed), path(bim), path(fam)
    path(phenoFile)
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
  tag "$chr"
  publishDir "${params.outdir}/gwas_2_spa_tests", mode: 'copy'

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

  output:
  path "*"
  path("chr${chrom}.SAIGE.gwas.txt"), emit: assoc_res

  script:
  """
  step2_SPAtests.R \
    --bgenFile=$bgen_path/$bgen_filebase".chr"$chrom".bgen" \
    --bgenFileIndex=$bgen_path/$bgen_filebase".chr"$chrom".bgen.bgi" \
    --chrom=${chrom} \
    --minMAC=${minMAC} \
    --minMAF=${minMAF} \
    --sampleFile=${sampleFile} \
    --GMMATmodelFile=${rda} \
    --varianceRatioFile=${varianceRatio} \
    --SAIGEOutputFile="chr${chrom}.SAIGE.gwas.txt" \
    --numLinesOutput=2 \
    --IsOutputAFinCaseCtrl=TRUE \
    --IsDropMissingDosages=FALSE \
    --IsOutputNinCaseCtrl=TRUE \
    --IsOutputHetHomCountsinCaseCtrl=TRUE \
    --LOCO=FALSE
  """
}