#------------------------------------------------------------------------------
# Package: MSOffice::Excel
# Purpose: Domain owner for Microsoft Excel automation helpers that were
#          migrated out of legacy `.plg` files and should no longer live under
#          plugin-branded scaffolding.
#------------------------------------------------------------------------------
package MSOffice::Excel;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

#------------------------------------------------------------------------------
# Function: start
# Purpose : Preserve the historical Excel automation helper as an explicit
#           package function: reuse an active Excel instance when one exists,
#           otherwise create a new instance that quits when released.
# Args    : none
# Returns : Win32::OLE Excel.Application object
#------------------------------------------------------------------------------
sub start {
 my $excel;

 my $load_err;
 {
  local $@;
  eval { require Win32::OLE; 1 } or $load_err = $@ || 'Win32::OLE load failed';
 }
 die "Excel not installed" if $load_err;

 my $active_excel_err;
 {
  local $@;
  eval { $excel = Win32::OLE->GetActiveObject('Excel.Application') };
  $active_excel_err = $@;
 }
 die "Excel not installed" if $active_excel_err;
 $excel = Win32::OLE->new('Excel.Application', sub { $_[0]->Quit }) || die "Oops, cannot start Excel" unless defined $excel;

 return $excel
}

1;
