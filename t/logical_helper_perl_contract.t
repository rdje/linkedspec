#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;

use File::Basename qw(dirname);
use File::Spec;
use IPC::Open3 qw(open3);
use JSON::PP ();
use Symbol qw(gensym);

BEGIN {
 my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
 unshift @INC, File::Spec->catdir($repo_root, 'perl');
}

use LinkedSpec;
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::RuntimeLogical ();

my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $contract_path = File::Spec->catfile(
 $repo_root,
 qw(capability_conformance logical_helper_contract.json),
);
open my $contract_fh, '<:encoding(UTF-8)', $contract_path
 or die "cannot read $contract_path: $!";
my $json = JSON::PP->new->canonical(1)->allow_nonref(1);
my $contract = $json->decode(do { local $/; <$contract_fh> });
close $contract_fh or die "cannot close $contract_path: $!";

is($contract->{format}, 1, 'logical-helper contract format is pinned');
is($LinkedSpec::RuntimeLogical::CONTRACT_ID, $contract->{contract_id}, 'Perl seam names the neutral contract');

sub typed_value {
 my ($record) = @_;
 my $kind = $record->{kind};
 return undef if $kind eq 'null';
 return $record->{value} if $kind eq 'string' || $kind eq 'number';
 return $record->{value} ? JSON::PP::true : JSON::PP::false if $kind eq 'boolean';
 return [map { typed_value($_) } @{$record->{items}}] if $kind eq 'array';
 return {map { $_ => typed_value($record->{entries}{$_}) } keys %{$record->{entries}}}
  if $kind eq 'harray';
 return {kind => 'codeblock_literal', id => $record->{id}} if $kind eq 'codeblock';
 die "unknown typed logical fixture kind '$kind'";
}

