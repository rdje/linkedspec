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

use constant {
 DUMP_LOW => 100,
};

sub _require_pkg {
 my ($pkg) = @_;
 (my $path = "$pkg.pm") =~ s{::}{/}g;
 require $path;
 return $pkg
}

sub _require_rewrite_pipeline_pkg {
 return _require_pkg('LinkedSpec::ActionIR::RewritePipeline')
}

sub _require_method_expr_pkg {
 return _require_pkg('LinkedSpec::ActionIR::MethodExpr')
}

sub _require_scanner_pkg {
 return _require_pkg('LinkedSpec::ActionIR::Scanner')
}

sub _require_canonical_events_pkg {
 return _require_pkg('LinkedSpec::ActionIR::CanonicalEvents')
}

sub _require_diagnostics_pkg {
 return _require_pkg('LinkedSpec::ActionIR::Diagnostics')
}

sub _require_statement_split_pkg {
 return _require_pkg('LinkedSpec::ActionIR::StatementSplit')
}

sub _require_contracts_pkg {
 return _require_pkg('LinkedSpec::ActionIR::Contracts')
}

sub _require_flow_expr_pkg {
 return _require_pkg('LinkedSpec::ActionIR::FlowExpr')
}

sub _require_array_pipeline_pkg {
 return _require_pkg('LinkedSpec::ActionIR::ArrayPipeline')
}

sub _require_control_flow_pkg {
 return _require_pkg('LinkedSpec::ActionIR::ControlFlow')
}

sub _require_method_lowering_pkg {
 return _require_pkg('LinkedSpec::ActionIR::MethodLowering')
}

sub _require_declare_method_pkg {
 return _require_pkg('LinkedSpec::ActionIR::DeclareMethod')
}

sub _require_value_expr_pkg {
 return _require_pkg('LinkedSpec::ActionIR::ValueExpr')
}

sub _require_trace_pkg {
 return _require_pkg('LinkedSpec::Trace')
}

sub _call_preserving_err {
 my ($cb) = @_;
 my $saved_err = $@;
 my $wantarray = wantarray;
 if ($wantarray) {
  my @ret = $cb->();
  $@ = $saved_err;
  return @ret
 }
 if (defined $wantarray) {
  my $ret = $cb->();
  $@ = $saved_err;
  return $ret
 }
 $cb->();
 $@ = $saved_err;
 return
}

sub _trace_log_output {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::log_output(@args)
 })
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

sub _parse_method_function_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_expr_pkg();
  return LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr(@args)
 })
}

sub _is_bare_method_scope_token {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_expr_pkg();
  return LinkedSpec::ActionIR::MethodExpr::_is_bare_method_scope_token(@args)
 })
}

sub _normalize_method_args_with_optional_scope {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_expr_pkg();
  return LinkedSpec::ActionIR::MethodExpr::_normalize_method_args_with_optional_scope(@args)
 })
}

sub _split_top_level_csv {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_expr_pkg();
  return LinkedSpec::ActionIR::MethodExpr::_split_top_level_csv(@args)
 })
}

sub _statement_split_deps {
 return {
  trim_action_ir_value => sub { return _trim_action_ir_value(@_) },
 }
}

sub _split_action_ir_statements {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_statement_split_pkg();
  return LinkedSpec::ActionIR::StatementSplit::_split_action_ir_statements(@args, _statement_split_deps())
 })
}

sub _flow_expr_deps {
 return {
  trim_action_ir_value => sub { return _trim_action_ir_value(@_) },
  extract_array_symbol_name => sub { return _extract_array_symbol_name(@_) },
  extract_scalar_symbol_name => sub { return _extract_scalar_symbol_name(@_) },
  lower_method_value_expr => sub { return _lower_method_value_expr(@_) },
  parse_method_function_expr => sub { return _parse_method_function_expr(@_) },
  normalize_method_args_with_optional_scope => sub { return _normalize_method_args_with_optional_scope(@_) },
 }
}

sub _value_expr_deps {
 return {
  trim_action_ir_value => sub { return _trim_action_ir_value(@_) },
  lower_flow_composite_expr => sub { return _lower_flow_composite_expr(@_) },
  lower_method_value_expr => sub { return _lower_method_value_expr(@_) },
 }
}

