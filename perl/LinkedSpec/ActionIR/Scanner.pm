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
use LinkedSpec::ActionIR::Trace ();

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
  my ($contract, $code) = @args;
  my $id = (ref($contract) eq 'HASH') ? ($contract->{id} // '') : '';
  my $scope = LinkedSpec::ActionIR::Trace::enter(
   package => __PACKAGE__,
   owner => 'scanner',
   phase => 'scan_contract_ir_events',
   label => $id,
   details => {
    contract_id => $id,
    code_len => defined($code) ? length($code) : 0,
   },
  );
  _require_scanner_core_pkg();
  my $events = LinkedSpec::ActionIR::ScannerCore::scan_contract_ir_events(@args);
  my $event_count = ref($events) eq 'ARRAY' ? scalar(@$events) : 0;
  if ($event_count) {
   LinkedSpec::ActionIR::Trace::decision(
    owner => 'scanner',
    phase => 'scan_contract_ir_events',
    label => $id,
    decision => 'events_found',
    taken => 1,
    context => {
     contract_id => $id,
     event_count => $event_count,
    },
   );
  }
  LinkedSpec::ActionIR::Trace::exit_scope(
   $scope,
   {
    status => 'ok',
    contract_id => $id,
    event_count => $event_count,
   },
  );
  return $events
 })
}

1;
