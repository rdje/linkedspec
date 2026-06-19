#------------------------------------------------------------------------------
# Package: QC::TclInterconn
# Purpose: QC Tcl interconnect and FANX helpers migrated out of legacy `.plg`
#          callback lookup.
#------------------------------------------------------------------------------
package QC::TclInterconn;

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
# Function: _require_hutils
# Purpose : Lazy-load recursive hash helpers only when FANX loading needs them.
# Args    : ()
# Returns : true on successful load
#------------------------------------------------------------------------------
sub _require_hutils {
 require HUtils;
 return 1
}

#------------------------------------------------------------------------------
# Function: _require_table2ss
# Purpose : Lazy-load Table2SS only when FANX table shaping needs it.
# Args    : ()
# Returns : true on successful load
#------------------------------------------------------------------------------
sub _require_table2ss {
 require Table2SS;
 return 1
}

#------------------------------------------------------------------------------
# Function: append_interconnect_tcl
# Purpose : Preserve the historical tcl4interconn Tcl snippet builder under a
#           QC package owner.
# Args    : ($qconf, $groups, $port, $tcl4interconn)
# Returns : undef after optionally appending one Tcl snippet
#------------------------------------------------------------------------------
sub append_interconnect_tcl {
 my ($qconf, $groups, $port, $tcl4interconn) = @_;

 return if $$groups{ios}{ion}{$port}[0][$qconf->{indexes}{direction}] =~ /$qconf->{vssvdd_re}/;

 my $direction = $groups->{ios}{ion}{$port}[0][$qconf->{indexes}{direction}] =~ /in/io ? "IN" : "OUT";
 my $get_fxy   = 'get_'.($direction eq 'IN' ? "fir" : "for");

 push @$tcl4interconn, <<TCL4INTERCONN ;
   set ${port}_list {}
   foreach_in_collection myep [$get_fxy -thrulatch -unknown \$MODULE_PATH/$port] {
    append ${port}_list " [get_attribute \$myep full_name]"
   }

   if {\$${port}_list != {}} {
    echo "\$MODULE_PATH/$port $direction \$${port}_list"
   } else {
    echo "\$MODULE_PATH/$port $direction"
   }
TCL4INTERCONN

 return
}

#------------------------------------------------------------------------------
# Function: load_fanx
# Purpose : Preserve the historical tcl4fanx FANX file loader and table index
#           allocation under a QC package owner.
# Args    : ($qconf)
# Returns : hashref of FANX info keyed by stripped port name
#------------------------------------------------------------------------------
sub load_fanx {
 my ($qconf) = @_;

 -s $qconf->{fanx} || die "($qconf->{progname}) -E- FANX file '$qconf->{fanx}' is either empty or doesn't exist,";

 _require_hutils();
 _require_table2ss();

 open(my $fanx_fh, '<', $qconf->{fanx}) or die "($qconf->{progname}) -E- FANX file '$qconf->{fanx}' is either empty or doesn't exist,";
 my $fanx_text = do {local $/; <$fanx_fh>};
 close $fanx_fh;

 my $fanxo = {map {
       my @fanx = split(/\s+/o, $_);
       $fanx[0] =~ s/.+\///o;
       $fanx[0] => (@fanx == 2 ? undef : (@fanx == 3 ? $fanx[2] : Table2SS::List2Table([@fanx[2 .. $#fanx]], 1)))
      } grep !/^(?:\(|\[)/o, split(/\n/o, $fanx_text)
 };

 my %withtable;
 HUtils::KeyGrep($fanxo, sub {ref $_[1]}, sub {my ($info, $table) = @_;
  $withtable{pop @$info} = $table;
 });

 $qconf->{_fanxtree} = Table2SS::TableTreeAllocate(\%withtable);
 return $fanxo
}

#------------------------------------------------------------------------------
# Function: fanx_info
# Purpose : Preserve the historical get_fanxinfo display formatter under a QC
#           package owner.
# Args    : ($qconf, $port)
# Returns : display string for one port's FANX info, or '-'
#------------------------------------------------------------------------------
sub fanx_info {
 my ($qconf, $port) = @_;

 my $fanx_info  = do {
        unless (ref $qconf->{_fanx}{$port}) {
         $qconf->{_fanx}{$port}
        } else {
         _require_table2ss();
         "internal:fanx!".Table2SS::TableTreeA1($qconf->{_fanxtree}, [$port])."\@".$qconf->{_fanx}{$port}[0][0]."  (".scalar(@{$qconf->{_fanx}{$port}}).")"
        }

 } if $qconf->{_fanx};

 return $fanx_info || '-'
}

1;