sub _method_lowering_deps {
 return {
  trim_action_ir_value => sub { return _trim_action_ir_value(@_) },
  split_declare_symbol_names => sub { return _split_declare_symbol_names(@_) },
  parse_declare_binding_entry => sub { return _parse_declare_binding_entry(@_) },
  lower_declare_initializer_expr => sub { return _lower_declare_initializer_expr(@_) },
  parse_method_function_expr => sub { return _parse_method_function_expr(@_) },
  normalize_method_args_with_optional_scope => sub { return _normalize_method_args_with_optional_scope(@_) },
  lower_scalaref_value_expr => sub { return _lower_scalaref_value_expr(@_) },
  extract_array_symbol_name => sub { return _extract_array_symbol_name(@_) },
  extract_hash_symbol_name => sub { return _extract_hash_symbol_name(@_) },
  extract_scalar_symbol_name => sub { return _extract_scalar_symbol_name(@_) },
  lower_scalar_access_key_expr => sub { return _lower_scalar_access_key_expr(@_) },
  infer_scalar_container_kind => sub { return _infer_scalar_container_kind(@_) },
  split_top_level_csv => sub { return _split_top_level_csv(@_) },
  lower_assignment_source_expr => sub { return _lower_assignment_source_expr(@_) },
  strip_literal_delimiters => sub { return _strip_literal_delimiters(@_) },
 }
}

sub _declare_method_deps {
 return {
  trim_action_ir_value => sub { return _trim_action_ir_value(@_) },
  parse_method_function_expr => sub { return _parse_method_function_expr(@_) },
  is_bare_method_scope_token => sub { return _is_bare_method_scope_token(@_) },
  normalize_method_args_with_optional_scope => sub { return _normalize_method_args_with_optional_scope(@_) },
  lower_flow_composite_expr => sub { return _lower_flow_composite_expr(@_) },
  lower_method_value_expr => sub { return _lower_method_value_expr(@_) },
  declare_alias_to_type => sub { return _declare_alias_to_type(@_) },
  split_declare_symbol_names => sub { return _split_declare_symbol_names(@_) },
  parse_declare_binding_entry => sub { return _parse_declare_binding_entry(@_) },
  lower_typed_declare_statement => sub { return _lower_typed_declare_statement(@_) },
  lower_assign_statement => sub { return _lower_assign_statement(@_) },
 }
}

sub _array_pipeline_deps {
 return {
  trim_action_ir_value => sub { return _trim_action_ir_value(@_) },
  strip_literal_delimiters => sub { return _strip_literal_delimiters(@_) },
  extract_array_symbol_name => sub { return _extract_array_symbol_name(@_) },
  parse_method_function_expr => sub { return _parse_method_function_expr(@_) },
  is_bare_method_scope_token => sub { return _is_bare_method_scope_token(@_) },
  extract_scalar_symbol_name => sub { return _extract_scalar_symbol_name(@_) },
 }
}

sub _control_flow_deps {
 return {
  trim_action_ir_value => sub { return _trim_action_ir_value(@_) },
  normalize_method_tag_expr => sub { return _normalize_method_tag_expr(@_) },
  lower_flow_composite_expr => sub { return _lower_flow_composite_expr(@_) },
  parse_method_function_expr => sub { return _parse_method_function_expr(@_) },
  normalize_method_args_with_optional_scope => sub { return _normalize_method_args_with_optional_scope(@_) },
 }
}

sub _scan_contract_ir_event_deps {
 return {
  split_action_ir_statements => sub { return _split_action_ir_statements(@_) },
  trim_action_ir_value => sub { return _trim_action_ir_value(@_) },
  parse_method_function_expr => sub { return _parse_method_function_expr(@_) },
  normalize_method_args_with_optional_scope => sub { return _normalize_method_args_with_optional_scope(@_) },
  build_array_pipeline_plan_from_expr => sub { return _build_array_pipeline_plan_from_expr(@_) },
  extract_declare_statement_from_method_expr => sub { return _extract_declare_statement_from_method_expr(@_) },
  parse_declare_binding_entry => sub { return _parse_declare_binding_entry(@_) },
 }
}

sub _diagnostics_deps {
 return {
  split_action_ir_statements => sub { return _split_action_ir_statements(@_) },
  scan_contract_ir_events => sub { return _scan_contract_ir_events(@_) },
 }
}

