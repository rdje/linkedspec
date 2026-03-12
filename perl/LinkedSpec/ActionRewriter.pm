package LinkedSpec::ActionRewriter;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::ActionIR::DeclareMethod ();
use LinkedSpec::ActionIR::MethodLowering ();

sub _require_pkg {
 my ($pkg) = @_;
 (my $path = "$pkg.pm") =~ s{::}{/}g;
 require $path;
 return $pkg
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

sub _require_rewrite_pipeline_pkg {
 return _require_pkg('LinkedSpec::ActionIR::RewritePipeline')
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

sub _require_value_expr_pkg {
 return _require_pkg('LinkedSpec::ActionIR::ValueExpr')
}

sub _trim_action_ir_value {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s*|\s*$//go;
 return $value
}
sub _declare_method_deps {
 _require_method_expr_pkg();
 return LinkedSpec::ActionIR::DeclareMethod::default_deps_for_package(__PACKAGE__)
}
sub _flow_expr_deps {
 _require_flow_expr_pkg();
 return LinkedSpec::ActionIR::FlowExpr::default_deps_for_package(__PACKAGE__)
}
sub _method_lowering_deps {
 return LinkedSpec::ActionIR::MethodLowering::default_deps_for_package(__PACKAGE__)
}
sub _array_pipeline_deps {
 _require_array_pipeline_pkg();
 return LinkedSpec::ActionIR::ArrayPipeline::default_deps_for_package(__PACKAGE__)
}
sub _control_flow_deps {
 _require_control_flow_pkg();
 return LinkedSpec::ActionIR::ControlFlow::default_deps_for_package(__PACKAGE__)
}
sub _value_expr_deps {
 _require_value_expr_pkg();
 return LinkedSpec::ActionIR::ValueExpr::default_deps_for_package(__PACKAGE__)
}
sub _statement_split_deps {
 _require_statement_split_pkg();
 return LinkedSpec::ActionIR::StatementSplit::default_deps_for_package(__PACKAGE__)
}
sub _canonical_event_deps {
 _require_canonical_events_pkg();
 return LinkedSpec::ActionIR::CanonicalEvents::default_deps_for_package(__PACKAGE__)
}
sub _diagnostics_deps {
 _require_diagnostics_pkg();
 return LinkedSpec::ActionIR::Diagnostics::default_deps_for_package(__PACKAGE__)
}
sub _rewrite_pipeline_deps {
 _require_rewrite_pipeline_pkg();
 return LinkedSpec::ActionIR::RewritePipeline::default_deps_for_package(__PACKAGE__)
}
sub _scan_contract_ir_event_deps {
 _require_method_expr_pkg();
 _require_scanner_pkg();
 return LinkedSpec::ActionIR::Scanner::default_deps_for_package(__PACKAGE__)
}

sub _parse_method_function_expr {
 _require_method_expr_pkg();
 return LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr(@_)
}

sub _is_bare_method_scope_token {
 _require_method_expr_pkg();
 return LinkedSpec::ActionIR::MethodExpr::_is_bare_method_scope_token(@_)
}

sub _normalize_method_args_with_optional_scope {
 _require_method_expr_pkg();
 return LinkedSpec::ActionIR::MethodExpr::_normalize_method_args_with_optional_scope(@_)
}

sub _split_top_level_csv {
 _require_method_expr_pkg();
 return LinkedSpec::ActionIR::MethodExpr::_split_top_level_csv(@_)
}

sub _lower_flow_composite_expr {
 _require_flow_expr_pkg();
 return LinkedSpec::ActionIR::FlowExpr::_lower_flow_composite_expr(@_, _flow_expr_deps())
}

sub _declare_alias_to_type {
 return LinkedSpec::ActionIR::MethodLowering::_declare_alias_to_type(@_, _method_lowering_deps())
}

sub _lower_typed_declare_statement {
 return LinkedSpec::ActionIR::MethodLowering::_lower_typed_declare_statement(@_, _method_lowering_deps())
}

sub _normalize_method_tag_expr {
 return LinkedSpec::ActionIR::MethodLowering::_normalize_method_tag_expr(@_, _method_lowering_deps())
}

sub _extract_scalar_symbol_name {
 _require_value_expr_pkg();
 return LinkedSpec::ActionIR::ValueExpr::_extract_scalar_symbol_name(@_, _value_expr_deps())
}

sub _extract_array_symbol_name {
 _require_value_expr_pkg();
 return LinkedSpec::ActionIR::ValueExpr::_extract_array_symbol_name(@_, _value_expr_deps())
}

sub _extract_hash_symbol_name {
 _require_value_expr_pkg();
 return LinkedSpec::ActionIR::ValueExpr::_extract_hash_symbol_name(@_, _value_expr_deps())
}

sub _lower_scalar_access_key_expr {
 _require_value_expr_pkg();
 return LinkedSpec::ActionIR::ValueExpr::_lower_scalar_access_key_expr(@_, _value_expr_deps())
}

sub _lower_scalaref_value_expr {
 _require_value_expr_pkg();
 return LinkedSpec::ActionIR::ValueExpr::_lower_scalaref_value_expr(@_, _value_expr_deps())
}

sub _infer_scalar_container_kind {
 _require_value_expr_pkg();
 return LinkedSpec::ActionIR::ValueExpr::_infer_scalar_container_kind(@_, _value_expr_deps())
}

sub _lower_assignment_source_expr {
 _require_value_expr_pkg();
 return LinkedSpec::ActionIR::ValueExpr::_lower_assignment_source_expr(@_, _value_expr_deps())
}

sub _strip_literal_delimiters {
 _require_value_expr_pkg();
 return LinkedSpec::ActionIR::ValueExpr::_strip_literal_delimiters(@_, _value_expr_deps())
}

sub _split_declare_symbol_names {
 return LinkedSpec::ActionIR::DeclareMethod::_split_declare_symbol_names(@_, _declare_method_deps())
}

sub _parse_declare_binding_entry {
 return LinkedSpec::ActionIR::DeclareMethod::_parse_declare_binding_entry(@_, _declare_method_deps())
}

sub _lower_declare_value_expr {
 return LinkedSpec::ActionIR::DeclareMethod::_lower_declare_value_expr(@_, _declare_method_deps())
}

sub _lower_declare_initializer_expr {
 return LinkedSpec::ActionIR::DeclareMethod::_lower_declare_initializer_expr(@_, _declare_method_deps())
}

sub _extract_declare_statement_from_method_expr {
 return LinkedSpec::ActionIR::DeclareMethod::_extract_declare_statement_from_method_expr(@_, _declare_method_deps())
}

sub _lower_declare_method_statement {
 return LinkedSpec::ActionIR::DeclareMethod::_lower_declare_method_statement(@_, _declare_method_deps())
}

sub _lower_assign_method_statement {
 return LinkedSpec::ActionIR::DeclareMethod::_lower_assign_method_statement(@_, _declare_method_deps())
}

sub _lower_method_value_expr {
 return LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr(@_, _method_lowering_deps())
}

sub _lower_return_general_statement {
 return LinkedSpec::ActionIR::MethodLowering::_lower_return_general_statement(@_, _method_lowering_deps())
}

sub _lower_return_imatch_statement {
 return LinkedSpec::ActionIR::MethodLowering::_lower_return_imatch_statement(@_, _method_lowering_deps())
}

sub _lower_assign_statement {
 return LinkedSpec::ActionIR::MethodLowering::_lower_assign_statement(@_, _method_lowering_deps())
}

sub _lower_push_value_statement {
 return LinkedSpec::ActionIR::MethodLowering::_lower_push_value_statement(@_, _method_lowering_deps())
}

sub _lower_regex_subst_statement {
 return LinkedSpec::ActionIR::MethodLowering::_lower_regex_subst_statement(@_, _method_lowering_deps())
}

sub _lower_return_undef_statement {
 return LinkedSpec::ActionIR::MethodLowering::_lower_return_undef_statement(@_, _method_lowering_deps())
}

sub _lower_return_array_statement {
 return LinkedSpec::ActionIR::MethodLowering::_lower_return_array_statement(@_, _method_lowering_deps())
}

sub _build_array_pipeline_plan_from_expr {
 _require_array_pipeline_pkg();
 return LinkedSpec::ActionIR::ArrayPipeline::_build_array_pipeline_plan_from_expr(@_, _array_pipeline_deps())
}

sub _lower_array_pipeline_expr {
 _require_array_pipeline_pkg();
 return LinkedSpec::ActionIR::ArrayPipeline::_lower_array_pipeline_expr(@_, _array_pipeline_deps())
}

sub _lower_if_flow_statement {
 _require_control_flow_pkg();
 return LinkedSpec::ActionIR::ControlFlow::_lower_if_flow_statement(@_, _control_flow_deps())
}

sub _lower_elseif_flow_statement {
 _require_control_flow_pkg();
 return LinkedSpec::ActionIR::ControlFlow::_lower_elseif_flow_statement(@_, _control_flow_deps())
}

sub _lower_else_flow_statement {
 _require_control_flow_pkg();
 return LinkedSpec::ActionIR::ControlFlow::_lower_else_flow_statement(@_, _control_flow_deps())
}

sub _lower_endif_flow_statement {
 _require_control_flow_pkg();
 return LinkedSpec::ActionIR::ControlFlow::_lower_endif_flow_statement(@_, _control_flow_deps())
}

sub _lower_switch_flow_statement {
 _require_control_flow_pkg();
 return LinkedSpec::ActionIR::ControlFlow::_lower_switch_flow_statement(@_, _control_flow_deps())
}

sub _lower_case_flow_statement {
 _require_control_flow_pkg();
 return LinkedSpec::ActionIR::ControlFlow::_lower_case_flow_statement(@_, _control_flow_deps())
}

sub _lower_default_flow_statement {
 _require_control_flow_pkg();
 return LinkedSpec::ActionIR::ControlFlow::_lower_default_flow_statement(@_, _control_flow_deps())
}

sub _lower_endcase_flow_statement {
 _require_control_flow_pkg();
 return LinkedSpec::ActionIR::ControlFlow::_lower_endcase_flow_statement(@_, _control_flow_deps())
}

sub _lower_endswitch_flow_statement {
 _require_control_flow_pkg();
 return LinkedSpec::ActionIR::ControlFlow::_lower_endswitch_flow_statement(@_, _control_flow_deps())
}

sub _lower_say_statement {
 _require_control_flow_pkg();
 return LinkedSpec::ActionIR::ControlFlow::_lower_say_statement(@_, _control_flow_deps())
}

sub _lower_print_statement {
 _require_control_flow_pkg();
 return LinkedSpec::ActionIR::ControlFlow::_lower_print_statement(@_, _control_flow_deps())
}

sub _action_contract_deps {
 _require_contracts_pkg();
 return LinkedSpec::ActionIR::Contracts::default_deps_for_package(__PACKAGE__)
}

sub _build_action_lowering_contracts {
 my ($label) = @_;
 _require_contracts_pkg();
 return LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts(
  $label,
  _action_contract_deps(),
 )
}

sub _scan_contract_ir_events {
 my ($contract, $code) = @_;
 _require_scanner_pkg();
 return LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
  $contract,
  $code,
  _scan_contract_ir_event_deps(),
 )
}

sub _find_unresolved_action_helpers {
 _require_diagnostics_pkg();
 return LinkedSpec::ActionIR::Diagnostics::_find_unresolved_action_helpers(@_, _diagnostics_deps())
}

sub _collect_action_helper_ir_nodes {
 _require_diagnostics_pkg();
 return LinkedSpec::ActionIR::Diagnostics::_collect_action_helper_ir_nodes(@_, _diagnostics_deps())
}

sub _canonicalize_helper_action_ir_event {
 _require_canonical_events_pkg();
 return LinkedSpec::ActionIR::CanonicalEvents::_canonicalize_helper_action_ir_event(@_, _canonical_event_deps())
}

sub _split_action_ir_statements {
 _require_statement_split_pkg();
 return LinkedSpec::ActionIR::StatementSplit::_split_action_ir_statements(@_, _statement_split_deps())
}
sub _build_canonical_action_ir_events {
 _require_canonical_events_pkg();
 return LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events(@_, _canonical_event_deps())
}

sub _lower_action_code_from_canonical_ir {
 _require_rewrite_pipeline_pkg();
 return LinkedSpec::ActionIR::RewritePipeline::_lower_action_code_from_canonical_ir(@_)
}

sub _accumulate_action_rewrite_diagnostics {
 _require_diagnostics_pkg();
 return LinkedSpec::ActionIR::Diagnostics::_accumulate_action_rewrite_diagnostics(@_)
}

sub _rewrite_action_code_with_diagnostics {
 my ($label, $code, $rewrite_rules) = @_;
 _require_rewrite_pipeline_pkg();
 return LinkedSpec::ActionIR::RewritePipeline::_rewrite_action_code_with_diagnostics(
  $label,
  $code,
  $rewrite_rules,
  _rewrite_pipeline_deps(),
 )
}

sub _build_action_rewrite_rules {
 _require_rewrite_pipeline_pkg();
 return LinkedSpec::ActionIR::RewritePipeline::_build_action_rewrite_rules(@_, _rewrite_pipeline_deps())
}

sub call_spec_handler_subst {
my ($label, $code) = @_;

 ($code) = _rewrite_action_code_with_diagnostics($label, $code);
 return $code
}

1;
