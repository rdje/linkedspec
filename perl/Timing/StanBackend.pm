#------------------------------------------------------------------------------
# Package: Timing::StanBackend
# Purpose: STAN/report-timing backend setup that migrated out of legacy `.plg`
#          helper lookup.
#------------------------------------------------------------------------------
package Timing::StanBackend;

use 5.010;
use strict;
use warnings;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

#------------------------------------------------------------------------------
# Function: start
# Purpose : Preserve the historical `stan_backend_start` setup step as an
#           explicit timing-domain package function.
# Args    : ($conf)
# Returns : whatever Table2SS::UConf(...) returns
#------------------------------------------------------------------------------
sub start {
 my ($conf) = @_;
 $conf //= {};

 require HTTP::FileAccess;
 require PathSearch;
 require Table2SS;

 print "($conf->{_program})($conf->{_action}) -I- Launching '$conf->{_action}' processing..\n";
 HTTP::FileAccess::set_hostport($conf->{_host}, $conf->{_port});
 return Table2SS::UConf(PathSearch->go('stan_backend_table2ss'));
}

#------------------------------------------------------------------------------
# Function: clock_matrix_cell_code
# Purpose : Preserve the historical minmax_clockmx_cellcode clock-matrix cell
#           formatter under the STAN timing backend owner.
# Args    : ($conf, $workbook, $row, $col, $path_tree)
# Returns : internal workbook link text for the summary cell
#------------------------------------------------------------------------------
sub clock_matrix_cell_code {
 my ($conf, $wb, $row, $col, $hh) = @_;

 require HUtils;
 require Table2SS;

 HUtils::WRecurse($hh, sub {
   my @num_slack   = grep {$$_[$conf->{_indexes}{slack}] ne '-'} @{$_[1]};
   my @undef_slack = grep {$$_[$conf->{_indexes}{slack}] eq '-'} @{$_[1]};
   [(sort {$a->[$conf->{_indexes}{slack}] <=> $b->[$conf->{_indexes}{slack}]} @num_slack), @undef_slack];
 });

 my $outstr_min = $hh->{pathtype}{min} ? $hh->{pathtype}{min}[0][$conf->{_indexes}{slack}]." (".@{$hh->{pathtype}{min}}.")" : "-";
 my $outstr_max = $hh->{pathtype}{max} ? $hh->{pathtype}{max}[0][$conf->{_indexes}{slack}]." (".@{$hh->{pathtype}{max}}.")" : "-";

 my @localpaths;

 push @localpaths, [grep {defined} @{$hh->{pathtype}{min}}[0 .. 99]] if $hh->{pathtype}{min};
 push @localpaths, [grep {defined} @{$hh->{pathtype}{max}}[0 .. 99]] if $hh->{pathtype}{max};

 Table2SS::DriveSheet($wb, "first100_r${row}c$col", Table2SS::RCAllocate(1, 1, 2, [@localpaths], "consolidated_rep"));

 return "internal:first100_r${row}c$col!A1\@$outstr_min / $outstr_max"
}

1;