sub _canonical_event_deps {
 return {
  trim_action_ir_value => sub { return _trim_action_ir_value(@_) },
  split_action_ir_statements => sub { return _split_action_ir_statements(@_) },
 }
}

sub _action_contract_deps {
 return {
  lower_return_general_statement => sub {
   _require_method_lowering_pkg();
   return LinkedSpec::ActionIR::MethodLowering::_lower_return_general_statement(@_, _method_lowering_deps())
  },
  lower_return_imatch_statement => sub {
   _require_method_lowering_pkg();
   return LinkedSpec::ActionIR::MethodLowering::_lower_return_imatch_statement(@_, _method_lowering_deps())
  },
  lower_assign_method_statement => sub {
   _require_declare_method_pkg();
   return LinkedSpec::ActionIR::DeclareMethod::_lower_assign_method_statement(@_, _declare_method_deps())
  },
  lower_push_value_statement => sub {
   _require_method_lowering_pkg();
   return LinkedSpec::ActionIR::MethodLowering::_lower_push_value_statement(@_, _method_lowering_deps())
  },
  lower_regex_subst_statement => sub {
   _require_method_lowering_pkg();
   return LinkedSpec::ActionIR::MethodLowering::_lower_regex_subst_statement(@_, _method_lowering_deps())
  },
  lower_array_pipeline_expr => sub {
   _require_array_pipeline_pkg();
   return LinkedSpec::ActionIR::ArrayPipeline::_lower_array_pipeline_expr(@_, _array_pipeline_deps())
  },
  lower_if_flow_statement => sub {
   _require_control_flow_pkg();
   return LinkedSpec::ActionIR::ControlFlow::_lower_if_flow_statement(@_, _control_flow_deps())
  },
  lower_elseif_flow_statement => sub {
   _require_control_flow_pkg();
   return LinkedSpec::ActionIR::ControlFlow::_lower_elseif_flow_statement(@_, _control_flow_deps())
  },
  lower_else_flow_statement => sub {
   _require_control_flow_pkg();
   return LinkedSpec::ActionIR::ControlFlow::_lower_else_flow_statement(@_, _control_flow_deps())
  },
  lower_endif_flow_statement => sub {
   _require_control_flow_pkg();
   return LinkedSpec::ActionIR::ControlFlow::_lower_endif_flow_statement(@_, _control_flow_deps())
  },
  lower_switch_flow_statement => sub {
   _require_control_flow_pkg();
   return LinkedSpec::ActionIR::ControlFlow::_lower_switch_flow_statement(@_, _control_flow_deps())
  },
  lower_case_flow_statement => sub {
   _require_control_flow_pkg();
   return LinkedSpec::ActionIR::ControlFlow::_lower_case_flow_statement(@_, _control_flow_deps())
  },
  lower_default_flow_statement => sub {
   _require_control_flow_pkg();
   return LinkedSpec::ActionIR::ControlFlow::_lower_default_flow_statement(@_, _control_flow_deps())
  },
  lower_endcase_flow_statement => sub {
   _require_control_flow_pkg();
   return LinkedSpec::ActionIR::ControlFlow::_lower_endcase_flow_statement(@_, _control_flow_deps())
  },
  lower_endswitch_flow_statement => sub {
   _require_control_flow_pkg();
   return LinkedSpec::ActionIR::ControlFlow::_lower_endswitch_flow_statement(@_, _control_flow_deps())
  },
  lower_say_statement => sub {
   _require_control_flow_pkg();
   return LinkedSpec::ActionIR::ControlFlow::_lower_say_statement(@_, _control_flow_deps())
  },
  lower_print_statement => sub {
   _require_control_flow_pkg();
   return LinkedSpec::ActionIR::ControlFlow::_lower_print_statement(@_, _control_flow_deps())
  },
  lower_return_undef_statement => sub {
   _require_method_lowering_pkg();
   return LinkedSpec::ActionIR::MethodLowering::_lower_return_undef_statement(@_, _method_lowering_deps())
  },
  lower_return_array_statement => sub {
   _require_method_lowering_pkg();
   return LinkedSpec::ActionIR::MethodLowering::_lower_return_array_statement(@_, _method_lowering_deps())
  },
  lower_declare_method_statement => sub {
   _require_declare_method_pkg();
   return LinkedSpec::ActionIR::DeclareMethod::_lower_declare_method_statement(@_, _declare_method_deps())
  },
 }
}

