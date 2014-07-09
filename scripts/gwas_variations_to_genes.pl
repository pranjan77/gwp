#!/usr/bin/env perl

# this script takes gwas population metadata json file and data text file as input
# and creates a GwasPopulation type workspace object

use strict;
#use warnings;
#no warnings('once');
use POSIX;
use JSON;
use Bio::KBase::workspace::Client;
use Data::Dumper;
use Bio::KBase::AuthToken;
use Getopt::Long;
use Data::Dumper;
use Bio::KBase::CDMI::CDMIClient;
use Bio::KBase::Utilities::ScriptThing;
#TODO: Confirm if this is the right url
my $cdmie = Bio::KBase::CDMI::Client->new("http://bio-data-1.mcs.anl.gov/services/cdmi_api");


my $ws_url                   = $ARGV[0];
my $wsid                     = $ARGV[1];
my $varinid                  = $ARGV[2];
my $outid                    = $ARGV[3];
my $numtopsnps               = $ARGV[4];
my $pmin                     = $ARGV[5];
my $distance                 = $ARGV[6];
my $comment                  = $ARGV[7];
#my $token                    = $ENV{KB_AUTH_TOKEN};


#TODO: Fix the token
my $to = Bio::KBase::AuthToken->new();
our $token = $to->{token};


my $wc = Bio::KBase::workspace::Client->new($ws_url, token => $token);

#Get Topvariation data
my $hash_gwas = $wc->get_object({id => $varinid, type => 'KBaseGwasData.GwasTopVariations', workspace => $wsid});

my $contigs = $hash_gwas->{'data'}{'contigs'};
my $index=0;
my %hash_contigs;
foreach my $contig(@$contigs)
{
  my $kbid = $contig->{"kbase_contig_id"};
  $hash_contigs{$index}=$kbid;
  $index++;
}


my $chromosomal_positions;
my $variations = $hash_gwas->{'data'}{'variations'};

my @results;
my @results2;

my $count=0;

foreach my $snp_array(@$variations)
{
  $count++;
  last if ($count > $numtopsnps);
  my($index, $position, $pvalue, $rank) = @$snp_array;
  my $kb_contig_id = $hash_contigs{$index};
  my @array_position = ($kb_contig_id,$position, $pvalue);
  push(@$chromosomal_positions,\@array_position) if($pvalue > $pmin);
}

my %uniquegenes;
my %hash_snp2gene;
my $cdmConnection = Bio::KBase::CDMI::CDMIClient->new_for_script();
my %hash_seen;

my $cdmi1 = Bio::KBase::CDMI::CDMI->new( "dbhost" => "db1.chicago.kbase.us", "dbName" => "kbase_sapling_v1", "userData" => "kbase_sapselect/oiwn22&dmwWEe", "DBD" => "/kb/deployment/lib/KSaplingDBD.xml");
foreach my $positions (@$chromosomal_positions) {
  my ($kb_chromosome, $position, $pvalx)  = (@$positions[0], @$positions[1], @$positions[2]);
#       $genelist_obj_id = $genelist_obj_id."kbchr:".$kb_chromosome."pos:".$position.";";



  my @res=$cdmi1->GetAll("Feature IsLocatedIn Contig",
      'Contig(id)=? AND (abs(IsLocatedIn(begin) - ?) <=?) AND IsLocatedIn(from_link) LIKE ?',
      [$kb_chromosome,$position,$distance,'%locus%'],
      [qw(Contig(id) Feature(source_id) Feature(id) Feature(function) Contig(source_id)   ) ]);



  my @snp_gene;

  foreach my $generef(@res)
  {
    my($cid, $sid, $fid, $func, $source_id) = @$generef;
    my $pvalue_1 =int ($pvalx);
    my @mq = ($cid,$sid, $fid, $position ,$func, $pvalue_1, $source_id, 0, 0);
    push(@results, \@mq);
    next if($hash_seen{$sid});
    push(@results2, $generef);
    $hash_seen{$sid}=1;
  }

}
my %hash;
$hash{"GwasTopVariations_obj_id"}=$wsid . "/" . $varinid;
$hash{"pvaluecutoff"}=int ($pmin);
$hash{"genes_snp_list"}=\@results;
my $distance1 = int ($distance);
$hash{"distance_cutoff"}=$distance1;

$hash{"genes"}=\@results2;
my $metadata = $wc->save_object({workspace => $wsid,
    id => $outid,
    type => "KBaseGwasData.GwasGeneList",
    data => \%hash});

