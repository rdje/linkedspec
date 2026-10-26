use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
sub read_fixture { my ($path)=@_;open my $fh,'<',$path or die "$path: $!";local $/;return <$fh> }
my $source=read_fixture('tests/fixtures/definedness_result_receiver_values.spec');
my $json=JSON::PP->new->canonical;
my $expected=$json->decode(read_fixture('tests/fixtures/definedness_result_receiver_values.perl.json'));
my %context;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);my $input='x';my $actual=eval {$parser->(\$input)};
is("$@",'','native definedness result execution has no thrown error');
is($context{last_error},undef,'native definedness results have no handler error') or diag($json->encode($context{last_error}));
is($json->encode($actual),$json->encode($expected),'native definedness results, scalar boundaries, shape and snapshots');
my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'definedness-result-receivers.spec');
my $loaded=eval "package LinkedSpec::DefinednessResultReceiverGenerated; $emitted; 1";
ok($loaded,'fresh definedness-result parser compiles') or diag($@);
if($loaded){my $fresh_input='x';my $fresh=eval {LinkedSpec::DefinednessResultReceiverGenerated::Execute(\$fresh_input)};
 is("$@",'','fresh definedness-result execution has no thrown error');
 is($json->encode($fresh),$json->encode($expected),'fresh definedness results, scalar boundaries, shape and snapshots');}
done_testing() unless caller;
1;