sub _lower_flow_composite_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_flow_expr_pkg();
  return LinkedSpec::ActionIR::FlowExpr::_lower_flow_composite_expr(@args, _flow_expr_deps())
 })
}

sub _extract_scalar_symbol_name {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_value_expr_pkg();
  return LinkedSpec::ActionIR::ValueExpr::_extract_scalar_symbol_name(@args, _value_expr_deps())
 })
}

sub _extract_array_symbol_name {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_value_expr_pkg();
  return LinkedSpec::ActionIR::ValueExpr::_extract_array_symbol_name(@args, _value_expr_deps())
 })
}

sub _extract_hash_symbol_name {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_value_expr_pkg();
  return LinkedSpec::ActionIR::ValueExpr::_extract_hash_symbol_name(@args, _value_expr_deps())
 })
}

sub _lower_scalar_access_key_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_value_expr_pkg();
  return LinkedSpec::ActionIR::ValueExpr::_lower_scalar_access_key_expr(@args, _value_expr_deps())
 })
}

sub _lower_scalaref_value_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_value_expr_pkg();
  return LinkedSpec::ActionIR::ValueExpr::_lower_scalaref_value_expr(@args, _value_expr_deps())
 })
}

sub _infer_scalar_container_kind {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_value_expr_pkg();
  return LinkedSpec::ActionIR::ValueExpr::_infer_scalar_container_kind(@args, _value_expr_deps())
 })
}

sub _lower_assignment_source_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_value_expr_pkg();
  return LinkedSpec::ActionIR::ValueExpr::_lower_assignment_source_expr(@args, _value_expr_deps())
 })
}

sub _strip_literal_delimiters {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_value_expr_pkg();
  return LinkedSpec::ActionIR::ValueExpr::_strip_literal_delimiters(@args, _value_expr_deps())
 })
}

sub _split_declare_symbol_names {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_declare_method_pkg();
  return LinkedSpec::ActionIR::DeclareMethod::_split_declare_symbol_names(@args, _declare_method_deps())
 })
}

sub _parse_declare_binding_entry {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_declare_method_pkg();
  return LinkedSpec::ActionIR::DeclareMethod::_parse_declare_binding_entry(@args, _declare_method_deps())
 })
}

sub _lower_declare_initializer_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_declare_method_pkg();
  return LinkedSpec::ActionIR::DeclareMethod::_lower_declare_initializer_expr(@args, _declare_method_deps())
 })
}

sub _lower_typed_declare_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_lower_typed_declare_statement(@args, _method_lowering_deps())
 })
}

sub _declare_alias_to_type {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_declare_alias_to_type(@args, _method_lowering_deps())
 })
}

sub _lower_assign_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_lower_assign_statement(@args, _method_lowering_deps())
 })
}

sub _lower_method_value_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr(@args, _method_lowering_deps())
 })
}

sub _lower_return_general_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_lower_return_general_statement(@args, _method_lowering_deps())
 })
}

sub _lower_return_imatch_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_lower_return_imatch_statement(@args, _method_lowering_deps())
 })
}

sub _lower_push_value_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_lower_push_value_statement(@args, _method_lowering_deps())
 })
}

sub _lower_regex_subst_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_lower_regex_subst_statement(@args, _method_lowering_deps())
 })
}

sub _lower_return_undef_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_lower_return_undef_statement(@args, _method_lowering_deps())
 })
}

sub _lower_return_array_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_lower_return_array_statement(@args, _method_lowering_deps())
 })
}

sub _extract_declare_statement_from_method_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_declare_method_pkg();
  return LinkedSpec::ActionIR::DeclareMethod::_extract_declare_statement_from_method_expr(@args, _declare_method_deps())
 })
}

sub _build_array_pipeline_plan_from_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_array_pipeline_pkg();
  return LinkedSpec::ActionIR::ArrayPipeline::_build_array_pipeline_plan_from_expr(@args, _array_pipeline_deps())
 })
}

