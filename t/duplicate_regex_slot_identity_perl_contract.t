#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec;
use File::Temp qw(tempdir tempfile);
use FindBin qw($Bin);
use JSON::PP ();
use Test::More;

use lib "$Bin/../perl";
use LinkedRE ();
use LinkedSpec;
use LinkedSpec::Trace ();

my $CONTRACT_ID = 'linkedspec-duplicate-regex-slot-identity-v1';
my $contract_path = "$Bin/../capability_conformance/duplicate_regex_slot_identity_contract.json";
open my $contract_fh, '<', $contract_path or die "cannot open $contract_path: $!";
my $contract = JSON::PP->new->decode(do { local $/; <$contract_fh> });
close $contract_fh or die "cannot close $contract_path: $!";

my %fixture_by_id = map { $_->{id} => $_ } @{$contract->{fixtures}};
my $generated_source;
my $generated_module;
my $generated_package_counter = 0;

sub read_text {
 my ($path) = @_;
 open my $fh, '<', $path or die "cannot read $path: $!";
 my $text = do { local $/; <$fh> };
 close $fh or die "cannot close $path: $!";
 return defined($text) ? $text : ''
}

sub execute_parser {
 my ($parser, $input_text) = @_;
 my $input = $input_text;
 my $result = eval { $parser->(\$input) };
 my $error = $@ // '';
 return ($result, $error, pos($input))
}

