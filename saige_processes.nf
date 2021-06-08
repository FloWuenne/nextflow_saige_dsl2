process saige_step1_bin {
    tag "$plink_grm_snps"
    publishDir "${params.outdir}/gwas_1_fit_null_glmm", mode: 'copy'

    input:
    set val(plink_grm_snps), file(bed), file(bim), file(fam)
    each file(phenoFile)

    output:
    path 'saige_step1'
    file "*"
    file ("step1_${phenoFile.baseName}_out.rda")
    file ("step1_${phenoFile.baseName}.varianceRatio.txt")

    script:
    """
    step1_fitNULLGLMM.R \
      --plinkFile=${params.plink_grm_snps} \
      --phenoFile="${phenoFile}" \
      --phenoCol=y_binary \
      --covarColList=x1,x2 \
      --sampleIDColinphenoFile=IID \
      --traitType=binary \
      --outputPrefix="step1_${phenoFile.baseName}_out" \
      --outputPrefix_varRatio="step1_${phenoFile.baseName}" \
      --nThreads=${task.cpus} ${params.saige_step1_extra_flags} \
      --LOCO=FALSE \
      --IsOverwriteVarianceRatioFile=TRUE
    """
  }