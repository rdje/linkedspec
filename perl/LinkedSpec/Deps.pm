package LinkedSpec::Deps;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _require_pkg_cb {
 my ($pkg, $name) = @_;
 my $code = $pkg->can($name);
 die "(LinkedSpec::Deps::_require_pkg_cb) -E- missing callback '$pkg\::$name'"
  unless ref($code) eq 'CODE';
 return $code
}

sub _require_pkg_value {
 my ($pkg, $name) = @_;
 my $cb = _require_pkg_cb($pkg, $name);
 return $cb->()
}

sub flow_expr_deps_for_package {
 my ($pkg) = @_;
 return {
  trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
  extract_array_symbol_name => _require_pkg_cb($pkg, '_extract_array_symbol_name'),
  extract_scalar_symbol_name => _require_pkg_cb($pkg, '_extract_scalar_symbol_name'),
  lower_method_value_expr => _require_pkg_cb($pkg, '_lower_method_value_expr'),
  parse_method_function_expr => _require_pkg_cb($pkg, '_parse_method_function_expr'),
  normalize_method_args_with_optional_scope => _require_pkg_cb($pkg, '_normalize_method_args_with_optional_scope'),
 }
}

sub method_lowering_deps_for_package {
 my ($pkg) = @_;
 return {
  trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
  split_declare_symbol_names => _require_pkg_cb($pkg, '_split_declare_symbol_names'),
  parse_declare_binding_entry => _require_pkg_cb($pkg, '_parse_declare_binding_entry'),
  lower_declare_initializer_expr => _require_pkg_cb($pkg, '_lower_declare_initializer_expr'),
  parse_method_function_expr => _require_pkg_cb($pkg, '_parse_method_function_expr'),
  normalize_method_args_with_optional_scope => _require_pkg_cb($pkg, '_normalize_method_args_with_optional_scope'),
  lower_scalaref_value_expr => _require_pkg_cb($pkg, '_lower_scalaref_value_expr'),
  extract_array_symbol_name => _require_pkg_cb($pkg, '_extract_array_symbol_name'),
  extract_hash_symbol_name => _require_pkg_cb($pkg, '_extract_hash_symbol_name'),
  extract_scalar_symbol_name => _require_pkg_cb($pkg, '_extract_scalar_symbol_name'),
  lower_scalar_access_key_expr => _require_pkg_cb($pkg, '_lower_scalar_access_key_expr'),
  infer_scalar_container_kind => _require_pkg_cb($pkg, '_infer_scalar_container_kind'),
  split_top_level_csv => _require_pkg_cb($pkg, '_split_top_level_csv'),
  lower_assignment_source_expr => _require_pkg_cb($pkg, '_lower_assignment_source_expr'),
  strip_literal_delimiters => _require_pkg_cb($pkg, '_strip_literal_delimiters'),
 }
}

sub array_pipeline_deps_for_package {
 my ($pkg) = @_;
 return {
  trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
  strip_literal_delimiters => _require_pkg_cb($pkg, '_strip_literal_delimiters'),
  extract_array_symbol_name => _require_pkg_cb($pkg, '_extract_array_symbol_name'),
  parse_method_function_expr => _require_pkg_cb($pkg, '_parse_method_function_expr'),
  is_bare_method_scope_token => _require_pkg_cb($pkg, '_is_bare_method_scope_token'),
  extract_scalar_symbol_name => _require_pkg_cb($pkg, '_extract_scalar_symbol_name'),
 }
}

sub control_flow_deps_for_package {
 my ($pkg) = @_;
 return {
  trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
  normalize_method_tag_expr => _require_pkg_cb($pkg, '_normalize_method_tag_expr'),
  lower_flow_composite_expr => _require_pkg_cb($pkg, '_lower_flow_composite_expr'),
  parse_method_function_expr => _require_pkg_cb($pkg, '_parse_method_function_expr'),
  normalize_method_args_with_optional_scope => _require_pkg_cb($pkg, '_normalize_method_args_with_optional_scope'),
 }
}

