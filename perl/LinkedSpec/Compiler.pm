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

use constant {
 DUMP_NONE   => 0,
 DUMP_LOW    => 100,
 DUMP_MEDIUM => 200,
 DUMP_HIGH   => 300,
 DUMP_DEBUG  => 500,
};

#------------------------------------------------------------------------------
# Function: _require_dep
# Purpose : Fetch one named dependency from the compile-pipeline dependency map.
# Args    : ($deps, $name)
# Returns : dependency value
#------------------------------------------------------------------------------
sub _require_dep {
 my ($deps, $name) = @_;
 my $value = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::Compiler::_require_dep) -E- missing dependency '$name'"
  unless defined $value;
 return $value
}

#------------------------------------------------------------------------------
# Function: _require_pkg
# Purpose : Lazy-load one compile-pipeline owner package through the shared
#           owner-dispatch seam.
# Args    : ($pkg)
# Returns : true on successful require
#------------------------------------------------------------------------------
sub _require_pkg {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg)
}

sub _require_trace_pkg {
 _require_pkg('LinkedSpec::Trace');
 return 1
}

sub _require_data_dumper_pkg {
 _require_pkg('Data::Dumper');
 return 1
}

sub _require_linkedre_pkg {
 _require_pkg('LinkedRE');
 return 1
}

#------------------------------------------------------------------------------
# Function: _call_preserving_err
# Purpose : Preserve caller-visible successful `$@` while executing one compile
#           helper callback.
# Args    : ($cb)
# Returns : callback return value in caller context
#------------------------------------------------------------------------------
sub _call_preserving_err {
 my ($cb) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err($cb)
}

sub _dump_value {
 my ($value) = @_;
 return _call_preserving_err(sub {
  _require_data_dumper_pkg();
  return Data::Dumper::Dumper($value)
 })
}

sub _ored_re {
 my (@regexes) = @_;
 return _call_preserving_err(sub {
  _require_linkedre_pkg();
  return LinkedRE::oredRE(@regexes)
 })
}

my $ACTIVE_SPEC_GDATA_RULE_LABEL;

sub _clear_active_spec_gdata_rule_label {
 $ACTIVE_SPEC_GDATA_RULE_LABEL = undef;
 return undef
}

sub _get_active_spec_gdata_rule_label {
 return $ACTIVE_SPEC_GDATA_RULE_LABEL
}

sub _trace_log_output {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::log_output(@args)
 })
}

sub _trace_log_dump {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::log_dump(@args)
 })
}

sub _trace_should_dump {
 my @args = @_;
 return _call_preserving_err(sub {
  return 0 unless exists $INC{'LinkedSpec/Trace.pm'};
  return LinkedSpec::Trace::should_dump(@args)
 })
}

sub _trace_enter {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::trace_enter(@args)
 })
}

sub _trace_exit {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::trace_exit(@args)
 })
}

sub _trace_decision {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::trace_decision(@args)
 })
}

sub _trace_apply_trace_options {
 my ($option) = @_;
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::_apply_trace_options($option)
 })
}

sub _trace_level_name_for_current_verbosity {
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::_trace_level_name($LinkedSpec::Trace::DUMP_VERBOSITY)
 })
}

sub _default_bootstrap_parse_cb {
 _require_pkg('LinkedSpec::BootstrapSpec') unless LinkedSpec::BootstrapSpec->can('run_bootstrap_parse');
 return \&LinkedSpec::BootstrapSpec::run_bootstrap_parse
}

sub _default_compile_spec_entry_cb {
 _require_pkg('LinkedSpec::SpecEntry') unless LinkedSpec::SpecEntry->can('compile_spec_entry');
 return \&LinkedSpec::SpecEntry::compile_spec_entry
}

sub _require_validation_pkg {
 _require_pkg('LinkedSpec::Validation') unless LinkedSpec::Validation->can('validate_spec_content');
 return 1
}

