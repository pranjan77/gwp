use strict;
use Getopt::Long;
use JSON;
use Data::Dumper;
use Bio::KBase::AuthToken;
use Bio::KBase::workspace::Client;

my $to = Bio::KBase::AuthToken->new();
our $token = $to->{token};
 my $workspaceURL = "https://kbase.us/services/ws";

my $ws = Bio::KBase::workspace::Client->new($workspaceURL, token=>$token );

my $file = $ARGV[0];
my $type = $ARGV[1];
my $workspace = $ARGV[2];
my $obj_name = $ARGV[3];

open (FILE, $file) or die ("can not open '$file' for reading.");
my $data = join ("", <FILE>);
my $hash = from_json($data);

my $metadata = $ws->save_object({id =>$obj_name, type => $type, auth => $token,  data => $hash, workspace => $workspace});
