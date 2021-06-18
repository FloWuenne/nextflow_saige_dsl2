# ## Test the nextflow workflow
nextflow run main.nf -resume \
-with-report "../nextflow_reports/test_report.html" \
-with-timeline "../nextflow_reports/test_timeline.html" \
--grm_plink_input "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input/nfam_100_nindep_0_step1_includeMoreRareVariants_poly.{bed,bim,fam}" \
--phenoFile "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input/pheno*.txt" \
--phenoCol "y_binary" \
--covarColList "x1,x2" \
--bgen_filebase "genotype_100markers" \
--bgen_path "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input" \
--sampleFile "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input/samplefile_test_input.txt" \
--outdir "../saige_test_out"


## With relative file paths
# ## Test the nextflow workflow
# nextflow run main.nf -resume \
# -with-report "../nextflow_reports/test_report.html" \
# -with-timeline "../nextflow_reports/test_timeline.html" \
# --grm_plink_input "./test_data/input/nfam_100_nindep_0_step1_includeMoreRareVariants_poly.{bed,bim,fam}" \
# --phenoFile "./test_data/input/pheno*.txt" \
# --phenoCol "y_binary" \
# --covarColList "x1,x2" \
# --bgen_filebase "genotype_100markers" \
# --bgen_path "./test_data/input" \
# --sampleFile "./test_data/input/samplefile_test_input.txt" \
# --outdir "../saige_test_out"