module GWAS
{

  /* All methods are authenticated. 
    authentication required;
*/

/* gwas_prepare_variation_for_gwas_async prepares variation data in proper format and allows option for minor allele frequecy based filtering*/

funcdef gwas_prepare_variation_for_gwas_async (string ws_url , string wsid  , string shock_url , string inid  , string outid  , string minor_allele_frequency  , string comment); 


/*gwas_calculate_kinship_matrix_emma_async calculates kinship matrix from variation data */
funcdef gwas_calculate_kinship_matrix_emma_async ( string ws_url, string wsid, string shock_url,string inid, string outid , string comment);


/*gwas_run_gwas_emma_async Runs genome wide association analysis and takes kinship, variation and trait file as input*/

funcdef gwas_run_gwas_emma_async (string ws_url , string wsid , string shock_url , string varinid  , string traitinid , string kinshipinid , string outid, string comment);


/*gwas_variations_to_genes gets genes close to the SNPs */

funcdef gwas_variations_to_genes (string ws_url , string wsid , string varinid , string outid  ,string numtopsnps, string pmin , string distance , string comment);               



};
