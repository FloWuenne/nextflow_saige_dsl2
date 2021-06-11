process saige_step1_bin {
    tag "$phenoFile"
    publishDir "${params.outdir}/SAIGE_gwas_1_fit_null_glmm", mode: 'copy'

    input:
    tuple val(grm_plink_input), path(bed), path(bim), path(fam)
    each path(phenoFile)
    val phenoCol
    val covarColList
    val sampleIDcol

    output:
    val(phenoFile.baseName), emit: phenotype
    tuple val(phenoFile.baseName), path("step1_${phenoFile.baseName}_out.rda"), path("step1_${phenoFile.baseName}.varianceRatio.txt"), emit: step1_out

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
  tag "chr${chrom}.${phenotype}"
  publishDir "${params.outdir}/SAIGE_gwas_2_spa_tests/${phenotype}_saige_step2", mode: 'copy'

  input:
  tuple val(phenotype), val(rda), val(varRatio)
  each chrom
  val(bgen_filebase)
  val(bgen_path)
  path(sampleFile)
  val vcfField
  val minMAC
  val minMAF

  output:
  path("${phenotype}.chr${chrom}.SAIGE.gwas.txt", emit: assoc_res)
  val(phenotype), emit: phenotype

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
        --varianceRatioFile=${varRatio} \
        --SAIGEOutputFile=${phenotype}.chr${chrom}.SAIGE.gwas.txt \
        --numLinesOutput=2 \
        --IsOutputAFinCaseCtrl=TRUE \
        --IsDropMissingDosages=FALSE \
        --IsOutputNinCaseCtrl=TRUE \
        --IsOutputHetHomCountsinCaseCtrl=TRUE \
        --LOCO=FALSE
  """
}

process merge_chr_files {
  tag "${phenotype}"
  publishDir "${params.outdir}/SAIGE_gwas_2_spa_tests/", mode: 'copy'

  input:
  path(assoc_res)
  val(phenotype)

  output:
  set file("*top_n.csv"), file("*${params.output_tag}.csv")

  script:

  """
for assocFile in ${assoc_res}
    do
        cat \$assocFile >> concatenatedBootstrapTrees.nwk
    done
  """
}