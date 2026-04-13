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

1;
