#------------------------------------------------------------------------------
# Package: LinkedSpec::Compiler
# Purpose: Compile-pipeline owner for validation, bootstrap parsing, descriptor
#          assembly, and generated parser source orchestration.
#------------------------------------------------------------------------------
package LinkedSpec::Compiler;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();
use LinkedSpec::RuntimeDiagnosticOutput ();

use constant {
 DUMP_NONE   => 0,
 DUMP_LOW    => 100,
 DUMP_MEDIUM => 200,
 DUMP_HIGH   => 300,
 DUMP_DEBUG  => 500,
};

sub _dump_value {
 my ($value) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'Data::Dumper');
  return Data::Dumper::Dumper($value)
 })
}

sub _ored_re {
 my (@regexes) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedRE');
  return LinkedRE::oredRE(@regexes)
 })
}

sub _quote_generated_source_string {
 my ($value) = @_;
 $value = '' unless defined $value;
 $value =~ s/\\/\\\\/g;
 $value =~ s/'/\\'/g;
 return "'$value'"
}

sub _generated_source_identity {
 my ($option, $runtime_ctx) = @_;
 my $identity = (ref($option) eq 'HASH') ? $option->{generated_source_identity} : undef;
 $identity = _call_runtime_ctx('get_runtime_ctx_spec_path', $runtime_ctx)
  unless defined($identity) && length($identity);
 $identity = _call_runtime_ctx('get_runtime_ctx_spec_name', $runtime_ctx)
  unless defined($identity) && length($identity);
 return (defined($identity) && length($identity)) ? $identity : '<inline>'
}

sub _generated_source_family_for_variant {
 my ($variant) = @_;
 my %family = (
  _default => 'default',
  '<none>' => 'default',
  OR_ACODE => 'or_acode',
  AND_SINGLE_ACODE => 'and_single_acode',
  AND_ACODE => 'and_acode_seq',
  AND_BCODE => 'and_bcode',
  OR_BCODE => 'or_bcode',
  REP_ACODE => 'rep_acode',
  REP_BCODE => 'rep_bcode',
  REP_AND_ACODE => 'rep_and_acode',
  REP_AND_BCODE => 'rep_and_bcode',
 );
 return $family{defined($variant) ? $variant : ''} // 'default'
}

sub _generated_source_plan_rows {
 my ($compiled_spec_state) = @_;
 my @rows;
 foreach my $row (@{_call_compiler_state('compiled_spec_state_rule_rows', $compiled_spec_state)}) {
  my ($label, $info) = @$row;
  my $variant = (ref($info) eq 'HASH' && ref($info->{meta}) eq 'HASH')
   ? $info->{meta}{selected_handler_variant}
   : undef;
  push @rows, {
   label => $label,
   family => _generated_source_family_for_variant($variant),
  };
 }
 return \@rows
}

sub _generated_source_plan_literal {
 my ($plan) = @_;
 return "[\n" . join('', map {
  ' { label => ' . _quote_generated_source_string($_->{label})
   . ', family => ' . _quote_generated_source_string($_->{family}) . " },\n"
 } @$plan) . ']'
}

sub _generated_source_preamble {
 my ($source_identity) = @_;
 my $identity_literal = _quote_generated_source_string($source_identity);
 return "# LinkedSpec generated parser source.\n"
  . "# contract_id: linkedspec-generated-source-v1\n"
  . "# format_version: 1\n"
  . "# source_identity: LINKEDSPEC_GENERATED_SOURCE_IDENTITY\n"
  . "no strict;\n"
  . "no warnings 'void';\n"
  . "use re 'eval';\n"
  . "use LinkedSpec::GeneratedSource ();\n"
  . "use LinkedSpec::RuntimeDiagnosticOutput ();\n"
  . "use LinkedSpec::Numeric ();\n"
  . "use LinkedSpec::UnicodeCaseMapping ();\n"
  . "sub _trace_runtime_mark_event { return LinkedSpec::GeneratedSource::trace_mark_event(\@_) }\n"
  . "our \$LINKEDSPEC_GENERATED_SOURCE_CONTRACT = 'linkedspec-generated-source-v1';\n"
  . "our \$LINKEDSPEC_GENERATED_SOURCE_FORMAT = 1;\n"
  . "our \$LINKEDSPEC_GENERATED_SOURCE_IDENTITY = $identity_literal;\n\n"
}

sub _dependency_regex_source_expression {
 my ($compiled_spec_state, $owner_label) = @_;
 my $owner_info = _call_compiler_state('compiled_spec_state_rule_info', $compiled_spec_state, $owner_label);
 return undef unless ref($owner_info) eq 'HASH' && ref($owner_info->{dependency_refs}) eq 'ARRAY';
 my @regex_exprs;
 foreach my $dependency_ref (@{$owner_info->{dependency_refs}}) {
  next unless ref($dependency_ref) eq 'HASH';
  my $dependency_label = $dependency_ref->{label};
  my $dependency_index = $dependency_ref->{idx};
  my $dependency_info = _call_compiler_state(
   'compiled_spec_state_rule_info', $compiled_spec_state, $dependency_label,
  );
  next unless ref($dependency_info) eq 'HASH' && ref($dependency_info->{re}) eq 'ARRAY';
  next unless defined($dependency_index) && exists $dependency_info->{re}[$dependency_index];
  my $pattern_literal = _quote_generated_source_string('' . $dependency_info->{re}[$dependency_index]);
  push @regex_exprs,
   'do { my $linkedspec_pattern = ' . $pattern_literal . '; qr/$linkedspec_pattern/ }';
 }
 return undef unless @regex_exprs;
 return 'LinkedRE::oredRE(' . join(', ', @regex_exprs) . ')'
}

sub _generated_source_postamble {
 my (%args) = @_;
 my $plan_literal = _generated_source_plan_literal($args{plan});
 my $top_rule_literal = _quote_generated_source_string($args{top_rule});
 my $top_family = 'default';
 foreach my $row (@{$args{plan}}) {
  if ($row->{label} eq $args{top_rule}) {
   $top_family = $row->{family};
   last;
  }
 }
 my $top_family_literal = _quote_generated_source_string($top_family);
 return <<"GENERATED_SOURCE_POSTAMBLE";

my \$LINKEDSPEC_GENERATED_EXPECTED_PLAN = $plan_literal;
my \$LINKEDSPEC_GENERATED_ACTIVE_PLAN = LinkedSpec::GeneratedSource::clone_plan(\$LINKEDSPEC_GENERATED_EXPECTED_PLAN);

sub LinkedSpecGeneratedMetadata {
 return {
  contract_id => \$LINKEDSPEC_GENERATED_SOURCE_CONTRACT,
  format_version => \$LINKEDSPEC_GENERATED_SOURCE_FORMAT,
  source_identity => \$LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
  plan => LinkedSpec::GeneratedSource::clone_plan(\$LINKEDSPEC_GENERATED_EXPECTED_PLAN),
 }
}

sub LinkedSpecGeneratedPlan {
 return LinkedSpec::GeneratedSource::clone_plan(\$LINKEDSPEC_GENERATED_EXPECTED_PLAN)
}

sub ValidateGeneratedPlan {
 my (\$plan) = \@_;
 \$plan = \$LINKEDSPEC_GENERATED_ACTIVE_PLAN unless defined \$plan;
 return LinkedSpec::GeneratedSource::validate_plan(
  expected => \$LINKEDSPEC_GENERATED_EXPECTED_PLAN,
  actual => \$plan,
  source_identity => \$LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
 )
}

sub Execute {
 my (\$input_ref, \$invocation_options) = \@_;
 ValidateGeneratedPlan();
 my \$diagnostic_sink = LinkedSpec::RuntimeDiagnosticOutput::validate_invocation_options(
  \$invocation_options,
 );
 my \$sink_slot = LinkedSpec::RuntimeDiagnosticOutput::sink_slot_name();
 my \$control_error_slot = LinkedSpec::RuntimeDiagnosticOutput::control_error_slot_name();
 local \$descr->{\$sink_slot} = \$diagnostic_sink;
 local \$descr->{\$control_error_slot} = undef;
 LinkedSpec::GeneratedSource::trace_role(
  role => 'generated_rule_enter',
  source_identity => \$LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
  rule_label => $top_rule_literal,
  handler_family => $top_family_literal,
 );
 LinkedSpec::GeneratedSource::trace_role(
  role => 'generated_family_decision',
  source_identity => \$LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
  rule_label => $top_rule_literal,
  handler_family => $top_family_literal,
 );
 my (\$result, \$execution_error);
 my \$ok = eval {
  \$result = &{\$descr->{spec}{$top_rule_literal}}(\$descr, \$input_ref);
  1
 };
 \$execution_error = \$@;
 LinkedSpec::GeneratedSource::trace_role(
  role => 'generated_rule_exit',
  source_identity => \$LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
  rule_label => $top_rule_literal,
  handler_family => $top_family_literal,
  status => \$ok ? 'ok' : 'error',
 );
 die \$execution_error
  if !\$ok && LinkedSpec::RuntimeDiagnosticOutput::is_marked_control_error(
   \$descr,
   \$execution_error,
  );
 die LinkedSpec::GeneratedSource::new_error(
  stage => 'execute_generated',
  code => 'generated_execution_failed',
  summary => 'Generated parser execution failed',
  source_identity => \$LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
  rule_label => $top_rule_literal,
  handler_family => $top_family_literal,
  detail => \$execution_error,
 ) unless \$ok;
 return \$result
}

sub ExecuteWithTrace {
 my (\$input_ref, \$trace_config, \$invocation_options) = \@_;
 require LinkedSpec::Trace;
 LinkedSpec::Trace::configure_trace(%\$trace_config) if ref(\$trace_config) eq 'HASH';
 return Execute(\$input_ref, \$invocation_options)
}

sub Get { return Execute(\@_) }
GENERATED_SOURCE_POSTAMBLE
}

