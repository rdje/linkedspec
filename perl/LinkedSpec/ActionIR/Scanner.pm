package LinkedSpec::ActionIR::Scanner;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::ActionIR::ScannerCore ();

#------------------------------------------------------------------------------
# Function: scan_contract_ir_events
# Purpose : Contract-specific scanner that extracts helper invocation events
#           and parsed arguments from raw action code.
# Args    : ($contract, $code, $deps)
# Returns : arrayref of event hashes
#------------------------------------------------------------------------------
sub scan_contract_ir_events {
 return LinkedSpec::ActionIR::ScannerCore::scan_contract_ir_events(@_)
}

1;
