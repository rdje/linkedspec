package LinkedSpec::ActionRewriter;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
sub _require_pkg {
 my ($pkg) = @_;
 (my $path = "$pkg.pm") =~ s{::}{/}g;
 require $path;
 return $pkg
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

sub _require_emit_context_pkg {
 return _require_pkg('LinkedSpec::RuleIR::EmitContext')
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

sub _trim_action_ir_value {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s*|\s*$//go;
 return $value
}
sub _declare_method_deps {
 return _call_preserving_err(sub {
  _require_declare_method_pkg();
  return LinkedSpec::ActionIR::DeclareMethod::default_deps_for_package(__PACKAGE__)
 })
}
sub _flow_expr_deps {
 return _call_preserving_err(sub {
  _require_flow_expr_pkg();
  return LinkedSpec::ActionIR::FlowExpr::default_deps_for_package(__PACKAGE__)
 })
}
sub _method_lowering_deps {
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::default_deps_for_package(__PACKAGE__)
 })
}
sub _array_pipeline_deps {
 return _call_preserving_err(sub {
  _require_array_pipeline_pkg();
  return LinkedSpec::ActionIR::ArrayPipeline::default_deps_for_package(__PACKAGE__)
 })
}
sub _control_flow_deps {
 return _call_preserving_err(sub {
  _require_control_flow_pkg();
  return LinkedSpec::ActionIR::ControlFlow::default_deps_for_package(__PACKAGE__)
 })
}
sub _parse_method_function_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_parse_method_function_expr(@args)
 })
}

sub _is_bare_method_scope_token {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_is_bare_method_scope_token(@args)
 })
}

sub _normalize_method_args_with_optional_scope {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_normalize_method_args_with_optional_scope(@args)
 })
}

sub _split_top_level_csv {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_split_top_level_csv(@args)
 })
}

sub _lower_flow_composite_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_flow_expr_pkg();
  return LinkedSpec::ActionIR::FlowExpr::_lower_flow_composite_expr(@args, _flow_expr_deps())
 })
}

sub _declare_alias_to_type {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_declare_alias_to_type(@args, _method_lowering_deps())
 })
}

sub _lower_typed_declare_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_lower_typed_declare_statement(@args, _method_lowering_deps())
 })
}

sub _normalize_method_tag_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_normalize_method_tag_expr(@args, _method_lowering_deps())
 })
}

sub _extract_scalar_symbol_name {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_extract_scalar_symbol_name(@args)
 })
}

sub _extract_array_symbol_name {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_extract_array_symbol_name(@args)
 })
}

sub _extract_hash_symbol_name {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_extract_hash_symbol_name(@args)
 })
}

sub _lower_scalar_access_key_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_lower_scalar_access_key_expr(@args)
 })
}

sub _lower_scalaref_value_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_lower_scalaref_value_expr(@args)
 })
}

sub _infer_scalar_container_kind {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_infer_scalar_container_kind(@args)
 })
}

sub _lower_assignment_source_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_lower_assignment_source_expr(@args)
 })
}

sub _strip_literal_delimiters {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_strip_literal_delimiters(@args)
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

sub _lower_declare_value_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_declare_method_pkg();
  return LinkedSpec::ActionIR::DeclareMethod::_lower_declare_value_expr(@args, _declare_method_deps())
 })
}

sub _lower_declare_initializer_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_declare_method_pkg();
  return LinkedSpec::ActionIR::DeclareMethod::_lower_declare_initializer_expr(@args, _declare_method_deps())
 })
}

sub _extract_declare_statement_from_method_expr {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_declare_method_pkg();
  return LinkedSpec::ActionIR::DeclareMethod::_extract_declare_statement_from_method_expr(@args, _declare_method_deps())
 })
}

sub _lower_declare_method_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_declare_method_pkg();
  return LinkedSpec::ActionIR::DeclareMethod::_lower_declare_method_statement(@args, _declare_method_deps())
 })
}

