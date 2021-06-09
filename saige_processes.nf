process saige_step1_bin {
    tag "$grm_plink_input"
    publishDir "${params.outdir}/gwas_1_fit_null_glmm", mode: 'copy'

    input:
    tuple val(grm_plink_input), file(bed), file(bim), file(fam)
    each file(phenoFile)

    output:
    file "*"
    file ("step1_${phenoFile.baseName}_out.rda")
    file ("step1_${phenoFile.baseName}.varianceRatio.txt")

    script:
    """
    step1_fitNULLGLMM.R \
      --plinkFile=${grm_plink_input} \
      --phenoFile="${phenoFile}" \
      --phenoCol=y_binary \
      --covarColList=x1,x2 \
      --sampleIDColinphenoFile=IID \
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
  set val(name), val(chr), file(vcf), file(index) from filteredVcfsCh
  each file(rda) from rdaCh
  each file(varianceRatio) from varianceRatioCh

  output:
  file "*" into results
  file("*.SAIGE.gwas.txt") into ch_saige_output

  script:
  """
  step2_SPAtests.R \
    --vcfFile=${vcf} \
    --vcfFileIndex=${index} \
    --vcfField=GT \
    --chrom=${chr} \
    --minMAC=20 \
    --sampleFile=day0_covid.samples \
    --GMMATmodelFile=${rda} \
    --varianceRatioFile=${varianceRatio} \
    --SAIGEOutputFile="step2_SPAtests.${name}.SAIGE.gwas.txt" \
    --numLinesOutput=2 \
    --IsOutputAFinCaseCtrl=TRUE \
    --IsDropMissingDosages=FALSE \
    --IsOutputNinCaseCtrl=TRUE \
    --IsOutputHetHomCountsinCaseCtrl=TRUE
  """
}