sub _lower_array_pipeline_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_array_pipeline_pkg();
  return LinkedSpec::ActionIR::ArrayPipeline::_lower_array_pipeline_expr(@args, _array_pipeline_deps())
 })
}

sub _normalize_method_tag_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_normalize_method_tag_expr(@args, _method_lowering_deps())
 })
}

sub _build_action_lowering_contracts {
 my ($label) = @_;
 return _call_preserving_err(sub {
  _require_contracts_pkg();
  return LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts($label, _action_contract_deps())
 })
}

sub _scan_contract_ir_events {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_scanner_pkg();
  return LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(@args, _scan_contract_ir_event_deps())
 })
}

sub _find_unresolved_action_helpers {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_diagnostics_pkg();
  return LinkedSpec::ActionIR::Diagnostics::_find_unresolved_action_helpers(@args, _diagnostics_deps())
 })
}

sub _collect_action_helper_ir_nodes {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_diagnostics_pkg();
  return LinkedSpec::ActionIR::Diagnostics::_collect_action_helper_ir_nodes(@args, _diagnostics_deps())
 })
}

sub _build_canonical_action_ir_events {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_canonical_events_pkg();
  return LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events(@args, _canonical_event_deps())
 })
}

sub _canonicalize_helper_action_ir_event {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_canonical_events_pkg();
  return LinkedSpec::ActionIR::CanonicalEvents::_canonicalize_helper_action_ir_event(@args, _canonical_event_deps())
 })
}

sub _rewrite_pipeline_deps {
 return _call_preserving_err(sub {
  _require_rewrite_pipeline_pkg();
  return LinkedSpec::ActionIR::RewritePipeline::default_deps_for_package(__PACKAGE__)
 })
}

sub _rewrite_action_code_with_diagnostics {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_rewrite_pipeline_pkg();
  return LinkedSpec::ActionIR::RewritePipeline::_rewrite_action_code_with_diagnostics(@args, _rewrite_pipeline_deps())
 })
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
 return _call_preserving_err(sub {
  _require_rewrite_pipeline_pkg();
  return LinkedSpec::ActionIR::RewritePipeline::_lower_action_code_from_canonical_ir(@args)
 })
}

sub _build_action_rewrite_rules {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_rewrite_pipeline_pkg();
  return LinkedSpec::ActionIR::RewritePipeline::_build_action_rewrite_rules(@args, _rewrite_pipeline_deps())
 })
}

sub rewrite_action_code_for_compat {
 my ($label, $code) = @_;
 return _call_preserving_err(sub {
  my ($rewritten) = _rewrite_action_code_with_diagnostics($label, $code, undef);
  return $rewritten
 })
}

sub _normalize_rule_code_chunks {
 my ($label, $chunks, $rewrite_diag_acc, $rewrite_rules) = @_;

 my @normalized;
 foreach my $chunk (@$chunks) {
  my ($rewritten, $diag) = _rewrite_action_code_with_diagnostics($label, $chunk, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag) if $rewrite_diag_acc;
  $rewritten =~ s/\s*;\s*$//o;
  push @normalized, $rewritten;
 }

 return join ";\n", @normalized
}

sub _rewrite_acode_entries {
 my ($label, $acode_entries, $rewrite_rules, $rewrite_diag_acc) = @_;

 my @ACODEs;
 my @GDATA;
 foreach my $acode_entry (@$acode_entries) {
  my ($rewritten_acode, $diag) = _rewrite_action_code_with_diagnostics($label, $acode_entry->{code}, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag);
  push @ACODEs, $rewritten_acode;
  push @GDATA, {label => $acode_entry->{relabel}, idx => $acode_entry->{reidx}};
 }

 return (\@ACODEs, \@GDATA)
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
# Purpose : Build fully-rewritten emit context (ACODE/BCODE/gdata/lifecycle
#           chunks) plus rich action-rewriter diagnostics metadata.
# Args    : ($rule_ir)
# Returns : hashref emit context
#------------------------------------------------------------------------------
sub build_rule_ir_emit_context {
 my ($rule_ir) = @_;
 my $label = $rule_ir->{label};
 my $rewrite_rules = _build_action_rewrite_rules($label);
 my $rewrite_diag_acc = _build_rewrite_diag_acc();

 my ($acodes, $gdata) = _rewrite_acode_entries(
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
  GDATA     => $gdata,
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
