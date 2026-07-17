use strict;
use warnings;

use FindBin qw($Bin);
use JSON::PP ();
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;
use LinkedSpec::BootstrapSpec ();
use LinkedSpec::RuleIR ();

my $contract_path = "$Bin/../capability_conformance/rule_local_cursor_contract.json";
open my $contract_fh, '<', $contract_path or die "cannot open $contract_path: $!";
my $contract = JSON::PP->new->decode(do { local $/; <$contract_fh> });
close $contract_fh or die "cannot close $contract_path: $!";

sub family_header_source {
 my ($header) = @_;
 return "$header\n /x/\n" if $header =~ /::/;
 return "Root::\n -> Top\n$header\n /x/\n"
}

sub edge_source {
 my ($family, $sources, $declared_rules) = @_;
 my $header = $family eq 'and' ? 'Top::AND' : 'Top::';
 my $source = $header . "\n" . join("\n", map { " $_" } @$sources) . "\n";
 for my $label (@$declared_rules) {
  my $literal = lc(substr($label, 0, 1) || 'x');
  my $needs_second_regex = grep { /\b\Q$label\E\s*\[\s*[1-9]/ } @$sources;
  $source .= "$label: /$literal/" . ($needs_second_regex ? " /${literal}2/" : '') . "\n";
 }
 return $source
}

sub compile_descriptor {
 my ($source) = @_;
 my %runtime_ctx;
 my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1, runtime_ctx_ref => \%runtime_ctx);
 return ($descriptor, \%runtime_ctx)
}

sub parsed_rule_ir {
 my ($source, $label) = @_;
 my ($ok, $parsed, $error) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$source);
 ok($ok, "$label bootstrap source parses") or diag($error // 'bootstrap parse failed without detail');
 return unless $ok;
 my %declared = map {
  my $entry = $_;
  my $entry_label = ref($entry) eq 'ARRAY' && ref($entry->[0]) eq 'ARRAY' ? $entry->[0][1] : undef;
  defined($entry_label) ? ($entry_label => 1) : ()
 } @$parsed;
 my ($tokens) = grep {
  ref($_) eq 'ARRAY' && ref($_->[0]) eq 'ARRAY' && defined($_->[0][1]) && $_->[0][1] eq $label
 } @$parsed;
 return unless $tokens;
 my $rule_ir = LinkedSpec::RuleIR::_collect_rule_ir($tokens);
 my $normalized = eval {
  LinkedSpec::RuleIR::_normalize_rule_ir_edges($rule_ir, declared_rule_labels => \%declared);
  1;
 };
 ok($normalized, "$label RuleIR normalizes") or diag(ref($@) eq 'HASH' ? JSON::PP->new->canonical->encode($@) : $@);
 return $normalized ? $rule_ir : undef
}

