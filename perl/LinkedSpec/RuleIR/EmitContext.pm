#------------------------------------------------------------------------------
# Package: LinkedSpec::RuleIR::EmitContext
# Purpose: Build the rule-emission context that bridges RuleIR planning into
#          ActionIR scanning, diagnostics, and lowering.
#------------------------------------------------------------------------------
package LinkedSpec::RuleIR::EmitContext;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $rule_ir_dir = File::Basename::dirname($module_dir);
 my $linked_spec_dir = File::Basename::dirname($rule_ir_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();

use constant {
 DUMP_LOW => 100,
};

#------------------------------------------------------------------------------
# Function: _require_pkg
# Purpose : Lazy-load one emit-context dependency owner through the shared
#           owner-dispatch seam.
# Args    : ($pkg)
# Returns : requested package name
#------------------------------------------------------------------------------
sub _require_pkg {
 my ($pkg) = @_;
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg);
 return $pkg
}

#------------------------------------------------------------------------------
# Function: _actionir_owner_package
# Purpose : Resolve one local ActionIR owner key to its package name and
#           lazy-load it through the shared owner-dispatch seam.
# Args    : ($owner_key)
# Returns : loaded package name
#------------------------------------------------------------------------------
sub _actionir_owner_package {
 my ($owner_key) = @_;
 state $owner_pkgs = {
  rewrite_pipeline => 'LinkedSpec::ActionIR::RewritePipeline',
  method_expr => 'LinkedSpec::ActionIR::MethodExpr',
  scanner => 'LinkedSpec::ActionIR::Scanner',
  canonical_events => 'LinkedSpec::ActionIR::CanonicalEvents',
  diagnostics => 'LinkedSpec::ActionIR::Diagnostics',
  statement_split => 'LinkedSpec::ActionIR::StatementSplit',
  contracts => 'LinkedSpec::ActionIR::Contracts',
  flow_expr => 'LinkedSpec::ActionIR::FlowExpr',
  array_pipeline => 'LinkedSpec::ActionIR::ArrayPipeline',
  control_flow => 'LinkedSpec::ActionIR::ControlFlow',
  method_lowering => 'LinkedSpec::ActionIR::MethodLowering',
  declare_method => 'LinkedSpec::ActionIR::DeclareMethod',
  value_expr => 'LinkedSpec::ActionIR::ValueExpr',
  trace => 'LinkedSpec::Trace',
 };

 my $pkg = $owner_pkgs->{$owner_key};
 die "(LinkedSpec::RuleIR::EmitContext::_actionir_owner_package) -E- unknown owner key '$owner_key'"
  unless defined($pkg) && length($pkg);
 return _require_pkg($pkg)
}

sub _require_rewrite_pipeline_pkg {
 return _actionir_owner_package('rewrite_pipeline')
}

sub _require_method_expr_pkg {
 return _actionir_owner_package('method_expr')
}

sub _require_scanner_pkg {
 return _actionir_owner_package('scanner')
}

sub _require_canonical_events_pkg {
 return _actionir_owner_package('canonical_events')
}

sub _require_diagnostics_pkg {
 return _actionir_owner_package('diagnostics')
}

sub _require_statement_split_pkg {
 return _actionir_owner_package('statement_split')
}

sub _require_contracts_pkg {
 return _actionir_owner_package('contracts')
}

sub _require_flow_expr_pkg {
 return _actionir_owner_package('flow_expr')
}

sub _require_array_pipeline_pkg {
 return _actionir_owner_package('array_pipeline')
}

sub _require_control_flow_pkg {
 return _actionir_owner_package('control_flow')
}

sub _require_method_lowering_pkg {
 return _actionir_owner_package('method_lowering')
}

sub _require_declare_method_pkg {
 return _actionir_owner_package('declare_method')
}

sub _require_value_expr_pkg {
 return _actionir_owner_package('value_expr')
}

sub _require_trace_pkg {
 return _actionir_owner_package('trace')
}

