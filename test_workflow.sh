## Test the nextflow workflow
nextflow run main.nf \
-with-report "./test_report.html" \
-with-timeline "./test_timeline.html" \
-with-singularity "/home/florian/Postdoc/Valve_disease_GWAS/Programs/saige_0.43.2.sif" \
--grm_plink_input "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input/nfam_100_nindep_0_step1_includeMoreRareVariants_poly.{bed,bim,fam}" \
--phenoFile "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input/pheno_1000samples.txt_withdosages_withBothTraitTypes.txt" \
--phenoCol "y_binary" \
--covarColList "x1,x2" \
--bgen_filebase "genotype_100markers" \
--bgen_path "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input" \
--sampleFile "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input/samplefileforbgen_10000samples.txt" \
--outdir "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/saige_test_out/nf_workflow"

#--bgen_files '/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input/genotype_100markers.chr*.bgen' \