sub perl_reference_spec {
 my ($source) = @_;
 $source =~ s/\n E \{/\n -> Done {/ or die "neutral logical fixture has no E block";
 return $source."\nDone::\n /x/\n"
}

my $generated_package_counter = 0;
sub load_generated_source {
 my ($source, $suffix) = @_;
 ++$generated_package_counter;
 my $package = 'LinkedSpec::LogicalGenerated::'.$suffix.$generated_package_counter;
 my $loaded = eval "package $package;\n$source\n1;";
 my $failure = $@;
 ok($loaded, "$suffix emitted source loads independently") or diag($failure);
 no strict 'refs';
 return *{"${package}::Execute"}{CODE};
}

sub compile_source {
 my ($source, $identity) = @_;
 my $captured = '';
 my %ctx;
 my $parser = LinkedSpec::Get(
  \$source,
  parse_mode => 'consume',
  runtime_ctx_ref => \%ctx,
  dump_parser_source => 1,
  parser_source_ref => \$captured,
  generated_source_identity => $identity,
 );
 ok(ref($parser) eq 'CODE', "$identity compiles through the live Perl path")
  or diag($json->encode($ctx{last_error} // {}));
 my $emitted = LinkedSpec::emit_generated_source(
  \$source,
  parse_mode => 'consume',
  source_identity => $identity,
 );
 is($captured, $emitted, "$identity live capture equals independently emitted source");
 return ($parser, load_generated_source($emitted, $identity =~ s/\W+/_/gr));
}

sub run_parser {
 my ($parser) = @_;
 my $input = 'xx';
 return $parser->(\$input)
}

sub run_primary_command {
 my ($source, $input) = @_;
 my $stderr_fh = gensym();
 my $pid = open3(
  undef,
  my $stdout_fh,
  $stderr_fh,
  $^X,
  File::Spec->catfile($repo_root, 'bin', 'linkedspec'),
  '--inline-spec',
  $source,
  '--input',
  $input,
 );
 local $/;
 my $stdout = <$stdout_fh> // '';
 my $stderr = <$stderr_fh> // '';
 waitpid($pid, 0);
 return ($? >> 8, $stdout, $stderr)
}

subtest 'typed truthiness and real boolean composition' => sub {
 foreach my $case (@{$contract->{truthiness_cases}}) {
  is(
   LinkedSpec::RuntimeLogical::truthy(typed_value($case->{value})),
   $case->{expected} ? 1 : 0,
   "$case->{id} has exact typed truth",
  );
 }
 foreach my $case (@{$contract->{helper_cases}}) {
  my @args = map { typed_value($_) } @{$case->{args}};
  my $result = LinkedSpec::RuntimeLogical::evaluate($case->{helper}, \@args);
  isa_ok($result, 'JSON::PP::Boolean', "$case->{id} result");
  is($result ? 1 : 0, $case->{expected} ? 1 : 0, "$case->{id} result is exact");
 }

 my @empty;
 is(
  LinkedSpec::RuntimeLogical::truthy(scalar(@empty)),
  0,
  'Perl shared numeric zero from an empty aggregate remains false',
 );
 is(
  LinkedSpec::RuntimeLogical::truthy(1 == 2),
  0,
  'Perl shared false comparison result remains false',
 );
 my $inspected_string_zero = '0';
 my $numeric_projection = 0 + $inspected_string_zero;
 is($numeric_projection, 0, 'string-zero probe performs a numeric inspection');
 is(
  LinkedSpec::RuntimeLogical::truthy($inspected_string_zero),
  1,
  'a nonempty string zero remains true after host numeric inspection',
 );
};

subtest 'typed ActionIR and lowering own logical calls' => sub {
 my $node = LinkedSpec::ActionIR::AST::parse_action_expr('and(true, or(false, "0"))');
 is($node->{kind}, 'call', 'logical expression is typed call data');
 is($node->{semantic_family}, 'logical', 'outer call records the logical semantic family');
 is($node->{evaluation_policy}, 'eager_left_to_right', 'outer call records eager evaluation');
 is($node->{result_kind}, 'boolean', 'outer call records boolean result kind');
 is($node->{minimum_arity}, 1, 'outer call records minimum arity');
 is($node->{maximum_arity}, undef, 'variadic logical call records no maximum');
 is($node->{args}[1]{semantic_family}, 'logical', 'nested logical call is typed independently');

 my $lowered = LinkedSpec::call_spec_handler_subst('Top', 'return(and(true, false))');
 like($lowered, qr/RuntimeLogical::evaluate\('and'/, 'direct return lowers through the typed runtime seam');
 unlike($lowered, qr/\band\s*\(/, 'direct return leaves no raw Perl keyword call');
 unlike($lowered, qr/&&|\|\|/, 'direct return does not use host short-circuit operators');

 my $condition = LinkedSpec::call_spec_handler_subst('Top', 'if(and(true, false), return(1))');
 like($condition, qr/RuntimeLogical::truthy/, 'condition uses the same typed truthiness seam');
 like($condition, qr/RuntimeLogical::evaluate\('and'/, 'condition logical helper uses typed composition');
 unlike($condition, qr/&&|\|\|/, 'condition lowering has no host logical shortcut');

 my $bad = LinkedSpec::call_spec_handler_subst('Top', 'return(not(false, true))');
 like($bad, qr/helper_arity_mismatch\(\$descr, 'Top', 'not', 2, 'exactly 1 positional argument'\)/,
  'invalid not arity is emitted before either operand');
 unlike($bad, qr/RuntimeLogical::evaluate/, 'invalid arity emits no operand evaluator');
};

subtest 'neutral live and emitted fixtures agree' => sub {
 foreach my $fixture_id (qw(values effects receiver_and_lazy_control)) {
  my $fixture = $contract->{fixtures}{$fixture_id};
  my $source = perl_reference_spec($fixture->{spec_source});
  my ($live, $emitted) = compile_source($source, "logical-helper/$fixture_id.spec");
  is_deeply(run_parser($live), $fixture->{expected}, "$fixture_id live result matches the neutral fixture");
  is_deeply(run_parser($emitted), $fixture->{expected}, "$fixture_id emitted result matches the neutral fixture");
 }
};

subtest 'invalid arity precedes effects in live and emitted execution' => sub {
 my %expected = map { $_->{id} => $_ } @{$contract->{invalid_arity_cases}};
 foreach my $fixture (@{$contract->{fixtures}{invalid_arity}}) {
  my $source = perl_reference_spec($fixture->{spec_source});
  my ($live, $emitted) = compile_source($source, "logical-helper/$fixture->{id}.spec");
  foreach my $surface ([live => $live], [emitted => $emitted]) {
   my $ok = eval { run_parser($surface->[1]); 1 };
   my $caught = $@;
   ok(!$ok, "$fixture->{id} $surface->[0] execution rejects invalid arity");
   isa_ok($caught, 'LinkedSpec::RuntimeDiagnosticOutput::Error', "$fixture->{id} $surface->[0] error");
   is($caught->{code}, $expected{$fixture->{id}}{expected_code}, "$fixture->{id} $surface->[0] code is exact");
   is($caught->{helper_name}, $expected{$fixture->{id}}{helper_name}, "$fixture->{id} $surface->[0] helper is exact");
   is($caught->{actual_arity}, $expected{$fixture->{id}}{actual_arity}, "$fixture->{id} $surface->[0] actual arity is exact");
   is($caught->{expected_arity}, $expected{$fixture->{id}}{expected_arity}, "$fixture->{id} $surface->[0] expected arity is exact");
   is($caught->{arguments_evaluated}, 0, "$fixture->{id} $surface->[0] evaluates no operand");
   is($caught->{rule_label}, 'Top', "$fixture->{id} $surface->[0] preserves rule attribution");
  }
 }
};

subtest 'Perl primary command preserves values and failure framing' => sub {
 my $values = $contract->{fixtures}{values};
 my ($status, $stdout, $stderr) = run_primary_command(
  perl_reference_spec($values->{spec_source}),
  'xx',
 );
 is($status, 0, 'primary logical value fixture exits successfully');
 is($stdout, $json->encode($values->{expected})."\n", 'primary logical values are exact canonical JSON');
 is($stderr, '', 'primary logical value fixture keeps stderr empty');

 my ($invalid) = grep { $_->{id} eq 'not_many' } @{$contract->{fixtures}{invalid_arity}};
 ($status, $stdout, $stderr) = run_primary_command(
  perl_reference_spec($invalid->{spec_source}),
  'xx',
 );
 is($status, 1, 'primary invalid logical arity exits with invocation failure');
 is($stdout, '', 'primary invalid logical arity keeps stdout empty');
 is($stderr, "linkedspec: parser invocation failed\n", 'primary invalid logical arity uses stable failure framing');
};

subtest 'assignment, block, user-function, and while paths share the policy' => sub {
 my $source = <<'SPEC';
fn all(value) { return(and(value, true)) }
Top::
 /x/ -> Done {
   assigned = or(0, "")
   block_value = not({ return([]) })
   seen = []
   flag = "0"
   while(flag) { push(seen, "body"); flag = "" }
   return([all("0"), assigned, block_value, copy(seen)])
 }
Done::
 /x/
SPEC
 my ($live, $emitted) = compile_source($source, 'logical-helper/typed-sites.spec');
 my $expected = [JSON::PP::true, JSON::PP::false, JSON::PP::true, ['body']];
 is_deeply(run_parser($live), $expected, 'live typed sites preserve values and one lazy while body');
 is_deeply(run_parser($emitted), $expected, 'emitted typed sites preserve values and one lazy while body');

 my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
 my $meta = $descriptor->{spec}{Top}{meta}{action_rewriter};
 is($meta->{raw_perl_dependency_count} || 0, 0, 'typed logical sites add no raw Perl dependency');
 is($meta->{unresolved_helper_count} || 0, 0, 'typed logical sites leave no unresolved helper');
 ok($meta->{language_agnostic_action_ir_ready}, 'descriptor remains language-agnostic ActionIR ready');
};

done_testing();
