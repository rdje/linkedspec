use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
my ($owner,$observer,$fixture,$output)=@ARGV;
die 'owned original overlay and observer required' unless @ARGV == 4
 && $owner eq 'docs/checkpoints/array-concat-open-arity-perl-2026-11-12/signature_oracle/MethodLowering.pm'
 && $observer eq 'docs/checkpoints/array-concat-open-arity-perl-2026-11-12/signature_oracle_observer.pl';
require "./$owner";
$INC{'LinkedSpec/ActionIR/MethodLowering.pm'}=$owner;
require LinkedSpec;
open my $fh,'<:raw',$owner or die $!;
my $body=do{local $/;<$fh>};close $fh or die $!;
print STDERR 'SIGNATURE_ORACLE_OWNER '.JSON::PP->new->canonical->encode({path=>$owner,bytes=>length($body),sha256=>sha256_hex($body)})."\n";
@ARGV=($fixture,$output);
do "./$observer";
die $@ if $@;
die 'original owner replaced' unless $INC{'LinkedSpec/ActionIR/MethodLowering.pm'} eq $owner;