#------------------------------------------------------------------------------
# Function: _call_preserving_err
# Purpose : Preserve caller-visible successful `$@` while executing one
#           emit-context helper callback.
# Args    : ($cb)
# Returns : callback return value in caller context
#------------------------------------------------------------------------------
sub _call_preserving_err {
 my ($cb) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err($cb)
}

#------------------------------------------------------------------------------
# Function: _actionir_owner_callback
# Purpose : Resolve one callback from a local ActionIR owner through the shared
#           owner-dispatch callback loader.
# Args    : ($owner_key, $method)
# Returns : coderef
#------------------------------------------------------------------------------
sub _actionir_owner_callback {
 my ($owner_key, $method) = @_;
 my $pkg = _actionir_owner_package($owner_key);
 return LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, $pkg, $method)
}

#------------------------------------------------------------------------------
# Function: _actionir_owner_default_deps
# Purpose : Ask one local ActionIR owner for its default dependency bundle as
#           seen from this emit-context package.
# Args    : ($owner_key)
# Returns : hashref dependency map
#------------------------------------------------------------------------------
sub _actionir_owner_default_deps {
 my ($owner_key) = @_;
 return _call_preserving_err(sub {
  my $code = _actionir_owner_callback($owner_key, 'default_deps_for_package');
  return $code->(__PACKAGE__)
 })
}

#------------------------------------------------------------------------------
# Function: _call_actionir_owner
# Purpose : Dispatch one helper callback to a local ActionIR owner without
#           appending that owner's default dependency bundle.
# Args    : ($owner_key, $method, @args)
# Returns : callback return value
#------------------------------------------------------------------------------
sub _call_actionir_owner {
 my ($owner_key, $method, @args) = @_;
 return _call_preserving_err(sub {
  my $code = _actionir_owner_callback($owner_key, $method);
  return $code->(@args)
 })
}

#------------------------------------------------------------------------------
# Function: _call_actionir_owner_with_deps
# Purpose : Dispatch one helper callback to a local ActionIR owner and append
#           that owner's default dependency bundle automatically.
# Args    : ($owner_key, $method, @args)
# Returns : callback return value
#------------------------------------------------------------------------------
sub _call_actionir_owner_with_deps {
 my ($owner_key, $method, @args) = @_;
 return _call_preserving_err(sub {
  my $code = _actionir_owner_callback($owner_key, $method);
  my $deps = _actionir_owner_default_deps($owner_key);
  return $code->(@args, $deps)
 })
}

sub _trace_log_output {
 my @args = @_;
 return _call_actionir_owner('trace', 'log_output', @args)
}

sub _build_rewrite_diag_acc {
 return {
  unresolved_helper_hits  => {},
  unresolved_helper_count => 0,
  unresolved_helper_events => [],
  helper_action_ir_hits   => {},
  helper_action_ir_count  => 0,
  helper_action_ir_events => [],
  canonical_action_ir_hits   => {},
  canonical_action_ir_count  => 0,
  canonical_action_ir_events => [],
  canonical_action_ir_fallback_count => 0,
 }
}

sub _trim_action_ir_value {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s*|\s*$//go;
 return $value
}

sub _preserve_terminal_block_statement_separator {
 my ($original, $rewritten) = @_;
 return $rewritten unless defined($original) && defined($rewritten);
 return $rewritten unless $original =~ /;\s*\}$/o;
 return $rewritten if $rewritten =~ /;\s*\}$/o;
 $rewritten =~ s/\s*\}$/; }/o;
 return $rewritten
}

sub _parse_method_function_expr {
 my @args = @_;
 return _call_actionir_owner('method_expr', '_parse_method_function_expr', @args)
}

sub _is_bare_method_scope_token {
 my @args = @_;
 return _call_actionir_owner('method_expr', '_is_bare_method_scope_token', @args)
}

sub _normalize_method_args_with_optional_scope {
 my @args = @_;
 return _call_actionir_owner('method_expr', '_normalize_method_args_with_optional_scope', @args)
}

sub _split_top_level_csv {
 my @args = @_;
 return _call_actionir_owner('method_expr', '_split_top_level_csv', @args)
}

