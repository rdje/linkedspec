#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Cwd qw(abs_path);
use Encode qw(decode FB_CROAK LEAVE_SRC);
use File::Basename qw(dirname);
use File::Spec;
use JSON::PP qw(decode_json);

my $repo_root = abs_path(File::Spec->catdir(dirname(__FILE__), '..'));
my $contract_path = File::Spec->catfile(
 $repo_root, 'capability_conformance', 'generated_source_contract.json'
);

sub fail {
 my ($message) = @_;
 die "generated-source-contract: ERROR: $message\n";
}

sub read_bytes {
 my ($path) = @_;
 open my $fh, '<:raw', $path or fail("cannot read $path: $!");
 local $/;
 my $bytes = <$fh>;
 close $fh or fail("cannot close $path: $!");
 return $bytes;
}

sub read_json {
 my ($where, $path) = @_;
 my $value = eval { decode_json(read_bytes($path)) };
 fail("invalid JSON in $where: $@") if $@;
 return $value;
}

sub require_object {
 my ($where, $value) = @_;
 fail("$where must be an object") unless ref($value) eq 'HASH';
}

sub require_array {
 my ($where, $value) = @_;
 fail("$where must be an array") unless ref($value) eq 'ARRAY';
}

sub require_string {
 my ($where, $value) = @_;
 fail("$where must be a non-empty string") if !defined($value) || ref($value) || $value eq '';
}

sub require_keys {
 my ($where, $value, $required, $optional) = @_;
 require_object($where, $value);
 my %allowed = map { $_ => 1 } (@$required, @$optional);
 fail("$where has unknown key '$_'") for grep { !$allowed{$_} } keys %$value;
 fail("$where is missing '$_'") for grep { !exists $value->{$_} } @$required;
}

sub require_exact_array {
 my ($where, $value, @expected) = @_;
 require_array($where, $value);
 fail("$where has unexpected values")
  unless join("\0", @$value) eq join("\0", @expected);
}

sub repo_path {
 my ($where, $path) = @_;
 require_string($where, $path);
 fail("$where must be repo-relative: $path")
  if File::Spec->file_name_is_absolute($path) || $path =~ m{(?:^|/)\.\.(?:/|$)|\\};
 my $absolute = File::Spec->catfile($repo_root, split m{/}, $path);
 fail("$where does not exist: $path") unless -e $absolute;
 return $absolute;
}

my $contract = read_json('generated_source_contract.json', $contract_path);
require_keys(
 'contract', $contract,
 [qw(schema_version contract_id task_owner parity_semantics source_contract execution_pipeline generated_plan
     error_contract behavior_cases corpus_proof current_backend_states)],
 []
);
fail('schema_version must be 1') unless $contract->{schema_version} == 1;
fail("unexpected contract_id '$contract->{contract_id}'")
 unless $contract->{contract_id} eq 'linkedspec-generated-source-v1';
fail("unexpected task_owner '$contract->{task_owner}'")
 unless $contract->{task_owner} eq 'FUTURE-PARITY-BACKLOG.3.1';
my $task_path = File::Spec->catfile($repo_root, 'docs', 'tasks', 'FUTURE-PARITY-BACKLOG.md');
my $task_text = decode('UTF-8', read_bytes($task_path), FB_CROAK | LEAVE_SRC);
fail("task owner '$contract->{task_owner}' is not tracked")
 unless $task_text =~ /^- ID: `\Q$contract->{task_owner}\E`/m;

require_keys(
 'parity_semantics', $contract->{parity_semantics},
 [qw(host_api_names host_source_syntax host_source_bytes_identical observable_behavior_identical
     primary_correctness_oracle)], []
);
my %parity_literal = (
 host_api_names => 'idiomatic_capability_equivalent',
 host_source_syntax => 'backend_native',
 primary_correctness_oracle => 'interpreter_manifest',
);
fail("parity_semantics.$_ has an unexpected value")
 for grep { $contract->{parity_semantics}{$_} ne $parity_literal{$_} } keys %parity_literal;
fail('host_source_bytes_identical must be false') if $contract->{parity_semantics}{host_source_bytes_identical};
fail('observable_behavior_identical must be true') unless $contract->{parity_semantics}{observable_behavior_identical};

require_keys(
 'source_contract', $contract->{source_contract},
 [qw(input_model output_model format_version text_model persisted_encoding deterministic_for_same_input
     required_markers entrypoint_roles)], []
);
my %source_literal = (
 input_model => 'compiled_spec_plus_source_identity',
 output_model => 'host_language_source_text',
 text_model => 'unicode_scalar_text',
 persisted_encoding => 'strict_utf8',
);
fail("source_contract.$_ has an unexpected value")
 for grep { $contract->{source_contract}{$_} ne $source_literal{$_} } keys %source_literal;