for my $case (@{$contract->{family_cases}}) {
 my ($descriptor, $ctx) = compile_descriptor(family_header_source($case->{header}));
 ok($descriptor, "$case->{id} compiles from authored source")
  or diag(JSON::PP->new->canonical->encode($ctx->{last_error} // {}));
 next unless $descriptor;
 is($descriptor->{spec}{Top}{meta}{family}, $case->{family}, "$case->{id} derives family");
 is($descriptor->{spec}{Top}{meta}{cursor_policy}, $case->{cursor_policy}, "$case->{id} derives cursor policy");
}

my %diagnostic_contract = map { $_->{code} => $_ } @{$contract->{diagnostics}};

for my $case (@{$contract->{edge_resolution_cases}}) {
 my $source = edge_source($case->{parent_family}, [$case->{source}], $case->{declared_rules});
 if (my $expected_error = $case->{expected_error}) {
  my ($descriptor, $ctx) = compile_descriptor($source);
  ok(!$descriptor, "$case->{id} rejects before handler emission");
  my $error = $ctx->{last_error} || {};
  is($error->{code}, $expected_error, "$case->{id} reports portable code");
  is($error->{stage}, $diagnostic_contract{$expected_error}{stage}, "$case->{id} reports portable stage");
  for my $field (@{$diagnostic_contract{$expected_error}{fields}}) {
   ok(exists($error->{$field}), "$case->{id} reports required field $field");
  }
  next;
 }

 my $expected = $case->{expected};
 my $rule_ir = parsed_rule_ir($source, 'Top');
 next unless $rule_ir;
 my ($descriptor, $ctx) = compile_descriptor($source);
 ok($descriptor, "$case->{id} compiles from authored source")
  or diag(JSON::PP->new->canonical->encode($ctx->{last_error} // {}));

 if ($expected->{kind} eq 'lifecycle') {
  my ($ok, $parsed) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$source);
  my ($top) = grep { ref($_) eq 'ARRAY' && ref($_->[0]) eq 'ARRAY' && ($_->[0][1] // '') eq 'Top' } @$parsed;
  ok(grep({ $_->[0] eq $expected->{name} . 'CODE' } @$top), "$case->{id} keeps reserved lifecycle precedence");
  is($rule_ir->{edge_ownership}, 'none', "$case->{id} does not become a rule edge");
  next;
 }

 my $expected_ownership = $expected->{ownership};
 is($descriptor->{spec}{Top}{meta}{edge_ownership}, $expected_ownership, "$case->{id} preserves resolved ownership");
 if ($expected->{source_form} eq 'bare') {
  is(scalar(@{$rule_ir->{normalized_edges}}), 1, "$case->{id} produces one normalized edge");
  my $normalized = $rule_ir->{normalized_edges}[0];
  is($normalized->{kind}, 'edge', "$case->{id} produces typed edge kind");
  is($normalized->{ownership}, $expected_ownership, "$case->{id} normalizes family ownership");
  is($normalized->{source_form}, 'bare', "$case->{id} retains source form");
  is($normalized->{has_block}, $expected->{has_block} ? 1 : 0, "$case->{id} retains block presence");
  is($normalized->{fluent}, $expected->{targets}[0]{fluent}, "$case->{id} retains normalized fluent form");
  is_deeply($normalized->{targets}, $expected->{targets}, "$case->{id} retains target/index structure");
 }
}

for my $case (@{$contract->{rule_edge_set_cases}}) {
 my $source = edge_source($case->{parent_family}, $case->{sources}, $case->{declared_rules});
 my ($descriptor, $ctx) = compile_descriptor($source);
 if (my $expected_error = $case->{expected_error}) {
  ok(!$descriptor, "$case->{id} rejects mixed normalized ownership");
  my $error = $ctx->{last_error} || {};
  is($error->{code}, $expected_error, "$case->{id} reports portable code");
  is($error->{stage}, $diagnostic_contract{$expected_error}{stage}, "$case->{id} reports portable stage");
  is_deeply($error->{ownerships}, ['action', 'blind'], "$case->{id} reports exact ownership set");
  next;
 }
 ok($descriptor, "$case->{id} compiles from authored source")
  or diag(JSON::PP->new->canonical->encode($ctx->{last_error} // {}));
 next unless $descriptor;
 is($descriptor->{spec}{Top}{meta}{edge_ownership}, $case->{expected_ownership}, "$case->{id} has one normalized ownership");
}

my $lifecycle_body_source = <<'SPEC';
Top::
 I {
  set(name, "Child")
 }
Child:
 /c/
SPEC
my $lifecycle_ir = parsed_rule_ir($lifecycle_body_source, 'Top');
is($lifecycle_ir->{edge_ownership}, 'none', 'identifier text inside lifecycle code is not re-scanned as a bare edge');

my $multiline_bare_source = <<'SPEC';
Top::AND
 Child {
  return(child_result)
 }
Child:
 /c/
SPEC
my $multiline_ir = parsed_rule_ir($multiline_bare_source, 'Top');
is($multiline_ir->{edge_ownership}, 'blind', 'multiline complete-line bare block normalizes as one blind edge');
is($multiline_ir->{normalized_edges}[0]{has_block}, 1, 'multiline bare block retains block presence');

my $bare_group_without_block = edge_source('or_default', ['A | B'], ['A', 'B']);
my ($missing_block_descriptor, $missing_block_ctx) = compile_descriptor($bare_group_without_block);
ok(!$missing_block_descriptor, 'bare grouped action without a shared block rejects');
is($missing_block_ctx->{last_error}{code}, 'grouped_action_shared_block_required', 'bare grouped action uses portable shared-block diagnostic');
is_deeply($missing_block_ctx->{last_error}{targets}, ['A', 'B'], 'bare grouped action diagnostic reports all targets');

my $live_boundary_source = <<'SPEC';
Top::AND
 /x/
 -> Top { return("hit") }
SPEC
my $live_parser = LinkedSpec::Get(\$live_boundary_source);
ok($live_parser, 'derived AND policy compiles for live rule-local cursor execution');
my $live_input = 'prefix x';
ok(!defined($live_parser->(\$live_input)), 'live Perl execution spends the derived AND consume policy');

done_testing;
