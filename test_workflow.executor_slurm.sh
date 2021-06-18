# ## Test the nextflow workflow
work_dir="$PWD"
nextflow run main.nf -profile cluster_slurm -resume \
-with-report "../nextflow_reports/test_report.html" \
-with-timeline "../nextflow_reports/test_timeline.html" \
--grm_plink_input "$work_dir/test_data/input/nfam_100_nindep_0_step1_includeMoreRareVariants_poly.{bed,bim,fam}" \
--phenoFile "$work_dir/test_data/input/pheno*.txt" \
--phenoCol "y_binary" \
--covarColList "x1,x2" \
--bgen_filebase "genotype_100markers" \
--bgen_path "$work_dir/test_data/input" \
--sampleFile "$work_dir/test_data/input/samplefile_test_input.txt" \
--outdir "../saige_test_out"


## With relative file paths
## Test the nextflow workflow
# nextflow run main.nf -resume \
# -with-report "../nextflow_reports/test_report.html" \
# -with-timeline "../nextflow_reports/test_timeline.html" \
# --grm_plink_input "test_data/input/nfam_100_nindep_0_step1_includeMoreRareVariants_poly.{bed,bim,fam}" \
# --phenoFile "test_data/input/pheno*.txt" \
# --phenoCol "y_binary" \
# --covarColList "x1,x2" \
# --bgen_filebase "genotype_100markers" \
# --bgen_path "test_data/input" \
# --sampleFile "test_data/input/samplefile_test_input.txt" \
# --outdir "../saige_test_out"