my $ACTIVE_DEPENDENCY_REGEX_RULE_LABEL;
my $LAST_BUILD_COMPILED_RULE_TABLE_FAILURE_DETAIL = '';

sub _trace_log_output {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::Trace');
  return LinkedSpec::Trace::log_output(@args)
 })
}

sub _trace_log_dump {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::Trace');
  return LinkedSpec::Trace::log_dump(@args)
 })
}

sub _trace_should_dump {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return 0 unless exists $INC{'LinkedSpec/Trace.pm'};
  return LinkedSpec::Trace::should_dump(@args)
 })
}

sub _trace_enter {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::Trace');
  return LinkedSpec::Trace::trace_enter(@args)
 })
}

sub _trace_exit {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::Trace');
  return LinkedSpec::Trace::trace_exit(@args)
 })
}

sub _trace_decision {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::Trace');
  return LinkedSpec::Trace::trace_decision(@args)
 })
}

sub _trace_apply_trace_options {
 my ($option) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::Trace');
  return LinkedSpec::Trace::_apply_trace_options($option)
 })
}

sub _trace_level_name_for_current_verbosity {
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::Trace');
  return LinkedSpec::Trace::_trace_level_name($LinkedSpec::Trace::DUMP_VERBOSITY)
 })
}

sub _default_bootstrap_parse_cb {
 return LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, 'LinkedSpec::BootstrapSpec', 'run_bootstrap_parse')
}

sub _default_compile_spec_entry_cb {
 return LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, 'LinkedSpec::SpecEntry', 'compile_spec_entry')
}

sub _build_action_rewriter_migration_summary {
 my ($spec_or_state) = @_;
 my $summary = _call_compiler_state('build_action_rewriter_migration_summary', $spec_or_state);

 if (_trace_should_dump(DUMP_DEBUG)) {
 _trace_log_output(
   DUMP_DEBUG,
   "(LinkedSpec::Compiler::_build_action_rewriter_migration_summary) summary",
   _dump_value($summary)
  );
 }

 return $summary
}

sub _call_compiler_state {
 my ($subname, @args) = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(__PACKAGE__, 'LinkedSpec::CompilerState', $subname, @args)
}

sub _call_user_function_registry {
 my ($subname, @args) = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(__PACKAGE__, 'LinkedSpec::UserFunctionRegistry', $subname, @args)
}

sub _normalize_compiled_dependency_regex_output {
 my ($value, $compiled_spec_state) = @_;
 return _call_compiler_state(
  'normalize_compiled_dependency_regex_output',
  $value,
  $compiled_spec_state,
  on_invalid => sub {
   return 'final descriptor assembly expects compiled dependency-regex HASH ref or compiled_dependency_regex_state; got '
    . _describe_contract_value_kind($_[0])
  },
 );
}

sub _normalize_compiled_spec_input {
 my ($value) = @_;
 return _call_compiler_state(
  'normalize_compiled_spec_input',
  $value,
  on_invalid => sub {
   return 'build_dependency_regex_map expects a HASH ref of compiled rule info; got '
    . _describe_contract_value_kind($_[0])
  },
 )
}

