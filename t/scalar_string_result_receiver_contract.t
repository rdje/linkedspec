use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

sub read_fixture {
 my ($path) = @_;
 open my $file, '<:encoding(UTF-8)', $path or die "$path: $!";
 local $/;
 return <$file>;
}

my $json = JSON::PP->new->canonical;
my $source = read_fixture('tests/fixtures/scalar_string_result_receiver_values.spec');
my $expected = $json->decode(read_fixture('tests/fixtures/scalar_string_result_receiver_values.json'));
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
my $input = 'x';
my $actual = eval { $parser->(\$input) };
is("$@", '', 'native scalar String results have no thrown error');
is($context{last_error}, undef, 'native scalar String results have no handler error')
 or diag($json->encode($context{last_error}));
is($json->encode($actual), $json->encode($expected),
 'native String scalar identity kinds, source snapshots, Unicode, boundaries and effects');

my $emitted = LinkedSpec::emit_generated_source(\$source,
 source_identity => 'scalar-string-results.spec');
my $loaded = eval "package LinkedSpec::ScalarStringResultGenerated; $emitted; 1";
ok($loaded, 'fresh scalar String result parser compiles') or diag($@);
if ($loaded) {
 my $fresh_input = 'x';
 my $value = eval { LinkedSpec::ScalarStringResultGenerated::Execute(\$fresh_input) };
 is("$@", '', 'fresh scalar String results have no thrown error');
 is($json->encode($value), $json->encode($expected),
  'fresh String scalar identity kinds, source snapshots, Unicode, boundaries and effects');
}

my $retired = LinkedSpec::call_spec_handler_subst('Top',
 q{return("a".cat({"key" => 7}).uppercase())});
like($retired, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon/,
 'String composition retains authored Hash colon validation');

done_testing() unless caller;
1;
