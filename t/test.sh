
#Upload Population object
#perl ../../scripts/gwas_create_population.pl ws_url ws_id population.json population_data.txt 
#perl upload_object.pl document.json KBaseGwasData.GwasPopulation pranjan77:testgw arapop1
#ws-get arapop1 -w pranjan77:testgw -p >test.json


#Upload trait object
#perl phenotype/preparemetadata.pl phenotype/phenotypemetadata.txt  |python -m json.tool >phenotype/phenotype-metadata.json

#perl ../../scripts/gwas_create_traits.pl https://kbase.us/services/ws pranjan77:testgw phenotype/phenotype-metadata.json phenotype/phenotypedata.txt

#perl ../../scripts/gwas_create_population_variation.pl https://kbase.us/services/ws pranjan77:testgw variation/variation-metadata.json ~/github/gwp_data/arabidopsis256ksnp.vcf https://kbase.us/services/shock-api f321ad26-a76a-4ae2-89fe-cbd0e07dde8e

#perl ../../scripts/gwas_prepare_variation_for_gwas.pl https://kbase.us/services/ws pranjan77:testgw https://kbase.us/services/shock-api ara1.var ara1.var.filtered 0.05 'test'


#perl ../../scripts/gwas_calculate_kinship_matrix_emma.pl https://kbase.us/services/ws pranjan77:testgw https://kbase.us/services/shock-api ara1.var.filtered ara1_kinship  'test'
#perl ../../scripts/gwas_run_gwas_emma.pl https://kbase.us/services/ws pranjan77:testgw https://kbase.us/services/shock-api ara1.var.filtered T-FLC ara1_kinship  T-FLC.genelist 'test'


perl ../../scripts/gwas_variations_to_genes.pl https://kbase.us/services/ws pranjan77:testgw T-FLC.genelist T-FLC.gene1  100  3  1000 'test'


