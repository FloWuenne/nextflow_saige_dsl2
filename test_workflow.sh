## Test the nextflow workflow
nextflow run main.nf \
-with-report "./test_report.html" \
-with-timeline "./test_timeline.html" \
-with-singularity "/home/florian/Postdoc/Valve_disease_GWAS/Programs/saige_0.43.2.sif" \
--grm_plink_input "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input/nfam_100_nindep_0_step1_includeMoreRareVariants_poly.{bed,bim,fam}" \
--phenoFile "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input/pheno_1000samples.txt_withdosages_withBothTraitTypes.txt" \
--phenoCol "y_binary" \
--covarColList "x1,x2" \
--bgen_list "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input/test_bgen_list.csv" \
--sampleFile "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input/samplefileforbgen_10000samples.txt" \
--varianceRatio "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/saige_test_out/nf_workflow/gwas_1_fit_null_glmm/step1_pheno_1000samples.txt_withdosages_withBothTraitTypes.varianceRatio.txt" \
--rda "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/saige_test_out/nf_workflow/gwas_1_fit_null_glmm/step1_pheno_1000samples.txt_withdosages_withBothTraitTypes_out.rda" \
--outdir "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/saige_test_out/nf_workflow"