sub build_compiled_rule_table {
 my ($specretv, $compile_spec_entry, $option) = @_;
 if (ref($compile_spec_entry) eq 'HASH' && !defined($option)) {
  $option = $compile_spec_entry;
  $compile_spec_entry = undef;
 }
 my $runtime_ctx = undef;
 if (ref($option) eq 'HASH') {
  my $top_rule = defined($option->{top_rule}) && length($option->{top_rule})
   ? $option->{top_rule}
   : (ref($specretv) eq 'ARRAY' && @$specretv ? _parsed_rule_label($specretv->[0]) : undef);
  $runtime_ctx = _call_runtime_ctx(
   'prepare_runtime_ctx_for_build_compiled_rule_table',
   $option,
   owner => 'LinkedSpec::Compiler::build_compiled_rule_table',
   top_rule => $top_rule,
  );
 }
 $compile_spec_entry ||= _default_compile_spec_entry_cb();
 $LAST_BUILD_COMPILED_RULE_TABLE_FAILURE_DETAIL = '';
 my $trace_scope = _trace_enter('LinkedSpec::Compiler::build_compiled_rule_table', {
  entry_count => (ref($specretv) eq 'ARRAY') ? scalar(@$specretv) : undef,
 }, DUMP_MEDIUM);

 unless (ref($compile_spec_entry) eq 'CODE') {
  my $detail = 'compile_spec_entry callback must be CODE';
  $LAST_BUILD_COMPILED_RULE_TABLE_FAILURE_DETAIL = $detail;
  _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'build_compiled_rule_table',
   summary => 'Compiled rule-table generation failed',
   detail => $detail,
   handler_source_label => _call_runtime_ctx('build_runtime_ctx_top_rule_handler_source_label', $runtime_ctx),
  ) if ref($runtime_ctx) eq 'HASH';
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", $detail);
  _trace_exit($trace_scope, { status => 'error', stage => 'build_compiled_rule_table' }, DUMP_MEDIUM);
  return undef
 }

 unless (ref($specretv) eq 'ARRAY') {
  my $value_desc = !defined($specretv)
   ? 'undef'
   : ref($specretv) ? ref($specretv) : 'SCALAR';
  my $detail = "build_compiled_rule_table expects an ARRAY ref of parsed bootstrap entries; got $value_desc";
  $LAST_BUILD_COMPILED_RULE_TABLE_FAILURE_DETAIL = $detail;
  _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'build_compiled_rule_table',
   summary => 'Compiled rule-table generation failed',
   detail => $detail,
   handler_source_label => _call_runtime_ctx('build_runtime_ctx_top_rule_handler_source_label', $runtime_ctx),
  ) if ref($runtime_ctx) eq 'HASH';
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", $detail);
  _trace_exit($trace_scope, { status => 'error', stage => 'build_compiled_rule_table' }, DUMP_MEDIUM);
  return undef
 }

 my $compiled_state = _call_compiler_state('new_compiled_spec_state');
 my %redefined_seen;
 for (my $entry_idx = 0; $entry_idx < @$specretv; ++$entry_idx) {
  my $entry = $specretv->[$entry_idx];
  unless (ref($entry) eq 'ARRAY') {
   my $value_desc = !defined($entry)
    ? 'undef'
    : ref($entry) ? ref($entry) : 'SCALAR';
   my $detail = "build_compiled_rule_table expects each parsed bootstrap entry to be ARRAY ref; entry[$entry_idx] got $value_desc";
   $LAST_BUILD_COMPILED_RULE_TABLE_FAILURE_DETAIL = $detail;
   _call_runtime_ctx(
    'set_runtime_ctx_last_error_for_owner',
    $runtime_ctx,
    'compiler_pipeline',
    stage => 'build_compiled_rule_table',
    summary => 'Compiled rule-table generation failed',
    detail => $detail,
    handler_source_label => _call_runtime_ctx('build_runtime_ctx_top_rule_handler_source_label', $runtime_ctx),
   ) if ref($runtime_ctx) eq 'HASH';
   _trace_log_output(DUMP_NONE, "CRITICAL ERROR", $detail);
   _trace_exit($trace_scope, { status => 'error', stage => 'build_compiled_rule_table' }, DUMP_MEDIUM);
   return undef
  }
  my $active_rule_label = _parsed_rule_label($entry);
  my $active_handler_source_label = (ref($runtime_ctx) eq 'HASH')
   ? _call_runtime_ctx('build_runtime_ctx_rule_or_top_handler_source_label', $runtime_ctx, $active_rule_label)
   : undef;
  my ($label, $info);
  my $compile_ok = eval {
   ($label, $info) = $compile_spec_entry->($entry);
   1;
  };
  my $compile_error = $@;
  unless ($compile_ok) {
   my $detail = defined($compile_error) && length($compile_error)
    ? $compile_error
    : 'compile_spec_entry died without diagnostic detail';
   $LAST_BUILD_COMPILED_RULE_TABLE_FAILURE_DETAIL = $detail;
   _call_runtime_ctx(
    'set_runtime_ctx_last_error_for_owner',
    $runtime_ctx,
    'compiler_pipeline',
    stage => 'build_compiled_rule_table',
    summary => 'Compiled rule-table generation failed',
    detail => $detail,
    rule_label => $active_rule_label,
    handler_source_label => $active_handler_source_label,
   ) if ref($runtime_ctx) eq 'HASH';
   _trace_log_output(DUMP_NONE, "CRITICAL ERROR", $detail);
   _trace_exit($trace_scope, { status => 'error', stage => 'spec_entry' }, DUMP_MEDIUM);
   return undef
  }
  unless (defined($label) && defined($info) && ref($info) eq 'HASH') {
   my $label_desc = !defined($label)
    ? 'undef'
    : ref($label) ? ref($label) : "'" . $label . "'";
   my $info_desc = !defined($info)
    ? 'undef'
    : ref($info) ? ref($info) : 'SCALAR';
   my $detail = "compile_spec_entry returned invalid descriptor tuple: label=$label_desc, info=$info_desc";
   my $failure_rule_label = defined($label) && !ref($label) && length($label)
    ? $label
    : $active_rule_label;
   $LAST_BUILD_COMPILED_RULE_TABLE_FAILURE_DETAIL = $detail;
   _call_runtime_ctx(
    'set_runtime_ctx_last_error_for_owner',
    $runtime_ctx,
    'compiler_pipeline',
    stage => 'build_compiled_rule_table',
    summary => 'Compiled rule-table generation failed',
    detail => $detail,
    rule_label => $failure_rule_label,
    handler_source_label => _call_runtime_ctx('build_runtime_ctx_rule_or_top_handler_source_label', $runtime_ctx, $failure_rule_label),
   ) if ref($runtime_ctx) eq 'HASH';
   _trace_log_output(DUMP_NONE, "CRITICAL ERROR", $detail);
    _trace_exit($trace_scope, { status => 'error', stage => 'spec_entry' }, DUMP_MEDIUM);
   return undef
  }
  my $is_duplicate = _call_compiler_state('record_compiled_spec_rule', $compiled_state, $label, $info, \%redefined_seen);
  if ($is_duplicate) {
   _trace_log_output(DUMP_LOW, "Duplicate rule detected", "Rule '$label' is defined multiple times - second definition will overwrite the first");
  }
 }

 my $definition_order = _call_compiler_state('compiled_spec_state_definition_order', $compiled_state);
 _trace_log_output(DUMP_LOW, "Compiled spec state", "Number of compiled rule entries: " . scalar(@$definition_order));
 for (my $i = 0; $i < @$definition_order; ++$i) {
  my $record = $definition_order->[$i];
  my $label = $record->{label};
  my $info  = $record->{info};
  _trace_log_output(DUMP_LOW, "Entry $i", "Label: '$label', Type: " . ref($info));
 }

 my @redefined_rules = @{_call_compiler_state('compiled_spec_state_redefined_rule_labels', $compiled_state)};
 _trace_decision('redefined_rule_definitions_present', scalar(@redefined_rules) ? 1 : 0, scalar(@redefined_rules) ? ('redefined_rules=' . join(',', @redefined_rules)) : 'no redefinitions detected', DUMP_MEDIUM);

 if (@redefined_rules) {
  _trace_log_output(DUMP_LOW, "Redefined rules summary", "Rules redefined later in the source: " . join(", ", @redefined_rules));
 }

 my $result = (ref($option) eq 'HASH' && $option->{return_state})
  ? $compiled_state
  : _call_compiler_state('compiled_spec_state_to_legacy_spec', $compiled_state);

 if (_trace_should_dump(DUMP_MEDIUM)) {
  _trace_log_dump("=== GENERATED RULE TABLE DUMP ===\n");
  _trace_log_dump(_dump_value($result));
  _trace_log_dump("=== END GENERATED RULE TABLE DUMP ===\n");
 }
 _trace_exit(
  $trace_scope,
  {
   status => 'ok',
   rule_count => _call_compiler_state('compiled_spec_state_rule_count', $compiled_state),
   result_model => (ref($option) eq 'HASH' && $option->{return_state}) ? 'compiled_spec_state' : 'compiled_rule_table_hash',
  },
  DUMP_MEDIUM
 );
 $LAST_BUILD_COMPILED_RULE_TABLE_FAILURE_DETAIL = '';

 return $result
}

