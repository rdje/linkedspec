#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use JSON::PP ();
use Test::More;

use lib "$Bin/../perl";
use LinkedSpec;
use LinkedSpec::EntryRuleSelection ();
use LinkedSpec::Validation ();

my $contract_path = "$Bin/../capability_conformance/root_rule_selection_contract.json";
open my $contract_fh, '<', $contract_path or die "cannot open $contract_path: $!";
my $contract = JSON::PP->new->decode(do { local $/; <$contract_fh> });
close $contract_fh or die "cannot close $contract_path: $!";

sub selection_rows {
 my ($case) = @_;
 return [map {
  {
   label => $_->{label},
   is_top => $_->{authored_is_top} ? 1 : 0,
  }
 } @{$case->{rules}}]
}

sub compile_parser {
 my ($source, $selector) = @_;
 my %runtime_ctx;
 my @options = (runtime_ctx_ref => \%runtime_ctx);
 push @options, (top_rule => $selector) if defined $selector;
 my $parser = LinkedSpec::Get(\$source, @options);
 return ($parser, \%runtime_ctx)
}

sub run_parser {
 my ($source, $selector, $input) = @_;
 my ($parser, $runtime_ctx) = compile_parser($source, $selector);
 return (undef, $runtime_ctx, 'parser did not compile') unless ref($parser) eq 'CODE';
 my $value;
 my $ok = eval {
  $value = $parser->(\$input);
  1;
 };
 return ($value, $runtime_ctx, $ok ? '' : $@)
}

sub strict_result {
 my ($source) = @_;
 my %failure;
 my $ok = LinkedSpec::Validation::validate_dsl_syntax(
  \$source,
  {
   strict_syntax => 1,
   on_failure => sub {
    %failure = @_;
    return 1;
   },
  },
 );
 return ($ok ? 1 : 0, \%failure)
}

subtest 'neutral resolver success and failure rows execute exactly' => sub {
 for my $case (@{$contract->{selection_cases}}) {
  my $selection = LinkedSpec::EntryRuleSelection::select_entry_rule(
   selection_rows($case),
   $case->{explicit_selector},
  );
  ok($selection->{ok}, "$case->{id} resolves successfully");
  is($selection->{entry_rule}, $case->{expected_label}, "$case->{id} selects the exact label");
  is($selection->{basis}, $case->{expected_basis}, "$case->{id} reports the exact basis");
 }

 for my $case (@{$contract->{failure_cases}}) {
  my $selection = LinkedSpec::EntryRuleSelection::select_entry_rule(
   selection_rows($case),
   $case->{explicit_selector},
  );
  ok(!$selection->{ok}, "$case->{id} rejects selection");
  is($selection->{code}, $case->{expected_code}, "$case->{id} reports the portable code");
  is($selection->{stage}, $case->{expected_stage}, "$case->{id} reports the portable stage");
 }
};

my $marked_source = <<'SPEC';
Earlier:
 /x/ -> EarlierDone { return("earlier") }
EarlierDone: /x/
Marked::
 /x/ -> MarkedDone { return("marked") }
MarkedDone: /x/
Later::
 /x/ -> LaterDone { return("later") }
LaterDone: /x/
SPEC

my $markerless_source = <<'SPEC';
First:
 /x/ -> FirstDone { return("first") }
FirstDone: /x/
Second:
 /x/ -> SecondDone { return("second") }
SecondDone: /x/
SPEC

subtest 'native execution applies explicit marker fallback precedence' => sub {
 my ($default_value, $default_ctx, $default_error) = run_parser($marked_source, undef, 'x');
 is($default_error, '', 'marked default execution does not die');
 is($default_value, 'marked', 'first authored marker beats an earlier ordinary rule');
 is($default_ctx->{top_rule}, 'Marked', 'runtime context records the effective marked entry');

 my ($ordinary_value, $ordinary_ctx, $ordinary_error) = run_parser($marked_source, 'Earlier', 'x');
 is($ordinary_error, '', 'explicit ordinary execution does not die');
 is($ordinary_value, 'earlier', 'explicit ordinary rule beats both authored markers');
 is($ordinary_ctx->{top_rule}, 'Earlier', 'runtime context records the explicit ordinary entry');

 my ($later_value, $later_ctx, $later_error) = run_parser($marked_source, 'Later', 'x');
 is($later_error, '', 'explicit later-marker execution does not die');
 is($later_value, 'later', 'explicit later marker beats the first marker');
 is($later_ctx->{top_rule}, 'Later', 'runtime context records the explicit later marker');

 my ($fallback_value, $fallback_ctx, $fallback_error) = run_parser($markerless_source, undef, 'x');
 is($fallback_error, '', 'markerless fallback execution does not die');
 is($fallback_value, 'first', 'markerless source selects the first authored rule');
 is($fallback_ctx->{top_rule}, 'First', 'runtime context records the first-rule fallback');

 my ($second_value, $second_ctx, $second_error) = run_parser($markerless_source, 'Second', 'x');
 is($second_error, '', 'markerless explicit execution does not die');
 is($second_value, 'second', 'explicit selector beats markerless first-rule fallback');
 is($second_ctx->{top_rule}, 'Second', 'runtime context records the explicit markerless entry');
};

