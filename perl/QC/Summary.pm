#------------------------------------------------------------------------------
# Package: QC::Summary
# Purpose: QC summary workbook row shaping that migrated out of legacy `.plg`
#          helper lookup.
#------------------------------------------------------------------------------
package QC::Summary;

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
# Function: append_merged_rows
# Purpose : Append the historical qc_summary_merge row block for one QC summary
#           data section into the supplied output accumulator.
# Args    : ($info, $data, $rows, $comment, $io_type, $cts_tpd, $slack)
# Returns : undef after mutating $data's header row and appending to $rows
#------------------------------------------------------------------------------
sub append_merged_rows {
 my ($info, $data, $rows, $comment, $io_type, $cts_tpd, $slack) = @_;

 my $name = join('/', (split(/\./, $info->[0]))[1 .. 2]);
 my @lsummary;
 push @lsummary, [$name, ('+') x $comment];

 my $i = 0;
 foreach my $sec (@$data) {
  push @lsummary, [('+') x ($comment + 1)] if $i >= 2;

  do {
   $sec->[0][$io_type] = "IO_Type";
   $sec->[0][$cts_tpd] = "Cts_Tpd";
   $sec->[0][$comment] = "Comment";
  } unless $i;

  push @lsummary, [@$_] foreach (($i == 1 || $i == 4) ? sort {$a->[$slack] <=> $b->[$slack]} @$sec : @$sec);

  ++$i;
 }

 push @$rows, [@lsummary];
 return
}

1;
