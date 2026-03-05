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
use LinkedSpec::Deps ();

sub _trim_action_ir_value {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s*|\s*$//go;
 return $value
}
sub _declare_method_deps {
 return LinkedSpec::Deps::action_rewriter_declare_method_deps_for_package(__PACKAGE__)
}
sub _statement_split_deps {
 return LinkedSpec::Deps::action_rewriter_statement_split_deps_for_package(__PACKAGE__)
}
sub _canonical_event_deps {
 return LinkedSpec::Deps::action_rewriter_canonical_event_deps_for_package(__PACKAGE__)
}
sub _diagnostics_deps {
 return LinkedSpec::Deps::action_rewriter_diagnostics_deps_for_package(__PACKAGE__)
}
sub _rewrite_pipeline_deps {
 return LinkedSpec::Deps::action_rewriter_rewrite_pipeline_deps_for_package(__PACKAGE__)
}
sub _scan_contract_ir_event_deps {
 return LinkedSpec::Deps::action_rewriter_scanner_deps_for_package(__PACKAGE__)
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
 return LinkedSpec::Deps::action_rewriter_contract_deps_for_package(__PACKAGE__)
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
  _scan_contract_ir_event_deps(),
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
