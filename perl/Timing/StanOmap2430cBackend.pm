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
