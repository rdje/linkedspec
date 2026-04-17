#------------------------------------------------------------------------------
# Package: QC::Flow
# Purpose: QC flow helpers that migrated out of legacy `.plg` helper lookup.
#------------------------------------------------------------------------------
package QC::Flow;

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
# Function: push_once
# Purpose : Preserve the historical qc_pushonce duplicate-suppressed qclog
#           insertion helper under an explicit QC flow owner.
# Args    : ($qclog, $once, $entry_name, @row)
# Returns : undef after updating qclog and duplicate counters
#------------------------------------------------------------------------------
sub push_once {
 my ($qclog, $once, $entry_name) = splice @_, 0, 3;
 my $row_key = join(':', @_);

 unless ($once->{$entry_name}{$row_key}) {
  push @{$qclog->{$entry_name}}, [@_];
 }

 $once->{$entry_name}{$row_key}++;
 return
}

#------------------------------------------------------------------------------
# Function: budget_check
# Purpose : Preserve the historical qc_budget_check traversal callback under the
#           QC flow package owner.
# Args    : HUtils::Recurse callback args plus helper coderefs and QC state refs
# Returns : undef after updating budget-check/qclog state
#------------------------------------------------------------------------------
sub budget_check {
 my (
  $info, $a2d, $qc_pushonce, $single_n_zero_match, $get_fanxinfo,
  $qconf, $groups, $qcflowlog, $budget_check, $match_port, $qclog, $once,
 ) = @_;
 my $port = $info->[1];

 if ($$match_port{$port}) {
  if ($$match_port{$port}{count} == 1) {
   $single_n_zero_match->(
    $port, $qc_pushonce, $get_fanxinfo, $qconf, $groups, $qcflowlog,
    $budget_check, $match_port, $qclog, $once, 1,
   );
  } else {
   $$budget_check{mmatch}{$port} = 1
  }
 } else {
  unless ($$groups{ios}{ion}{$port}[0][$qconf->{indexes}{direction}] =~ /$qconf->{vssvdd_re}/) {
   unless ($$budget_check{unknown}{$port}) {
    $qc_pushonce->($qclog, $once, '(XCEL2HM vs GUIDELINE) Ports not defined in the GUIDELINE', $port);
    $$budget_check{unknown}{$port} = 1;

    $single_n_zero_match->(
     $port, $qc_pushonce, $get_fanxinfo, $qconf, $groups, $qcflowlog,
     $budget_check, $match_port, $qclog, $once, 0,
    );
   }
  } else {
   $$budget_check{vssvdd}{$port} = 1
  }
 }

 return
}