sub build_dependency_regex_map {
 my ($spec_input, $option) = @_;
 my $sg = _normalize_compiled_spec_input($spec_input);
 my $trace_scope = _trace_enter('LinkedSpec::Compiler::build_dependency_regex_map', {
  rule_count => _call_compiler_state('compiled_spec_state_rule_count', $sg),
 }, DUMP_MEDIUM);

 if (_trace_should_dump(DUMP_HIGH)) {
 _trace_log_dump("=== SPEC DEPENDENCY REGEX DUMP ===\n");
  _trace_log_dump(_dump_value($sg));
  _trace_log_dump("=== END SPEC DEPENDENCY REGEX DUMP ===\n");
 }

my %dependency_regex_map;
foreach my $row (@{_call_compiler_state('compiled_spec_state_rule_rows', $sg)}) {
  my ($label, $rule_info) = @$row;
  $ACTIVE_DEPENDENCY_REGEX_RULE_LABEL = $label;
  _die_with_detail("build_dependency_regex_map expects rule '$label' info to be HASH ref; got "
   . _describe_contract_value_kind($rule_info))
   unless ref($rule_info) eq 'HASH';
  my $rule_dependency_refs = $rule_info->{dependency_refs};
  _die_with_detail("build_dependency_regex_map expects rule '$label' dependency_refs to be ARRAY ref; got "
   . _describe_contract_value_kind($rule_dependency_refs))
   unless ref($rule_dependency_refs) eq 'ARRAY';
  my @dependency_regexes;
  for (my $dependency_ref_idx = 0; $dependency_ref_idx < @$rule_dependency_refs; ++$dependency_ref_idx) {
   my $dependency_ref = $rule_dependency_refs->[$dependency_ref_idx];
   _die_with_detail("build_dependency_regex_map expects rule '$label' dependency_refs[$dependency_ref_idx] to be HASH ref; got "
    . _describe_contract_value_kind($dependency_ref))
    unless ref($dependency_ref) eq 'HASH';
   my $dep_label = $dependency_ref->{label};
   _die_with_detail("build_dependency_regex_map expects rule '$label' dependency_refs[$dependency_ref_idx]{label} to be a non-empty scalar; got "
    . _describe_contract_scalar_value($dep_label))
    unless defined($dep_label) && !ref($dep_label) && length($dep_label);
   my $dep_idx = $dependency_ref->{idx};
   _die_with_detail("build_dependency_regex_map expects rule '$label' dependency_refs[$dependency_ref_idx]{idx} to be a non-negative integer; got "
    . _describe_contract_scalar_value($dep_idx))
    unless defined($dep_idx) && !ref($dep_idx) && $dep_idx =~ /\A\d+\z/;
   _die_with_detail("build_dependency_regex_map expects rule '$label' dependency '$dep_label' at index $dep_idx to refer to an existing compiled rule")
   unless _call_compiler_state('compiled_spec_state_has_rule', $sg, $dep_label);
   my $dep_rule = _call_compiler_state('compiled_spec_state_rule_info', $sg, $dep_label);
   _die_with_detail("build_dependency_regex_map expects referenced rule '$dep_label' for rule '$label' to be HASH ref; got "
    . _describe_contract_value_kind($dep_rule))
    unless ref($dep_rule) eq 'HASH';
   my $dep_re = $dep_rule->{re};
   _die_with_detail("build_dependency_regex_map expects referenced rule '$dep_label' regex list for rule '$label' to be ARRAY ref; got "
    . _describe_contract_value_kind($dep_re))
    unless ref($dep_re) eq 'ARRAY';
   if (exists $dep_re->[$dep_idx]) {
    push @dependency_regexes, $dep_re->[$dep_idx]
   } else {
    _trace_decision("build_dependency_regex_map:$label", 0, "missing regex mapping for label=$dep_label idx=$dep_idx", DUMP_HIGH);
    my $error_msg = "Rule '$label': Referenced rule '$dep_label' has no regex at index $dep_idx";
    my $context = "Referenced rule: $dep_label, Requested index: $dep_idx, Available indices: " .
                  (defined $dep_re ? "0.." . ($#$dep_re) : "none");
    _trace_log_output(DUMP_NONE, $error_msg, $context);
    if (_trace_should_dump(DUMP_HIGH)) {
     _trace_log_dump("=== DEPENDENCY REGEX ERROR CONTEXT ===\n");
     _trace_log_dump("label: $label\n");
     _trace_log_dump("dependency_ref: "._dump_value($dependency_ref)."\n");
     _trace_log_dump("sg: "._dump_value($sg)."\n");
     _trace_log_dump("dependency_regexes: "._dump_value(\@dependency_regexes)."\n");
     _trace_log_dump("=== END DEPENDENCY REGEX ERROR CONTEXT ===\n");
    }
    # exit 1
   }
  }

  if (@dependency_regexes) {
   _trace_decision("build_dependency_regex_map:$label", 1, 'resolved at least one regex dependency', DUMP_DEBUG);
   $dependency_regex_map{$label} = _ored_re(@dependency_regexes);
  }
  else {
   _trace_decision("build_dependency_regex_map:$label", 0, 'no resolvable regex dependencies for this label', DUMP_DEBUG);
  }
}

 my $dependency_regex_map = \%dependency_regex_map;
 my $result = (ref($option) eq 'HASH' && $option->{return_state})
  ? _call_compiler_state(
     'new_compiled_dependency_regex_state',
     compiled_spec_state => $sg,
     compiled_dependency_regex_by_label => $dependency_regex_map,
    )
  : $dependency_regex_map;
 $ACTIVE_DEPENDENCY_REGEX_RULE_LABEL = undef;

if (_trace_should_dump(DUMP_MEDIUM)) {
  _trace_log_dump("=== GENERATED DEPENDENCY REGEX DUMP ===\n");
  _trace_log_dump(_dump_value($result));
  _trace_log_dump("=== END GENERATED DEPENDENCY REGEX DUMP ===\n");
 }
 _trace_exit($trace_scope, {
   status => 'ok',
   compiled_labels => scalar(keys %$dependency_regex_map),
   result_model => (ref($option) eq 'HASH' && $option->{return_state}) ? 'compiled_dependency_regex_state' : 'dependency_regex_map_hash',
  }, DUMP_MEDIUM);
 return $result
}

sub _build_final_descriptor_state {
 my ($compiled_spec_input, $dependency_regex_builder_cb, %args) = @_;
 my $compiled_state = _normalize_compiled_spec_input($compiled_spec_input);
 my $use_default_dependency_regex_builder = !defined($dependency_regex_builder_cb);
 $dependency_regex_builder_cb ||= \&build_dependency_regex_map;
 my $legacy_spec = $use_default_dependency_regex_builder ? undef : _call_compiler_state('compiled_spec_state_to_legacy_spec', $compiled_state);
 my $compiled_dependency_regex_input = $use_default_dependency_regex_builder
  ? $dependency_regex_builder_cb->($compiled_state, { return_state => 1 })
  : $dependency_regex_builder_cb->($legacy_spec);
 my $compiled_dependency_regex_state = _normalize_compiled_dependency_regex_output($compiled_dependency_regex_input, $compiled_state);

 my $compiled_state_meta = _call_compiler_state(
  'build_compiled_descriptor_meta',
  $compiled_state,
  parse_mode => $args{parse_mode},
  action_rewriter_migration => _build_action_rewriter_migration_summary($compiled_state),
 );

 return _call_compiler_state(
  'new_compiled_descriptor_state',
  compiled_spec_state => $compiled_state,
  compiled_dependency_regex_state => $compiled_dependency_regex_state,
  meta => $compiled_state_meta,
 );
}

sub _normalize_parse_mode {
 my ($parse_mode) = @_;
 return 'seek' unless defined($parse_mode) && length($parse_mode);
 return $parse_mode if $parse_mode eq 'seek' || $parse_mode eq 'consume';
 die "(LinkedSpec::Compiler::_normalize_parse_mode) -E- option 'parse_mode' must be 'seek' or 'consume'"
}

sub _require_runtime_ctx {
 my ($deps) = @_;
 my $runtime_ctx = (ref($deps) eq 'HASH') ? $deps->{runtime_ctx} : undef;
 die "(LinkedSpec::Compiler::_require_dep) -E- missing dependency 'runtime_ctx'"
  unless defined $runtime_ctx;
 die "(LinkedSpec::Compiler::_require_runtime_ctx) -E- dependency 'runtime_ctx' must be HASH ref"
  unless ref($runtime_ctx) eq 'HASH';
 return _call_runtime_ctx('prepare_runtime_ctx_for_run_get_pipeline', $runtime_ctx)
}

sub _call_runtime_ctx {
 my ($subname, @args) = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(__PACKAGE__, 'LinkedSpec::RuntimeContext', $subname, @args)
}

sub _parsed_rule_label {
 my ($parsed_entry) = @_;
 return undef unless ref($parsed_entry) eq 'ARRAY';
 foreach my $centry (@$parsed_entry) {
  next unless ref($centry) eq 'ARRAY';
  next unless defined($centry->[0]) && $centry->[0] =~ /ELABEL/o;
  return $centry->[1] if defined($centry->[1]) && length($centry->[1]);
 }
 return undef
}

sub _describe_contract_value_kind {
 my ($value) = @_;

 return 'undef' unless defined($value);
 return ref($value) ? ref($value) : 'SCALAR';
}

sub _describe_contract_scalar_value {
 my ($value) = @_;

 return 'undef' unless defined($value);
 return ref($value) ? ref($value) : "'" . $value . "'";
}

sub _die_with_detail {
 my ($detail) = @_;

 die((defined($detail) ? $detail : '') . "\n");
}

#------------------------------------------------------------------------------
# Function: run_get_pipeline
# Purpose : Execute the full `.spec` compile/generate pipeline used by
#           `LinkedSpec::Get`, with explicit injected bootstrap/runtime state.
# Args    : ($spec_content_ref, $option_hashref, $deps_hashref)
# Returns : parser coderef | descriptor hashref | undef (mode/error dependent)
#------------------------------------------------------------------------------
sub run_get_pipeline {
 my ($spec_content_ref, $option, $deps) = @_;
 $option = {} unless ref($option) eq 'HASH';
 $deps = {} unless ref($deps) eq 'HASH';

 my $runtime_ctx = _require_runtime_ctx($deps);
 _trace_apply_trace_options($option);
 my $parse_only = $option->{parse_only};
 my $generate_only = $option->{generate_only};
 my $return_descriptor = $option->{return_descriptor};
 my $test_expectation = $option->{test_expectation};
 my $dump_parser_source = $option->{dump_parser_source};
 my $parser_source_ref = $option->{parser_source_ref};
 my $requested_top_rule = defined($option->{top_rule}) && length($option->{top_rule})
  ? $option->{top_rule}
  : undef;
 my $parse_mode = defined($option->{parse_mode}) && length($option->{parse_mode})
  ? $option->{parse_mode}
  : 'seek';

 my $trace_scope = _trace_enter('LinkedSpec::Get', {
  parse_only => $parse_only ? 1 : 0,
  generate_only => $generate_only ? 1 : 0,
  return_descriptor => $return_descriptor ? 1 : 0,
  dump_parser_source => $dump_parser_source ? 1 : 0,
  parse_mode => $parse_mode,
  trace_level => _trace_level_name_for_current_verbosity(),
 }, DUMP_LOW);

 _call_runtime_ctx('clear_runtime_ctx_last_error', $runtime_ctx);

 _trace_log_output(DUMP_LOW, "Starting parser generation", "Processing .spec file");

 my $validation_failed = 0;
 my $function_registry;
 my ($bootstrap_parse, $compile_spec_entry);
 my $pipeline_setup_ok = eval {
  $parse_mode = _normalize_parse_mode($option->{parse_mode});
  if (exists $deps->{bootstrap_parse}) {
   $bootstrap_parse = $deps->{bootstrap_parse};
   die "(LinkedSpec::Compiler::_require_dep) -E- missing dependency 'bootstrap_parse'"
    unless defined $bootstrap_parse;
  } else {
   $bootstrap_parse = _default_bootstrap_parse_cb();
  }
  die "(LinkedSpec::Compiler::run_get_pipeline) -E- dependency 'bootstrap_parse' must be CODE"
   unless ref($bootstrap_parse) eq 'CODE';
  my $default_compile_spec_entry = _default_compile_spec_entry_cb();
  if (exists $deps->{compile_spec_entry}) {
   $compile_spec_entry = $deps->{compile_spec_entry};
   die "(LinkedSpec::Compiler::_require_dep) -E- missing dependency 'compile_spec_entry'"
    unless defined $compile_spec_entry;
  } else {
   $compile_spec_entry = sub {
    return $default_compile_spec_entry->(
     $_[0],
     {
      runtime_ctx => $runtime_ctx,
      parse_mode => $parse_mode,
      function_registry => $function_registry,
     },
    )
   };
  }
  LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, 'LinkedSpec::Validation', 'validate_spec_content');
  1;
 };
 my $pipeline_setup_error = $@;
 unless ($pipeline_setup_ok) {
 _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'prepare_pipeline',
   summary => 'Compiler pipeline setup failed',
   detail => $pipeline_setup_error,
   handler_source_label => _call_runtime_ctx('build_runtime_ctx_top_rule_handler_source_label', $runtime_ctx),
  );
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Compiler pipeline setup failed");
  _trace_exit($trace_scope, { status => 'error', stage => 'prepare_pipeline' }, DUMP_LOW);
 return undef;
 }

 $function_registry = _call_user_function_registry('empty_function_registry');
 my $compile_spec_content_ref = $spec_content_ref;
 my $function_extract = eval {
  _call_user_function_registry('extract_and_strip_spec_source', $spec_content_ref)
 };
 my $function_extract_error = $@;
 if ($function_extract_error) {
  _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'function_registry',
   summary => 'User function registry build failed',
   detail => $function_extract_error,
   handler_source_label => _call_runtime_ctx('build_runtime_ctx_top_rule_handler_source_label', $runtime_ctx),
  );
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "User function registry build failed");
  _trace_exit($trace_scope, { status => 'error', stage => 'function_registry' }, DUMP_LOW);
  return undef;
 }
 if (ref($function_extract) eq 'HASH') {
  $function_registry = $function_extract->{registry}
   if ref($function_extract->{registry}) eq 'HASH';
  if (defined($function_extract->{stripped_source}) && !ref($function_extract->{stripped_source})) {
   $compile_spec_content_ref = \$function_extract->{stripped_source};
  }
 }

 my %validate_spec_content_failure;
 my $spec_content_valid = eval {
  LinkedSpec::Validation::validate_spec_content(
   $compile_spec_content_ref,
   {
    on_failure => sub {
     %validate_spec_content_failure = @_;
     return 1;
    },
   },
  )
 };
 my $validate_spec_content_error = $@;
 my $validate_spec_content_handler_source_label =
  _call_runtime_ctx('build_runtime_ctx_rule_or_top_handler_source_label', $runtime_ctx, $validate_spec_content_failure{rule_label});
 if ($validate_spec_content_error) {
  _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'validate_spec_content',
   summary => defined($validate_spec_content_failure{summary}) && length($validate_spec_content_failure{summary})
    ? $validate_spec_content_failure{summary}
    : 'Spec content validation failed',
   detail => defined($validate_spec_content_failure{detail}) && length($validate_spec_content_failure{detail})
    ? $validate_spec_content_failure{detail}
    : $validate_spec_content_error,
   rule_label => $validate_spec_content_failure{rule_label},
   handler_source_label => $validate_spec_content_handler_source_label,
  );
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Spec content validation failed - trapped exception during validation");
  _trace_exit($trace_scope, { status => 'error', stage => 'validate_spec_content' }, DUMP_LOW);
  return undef;
 }

 unless ($spec_content_valid) {
  _trace_decision('validate_spec_content', 0, 'Input envelope validation failed', DUMP_HIGH);
  if ($parse_only && $test_expectation eq 'fail') {
   $validation_failed = 1;
   _call_runtime_ctx(
    'set_runtime_ctx_last_error_for_owner',
    $runtime_ctx,
    'compiler_pipeline',
    stage => 'validate_spec_content',
    summary => defined($validate_spec_content_failure{summary}) && length($validate_spec_content_failure{summary})
     ? $validate_spec_content_failure{summary}
     : 'Spec content validation failed',
    detail => defined($validate_spec_content_failure{detail}) && length($validate_spec_content_failure{detail})
     ? $validate_spec_content_failure{detail}
     : 'Input envelope validation failed',
    rule_label => $validate_spec_content_failure{rule_label},
    handler_source_label => $validate_spec_content_handler_source_label,
   );
   _trace_log_output(DUMP_LOW, "Validation failed as expected", "Spec content validation failed - this is expected for this test");
  } else {
   _call_runtime_ctx(
    'set_runtime_ctx_last_error_for_owner',
    $runtime_ctx,
    'compiler_pipeline',
    stage => 'validate_spec_content',
    summary => defined($validate_spec_content_failure{summary}) && length($validate_spec_content_failure{summary})
     ? $validate_spec_content_failure{summary}
     : 'Spec content validation failed',
    detail => defined($validate_spec_content_failure{detail}) && length($validate_spec_content_failure{detail})
     ? $validate_spec_content_failure{detail}
     : 'Input envelope validation failed',
    rule_label => $validate_spec_content_failure{rule_label},
    handler_source_label => $validate_spec_content_handler_source_label,
   );
   _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Spec content validation failed - terminating parser generation");
   _trace_exit($trace_scope, { status => 'error', stage => 'validate_spec_content' }, DUMP_LOW);
   return undef;
  }
 } else {
  _trace_decision('validate_spec_content', 1, 'Input envelope validation passed', DUMP_HIGH);
 }

 unless ($validation_failed) {
  pos($$compile_spec_content_ref) = 0 if ref($compile_spec_content_ref) eq 'SCALAR';
  my %validate_dsl_failure;
  my $dsl_valid = eval {
   LinkedSpec::Validation::validate_dsl_syntax(
    $compile_spec_content_ref,
    {
     on_failure => sub {
      %validate_dsl_failure = @_;
      return 1;
     },
    },
   )
  };
  my $validate_dsl_syntax_error = $@;
  my $validate_dsl_handler_source_label =
   _call_runtime_ctx('build_runtime_ctx_rule_or_top_handler_source_label', $runtime_ctx, $validate_dsl_failure{rule_label});
  if ($validate_dsl_syntax_error) {
   _call_runtime_ctx(
    'set_runtime_ctx_last_error_for_owner',
    $runtime_ctx,
    'compiler_pipeline',
    stage => 'validate_dsl_syntax',
    summary => defined($validate_dsl_failure{summary}) && length($validate_dsl_failure{summary})
     ? $validate_dsl_failure{summary}
     : 'DSL syntax validation failed',
    detail => defined($validate_dsl_failure{detail}) && length($validate_dsl_failure{detail})
     ? $validate_dsl_failure{detail}
     : $validate_dsl_syntax_error,
    rule_label => $validate_dsl_failure{rule_label},
    handler_source_label => $validate_dsl_handler_source_label,
   );
   _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "DSL syntax validation failed - trapped exception during validation");
   _trace_exit($trace_scope, { status => 'error', stage => 'validate_dsl_syntax' }, DUMP_LOW);
   return undef;
  }

  unless ($dsl_valid) {
   _trace_decision('validate_dsl_syntax', 0, 'Rule-level DSL syntax validation failed', DUMP_HIGH);
   if ($parse_only && $test_expectation eq 'fail') {
    $validation_failed = 1;
    _call_runtime_ctx(
     'set_runtime_ctx_last_error_for_owner',
     $runtime_ctx,
     'compiler_pipeline',
     stage => 'validate_dsl_syntax',
     summary => defined($validate_dsl_failure{summary}) && length($validate_dsl_failure{summary})
      ? $validate_dsl_failure{summary}
      : 'DSL syntax validation failed',
     detail => defined($validate_dsl_failure{detail}) && length($validate_dsl_failure{detail})
      ? $validate_dsl_failure{detail}
      : 'Rule-level DSL syntax validation failed',
     rule_label => $validate_dsl_failure{rule_label},
     handler_source_label => $validate_dsl_handler_source_label,
    );
    _trace_log_output(DUMP_LOW, "Validation failed as expected", "DSL syntax validation failed - this is expected for this test");
   } else {
    _call_runtime_ctx(
     'set_runtime_ctx_last_error_for_owner',
     $runtime_ctx,
     'compiler_pipeline',
     stage => 'validate_dsl_syntax',
     summary => defined($validate_dsl_failure{summary}) && length($validate_dsl_failure{summary})
      ? $validate_dsl_failure{summary}
      : 'DSL syntax validation failed',
     detail => defined($validate_dsl_failure{detail}) && length($validate_dsl_failure{detail})
      ? $validate_dsl_failure{detail}
      : 'Rule-level DSL syntax validation failed',
     rule_label => $validate_dsl_failure{rule_label},
     handler_source_label => $validate_dsl_handler_source_label,
    );
    _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "DSL syntax validation failed - terminating parser generation");
    _trace_exit($trace_scope, { status => 'error', stage => 'validate_dsl_syntax' }, DUMP_LOW);
    return undef;
   }
  } else {
   _trace_decision('validate_dsl_syntax', 1, 'Rule-level DSL syntax validation passed', DUMP_HIGH);
  }
 }

 my $retv;
 my $parse_success = 1;

 _trace_log_output(DUMP_LOW, "Starting spec file parsing", "Attempting to parse .spec file content");
 my $parse_error = '';
 pos($$compile_spec_content_ref) = 0 if ref($compile_spec_content_ref) eq 'SCALAR';
 my $bootstrap_parse_eval_ok = eval {
  ($parse_success, $retv, $parse_error) = $bootstrap_parse->($compile_spec_content_ref);
  1;
 };
 my $bootstrap_parse_error = $@;
 unless ($bootstrap_parse_eval_ok) {
 _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'bootstrap_parse',
   summary => 'Spec parsing failed',
   detail => $bootstrap_parse_error,
   handler_source_label => _call_runtime_ctx('build_runtime_ctx_top_rule_handler_source_label', $runtime_ctx),
  );
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Spec parsing failed - trapped exception during bootstrap parse");
  _trace_exit($trace_scope, { status => 'error', stage => 'bootstrap_parse' }, DUMP_LOW);
  return undef;
 }
 unless ($parse_success) {
  _trace_log_output(DUMP_NONE, "SPEC PARSING FAILED", "Hardcoded parser failed with error: $parse_error");
 }

 _trace_decision('bootstrap_spec_parse', $parse_success, $parse_success ? 'Hardcoded parser returned successfully' : 'Hardcoded parser eval failed', DUMP_HIGH);
 if ($parse_success) {
  _trace_log_output(DUMP_LOW, "Spec file parsing successful", "Hardcoded parser completed successfully");
 }

 if (_trace_should_dump(DUMP_MEDIUM) || $parse_only) {
 _trace_log_dump("=== SPEC COMPILE RESULT DUMP ===\n");
  if ($parse_success && defined $retv) {
   _trace_log_dump(_dump_value($retv));
  } else {
   _trace_log_dump("Parse failed - no result available\n");
  }
  _trace_log_dump("=== END SPEC COMPILE RESULT DUMP ===\n");
 }

 unless ($parse_success && ref($retv) eq 'ARRAY' && @$retv) {
  _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'bootstrap_parse',
   summary => 'Spec parsing did not produce a valid intermediate representation',
   detail => do {
    defined($parse_error) && length($parse_error)
     ? $parse_error
     : !$parse_success
      ? 'bootstrap_parse reported failure without parse_error detail'
      : !defined($retv)
       ? 'bootstrap_parse returned undef while reporting parse_success=1'
       : ref($retv) ne 'ARRAY'
        ? "bootstrap_parse returned " . ref($retv) . " while reporting parse_success=1; expected ARRAY"
        : !@$retv
         ? 'bootstrap_parse returned an empty ARRAY while reporting parse_success=1'
         : '';
   },
   handler_source_label => _call_runtime_ctx('build_runtime_ctx_top_rule_handler_source_label', $runtime_ctx),
  );
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Spec parsing did not produce a valid intermediate representation");
  _trace_exit($trace_scope, { status => 'error', stage => 'bootstrap_parse' }, DUMP_LOW);
  return undef;
 }

 if ($parse_only) {
  _trace_log_output(DUMP_LOW, "Parse-only mode", "Stopping after .spec file parsing - no parser generated");
  _trace_exit($trace_scope, { status => 'ok', stage => 'parse_only', parse_only => 1 }, DUMP_LOW);
  return undef;
 }

 _trace_log_output(DUMP_LOW, "Starting parser generation", "Converting parsed spec data into executable parser");
 if ($dump_parser_source) {
  my $source_identity = _generated_source_identity($option, $runtime_ctx);
  _call_runtime_ctx('emit_runtime_ctx_parser_source_line', $runtime_ctx, _generated_source_preamble($source_identity));
  _call_runtime_ctx('emit_runtime_ctx_parser_source_line', $runtime_ctx, "my \$descr = {\n spec => {\n");
 }

