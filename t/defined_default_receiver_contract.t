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
my $source = read_fixture('tests/fixtures/defined_default_receiver_values.spec');
my $expected = $json->decode(read_fixture('tests/fixtures/defined_default_receiver_values.json'));
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
my $input = 'x';
my $actual = eval { $parser->(\$input) };
is("$@", '', 'native defined defaults have no thrown error');
is($context{last_error}, undef, 'native defined defaults have no handler error')
 or diag($json->encode($context{last_error}));
is($json->encode($actual), $json->encode($expected),
 'native defined selection, actual kinds, lazy copies, boundaries and effects');

my $emitted = LinkedSpec::emit_generated_source(\$source,
 source_identity => 'defined-default-receivers.spec');
my $loaded = eval "package LinkedSpec::DefinedDefaultReceiverGenerated; $emitted; 1";
ok($loaded, 'fresh defined-default parser compiles') or diag($@);
if ($loaded) {
 my $fresh_input = 'x';
 my $value = eval { LinkedSpec::DefinedDefaultReceiverGenerated::Execute(\$fresh_input) };
 is("$@", '', 'fresh defined defaults have no thrown error');
 is($json->encode($value), $json->encode($expected),
  'fresh defined selection, actual kinds, lazy copies, boundaries and effects');
}

# The Hash consumer's block key uses the same legacy lowering as its free form.
# Retain the direct producer independently of the new receiver spelling.
my $key_source = q{Top:: I { meta={"a":"a","b":"b"};order="";chosen=coalesce(undef,meta);picked=pick_keys(chosen,{order=cat(order,"C");meta["a"]="z";"a"});return([uppercase(first(sorted_values(picked))),order,meta]) }};
my %key_context;
my $key_parser = LinkedSpec::Get(\$key_source, runtime_ctx_ref => \%key_context);
my $key_input = 'x';
my $key_actual = eval { $key_parser->(\$key_input) };
is("$@", '', 'native expression-valued pick key has no thrown error');
is($key_context{last_error}, undef, 'native expression-valued pick key compiles');
my $key_expected = $json->decode('["A","C",{"a":"z","b":"b"}]');
is($json->encode($key_actual), $json->encode($key_expected),
 'free pick key evaluates once after capturing its Hash');
my $key_emitted = LinkedSpec::emit_generated_source(\$key_source,
 source_identity => 'defined-default-key-block.spec');
my $key_loaded = eval "package LinkedSpec::DefinedDefaultKeyGenerated; $key_emitted; 1";
ok($key_loaded, 'fresh expression-valued pick key compiles') or diag($@);
if ($key_loaded) {
 my $subject = 'x';
 my $value = eval { LinkedSpec::DefinedDefaultKeyGenerated::Execute(\$subject) };
 is("$@", '', 'fresh expression-valued pick key has no thrown error');
 is($json->encode($value), $json->encode($key_expected),
  'fresh free pick key preserves capture and once-only effects');
}

my $retired = LinkedSpec::call_spec_handler_subst('Top',
 q{return(undef.coalesce({"key" => 7}).sorted_values())});
like($retired, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon/,
 'defined-default composition retains authored Hash colon validation');

done_testing() unless caller;
1;
