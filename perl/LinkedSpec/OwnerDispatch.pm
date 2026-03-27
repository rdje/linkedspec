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
# Function: build_dep_map
# Purpose : Build one dependency callback map by resolving a list of callback
#           specs through the shared owner-dispatch seam.
# Args    : ($owner_pkg, $default_target_pkg, $dep_specs)
# Returns : hashref of dependency callbacks
#------------------------------------------------------------------------------
sub build_dep_map {
 my ($owner_pkg, $default_target_pkg, $dep_specs) = @_;
 my $owner = defined($owner_pkg) && length($owner_pkg) ? $owner_pkg : __PACKAGE__;
 my $default_target = defined($default_target_pkg) && length($default_target_pkg)
  ? $default_target_pkg
  : undef;

 return call_preserving_err(sub {
  my $specs = (ref($dep_specs) eq 'ARRAY') ? $dep_specs : [];
  my %deps;

  foreach my $spec (@{$specs}) {
   my ($dep_name, $target_pkg, $cb_name);

   if (!ref($spec)) {
    $dep_name = $spec;
    $target_pkg = $default_target;
   }
   elsif (ref($spec) eq 'HASH') {
    $dep_name = $spec->{dep};
    $target_pkg = defined($spec->{pkg}) ? $spec->{pkg} : $default_target;
    $cb_name = $spec->{cb};
   }
   else {
    die "(${owner}::build_dep_map) -E- malformed dependency spec";
   }

   die "(${owner}::build_dep_map) -E- dependency spec missing dep name"
    unless defined($dep_name) && length($dep_name);
   die "(${owner}::build_dep_map) -E- dependency spec missing target package for '$dep_name'"
    unless defined($target_pkg) && length($target_pkg);

   $cb_name = '_'.$dep_name unless defined($cb_name) && length($cb_name);
   $deps{$dep_name} = require_pkg_cb($owner, $target_pkg, $cb_name);
  }

  return \%deps
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
