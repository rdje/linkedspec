#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::Scanner
# Purpose: Contract-level ActionIR scanner owner for dependency assembly and
#          helper-event extraction orchestration.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::Scanner;

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
# Function: _require_pkg
# Purpose : Lazy-load one scanner dependency owner through the shared
#           owner-dispatch seam.
# Args    : ($pkg)
# Returns : true on successful require
#------------------------------------------------------------------------------
sub _require_pkg {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg)
}

sub _require_scanner_core_pkg {
 _require_pkg('LinkedSpec::ActionIR::ScannerCore') unless LinkedSpec::ActionIR::ScannerCore->can('scan_contract_ir_events');
 return 1
}

#------------------------------------------------------------------------------
# Function: _call_preserving_err
# Purpose : Preserve caller-visible successful `$@` while executing one scanner
#           helper callback.
# Args    : ($cb)
# Returns : callback return value in caller context
#------------------------------------------------------------------------------
sub _call_preserving_err {
 my ($cb) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err($cb)
}

#------------------------------------------------------------------------------
# Function: _require_pkg_cb
# Purpose : Lazy-load one scanner dependency owner and resolve one callback
#           through the shared owner-dispatch seam.
# Args    : ($pkg, $name)
# Returns : callback coderef
#------------------------------------------------------------------------------
sub _require_pkg_cb {
 my ($pkg, $name) = @_;
 return LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, $pkg, $name)
}

sub default_deps_for_package {
 my ($pkg) = @_;
 return _call_preserving_err(sub {
  return {
   split_action_ir_statements => _require_pkg_cb($pkg, '_split_action_ir_statements'),
   trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
   parse_method_function_expr => _require_pkg_cb('LinkedSpec::ActionIR::MethodExpr', '_parse_method_function_expr'),
   normalize_method_args_with_optional_scope => _require_pkg_cb('LinkedSpec::ActionIR::MethodExpr', '_normalize_method_args_with_optional_scope'),
   build_array_pipeline_plan_from_expr => _require_pkg_cb($pkg, '_build_array_pipeline_plan_from_expr'),
   extract_declare_statement_from_method_expr => _require_pkg_cb($pkg, '_extract_declare_statement_from_method_expr'),
   parse_declare_binding_entry => _require_pkg_cb($pkg, '_parse_declare_binding_entry'),
  }
 })
}

#------------------------------------------------------------------------------
# Function: scan_contract_ir_events
# Purpose : Contract-specific scanner that extracts helper invocation events
#           and parsed arguments from raw action code.
# Args    : ($contract, $code, $deps)
# Returns : arrayref of event hashes
#------------------------------------------------------------------------------
sub scan_contract_ir_events {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_scanner_core_pkg();
  return LinkedSpec::ActionIR::ScannerCore::scan_contract_ir_events(@args)
 })
}

1;
