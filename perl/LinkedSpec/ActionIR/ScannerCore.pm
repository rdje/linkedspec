package LinkedSpec::ActionIR::ScannerCore;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules ();
use LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules ();
use LinkedSpec::ActionIR::Scanner::FlowRules ();
use LinkedSpec::ActionIR::Scanner::LegacyRules ();

sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ActionIR::ScannerCore::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

#------------------------------------------------------------------------------
# Function: scan_contract_ir_events
# Purpose : Contract-specific scanner that extracts helper invocation events
#           and parsed arguments from raw action code.
# Args    : ($contract, $code, $deps)
# Returns : arrayref of event hashes
#------------------------------------------------------------------------------
sub scan_contract_ir_events {
 my ($contract, $code, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';

 my $split_action_ir_statements = _require_dep($deps, 'split_action_ir_statements');
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');
 my $build_array_pipeline_plan_from_expr = _require_dep($deps, 'build_array_pipeline_plan_from_expr');
 my $extract_declare_statement_from_method_expr = _require_dep($deps, 'extract_declare_statement_from_method_expr');
 my $parse_declare_binding_entry = _require_dep($deps, 'parse_declare_binding_entry');

 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_split_action_ir_statements = $split_action_ir_statements;
 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_trim_action_ir_value = $trim_action_ir_value;
 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_parse_method_function_expr = $parse_method_function_expr;
 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_normalize_method_args_with_optional_scope = $normalize_method_args_with_optional_scope;
 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_build_array_pipeline_plan_from_expr = $build_array_pipeline_plan_from_expr;
 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_extract_declare_statement_from_method_expr = $extract_declare_statement_from_method_expr;
 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_parse_declare_binding_entry = $parse_declare_binding_entry;

 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_split_action_ir_statements = $split_action_ir_statements;
 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_trim_action_ir_value = $trim_action_ir_value;
 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_parse_method_function_expr = $parse_method_function_expr;
 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_normalize_method_args_with_optional_scope = $normalize_method_args_with_optional_scope;
 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_build_array_pipeline_plan_from_expr = $build_array_pipeline_plan_from_expr;
 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_extract_declare_statement_from_method_expr = $extract_declare_statement_from_method_expr;
 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_parse_declare_binding_entry = $parse_declare_binding_entry;

 local *LinkedSpec::ActionIR::Scanner::FlowRules::_split_action_ir_statements = $split_action_ir_statements;
 local *LinkedSpec::ActionIR::Scanner::FlowRules::_trim_action_ir_value = $trim_action_ir_value;
 local *LinkedSpec::ActionIR::Scanner::FlowRules::_parse_method_function_expr = $parse_method_function_expr;
 local *LinkedSpec::ActionIR::Scanner::FlowRules::_normalize_method_args_with_optional_scope = $normalize_method_args_with_optional_scope;
 local *LinkedSpec::ActionIR::Scanner::FlowRules::_build_array_pipeline_plan_from_expr = $build_array_pipeline_plan_from_expr;
 local *LinkedSpec::ActionIR::Scanner::FlowRules::_extract_declare_statement_from_method_expr = $extract_declare_statement_from_method_expr;
 local *LinkedSpec::ActionIR::Scanner::FlowRules::_parse_declare_binding_entry = $parse_declare_binding_entry;

 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_split_action_ir_statements = $split_action_ir_statements;
 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_trim_action_ir_value = $trim_action_ir_value;
 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_parse_method_function_expr = $parse_method_function_expr;
 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_normalize_method_args_with_optional_scope = $normalize_method_args_with_optional_scope;
 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_build_array_pipeline_plan_from_expr = $build_array_pipeline_plan_from_expr;
 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_extract_declare_statement_from_method_expr = $extract_declare_statement_from_method_expr;
 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_parse_declare_binding_entry = $parse_declare_binding_entry;

 my $id = $contract->{id} // '';
 foreach my $scanner (
  \&LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::try_scan_contract_ir_events,
  \&LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::try_scan_contract_ir_events,
  \&LinkedSpec::ActionIR::Scanner::FlowRules::try_scan_contract_ir_events,
  \&LinkedSpec::ActionIR::Scanner::LegacyRules::try_scan_contract_ir_events,
 ) {
  my $events = $scanner->($id, $code);
  return $events if defined $events;
 }

 return []
}

1;
