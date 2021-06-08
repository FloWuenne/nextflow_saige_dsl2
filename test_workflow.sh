## Test the nextflow workflow
nextflow run main.nf \
--grm_plink_input "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/input/nfam_100_nindep_0_step1_includeMoreRareVariants_poly.{bed,bim,fam}" \
--phenoFile "/home/florian/Postdoc/Valve_disease_GWAS/nextflow_pipeline/nextflow_saige_dsl2/test_data/pheno_1000samples.txt_withdosages_withBothTraitTypes.txt" \
--outdir "test"