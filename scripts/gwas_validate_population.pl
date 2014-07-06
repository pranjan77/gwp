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

if(@ARGV != 4) {
  print_usage();
  exit __LINE__;
}

my $ws_url              = $ARGV[0];
my $ws1                 = $ARGV[1];
my $metadata_json_file  = $ARGV[2];
my $uploaded_population_file = $ARGV[3];
my $token               = $ENV{KB_AUTH_TOKEN};


open (FILE, $metadata_json_file) || &return_error("Could not open file '$metadata_json_file' for reading. ");
my $metadata_json = join ("", <FILE>);
close (FILE);

my $hash_metadata = from_json($metadata_json);
$hash_metadata = $hash_metadata->{'BasicPopulationInfo'};


my $kbase_genome_id = $hash_metadata->{'kbase_genome_id'};

my $gH = $cdmie->get_entity_Genome([$kbase_genome_id], ["id", "scientific_name", "source_id"]);
my %genome_details = (
    "kbase_genome_id" => $gH->{$kbase_genome_id}{"id"},
    "kbase_genome_name" => $gH->{$kbase_genome_id}{"scientific_name"},
    "source_genome_name" => $gH->{$kbase_genome_id}{"source_id"},
    "source" => "KBase central store"
    );




my $ws_doc;
$ws_doc->{"genome"}=\%genome_details;
$ws_doc->{"GwasPopulation_description"}=$hash_metadata->{'GwasPopulation_description'};
$ws_doc->{"originator"}=$hash_metadata->{'originator'}; 
$ws_doc->{"pubmed"}=$hash_metadata->{'pubmed'}; ;
$ws_doc->{"comments"}=$hash_metadata->{'comments'}; 


open (FILE2, $uploaded_population_file) || &return_error ("Could not open file '$uploaded_population_file' for reading. ");
my @data = <FILE2>;
shift @data;


my @obs_unit_details = ();

foreach my $line (@data){
  $line=~s/\s*$//;
  my ($obs_unit_source_id, $latitude,$longitude, $nativename, $region, $country, $comment) = split ("\t", $line);
  my %obs_unit = ();
  
  my $kbase_id = "test-kb|...."; #TODO:Get this value from a hash and fill it properly later
  $obs_unit{'source_id'}=$obs_unit_source_id;
  $obs_unit{'latitude'}=$latitude;
  $obs_unit{'longitude'}=$longitude;
  $obs_unit{'nativenames'}=$nativename;
  $obs_unit{'region'}=$region;
  $obs_unit{'country'}=$country;
  $obs_unit{'comment'}=$comment;
  $obs_unit{'kbase_id'}=$kbase_id;
  push (@obs_unit_details, \%obs_unit);
}


$ws_doc->{"observation_unit_details"}=\@obs_unit_details ;


open OUT, ">document.json" || &return_error("Cannot open document.json for writing");
print OUT to_json($ws_doc, { ascii => 1, pretty => 1 });
close OUT;

exit(0);

sub print_usage {
  &return_error("USAGE: gwas_validate_population.pl ws_url ws_id metadata data");
}

sub return_error {
  my ($str) = @_;
  print STDERR "$str\n";
  exit(1);
}



