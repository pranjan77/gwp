use strict;
use Getopt::Long;
use JSON;
use Bio::KBase::workspace::Client;
use Data::Dumper;
use Scalar::Util qw(looks_like_number);



my $to = Bio::KBase::AuthToken->new();
our $token = $to->{token};
our $shock_url ="https://kbase.us/services/shock-api";

my $id = upload2shock ('/homes/knoxville/pranjan77/github/gwp_data/arabidopsis256ksnp.vcf'); 

print $id;

sub upload2shock {
  my $fn = shift;
  our $token;
  our $shock_url;

  my $cmd = "curl -s -H \"Authorization: OAuth $token\" -X POST -F upload=\@$fn $shock_url/node";
  my $out_shock_meta = from_json(`$cmd`);
  return $out_shock_meta->{data}->{id};

}

