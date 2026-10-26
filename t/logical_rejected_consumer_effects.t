use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

sub read_fixture {
 my ($path) = @_;
 open my $file, '<', $path or die "$path: $!";
 local $/;
 return <$file>;
}

my $json = JSON::PP->new->canonical;
my @cases = (
 [read_fixture('tests/fixtures/logical_rejected_consumer_effects.spec'),
  $json->decode(read_fixture('tests/fixtures/logical_rejected_consumer_effects.json'))],
 [q{Top:: I { seen=0;bad=and({seen=num_add(seen,1);true}).sorted(1);return([bad,seen]) }},
  [undef, 0]],
);
my $sequence = 0;
for my $case (@cases) {
 my ($source, $expected) = @$case;
 my %context;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
 my $input = 'x';
 my $actual = eval { $parser->(\$input) };
 is("$@", '', 'native rejection has no thrown error');
 is($context{last_error}, undef, 'native rejection has no handler error');
 is($json->encode($actual), $json->encode($expected),
  'native rejection retains valid prefix effects and preflight boundaries');
 my $emitted = LinkedSpec::emit_generated_source(\$source,
  source_identity => 'logical-rejected-consumer-effects.spec');
 my $package = 'LinkedSpec::LogicalRejectedConsumerEffects'.++$sequence;
 my $loaded = eval "package $package; $emitted; 1";
 ok($loaded, 'fresh rejection parser compiles') or diag($@);
 if ($loaded) {
  my $fresh_input = 'x';
  no strict 'refs';
  my $value = eval { &{$package.'::Execute'}(\$fresh_input) };
  is("$@", '', 'fresh rejection has no thrown error');
  is($json->encode($value), $json->encode($expected),
   'fresh rejection retains valid prefix effects and preflight boundaries');
 }
}

done_testing() unless caller;
1;