my $active_build_compiled_rule_table_rule_label = undef;
$LAST_BUILD_COMPILED_RULE_TABLE_FAILURE_DETAIL = '';
my $compiled_spec_state = eval {
 build_compiled_rule_table($retv, sub {
   my ($entry) = @_;
   $active_build_compiled_rule_table_rule_label = _parsed_rule_label($entry);
   return $compile_spec_entry->($entry)
  }, { return_state => 1 })
};
my $build_compiled_rule_table_error = $@;
 my $active_build_compiled_rule_table_handler_source_label =
  _call_runtime_ctx('build_runtime_ctx_rule_or_top_handler_source_label', $runtime_ctx, $active_build_compiled_rule_table_rule_label);
if ($build_compiled_rule_table_error) {
  _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'build_compiled_rule_table',
   summary => 'Compiled rule-table generation failed',
   detail => $build_compiled_rule_table_error,
   rule_label => $active_build_compiled_rule_table_rule_label,
   handler_source_label => $active_build_compiled_rule_table_handler_source_label,
  );
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Compiled rule-table generation failed - trapped exception while compiling parsed spec entries");
  _trace_exit($trace_scope, { status => 'error', stage => 'build_compiled_rule_table' }, DUMP_LOW);
  return undef;
 }
unless (_call_compiler_state('is_compiled_spec_state', $compiled_spec_state)) {
 _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'build_compiled_rule_table',
   summary => 'Compiled rule-table generation failed',
   detail => do {
    my $detail = $LAST_BUILD_COMPILED_RULE_TABLE_FAILURE_DETAIL;
    defined($detail) && length($detail)
     ? $detail
     : 'Compiled rule-table build failed while compiling parsed spec entries'
   },
   rule_label => $active_build_compiled_rule_table_rule_label,
   handler_source_label => $active_build_compiled_rule_table_handler_source_label,
  );
 _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Compiled rule-table generation failed");
  _trace_exit($trace_scope, { status => 'error', stage => 'build_compiled_rule_table' }, DUMP_LOW);
  return undef;
 }

