#!/usr/bin/env perl

# this script takes gwas population metadata json file and data text file as input
# and creates a GwasPopulation type workspace object

use strict;
use warnings;
no warnings('once');
use POSIX;
use JSON;

use Bio::KBase::workspace::Client;
use Data::Dumper;
use  Bio::KBase::AuthToken;

use Bio::KBase::CDMI::CDMIClient;
use Bio::KBase::Utilities::ScriptThing;
my $cdmie = Bio::KBase::CDMI::Client->new("http://bio-data-1.mcs.anl.gov/services/cdmi_api");



umask 000;

if(@ARGV != 6) {
  print_usage();
  exit __LINE__;
}

my $ws_url                   = $ARGV[0];
my $ws1                      = $ARGV[1];
my $metadata_json_file       = $ARGV[2];
my $uploaded_variation_file  = $ARGV[3];
my $s_url                    = $ARGV[4];
my $s_id                     = $ARGV[5];
my $token                    = $ENV{KB_AUTH_TOKEN};


my $wsc = Bio::KBase::workspace::Client->new($ws_url, token=>$token );

open (FILE, $metadata_json_file) || &return_error("Could not open file '$metadata_json_file' for reading. ");
my $metadata_json = join ("", <FILE>);
close (FILE);

my $hash_metadata = from_json($metadata_json);
$hash_metadata = $hash_metadata->{'BasicPopulationVariationInfo'};

my $population_obj=$hash_metadata->{'GwasPopulation_obj_id'};

my $type = "KBaseGwasData.GwasPopulation";
my $object_data = $wsc->get_object({id => $population_obj,
    type => $type,
    workspace => $ws1,
    auth => $token});

my $ecotype_details  = $object_data->{'data'}{'observation_unit_details'};
my $genome  = $object_data->{'data'}{'genome'};
my %hash_germplasms = ();

foreach my $ecotype (@$ecotype_details){
  my $germplasm = $ecotype->{'source_id'};
  $hash_germplasms{$germplasm}++;
}


##TODO: write validator code. Read first few lines of vcf file and check
#Support both .vcf and .vcf.gz
#Check if vcftools gives an error

my $obs_units_string = `head -100 $uploaded_variation_file|grep ^#CHROM`;
chomp ($obs_units_string);
my @obs_units1 = split ("\t", $obs_units_string);

my $length=@obs_units1;
@obs_units1 = @obs_units1[9..$length-1];

my @obs_units = ();
foreach my $line (@obs_units1){
 my @data = ($line, 'kb|..');
 push (@obs_units, \@data);
}


my $ws_doc;

my $population_obj_ref = $ws1 . "/" .$hash_metadata->{'GwasPopulation_obj_id'}; 
$ws_doc->{'GwasPopulation_obj_id'}= $population_obj_ref;
#$ws_doc->{'GwasPopulation_obj_id'}= $hash_metadata->{'GwasPopulation_obj_id'};
$ws_doc->{'assay'}= $hash_metadata->{'assay'};
$ws_doc->{'originator'}= $hash_metadata->{'originator'};
$ws_doc->{'genome'}= $genome;
#$ws_doc->{'parent_variation_obj_id'}= "NA";
$ws_doc->{'minor_allele_frequency'}= "NA";
$ws_doc->{'obs_units'}= \@obs_units;


my %files = ();
$files{'shock_url'}=$s_url;
$files{'vcf_shock_id'}=$s_id;
$files{'emmax_format_hapmap_shock_id'}="";
$files{'tassel_format_hapmap_shock_id'}="";


$ws_doc->{'files'}= \%files;

my $comment = $hash_metadata->{'comment'}; 
$comment = "NA" if (!$comment);
$ws_doc->{'comment'}= $comment;
$ws_doc->{"pubmed_id"}=$hash_metadata->{'pubmed_id'}; ;


my $outid = $hash_metadata->{'variation_output_name'}; 

#open OUT, ">document.json" || &return_error("Cannot open document.json for writing");
#print OUT to_json($ws_doc, { ascii => 1, pretty => 1 });
#close OUT;

my $metadata = $wsc->save_object({id =>"$outid", type =>"KBaseGwasData.GwasPopulationVariation" , auth => $token,  data => $ws_doc, workspace => $ws1});
#print to_json($ws_doc);


exit(0);

sub print_usage {
  &return_error("USAGE: gwas_validate_population.pl ws_url ws_id metadata data");
}

sub return_error {
  my ($str) = @_;
  print STDERR "$str\n";
  exit(1);
}



