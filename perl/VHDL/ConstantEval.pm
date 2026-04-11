#------------------------------------------------------------------------------
# Package: VHDL::ConstantEval
# Purpose: Domain owner for VHDL constant evaluation helpers that were
#          migrated out of legacy `.plg` files and should no longer live under
#          plugin-branded scaffolding.
#------------------------------------------------------------------------------
package VHDL::ConstantEval;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

#------------------------------------------------------------------------------
# Function: evaluate_constant_values
# Purpose : Read one VHDL file, extract simple constant assignments, remove
#           `_init_c` constants, and resolve references inside the remaining
#           constant-value expressions.
# Args    : ($vhdl_file)
# Returns : hashref mapping constant names to evaluated values
#------------------------------------------------------------------------------
sub evaluate_constant_values {
 my ($vhdl_file) = @_;

 my $slurp = _slurp_file($vhdl_file);
 $slurp =~ s/--.*//go;

 my $constants = {$slurp =~ /\bconstant\s+(\w+?)\s*:.+?:=\s*(.+?)\s*;/sgi};
 $constants = {map {$_ => $$constants{$_}} grep {!/init_c$/o} keys %$constants};

 substitute_hash_values($constants);

 return $constants
}

#------------------------------------------------------------------------------
# Function: substitute_hash_values
# Purpose : Preserve the historical `hvalue_substitute` behavior: repeatedly
#           substitute identifier references from the same hash, then evaluate
#           the resulting expression for each defined value.
# Args    : ($hashref)
# Returns : the same hashref, mutated in place
#------------------------------------------------------------------------------
sub substitute_hash_values {
 my ($values) = @_;

 foreach my $key (keys %$values) {
  local $_ = $$values{$key};
  next unless $_;
  s/((?<!')\b[a-z]\w*)/$$values{$1}/goi while /(?<!')\b[a-z]\w*/oi;
  {
   local $@;
   $$values{$key} = eval $_;
  }
 }

 return $values
}

#------------------------------------------------------------------------------
# Function: print_constant_values_for_conf
# Purpose : Preserve the former `vhdconst_eval` action behavior as an explicit
#           package function for callers that already have the action config.
# Args    : ($conf_hashref) with `_argv->[0]`
# Returns : undef after printing aligned constant values
#------------------------------------------------------------------------------
sub print_constant_values_for_conf {
 my ($conf) = @_;

 require RTLUtils;

 my %constants = %{evaluate_constant_values($$conf{_argv}[0])};
 my $align = RTLUtils::string_align([keys %constants]);
 print map {"$$align{$_} : $constants{$_}\n"} keys %constants;

 return
}

sub _slurp_file {
 my ($file) = @_;

 open(my $fh, '<', $file) || die "(VHDL::ConstantEval::_slurp_file) -E- Can't read open '$file',";
 local $/;
 return <$fh>
}

1;