my $function_registry_valid = eval {
 _call_user_function_registry(
  'validate_registry_against_rule_labels',
  $function_registry,
  _call_compiler_state('compiled_spec_state_compiled_rule_order', $compiled_spec_state),
 );
 _call_compiler_state('set_compiled_spec_function_registry', $compiled_spec_state, $function_registry);
 1;
};
my $function_registry_validation_error = $@;
if ($function_registry_validation_error) {
 _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'function_registry',
   summary => 'User function registry validation failed',
   detail => $function_registry_validation_error,
   handler_source_label => _call_runtime_ctx('build_runtime_ctx_top_rule_handler_source_label', $runtime_ctx),
  );
 _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "User function registry validation failed");
 _trace_exit($trace_scope, { status => 'error', stage => 'function_registry' }, DUMP_LOW);
 return undef;
}
 $ACTIVE_DEPENDENCY_REGEX_RULE_LABEL = undef;
 my $final_descriptor_state = eval { _build_final_descriptor_state($compiled_spec_state, undef, parse_mode => $parse_mode) };
my $build_final_descriptor_error = $@;
my $build_final_descriptor_rule_label = $ACTIVE_DEPENDENCY_REGEX_RULE_LABEL;
 my $build_final_descriptor_handler_source_label =
  _call_runtime_ctx('build_runtime_ctx_rule_or_top_handler_source_label', $runtime_ctx, $build_final_descriptor_rule_label);
