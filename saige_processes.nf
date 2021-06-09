process saige_step1_bin {
    tag "$grm_plink_input"
    publishDir "${params.outdir}/gwas_1_fit_null_glmm", mode: 'copy'

    input:
    tuple val(grm_plink_input), file(bed), file(bim), file(fam)
    each file(phenoFile)
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
  tag "$name"
  publishDir "${params.outdir}/gwas_2_spa_tests", mode: 'copy'

  input:
  tuple val(name), val(chr), file(vcf), file(index)
  file rda
  file varianceRatio
  file sampleFile
  val vcfField
  val minMAC
  val minMAF

  output:
  file("*.SAIGE.gwas.txt")

  script:
  """
  step2_SPAtests.R \
    --bgenFile=${vcf} \
    --vcfFileIndex=${index} \
    --bgenFileIndex=${vcfField} \
    --chrom=${chr} \
    --minMAC=${minMAC} \
    --minMAF=${minMAF} \
    --sampleFile=${sampleFile} \
    --GMMATmodelFile=${rda} \
    --varianceRatioFile=${varianceRatio} \
    --SAIGEOutputFile="step2_SPAtests.${name}.SAIGE.gwas.txt" \
    --numLinesOutput=2 \
    --IsOutputAFinCaseCtrl=TRUE \
    --IsDropMissingDosages=FALSE \
    --IsOutputNinCaseCtrl=TRUE \
    --IsOutputHetHomCountsinCaseCtrl=TRUE \
    --LOCO=FALSE
  """
}