sub value_expr_deps_for_package {
 my ($pkg) = @_;
 return {
  trim_action_ir_value      => _require_pkg_cb($pkg, '_trim_action_ir_value'),
  lower_flow_composite_expr => _require_pkg_cb($pkg, '_lower_flow_composite_expr'),
  lower_method_value_expr   => _require_pkg_cb($pkg, '_lower_method_value_expr'),
 }
}

sub declare_method_deps_for_package {
 my ($pkg) = @_;
 return {
  trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
  parse_method_function_expr => _require_pkg_cb($pkg, '_parse_method_function_expr'),
  is_bare_method_scope_token => _require_pkg_cb($pkg, '_is_bare_method_scope_token'),
  normalize_method_args_with_optional_scope => _require_pkg_cb($pkg, '_normalize_method_args_with_optional_scope'),
  lower_flow_composite_expr => _require_pkg_cb($pkg, '_lower_flow_composite_expr'),
  lower_method_value_expr => _require_pkg_cb($pkg, '_lower_method_value_expr'),
  declare_alias_to_type => _require_pkg_cb($pkg, '_declare_alias_to_type'),
  lower_typed_declare_statement => _require_pkg_cb($pkg, '_lower_typed_declare_statement'),
  lower_assign_statement => _require_pkg_cb($pkg, '_lower_assign_statement'),
 }
}
sub action_rewriter_declare_method_deps_for_package {
 my ($pkg) = @_;
 return {
  trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
  parse_method_function_expr => _require_pkg_cb('LinkedSpec::ActionIR::MethodExpr', '_parse_method_function_expr'),
  is_bare_method_scope_token => _require_pkg_cb('LinkedSpec::ActionIR::MethodExpr', '_is_bare_method_scope_token'),
  normalize_method_args_with_optional_scope => _require_pkg_cb('LinkedSpec::ActionIR::MethodExpr', '_normalize_method_args_with_optional_scope'),
  lower_flow_composite_expr => _require_pkg_cb('LinkedSpec', '_lower_flow_composite_expr'),
  lower_method_value_expr => _require_pkg_cb('LinkedSpec', '_lower_method_value_expr'),
  declare_alias_to_type => _require_pkg_cb('LinkedSpec', '_declare_alias_to_type'),
  lower_typed_declare_statement => _require_pkg_cb('LinkedSpec', '_lower_typed_declare_statement'),
  lower_assign_statement => _require_pkg_cb('LinkedSpec', '_lower_assign_statement'),
 }
}

sub action_rewriter_statement_split_deps_for_package {
 my ($pkg) = @_;
 return {
  trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
 }
}

sub action_rewriter_canonical_event_deps_for_package {
 my ($pkg) = @_;
 return {
  trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
  split_action_ir_statements => _require_pkg_cb($pkg, '_split_action_ir_statements'),
 }
}

sub action_rewriter_scanner_deps_for_package {
 my ($pkg) = @_;
 return {
  split_action_ir_statements => _require_pkg_cb($pkg, '_split_action_ir_statements'),
  trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
  parse_method_function_expr => _require_pkg_cb('LinkedSpec::ActionIR::MethodExpr', '_parse_method_function_expr'),
  normalize_method_args_with_optional_scope => _require_pkg_cb('LinkedSpec::ActionIR::MethodExpr', '_normalize_method_args_with_optional_scope'),
  build_array_pipeline_plan_from_expr => _require_pkg_cb('LinkedSpec', '_build_array_pipeline_plan_from_expr'),
  extract_declare_statement_from_method_expr => _require_pkg_cb($pkg, '_extract_declare_statement_from_method_expr'),
  parse_declare_binding_entry => _require_pkg_cb($pkg, '_parse_declare_binding_entry'),
 }
}

sub action_rewriter_diagnostics_deps_for_package {
 my ($pkg) = @_;
 return {
  split_action_ir_statements => _require_pkg_cb($pkg, '_split_action_ir_statements'),
  scan_contract_ir_events => _require_pkg_cb($pkg, '_scan_contract_ir_events'),
 }
}