sub _statement_split_deps {
 return _actionir_owner_default_deps('statement_split')
}

sub _split_action_ir_statements {
 my @args = @_;
 return _call_actionir_owner_with_deps('statement_split', '_split_action_ir_statements', @args)
}

sub _flow_expr_deps {
 return _actionir_owner_default_deps('flow_expr')
}

sub _value_expr_deps {
 return _actionir_owner_default_deps('value_expr')
}

sub _method_lowering_deps {
 return _actionir_owner_default_deps('method_lowering')
}

sub _declare_method_deps {
 return _actionir_owner_default_deps('declare_method')
}

sub _array_pipeline_deps {
 return _actionir_owner_default_deps('array_pipeline')
}

sub _control_flow_deps {
 return _actionir_owner_default_deps('control_flow')
}

sub _scan_contract_ir_event_deps {
 return _actionir_owner_default_deps('scanner')
}

sub _diagnostics_deps {
 return _actionir_owner_default_deps('diagnostics')
}

sub _canonical_event_deps {
 return _actionir_owner_default_deps('canonical_events')
}

sub _action_contract_deps {
 return _actionir_owner_default_deps('contracts')
}

sub _rewrite_pipeline_deps {
 return _actionir_owner_default_deps('rewrite_pipeline')
}

sub _lower_flow_composite_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('flow_expr', '_lower_flow_composite_expr', @args)
}

sub _extract_scalar_symbol_name {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_extract_scalar_symbol_name', @args)
}

sub _extract_array_symbol_name {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_extract_array_symbol_name', @args)
}

sub _extract_hash_symbol_name {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_extract_hash_symbol_name', @args)
}

sub _lower_scalar_access_key_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_lower_scalar_access_key_expr', @args)
}

sub _lower_scalaref_value_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_lower_scalaref_value_expr', @args)
}

sub _infer_scalar_container_kind {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_infer_scalar_container_kind', @args)
}

sub _lower_assignment_source_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_lower_assignment_source_expr', @args)
}

sub _strip_literal_delimiters {
 my @args = @_;
 return _call_actionir_owner_with_deps('value_expr', '_strip_literal_delimiters', @args)
}

sub _split_declare_symbol_names {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_split_declare_symbol_names', @args)
}

sub _parse_declare_binding_entry {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_parse_declare_binding_entry', @args)
}

sub _lower_declare_value_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_lower_declare_value_expr', @args)
}

sub _lower_declare_initializer_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_lower_declare_initializer_expr', @args)
}

sub _lower_typed_declare_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_typed_declare_statement', @args)
}

sub _declare_alias_to_type {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_declare_alias_to_type', @args)
}

sub _lower_assign_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_assign_statement', @args)
}

sub _lower_method_value_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_method_value_expr', @args)
}

sub _lower_return_general_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_return_general_statement', @args)
}

sub _lower_return_imatch_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_return_imatch_statement', @args)
}

sub _lower_push_value_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_push_value_statement', @args)
}

sub _lower_push_nonempty_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_push_nonempty_statement', @args)
}

sub _lower_regex_subst_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_regex_subst_statement', @args)
}

sub _lower_return_undef_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_return_undef_statement', @args)
}

sub _lower_return_array_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_lower_return_array_statement', @args)
}

sub _extract_declare_statement_from_method_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_extract_declare_statement_from_method_expr', @args)
}

sub _lower_declare_method_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_lower_declare_method_statement', @args)
}

sub _lower_assign_method_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('declare_method', '_lower_assign_method_statement', @args)
}

sub _build_array_pipeline_plan_from_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('array_pipeline', '_build_array_pipeline_plan_from_expr', @args)
}

sub _lower_array_pipeline_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('array_pipeline', '_lower_array_pipeline_expr', @args)
}

sub _lower_if_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_if_flow_statement', @args)
}

sub _lower_elseif_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_elseif_flow_statement', @args)
}

sub _lower_else_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_else_flow_statement', @args)
}

sub _lower_endif_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_endif_flow_statement', @args)
}

sub _lower_switch_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_switch_flow_statement', @args)
}

