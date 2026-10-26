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
my $source = read_fixture('tests/fixtures/logical_result_receiver_values.spec');
my $expected = $json->decode(read_fixture('tests/fixtures/logical_result_receiver_values.json'));
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
my $input = 'x';
my $actual = eval { $parser->(\$input) };
is("$@", '', 'native logical results have no thrown error');
is($context{last_error}, undef, 'native logical results have no handler error');
is($json->encode($actual), $json->encode($expected), 'native Boolean kinds, continuations and eager snapshots');

my $sequence = 0;
sub fresh_parser {
 my ($spec) = @_;
 my $emitted = LinkedSpec::emit_generated_source(\$spec,
  source_identity => 'logical-result-receivers.spec');
 my $package = 'LinkedSpec::LogicalResultReceiverGenerated'.++$sequence;
 my $loaded = eval "package $package; $emitted; 1";
 ok($loaded, 'fresh logical result parser compiles') or diag($@);
 return unless $loaded;
 no strict 'refs';
 return \&{$package.'::Execute'};
}

if (my $fresh = fresh_parser($source)) {
 my $fresh_input = 'x';
 my $value = eval { $fresh->(\$fresh_input) };
 is("$@", '', 'fresh logical results have no thrown error');
 is($json->encode($value), $json->encode($expected), 'fresh Boolean kinds, continuations and eager snapshots');
}

for my $case (
 ['and', 0, 'and()'],
 ['or', 0, 'or()'],
 ['not', 0, 'not()'],
 ['not', 2, 'not({fail("must-not-run")},{fail("must-not-run")})'],
 ['not', 2, 'not({print("must-not-run");true},{print("must-not-run");false})'],
) {
 my ($helper, $arity, $call) = @$case;
 subtest "$helper source arity $arity precedes invalid operands and consumers" => sub {
  my $spec = 'Top:: I { return('.$call.'.cat("!")) }';
  my $live = LinkedSpec::Get(\$spec);
  my $fresh = fresh_parser($spec);
  for my $route ([native => $live], [fresh => $fresh]) {
   next unless $route->[1];
   my $subject = 'x';
   my $ok = eval { $route->[1]->(\$subject); 1 };
   my $error = $@;
   ok(!$ok, "$route->[0] rejects source arity");
   isa_ok($error, 'LinkedSpec::RuntimeDiagnosticOutput::Error');
   if (ref($error) eq 'LinkedSpec::RuntimeDiagnosticOutput::Error') {
    is($error->{code}, 'helper_arity_mismatch', 'typed logical error retained');
    is($error->{helper_name}, $helper, 'logical source helper identified');
    is($error->{actual_arity}, $arity, 'logical source arity identified');
    is($error->{arguments_evaluated}, 0, 'no invalid source operand evaluated');
   }
  }
 };
}

my $retired = LinkedSpec::call_spec_handler_subst('Top',
 q{return(and(true).add(1).coalesce_nonempty({"key" => 7}).sorted_values())});
like($retired, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon/,
 'logical composition retains authored Hash colon validation');

done_testing() unless caller;
1;
