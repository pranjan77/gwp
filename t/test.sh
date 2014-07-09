scriptdir=~/github/gwp/scripts
ws_url=https://kbase.us/services/ws
ws_id=pranjan77:gwas_test
data_dir=sample_data
shock_url=https://kbase.us/services/shock-api

#Upload Population object
perl $scriptdir/gwas_upload_population_data.pl $ws_url $ws_id $data_dir/population_metadata.txt $data_dir/population_data.txt Athalianapopulation1 local


#Upload variation object
perl $scriptdir/gwas_create_population_variation.pl $ws_url $ws_id atpopvar1 $data_dir/variation_metadata.txt  $data_dir/test.vcf $shock_url NA local

#Upload trait object
perl $scriptdir/gwas_create_traits.pl https://kbase.us/services/ws $ws_id $data_dir/trait_metadata.txt $data_dir/trait_data.txt local

#Prepare data for GWAS including minor allele frequency filtration
perl $scriptdir/gwas_prepare_variation_for_gwas.pl $ws_url $ws_id $shock_url atpopvar1  atpopvar1.filtered 0.05 'test'

#Calculate kinship matrix
perl $scriptdir/gwas_calculate_kinship_matrix_emma.pl $ws_url $ws_id $shock_url atpopvar1.filtered  atpopvar1.filtered.kinship  'test'

#Run Gwas analysis
perl $scriptdir/gwas_run_gwas_emma.pl $ws_url $ws_id $shock_url atpopvar1.filtered FLC atpopvar1.filtered.kinship  FLC.topvariations 'test'

#Get genes for snps
perl $scriptdir/gwas_variations_to_genes.pl $ws_url $ws_id FLC.topvariations FLC.genelist  100  3  1000 'test'