sub _build_action_rewriter_migration_summary {
 my ($spec_or_state) = @_;

 my $summary = {
 total_rules => 0,
 rules_with_action_rewriter_meta => 0,
 language_agnostic_ready_rule_count => 0,
 language_agnostic_blocked_rule_count => 0,
 language_agnostic_blocker_statement_total_count => 0,
  language_agnostic_blocked_raw_perl_only_rule_count => 0,
  language_agnostic_blocked_unresolved_helper_only_rule_count => 0,
  language_agnostic_blocked_mixed_rule_count => 0,
  language_agnostic_blocked_raw_perl_only_ratio => '0.0000',
  language_agnostic_blocked_unresolved_helper_only_ratio => '0.0000',
  language_agnostic_blocked_mixed_ratio => '0.0000',
  compatibility_surface_rule_count => 0,
  compatibility_surface_ready_rule_count => 0,
  compatibility_surface_statement_total_count => 0,
  language_agnostic_ready_rules => [],
  language_agnostic_blocked_rules => [],
  language_agnostic_blocked_raw_perl_only_rules => [],
  language_agnostic_blocked_unresolved_helper_only_rules => [],
  language_agnostic_blocked_mixed_rules => [],
  compatibility_surface_rules => [],
  compatibility_surface_ready_rules => [],
  compatibility_surface_rules_by_priority => [],
 compatibility_surface_top_rule => undef,
  language_agnostic_blocked_rules_by_priority => [],
  language_agnostic_top_blocked_rule => undef,
 };

 my @rule_rows;
 if (_is_compiled_spec_state($spec_or_state)) {
  my $rules_by_label = _compiled_spec_state_rules_by_label($spec_or_state);
  @rule_rows = map { [$_, $rules_by_label->{$_}] } @{_compiled_spec_state_rule_order($spec_or_state)};
 }
 elsif (ref($spec_or_state) eq 'HASH') {
  @rule_rows = map { [$_, $spec_or_state->{$_}] } sort keys %$spec_or_state;
 }
 else {
  return $summary
 }

 foreach my $row (@rule_rows) {
  my ($rule_name, $rule) = @$row;
  next unless ref($rule) eq 'HASH';
  ++$summary->{total_rules};

  my $rule_meta = $rule->{meta};
  next unless ref($rule_meta) eq 'HASH';
  my $rewriter_meta = $rule_meta->{action_rewriter};
  next unless ref($rewriter_meta) eq 'HASH';

  ++$summary->{rules_with_action_rewriter_meta};

  my $is_ready = $rewriter_meta->{language_agnostic_action_ir_ready} ? 1 : 0;
  my $compatibility_surface_count = $rewriter_meta->{compatibility_surface_count} || 0;
  if ($compatibility_surface_count > 0) {
   my @compatibility_surface_statements = ref($rewriter_meta->{compatibility_surface_statements}) eq 'ARRAY'
    ? @{$rewriter_meta->{compatibility_surface_statements}}
    : ();
   my @compatibility_surface_contract_ids = ref($rewriter_meta->{compatibility_surface_contract_ids}) eq 'ARRAY'
    ? @{$rewriter_meta->{compatibility_surface_contract_ids}}
    : ();
   ++$summary->{compatibility_surface_rule_count};
   push @{$summary->{compatibility_surface_rules}}, {
    rule => $rule_name,
    compatibility_surface_count => $compatibility_surface_count,
    compatibility_surface_statement_count => scalar @compatibility_surface_statements,
    compatibility_surface_statements => \@compatibility_surface_statements,
    compatibility_surface_contract_ids => \@compatibility_surface_contract_ids,
   };
   $summary->{compatibility_surface_statement_total_count} += scalar @compatibility_surface_statements;
   if ($is_ready) {
    ++$summary->{compatibility_surface_ready_rule_count};
    push @{$summary->{compatibility_surface_ready_rules}}, $rule_name;
   }
  }

  if ($is_ready) {
   ++$summary->{language_agnostic_ready_rule_count};
   push @{$summary->{language_agnostic_ready_rules}}, $rule_name;
   next;
  }

  ++$summary->{language_agnostic_blocked_rule_count};
  my $unresolved_helper_count = $rewriter_meta->{unresolved_helper_count} || 0;
  my $raw_perl_dependency_count = $rewriter_meta->{raw_perl_dependency_count} || 0;
  my @blocker_statements = ref($rewriter_meta->{language_agnostic_action_ir_blocker_statements}) eq 'ARRAY'
   ? @{$rewriter_meta->{language_agnostic_action_ir_blocker_statements}}
   : ();
  push @{$summary->{language_agnostic_blocked_rules}}, {
   rule => $rule_name,
   blocker_statement_count => scalar @blocker_statements,
   blocker_statements => \@blocker_statements,
   unresolved_helper_count => $unresolved_helper_count,
   raw_perl_dependency_count => $raw_perl_dependency_count,
  };
  $summary->{language_agnostic_blocker_statement_total_count} += scalar @blocker_statements;

  if ($raw_perl_dependency_count > 0 && $unresolved_helper_count > 0) {
   ++$summary->{language_agnostic_blocked_mixed_rule_count};
   push @{$summary->{language_agnostic_blocked_mixed_rules}}, $rule_name;
  }
  elsif ($raw_perl_dependency_count > 0) {
   ++$summary->{language_agnostic_blocked_raw_perl_only_rule_count};
   push @{$summary->{language_agnostic_blocked_raw_perl_only_rules}}, $rule_name;
  }
  elsif ($unresolved_helper_count > 0) {
   ++$summary->{language_agnostic_blocked_unresolved_helper_only_rule_count};
   push @{$summary->{language_agnostic_blocked_unresolved_helper_only_rules}}, $rule_name;
  }
 }

 my @blocked_by_priority = sort {
  $b->{blocker_statement_count} <=> $a->{blocker_statement_count}
   || $b->{unresolved_helper_count} <=> $a->{unresolved_helper_count}
   || $b->{raw_perl_dependency_count} <=> $a->{raw_perl_dependency_count}
   || $a->{rule} cmp $b->{rule}
 } @{$summary->{language_agnostic_blocked_rules}};
 $summary->{language_agnostic_blocked_rules_by_priority} = [map { $_->{rule} } @blocked_by_priority];
 $summary->{language_agnostic_top_blocked_rule} = @blocked_by_priority ? $blocked_by_priority[0]{rule} : undef;

 my @compatibility_by_priority = sort {
  $b->{compatibility_surface_statement_count} <=> $a->{compatibility_surface_statement_count}
   || $b->{compatibility_surface_count} <=> $a->{compatibility_surface_count}
   || $a->{rule} cmp $b->{rule}
 } @{$summary->{compatibility_surface_rules}};
 $summary->{compatibility_surface_rules_by_priority} = [map { $_->{rule} } @compatibility_by_priority];
 $summary->{compatibility_surface_top_rule} = @compatibility_by_priority ? $compatibility_by_priority[0]{rule} : undef;

 if ($summary->{rules_with_action_rewriter_meta} > 0) {
  $summary->{language_agnostic_ready_ratio} = sprintf(
   '%.4f',
   $summary->{language_agnostic_ready_rule_count} / $summary->{rules_with_action_rewriter_meta}
  );
 } else {
  $summary->{language_agnostic_ready_ratio} = '0.0000';
 }

 if ($summary->{language_agnostic_blocked_rule_count} > 0) {
  $summary->{language_agnostic_blocked_raw_perl_only_ratio} = sprintf(
   '%.4f',
   $summary->{language_agnostic_blocked_raw_perl_only_rule_count} / $summary->{language_agnostic_blocked_rule_count}
  );
  $summary->{language_agnostic_blocked_unresolved_helper_only_ratio} = sprintf(
   '%.4f',
   $summary->{language_agnostic_blocked_unresolved_helper_only_rule_count} / $summary->{language_agnostic_blocked_rule_count}
  );
  $summary->{language_agnostic_blocked_mixed_ratio} = sprintf(
   '%.4f',
   $summary->{language_agnostic_blocked_mixed_rule_count} / $summary->{language_agnostic_blocked_rule_count}
  );
 }

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

sub _new_compiled_spec_state {
 return _call_compiler_state('new_compiled_spec_state', @_)
}

sub _is_compiled_spec_state {
 return _call_compiler_state('is_compiled_spec_state', @_)
}

sub _compiled_spec_state_rule_count {
 return _call_compiler_state('compiled_spec_state_rule_count', @_)
}

sub _compiled_spec_state_rules_by_label {
 return _call_compiler_state('compiled_spec_state_rules_by_label', @_)
}

sub _compiled_spec_state_rule_order {
 return _call_compiler_state('compiled_spec_state_rule_order', @_)
}

sub _compiled_spec_state_definition_order {
 return _call_compiler_state('compiled_spec_state_definition_order', @_)
}

sub _compiled_spec_state_to_legacy_spec {
 return _call_compiler_state('compiled_spec_state_to_legacy_spec', @_)
}

sub _compiled_spec_state_meta {
 return _call_compiler_state('compiled_spec_state_meta', @_)
}

sub _record_compiled_spec_rule {
 return _call_compiler_state('record_compiled_spec_rule', @_)
}

sub _new_compiled_gdata_state {
 return _call_compiler_state('new_compiled_gdata_state', @_)
}

sub _is_compiled_gdata_state {
 return _call_compiler_state('is_compiled_gdata_state', @_)
}

sub _compiled_gdata_state_gdata_by_label {
 return _call_compiler_state('compiled_gdata_state_gdata_by_label', @_)
}

sub _compiled_gdata_state_to_legacy_gdata {
 return _call_compiler_state('compiled_gdata_state_to_legacy_gdata', @_)
}

sub _new_compiled_descriptor_state {
 return _call_compiler_state('new_compiled_descriptor_state', @_)
}

sub _is_compiled_descriptor_state {
 return _call_compiler_state('is_compiled_descriptor_state', @_)
}

sub _compiled_descriptor_state_spec_state {
 return _call_compiler_state('compiled_descriptor_state_spec_state', @_)
}

sub _compiled_descriptor_state_gdata_state {
 return _call_compiler_state('compiled_descriptor_state_gdata_state', @_)
}

sub _compiled_descriptor_state_gdata_by_label {
 return _call_compiler_state('compiled_descriptor_state_gdata_by_label', @_)
}

sub _compiled_descriptor_state_meta {
 return _call_compiler_state('compiled_descriptor_state_meta', @_)
}

sub _compiled_descriptor_state_to_legacy_descr {
 return _call_compiler_state('compiled_descriptor_state_to_legacy_descr', @_)
}

sub _normalize_compiled_spec_input {
 my ($value) = @_;
 return _call_compiler_state(
  'normalize_compiled_spec_input',
  $value,
  on_invalid => sub { return _describe_spec_gdata_spec_result($_[0]) },
 )
}

sub spec_descr {
 my ($specretv, $compile_spec_entry, $option) = @_;
 if (ref($compile_spec_entry) eq 'HASH' && !defined($option)) {
  $option = $compile_spec_entry;
  $compile_spec_entry = undef;
 }
 my $runtime_ctx = _prepare_runtime_ctx_for_spec_descr($specretv, $option);
 $compile_spec_entry ||= _default_compile_spec_entry_cb();
 _clear_last_spec_descr_failure_detail();
 my $trace_scope = _trace_enter('LinkedSpec::Compiler::spec_descr', {
  entry_count => (ref($specretv) eq 'ARRAY') ? scalar(@$specretv) : undef,
 }, DUMP_MEDIUM);

 unless (ref($compile_spec_entry) eq 'CODE') {
  my $detail = 'compile_spec_entry callback must be CODE';
  _set_last_spec_descr_failure_detail($detail);
  _set_runtime_ctx_last_error(
   $runtime_ctx,
   stage => 'spec_descr',
   summary => 'Spec descriptor generation failed',
   detail => $detail,
   handler_source_label => _compiler_top_rule_handler_source_label($runtime_ctx),
  ) if ref($runtime_ctx) eq 'HASH';
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", $detail);
  _trace_exit($trace_scope, { status => 'error', stage => 'spec_descr' }, DUMP_MEDIUM);
  return undef
 }

 unless (ref($specretv) eq 'ARRAY') {
  my $detail = _describe_spec_descr_entries_result($specretv);
  _set_last_spec_descr_failure_detail($detail);
  _set_runtime_ctx_last_error(
   $runtime_ctx,
   stage => 'spec_descr',
   summary => 'Spec descriptor generation failed',
   detail => $detail,
   handler_source_label => _compiler_top_rule_handler_source_label($runtime_ctx),
  ) if ref($runtime_ctx) eq 'HASH';
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", $detail);
  _trace_exit($trace_scope, { status => 'error', stage => 'spec_descr' }, DUMP_MEDIUM);
  return undef
 }

 my $compiled_state = _new_compiled_spec_state();
 my %duplicate_seen;
 for (my $entry_idx = 0; $entry_idx < @$specretv; ++$entry_idx) {
  my $entry = $specretv->[$entry_idx];
  unless (ref($entry) eq 'ARRAY') {
   my $detail = _describe_spec_descr_entry_result($entry, $entry_idx);
   _set_last_spec_descr_failure_detail($detail);
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'spec_descr',
    summary => 'Spec descriptor generation failed',
    detail => $detail,
    handler_source_label => _compiler_top_rule_handler_source_label($runtime_ctx),
   ) if ref($runtime_ctx) eq 'HASH';
   _trace_log_output(DUMP_NONE, "CRITICAL ERROR", $detail);
   _trace_exit($trace_scope, { status => 'error', stage => 'spec_descr' }, DUMP_MEDIUM);
   return undef
  }
  my $active_rule_label = _parsed_rule_label($entry);
  my $active_handler_source_label = (ref($runtime_ctx) eq 'HASH')
   ? _compiler_rule_or_top_handler_source_label($runtime_ctx, $active_rule_label)
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
   _set_last_spec_descr_failure_detail($detail);
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'spec_descr',
    summary => 'Spec descriptor generation failed',
    detail => $detail,
    rule_label => $active_rule_label,
    handler_source_label => $active_handler_source_label,
   ) if ref($runtime_ctx) eq 'HASH';
   _trace_log_output(DUMP_NONE, "CRITICAL ERROR", $detail);
   _trace_exit($trace_scope, { status => 'error', stage => 'spec_entry' }, DUMP_MEDIUM);
   return undef
  }
  unless (defined($label) && defined($info) && ref($info) eq 'HASH') {
   my $detail = _describe_compile_spec_entry_result($label, $info);
   my $failure_rule_label = defined($label) && !ref($label) && length($label)
    ? $label
    : $active_rule_label;
   _set_last_spec_descr_failure_detail($detail);
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'spec_descr',
    summary => 'Spec descriptor generation failed',
    detail => $detail,
    rule_label => $failure_rule_label,
    handler_source_label => _compiler_rule_or_top_handler_source_label($runtime_ctx, $failure_rule_label),
   ) if ref($runtime_ctx) eq 'HASH';
   _trace_log_output(DUMP_NONE, "CRITICAL ERROR", $detail);
    _trace_exit($trace_scope, { status => 'error', stage => 'spec_entry' }, DUMP_MEDIUM);
   return undef
  }
  my $is_duplicate = _record_compiled_spec_rule($compiled_state, $label, $info, \%duplicate_seen);
  if ($is_duplicate) {
   _trace_log_output(DUMP_LOW, "Duplicate rule detected", "Rule '$label' is defined multiple times - second definition will overwrite the first");
  }
 }

 my $definition_order = $compiled_state->{definition_order};
 _trace_log_output(DUMP_LOW, "Compiled spec state", "Number of compiled rule entries: " . scalar(@$definition_order));
 for (my $i = 0; $i < @$definition_order; ++$i) {
  my $record = $definition_order->[$i];
  my $label = $record->{label};
  my $info  = $record->{info};
  _trace_log_output(DUMP_LOW, "Entry $i", "Label: '$label', Type: " . ref($info));
 }

 my @duplicate_rules = @{$compiled_state->{duplicate_rule_labels}};
 _trace_decision('duplicate_rule_definitions_present', scalar(@duplicate_rules) ? 1 : 0, scalar(@duplicate_rules) ? ('duplicate_rules=' . join(',', @duplicate_rules)) : 'no duplicates detected', DUMP_MEDIUM);

 if (@duplicate_rules) {
  _trace_log_output(DUMP_LOW, "Duplicate rules summary", "Rules with multiple definitions: " . join(", ", @duplicate_rules));
 }

 my $result = (ref($option) eq 'HASH' && $option->{return_state})
  ? $compiled_state
  : _compiled_spec_state_to_legacy_spec($compiled_state);

 if (_trace_should_dump(DUMP_MEDIUM)) {
  _trace_log_dump("=== GENERATED SPEC DUMP ===\n");
  _trace_log_dump(_dump_value($result));
  _trace_log_dump("=== END GENERATED SPEC DUMP ===\n");
 }
 _trace_exit(
  $trace_scope,
  {
   status => 'ok',
   rule_count => _compiled_spec_state_rule_count($compiled_state),
   result_model => (ref($option) eq 'HASH' && $option->{return_state}) ? 'compiled_spec_state' : 'legacy_spec_hash',
  },
  DUMP_MEDIUM
 );
 _clear_last_spec_descr_failure_detail();

 return $result
}

