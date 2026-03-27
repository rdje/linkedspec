#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::StatementSplit
# Purpose: ActionIR statement-splitting owner for dependency assembly and
#          statement segmentation orchestration.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::StatementSplit;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();

#------------------------------------------------------------------------------
# Function: _require_pkg
# Purpose : Lazy-load one statement-split dependency owner through the shared
#           owner-dispatch seam.
# Args    : ($pkg)
# Returns : requested package name
#------------------------------------------------------------------------------
sub _require_pkg {
 my ($pkg) = @_;
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg);
 return $pkg
}

sub _require_statement_split_core_pkg {
 return _require_pkg('LinkedSpec::ActionIR::StatementSplit::Core')
}

#------------------------------------------------------------------------------
# Function: _call_preserving_err
# Purpose : Preserve caller-visible successful `$@` while executing one
#           statement-split helper callback.
# Args    : ($cb)
# Returns : callback return value in caller context
#------------------------------------------------------------------------------
sub _call_preserving_err {
 my ($cb) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err($cb)
}

#------------------------------------------------------------------------------
# Function: _require_pkg_cb
# Purpose : Lazy-load one statement-split dependency owner and resolve one
#           callback through the shared owner-dispatch seam.
# Args    : ($pkg, $name)
# Returns : callback coderef
#------------------------------------------------------------------------------
sub _require_pkg_cb {
 my ($pkg, $name) = @_;
 return LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, $pkg, $name)
}

sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ActionIR::StatementSplit::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

sub default_deps_for_package {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::build_dep_map(
  __PACKAGE__,
  $pkg,
  [
   'trim_action_ir_value',
  ],
 )
}

sub _split_action_ir_statements {
 my ($code, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 return _call_preserving_err(sub {
  _require_statement_split_core_pkg();
  return LinkedSpec::ActionIR::StatementSplit::Core::split_action_ir_statements($code, $trim_action_ir_value)
 })
}

1;
