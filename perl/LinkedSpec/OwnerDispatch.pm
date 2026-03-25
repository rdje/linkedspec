#------------------------------------------------------------------------------
# Package: LinkedSpec::OwnerDispatch
# Purpose: Shared internal helper for lazy owner-package loading, delegated
#          owner calls, and `$@` preservation across thin compatibility wrappers.
#------------------------------------------------------------------------------
package LinkedSpec::OwnerDispatch;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

#------------------------------------------------------------------------------
# Function: call_preserving_err
# Purpose : Execute a callback without clobbering caller-visible successful `$@`.
# Args    : ($cb)
# Returns : callback return value in caller context
#------------------------------------------------------------------------------
sub call_preserving_err {
 my ($cb) = @_;
 my $saved_err = $@;
 my $wantarray = wantarray;
 if ($wantarray) {
  my @ret = $cb->();
  $@ = $saved_err;
  return @ret
 }
 if (defined $wantarray) {
  my $ret = $cb->();
  $@ = $saved_err;
  return $ret
 }
 $cb->();
 $@ = $saved_err;
 return
}

#------------------------------------------------------------------------------
# Function: require_pkg
# Purpose : Lazy-load one owner package while keeping the caller package name in
#           the emitted load-failure diagnostic.
# Args    : ($owner_pkg, $target_pkg)
# Returns : true on successful require
#------------------------------------------------------------------------------
sub require_pkg {
 my ($owner_pkg, $target_pkg) = @_;
 my $owner = defined($owner_pkg) && length($owner_pkg) ? $owner_pkg : __PACKAGE__;
 return call_preserving_err(sub {
  my $file = $target_pkg;
  $file =~ s{::}{/}go;
  $file .= '.pm';
  my $ok = eval { require $file; 1 };
  die "(${owner}::_require_pkg) -E- unable to load '$target_pkg': $@" unless $ok;
  return 1
 })
}

#------------------------------------------------------------------------------
# Function: require_pkg_cb
# Purpose : Lazy-load one owner package and return one named callback from it.
# Args    : ($owner_pkg, $target_pkg, $subname)
# Returns : coderef for the requested owner callback
#------------------------------------------------------------------------------
sub require_pkg_cb {
 my ($owner_pkg, $target_pkg, $subname) = @_;
 my $owner = defined($owner_pkg) && length($owner_pkg) ? $owner_pkg : __PACKAGE__;
 return call_preserving_err(sub {
  require_pkg($owner, $target_pkg) unless $target_pkg->can($subname);
  my $code = $target_pkg->can($subname);
  die "(${owner}::_require_pkg_cb) -E- missing callback '$target_pkg\::$subname'"
   unless ref($code) eq 'CODE';
  return $code
 })
}

#------------------------------------------------------------------------------
# Function: require_pkg_value
# Purpose : Lazy-load one owner package, resolve one named callback from it,
#           and invoke that callback to obtain a value.
# Args    : ($owner_pkg, $target_pkg, $subname)
# Returns : callback return value
#------------------------------------------------------------------------------
sub require_pkg_value {
 my ($owner_pkg, $target_pkg, $subname) = @_;
 my $owner = defined($owner_pkg) && length($owner_pkg) ? $owner_pkg : __PACKAGE__;
 return call_preserving_err(sub {
  my $cb = require_pkg_cb($owner, $target_pkg, $subname);
  return $cb->()
 })
}

#------------------------------------------------------------------------------
# Function: dispatch_owner_call
# Purpose : Shared thin-wrapper delegator that lazy-loads one owner package and
#           invokes a named routine through it.
# Args    : ($owner_pkg, $target_pkg, $subname, @args)
# Returns : delegated owner return value
#------------------------------------------------------------------------------
sub dispatch_owner_call {
 my ($owner_pkg, $target_pkg, $subname, @args) = @_;
 return call_preserving_err(sub {
  require_pkg($owner_pkg, $target_pkg) unless $target_pkg->can($subname);
  no strict 'refs';
  return &{"${target_pkg}::${subname}"}(@args);
 })
}

1;
