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
 $repo_root, 'capability_conformance', 'native_spec_resolution_contract.json'
);
my $task_path = File::Spec->catfile($repo_root, 'docs', 'tasks', 'FUTURE-PARITY-BACKLOG.md');

sub fail {
 my ($message) = @_;
 die "native-spec-resolution-contract: ERROR: $message\n";
}

sub read_bytes {
 my ($path) = @_;
 open my $fh, '<:raw', $path or fail("cannot read $path: $!");
 local $/;
 my $bytes = <$fh>;
 close $fh or fail("cannot close $path: $!");
 return $bytes;
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
 my ($where, $value, $allow_empty) = @_;
 fail("$where must be a string") if !defined($value) || ref($value);
 fail("$where must not be empty") if !$allow_empty && $value eq '';
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

sub require_fixture_path {
 my ($where, $path) = @_;
 require_string($where, $path, 0);
 fail("$where must use fixture-relative forward-slash paths: '$path'")
  if $path =~ m{(?:^|/)\.\.(?:/|$)} || $path =~ m{^/|\\|//};
}

sub join_fixture_path {
 my ($base, $child) = @_;
 return $child if $child =~ m{^/};
 $base =~ s{/$}{};
 $child =~ s{^/}{};
 return "$base/$child";
}

sub name_is_valid {
 my ($value) = @_;
 return 0 unless length($value) && $value =~ /\S/u;
 return 0 if $value =~ /^\s|\s$/u || $value =~ /\p{Cc}/u;
 return 0 if $value =~ m{^/|\\|//};
 return 0 if grep { $_ eq '.' || $_ eq '..' } split m{/}, $value, -1;
 return 1;
}

sub name_candidates {
 my ($request, $cwd, $roots) = @_;
 my $value = $request->{value};
 my @raw;
 if ($request->{kind} eq 'path') {
  push @raw, [$value =~ m{^/} ? $value : join_fixture_path($cwd, $value), 'path_exact'];
 } else {
  my $spec_file = $value =~ /\.spec\z/ ? $value : "$value.spec";
  push @raw, [join_fixture_path($cwd, $value), 'cwd_exact'];
  push @raw, [join_fixture_path($cwd, $spec_file), 'cwd_spec_suffix'];
  for my $index (0 .. $#$roots) {
   push @raw, [join_fixture_path($roots->[$index], $spec_file), "search_root:$index"];
  }
 }
 my %seen;
 return grep { !$seen{$_->[0]}++ } @raw;
}

my $contract = eval { decode_json(read_bytes($contract_path)) };
fail("invalid JSON: $@") if $@;
require_keys(
 'contract', $contract,
 [qw(schema_version contract_id task_owner request_kinds name_policy candidate_order text_boundary error_contract
     name_validation_cases resolution_cases text_cases pipeline_contract)],
 []
);
fail('schema_version must be 1') unless $contract->{schema_version} == 1;
fail("unexpected contract_id '$contract->{contract_id}'")
 unless $contract->{contract_id} eq 'linkedspec-native-spec-resolution-v1';
fail("unexpected task_owner '$contract->{task_owner}'")
 unless $contract->{task_owner} eq 'FUTURE-PARITY-BACKLOG.1.6.4';
my $task_text = decode('UTF-8', read_bytes($task_path), FB_CROAK | LEAVE_SRC);
fail("task_owner '$contract->{task_owner}' is not tracked")
 unless $task_text =~ /^- ID: `\Q$contract->{task_owner}\E`/m;

require_exact_array('request_kinds', $contract->{request_kinds}, qw(name path));
require_keys('name_policy', $contract->{name_policy}, [qw(form allow_nested_components forbid)], []);
fail('name_policy.form must be relative_forward_slash_identity')
 unless $contract->{name_policy}{form} eq 'relative_forward_slash_identity';
fail('name_policy.allow_nested_components must be true')
 unless $contract->{name_policy}{allow_nested_components};
require_exact_array(
 'name_policy.forbid', $contract->{name_policy}{forbid},
 qw(empty_or_whitespace_only leading_or_trailing_unicode_whitespace unicode_control_characters absolute_paths backslashes empty_components dot_components parent_components)
);
require_keys(
 'candidate_order', $contract->{candidate_order},
 [qw(name path deduplicate search selection non_regular_miss)], []
);
require_exact_array(
 'candidate_order.name', $contract->{candidate_order}{name},
 qw(cwd_exact cwd_spec_suffix search_roots_spec_suffix_in_declared_order)
);
require_exact_array(
 'candidate_order.path', $contract->{candidate_order}{path},
 'absolute_or_cwd_relative_exact'
);
my %candidate_literals = (
 deduplicate => 'preserve_first_lexical_candidate',
 search => 'direct_children_only_no_recursion',
 selection => 'first_regular_file',
 non_regular_miss => 'report_first_existing_non_regular_candidate_if_no_file_matches',
);
for my $key (sort keys %candidate_literals) {
 fail("candidate_order.$key has unexpected value")
  unless $contract->{candidate_order}{$key} eq $candidate_literals{$key};
}

require_keys('text_boundary', $contract->{text_boundary}, [qw(logical_model file_encoding preserve forbid)], []);
fail('logical text model must be Unicode scalar text')
 unless $contract->{text_boundary}{logical_model} eq 'unicode_scalar_text';
fail('file encoding must be strict UTF-8')
 unless $contract->{text_boundary}{file_encoding} eq 'strict_utf8';
require_exact_array(
 'text_boundary.preserve', $contract->{text_boundary}{preserve},
 qw(utf8_bom_as_u+feff code_points normalization_form newlines leading_and_trailing_text)
);
require_exact_array(
 'text_boundary.forbid', $contract->{text_boundary}{forbid},
 qw(replacement_decoding implicit_utf16_transcoding implicit_utf32_transcoding unicode_normalization bom_removal newline_conversion trimming)
);

require_keys(
 'error_contract', $contract->{error_contract},
 [qw(type required_fields optional_fields stages codes)], []
);
fail('error_contract.type must be spec_pipeline_error')
 unless $contract->{error_contract}{type} eq 'spec_pipeline_error';
require_exact_array(
 'error_contract.required_fields', $contract->{error_contract}{required_fields},
 qw(type stage code summary request_kind requested)
);
require_exact_array(
 'error_contract.optional_fields', $contract->{error_contract}{optional_fields},
 qw(resolved_path detail)
);
require_exact_array(
 'error_contract.stages', $contract->{error_contract}{stages},
 qw(validate_spec_name validate_spec_path resolve_spec_path load_spec_content decode_spec_content parse_spec validate_spec compile_spec)
);
require_exact_array(
 'error_contract.codes', $contract->{error_contract}{codes},
 qw(invalid_spec_name invalid_spec_path spec_path_not_found spec_path_not_file spec_read_failed invalid_utf8 spec_parse_failed spec_validation_failed spec_compile_failed)
);
my %stage = map { $_ => 1 } @{$contract->{error_contract}{stages}};
my %code = map { $_ => 1 } @{$contract->{error_contract}{codes}};

my %seen_id;
require_array('name_validation_cases', $contract->{name_validation_cases});
fail('name_validation_cases must not be empty') unless @{$contract->{name_validation_cases}};
for my $index (0 .. $#{$contract->{name_validation_cases}}) {
 my $case = $contract->{name_validation_cases}[$index];
 my $where = "name_validation_cases[$index]";
 require_keys($where, $case, [qw(id value expect)], []);
 require_string("$where.id", $case->{id}, 0);
 fail("duplicate case id '$case->{id}'") if $seen_id{$case->{id}}++;
 require_string("$where.value", $case->{value}, 1);
 require_keys("$where.expect", $case->{expect}, [qw(status)], [qw(stage code)]);
 my $actual = name_is_valid($case->{value}) ? 'ok' : 'error';
 fail("$where expected $case->{expect}{status}, validator produced $actual")
  unless $case->{expect}{status} eq $actual;
 if ($actual eq 'error') {
  fail("$where error must be validate_spec_name/invalid_spec_name")
   unless ($case->{expect}{stage} // '') eq 'validate_spec_name'
   && ($case->{expect}{code} // '') eq 'invalid_spec_name';
 }
}

require_array('resolution_cases', $contract->{resolution_cases});
fail('resolution_cases must not be empty') unless @{$contract->{resolution_cases}};
for my $index (0 .. $#{$contract->{resolution_cases}}) {
 my $case = $contract->{resolution_cases}[$index];
 my $where = "resolution_cases[$index]";
 require_keys($where, $case, [qw(id request cwd search_roots entries expect)], []);
 require_string("$where.id", $case->{id}, 0);
 fail("duplicate case id '$case->{id}'") if $seen_id{$case->{id}}++;
 require_keys("$where.request", $case->{request}, [qw(kind value)], []);
 fail("$where.request.kind must be name or path")
  unless $case->{request}{kind} eq 'name' || $case->{request}{kind} eq 'path';
 require_string("$where.request.value", $case->{request}{value}, 0);
 require_fixture_path("$where.cwd", $case->{cwd});
 require_array("$where.search_roots", $case->{search_roots});
 require_fixture_path("$where.search_roots", $_) for @{$case->{search_roots}};
 require_array("$where.entries", $case->{entries});
 my %entries;
 for my $entry_index (0 .. $#{$case->{entries}}) {
  my $entry = $case->{entries}[$entry_index];
  require_keys("$where.entries[$entry_index]", $entry, [qw(path kind)], []);
  require_fixture_path("$where.entries[$entry_index].path", $entry->{path});
  fail("$where has duplicate entry '$entry->{path}'") if exists $entries{$entry->{path}};
  fail("$where.entries[$entry_index].kind is invalid")
   unless $entry->{kind} eq 'file' || $entry->{kind} eq 'directory' || $entry->{kind} eq 'non_regular';
  $entries{$entry->{path}} = $entry->{kind};
 }
 require_keys("$where.expect", $case->{expect}, [qw(status)], [qw(path origin stage code resolved_path)]);
 my @candidates = name_candidates($case->{request}, $case->{cwd}, $case->{search_roots});
 my ($selected, $origin, $first_non_regular);
 for my $candidate (@candidates) {
  my ($path, $candidate_origin) = @$candidate;
  my $kind = $entries{$path};
  if (defined($kind) && $kind eq 'file') {
   ($selected, $origin) = ($path, $candidate_origin);
   last;
  }
  $first_non_regular //= $path if defined($kind);
 }
 if (defined $selected) {
  fail("$where expected an error but selected '$selected'") unless $case->{expect}{status} eq 'ok';
  fail("$where expected path '$case->{expect}{path}', selected '$selected'")
   unless ($case->{expect}{path} // '') eq $selected;
  fail("$where expected origin '$case->{expect}{origin}', selected '$origin'")
   unless ($case->{expect}{origin} // '') eq $origin;
 } else {
  fail("$where expected success but no file was selected") unless $case->{expect}{status} eq 'error';
  my $expected_code = defined($first_non_regular) ? 'spec_path_not_file' : 'spec_path_not_found';
  fail("$where must report resolve_spec_path/$expected_code")
   unless ($case->{expect}{stage} // '') eq 'resolve_spec_path'
   && ($case->{expect}{code} // '') eq $expected_code;
  if (defined $first_non_regular) {
   fail("$where must report first non-regular candidate '$first_non_regular'")
    unless ($case->{expect}{resolved_path} // '') eq $first_non_regular;
  } else {
   fail("$where must omit resolved_path for a pure miss") if exists $case->{expect}{resolved_path};
  }
 }
}

require_array('text_cases', $contract->{text_cases});
fail('text_cases must not be empty') unless @{$contract->{text_cases}};
for my $index (0 .. $#{$contract->{text_cases}}) {
 my $case = $contract->{text_cases}[$index];
 my $where = "text_cases[$index]";
 require_keys($where, $case, [qw(id bytes_hex expect)], []);
 require_string("$where.id", $case->{id}, 0);
 fail("duplicate case id '$case->{id}'") if $seen_id{$case->{id}}++;
 require_string("$where.bytes_hex", $case->{bytes_hex}, 1);
 fail("$where.bytes_hex must contain complete lowercase hex bytes")
  if $case->{bytes_hex} =~ /[^0-9a-f]/ || length($case->{bytes_hex}) % 2;
 require_keys("$where.expect", $case->{expect}, [qw(status)], [qw(text stage code)]);
 my $bytes = pack('H*', $case->{bytes_hex});
 my $text = eval { decode('UTF-8', $bytes, FB_CROAK | LEAVE_SRC) };
 if (defined $text && !$@) {
  fail("$where expected decoding error") unless $case->{expect}{status} eq 'ok';
  fail("$where decoded text differs") unless ($case->{expect}{text} // '') eq $text;
 } else {
  fail("$where expected valid UTF-8") unless $case->{expect}{status} eq 'error';
  fail("$where must report decode_spec_content/invalid_utf8")
   unless ($case->{expect}{stage} // '') eq 'decode_spec_content'
   && ($case->{expect}{code} // '') eq 'invalid_utf8';
 }
}

require_keys(
 'pipeline_contract', $contract->{pipeline_contract},
 [qw(phase_order success_identity_fields compiled_value)], []
);
require_exact_array(
 'pipeline_contract.phase_order', $contract->{pipeline_contract}{phase_order},
 qw(validate_request resolve_spec_path load_spec_content decode_spec_content parse_spec validate_spec compile_spec)
);
require_exact_array(
 'pipeline_contract.success_identity_fields', $contract->{pipeline_contract}{success_identity_fields},
 qw(request_kind requested resolved_path source_text)
);
fail('pipeline compiled value must remain backend native')
 unless $contract->{pipeline_contract}{compiled_value} eq 'backend_native_compiled_spec';

printf "native-spec-resolution-contract: OK (%d validation, %d resolution, %d text cases)\n",
 scalar(@{$contract->{name_validation_cases}}),
 scalar(@{$contract->{resolution_cases}}),
 scalar(@{$contract->{text_cases}});
