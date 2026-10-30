use strict;
use warnings;
use JSON::PP ();
use Test::More;
use LinkedSpec ();

my $json=JSON::PP->new->canonical;
open my $file,'<','tests/fixtures/pick_keys_operand_isolation.json' or die $!;
my $text; {local $/;$text=<$file>}
my $sequence=0;
for my $case (@{$json->decode($text)}) {
 subtest $case->{name} => sub {
  my $source=$case->{source};my (%context,@warnings);
  local $SIG{__WARN__}=sub{push @warnings,@_};
  my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
  ok(ref($parser) eq 'CODE','native parser builds') or return;
  my $input=$case->{input};my $value=eval{$parser->(\$input)};
  is("$@",'','native has no thrown error');
  is($context{last_error},undef,'native has no handler error');
  is($json->encode($value),$json->encode($case->{expected}),'native preserves each key, result and operand effect');
  is(pos($input),$case->{expected_cursor},'native cursor unchanged');
  my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'pick-keys-isolation.spec');
  my $package='LinkedSpec::PickKeysIsolation'.++$sequence;
  my $loaded=eval "package $package; $emitted; 1";
  ok($loaded,'fresh emitted parser loads') or do{diag($@);return};
  my $fresh_input=$case->{input};my $fresh=eval{$package->can('Execute')->(\$fresh_input)};
  is("$@",'','fresh has no thrown error');
  is($json->encode($fresh),$json->encode($case->{expected}),'fresh preserves each key, result and operand effect');
  is(pos($fresh_input),$case->{expected_cursor},'fresh cursor unchanged');
  is_deeply(\@warnings,[],'all build/load/run channels have no warnings');
 };
}
done_testing;