subtest 'descriptor preserves order and authored marker identity' => sub {
 my %runtime_ctx;
 my $descriptor = LinkedSpec::Get(
  \$marked_source,
  return_descriptor => 1,
  top_rule => 'Earlier',
  runtime_ctx_ref => \%runtime_ctx,
 );
 ok(ref($descriptor) eq 'HASH', 'descriptor compiles with an explicit ordinary selector');
 is(
  $descriptor->{meta}{entry_rule_contract},
  'linkedspec-root-rule-selection-v1',
  'descriptor publishes the root-selection contract identity',
 );
 is_deeply(
  $descriptor->{meta}{definition_order},
  [qw(Earlier EarlierDone Marked MarkedDone Later LaterDone)],
  'descriptor preserves exact authored definition order',
 );
 is_deeply(
  [map { $descriptor->{spec}{$_}{meta}{is_top} } @{$descriptor->{meta}{definition_order}}],
  [0, 0, 1, 0, 1, 0],
  'descriptor exposes immutable authored is_top bits for every rule',
 );
 is($runtime_ctx{top_rule}, 'Earlier', 'explicit descriptor request records execution selection separately');
 is($descriptor->{spec}{Earlier}{meta}{is_top}, 0, 'explicit selection does not rewrite ordinary source identity');
 is($descriptor->{spec}{Marked}{meta}{is_top}, 1, 'explicit selection does not clear authored marker identity');
};

subtest 'unknown explicit selector fails at selection before handler invocation' => sub {
 my ($parser, $runtime_ctx) = compile_parser($marked_source, 'Missing');
 ok(ref($parser) eq 'CODE', 'unknown selector preserves compile-before-input primary ordering');
 my $input = 'x';
 my $ok = eval {
  $parser->(\$input);
  1;
 };
 ok(!$ok, 'unknown selector rejects parser invocation');
 like($@, qr/No declared rule matches explicit entry selector 'Missing'/, 'unknown selector reports exact detail');
 is($runtime_ctx->{last_error}{code}, 'entry_rule_not_found', 'unknown selector reports portable code');
 is($runtime_ctx->{last_error}{stage}, 'select_entry_rule', 'unknown selector reports portable stage');
 is($runtime_ctx->{last_error}{entry_rule}, 'Missing', 'unknown selector reports requested entry label');
 is($runtime_ctx->{last_error}{top_rule}, 'Missing', 'unknown selector retains requested label for attribution');
};

subtest 'zero rules fail before selection while markerless rules validate' => sub {
 ok(
  LinkedSpec::Validation::validate_spec_content(\$markerless_source),
  'envelope validation accepts one-or-more-rule markerless source',
 );

 for my $case (
  ['empty', ''],
  ['comment-only', "# no rules\n"],
 ) {
  my ($label, $source) = @$case;
  my %runtime_ctx;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%runtime_ctx);
  ok(!defined($parser), "$label source is invalid");
  is($runtime_ctx{last_error}{code}, 'no_rules_defined', "$label source reports portable code");
  is($runtime_ctx{last_error}{stage}, 'validate_spec', "$label source fails before entry selection");
 }
};

subtest 'strict unused remains authored-edge graph analysis' => sub {
 my $marker_source = <<'SPEC';
Top::
 /x/ -> Child { return(1) }
Child:
 /x/ -> Child { return(1) }
SPEC
 my ($marker_ok, $marker_failure) = strict_result($marker_source);
 ok(!$marker_ok, 'strict mode rejects the unreferenced marked rule');
 like($marker_failure->{detail}, qr/Unused rule\(s\): Top/, 'authored marker is not a strict reference or exemption');

 my $unreferenced_source = "A: /a/\nB: /b/\n";
 my ($unreferenced_ok, $unreferenced_failure) = strict_result($unreferenced_source);
 ok(!$unreferenced_ok, 'strict mode rejects both unreferenced markerless rules');
 like($unreferenced_failure->{detail}, qr/Unused rule\(s\): A, B/, 'selection does not add a strict reference');

 my $cycle_source = "A: /a/ -> B\nB: /b/ -> A\n";
 my ($cycle_ok, $cycle_failure) = strict_result($cycle_source);
 ok($cycle_ok, 'closed authored reference cycle has no unused rules')
  or diag(JSON::PP->new->canonical->encode($cycle_failure));

 my $descriptor = LinkedSpec::Get(
  \$unreferenced_source,
  return_descriptor => 1,
  strict_syntax => 1,
 );
 ok(ref($descriptor) eq 'HASH', 'Get strict_syntax remains unwired rather than silently expanding the public API');
};

done_testing;
