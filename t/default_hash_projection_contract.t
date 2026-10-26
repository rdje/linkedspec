use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
sub read_fixture { my ($path)=@_;open my $fh,'<',$path or die "$path: $!";local $/;return <$fh> }
my $json=JSON::PP->new->canonical;
my @cases=([read_fixture('tests/fixtures/default_hash_projection_values.spec'),$json->decode(read_fixture('tests/fixtures/default_hash_projection_values.json'))]);
my $sequence=0;
for my $case (@cases){
 my($source,$expected)=@$case;
 my %context;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);my $input='x';my $actual=eval {$parser->(\$input)};
 is("$@",'','native default Hash projection result execution has no thrown error');
 is($context{last_error},undef,'native default Hash projection results have no handler error') or diag($context{last_error}{summary}//'handler error');
 is($json->encode($actual),$json->encode($expected),'native default Hash projection results, kinds, scalar boundaries and snapshots');
 my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'default-hash-projection.spec');
 my $package='LinkedSpec::DefaultHashProjectionGenerated'.++$sequence;
 my $loaded=eval "package $package; $emitted; 1";
 ok($loaded,'fresh default Hash projection-result parser compiles') or diag($@);
 if($loaded){my $fresh_input='x';no strict 'refs';my $fresh=eval {&{$package.'::Execute'}(\$fresh_input)};
  is("$@",'','fresh default Hash projection-result execution has no thrown error');
  is($json->encode($fresh),$json->encode($expected),'fresh default Hash projection results, kinds, scalar boundaries and snapshots');}
}
done_testing() unless caller;
1;
