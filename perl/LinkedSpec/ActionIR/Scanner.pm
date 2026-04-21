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

sub _require_scanner_core_pkg {
 LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, 'LinkedSpec::ActionIR::ScannerCore', 'scan_contract_ir_events');
 return 1
}

sub default_deps_for_package {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  _require_scanner_core_pkg();
  my @dep_specs = map {
   +{
    dep => $_->{dep_name},
    pkg => ($_->{provider_pkg} // $pkg),
    cb  => $_->{binding_symbol},
   }
  } LinkedSpec::ActionIR::ScannerCore::_scanner_dep_specs();
  return LinkedSpec::OwnerDispatch::build_dep_map(__PACKAGE__, $pkg, \@dep_specs)
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
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  _require_scanner_core_pkg();
  return LinkedSpec::ActionIR::ScannerCore::scan_contract_ir_events(@args)
 })
}

1;
