#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionRewriter
# Purpose: Backward-compatible compatibility wrapper that forwards legacy
#          ActionRewriter helper entrypoints into `RuleIR::EmitContext`.
#------------------------------------------------------------------------------
package LinkedSpec::ActionRewriter;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::OwnerDispatch ();

#------------------------------------------------------------------------------
# Function: _delegate_emit_context_call
# Purpose : Forward one historical ActionRewriter helper entrypoint into the
#           extracted `RuleIR::EmitContext` owner.
# Args    : ($method, @args)
# Returns : delegated helper return value
#------------------------------------------------------------------------------
sub _delegate_emit_context_call {
 my ($method, @args) = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(
  __PACKAGE__,
  'LinkedSpec::RuleIR::EmitContext',
  $method,
  @args,
 )
}

my @EMIT_CONTEXT_FORWARDERS = qw(
 _parse_method_function_expr
 _is_bare_method_scope_token
 _normalize_method_args_with_optional_scope
 _split_top_level_csv
 _lower_flow_composite_expr
 _declare_alias_to_type
 _lower_typed_declare_statement
 _normalize_method_tag_expr
 _extract_scalar_symbol_name
 _extract_array_symbol_name
 _extract_hash_symbol_name
 _lower_scalar_access_key_expr
 _lower_scalaref_value_expr
 _infer_scalar_container_kind
 _lower_assignment_source_expr
 _strip_literal_delimiters
 _split_declare_symbol_names
 _parse_declare_binding_entry
 _lower_declare_value_expr
 _lower_declare_initializer_expr
 _extract_declare_statement_from_method_expr
 _lower_declare_method_statement
 _lower_assign_method_statement
 _lower_method_value_expr
 _lower_return_general_statement
 _lower_return_imatch_statement
 _lower_assign_statement
 _lower_push_value_statement
 _lower_push_nonempty_statement
 _lower_regex_subst_statement
 _lower_return_undef_statement
 _lower_return_array_statement
 _build_array_pipeline_plan_from_expr
 _lower_array_pipeline_expr
 _lower_if_flow_statement
 _lower_elseif_flow_statement
 _lower_else_flow_statement
 _lower_endif_flow_statement
 _lower_switch_flow_statement
 _lower_case_flow_statement
 _lower_default_flow_statement
 _lower_endcase_flow_statement
 _lower_endswitch_flow_statement
 _lower_say_statement
 _lower_print_statement
 _lower_print_each_statement
 _build_action_lowering_contracts
 _scan_contract_ir_events
 _find_unresolved_action_helpers
 _collect_action_helper_ir_nodes
 _canonicalize_helper_action_ir_event
 _split_action_ir_statements
 _build_canonical_action_ir_events
 _lower_action_code_from_canonical_ir
 _accumulate_action_rewrite_diagnostics
 _rewrite_action_code_with_diagnostics
 _build_action_rewrite_rules
);

{
 no strict 'refs';
 foreach my $method (@EMIT_CONTEXT_FORWARDERS) {
  my $delegate = $method;
  *{$method} = sub {
   my @args = @_;
   return _delegate_emit_context_call($delegate, @args)
  };
 }
}

#------------------------------------------------------------------------------
# Function: call_spec_handler_subst
# Purpose : Backward-compatible helper-rewrite entrypoint retained for direct
#           legacy ActionRewriter callers.
# Args    : ($label, $code)
# Returns : rewritten code string
#------------------------------------------------------------------------------
sub call_spec_handler_subst {
 my @args = @_;
 return _delegate_emit_context_call('rewrite_action_code_for_compat', @args)
}

1;