sub spec_gdata {
 my ($spec_input, $option) = @_;
 my $sg = _normalize_compiled_spec_input($spec_input);
 my $trace_scope = _trace_enter('LinkedSpec::Compiler::spec_gdata', {
  rule_count => _compiled_spec_state_rule_count($sg),
 }, DUMP_MEDIUM);

 if (_trace_should_dump(DUMP_HIGH)) {
 _trace_log_dump("=== SPEC GDATA DUMP ===\n");
  _trace_log_dump(_dump_value($sg));
  _trace_log_dump("=== END SPEC GDATA DUMP ===\n");
 }

my %gdata;
my $rules_by_label = _compiled_spec_state_rules_by_label($sg);
foreach my $label (@{_compiled_spec_state_rule_order($sg)}) {
  $ACTIVE_SPEC_GDATA_RULE_LABEL = $label;
  my $rule_info = $rules_by_label->{$label};
  _die_with_detail(_describe_spec_gdata_rule_info_result($label, $rule_info))
   unless ref($rule_info) eq 'HASH';
  my $rule_gdata = $rule_info->{gdata};
  _die_with_detail(_describe_spec_gdata_rule_gdata_result($label, $rule_gdata))
   unless ref($rule_gdata) eq 'ARRAY';
  my @lgdata;
  for (my $gde_idx = 0; $gde_idx < @$rule_gdata; ++$gde_idx) {
   my $gde = $rule_gdata->[$gde_idx];
   _die_with_detail(_describe_spec_gdata_dependency_result($label, $gde, $gde_idx))
    unless ref($gde) eq 'HASH';
   my $dep_label = $gde->{label};
   _die_with_detail(_describe_spec_gdata_dependency_label_result($label, $dep_label, $gde_idx))
    unless defined($dep_label) && !ref($dep_label) && length($dep_label);
   my $dep_idx = $gde->{idx};
   _die_with_detail(_describe_spec_gdata_dependency_index_result($label, $dep_idx, $gde_idx))
    unless defined($dep_idx) && !ref($dep_idx) && $dep_idx =~ /\A\d+\z/;
   _die_with_detail(_describe_spec_gdata_dependency_rule_missing($label, $dep_label, $dep_idx))
    unless exists $rules_by_label->{$dep_label};
   my $dep_rule = $rules_by_label->{$dep_label};
   _die_with_detail(_describe_spec_gdata_dependency_rule_info_result($label, $dep_label, $dep_rule))
    unless ref($dep_rule) eq 'HASH';
   my $dep_re = $dep_rule->{re};
   _die_with_detail(_describe_spec_gdata_dependency_re_result($label, $dep_label, $dep_re))
    unless ref($dep_re) eq 'ARRAY';
   if (exists $dep_re->[$dep_idx]) {
    push @lgdata, $dep_re->[$dep_idx]
   } else {
    _trace_decision("spec_gdata:$label", 0, "missing regex mapping for label=$dep_label idx=$dep_idx", DUMP_HIGH);
    my $error_msg = "Rule '$label': Referenced rule '$dep_label' has no regex at index $dep_idx";
    my $context = "Referenced rule: $dep_label, Requested index: $dep_idx, Available indices: " .
                  (defined $dep_re ? "0.." . ($#$dep_re) : "none");
    _trace_log_output(DUMP_NONE, $error_msg, $context);
    if (_trace_should_dump(DUMP_HIGH)) {
     _trace_log_dump("=== GDATA ERROR CONTEXT ===\n");
     _trace_log_dump("label: $label\n");
     _trace_log_dump("gde: "._dump_value($gde)."\n");
     _trace_log_dump("sg: "._dump_value($sg)."\n");
     _trace_log_dump("lgdata: "._dump_value(\@lgdata)."\n");
     _trace_log_dump("=== END GDATA ERROR CONTEXT ===\n");
    }
    # exit 1
   }
  }

  if (@lgdata) {
   _trace_decision("spec_gdata:$label", 1, 'resolved at least one regex dependency', DUMP_DEBUG);
   $gdata{$label} = _ored_re(@lgdata);
  }
  else {
   _trace_decision("spec_gdata:$label", 0, 'no resolvable regex dependencies for this label', DUMP_DEBUG);
  }
}

 my $legacy_gdata = \%gdata;
 my $result = (ref($option) eq 'HASH' && $option->{return_state})
  ? _new_compiled_gdata_state(
     compiled_spec_state => $sg,
     compiled_gdata_by_label => $legacy_gdata,
    )
  : $legacy_gdata;
 _clear_active_spec_gdata_rule_label();

if (_trace_should_dump(DUMP_MEDIUM)) {
  _trace_log_dump("=== GENERATED GDATA DUMP ===\n");
  _trace_log_dump(_dump_value($result));
  _trace_log_dump("=== END GENERATED GDATA DUMP ===\n");
 }
 _trace_exit($trace_scope, {
   status => 'ok',
   compiled_labels => scalar(keys %$legacy_gdata),
   result_model => (ref($option) eq 'HASH' && $option->{return_state}) ? 'compiled_gdata_state' : 'legacy_gdata_hash',
  }, DUMP_MEDIUM);
 return $result
}

sub _normalize_compiled_gdata_output {
 my ($value, $compiled_spec_state) = @_;
 return _call_compiler_state(
  'normalize_compiled_gdata_output',
  $value,
  $compiled_spec_state,
  on_invalid => sub { return _describe_final_descr_gdata_result($_[0]) },
 );
}

sub _build_final_descr_state {
 my ($compiled_spec_input, $spec_gdata_cb, %args) = @_;
 my $compiled_state = _normalize_compiled_spec_input($compiled_spec_input);
 my $use_default_spec_gdata = !defined($spec_gdata_cb);
 $spec_gdata_cb ||= \&spec_gdata;
 my $legacy_spec = $use_default_spec_gdata ? undef : _compiled_spec_state_to_legacy_spec($compiled_state);
 my $compiled_gdata_input = $use_default_spec_gdata
  ? $spec_gdata_cb->($compiled_state, { return_state => 1 })
  : $spec_gdata_cb->($legacy_spec);
 my $compiled_gdata_state = _normalize_compiled_gdata_output($compiled_gdata_input, $compiled_state);

 my $compiled_state_meta = _compiled_spec_state_meta($compiled_state);
 $compiled_state_meta->{parse_mode} = $args{parse_mode} if defined $args{parse_mode};
 $compiled_state_meta->{action_rewriter_migration} = _build_action_rewriter_migration_summary($compiled_state);

 return _new_compiled_descriptor_state(
  compiled_spec_state => $compiled_state,
  compiled_gdata_state => $compiled_gdata_state,
  meta => $compiled_state_meta,
 );
}

sub _build_final_descr {
 my ($compiled_spec_input, $spec_gdata_cb, %args) = @_;
 my $descriptor_state = _build_final_descr_state($compiled_spec_input, $spec_gdata_cb, %args);
 return _compiled_descriptor_state_to_legacy_descr($descriptor_state);
}

sub _normalize_parse_mode {
 my ($parse_mode) = @_;
 return 'seek' unless defined($parse_mode) && length($parse_mode);
 return $parse_mode if $parse_mode eq 'seek' || $parse_mode eq 'consume';
 die "(LinkedSpec::Compiler::_normalize_parse_mode) -E- option 'parse_mode' must be 'seek' or 'consume'"
}

sub _require_runtime_ctx {
 my ($deps) = @_;
 my $runtime_ctx = _require_dep($deps, 'runtime_ctx');
 die "(LinkedSpec::Compiler::_require_runtime_ctx) -E- dependency 'runtime_ctx' must be HASH ref"
  unless ref($runtime_ctx) eq 'HASH';
 return _call_runtime_ctx('prepare_runtime_ctx_for_run_get_pipeline', $runtime_ctx)
}

sub _call_runtime_ctx {
 my ($subname, @args) = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(__PACKAGE__, 'LinkedSpec::RuntimeContext', $subname, @args)
}

sub _emit_runtime_ctx_parser_source_line {
 my ($runtime_ctx, $chunk) = @_;
 return _call_runtime_ctx('emit_runtime_ctx_parser_source_line', $runtime_ctx, $chunk)
}

sub _clear_runtime_ctx_last_error {
 my ($runtime_ctx) = @_;
 return _call_runtime_ctx('clear_runtime_ctx_last_error', $runtime_ctx)
}

sub _get_runtime_ctx_top_rule {
 my ($runtime_ctx) = @_;
 return _call_runtime_ctx('get_runtime_ctx_top_rule', $runtime_ctx)
}

sub _set_runtime_ctx_top_rule {
 my ($runtime_ctx, $top_rule) = @_;
 return _call_runtime_ctx('set_runtime_ctx_top_rule', $runtime_ctx, $top_rule)
}

sub _set_runtime_ctx_last_error {
 my ($runtime_ctx, %args) = @_;
 return _call_runtime_ctx('set_runtime_ctx_last_error_for_owner', $runtime_ctx, 'compiler_pipeline', %args)
}

sub _has_runtime_ctx_last_error_type {
 my ($runtime_ctx, $type) = @_;
 return _call_runtime_ctx('has_runtime_ctx_last_error_type', $runtime_ctx, $type)
}

sub _get_runtime_ctx_last_error_detail {
 my ($runtime_ctx) = @_;
 return _call_runtime_ctx('get_runtime_ctx_last_error_detail', $runtime_ctx)
}

sub _flush_runtime_ctx_parser_source {
 my ($runtime_ctx, $parser_source_ref) = @_;
 return _call_runtime_ctx('flush_runtime_ctx_parser_source', $runtime_ctx, $parser_source_ref)
}

sub _build_generated_handler_source_label {
 my (%args) = @_;
 return _call_runtime_ctx('build_generated_handler_source_label', %args)
}

sub _compiler_top_rule_handler_source_label {
 my ($runtime_ctx) = @_;
 my $top_rule = _get_runtime_ctx_top_rule($runtime_ctx);
 return undef unless defined($top_rule) && length($top_rule);
 return _build_generated_handler_source_label(label => $top_rule)
}

sub _compiler_rule_or_top_handler_source_label {
 my ($runtime_ctx, $rule_label) = @_;
 if (defined($rule_label) && length($rule_label)) {
  return _build_generated_handler_source_label(label => $rule_label)
 }
 return _compiler_top_rule_handler_source_label($runtime_ctx)
}

sub _prepare_runtime_ctx_for_spec_descr {
 my ($specretv, $option) = @_;
 return undef unless ref($option) eq 'HASH' && exists($option->{runtime_ctx_ref});
 my $runtime_ctx_ref = _call_runtime_ctx(
  'normalize_runtime_ctx_ref',
  $option->{runtime_ctx_ref},
  owner => 'LinkedSpec::Compiler::spec_descr',
 );
 my $runtime_ctx = _call_runtime_ctx('ensure_runtime_ctx', $runtime_ctx_ref);
 return undef unless ref($runtime_ctx) eq 'HASH';
 _clear_runtime_ctx_last_error($runtime_ctx);
 _call_runtime_ctx('clear_runtime_ctx_spec_name', $runtime_ctx);
 _call_runtime_ctx('clear_runtime_ctx_spec_path', $runtime_ctx);
 _call_runtime_ctx('clear_runtime_ctx_top_rule', $runtime_ctx);
 my $top_rule = defined($option->{top_rule}) && length($option->{top_rule})
  ? $option->{top_rule}
  : _first_parsed_rule_label($specretv);
 _set_runtime_ctx_top_rule($runtime_ctx, $top_rule)
  if defined($top_rule) && length($top_rule);
 return $runtime_ctx;
}

sub _describe_parser_input_ref {
 my ($input_ref) = @_;
 my $value_desc = !defined($input_ref)
  ? 'undef'
  : ref($input_ref) ? ref($input_ref) : 'SCALAR';
 return "Top-level parser expects a SCALAR reference input; got $value_desc";
}

sub _reset_spec_content_pos {
 my ($spec_content_ref) = @_;
 return unless ref($spec_content_ref) eq 'SCALAR';
 pos($$spec_content_ref) = 0;
 return 0
}

sub _first_parsed_rule_label {
 my ($parsed_spec_entries) = @_;
 return undef unless ref($parsed_spec_entries) eq 'ARRAY' && @$parsed_spec_entries;
 return _parsed_rule_label($parsed_spec_entries->[0])
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

sub _bootstrap_parse_result_detail {
 my ($parse_success, $retv, $parse_error) = @_;

 return $parse_error if defined($parse_error) && length($parse_error);
 return 'bootstrap_parse reported failure without parse_error detail' unless $parse_success;
 return 'bootstrap_parse returned undef while reporting parse_success=1' unless defined($retv);

 my $retv_ref = ref($retv);
 return "bootstrap_parse returned $retv_ref while reporting parse_success=1; expected ARRAY"
  unless $retv_ref eq 'ARRAY';
 return 'bootstrap_parse returned an empty ARRAY while reporting parse_success=1'
  unless @$retv;

 return '';
}

my $LAST_SPEC_DESCR_FAILURE_DETAIL = '';

sub _clear_last_spec_descr_failure_detail {
 $LAST_SPEC_DESCR_FAILURE_DETAIL = '';
 return ''
}

sub _set_last_spec_descr_failure_detail {
 my ($detail) = @_;
 $LAST_SPEC_DESCR_FAILURE_DETAIL = defined($detail) ? $detail : '';
 return $LAST_SPEC_DESCR_FAILURE_DETAIL
}

sub _get_last_spec_descr_failure_detail {
 return $LAST_SPEC_DESCR_FAILURE_DETAIL
}

sub _describe_compile_spec_entry_result {
 my ($label, $info) = @_;

 my $label_desc = !defined($label)
  ? 'undef'
  : ref($label) ? ref($label) : "'" . $label . "'";
 my $info_desc = !defined($info)
  ? 'undef'
  : ref($info) ? ref($info) : 'SCALAR';

 return "compile_spec_entry returned invalid descriptor tuple: label=$label_desc, info=$info_desc";
}

sub _describe_spec_descr_entries_result {
 my ($specretv) = @_;

 my $value_desc = !defined($specretv)
  ? 'undef'
  : ref($specretv) ? ref($specretv) : 'SCALAR';

 return "spec_descr expects an ARRAY ref of parsed bootstrap entries; got $value_desc";
}

sub _describe_spec_descr_entry_result {
 my ($entry, $idx) = @_;

 my $value_desc = !defined($entry)
  ? 'undef'
  : ref($entry) ? ref($entry) : 'SCALAR';
 my $entry_idx = defined($idx) ? $idx : '?';

 return "spec_descr expects each parsed bootstrap entry to be ARRAY ref; entry[$entry_idx] got $value_desc";
}

sub _describe_final_descr_state_result {
 my ($value) = @_;

 return 'final descriptor assembly expects a compiled_descriptor_state result; got '
  . _describe_contract_value_kind($value);
}

sub _describe_contract_value_kind {
 my ($value) = @_;

 return 'undef' unless defined($value);
 return ref($value) ? ref($value) : 'SCALAR';
}

sub _describe_final_descr_gdata_result {
 my ($value) = @_;

 return 'final descriptor assembly expects compiled gdata HASH ref or compiled_gdata_state; got '
  . _describe_contract_value_kind($value);
}

sub _describe_contract_scalar_value {
 my ($value) = @_;

 return 'undef' unless defined($value);
 return ref($value) ? ref($value) : "'" . $value . "'";
}

sub _describe_spec_gdata_spec_result {
 my ($sg) = @_;

 return 'spec_gdata expects a HASH ref of compiled rule info; got ' . _describe_contract_value_kind($sg);
}

sub _describe_spec_gdata_rule_info_result {
 my ($label, $rule_info) = @_;

 return "spec_gdata expects rule '$label' info to be HASH ref; got " . _describe_contract_value_kind($rule_info);
}

sub _describe_spec_gdata_rule_gdata_result {
 my ($label, $rule_gdata) = @_;

 return "spec_gdata expects rule '$label' gdata to be ARRAY ref; got " . _describe_contract_value_kind($rule_gdata);
}

sub _describe_spec_gdata_dependency_result {
 my ($label, $gde, $gde_idx) = @_;

 return "spec_gdata expects rule '$label' gdata[$gde_idx] to be HASH ref; got " . _describe_contract_value_kind($gde);
}

sub _describe_spec_gdata_dependency_label_result {
 my ($label, $dep_label, $gde_idx) = @_;

 return "spec_gdata expects rule '$label' gdata[$gde_idx]{label} to be a non-empty scalar; got " . _describe_contract_scalar_value($dep_label);
}

sub _describe_spec_gdata_dependency_index_result {
 my ($label, $dep_idx, $gde_idx) = @_;

 return "spec_gdata expects rule '$label' gdata[$gde_idx]{idx} to be a non-negative integer; got " . _describe_contract_scalar_value($dep_idx);
}

sub _describe_spec_gdata_dependency_rule_missing {
 my ($label, $dep_label, $dep_idx) = @_;

 return "spec_gdata expects rule '$label' dependency '$dep_label' at index $dep_idx to refer to an existing compiled rule";
}

sub _describe_spec_gdata_dependency_rule_info_result {
 my ($label, $dep_label, $dep_rule) = @_;

 return "spec_gdata expects referenced rule '$dep_label' for rule '$label' to be HASH ref; got " . _describe_contract_value_kind($dep_rule);
}

sub _describe_spec_gdata_dependency_re_result {
 my ($label, $dep_label, $dep_re) = @_;

 return "spec_gdata expects referenced rule '$dep_label' regex list for rule '$label' to be ARRAY ref; got " . _describe_contract_value_kind($dep_re);
}

sub _die_with_detail {
 my ($detail) = @_;

 die((defined($detail) ? $detail : '') . "\n");
}

sub _normalize_error_detail {
 my ($detail) = @_;

 return '' unless defined($detail);
 $detail =~ s/\n+\z//;
 return $detail;
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
 my $return_descr = $option->{return_descr};
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
  return_descr => $return_descr ? 1 : 0,
  dump_parser_source => $dump_parser_source ? 1 : 0,
  parse_mode => $parse_mode,
  trace_level => _trace_level_name_for_current_verbosity(),
 }, DUMP_LOW);

 _clear_runtime_ctx_last_error($runtime_ctx);

 _trace_log_output(DUMP_LOW, "Starting parser generation", "Processing .spec file");

 my $validation_failed = 0;
 my ($bootstrap_parse, $compile_spec_entry);
 my $pipeline_setup_ok = eval {
  $parse_mode = _normalize_parse_mode($option->{parse_mode});
  $bootstrap_parse = exists $deps->{bootstrap_parse}
   ? _require_dep($deps, 'bootstrap_parse')
   : _default_bootstrap_parse_cb();
  die "(LinkedSpec::Compiler::run_get_pipeline) -E- dependency 'bootstrap_parse' must be CODE"
   unless ref($bootstrap_parse) eq 'CODE';
  my $default_compile_spec_entry = _default_compile_spec_entry_cb();
  $compile_spec_entry = exists $deps->{compile_spec_entry}
   ? _require_dep($deps, 'compile_spec_entry')
   : sub { return $default_compile_spec_entry->($_[0], { runtime_ctx => $runtime_ctx, parse_mode => $parse_mode }) };
  _require_validation_pkg();
  1;
 };
 my $pipeline_setup_error = $@;
 unless ($pipeline_setup_ok) {
 _set_runtime_ctx_last_error(
   $runtime_ctx,
   stage => 'prepare_pipeline',
   summary => 'Compiler pipeline setup failed',
   detail => $pipeline_setup_error,
   handler_source_label => _compiler_top_rule_handler_source_label($runtime_ctx),
  );
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Compiler pipeline setup failed");
  _trace_exit($trace_scope, { status => 'error', stage => 'prepare_pipeline' }, DUMP_LOW);
  return undef;
 }

 my %validate_spec_content_failure;
 my $spec_content_valid = eval {
  LinkedSpec::Validation::validate_spec_content(
   $spec_content_ref,
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
  _compiler_rule_or_top_handler_source_label($runtime_ctx, $validate_spec_content_failure{rule_label});
 if ($validate_spec_content_error) {
  _set_runtime_ctx_last_error(
   $runtime_ctx,
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
   _set_runtime_ctx_last_error(
    $runtime_ctx,
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
   _set_runtime_ctx_last_error(
    $runtime_ctx,
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
  _reset_spec_content_pos($spec_content_ref);
  my %validate_dsl_failure;
  my $dsl_valid = eval {
   LinkedSpec::Validation::validate_dsl_syntax(
    $spec_content_ref,
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
   _compiler_rule_or_top_handler_source_label($runtime_ctx, $validate_dsl_failure{rule_label});
  if ($validate_dsl_syntax_error) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
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
    _set_runtime_ctx_last_error(
     $runtime_ctx,
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
    _set_runtime_ctx_last_error(
     $runtime_ctx,
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
 _reset_spec_content_pos($spec_content_ref);
 my $bootstrap_parse_eval_ok = eval {
  ($parse_success, $retv, $parse_error) = $bootstrap_parse->($spec_content_ref);
  1;
 };
 my $bootstrap_parse_error = $@;
 unless ($bootstrap_parse_eval_ok) {
 _set_runtime_ctx_last_error(
   $runtime_ctx,
   stage => 'bootstrap_parse',
   summary => 'Spec parsing failed',
   detail => $bootstrap_parse_error,
   handler_source_label => _compiler_top_rule_handler_source_label($runtime_ctx),
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
  _set_runtime_ctx_last_error(
   $runtime_ctx,
   stage => 'bootstrap_parse',
   summary => 'Spec parsing did not produce a valid intermediate representation',
   detail => _bootstrap_parse_result_detail($parse_success, $retv, $parse_error),
   handler_source_label => _compiler_top_rule_handler_source_label($runtime_ctx),
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
  _emit_runtime_ctx_parser_source_line($runtime_ctx, "my \$descr = {\n spec => {\n");
 }

my $active_spec_descr_rule_label = undef;
_clear_last_spec_descr_failure_detail();
my $compiled_spec_state = eval {
 spec_descr($retv, sub {
   my ($entry) = @_;
   $active_spec_descr_rule_label = _parsed_rule_label($entry);
   return $compile_spec_entry->($entry)
  }, { return_state => 1 })
};
my $spec_descr_error = $@;
 my $active_spec_descr_handler_source_label =
  _compiler_rule_or_top_handler_source_label($runtime_ctx, $active_spec_descr_rule_label);
if ($spec_descr_error) {
  _set_runtime_ctx_last_error(
   $runtime_ctx,
   stage => 'spec_descr',
   summary => 'Spec descriptor generation failed',
   detail => $spec_descr_error,
   rule_label => $active_spec_descr_rule_label,
   handler_source_label => $active_spec_descr_handler_source_label,
  );
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Spec descriptor generation failed - trapped exception while compiling parsed spec entries");
  _trace_exit($trace_scope, { status => 'error', stage => 'spec_descr' }, DUMP_LOW);
  return undef;
 }
 unless (_is_compiled_spec_state($compiled_spec_state)) {
 _set_runtime_ctx_last_error(
   $runtime_ctx,
   stage => 'spec_descr',
   summary => 'Spec descriptor generation failed',
   detail => do {
    my $detail = _get_last_spec_descr_failure_detail();
    defined($detail) && length($detail)
     ? $detail
     : 'Rule descriptor build failed while compiling parsed spec entries'
   },
   rule_label => $active_spec_descr_rule_label,
   handler_source_label => $active_spec_descr_handler_source_label,
  );
 _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Spec descriptor generation failed");
  _trace_exit($trace_scope, { status => 'error', stage => 'spec_descr' }, DUMP_LOW);
  return undef;
 }
 _clear_active_spec_gdata_rule_label();
 my $final_descr_state = eval { _build_final_descr_state($compiled_spec_state, undef, parse_mode => $parse_mode) };
my $build_final_descr_error = $@;
my $build_final_descr_rule_label = _get_active_spec_gdata_rule_label();
 my $build_final_descr_handler_source_label =
  _compiler_rule_or_top_handler_source_label($runtime_ctx, $build_final_descr_rule_label);
_clear_active_spec_gdata_rule_label();
if ($build_final_descr_error) {
  _set_runtime_ctx_last_error(
   $runtime_ctx,
   stage => 'build_final_descr',
   summary => 'Final descriptor assembly failed',
   detail => _normalize_error_detail($build_final_descr_error),
   rule_label => $build_final_descr_rule_label,
   handler_source_label => $build_final_descr_handler_source_label,
  );
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Final descriptor assembly failed - trapped exception while building gdata/final descriptor state");
  _trace_exit($trace_scope, { status => 'error', stage => 'build_final_descr' }, DUMP_LOW);
 return undef;
 }
 unless (_is_compiled_descriptor_state($final_descr_state)) {
  _set_runtime_ctx_last_error(
   $runtime_ctx,
   stage => 'build_final_descr',
   summary => 'Final descriptor assembly failed',
   detail => _describe_final_descr_state_result($final_descr_state),
   rule_label => $build_final_descr_rule_label,
   handler_source_label => $build_final_descr_handler_source_label,
  );
 _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Final descriptor assembly did not produce a valid compiled descriptor state");
 _trace_exit($trace_scope, { status => 'error', stage => 'build_final_descr' }, DUMP_LOW);
  return undef;
 }

 my %validate_gdata_failure;
 my $gdata_refs_valid = eval {
  LinkedSpec::Validation::validate_compiled_descriptor_state(
   $final_descr_state,
   {
    on_failure => sub {
     %validate_gdata_failure = @_;
     return 1;
    },
   },
  )
 };
my $validate_gdata_references_error = $@;
 my $validate_gdata_handler_source_label =
  _compiler_rule_or_top_handler_source_label($runtime_ctx, $validate_gdata_failure{rule_label});
if ($validate_gdata_references_error) {
  _set_runtime_ctx_last_error(
   $runtime_ctx,
   stage => 'validate_gdata_references',
   summary => defined($validate_gdata_failure{summary}) && length($validate_gdata_failure{summary})
    ? $validate_gdata_failure{summary}
    : 'Generated parser validation failed',
   detail => defined($validate_gdata_failure{detail}) && length($validate_gdata_failure{detail})
    ? $validate_gdata_failure{detail}
    : $validate_gdata_references_error,
   rule_label => $validate_gdata_failure{rule_label},
   handler_source_label => $validate_gdata_handler_source_label,
  );
  _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Generated parser validation failed - trapped exception during generated-descriptor validation");
  _trace_exit($trace_scope, { status => 'error', stage => 'validate_gdata_references' }, DUMP_LOW);
  return undef;
 }

 unless ($gdata_refs_valid) {
  _set_runtime_ctx_last_error(
   $runtime_ctx,
   stage => 'validate_gdata_references',
   summary => defined($validate_gdata_failure{summary}) && length($validate_gdata_failure{summary})
    ? $validate_gdata_failure{summary}
    : 'Generated parser validation failed',
   detail => defined($validate_gdata_failure{detail}) && length($validate_gdata_failure{detail})
    ? $validate_gdata_failure{detail}
    : 'validate_gdata_references returned false for the generated descriptor',
   rule_label => $validate_gdata_failure{rule_label},
   handler_source_label => $validate_gdata_handler_source_label,
  );
 _trace_log_output(DUMP_NONE, "CRITICAL ERROR", "Generated parser validation failed - terminating parser generation");
 _trace_exit($trace_scope, { status => 'error', stage => 'validate_gdata_references' }, DUMP_LOW);
 return undef;
}
 my $final_descr = _compiled_descriptor_state_to_legacy_descr($final_descr_state);

 my $selected_top_rule =
    defined($requested_top_rule) && length($requested_top_rule) ? $requested_top_rule
  : _first_parsed_rule_label($retv);
 _set_runtime_ctx_top_rule($runtime_ctx, $selected_top_rule) if defined($selected_top_rule) && length($selected_top_rule);

 my $rule_count = _compiled_spec_state_rule_count($compiled_spec_state);
 _trace_log_output(DUMP_LOW, "Parser generation completed", "Generated parser with $rule_count rules");
 if ($dump_parser_source) {
  _emit_runtime_ctx_parser_source_line($runtime_ctx, " },\n gdata => {\n");
  my @glabels = sort keys %{$final_descr->{gdata} || {}};
  for (my $i = 0; $i < @glabels; ++$i) {
   my $label = $glabels[$i];
   my $gregex = $final_descr->{gdata}{$label};
   my $prefix = $i ? ",\n" : '';
   _emit_runtime_ctx_parser_source_line($runtime_ctx, $prefix . " $label\t=> qr/$gregex/o");
  }
  my $top_rule = _get_runtime_ctx_top_rule($runtime_ctx);
  _emit_runtime_ctx_parser_source_line($runtime_ctx, "\n }\n};\n\nsub Get {&{\$descr->{spec}{$top_rule}}(\$descr, \$_[0])}\n");
  _flush_runtime_ctx_parser_source($runtime_ctx, $parser_source_ref);
 }

 if (_trace_should_dump(DUMP_LOW)) {
  my $top_rule = _get_runtime_ctx_top_rule($runtime_ctx);
  _trace_log_dump("=== FINAL_DESCR DUMP: top_rule=$top_rule ===\n");
  _trace_log_dump(_dump_value($final_descr));
  _trace_log_dump("=== END FINAL_DESCR DUMP: top_rule=$top_rule ===\n");
 }

 if ($generate_only) {
  _trace_log_output(DUMP_LOW, "Generate-only mode", "Stopping after parser generation - no functional parser returned");
  _trace_exit($trace_scope, { status => 'ok', stage => 'generate_only', generate_only => 1 }, DUMP_LOW);
  return undef;
 }

 if ($return_descr) {
  _trace_log_output(DUMP_LOW, "Descriptor-return mode", "Returning generated parser descriptor hash");
  _trace_exit($trace_scope, { status => 'ok', stage => 'return_descr', return_descr => 1, rule_count => $rule_count }, DUMP_LOW);
  return $final_descr;
 }

 _trace_log_output(DUMP_LOW, "Parser generation completed successfully", "Returning functional parser for execution");
 _trace_exit($trace_scope, { status => 'ok', stage => 'parser_ready', top_rule => _get_runtime_ctx_top_rule($runtime_ctx), rule_count => $rule_count }, DUMP_LOW);

 my $top_rule = _get_runtime_ctx_top_rule($runtime_ctx);
 return sub {
  _clear_runtime_ctx_last_error($runtime_ctx);
 my $top_rule_entry = (defined($top_rule) && length($top_rule) && ref($final_descr->{spec}{$top_rule}) eq 'HASH')
   ? $final_descr->{spec}{$top_rule}
   : undef;
  my $top_rule_meta = (ref($top_rule_entry) eq 'HASH') ? $top_rule_entry->{meta} : undef;
  my $top_handler_variant = (ref($top_rule_meta) eq 'HASH') ? $top_rule_meta->{selected_handler_variant} : undef;
  my $top_handler_source_label = (defined($top_rule) && length($top_rule))
   ? _build_generated_handler_source_label(
      label => $top_rule,
      handler_variant => $top_handler_variant,
     )
   : undef;
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
   _set_runtime_ctx_last_error(
    $runtime_ctx,
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
   _set_runtime_ctx_last_error(
    $runtime_ctx,
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
  _set_runtime_ctx_last_error(
   $runtime_ctx,
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
  my $detail = _describe_parser_input_ref($input_ref);
  _set_runtime_ctx_last_error(
   $runtime_ctx,
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
 my $retv = eval { &$handler($final_descr, $input_ref) };
  my $eval_error = $@;
  if ($eval_error) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
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
  if (_has_runtime_ctx_last_error_type($runtime_ctx, 'runtime_handler')) {
   if (defined($retv)) {
    _clear_runtime_ctx_last_error($runtime_ctx);
    $@ = '';
    $invoke_reason = 'top-level handler returned defined AST and cleared stale runtime_handler context';
   } else {
    $@ = _get_runtime_ctx_last_error_detail($runtime_ctx);
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
