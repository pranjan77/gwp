#trait name  protocol  Trait ontology  gwaspopulation object id  originator  pubmed id  unit of measurement

use strict;
use JSON;

my $metadata_file = $ARGV[0];
open (FILE, $ARGV[0]) or die ("Could not file '$metadata_file' for reading. ");

my @file = <FILE>;

shift @file; #skip header line

my %hash_meta = ();
my @trait_metadata = ();

foreach my $line (@file){
  chomp($line);
  my ($trait_name, $protocol, $trait_ontology_id, $gwaspopulation_object_id, $originator, $pubmed_id, $unit_of_measurement) = split ("\t", $line);  
  my %trait_meta = ();
  $trait_meta{'trait_name'}=$trait_name;
  $trait_meta{'protocol'}=$protocol;
  $trait_meta{'trait_ontology_id'}=$trait_ontology_id;
  $trait_meta{'GwasPopulation_obj_id'}=$gwaspopulation_object_id;
  $trait_meta{'originator'}=$originator;
  $trait_meta{'pubmed_id'}=$pubmed_id;
  $trait_meta{'unit_of_measure'}=$unit_of_measurement;

  push (@trait_metadata, \%trait_meta);
}

$hash_meta{"BasicTraitInfo"}=\@trait_metadata;
print to_json (\%hash_meta);
