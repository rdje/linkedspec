package LinkedSpec::ActionIR::ScannerCore;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::OwnerDispatch ();

#------------------------------------------------------------------------------
# Package : LinkedSpec::ActionIR::ScannerCore
# Purpose : ActionIR scanner core owner that binds shared scanner-rule deps and
#           dispatches contract scanning across the rule-family scanners.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function: _require_pkg
# Purpose : Lazy-load a package through the shared owner-dispatch helper.
# Args    : ($pkg)
# Returns : package name string
#------------------------------------------------------------------------------
sub _require_pkg {
 my ($pkg) = @_;
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg);
 return $pkg
}

#------------------------------------------------------------------------------
# Function: _require_dep
# Purpose : Resolve a required callback from a dependency hash.
# Args    : ($deps, $name)
# Returns : callback coderef
#------------------------------------------------------------------------------
sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ActionIR::ScannerCore::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

sub _scanner_rule_dep_bindings {
 my ($deps) = @_;
 return {
  _split_action_ir_statements => _require_dep($deps, 'split_action_ir_statements'),
  _trim_action_ir_value => _require_dep($deps, 'trim_action_ir_value'),
  _parse_method_function_expr => _require_dep($deps, 'parse_method_function_expr'),
  _normalize_method_args_with_optional_scope => _require_dep($deps, 'normalize_method_args_with_optional_scope'),
  _build_array_pipeline_plan_from_expr => _require_dep($deps, 'build_array_pipeline_plan_from_expr'),
  _extract_declare_statement_from_method_expr => _require_dep($deps, 'extract_declare_statement_from_method_expr'),
  _parse_declare_binding_entry => _require_dep($deps, 'parse_declare_binding_entry'),
 }
}

sub _scanner_dispatchers {
 _require_pkg('LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules');
 _require_pkg('LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules');
 _require_pkg('LinkedSpec::ActionIR::Scanner::FlowRules');
 _require_pkg('LinkedSpec::ActionIR::Scanner::LegacyRules');
 return (
  \&LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::try_scan_contract_ir_events,
  \&LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::try_scan_contract_ir_events,
  \&LinkedSpec::ActionIR::Scanner::FlowRules::try_scan_contract_ir_events,
  \&LinkedSpec::ActionIR::Scanner::LegacyRules::try_scan_contract_ir_events,
 )
}

sub _with_scanner_rule_deps {
 my ($bindings, $body) = @_;
 die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_deps) -E- scanner dep bindings must be HASH"
  unless ref($bindings) eq 'HASH';
 die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_deps) -E- body callback must be CODE"
  unless ref($body) eq 'CODE';

 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_split_action_ir_statements = $bindings->{_split_action_ir_statements};
 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_trim_action_ir_value = $bindings->{_trim_action_ir_value};
 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_parse_method_function_expr = $bindings->{_parse_method_function_expr};
 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_normalize_method_args_with_optional_scope = $bindings->{_normalize_method_args_with_optional_scope};
 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_build_array_pipeline_plan_from_expr = $bindings->{_build_array_pipeline_plan_from_expr};
 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_extract_declare_statement_from_method_expr = $bindings->{_extract_declare_statement_from_method_expr};
 local *LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules::_parse_declare_binding_entry = $bindings->{_parse_declare_binding_entry};

 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_split_action_ir_statements = $bindings->{_split_action_ir_statements};
 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_trim_action_ir_value = $bindings->{_trim_action_ir_value};
 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_parse_method_function_expr = $bindings->{_parse_method_function_expr};
 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_normalize_method_args_with_optional_scope = $bindings->{_normalize_method_args_with_optional_scope};
 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_build_array_pipeline_plan_from_expr = $bindings->{_build_array_pipeline_plan_from_expr};
 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_extract_declare_statement_from_method_expr = $bindings->{_extract_declare_statement_from_method_expr};
 local *LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules::_parse_declare_binding_entry = $bindings->{_parse_declare_binding_entry};

 local *LinkedSpec::ActionIR::Scanner::FlowRules::_split_action_ir_statements = $bindings->{_split_action_ir_statements};
 local *LinkedSpec::ActionIR::Scanner::FlowRules::_trim_action_ir_value = $bindings->{_trim_action_ir_value};
 local *LinkedSpec::ActionIR::Scanner::FlowRules::_parse_method_function_expr = $bindings->{_parse_method_function_expr};
 local *LinkedSpec::ActionIR::Scanner::FlowRules::_normalize_method_args_with_optional_scope = $bindings->{_normalize_method_args_with_optional_scope};
 local *LinkedSpec::ActionIR::Scanner::FlowRules::_build_array_pipeline_plan_from_expr = $bindings->{_build_array_pipeline_plan_from_expr};
 local *LinkedSpec::ActionIR::Scanner::FlowRules::_extract_declare_statement_from_method_expr = $bindings->{_extract_declare_statement_from_method_expr};
 local *LinkedSpec::ActionIR::Scanner::FlowRules::_parse_declare_binding_entry = $bindings->{_parse_declare_binding_entry};

 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_split_action_ir_statements = $bindings->{_split_action_ir_statements};
 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_trim_action_ir_value = $bindings->{_trim_action_ir_value};
 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_parse_method_function_expr = $bindings->{_parse_method_function_expr};
 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_normalize_method_args_with_optional_scope = $bindings->{_normalize_method_args_with_optional_scope};
 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_build_array_pipeline_plan_from_expr = $bindings->{_build_array_pipeline_plan_from_expr};
 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_extract_declare_statement_from_method_expr = $bindings->{_extract_declare_statement_from_method_expr};
 local *LinkedSpec::ActionIR::Scanner::LegacyRules::_parse_declare_binding_entry = $bindings->{_parse_declare_binding_entry};

 return $body->()
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
 my $id = $contract->{id} // '';
 my $bindings = _scanner_rule_dep_bindings($deps);
 return _with_scanner_rule_deps($bindings, sub {
  foreach my $scanner (_scanner_dispatchers()) {
   my $events = $scanner->($id, $code);
   return $events if defined $events;
  }

  return []
 })
}

1;
