#------------------------------------------------------------------------------
# Package: Timing::SetupHold
# Purpose: Setup/hold timing math and traversal callbacks that migrated out of
#          legacy `.plg` helper lookup.
#------------------------------------------------------------------------------
package Timing::SetupHold;

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
# Function: _indexes
# Purpose : Return the timing-index map used by legacy setup/hold callers.
# Args    : ($conf)
# Returns : hashref of column-name to column-index mappings
#------------------------------------------------------------------------------
sub _indexes {
 my ($conf) = @_;
 return $conf->{_indexes} || $conf->{indexes} || {}
}

#------------------------------------------------------------------------------
# Function: delay_calculator
# Purpose : Resolve one historical DxCy calculator name into a package-owned
#           callback without routing through legacy plugin lookup.
# Args    : ($name)
# Returns : coderef delay calculator
#------------------------------------------------------------------------------
sub delay_calculator {
 my ($name) = @_;
 my %calculators = (
  DiCi => \&delay_dici,
  DiCo => \&delay_dico,
  DoCi => \&delay_doci,
  DoCo => \&delay_doco,
 );
 my $display_name = defined($name) ? $name : '<undef>';
 die "(Timing::SetupHold::delay_calculator) -E- unsupported delay calculator '$display_name',"
  unless defined($name) && exists $calculators{$name};
 return $calculators{$name}
}

#------------------------------------------------------------------------------
# Function: calculate_path_delay
# Purpose : Calculate one named DiCi/DiCo/DoCi/DoCo timing-path delay.
# Args    : ($name, $conf, $path, $type)
# Returns : numeric delay value
#------------------------------------------------------------------------------
sub calculate_path_delay {
 my ($name, $conf, $path, $type) = @_;
 return delay_calculator($name)->($conf, $path, $type)
}

#------------------------------------------------------------------------------
# Function: delay_dici
# Purpose : Preserve the historical DiCi delay formula.
# Args    : ($conf, $path, $type)
# Returns : numeric delay value
#------------------------------------------------------------------------------
sub delay_dici {
 my ($conf, $path, $type) = @_;
 my $idx = _indexes($conf);
 return ($type eq 'max' ? 1 : -1) * ($path->[$idx->{capture_start_time}] - $path->[$idx->{startpoint_delay}]) - $path->[$idx->{slack}]
}

#------------------------------------------------------------------------------
# Function: delay_dico
# Purpose : Preserve the historical DiCo delay formula.
# Args    : ($conf, $path, $type)
# Returns : numeric delay value
#------------------------------------------------------------------------------
sub delay_dico {
 my ($conf, $path, $type) = @_;
 my $idx = _indexes($conf);
 return ($type eq 'max' ? 1 : -1) * ($path->[$idx->{capture_start_time}] - $path->[$idx->{launch_start_time}] - $path->[$idx->{input_external_delay}]) - $path->[$idx->{slack}]
}

#------------------------------------------------------------------------------
# Function: delay_doci
# Purpose : Preserve the historical DoCi delay formula used by the legacy helper.
# Args    : ($conf, $path, $type)
# Returns : numeric delay value
#------------------------------------------------------------------------------
sub delay_doci {
 my ($conf, $path, $type) = @_;
 my $idx = _indexes($conf);
 return $path->[$idx->{arrival_time}] - $path->[$idx->{launch_start_time}]
}

#------------------------------------------------------------------------------
# Function: delay_doco
# Purpose : Preserve the historical DoCo delay formula.
# Args    : ($conf, $path, $type)
# Returns : numeric delay value
#------------------------------------------------------------------------------
sub delay_doco {
 my ($conf, $path, $type) = @_;
 my $idx = _indexes($conf);
 return ($type eq 'max' ? 1 : -1) * ($path->[$idx->{capture_start_time}] - $path->[$idx->{launch_start_time}] + $path->[$idx->{output_external_delay}]) - $path->[$idx->{slack}]
}

#------------------------------------------------------------------------------
# Function: tss_setup_hold_delay
# Purpose : Preserve the historical tss_setup_hold delay formula.
# Args    : ($conf, $path, $type)
# Returns : numeric delay value
#------------------------------------------------------------------------------
sub tss_setup_hold_delay {
 my ($conf, $path, $type) = @_;
 my $idx = _indexes($conf);
 return ($type eq 'max' ? 1 : -1) * ($path->[$idx->{capture_start_time}] - $path->[$idx->{launch_start_time}] - $path->[$idx->{input_external_delay}])
}

#------------------------------------------------------------------------------
# Function: tss_tmax_tmin_delay
# Purpose : Preserve the historical tss_tmax_tmin delay formula.
# Args    : ($conf, $path, $type)
# Returns : numeric delay value
#------------------------------------------------------------------------------
sub tss_tmax_tmin_delay {
 my ($conf, $path, $type) = @_;
 my $idx = _indexes($conf);
 return $path->[$idx->{capture_start_time}] - $path->[$idx->{launch_start_time}] + ($type eq 'max' ? 1 : -1) * $path->[$idx->{output_external_delay}]
}

#------------------------------------------------------------------------------
# Function: collect_dxcy
# Purpose : Preserve the historical DxCy traversal callback while resolving
#           delay calculators through this package owner instead of plugins.
# Args    : ($info, $dxcy, $maxcheck, $mincheck, $iomodes, $corners, $modes, $crail, $conf)
# Returns : undef after mutating $crail
#------------------------------------------------------------------------------
sub collect_dxcy {
 my ($info, $dxcy, $maxcheck, $mincheck, $iomodes, $corners, $modes, $crail, $conf) = @_;
 my ($path_type, $sens, $port) = @$info;
 my $delay_for = delay_calculator($dxcy);
 my $callnum = $$crail{callnum} || 0;

 $crail->{pathtype}{$path_type}{header} = "+ $path_type + @$corners";
 foreach my $cmode (@$modes) {
  my $i = 0;
  foreach my $ciomode (@$iomodes) {
   my $j = 0;
   foreach my $ccorner (@$corners) {
    my $official_target_period = 1000 / $conf->{'official-target-frequencies'}{$path_type}{$ccorner};

    my $sheetname = "shtm_${path_type}_$callnum$i$j";
    $$crail{pathsets}{$sheetname}{setup} = $maxcheck->{$ccorner}{$cmode}{$ciomode}{$path_type}{$sens}{$port};
    $$crail{pathsets}{$sheetname}{hold} = $mincheck->{$ccorner}{$cmode}{$ciomode}{$path_type}{$sens}{$port};

    my $maxdelay = sprintf("%4.2f", $delay_for->($conf, $maxcheck->{$ccorner}{$cmode}{$ciomode}{$path_type}{$sens}{$port}[0], 'max')) || '-';
    my $mindelay = sprintf("%4.2f", $delay_for->($conf, $mincheck->{$ccorner}{$cmode}{$ciomode}{$path_type}{$sens}{$port}[0], 'min')) || '-';
    my $maxbudget = sprintf("%3.1f", 100 * $maxdelay / $official_target_period);
    my $maxv = "$maxdelay($maxbudget%)";

    push @{$crail->{pathtype}{$path_type}{data}{$port}{$sens}{$ciomode}}, "internal:$sheetname!A1@" . "$maxv/$mindelay";
    ++$j;
   }

   ++$i;
  }
 }

 ++$$crail{callnum};
 return
}

1;
