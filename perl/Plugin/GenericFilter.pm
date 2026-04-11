#------------------------------------------------------------------------------
# Package: Plugin::GenericFilter
# Purpose: Package-backed owner for the generic table-filter grouping actions
#          that historically lived entirely in `plugin/genericfilter.plg`.
#------------------------------------------------------------------------------
package Plugin::GenericFilter;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

#------------------------------------------------------------------------------
# Function: _require_tablegrep
# Purpose : Lazy-load TableGrep only when a generic-filter action actually
#           needs table-map indexing or filtering.
# Args    : ()
# Returns : true on successful load
#------------------------------------------------------------------------------
sub _require_tablegrep {
 require TableGrep;
 return 1
}

#------------------------------------------------------------------------------
# Function: _require_hutils
# Purpose : Lazy-load HUtils only when a recursive grouping action needs the
#           HUtils tree helpers, avoiding a compile-time HUtils/plugin cycle.
# Args    : ()
# Returns : true on successful load
#------------------------------------------------------------------------------
sub _require_hutils {
 require HUtils;
 return 1
}

#------------------------------------------------------------------------------
# Function: _action_handlers
# Purpose : Return the supported GenericFilter action dispatch table.
# Args    : ()
# Returns : hashref mapping action names to coderefs
#------------------------------------------------------------------------------
sub _action_handlers {
 state $handlers = {
  group_by => \&group_by,
  group_by_port => \&group_by_port,
  group_by_ioclock => \&group_by_ioclock,
  group_byRE => \&group_byRE,
 };
 return $handlers
}

#------------------------------------------------------------------------------
# Function: dispatch
# Purpose : Execute one GenericFilter action by its configuration action name,
#           without routing through the legacy `.plg` runtime.
# Args    : ($action, $conf, $info, $data, $maptable, $varargs)
# Returns : action return payload, normally a hashref grouping tree
#------------------------------------------------------------------------------
sub dispatch {
 my ($action, @args) = @_;
 my $handler = _action_handlers()->{$action};
 die "(Plugin::GenericFilter::dispatch) -E- Unsupported generic filter action '$action',"
  unless ref($handler) eq 'CODE';
 return $handler->(@args)
}

#------------------------------------------------------------------------------
# Function: group_by
# Purpose : Group table rows by the value of one named maptable field. When
#           `clock_aware` is set, a trailing clock tick quote is ignored for the
#           grouping key.
# Args    : ($conf, $info, $data, $maptable, $varargs)
# Returns : hashref keyed by field value, each value holding matching rows
#------------------------------------------------------------------------------
sub group_by {
 my ($conf, $info, $data, $maptable, $varargs) = @_;

 die "(GenericFilter/group_by) -E- No argument provided (usage: group_by <FieldName> (maptable <MapTable>)? (clock_aware 0|1)? (verbose 0|1)?)" unless @$varargs;
 my $field = shift @$varargs;
 my %option = map {%$_} grep {ref } @$varargs;

 _require_tablegrep();
 my $a_maptable = $option{maptable} || $maptable;
 my $field_index = TableGrep::IndexOf($field, $a_maptable);
 $option{verbose} && print "genericfilter_group_by: info<@$info> fields<$field> maptable<$a_maptable> field_indexes<$field_index>\n";

 my %ret;
 unless ($option{clock_aware}) {
  foreach (@$data) {push @{$ret{$$_[$field_index]}}, $_}
 } else {
  foreach (@$data) {
   my $rmtick = $$_[$field_index];
   $rmtick =~ s/'$//o;
   push @{$ret{$rmtick}}, $_
  }
 }

 return \%ret
}

#------------------------------------------------------------------------------
# Function: group_by_port
# Purpose : Split timing rows by input/output port name using the same nested
#           HUtils::GenericFilter recursion as the historical plugin action.
# Args    : ($conf, $info, $data, $maptable, $varargs)
# Returns : hashref containing recursively grouped input/output port buckets
#------------------------------------------------------------------------------
sub group_by_port {
 my ($conf, $info, $data, $maptable, $varargs) = @_;

 die "(GenericFilter -> group_by_port) -E- No argument provided (usage: group_by_port input|output|both)," unless @$varargs;

 my $arg = shift @$varargs;
 die "(GenericFilter -> group_by_port) -E- Unsupported '$arg' argument (usage: group_by_port input|output|both)," unless $arg =~ /input|output|both/o;

 _require_tablegrep();
 _require_hutils();
 my @outarray;
 if ($arg =~ /input|both/o) {
  my $input_paths = TableGrep::Filter('startpoint !~ /\// && endpoint =~ /\//', $data);
  print "(GenericFilter -> group_by_port) -W- No *input* paths found for <... @$info>\n" unless $input_paths;

  if ($input_paths) {
   my %portnames = map {$$_[$$conf{_indexes}{startpoint}] => 1} @$input_paths;
   $conf->{"__startpoint"}{$_} = "startpoint =~ /^$_\$/" foreach (keys %portnames);
   push @outarray, %{HUtils::GenericFilter($conf, $input_paths, ["__startpoint"], maptable=>$maptable, exclusive=>1)};

   delete $conf->{"__startpoint"};
  }
 }

 if ($arg =~ /output|both/o) {
  my $output_paths = TableGrep::Filter('startpoint =~ /\// && endpoint !~ /\//', $data);
  print "(GenericFilter -> group_by_port) -W- No *output* paths found for <... @$info>\n" unless $output_paths;

  if ($output_paths) {
   my %portnames = map {$$_[$$conf{_indexes}{endpoint}] => 1} @$output_paths;
   $conf->{"__endpoint"}{$_} = "endpoint =~ /^$_\$/" foreach (keys %portnames);
   push @outarray, %{HUtils::GenericFilter($conf, $output_paths, ["__endpoint"], maptable=>$maptable, exclusive=>1)};

   delete $conf->{"__endpoint"};
  }
 }

 return {@outarray}
}