#------------------------------------------------------------------------------
# Function: budget_check_single_or_zero_match
# Purpose : Preserve the historical qc_budget_check_01match_code helper without
#           requiring same-file plugin lookup.
# Args    : ($port, $push_once_coderef, $fanxinfo_coderef, QC state refs..., flag)
# Returns : undef after updating budget-check/qclog state and writing log output
#------------------------------------------------------------------------------
sub budget_check_single_or_zero_match {
 my (
  $port, $qc_pushonce, $get_fanxinfo, $qconf, $groups, $qcflowlog,
  $budget_check, $match_port, $qclog, $once, $zero_one_flag,
 ) = @_;

 print $qcflowlog "\n".('#' x 40)." $port ".('#' x 40)."\n";

 unless ($$groups{clocks}{clockn}{$port}) {
  $$budget_check{smatch}{$port} = 1 if $zero_one_flag;

  print $qcflowlog "($qconf->{progname}) -I- Budget Checking DATA port '$port'..\n";

  foreach my $cbgt (@{$$groups{ios}{ion}{$port}}) {
   my $reference_clock = $cbgt->[$qconf->{indexes}{reference_signal}];
   my $dir = $cbgt->[$qconf->{indexes}{direction}];

   unless ($$groups{clocks}{clockn}{$reference_clock}) {
    if ($reference_clock ne '-') {
     $qc_pushonce->($qclog, $once, 'Port used as a clock in XCEL2HM but not defined as clock in XCEL2HM', $reference_clock)
    } else {
     $qc_pushonce->($qclog, $once, '(XCEL2HM vs GUIDELINE) Ports with NO reference clock', $port, $dir)
    }

    next
   }

   my $port_budgets = eval q($qconf->{').join(q('}{'), $zero_one_flag ? @{$$match_port{$port}{info}[0]} : "not-covered").q('});

   my @minmax = map {$port_budgets->[2*($dir =~ /in/io) + $_]} 0 .. 1;
   my @cminmax = map {$cbgt->[$qconf->{indexes}{min_budget} + $_]} 0 .. 1;

   my $no_minmax = grep /^-$/, @cminmax;
   if ($no_minmax == 2) {
    $qc_pushonce->(
     $qclog,
     $once,
     "(XCEL2HM vs GUIDELINE) Ports with a reference clock but with NO min & max budgets",
     $port,
     $dir,
    );
    next
   }

   my @minmax_edges = map { /F:/io ? 0 : 1} @minmax;
   my @cminmax_edges = map { /A|R/io ? 1 : 0} reverse split(/\//, $cbgt->[$qconf->{indexes}{intsim_code}]);

   @minmax = map {s/F://; $_} @minmax;

   if ($cbgt->[$qconf->{indexes}{direction}] =~ /in/io) {
    unless (@cminmax_edges == 2) {
     print $qcflowlog "($qconf->{progname}) -W- input port '$port' should have exactly two edge information.\n";
     @cminmax_edges = (@cminmax_edges) x 2;
    }
   } else {
    if (@cminmax_edges == 1) {
     @cminmax_edges = (@cminmax_edges) x 2
    } else {
     print $qcflowlog "($qconf->{progname}) -W- Output port '$port' has two edges information, Is it normal ??\n";
    }
   }

   foreach (0 .. 1) {
    unless ($minmax_edges[$_] == $cminmax_edges[$_]) {
     $qc_pushonce->(
      $qclog,
      $once,
      "(XCEL2HM vs GUIDELINE) Clock Edge Mismatch",
      $port,
      $dir,
      $reference_clock,
      ($cminmax_edges[$_] ? "PosEdge" : "NegEdge"),
      ($minmax_edges[$_] ? "PosEdge" : "NegEdge"),
     );

     $$budget_check{edges_mismatches}++;
    }

    unless ($minmax[$_] =~ /^(?:\?|NS:\S+|-)$/io) {
     my ($cxbudget) = $cminmax[$_] =~ /(-?\d+)/;
     my $inpercent_or_null = $cminmax[$_] =~ /^0$|%$/;
     unless ($inpercent_or_null) {
      print $qcflowlog "($qconf->{progname}) -W- Actual *".($_ ? 'Max' : 'Min').
                      "* budget 'A:$cminmax[$_]' (vs. GL:$minmax[$_]) for '$port'/'$reference_clock' is NOT expressed in '%' or is not zero, Skipping.\n";
      next
     } elsif ($_ || $dir =~ /in/io ? ($minmax[$_] < $cxbudget) : ($minmax[$_] > $cxbudget)) {
      my @interface_n_re_info = $zero_one_flag ? split(/\s+:\s+/, $$match_port{$port}{regexes}[0]) : ('NOT_COVERED', 'not_applicable');
      my $freq = $$groups{clocks}{clockn}{$reference_clock}[0][$qconf->{clock_indexes}{silicon_frequency}];
      my $fanx_info = $get_fanxinfo->($qconf, $port);

      my $period = sprintf("%4.1f", 1000/$freq);
      my $xcel_delay = sprintf("%4.1f", $cxbudget *10/$freq);
      my $gl_delay = sprintf("%4.1f", $minmax[$_]*10/$freq);
      $qc_pushonce->(
       $qclog,
       $once,
       "(XCEL2HM vs GUIDELINE) Budget Check: Failed",
       $port,
       $dir,
       $reference_clock,
       "$freq    ($period)",
       ($_ ? 'Max' : 'Min'),
       "$cxbudget     ($xcel_delay)",
       "$minmax[$_]     ($gl_delay)",
       @interface_n_re_info,
       $qconf->{fanx} ? $fanx_info : '+',
       $qconf->{uicomment} ? $cbgt->[$qconf->{indexes}{comment}] : '+',
      );

      $$budget_check{budget_failed}++;
     } else {
      my @interface_n_re_info = $zero_one_flag ? split(/\s+:\s+/, $$match_port{$port}{regexes}[0]) : ('NOT_COVERED', 'not_applicable');
      my $freq = $$groups{clocks}{clockn}{$reference_clock}[0][$qconf->{clock_indexes}{silicon_frequency}];
      my $fanx_info = $get_fanxinfo->($qconf, $port);

      my $period = sprintf("%4.1f", 1000/$freq);
      my $xcel_delay = sprintf("%4.1f", $cxbudget *10/$freq);
      my $gl_delay = sprintf("%4.1f", $minmax[$_]*10/$freq);
      $qc_pushonce->(
       $qclog,
       $once,
       "(XCEL2HM vs GUIDELINE) Budget Check: Passed",
       $port,
       $dir,
       $reference_clock,
       "$freq    ($period)",
       ($_ ? 'Max' : 'Min'),
       "$cxbudget     ($xcel_delay)",
       "$minmax[$_]     ($gl_delay)",
       @interface_n_re_info,
       $qconf->{fanx} ? $fanx_info : '+',
       $qconf->{uicomment} ? $cbgt->[$qconf->{indexes}{comment}] : '+',
      );
     }
    } elsif ($minmax[$_] eq '-') {
     $qc_pushonce->(
      $qclog,
      $once,
      "(XCEL2HM vs GUIDELINE) No Guideline Budget defined",
      $port,
      $dir,
      ($_ ? 'Max' : 'Min'),
      $minmax[$_],
     )
    } elsif ($minmax[$_] eq '?') {
     print $qcflowlog "($qconf->{progname}) -W- Please manually check the *".($_ ? 'Max' : 'Min').
                     "* Budget for port '$port'/'$reference_clock' (A:$cminmax[$_] vs. GL:$minmax[$_]).\n";
    } else {
     print $qcflowlog "($qconf->{progname}) -W- Please manually check the *".($_ ? 'Max' : 'Min').
                     "* Budget for port '$port'/'$reference_clock'. GL is expressed in (ns) (A:$cminmax[$_] vs. GL:$minmax[$_]).\n";
    }
   }

   print $qcflowlog "\n".('#' x 80)."\n";
  }

  print $qcflowlog "\n\n";
 }

 return
}

#------------------------------------------------------------------------------
# Function: clock_cts_info
# Purpose : Preserve the historical qcflow_clock_ctsinfo CTS range summary under
#           the QC flow package owner.
# Args    : ($qconf, $extracted_cts)
# Returns : undef after updating $qconf->{_ctsinfo_rca} when both LIB inputs exist
#------------------------------------------------------------------------------
sub clock_cts_info {
 my ($qconf, $extracted_cts) = @_;

 return unless $qconf->{qclib} && $qconf->{noctslib};

 my %ctsinfo_range;
 my %clock_2_pin;
 HUtils::Recurse($extracted_cts, sub {my ($info, $cts_table) = @_;
   push @{$ctsinfo_range{$info->[2]}}, map {@$_} @$cts_table[1 .. $#$cts_table];
   push @{$clock_2_pin{$info->[2]}{$info->[0]}}, map {@$_} @$cts_table[1 .. $#$cts_table];
 });

 my @ctsinfo;
 foreach (keys %ctsinfo_range) {
  # Will consider only positive CTS info
  my @sorted = sort {$a <=> $b} grep {$_ >= 0} @{$ctsinfo_range{$_}};

  # Need to also convert them in pico-seconds
  my $xcel2hmin = $qconf->{_groups}{clocks}{clockn}{$_}[0][$qconf->{clock_indexes}{smallest_insertion_delay}] * 1000;
  my $xcel2hmax = ($xcel2hmin + $qconf->{_groups}{clocks}{clockn}{$_}[0][$qconf->{clock_indexes}{skew}] * 1000);

  push @ctsinfo, [$_,
                  ($sorted[0]         < $xcel2hmin ? "V:" : "").sprintf("%4.2f", $sorted[0]),
                  ($sorted[$#sorted] > $xcel2hmax ? "V:" : "").sprintf("%4.2f", $sorted[$#sorted]),
                  sprintf("%4.2f", $xcel2hmin),
                  sprintf("%4.2f", $xcel2hmax)]
 }

 $qconf->{_ctsinfo_rca} = Table2SS::RCAllocate(1, 1, 1, [\@ctsinfo], 'ctsinfo');
 return
}

#------------------------------------------------------------------------------
# Function: prepare_qclog_data
# Purpose : Preserve the historical qcflow_qclogdata qclog table preparation
#           helper under the QC flow package owner.
# Args    : ($qconf)
# Returns : undef after updating _qclogdata_h and _qclogdata_a
#------------------------------------------------------------------------------
sub prepare_qclog_data {
 my ($qconf) = @_;

 my $logindex = 0;
 HUtils::Recurse($qconf->{_qclog}, sub {my ($info, $a2d) = @_;
  print "($qconf->{progname}) -I- Processing '$info->[0]'..\n";

  if ($qconf->{_filter_info}{$info->[0]}) {
   print "($qconf->{progname}) -I- Filtering '$info->[0]'..\n";

   $a2d = TableGrep::Filter($qconf->{_filter_handler}->($qconf->{_filter_info}{$info->[0]}), $a2d, invert=>1);
   return unless $a2d;
  }

  # Mapping between table names, 'Violating timing arcs', ..., and their position in the qclog tables.
  $qconf->{_qclogdata_h}{$info->[0]} = $logindex;
  my $myre = join('|', @{$qconf->{tableport_2_xcel2hm_re}});
  if ($info->[0] =~ /$myre/o) {
   $a2d = [map {my $lindex = -1;
                [map {++$lindex;
                  $lindex == 0 ? "internal:XCEL2HM_UITiming!".Table2SS::TableTreeA1($qconf->{_rca_qcflow_port_2_xcel2hm_budget}, [$_]).'@'.$_: $_
                     } @$_]
               } @$a2d];
  }

  push @{$qconf->{_qclogdata_a}}, Table2SS::TableHandler($a2d, "qcflow_$info->[0]");
  ++$logindex;
 });

 return
}

#------------------------------------------------------------------------------
# Function: write_qclog_links
# Purpose : Preserve the historical qcflow_links_n_qclog workbook/link writer
#           under the QC flow package owner.
# Args    : ($qconf)
# Returns : undef after creating links/qclog sheets and storing _logallocate
#------------------------------------------------------------------------------
sub write_qclog_links {
 my ($qconf) = @_;

 $qconf->{_qcwb} = Table2SS::AddWorkBook($qconf->{_qco});
 my $logallocate = Table2SS::RCAllocate(1, 1, 1, $qconf->{_qclogdata_a});

 print "($qconf->{progname}) -I- Creating '$qconf->{_qco}'..\n";
 my @links_list  = ([map {["internal:qclog!".$logallocate->[$qconf->{_qclogdata_h}{$_}]{a1}."\@$_"]} keys %{$qconf->{_qclogdata_h}}]);
 push @links_list, [["internal:clock_ctsinfo!".$qconf->{_ctsinfo_rca}[0]{a1}."\@Clocks Min and Max CTS information"]] if $qconf->{_ctsinfo_rca};

 Table2SS::DriveSheet($qconf->{_qcwb}, 'links', Table2SS::RCAllocate(5, 5, 1, [@links_list], 'qcflow_links', ypad=> 10));
 Table2SS::DriveSheet($qconf->{_qcwb}, 'qclog', $logallocate);

 # Saving the RCAllocate of qclog tables
 $qconf->{_logallocate} = $logallocate;
 return
}

#------------------------------------------------------------------------------
# Function: filter_handler
# Purpose : Preserve the historical qcflow_filter_handler expression formatting
#           helper under the QC flow package owner.
# Args    : scalar expression or arrayref of expressions
# Returns : scalar expression or grouped OR expression
#------------------------------------------------------------------------------
sub filter_handler {
 return $_[0] unless ref $_[0];
 return q{(}.join(') || (', @{$_[0]}).q{)}
}

1;
