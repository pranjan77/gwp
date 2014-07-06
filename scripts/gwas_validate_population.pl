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

my $wsc = Bio::KBase::workspace::Client->new($ws_url);

open (FILE, $metadata_json_file) || &return_error("Could not open file '$metadata_json_file' for reading. ");
my $metadata_json = join ("", <FILE>);
close (FILE);

my $hash_metadata = from_json($metadata_json);
$hash_metadata = $hash_metadata->{'BasicPopulationInfo'};