fail('source_contract.format_version must be 1') unless $contract->{source_contract}{format_version} == 1;
fail('source_contract.deterministic_for_same_input must be true')
 unless $contract->{source_contract}{deterministic_for_same_input};
require_exact_array(
 'source_contract.required_markers', $contract->{source_contract}{required_markers},
 qw(contract_id format_version source_identity)
);
require_exact_array(
 'source_contract.entrypoint_roles', $contract->{source_contract}{entrypoint_roles},
 qw(execute execute_with_trace)
);
require_exact_array(
 'execution_pipeline', $contract->{execution_pipeline},
 qw(parse_spec validate_spec compile_spec emit_source compile_or_load_generated_source validate_generated_plan execute_generated)
);

require_keys(
 'generated_plan', $contract->{generated_plan},
 [qw(row_fields families validation_rules rejection_cases)], []
);
require_exact_array('generated_plan.row_fields', $contract->{generated_plan}{row_fields}, qw(label family));
my @families = qw(default or_acode and_single_acode and_acode_seq and_bcode or_bcode rep_acode rep_bcode rep_and_acode rep_and_bcode);
require_exact_array('generated_plan.families', $contract->{generated_plan}{families}, @families);
require_exact_array(
 'generated_plan.validation_rules', $contract->{generated_plan}{validation_rules},
 qw(exact_rule_count source_rule_order exact_rule_labels exact_rule_families reject_unknown_family_before_execution)
);
my @rejection_ids = qw(row_count_mismatch label_mismatch family_mismatch unknown_family);
my @rejection_codes = qw(generated_plan_row_count_mismatch generated_plan_label_mismatch generated_plan_family_mismatch generated_plan_unknown_family);
require_array('generated_plan.rejection_cases', $contract->{generated_plan}{rejection_cases});
fail('generated_plan.rejection_cases must have four cases')
 unless @{$contract->{generated_plan}{rejection_cases}} == 4;
for my $index (0 .. 3) {
 my $case = $contract->{generated_plan}{rejection_cases}[$index];
 require_keys("generated_plan.rejection_cases[$index]", $case, [qw(id code)], []);
 fail("generated_plan.rejection_cases[$index] has unexpected id/code")
  unless $case->{id} eq $rejection_ids[$index] && $case->{code} eq $rejection_codes[$index];
}

require_keys(
 'error_contract', $contract->{error_contract},
 [qw(type required_fields optional_fields stages codes)], []
);
fail('error_contract.type must be generated_source_error')
 unless $contract->{error_contract}{type} eq 'generated_source_error';
require_exact_array(
 'error_contract.required_fields', $contract->{error_contract}{required_fields},
 qw(type stage code summary source_identity)
);
require_exact_array(
 'error_contract.optional_fields', $contract->{error_contract}{optional_fields},
 qw(rule_label handler_family detail)
);
require_exact_array(
 'error_contract.stages', $contract->{error_contract}{stages},
 qw(emit_source compile_or_load_generated_source validate_generated_plan execute_generated)
);
require_exact_array(
 'error_contract.codes', $contract->{error_contract}{codes},
 qw(generated_source_emit_failed generated_source_compile_failed generated_plan_row_count_mismatch
    generated_plan_label_mismatch generated_plan_family_mismatch generated_plan_unknown_family generated_execution_failed)
);

require_array('behavior_cases', $contract->{behavior_cases});
fail('behavior_cases must not be empty') unless @{$contract->{behavior_cases}};
my %seen_case;
for my $index (0 .. $#{$contract->{behavior_cases}}) {
 my $case = $contract->{behavior_cases}[$index];
 my $where = "behavior_cases[$index]";
 require_keys($where, $case, [qw(id fixture_dir parse_mode top_rule source_identity expect)], []);
 require_string("$where.id", $case->{id});
 fail("duplicate behavior case '$case->{id}'") if $seen_case{$case->{id}}++;
 fail("$where.parse_mode must be seek or consume")
  unless $case->{parse_mode} eq 'seek' || $case->{parse_mode} eq 'consume';
 require_string("$where.top_rule", $case->{top_rule});
 require_string("$where.source_identity", $case->{source_identity});
 my $fixture_dir = repo_path("$where.fixture_dir", $case->{fixture_dir});
 fail("$where.fixture_dir must be a directory") unless -d $fixture_dir;
 for my $file (qw(input.spec input.txt)) {
  my $path = File::Spec->catfile($fixture_dir, $file);
  fail("$where fixture is missing $file") unless -f $path;
  eval { decode('UTF-8', read_bytes($path), FB_CROAK | LEAVE_SRC) };
  fail("$where.$file must be strict UTF-8: $@") if $@;
 }
 require_keys("$where.expect", $case->{expect}, [qw(status result_file trace_event_roles)], []);
 fail("$where.expect.status must be ok") unless $case->{expect}{status} eq 'ok';
 fail("$where.expect.result_file must be expected.json")
  unless $case->{expect}{result_file} eq 'expected.json';
 my $expected_path = File::Spec->catfile($fixture_dir, $case->{expect}{result_file});
 fail("$where expected JSON is missing") unless -f $expected_path;
 read_json("$where expected result", $expected_path);
 require_exact_array(
  "$where.expect.trace_event_roles", $case->{expect}{trace_event_roles},
  qw(generated_rule_enter generated_family_decision generated_rule_exit)
 );
}

