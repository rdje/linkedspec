package LinkedSpec::ActionRewriter;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::MethodExpr ();
use LinkedSpec::ActionIR::DeclareMethod ();
use LinkedSpec::ActionIR::CanonicalEvents ();
use LinkedSpec::ActionIR::Contracts ();
use LinkedSpec::ActionIR::StatementSplit ();
use LinkedSpec::ActionIR::Diagnostics ();
use LinkedSpec::ActionIR::RewritePipeline ();

sub _trim_action_ir_value {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s*|\s*$//go;
 return $value
}
sub _declare_method_deps {
 return {
  trim_action_ir_value => \&_trim_action_ir_value,
  parse_method_function_expr => \&LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr,
  is_bare_method_scope_token => \&LinkedSpec::ActionIR::MethodExpr::_is_bare_method_scope_token,
  normalize_method_args_with_optional_scope => \&LinkedSpec::ActionIR::MethodExpr::_normalize_method_args_with_optional_scope,
  lower_flow_composite_expr => \&LinkedSpec::_lower_flow_composite_expr,
  lower_method_value_expr => \&LinkedSpec::_lower_method_value_expr,
  declare_alias_to_type => \&LinkedSpec::_declare_alias_to_type,
  lower_typed_declare_statement => \&LinkedSpec::_lower_typed_declare_statement,
  lower_assign_statement => \&LinkedSpec::_lower_assign_statement,
 }
}
sub _statement_split_deps {
 return {
  trim_action_ir_value => \&_trim_action_ir_value,
 }
}
sub _canonical_event_deps {
 return {
  trim_action_ir_value => \&_trim_action_ir_value,
  split_action_ir_statements => \&_split_action_ir_statements,
 }
}
sub _diagnostics_deps {
 return {
  split_action_ir_statements => \&_split_action_ir_statements,
  scan_contract_ir_events => \&_scan_contract_ir_events,
 }
}
sub _rewrite_pipeline_deps {
 return {
  build_action_lowering_contracts => \&_build_action_lowering_contracts,
  collect_action_helper_ir_nodes => \&_collect_action_helper_ir_nodes,
  build_canonical_action_ir_events => \&_build_canonical_action_ir_events,
  find_unresolved_action_helpers => \&_find_unresolved_action_helpers,
 }
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

sub _action_contract_deps {
 return {
  lower_return_general_statement => \&LinkedSpec::_lower_return_general_statement,
  lower_return_imatch_statement  => \&LinkedSpec::_lower_return_imatch_statement,
  lower_assign_method_statement  => \&_lower_assign_method_statement,
  lower_regex_subst_statement    => \&LinkedSpec::_lower_regex_subst_statement,
  lower_array_pipeline_expr      => \&LinkedSpec::_lower_array_pipeline_expr,
  lower_if_flow_statement        => \&LinkedSpec::_lower_if_flow_statement,
  lower_elseif_flow_statement    => \&LinkedSpec::_lower_elseif_flow_statement,
  lower_else_flow_statement      => \&LinkedSpec::_lower_else_flow_statement,
  lower_endif_flow_statement     => \&LinkedSpec::_lower_endif_flow_statement,
  lower_switch_flow_statement    => \&LinkedSpec::_lower_switch_flow_statement,
  lower_case_flow_statement      => \&LinkedSpec::_lower_case_flow_statement,
  lower_default_flow_statement   => \&LinkedSpec::_lower_default_flow_statement,
  lower_endcase_flow_statement   => \&LinkedSpec::_lower_endcase_flow_statement,
  lower_endswitch_flow_statement => \&LinkedSpec::_lower_endswitch_flow_statement,
  lower_say_statement            => \&LinkedSpec::_lower_say_statement,
  lower_print_statement          => \&LinkedSpec::_lower_print_statement,
  lower_return_undef_statement   => \&LinkedSpec::_lower_return_undef_statement,
  lower_return_array_statement   => \&LinkedSpec::_lower_return_array_statement,
  lower_declare_method_statement => \&_lower_declare_method_statement,
 }
}

sub _build_action_lowering_contracts {
 my ($label) = @_;
 return LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts(
  $label,
  _action_contract_deps(),
 )
}

sub _scan_contract_ir_events {
 my ($contract, $code) = @_;
 return LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
  $contract,
  $code,
  {
   split_action_ir_statements                 => \&_split_action_ir_statements,
   trim_action_ir_value                       => \&_trim_action_ir_value,
   parse_method_function_expr                 => \&LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr,
   normalize_method_args_with_optional_scope  => \&LinkedSpec::ActionIR::MethodExpr::_normalize_method_args_with_optional_scope,
   build_array_pipeline_plan_from_expr        => \&LinkedSpec::_build_array_pipeline_plan_from_expr,
   extract_declare_statement_from_method_expr => \&_extract_declare_statement_from_method_expr,
   parse_declare_binding_entry                => \&_parse_declare_binding_entry,
  }
 )
}

sub _find_unresolved_action_helpers {
 return LinkedSpec::ActionIR::Diagnostics::_find_unresolved_action_helpers(@_, _diagnostics_deps())
}

sub _collect_action_helper_ir_nodes {
 return LinkedSpec::ActionIR::Diagnostics::_collect_action_helper_ir_nodes(@_, _diagnostics_deps())
}

sub _canonicalize_helper_action_ir_event {
 return LinkedSpec::ActionIR::CanonicalEvents::_canonicalize_helper_action_ir_event(@_, _canonical_event_deps())
}

sub _split_action_ir_statements {
 return LinkedSpec::ActionIR::StatementSplit::_split_action_ir_statements(@_, _statement_split_deps())
}
sub _build_canonical_action_ir_events {
 return LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events(@_, _canonical_event_deps())
}

sub _lower_action_code_from_canonical_ir {
 return LinkedSpec::ActionIR::RewritePipeline::_lower_action_code_from_canonical_ir(@_)
}

sub _accumulate_action_rewrite_diagnostics {
 return LinkedSpec::ActionIR::Diagnostics::_accumulate_action_rewrite_diagnostics(@_)
}

sub _rewrite_action_code_with_diagnostics {
 my ($label, $code, $rewrite_rules) = @_;
 return LinkedSpec::ActionIR::RewritePipeline::_rewrite_action_code_with_diagnostics(
  $label,
  $code,
  $rewrite_rules,
  _rewrite_pipeline_deps(),
 )
}

sub _build_action_rewrite_rules {
 return LinkedSpec::ActionIR::RewritePipeline::_build_action_rewrite_rules(@_, _rewrite_pipeline_deps())
}

sub call_spec_handler_subst {
my ($label, $code) = @_;

 ($code) = _rewrite_action_code_with_diagnostics($label, $code);
 return $code
}

1;