#------------------------------------------------------------------------------
# Function: group_by_ioclock
# Purpose : Split timing rows by input/output clock name, normalizing optional
#           clock tick quotes while preserving the historical recursive output.
# Args    : ($conf, $info, $data, $maptable, $varargs)
# Returns : hashref containing recursively grouped input/output clock buckets
#------------------------------------------------------------------------------
sub group_by_ioclock {
 my ($conf, $info, $data, $maptable, $varargs) = @_;

 die "(GenericFilter -> group_by_ioclock) -E- No argument provided (usage: group_by_ioclock input|output|auto)," unless @$varargs;

 my $arg = shift @$varargs;
 die "(GenericFilter -> group_by_ioclock) -E- Unsupported '$arg' argument (usage: group_by_ioclock input|output|auto)," unless $arg =~ /input|output|auto/o;

 _require_tablegrep();
 _require_hutils();
 my @outarray;
 if ($arg =~ /input|auto/o) {
  my $input_paths = TableGrep::Filter('startpoint !~ /\// && endpoint =~ /\//', $data);
  print "(GenericFilter -> group_by_ioclock) -W- No *input* paths found for <... @$info>\n" unless $input_paths;

  if ($input_paths) {
   my %ioclocknames = map {$$_[$$conf{_indexes}{startpoint_clock}] => 1} @$input_paths;
   do {s/'//; $conf->{"__startpoint_clock"}{$_} = "startpoint_clock =~ /^$_'?\$/"} foreach (keys %ioclocknames);
   push @outarray, %{HUtils::GenericFilter($conf, $input_paths, ["__startpoint_clock"], maptable=>$maptable, exclusive=>1)};

   delete $conf->{"__startpoint_clock"};
  }
 }

 if ($arg =~ /output|auto/o) {
  my $output_paths = TableGrep::Filter('startpoint =~ /\// && endpoint !~ /\//', $data);
  print "(GenericFilter -> group_by_ioclock) -W- No *output* paths found for <... @$info>\n" unless $output_paths;

  if ($output_paths) {
   my %ioclocknames = map {$$_[$$conf{_indexes}{endpoint_clock}] => 1} @$output_paths;
   do {s/'//; $conf->{"__endpoint_clock"}{$_} = "endpoint_clock =~ /^$_'?\$/"} foreach (keys %ioclocknames);
   push @outarray, %{HUtils::GenericFilter($conf, $output_paths, ["__endpoint_clock"], maptable=>$maptable)};

   delete $conf->{"__endpoint_clock"};
  }
 }

 return {@outarray}
}

#------------------------------------------------------------------------------
# Function: group_byRE
# Purpose : Group table rows by the capture list produced when one named field
#           is matched against a caller-provided regular expression.
# Args    : ($conf, $info, $data, $maptable, $varargs)
# Returns : nested hashref keyed by regex capture values
#------------------------------------------------------------------------------
sub group_byRE {
 my ($conf, $info, $data, $maptable, $varargs) = @_;

 die "(GenericFilter/group_byRE) -E- No argument provided (usage: group_byRE <FieldName> <RegexWithCapture> (maptable <MapTable>)? (verbose 0|1)?) " unless @$varargs;
 my ($field, $fre) = splice @$varargs, 0, 2;
 my %option = map {%$_} grep {ref } @$varargs;

 _require_tablegrep();
 _require_hutils();
 my $a_maptable = $option{maptable} || $maptable;
 my $field_index = TableGrep::IndexOf($field, $a_maptable);
 $option{verbose} && print "genericfilter_group_byRE: info<@$info> fields<$field> maptable<$a_maptable> field_indexes<$field_index>\n";

 my $ret = {};
 my $compiledre = qr/$fre/;
 foreach (@$data) {
  my @captlist = $$_[$field_index] =~ $compiledre;
  unless (@captlist) {
   warn "(GenericFilter/group_byRE) -E- Regex '$compiledre' did not match '$$_[$field_index]',";
   next
  }

  HUtils::avv_push($ret, \@captlist, $_);
 }

 return $ret
}

1;