require_keys(
 'corpus_proof', $contract->{corpus_proof},
 [qw(interpreter_manifest interpreter_case_count proof_order accepted_subset rust_breadth_target
     rust_full_manifest_test new_backend_admission_target)], []
);
my $manifest_path = repo_path('corpus_proof.interpreter_manifest', $contract->{corpus_proof}{interpreter_manifest});
my $manifest = read_json('interpreter manifest', $manifest_path);
require_keys('interpreter manifest', $manifest, [qw(format case_count cases)], [qw(generated_by)]);
fail('interpreter manifest format must be 1') unless $manifest->{format} == 1;
fail('interpreter_case_count must be 105') unless $contract->{corpus_proof}{interpreter_case_count} == 105;
fail('interpreter manifest case_count does not match the contract')
 unless $manifest->{case_count} == $contract->{corpus_proof}{interpreter_case_count};
require_array('interpreter manifest cases', $manifest->{cases});
fail('interpreter manifest case_count does not match cases') unless $manifest->{case_count} == @{$manifest->{cases}};
require_exact_array(
 'corpus_proof.proof_order', $contract->{corpus_proof}{proof_order},
 qw(interpreter_exact_result emit_source independent_compile_or_load generated_exact_result)
);
my @subset = qw(proof_edge_array_literal proof_edge_scalar_literal autoexist_array_bare_arg
 terse_1_5_2_primitive_literals terse_2_2_3_attached_if_blocks terse_4_3_2_user_function_runtime
 tclite_command_subst portmap_bare);
require_exact_array('corpus_proof.accepted_subset', $contract->{corpus_proof}{accepted_subset}, @subset);
my %manifest_case = map { $_ => 1 } @{$manifest->{cases}};
fail("accepted subset case '$_' is absent from the interpreter manifest") for grep { !$manifest_case{$_} } @subset;
my $rust_full_manifest_test = repo_path(
 'corpus_proof.rust_full_manifest_test', $contract->{corpus_proof}{rust_full_manifest_test}
);
fail('corpus_proof.rust_full_manifest_test must be a regular file') unless -f $rust_full_manifest_test;
my $rust_full_manifest_text = decode('UTF-8', read_bytes($rust_full_manifest_test), FB_CROAK | LEAVE_SRC);
fail('Rust full-manifest test must lock the 105-case count')
 unless $rust_full_manifest_text =~ /FULL_MANIFEST_CASE_COUNT:\s*usize\s*=\s*105\s*;/;
fail('Rust full-manifest test must not be ignored') if $rust_full_manifest_text =~ /^\s*#\[ignore/m;
fail('Rust full-manifest test must unconditionally reject any classified failure')
 unless $rust_full_manifest_text =~ /assert!\(\s*failures\.is_empty\(\)/s;
fail('corpus_proof.rust_breadth_target has an unexpected value')
 unless $contract->{corpus_proof}{rust_breadth_target} eq 'full_interpreter_manifest';
fail('corpus_proof.new_backend_admission_target has an unexpected value')
 unless $contract->{corpus_proof}{new_backend_admission_target} eq 'accepted_subset_plus_all_generated_families';

require_keys('current_backend_states', $contract->{current_backend_states}, [qw(perl rust dart julia)], []);
my %expected_state = (perl => 'pass', rust => 'pass', dart => 'gap', julia => 'gap');
fail("current_backend_states.$_ must be $expected_state{$_}")
 for grep { $contract->{current_backend_states}{$_} ne $expected_state{$_} } keys %expected_state;
my $capability_manifest = read_json(
 'capability manifest', File::Spec->catfile($repo_root, 'capability_conformance', 'manifest.json')
);
my ($row) = grep { ($_->{id} // '') eq 'codegen.generated_parser_source' }
 @{$capability_manifest->{capabilities} || []};
fail('capability manifest is missing codegen.generated_parser_source') unless ref($row) eq 'HASH';
for my $backend (sort keys %expected_state) {
 my $actual = $row->{backends}{$backend}{status};
 fail("capability status for $backend is '$actual', expected '$expected_state{$backend}'")
  unless defined($actual) && $actual eq $expected_state{$backend};
}

printf "generated-source-contract: OK (v1; %d families; %d behavior case; %d/105 subset + strict Rust 105/105; states 58/0/2)\n",
 scalar(@families), scalar(@{$contract->{behavior_cases}}), scalar(@subset);
