process saige_step1_bin {
    tag "${phenoFile.baseName}"
    publishDir "${params.outdir}/${phenoFile.baseName}/SAIGE_out_step1", mode: 'copy'
    clusterOptions "--account=def-glettre"

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
      --IsOverwriteVarianceRatioFile=TRUE 
    """
  }

process saige_step2_spa {
  tag "chr${chrom}.${phenotype}"
  publishDir "${params.outdir}/${phenotype}/SAIGE_out_step2", mode: 'copy'

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
  tuple val(phenotype), path("${phenotype}.chr${chrom}.SAIGE.gwas.txt"), emit: assoc_res

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

process prepare_files {
  tag "merging_chromosomes.${phenotype}"
  publishDir "${params.outdir}/${phenotype}", mode: 'copy'

  input:
  tuple val(phenotype), path(merged_assoc)

  output:
  tuple val(phenotype), path("saige_results_${phenotype}_top_n.csv"), emit: top_hits
  tuple val(phenotype), path("saige_results_${phenotype}.csv"), emit: merged_out
  

  script:
  """
  # creates 2 .csv files, saige_results_<params.output_tag>.csv, saige_results_top_n.csv
  concat_chroms.R \
    --saige_output_name='saige_results' \
    --filename_pattern='${phenotype}.*' \
    --output_tag='${phenotype}' \
    --top_n_sites=${params.top_n_sites} \
    --max_top_n_sites=${params.max_top_n_sites}
    mv saige_results_top_n.csv saige_results_${phenotype}_top_n.csv
  """
}

process create_plots {
tag "plotting.${phenotype}"
publishDir "${params.outdir}/${phenotype}/final", mode: 'copy'

input:
tuple val(phenotype), path(saige_res), path(top_hits), path(ch_gwas_cat)

output:
tuple file("*png"), file("*csv")

script:
"""
cp /opt/bin/* .
rm logo.png
rm covid_1_manhattan.png
# creates gwascat_subset.csv
subset_gwascat.R \
  --saige_output='saige_results_${phenotype}.csv' \
  --gwas_cat='${ch_gwas_cat}'
# creates <params.output_tag>_manhattan.png with analysis.csv as input
manhattan.R \
  --saige_output='saige_results_${phenotype}.csv' \
  --output_tag='${phenotype}'
# creates <params.output_tag>_qqplot_ci.png with analysis.csv as input
qqplot.R \
  --saige_output='saige_results_${phenotype}.csv' \
  --output_tag='${phenotype}'
  mv gwascat_subset.csv gwascat_subset_${phenotype}.csv
"""
}