$ACTIVE_DEPENDENCY_REGEX_RULE_LABEL = undef;
if ($build_final_descriptor_error) {
  _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'build_final_descriptor',
   summary => 'Final descriptor assembly failed',
   detail => do {
    my $detail = defined($build_final_descriptor_error) ? $build_final_descriptor_error : '';
    $detail =~ s/\n+\z//;
    $detail;
   },
   rule_label => $build_final_descriptor_rule_label,
   handler_source_label => $build_final_descriptor_handler_source_label,
  );
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Final descriptor assembly failed - trapped exception while building dependency-regex/final descriptor state");
  _trace_exit($trace_scope, { status => 'error', stage => 'build_final_descriptor' }, DUMP_LOW);
 return undef;
 }
 unless (_call_compiler_state('is_compiled_descriptor_state', $final_descriptor_state)) {
 _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'build_final_descriptor',
   summary => 'Final descriptor assembly failed',
  detail => 'final descriptor assembly expects a compiled_descriptor_state result; got '
   . _describe_contract_value_kind($final_descriptor_state),
   rule_label => $build_final_descriptor_rule_label,
   handler_source_label => $build_final_descriptor_handler_source_label,
  );
 _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Final descriptor assembly did not produce a valid compiled descriptor state");
 _trace_exit($trace_scope, { status => 'error', stage => 'build_final_descriptor' }, DUMP_LOW);
  return undef;
 }

 my %validate_dependency_regex_failure;
 my $dependency_regex_refs_valid = eval {
  LinkedSpec::Validation::validate_compiled_descriptor_state(
   $final_descriptor_state,
   {
    on_failure => sub {
     %validate_dependency_regex_failure = @_;
     return 1;
    },
   },
  )
 };
my $validate_dependency_regex_references_error = $@;
 my $validate_dependency_regex_handler_source_label =
  _call_runtime_ctx('build_runtime_ctx_rule_or_top_handler_source_label', $runtime_ctx, $validate_dependency_regex_failure{rule_label});
