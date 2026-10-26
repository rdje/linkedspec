use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
sub read_fixture { my ($path)=@_;open my $fh,'<',$path or die "$path: $!";local $/;return <$fh> }
my $json=JSON::PP->new->canonical;
my @cases=(
 [read_fixture('tests/fixtures/numeric_comparison_result_receiver_values.spec'),$json->decode(read_fixture('tests/fixtures/numeric_comparison_result_receiver_values.json'))],
 [q{Top:: I { score=2;values=["zero","one"];values[score.eq(2)]="updated";return(values) }},['zero','updated']],
);
my $sequence=0;
for my $case (@cases){
 my($source,$expected)=@$case;
 my %context;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);my $input='x';my $actual=eval {$parser->(\$input)};
 is("$@",'','native numeric comparison result execution has no thrown error');
 is($context{last_error},undef,'native numeric comparison results have no handler error') or diag($context{last_error}{summary}//'handler error');
 is($json->encode($actual),$json->encode($expected),'native numeric comparison results, kinds, scalar boundaries and snapshots');
 my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'numeric-comparison-result-receivers.spec');
 my $package='LinkedSpec::NumericComparisonResultReceiverGenerated'.++$sequence;
 my $loaded=eval "package $package; $emitted; 1";
 ok($loaded,'fresh numeric comparison-result parser compiles') or diag($@);
 if($loaded){my $fresh_input='x';no strict 'refs';my $fresh=eval {&{$package.'::Execute'}(\$fresh_input)};
  is("$@",'','fresh numeric comparison-result execution has no thrown error');
  is($json->encode($fresh),$json->encode($expected),'fresh numeric comparison results, kinds, scalar boundaries and snapshots');}
}
done_testing() unless caller;
1;
