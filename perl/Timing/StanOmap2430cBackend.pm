#------------------------------------------------------------------------------
# Package: Timing::StanOmap2430cBackend
# Purpose: STAN OMAP2430C backend frequency-detail helpers that migrated out of
#          legacy `.plg` helper lookup.
#------------------------------------------------------------------------------
package Timing::StanOmap2430cBackend;

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
# Function: frequency_detail_filename
# Purpose : Preserve the historical get_freqency_detailed_fname naming scheme
#           behind a correctly spelled package function.
# Args    : ($path_type, $direction, $io_mode_index, $corner)
# Returns : filename stem used for frequency-detail LOF files and workbook links
#------------------------------------------------------------------------------
sub frequency_detail_filename {
 my ($path_type, $direction, $io_mode_index, $corner) = @_;
 my $safe_corner = $corner;
 $safe_corner =~ s/\./_/g if defined $safe_corner;
 return (split(//, $direction))[0] . '_' . join("", (split(//, $path_type))[0 .. 2]) . '_' . $io_mode_index . '_' . $safe_corner
}

#------------------------------------------------------------------------------
# Function: record_frequency_detail
# Purpose : Preserve the historical freqency_detailed traversal callback.
# Args    : ($info, $frequencies, $conf)
# Returns : undef after mutating $conf->{_freqency_detailed}
#------------------------------------------------------------------------------
sub record_frequency_detail {
 my ($info, $frequencies, $conf) = @_;

 my ($path_type, $direction, $io_mode, $corner) = @$info;
 my ($io_mode_index) = $io_mode =~ /iomode(\d+)/;

 my $has_questionable_frequency = grep { !/\d+/ } @$frequencies;
 my $minimum_frequency = $has_questionable_frequency ? '?' : (sort { $a <=> $b } @$frequencies)[0];
 $conf->{_freqency_detailed}{$path_type}{$direction}[$io_mode_index]{$corner} = $minimum_frequency;
 return
}

#------------------------------------------------------------------------------
# Function: filter_port_timing_paths
# Purpose : Preserve the historical portiming traversal callback while keeping
#           the callback under an explicit package owner.
# Args    : ($info, $paths, $conf)
# Returns : hashref keyed by configured port-timing regex, with filtered paths
#------------------------------------------------------------------------------
sub filter_port_timing_paths {
 my ($info, $paths, $conf) = @_;

 require TableGrep;

 my %paths_by_port_filter;
 my $sensitivity = $info->[-1];
 foreach my $port_filter (@{$conf->{portiming}{$sensitivity}}) {
  my $field = $sensitivity =~ /input/ ? 'startpoint' : 'endpoint';
  my $filter_expr = "$field =~ /$port_filter/";
  my $filtered_paths = TableGrep::Filter($filter_expr, $paths);

  $paths_by_port_filter{$port_filter} = $filtered_paths if $filtered_paths;
 }

 return \%paths_by_port_filter
}

#------------------------------------------------------------------------------
# Function: collect_sta_frequency
# Purpose : Preserve the historical stafrequency traversal callback while
#           keeping STA-frequency classification under the timing owner.
# Args    : ($info, $paths, $conf)
# Returns : undef after mutating STA frequency/path buckets in $conf
#------------------------------------------------------------------------------
sub collect_sta_frequency {
 my ($info, $paths, $conf) = @_;
 my $verbose = $conf->{_verbose} // 0;

 unless ($paths) {
  $verbose > 1 && print "(stafrequency) -W- No DATA for '@$info'\n";
  return
 }

 $verbose && print "stafrequency: @$info\n";

 my $corner = $info->[0];
 my $iomode = $info->[2];
 my $pathinstance = $info->[3];
 my $pathsens = $info->[4];

 my $cycle_type = $conf->{cycle_type}{$pathinstance}{$pathsens};
 my $edge_role = $pathsens eq 'input' ? 'launch' : 'capture';
 my $sens_edgetype = $conf->{cycle_type}{$pathinstance}{"${pathsens}_${edge_role}_edge"};

 $verbose > 1
  && print "pathinstance<$pathinstance> pathsens<$pathsens> cycle_type<$cycle_type> sens_edgetype<$sens_edgetype>\n";
 my $other_edgetype = $cycle_type =~ /full/
  ? ($sens_edgetype eq 'rise' ? 'rise' : 'fall')
  : ($sens_edgetype eq 'rise' ? 'fall' : 'rise');

 my $clock_name = $pathsens eq 'input' ? 'startpoint_clock' : 'endpoint_clock';
 my $other_clock_name = $clock_name eq 'startpoint_clock' ? 'endpoint_clock' : 'startpoint_clock';

 unless (exists $conf->{frequencies}{$corner}) {
  print "(stafrequency) -W- Corner '$corner' has no associated frequency\n";
  return
 }

 my $period = 1000 / $conf->{frequencies}{$corner};

 foreach my $path (@$paths) {
  my $actual_edge = $path->[$conf->{_indexes}{$clock_name}] =~ /'$/
   ? ($sens_edgetype eq 'rise' ? 'fall' : 'rise')
   : $sens_edgetype;
  my $other_actual_edge = $path->[$conf->{_indexes}{$other_clock_name}] =~ /'$/
   ? ($other_edgetype eq 'rise' ? 'fall' : 'rise')
   : $other_edgetype;

  $verbose > 1
   && print "INFO[@$info] cycle_type($cycle_type) sens_edgetype($sens_edgetype) edge1<$actual_edge> o_edgetype($other_edgetype) edge2<$other_actual_edge>\n";

  if (
   $path->[$conf->{_indexes}{"${clock_name}_edge"}] eq $actual_edge
   && $path->[$conf->{_indexes}{"${other_clock_name}_edge"}] eq $other_actual_edge
  ) {
   $verbose > 1
    && print "-I- *@$info*:\n@$path\n" . ('#' x 80) . "\n";

   my $slack = $path->[$conf->{_indexes}{slack}];
   my $new_period = $period - $slack * ($cycle_type eq 'full' ? 1 : 2);

   $verbose > 1
    && print "calculation - @$info : edge1<$actual_edge> edge2<$other_actual_edge> slack=$slack period:$period newperiod:$new_period cycle_type:$cycle_type\n\n";

   if ($new_period < 0) {
    $verbose > 1
     && print "($conf->{_program}) -W- The New period is **Negative** that's weird so please carefully check this Path.\n\n";
    push @{$conf->{_questionable_paths}}, $path;
    push @{$conf->{_stafrequency}{$pathinstance}{$pathsens}{$iomode}{$corner}}, "?";
    push @{$conf->{_stafrequency_paths}{$pathinstance}{$pathsens}{$iomode}{$corner}[1]}, $path;
   }
   else {
    push @{$conf->{_stafrequency}{$pathinstance}{$pathsens}{$iomode}{$corner}}, int(1000 / $new_period);
    push @{$conf->{_stafrequency_paths}{$pathinstance}{$pathsens}{$iomode}{$corner}[0]}, $path;
   }

   next
  }

  $verbose
   && print "(stafrequency) -W- The following path is a potential 'false path' for *@$info*:\n@$path\n" . ('#' x 80) . "\n\n";
  push @{$conf->{_potential_fp}}, $path;
 }

 return
}

#------------------------------------------------------------------------------
# Function: write_tck_delays
# Purpose : Preserve the historical drive_tckdelays DM-measures file writer
#           under the explicit STAN OMAP timing package owner.
# Args    : ($conf, $data)
# Returns : undef after writing stan_tcksegments.lof and per-segment sheets
#------------------------------------------------------------------------------
sub write_tck_delays {
 my ($conf, $data) = @_;
 my @print;

 open(my $fo, ">", "$conf->{_workdir}/stan_tcksegments.lof")
  || die "($conf->{_program}) -E- Can't write open '$conf->{_workdir}/stan_tcksegments.lof', ";
 print {$fo} "=stan_dmeasures=\n";
 print {$fo} "+ + + @{$conf->{'corner-order'}}\n";
 foreach my $cmode (keys %{$conf->{mode}}) {
  foreach my $tseg (sort { $a cmp $b } keys %{$conf->{tck_timing_segments}}) {
   foreach my $min_or_max (qw(min max)) {
    foreach my $ciomode (keys %{$conf->{tck_iomode}}) {
     push @print, $conf->{dmsegment_name_map}{$tseg}, $min_or_max, $ciomode;
     my $corner_index = 0;
     foreach my $ccorner (@{$conf->{'corner-order'}}) {
      my $toprint = $data->{$cmode}{$ciomode}{$ccorner}{$tseg}{$min_or_max};
      my ($iomode_index) = $ciomode =~ /(\d+)/;
      my $sheet = "$conf->{dmsegment_name_map}{$tseg}_${min_or_max}${iomode_index}$corner_index";

      $corner_index++;
      push @print, $toprint ? "internal:$sheet!A1@" . sprintf("%4.2f", $toprint) : '-';

      if ($toprint) {
       open(my $s, ">", "$conf->{_workdir}/$sheet.lof")
        || die "($conf->{_program}) -E- Can't write open '$conf->{_workdir}/$sheet.lof', ";
       print {$s} "=consolidated_ns=\n";
       print {$s} "@$_\n" foreach (@{$data->{$cmode}{$ciomode}{$ccorner}{$tseg}{paths}});
       print {$s} "=consolidated_ns_end=\n";
       close($s);
      }
     }

     print {$fo} "@print\n";
     @print = ();
    }
   }
  }
 }

 print {$fo} "=stan_dmeasures_end=\n";
 close($fo);
 return
}

#------------------------------------------------------------------------------
# Function: write_no_path_check
# Purpose : Preserve the historical drive_nopath_check writer while keeping the
#           no-path traversal out of legacy plugin lookup.
# Args    : ($conf)
# Returns : undef after writing stan_nopath_check.lof
#------------------------------------------------------------------------------
sub write_no_path_check {
 my ($conf) = @_;

 require HUtils;

 open(my $check_fh, ">", "$conf->{_workdir}/stan_nopath_check.lof")
  || die "($conf->{_program}) -E- Can't write open '$conf->{_workdir}/stan_nopath_check.lof', ";
 print {$check_fh} "=stan_nopath_check=\n";

 HUtils::Recurse($conf->{_filteredata}, [\&record_no_path_check, $conf, $check_fh]);

 print {$check_fh} "=stan_nopath_check_end=\n";
 close($check_fh);
 return
}

#------------------------------------------------------------------------------
# Function: record_no_path_check
# Purpose : Preserve the historical nopath_check traversal callback with an
#           explicit output filehandle instead of a package-global CHECK handle.
# Args    : ($info, $paths, $conf, $fh)
# Returns : undef after appending missing-port rows to $fh
#------------------------------------------------------------------------------
sub record_no_path_check {
 my ($info, $paths, $conf, $fh) = @_;
 die "(Timing::StanOmap2430cBackend::record_no_path_check) -E- missing output filehandle,"
  unless $fh;

 my ($corner, $mode, $iomode, $pathinst, $pathsens) = @$info;
 my @interface_ports = @{$conf->{ports}{$pathinst}{$pathsens}};
 my $verbose = $conf->{_verbose} // 0;

 unless ($paths) {
  foreach my $port (@interface_ports) {
   $verbose && print "(nopath_check) -W- No $corner $mode $pathsens path on port '$port' was found for $pathinst\n";
   print {$fh} "$port @$info\n";
  }

  return
 }

 my %found;
 my $start_or_end = $pathsens eq 'input' ? 'startpoint' : 'endpoint';

 foreach my $path (@$paths) {
  foreach my $port (@interface_ports) {
   $found{$port}++ if $path->[$conf->{_indexes}{$start_or_end}] eq $port;
  }
 }

 foreach my $port (@interface_ports) {
  unless (exists $found{$port}) {
   $verbose && print "(nopath_check) -W- No $corner $mode $pathsens path on port '$port' was found for $pathinst\n";
   print {$fh} "$port @$info\n";
  }
 }

 return
}

#------------------------------------------------------------------------------
# Function: write_frequency_detail_paths
# Purpose : Preserve the historical freqency_detailed_paths file writer.
# Args    : ($info, $paths, $conf)
# Returns : undef after writing the detail-path LOF file
#------------------------------------------------------------------------------
sub write_frequency_detail_paths {
 my ($info, $paths, $conf) = @_;

 my ($path_type, $direction, $io_mode, $corner) = @$info;
 my ($io_mode_index) = $io_mode =~ /iomode(\d+)/;
 my $filename = frequency_detail_filename($path_type, $direction, $io_mode_index, $corner);

 open(my $path_fh, ">", "$conf->{_stanpaths_lof_workdir}/$filename.lof")
  || die "($conf->{_program}) -E- Can't write open '$conf->{_stanpaths_lof_workdir}/$filename.lof', ";
 print {$path_fh} "=stan_freqency_detailed_paths=\n";

 if (exists $paths->[0]) {
  print {$path_fh} "@$_\n" foreach (@{$paths->[0]});
 }
 if (exists $paths->[1]) {
  print {$path_fh} "@$_\n" foreach (@{$paths->[1]});
 }

 print {$path_fh} "=stan_freqency_detailed_paths_end=\n";
 close($path_fh);
 return
}

#------------------------------------------------------------------------------
# Function: write_frequency_detail
# Purpose : Preserve the historical drive_freqency_detailed traversal callback.
# Args    : ($info, $frequencies, $conf, $fh)
# Returns : undef after appending one frequency-detail LOF section to $fh
#------------------------------------------------------------------------------
sub write_frequency_detail {
 my ($info, $frequencies, $conf, $fh) = @_;
 die "(Timing::StanOmap2430cBackend::write_frequency_detail) -E- missing output filehandle,"
  unless $fh;

 my $label = join("/", @$info);
 my @sorted_corners = sort { $b <=> $a } keys %{$conf->{frequencies}};
 my $path_type = $info->[0];

 print {$fh} "=stan_frequency_detailed=\n";

 my @official_target_frequencies = map { $conf->{'official-target-frequencies'}{$path_type}{$_} . "(Mhz)" } @sorted_corners;

 print {$fh} join("\t", "+", @official_target_frequencies) . "\n";
 print {$fh} join("\t", $label, @sorted_corners) . "\n";

 my $io_mode_index = 0;
 foreach my $io_mode_entry (@$frequencies) {
  print {$fh} "io_mode$io_mode_index";
  foreach my $corner (@sorted_corners) {
   my $ref_filename = frequency_detail_filename(@$info, $io_mode_index, $corner);
   my $cell_value = $io_mode_entry->{$corner} || "-";
   print {$fh} $cell_value eq '-' ? "\t$cell_value" : "\tinternal:$ref_filename!A1\@$cell_value";
  }

  print {$fh} "\n";
  ++$io_mode_index;
 }

 print {$fh} "=stan_frequency_detailed_end=\n";
 return
}

1;