sub _lower_case_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_case_flow_statement', @args)
}

sub _lower_default_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_default_flow_statement', @args)
}

sub _lower_endcase_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_endcase_flow_statement', @args)
}

sub _lower_endswitch_flow_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_endswitch_flow_statement', @args)
}

sub _lower_say_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_say_statement', @args)
}

sub _lower_print_statement {
 my @args = @_;
 return _call_actionir_owner_with_deps('control_flow', '_lower_print_statement', @args)
}

sub _normalize_method_tag_expr {
 my @args = @_;
 return _call_actionir_owner_with_deps('method_lowering', '_normalize_method_tag_expr', @args)
}

sub _build_action_lowering_contracts {
 my ($label) = @_;
 return _call_actionir_owner_with_deps('contracts', 'build_action_lowering_contracts', $label)
}

sub _scan_contract_ir_events {
 my @args = @_;
 return _call_actionir_owner_with_deps('scanner', 'scan_contract_ir_events', @args)
}

sub _find_unresolved_action_helpers {
 my @args = @_;
 return _call_actionir_owner_with_deps('diagnostics', '_find_unresolved_action_helpers', @args)
}

sub _collect_action_helper_ir_nodes {
 my @args = @_;
 return _call_actionir_owner_with_deps('diagnostics', '_collect_action_helper_ir_nodes', @args)
}

sub _build_canonical_action_ir_events {
 my @args = @_;
 return _call_actionir_owner_with_deps('canonical_events', '_build_canonical_action_ir_events', @args)
}

sub _canonicalize_helper_action_ir_event {
 my @args = @_;
 return _call_actionir_owner_with_deps('canonical_events', '_canonicalize_helper_action_ir_event', @args)
}

sub _rewrite_action_code_with_diagnostics {
 my ($label, $code, $rewrite_rules) = @_;
 return _call_actionir_owner_with_deps('rewrite_pipeline', '_rewrite_action_code_with_diagnostics', $label, $code, $rewrite_rules)
}

sub _accumulate_action_rewrite_diagnostics {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_diagnostics_pkg();
  return LinkedSpec::ActionIR::Diagnostics::_accumulate_action_rewrite_diagnostics(@args)
 })
}

sub _lower_action_code_from_canonical_ir {
 my @args = @_;
 return _call_actionir_owner('rewrite_pipeline', '_lower_action_code_from_canonical_ir', @args)
}

sub _build_action_rewrite_rules {
 my @args = @_;
 return _call_actionir_owner_with_deps('rewrite_pipeline', '_build_action_rewrite_rules', @args)
}

