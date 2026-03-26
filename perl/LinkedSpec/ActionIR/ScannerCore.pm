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

#------------------------------------------------------------------------------
# Function: _scanner_rule_family_packages
# Purpose : Return the ordered scanner-rule family package list used for both
#           lazy loading and shared dependency rebinding.
# Args    : none
# Returns : ordered package-name list
#------------------------------------------------------------------------------
sub _scanner_rule_family_packages {
 return (
  'LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules',
  'LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules',
  'LinkedSpec::ActionIR::Scanner::FlowRules',
  'LinkedSpec::ActionIR::Scanner::LegacyRules',
 )
}

#------------------------------------------------------------------------------
# Function: _scanner_rule_binding_symbols
# Purpose : Return the shared helper symbol list rebound into each scanner-rule
#           family while contract scanning runs.
# Args    : none
# Returns : ordered helper-symbol list
#------------------------------------------------------------------------------
sub _scanner_rule_binding_symbols {
 return (
  '_split_action_ir_statements',
  '_trim_action_ir_value',
  '_parse_method_function_expr',
  '_normalize_method_args_with_optional_scope',
  '_build_array_pipeline_plan_from_expr',
  '_extract_declare_statement_from_method_expr',
  '_parse_declare_binding_entry',
 )
}

#------------------------------------------------------------------------------
# Function: _scanner_rule_dep_bindings
# Purpose : Normalize the dependency callback bundle into the exact symbol map
#           rebound into each scanner-rule family package.
# Args    : ($deps)
# Returns : hashref of helper-symbol => callback bindings
#------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------
# Function: _scanner_dispatchers
# Purpose : Lazy-load the scanner-rule families and return their public
#           dispatcher callbacks in the canonical family order.
# Args    : none
# Returns : ordered list of dispatcher coderefs
#------------------------------------------------------------------------------
sub _scanner_dispatchers {
 my @dispatchers;
 no strict 'refs';
 foreach my $pkg (_scanner_rule_family_packages()) {
  _require_pkg($pkg);
  push @dispatchers, \&{"${pkg}::try_scan_contract_ir_events"};
 }
 return @dispatchers
}

#------------------------------------------------------------------------------
# Function: _with_scanner_rule_family_deps
# Purpose : Rebind the shared helper symbols into one scanner-rule family for
#           the duration of one callback body.
# Args    : ($pkg, $bindings, $body)
# Returns : callback return value
#------------------------------------------------------------------------------
sub _with_scanner_rule_family_deps {
 my ($pkg, $bindings, $body) = @_;
 die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_family_deps) -E- scanner-rule package must be provided"
  unless defined($pkg) && length($pkg);
 die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_family_deps) -E- scanner dep bindings must be HASH"
  unless ref($bindings) eq 'HASH';
 die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_family_deps) -E- body callback must be CODE"
  unless ref($body) eq 'CODE';

 my $runner = $body;
 foreach my $symbol (reverse _scanner_rule_binding_symbols()) {
  my $cb = $bindings->{$symbol};
  die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_family_deps) -E- missing bound scanner helper '$symbol'"
   unless ref($cb) eq 'CODE';
  my $next = $runner;
  $runner = sub {
   no strict 'refs';
   local *{"${pkg}::$symbol"} = $cb;
   return $next->();
  };
 }

 return $runner->()
}

#------------------------------------------------------------------------------
# Function: _with_scanner_rule_deps
# Purpose : Rebind the shared helper symbols into all scanner-rule families for
#           the duration of one callback body.
# Args    : ($bindings, $body)
# Returns : callback return value
#------------------------------------------------------------------------------
sub _with_scanner_rule_deps {
 my ($bindings, $body) = @_;
 die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_deps) -E- scanner dep bindings must be HASH"
  unless ref($bindings) eq 'HASH';
 die "(LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_deps) -E- body callback must be CODE"
  unless ref($body) eq 'CODE';

 my $runner = $body;
 foreach my $pkg (reverse _scanner_rule_family_packages()) {
  my $next = $runner;
  $runner = sub {
   return _with_scanner_rule_family_deps($pkg, $bindings, $next)
  };
 }

 return $runner->()
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