sub action_rewriter_rewrite_pipeline_deps_for_package {
 my ($pkg) = @_;
 return {
  build_action_lowering_contracts => _require_pkg_cb($pkg, '_build_action_lowering_contracts'),
  collect_action_helper_ir_nodes => _require_pkg_cb($pkg, '_collect_action_helper_ir_nodes'),
  build_canonical_action_ir_events => _require_pkg_cb($pkg, '_build_canonical_action_ir_events'),
  find_unresolved_action_helpers => _require_pkg_cb($pkg, '_find_unresolved_action_helpers'),
 }
}

sub action_rewriter_contract_deps_for_package {
 my ($pkg) = @_;
 return {
  lower_return_general_statement => _require_pkg_cb('LinkedSpec', '_lower_return_general_statement'),
  lower_return_imatch_statement  => _require_pkg_cb('LinkedSpec', '_lower_return_imatch_statement'),
  lower_assign_method_statement  => _require_pkg_cb($pkg, '_lower_assign_method_statement'),
  lower_push_value_statement     => _require_pkg_cb('LinkedSpec', '_lower_push_value_statement'),
  lower_regex_subst_statement    => _require_pkg_cb('LinkedSpec', '_lower_regex_subst_statement'),
  lower_array_pipeline_expr      => _require_pkg_cb('LinkedSpec', '_lower_array_pipeline_expr'),
  lower_if_flow_statement        => _require_pkg_cb('LinkedSpec', '_lower_if_flow_statement'),
  lower_elseif_flow_statement    => _require_pkg_cb('LinkedSpec', '_lower_elseif_flow_statement'),
  lower_else_flow_statement      => _require_pkg_cb('LinkedSpec', '_lower_else_flow_statement'),
  lower_endif_flow_statement     => _require_pkg_cb('LinkedSpec', '_lower_endif_flow_statement'),
  lower_switch_flow_statement    => _require_pkg_cb('LinkedSpec', '_lower_switch_flow_statement'),
  lower_case_flow_statement      => _require_pkg_cb('LinkedSpec', '_lower_case_flow_statement'),
  lower_default_flow_statement   => _require_pkg_cb('LinkedSpec', '_lower_default_flow_statement'),
  lower_endcase_flow_statement   => _require_pkg_cb('LinkedSpec', '_lower_endcase_flow_statement'),
  lower_endswitch_flow_statement => _require_pkg_cb('LinkedSpec', '_lower_endswitch_flow_statement'),
  lower_say_statement            => _require_pkg_cb('LinkedSpec', '_lower_say_statement'),
  lower_print_statement          => _require_pkg_cb('LinkedSpec', '_lower_print_statement'),
  lower_return_undef_statement   => _require_pkg_cb('LinkedSpec', '_lower_return_undef_statement'),
  lower_return_array_statement   => _require_pkg_cb('LinkedSpec', '_lower_return_array_statement'),
  lower_declare_method_statement => _require_pkg_cb($pkg, '_lower_declare_method_statement'),
 }
}

sub parser_factory_deps_for_package {
 my ($pkg) = @_;
 return {
  apply_trace_options => _require_pkg_cb($pkg, '_apply_trace_options'),
  trace_enter => _require_pkg_cb($pkg, 'trace_enter'),
  trace_exit => _require_pkg_cb($pkg, 'trace_exit'),
  trace_decision => _require_pkg_cb($pkg, 'trace_decision'),
  validate_spec_name => _require_pkg_cb('LinkedSpec::Resolver', 'validate_spec_name'),
  resolve_spec_path => _require_pkg_cb('LinkedSpec::Resolver', 'resolve_spec_path'),
  load_spec_content => _require_pkg_cb('LinkedSpec::Resolver', 'load_spec_content'),
  compile_spec => _require_pkg_cb($pkg, 'Get'),
  dump_low => _require_pkg_value($pkg, 'DUMP_LOW'),
  dump_medium => _require_pkg_value($pkg, 'DUMP_MEDIUM'),
 }
}

1;