sub compile_fixture {
 my ($id, %options) = @_;
 my $fixture = $fixture_by_id{$id} or die "unknown fixture $id";
 my $source = $fixture->{source};
 my %runtime_ctx;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%runtime_ctx, %options);
 ok(ref($parser) eq 'CODE', "$id compiles")
  or diag(JSON::PP->new->canonical->encode($runtime_ctx{last_error} // {}));
 return ($fixture, $parser, \%runtime_ctx)
}

sub load_generated_source {
 my ($source) = @_;
 my $package = 'LinkedSpec::DuplicateSlotAdmission::Generated' . ++$generated_package_counter;
 my $loaded = eval "package $package;\n$source\n1;";
 my $error = $@;
 ok($loaded, 'generated source loads in an isolated package') or diag($error);
 no strict 'refs';
 return {
  execute => *{"${package}::Execute"}{CODE},
  execute_with_trace => *{"${package}::ExecuteWithTrace"}{CODE},
  metadata => *{"${package}::LinkedSpecGeneratedMetadata"}{CODE},
  plan => *{"${package}::LinkedSpecGeneratedPlan"}{CODE},
 }
}

sub run_traced_parser {
 my ($parser, $input_text) = @_;
 my $tmp = tempdir(CLEANUP => 1);
 my $trace_path = File::Spec->catfile($tmp, 'duplicate-slot.trace');
 LinkedSpec::Trace::configure_trace(
  trace_level => 'debug',
  trace_log_file => $trace_path,
  trace_log_mode => 'route',
  trace_reset_log => 1,
  trace_topic_spacing => 0,
 );
 my ($result, $error, $position) = execute_parser($parser, $input_text);
 my $trace = read_text($trace_path);
 LinkedSpec::Trace::configure_trace(
  trace_level => 'none',
  trace_log_file => '',
  trace_log_mode => 'stdout',
 );
 return ($result, $error, $position, $trace)
}

sub role_neutral_fixtures {
 is($contract->{contract_id}, $CONTRACT_ID, 'consumer reads the neutral contract identity');
 is_deeply(
  [map { $_->{id} } @{$contract->{fixtures}}],
  [qw(
   ordered_same_rule_duplicate
   choice_same_rule_duplicate
   repeated_ordered_duplicate
   repeated_non_duplicate_control
   ordered_cross_target_duplicate
  )],
  'consumer locks all five neutral fixtures in authored order',
 );
 is_deeply(
  $contract->{identity}{required_fields},
  [qw(target_rule regex_index)],
  'consumer treats target rule and regex index as structural identity',
 );
}

sub role_live_ordered {
 my ($fixture, $parser) = compile_fixture('ordered_same_rule_duplicate');
 my ($result, $error, $position) = execute_parser($parser, $fixture->{input});
 is($error, '', 'live ordered duplicate execution does not die');
 is($result, $fixture->{expected_result}, 'live ordered duplicate reaches the later slot action');
 is($position, length($fixture->{input}), 'live ordered duplicate consumes both required slots');
}

sub role_live_choice {
 my ($fixture, $parser) = compile_fixture('choice_same_rule_duplicate');
 my ($result, $error, undef, $trace) = run_traced_parser($parser, $fixture->{input});
 is($error, '', 'live duplicate choice execution does not die');
 is($result, $fixture->{expected_result}, 'live single-choice duplicate keeps first-authored action priority');
 like($trace, qr/regex_slot_selected => TAKEN/, 'choice emits the portable slot-selection event');
 like($trace, qr/selection_role=choice/, 'choice trace reports choice role');
 like($trace, qr/target_rule=Top/, 'choice trace reports target rule');
 like($trace, qr/regex_index=0/, 'choice trace reports the first-authored slot index');
}

sub role_repeated_ordered {
 my ($fixture, $parser) = compile_fixture('repeated_ordered_duplicate');
 my ($result, $error, $position) = execute_parser($parser, $fixture->{input});
 is($error, '', 'repeated ordered duplicate execution does not die');
 is_deeply($result, $fixture->{expected_result}, 'each repeated iteration resets to structural slot zero');
 is($position, length($fixture->{input}), 'repeated duplicate consumes both pairs');
}

sub role_repeated_control {
 my ($fixture, $parser) = compile_fixture('repeated_non_duplicate_control');
 my ($result, $error, $position) = execute_parser($parser, $fixture->{input});
 is($error, '', 'repeated non-duplicate control does not die');
 is_deeply($result, $fixture->{expected_result}, 'required-slot matching preserves non-duplicate behavior');
 is($position, length($fixture->{input}), 'non-duplicate control consumes both pairs');
}

sub role_cross_target {
 my ($fixture, $parser) = compile_fixture('ordered_cross_target_duplicate');
 my ($result, $error, $position) = execute_parser($parser, $fixture->{input});
 is($error, '', 'cross-target duplicate execution does not die');
 is($result, $fixture->{expected_result}, 'cross-target sequence reaches the second target action');
 is($position, length($fixture->{input}), 'cross-target sequence consumes both structural slots');
}

sub role_loaded {
 my $fixture = $fixture_by_id{ordered_same_rule_duplicate};
 my ($fh, $path) = tempfile(SUFFIX => '.spec');
 print {$fh} $fixture->{source} or die "cannot write $path: $!";
 close $fh or die "cannot close $path: $!";
 my $parser = LinkedSpec::get_parser($path);
 ok(ref($parser) eq 'CODE', 'loaded-spec route returns a parser');
 my ($result, $error, $position) = execute_parser($parser, $fixture->{input});
 is($error, '', 'loaded-spec ordered duplicate execution does not die');
 is($result, $fixture->{expected_result}, 'loaded-spec route preserves later-slot identity');
 is($position, length($fixture->{input}), 'loaded-spec route preserves consume cursor');
}

sub role_descriptor {
 my $fixture = $fixture_by_id{ordered_same_rule_duplicate};
 my $source = $fixture->{source};
 my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
 ok(ref($descriptor) eq 'HASH', 'descriptor route compiles');
 is(
  $descriptor->{meta}{regex_slot_identity_contract},
  $CONTRACT_ID,
  'descriptor publishes the duplicate-slot identity contract',
 );
 is_deeply(
  $descriptor->{spec}{Top}{dependency_refs},
  [{label => 'Top', idx => 0}, {label => 'Top', idx => 1}],
  'descriptor retains both same-pattern structural rows',
 );
 is(scalar(@{$descriptor->{spec}{Top}{re}}), 2, 'descriptor retains two compiled regex slots');
 is_deeply(
  [map { [$_->{target}, $_->{regex_index}] } @{$descriptor->{spec}{Top}{meta}{resolved_edges}}],
  [['Top', 0], ['Top', 1]],
  'resolved action edges retain target and regex-index identity',
 );
}

sub role_emitted_source {
 my $fixture = $fixture_by_id{ordered_same_rule_duplicate};
 my $source = $fixture->{source};
 $generated_source = LinkedSpec::emit_generated_source(
  \$source,
  source_identity => 'duplicate-regex-slot/perl-admission.spec',
 );
 ok(defined($generated_source) && length($generated_source), 'public emitter returns generated source');
 like($generated_source, qr/contract_id: linkedspec-generated-source-v2/, 'emitted source remains generated-source v2');
 like($generated_source, qr/format_version: 2/, 'emitted source remains format 2');
 like($generated_source, qr/LinkedRE::match_slot\(/, 'emitted ordered handler matches its required slot directly');
 like($generated_source, qr/LinkedRE::assert_slot_identity\(/, 'emitted ordered handler enforces slot identity');
 like($generated_source, qr/branch => 'regex_slot_selected'/, 'emitted handler owns portable slot-selection trace');
 unlike($generated_source, qr/\{\s*label\s*=>[^}]*regex_index/s, 'generated plan is not widened with regex identity');
}

sub role_generated_direct {
 $generated_module = load_generated_source($generated_source);
 my $fixture = $fixture_by_id{ordered_same_rule_duplicate};
 my ($result, $error, $position) = execute_parser($generated_module->{execute}, $fixture->{input});
 is($error, '', 'standalone generated execution does not die');
 is($result, $fixture->{expected_result}, 'standalone generated execution preserves later-slot identity');
 is($position, length($fixture->{input}), 'standalone generated execution preserves consume cursor');
 is_deeply(
  $generated_module->{plan}->(),
  [{label => 'Top', family => 'and_acode_seq'}],
  'generated v2 plan remains the minimal label/family row',
 );
 is(
  $generated_module->{metadata}->()->{contract_id},
  'linkedspec-generated-source-v2',
  'generated metadata preserves the v2 contract',
 );
}

sub role_generated_trace {
 my $fixture = $fixture_by_id{ordered_same_rule_duplicate};
 my $tmp = tempdir(CLEANUP => 1);
 my $trace_path = File::Spec->catfile($tmp, 'generated-duplicate-slot.trace');
 my $input = $fixture->{input};
 my $result = $generated_module->{execute_with_trace}->(
  \$input,
  {
   trace_level => 'debug',
   trace_log_file => $trace_path,
   trace_log_mode => 'route',
   trace_reset_log => 1,
   trace_topic_spacing => 0,
  },
 );
 is($result, $fixture->{expected_result}, 'generated traced execution preserves direct result');
 my $trace = read_text($trace_path);
 like($trace, qr/regex_slot_selected => TAKEN/, 'generated trace emits slot-selection event');
 like($trace, qr/selection_role=ordered_required/, 'generated trace reports ordered-required role');
 like($trace, qr/target_rule=Top/, 'generated trace reports target rule');
 like($trace, qr/regex_index=0.*regex_slot_selected => TAKEN.*regex_index=1/s, 'generated trace reports both ordered slot indices');
 LinkedSpec::Trace::configure_trace(trace_level => 'none', trace_log_file => '', trace_log_mode => 'stdout');
}

sub role_invalid_identity_diagnostics {
 my $capture_input = 'ab';
 my $capture_info = LinkedRE::match_slot(
  \$capture_input, qr/(?<first>a)(b)/, 0, 'Top', 'Top', 0, 'consume', undef,
 );
 is($capture_info->{match}, 'ab', 'required-slot matcher snapshots the whole match');
 is_deeply($capture_info->{match_list}, ['a', 'b'], 'required-slot matcher snapshots positional captures');
 is_deeply($capture_info->{match_hash}, {first => 'a'}, 'required-slot matcher snapshots named captures');

 my $input = 'a';
 my $invalid_ok = eval {
  LinkedRE::match_slot(\$input, undef, 0, 'Top', 'Missing', 3, 'consume', undef);
  1;
 };
 my $invalid_error = $@;
 ok(!$invalid_ok, 'invalid compiled slot identity rejects');
 like($invalid_error, qr/^regex_slot_identity_invalid stage=validate_compiled_rule /, 'invalid slot uses portable code and stage');
 like($invalid_error, qr/rule_label=Top target_rule=Missing regex_index=3/, 'invalid slot reports required identity fields');

 my $lost_ok = eval {
  LinkedRE::assert_slot_identity(
   {index => 1, target_rule => 'Top', regex_index => 0},
   'Top', 1, 'Top', 1,
  );
  1;
 };
 my $lost_error = $@;
 ok(!$lost_ok, 'ordered matcher identity mismatch rejects as an invariant');
 like($lost_error, qr/^ordered_regex_slot_identity_lost stage=execute_rule /, 'lost identity uses portable code and stage');
 like(
  $lost_error,
  qr/rule_label=Top target_rule=Top expected_regex_index=1 actual_regex_index=0/,
  'lost identity reports expected and actual slot indices',
 );
}

my @roles = (
 [neutral_fixtures => \&role_neutral_fixtures],
 [live_ordered => \&role_live_ordered],
 [live_choice => \&role_live_choice],
 [repeated_ordered => \&role_repeated_ordered],
 [repeated_control => \&role_repeated_control],
 [cross_target => \&role_cross_target],
 [loaded => \&role_loaded],
 [descriptor => \&role_descriptor],
 [emitted_source => \&role_emitted_source],
 [generated_direct => \&role_generated_direct],
 [generated_trace => \&role_generated_trace],
 [invalid_identity_diagnostics => \&role_invalid_identity_diagnostics],
);

subtest $_->[0] => $_->[1] for @roles;
done_testing();