if ($validate_dependency_regex_references_error) {
  _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'validate_dependency_regex_references',
   summary => defined($validate_dependency_regex_failure{summary}) && length($validate_dependency_regex_failure{summary})
    ? $validate_dependency_regex_failure{summary}
    : 'Generated parser validation failed',
   detail => defined($validate_dependency_regex_failure{detail}) && length($validate_dependency_regex_failure{detail})
    ? $validate_dependency_regex_failure{detail}
    : $validate_dependency_regex_references_error,
   rule_label => $validate_dependency_regex_failure{rule_label},
   handler_source_label => $validate_dependency_regex_handler_source_label,
  );
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Generated parser validation failed - trapped exception during generated-descriptor validation");
  _trace_exit($trace_scope, { status => 'error', stage => 'validate_dependency_regex_references' }, DUMP_LOW);
  return undef;
 }

 unless ($dependency_regex_refs_valid) {
  _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   stage => 'validate_dependency_regex_references',
   summary => defined($validate_dependency_regex_failure{summary}) && length($validate_dependency_regex_failure{summary})
    ? $validate_dependency_regex_failure{summary}
    : 'Generated parser validation failed',
   detail => defined($validate_dependency_regex_failure{detail}) && length($validate_dependency_regex_failure{detail})
    ? $validate_dependency_regex_failure{detail}
    : 'validate_dependency_regex_references returned false for the generated descriptor',
   rule_label => $validate_dependency_regex_failure{rule_label},
   handler_source_label => $validate_dependency_regex_handler_source_label,
  );
 _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Generated parser validation failed - terminating parser generation");
 _trace_exit($trace_scope, { status => 'error', stage => 'validate_dependency_regex_references' }, DUMP_LOW);
 return undef;
}
 my $final_descriptor = _call_compiler_state('compiled_descriptor_state_to_legacy_descriptor', $final_descriptor_state);

 my $selected_top_rule =
    defined($requested_top_rule) && length($requested_top_rule) ? $requested_top_rule
  : (ref($retv) eq 'ARRAY' && @$retv ? _parsed_rule_label($retv->[0]) : undef);
 _call_runtime_ctx('set_runtime_ctx_top_rule', $runtime_ctx, $selected_top_rule) if defined($selected_top_rule) && length($selected_top_rule);

 my $rule_count = _call_compiler_state('compiled_spec_state_rule_count', $compiled_spec_state);
 _trace_log_output(DUMP_LOW, "Parser generation completed", "Generated parser with $rule_count rules");
 if ($dump_parser_source) {
  _call_runtime_ctx('emit_runtime_ctx_parser_source_line', $runtime_ctx, " },\n dependency_regex_map => {\n");
  my @glabels = sort keys %{$final_descriptor->{dependency_regex_map} || {}};
  for (my $i = 0; $i < @glabels; ++$i) {
   my $label = $glabels[$i];
   my $gregex = _dependency_regex_source_expression($compiled_spec_state, $label);
   unless (defined $gregex) {
    my $pattern_literal = _quote_generated_source_string(
     '' . $final_descriptor->{dependency_regex_map}{$label},
    );
    $gregex = 'do { my $linkedspec_pattern = ' . $pattern_literal
     . '; qr/$linkedspec_pattern/ }';
   }
   my $prefix = $i ? ",\n" : '';
   _call_runtime_ctx('emit_runtime_ctx_parser_source_line', $runtime_ctx, $prefix . " $label\t=> $gregex");
  }
  my $top_rule = _call_runtime_ctx('get_runtime_ctx_top_rule', $runtime_ctx);
  my $source_identity = _generated_source_identity($option, $runtime_ctx);
  my $plan = _generated_source_plan_rows($compiled_spec_state);
  _call_runtime_ctx('emit_runtime_ctx_parser_source_line', $runtime_ctx, "\n }\n};\n");
  _call_runtime_ctx(
   'emit_runtime_ctx_parser_source_line',
   $runtime_ctx,
   _generated_source_postamble(
    source_identity => $source_identity,
    top_rule => $top_rule,
    plan => $plan,
   ),
  );
  _call_runtime_ctx('flush_runtime_ctx_parser_source', $runtime_ctx, $parser_source_ref);
 }

 if (_trace_should_dump(DUMP_LOW)) {
  my $top_rule = _call_runtime_ctx('get_runtime_ctx_top_rule', $runtime_ctx);
  _trace_log_dump("=== FINAL_DESCRIPTOR DUMP: top_rule=$top_rule ===\n");
  _trace_log_dump(_dump_value($final_descriptor));
  _trace_log_dump("=== END FINAL_DESCRIPTOR DUMP: top_rule=$top_rule ===\n");
 }

 if ($generate_only) {
  _trace_log_output(DUMP_LOW, "Generate-only mode", "Stopping after parser generation - no functional parser returned");
  _trace_exit($trace_scope, { status => 'ok', stage => 'generate_only', generate_only => 1 }, DUMP_LOW);
  return undef;
 }

 if ($return_descriptor) {
  _trace_log_output(DUMP_LOW, "Descriptor-return mode", "Returning generated parser descriptor hash");
  _trace_exit($trace_scope, { status => 'ok', stage => 'return_descriptor', return_descriptor => 1, rule_count => $rule_count }, DUMP_LOW);
  return $final_descriptor;
 }

 _trace_log_output(DUMP_LOW, "Parser generation completed successfully", "Returning functional parser for execution");
 _trace_exit($trace_scope, { status => 'ok', stage => 'parser_ready', top_rule => _call_runtime_ctx('get_runtime_ctx_top_rule', $runtime_ctx), rule_count => $rule_count }, DUMP_LOW);

 my $top_rule = _call_runtime_ctx('get_runtime_ctx_top_rule', $runtime_ctx);
 return sub {
  _call_runtime_ctx('clear_runtime_ctx_last_error', $runtime_ctx);
 my $top_rule_entry = (defined($top_rule) && length($top_rule) && ref($final_descriptor->{spec}{$top_rule}) eq 'HASH')
   ? $final_descriptor->{spec}{$top_rule}
   : undef;
  my $top_rule_meta = (ref($top_rule_entry) eq 'HASH') ? $top_rule_entry->{meta} : undef;
  my $top_handler_variant = (ref($top_rule_meta) eq 'HASH') ? $top_rule_meta->{selected_handler_variant} : undef;
  my $top_handler_source_label = _call_runtime_ctx(
   'build_runtime_ctx_top_rule_handler_source_label',
   $runtime_ctx,
   handler_variant => $top_handler_variant,
  );
  my $handler = (ref($top_rule_entry) eq 'HASH') ? $top_rule_entry->{handler} : undef;
  my $runtime_scope = _trace_enter(
   defined($top_rule) && length($top_rule)
    ? "LinkedSpec::parser_invoke:$top_rule"
    : 'LinkedSpec::parser_invoke:<missing_top_rule>',
   {
    top_rule => $top_rule,
    handler_variant => $top_handler_variant,
    input_ref => ref($_[0]) || '',
   },
   DUMP_HIGH
  );
  if (!defined($top_rule) || !length($top_rule)) {
   my $detail = "No top-level rule label is available for parser invocation";
   _call_runtime_ctx(
    'set_runtime_ctx_last_error_for_owner',
    $runtime_ctx,
    'compiler_pipeline',
    type => 'runtime_parser',
    stage => 'resolve_top_rule_handler',
    summary => 'Top-level parser invocation failed',
    detail => $detail,
   );
   _trace_decision('resolve_top_rule_handler', 0, $detail, DUMP_NONE);
   _trace_exit($runtime_scope, { status => 'error', stage => 'resolve_top_rule_handler', returned_defined => 0, return_ref => '', return_size => undef }, DUMP_HIGH);
   die "$detail\n";
  }
  if (ref($top_rule_entry) ne 'HASH') {
   my $detail = "No compiled descriptor entry found for top-level rule '$top_rule'";
   _call_runtime_ctx(
    'set_runtime_ctx_last_error_for_owner',
    $runtime_ctx,
    'compiler_pipeline',
    type => 'runtime_parser',
    stage => 'resolve_top_rule_handler',
    summary => 'Top-level parser invocation failed',
    detail => $detail,
    rule_label => $top_rule,
    handler_source_label => $top_handler_source_label,
   );
   _trace_decision('resolve_top_rule_handler', 0, $detail, DUMP_NONE);
   _trace_exit($runtime_scope, { status => 'error', stage => 'resolve_top_rule_handler', returned_defined => 0, return_ref => '', return_size => undef }, DUMP_HIGH);
   die "$detail\n";
  }
 if (ref($handler) ne 'CODE') {
  my $detail = "No handler coderef found for top-level rule '$top_rule'";
  _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   type => 'runtime_parser',
    stage => 'resolve_top_rule_handler',
    summary => 'Top-level parser invocation failed',
    detail => $detail,
    rule_label => $top_rule,
    handler_variant => $top_handler_variant,
    handler_source_label => $top_handler_source_label,
   );
  _trace_decision('resolve_top_rule_handler', 0, $detail, DUMP_NONE);
  _trace_exit($runtime_scope, { status => 'error', stage => 'resolve_top_rule_handler', returned_defined => 0, return_ref => '', return_size => undef }, DUMP_HIGH);
  die "$detail\n";
 }
 _trace_decision('resolve_top_rule_handler', 1, "Resolved top-level rule '$top_rule'", DUMP_DEBUG);
 my $input_ref = $_[0];
 if (ref($input_ref) ne 'SCALAR') {
  my $value_desc = !defined($input_ref)
   ? 'undef'
   : ref($input_ref) ? ref($input_ref) : 'SCALAR';
  my $detail = "Top-level parser expects a SCALAR reference input; got $value_desc";
  _call_runtime_ctx(
   'set_runtime_ctx_last_error_for_owner',
   $runtime_ctx,
   'compiler_pipeline',
   type => 'runtime_parser',
   stage => 'validate_input_ref',
   summary => 'Top-level parser invocation failed',
   detail => $detail,
   rule_label => $top_rule,
   handler_variant => $top_handler_variant,
   handler_source_label => $top_handler_source_label,
  );
  _trace_decision('validate_input_ref', 0, $detail, DUMP_NONE);
  _trace_exit($runtime_scope, { status => 'error', stage => 'validate_input_ref', returned_defined => 0, return_ref => '', return_size => undef }, DUMP_HIGH);
  die "$detail\n";
 }
 _trace_decision('validate_input_ref', 1, 'Top-level parser received SCALAR reference input', DUMP_DEBUG);
 my $diagnostic_sink = LinkedSpec::RuntimeDiagnosticOutput::validate_invocation_options($_[1]);
 my $sink_slot = LinkedSpec::RuntimeDiagnosticOutput::sink_slot_name();
 my $control_error_slot = LinkedSpec::RuntimeDiagnosticOutput::control_error_slot_name();
 local $final_descriptor->{$sink_slot} = $diagnostic_sink;
 local $final_descriptor->{$control_error_slot} = undef;

 my $retv;
 my $eval_ok = eval {
  $retv = &$handler($final_descriptor, $input_ref);
  1
 };
  my $eval_error = $@;
  unless ($eval_ok) {
   if (LinkedSpec::RuntimeDiagnosticOutput::is_marked_control_error($final_descriptor, $eval_error)) {
    _trace_decision("invoke_top_rule_control:$top_rule", 1, $eval_error, DUMP_DEBUG);
    _trace_exit($runtime_scope, { status => 'control', stage => 'invoke_top_rule', returned_defined => 0, return_ref => ref($eval_error) || '', return_size => undef }, DUMP_HIGH);
    die $eval_error
   }
   _call_runtime_ctx(
    'set_runtime_ctx_last_error_for_owner',
    $runtime_ctx,
    'compiler_pipeline',
    type => 'runtime_parser',
    stage => 'invoke_top_rule',
    summary => 'Top-level parser invocation failed',
    detail => $eval_error,
    rule_label => $top_rule,
    handler_variant => $top_handler_variant,
    handler_source_label => $top_handler_source_label,
   );
   _trace_decision("invoke_top_rule:$top_rule", 0, $eval_error, DUMP_NONE);
   _trace_exit($runtime_scope, { status => 'error', stage => 'invoke_top_rule', returned_defined => 0, return_ref => '', return_size => undef }, DUMP_HIGH);
   die $eval_error;
  }
  my $invoke_reason = defined($retv) ? 'top-level handler returned defined AST' : 'top-level handler returned undef';
  if (_call_runtime_ctx('has_runtime_ctx_last_error_type', $runtime_ctx, 'runtime_handler')) {
   if (defined($retv)) {
    _call_runtime_ctx('clear_runtime_ctx_last_error', $runtime_ctx);
    $@ = '';
    $invoke_reason = 'top-level handler returned defined AST and cleared stale runtime_handler context';
   } else {
    $@ = _call_runtime_ctx('get_runtime_ctx_last_error_detail', $runtime_ctx);
    $invoke_reason = 'top-level handler returned undef while preserving runtime_handler context';
   }
  }
  _trace_decision("invoke_top_rule:$top_rule", defined($retv) ? 1 : 0, $invoke_reason, defined($retv) ? DUMP_DEBUG : DUMP_LOW);
  _trace_exit(
   $runtime_scope,
   {
    status => 'ok',
    returned_defined => defined($retv) ? 1 : 0,
    return_ref => ref($retv) || '',
    return_size => (ref($retv) eq 'ARRAY') ? scalar(@$retv) : undef,
   },
   DUMP_HIGH
  );
  return $retv
 }
}

1;