sub _lower_assign_method_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_declare_method_pkg();
  return LinkedSpec::ActionIR::DeclareMethod::_lower_assign_method_statement(@args, _declare_method_deps())
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

sub _lower_assign_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_method_lowering_pkg();
  return LinkedSpec::ActionIR::MethodLowering::_lower_assign_statement(@args, _method_lowering_deps())
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

sub _lower_if_flow_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_control_flow_pkg();
  return LinkedSpec::ActionIR::ControlFlow::_lower_if_flow_statement(@args, _control_flow_deps())
 })
}

sub _lower_elseif_flow_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_control_flow_pkg();
  return LinkedSpec::ActionIR::ControlFlow::_lower_elseif_flow_statement(@args, _control_flow_deps())
 })
}

sub _lower_else_flow_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_control_flow_pkg();
  return LinkedSpec::ActionIR::ControlFlow::_lower_else_flow_statement(@args, _control_flow_deps())
 })
}

sub _lower_endif_flow_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_control_flow_pkg();
  return LinkedSpec::ActionIR::ControlFlow::_lower_endif_flow_statement(@args, _control_flow_deps())
 })
}

sub _lower_switch_flow_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_control_flow_pkg();
  return LinkedSpec::ActionIR::ControlFlow::_lower_switch_flow_statement(@args, _control_flow_deps())
 })
}

sub _lower_case_flow_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_control_flow_pkg();
  return LinkedSpec::ActionIR::ControlFlow::_lower_case_flow_statement(@args, _control_flow_deps())
 })
}

sub _lower_default_flow_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_control_flow_pkg();
  return LinkedSpec::ActionIR::ControlFlow::_lower_default_flow_statement(@args, _control_flow_deps())
 })
}

sub _lower_endcase_flow_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_control_flow_pkg();
  return LinkedSpec::ActionIR::ControlFlow::_lower_endcase_flow_statement(@args, _control_flow_deps())
 })
}

sub _lower_endswitch_flow_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_control_flow_pkg();
  return LinkedSpec::ActionIR::ControlFlow::_lower_endswitch_flow_statement(@args, _control_flow_deps())
 })
}

sub _lower_say_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_control_flow_pkg();
  return LinkedSpec::ActionIR::ControlFlow::_lower_say_statement(@args, _control_flow_deps())
 })
}

sub _lower_print_statement {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_control_flow_pkg();
  return LinkedSpec::ActionIR::ControlFlow::_lower_print_statement(@args, _control_flow_deps())
 })
}

sub _build_action_lowering_contracts {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_build_action_lowering_contracts(@args)
 })
}

sub _scan_contract_ir_events {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_scan_contract_ir_events(@args)
 })
}

sub _find_unresolved_action_helpers {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_find_unresolved_action_helpers(@args)
 })
}

sub _collect_action_helper_ir_nodes {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_collect_action_helper_ir_nodes(@args)
 })
}

sub _canonicalize_helper_action_ir_event {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_canonicalize_helper_action_ir_event(@args)
 })
}

sub _split_action_ir_statements {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_split_action_ir_statements(@args)
 })
}
sub _build_canonical_action_ir_events {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_build_canonical_action_ir_events(@args)
 })
}

sub _lower_action_code_from_canonical_ir {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_lower_action_code_from_canonical_ir(@args)
 })
}

sub _accumulate_action_rewrite_diagnostics {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_accumulate_action_rewrite_diagnostics(@args)
 })
}

sub _rewrite_action_code_with_diagnostics {
 my ($label, $code, $rewrite_rules) = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics(
   $label,
   $code,
   $rewrite_rules,
  )
 })
}

sub _build_action_rewrite_rules {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::_build_action_rewrite_rules(@args)
 })
}

sub call_spec_handler_subst {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_emit_context_pkg();
  return LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat(@args)
 })
}

1;
