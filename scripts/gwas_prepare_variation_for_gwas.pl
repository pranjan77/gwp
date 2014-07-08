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


use Getopt::Long;
use Data::Dumper;
use Scalar::Util qw(looks_like_number);

umask 000;


if(@ARGV != 6) {
  print_usage();
  exit __LINE__;
}

my $ws_url                   = $ARGV[0];
my $wsid                     = $ARGV[1];
my $shock_url                = $ARGV[2];
my $inid                     = $ARGV[3];
my $outid                    = $ARGV[4];
my $minor_allele_frequency   = $ARGV[5];

#my $token                    = $ENV{KB_AUTH_TOKEN};
my $to = Bio::KBase::AuthToken->new();
our $token = $to->{token};


my $output_file = "tmp.vcf";

#Minor allele frequency should be a number with value between 0 and 1
if (! (looks_like_number ($minor_allele_frequency) 
                        && $minor_allele_frequency >=0
                                && $minor_allele_frequency <=1 )){
 die "Minor allele frequency should be between 0 and 1. Minor allele frequency $minor_allele_frequency is not in range\n";
}


my $wc = Bio::KBase::workspace::Client->new($ws_url, token => $token);
my $obj = $wc->get_object({id => $inid, type => 'KBaseGwasData.GwasPopulationVariation', workspace => $wsid});

#$shock_url = $obj->{data}->{files}->{shock_url};
my $nodeid = $obj->{data}->{files}->{vcf_shock_id};
my $maf_ws = $obj->{data}->{minor_allele_frequency};

my $cmd = "curl -s -H \"Authorization: OAuth $token\" -X GET $shock_url/node/$nodeid"; 
my $out_shock_meta = from_json(`$cmd`);
my $fn = $out_shock_meta->{data}->{file}->{name};

my $vcftools = "vcftools";

# streaming 
$cmd = "curl -s -H \"Authorization: OAuth $token\" -X GET $shock_url/node/$nodeid?download ";
$cmd .= " | gunzip -c - " if ($fn =~ m/gz$/);
$cmd .= " | $vcftools --vcf - --maf $minor_allele_frequency   --max-alleles 2 --recode --stdout >  $output_file;";
`$cmd`;

$obj->{data}->{files}->{vcf_shock_id} = upload2shock($output_file);
$obj->{data}->{minor_allele_frequency} = $minor_allele_frequency;

$cmd = "cat $output_file |gwas_vcf_to_hapmap_emma.pl";
`$cmd`;
$obj->{data}->{files}->{emmax_format_hapmap_shock_id} = upload2shock("out.tped");


$wc->save_objects({workspace => $wsid, objects => [{type=>'KBaseGwasData.GwasPopulationVariation',
                                                    name=>$outid,
                                                    data=>$obj->{data},
                                                    meta=>{source=>"$wsid:$inid by GWAS.filter_vcf"}}]});


system ("rm -f tmp.vcf");
system ("rm -f out.tped");

exit(0);


sub upload2shock {
  my $fn = shift;

  my $cmd = "curl -s -H \"Authorization: OAuth $token\" -X POST -F upload=\@$fn $shock_url/node";
  my $out_shock_meta = from_json(`$cmd`);
  return $out_shock_meta->{data}->{id};

}



sub print_usage {
  &return_error("USAGE: gwas_validate_population.pl ws_url ws_id metadata data");
}

sub return_error {
  my ($str) = @_;
  print STDERR "$str\n";
  exit(1);
}