sub rewrite_action_code_for_compat {
 my ($label, $code) = @_;
 return _call_preserving_err(sub {
  my ($rewritten) = _rewrite_action_code_with_diagnostics($label, $code, undef);
  my $trimmed = _trim_action_ir_value($code);
  if (
   defined($trimmed) &&
   length($trimmed) &&
   $rewritten eq $code &&
   $trimmed =~ /^(?:s|a|h)\s*\(/o
  ) {
   my $call = _parse_method_function_expr($trimmed);
   if ($call && ($call->{method} // '') =~ /^(?:scalar|array|hash)$/o) {
    my $lowered = _lower_method_value_expr($trimmed);
    return $lowered if defined($lowered) && length($lowered);
   }
  }
  return $rewritten
 })
}

sub _normalize_rule_code_chunks {
 my ($label, $chunks, $rewrite_diag_acc, $rewrite_rules) = @_;

 my @normalized;
 foreach my $chunk (@$chunks) {
  my ($rewritten, $diag) = _rewrite_action_code_with_diagnostics($label, $chunk, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag) if $rewrite_diag_acc;
  $rewritten = _preserve_terminal_block_statement_separator($chunk, $rewritten);
  $rewritten =~ s/\s*;\s*$//o;
  push @normalized, $rewritten;
 }

 return join ";\n", @normalized
}

sub _rewrite_acode_entries {
 my ($label, $acode_entries, $rewrite_rules, $rewrite_diag_acc) = @_;

 my @ACODEs;
 my @dependency_refs;
 foreach my $acode_entry (@$acode_entries) {
  my ($rewritten_acode, $diag) = _rewrite_action_code_with_diagnostics($label, $acode_entry->{code}, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag);
  push @ACODEs, $rewritten_acode;
  push @dependency_refs, {label => $acode_entry->{relabel}, idx => $acode_entry->{reidx}};
 }

 return (\@ACODEs, \@dependency_refs)
}

sub _rewrite_bcode_entries {
 my ($label, $bcode_entries, $rewrite_rules, $rewrite_diag_acc) = @_;

 my @BCALLs;
 my %BCODEs;
 foreach my $bcode_entry (@$bcode_entries) {
  my ($rewritten_bcode, $diag) = _rewrite_action_code_with_diagnostics($label, $bcode_entry->{code}, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag);
  push @BCALLs, $bcode_entry->{call};
  $BCODEs{$bcode_entry->{call}} = $rewritten_bcode;
 }

 return (\@BCALLs, \%BCODEs)
}

sub _normalize_rule_lifecycle_code {
 my ($label, $code_blocks, $rewrite_diag_acc, $rewrite_rules) = @_;
 return {
  icode  => _normalize_rule_code_chunks($label, $code_blocks->{ICODE},  $rewrite_diag_acc, $rewrite_rules),
  ecode  => _normalize_rule_code_chunks($label, $code_blocks->{ECODE},  $rewrite_diag_acc, $rewrite_rules),
  excode => _normalize_rule_code_chunks($label, $code_blocks->{EXCODE}, $rewrite_diag_acc, $rewrite_rules),
  itcode => _normalize_rule_code_chunks($label, $code_blocks->{ITCODE}, $rewrite_diag_acc, $rewrite_rules),
  lxcode => _normalize_rule_code_chunks($label, $code_blocks->{LXCODE}, $rewrite_diag_acc, $rewrite_rules),
  lscode => _normalize_rule_code_chunks($label, $code_blocks->{LSCODE}, $rewrite_diag_acc, $rewrite_rules),
  lecode => _normalize_rule_code_chunks($label, $code_blocks->{LECODE}, $rewrite_diag_acc, $rewrite_rules),
 }
}

sub _collect_unresolved_helper_statements {
 my ($rewrite_diag_acc) = @_;

 my @unresolved_helper_statements;
 my %seen_unresolved_helper_statement;
 foreach my $event (@{$rewrite_diag_acc->{unresolved_helper_events}}) {
  my $raw_code = _trim_action_ir_value($event->{raw});
  next unless defined($raw_code) && length($raw_code);
  next if $seen_unresolved_helper_statement{$raw_code}++;
  push @unresolved_helper_statements, $raw_code;
 }
 return @unresolved_helper_statements
}

sub _collect_raw_perl_dependency_statements {
 my ($rewrite_diag_acc) = @_;

 my @raw_perl_dependency_statements;
 my %seen_raw_perl_dependency_statement;
 foreach my $event (@{$rewrite_diag_acc->{canonical_action_ir_events}}) {
  next unless ($event->{kind} // '') eq 'RAW_PERL';
  my $raw_code = (ref($event->{args}) eq 'HASH') ? $event->{args}{code} : $event->{raw};
  $raw_code = _trim_action_ir_value($raw_code);
  next unless defined($raw_code) && length($raw_code);
  next if $seen_raw_perl_dependency_statement{$raw_code}++;
  push @raw_perl_dependency_statements, $raw_code;
 }
 return @raw_perl_dependency_statements
}

sub _build_compatibility_surface_diag {
 my ($rewrite_rules, $rewrite_diag_acc) = @_;

 my %compatibility_contract_ids = map {
  my $id = $_->{id};
  defined($id) && length($id) ? ($id => 1) : ()
 } grep { $_->{compatibility_surface} } @$rewrite_rules;

 my %compatibility_surface_hits;
 my @compatibility_surface_events;
 my @compatibility_surface_statements;
 my %seen_compatibility_surface_statement;

 foreach my $event (@{$rewrite_diag_acc->{helper_action_ir_events}}) {
  my $contract_id = $event->{contract_id} // '';
  next unless length($contract_id) && $compatibility_contract_ids{$contract_id};

  push @compatibility_surface_events, $event;
  ++$compatibility_surface_hits{$contract_id};

  my $raw_code = _trim_action_ir_value($event->{raw});
  next unless defined($raw_code) && length($raw_code);
  next if $seen_compatibility_surface_statement{$raw_code}++;
  push @compatibility_surface_statements, $raw_code;
 }

 my @compatibility_surface_contract_ids = sort keys %compatibility_surface_hits;
 return {
  compatibility_surface_count => scalar(@compatibility_surface_events),
  compatibility_surface_contract_ids => \@compatibility_surface_contract_ids,
  compatibility_surface_hits => \%compatibility_surface_hits,
  compatibility_surface_events => [@compatibility_surface_events],
  compatibility_surface_statement_count => scalar(@compatibility_surface_statements),
  compatibility_surface_statements => \@compatibility_surface_statements,
 };
}

sub _build_language_agnostic_blocker_statements {
 my ($raw_perl_dependency_statements, $unresolved_helper_statements) = @_;

 my @language_agnostic_action_ir_blocker_statements;
 my %seen_language_agnostic_action_ir_blocker_statement;
 foreach my $statement (@$raw_perl_dependency_statements, @$unresolved_helper_statements) {
  next unless defined($statement) && length($statement);
  next if $seen_language_agnostic_action_ir_blocker_statement{$statement}++;
  push @language_agnostic_action_ir_blocker_statements, $statement;
 }
 return @language_agnostic_action_ir_blocker_statements
}

sub _build_action_rewriter_meta {
 my ($label, $rewrite_rules, $rewrite_diag_acc) = @_;

 my @rewrite_contract_ids = map { $_->{id} } @$rewrite_rules;
 my @unresolved_helper_statements = _collect_unresolved_helper_statements($rewrite_diag_acc);
 my @raw_perl_dependency_statements = _collect_raw_perl_dependency_statements($rewrite_diag_acc);
 my $raw_perl_dependency_count = $rewrite_diag_acc->{canonical_action_ir_fallback_count} || 0;
 my @language_agnostic_action_ir_blocker_statements = _build_language_agnostic_blocker_statements(
 \@raw_perl_dependency_statements,
  \@unresolved_helper_statements,
 );
 my $compatibility_surface_diag = _build_compatibility_surface_diag($rewrite_rules, $rewrite_diag_acc);
 my $language_agnostic_action_ir_blocker_statement_count = scalar @language_agnostic_action_ir_blocker_statements;
 my $language_agnostic_action_ir_ready = (
  $raw_perl_dependency_count == 0 &&
  ($rewrite_diag_acc->{unresolved_helper_count} || 0) == 0
 ) ? 1 : 0;

 my $action_rewriter_meta = {
  unresolved_helper_count => $rewrite_diag_acc->{unresolved_helper_count},
  unresolved_helpers      => [sort keys %{$rewrite_diag_acc->{unresolved_helper_hits}}],
  unresolved_helper_hits  => {%{$rewrite_diag_acc->{unresolved_helper_hits}}},
  unresolved_helper_events => [@{$rewrite_diag_acc->{unresolved_helper_events}}],
  unresolved_helper_statements => \@unresolved_helper_statements,
  helper_action_ir_count  => $rewrite_diag_acc->{helper_action_ir_count},
  helper_action_ir_nodes  => [sort keys %{$rewrite_diag_acc->{helper_action_ir_hits}}],
  helper_action_ir_hits   => {%{$rewrite_diag_acc->{helper_action_ir_hits}}},
  helper_action_ir_events => [@{$rewrite_diag_acc->{helper_action_ir_events}}],
  canonical_action_ir_count => $rewrite_diag_acc->{canonical_action_ir_count},
  canonical_action_ir_nodes => [sort keys %{$rewrite_diag_acc->{canonical_action_ir_hits}}],
  canonical_action_ir_hits  => {%{$rewrite_diag_acc->{canonical_action_ir_hits}}},
  canonical_action_ir_events => [@{$rewrite_diag_acc->{canonical_action_ir_events}}],
  canonical_action_ir_fallback_count => $rewrite_diag_acc->{canonical_action_ir_fallback_count},
  raw_perl_dependency_count => $raw_perl_dependency_count,
  raw_perl_dependency_statements => \@raw_perl_dependency_statements,
  compatibility_surface_count => $compatibility_surface_diag->{compatibility_surface_count},
  compatibility_surface_contract_ids => [@{$compatibility_surface_diag->{compatibility_surface_contract_ids}}],
  compatibility_surface_hits => {%{$compatibility_surface_diag->{compatibility_surface_hits}}},
  compatibility_surface_events => [@{$compatibility_surface_diag->{compatibility_surface_events}}],
  compatibility_surface_statement_count => $compatibility_surface_diag->{compatibility_surface_statement_count},
  compatibility_surface_statements => [@{$compatibility_surface_diag->{compatibility_surface_statements}}],
  language_agnostic_action_ir_blocker_statement_count => $language_agnostic_action_ir_blocker_statement_count,
  language_agnostic_action_ir_blocker_statements => \@language_agnostic_action_ir_blocker_statements,
  language_agnostic_action_ir_ready => $language_agnostic_action_ir_ready,
  rewrite_contract_ids    => \@rewrite_contract_ids,
 };

 if ($action_rewriter_meta->{unresolved_helper_count}) {
  _trace_log_output(
   DUMP_LOW,
   "Rule '$label': unresolved action helper(s) after rewrite pipeline",
   "helpers=" . join(', ', @{$action_rewriter_meta->{unresolved_helpers}})
  );
 }

 return $action_rewriter_meta
}

#------------------------------------------------------------------------------
# Function: build_rule_ir_emit_context
# Purpose : Build fully-rewritten emit context (ACODE/BCODE/dependency_refs/lifecycle
#           chunks) plus rich action-rewriter diagnostics metadata.
# Args    : ($rule_ir)
# Returns : hashref emit context
#------------------------------------------------------------------------------
sub build_rule_ir_emit_context {
 my ($rule_ir) = @_;
 my $label = $rule_ir->{label};
 my $rewrite_rules = _build_action_rewrite_rules($label);
 my $rewrite_diag_acc = _build_rewrite_diag_acc();

 my ($acodes, $dependency_refs) = _rewrite_acode_entries(
  $label,
  $rule_ir->{acode_entries},
  $rewrite_rules,
  $rewrite_diag_acc,
 );
 my ($bcalls, $bcodes) = _rewrite_bcode_entries(
  $label,
  $rule_ir->{bcode_entries},
  $rewrite_rules,
  $rewrite_diag_acc,
 );
 my $lifecycle_code = _normalize_rule_lifecycle_code(
  $label,
  $rule_ir->{code_blocks},
  $rewrite_diag_acc,
  $rewrite_rules,
 );

 my %ab_count = (
  ACODE => scalar(@{$rule_ir->{acode_entries}}),
  BCODE => scalar(@{$rule_ir->{bcode_entries}}),
 );
 my $action_rewriter_meta = _build_action_rewriter_meta(
  $label,
  $rewrite_rules,
  $rewrite_diag_acc,
 );

 return {
  label     => $label,
  node_type => $rule_ir->{node_type},
  REs       => $rule_ir->{REs},
  ACODEs    => $acodes,
  BCODEs    => $bcodes,
  BCALLs    => $bcalls,
  DEPENDENCY_REFS => $dependency_refs,
  ab_count  => \%ab_count,
  icode     => $lifecycle_code->{icode},
  ecode     => $lifecycle_code->{ecode},
  excode    => $lifecycle_code->{excode},
  itcode    => $lifecycle_code->{itcode},
  lxcode    => $lifecycle_code->{lxcode},
  lscode    => $lifecycle_code->{lscode},
  lecode    => $lifecycle_code->{lecode},
  action_rewriter_meta => $action_rewriter_meta,
 }
}

1;
