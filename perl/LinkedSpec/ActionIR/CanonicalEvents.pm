#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::CanonicalEvents
# Purpose: Canonical ActionIR event owner for helper-hit normalization and
#          fallback event assembly.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::CanonicalEvents;

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
# Purpose : Lazy-load one canonical-events dependency owner through the shared
#           owner-dispatch seam.
# Args    : ($pkg)
# Returns : requested package name
#------------------------------------------------------------------------------
sub _require_pkg {
 my ($pkg) = @_;
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg);
 return $pkg
}

#------------------------------------------------------------------------------
# Function: _require_canonical_events_core_pkg
# Purpose : Lazy-load the canonical-events core owner.
# Args    : none
# Returns : requested package name
#------------------------------------------------------------------------------
sub _require_canonical_events_core_pkg {
 return _require_pkg('LinkedSpec::ActionIR::CanonicalEvents::Core')
}

#------------------------------------------------------------------------------
# Function: _call_preserving_err
# Purpose : Preserve caller-visible successful `$@` while executing one
#           canonical-events helper callback.
# Args    : ($cb)
# Returns : callback return value in caller context
#------------------------------------------------------------------------------
sub _call_preserving_err {
 my ($cb) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err($cb)
}

#------------------------------------------------------------------------------
# Function: _require_pkg_cb
# Purpose : Lazy-load one canonical-events dependency owner and resolve one
#           callback from it through the shared owner-dispatch seam.
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
 die "(LinkedSpec::ActionIR::CanonicalEvents::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

sub default_deps_for_package {
 my ($pkg) = @_;
 return _call_preserving_err(sub {
  return {
   trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
   split_action_ir_statements => _require_pkg_cb($pkg, '_split_action_ir_statements'),
  }
 })
}

sub _canonicalize_helper_action_ir_event {
 my ($label, $event, $deps) = @_;
 return _call_preserving_err(sub {
  _require_canonical_events_core_pkg();
  return LinkedSpec::ActionIR::CanonicalEvents::Core::canonicalize_helper_action_ir_event($label, $event)
 })
}

sub _build_canonical_action_ir_events {
 my ($label, $code, $helper_events, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $split_action_ir_statements = _require_dep($deps, 'split_action_ir_statements');

 my %helper_event_queue;
 foreach my $helper_event (@$helper_events) {
  my $raw_key = $trim_action_ir_value->($helper_event->{raw});
  next unless defined($raw_key) && length($raw_key);
  my $canonical_event = _canonicalize_helper_action_ir_event($label, $helper_event, $deps);
  push @{$helper_event_queue{$raw_key}}, $canonical_event;
 }

 my @canonical_events;
 my $fallback_count = 0;
 foreach my $statement (@{$split_action_ir_statements->($code)}) {
  if (exists $helper_event_queue{$statement} && @{$helper_event_queue{$statement}}) {
   push @canonical_events, shift @{$helper_event_queue{$statement}};
  } else {
   push @canonical_events, {
    kind        => 'RAW_PERL',
    source      => 'fallback_non_helper_statement',
    contract_id => undef,
    raw         => $statement,
    args        => {code => $statement},
   };
   ++$fallback_count;
  }
 }

 foreach my $raw_key (keys %helper_event_queue) {
  while (@{$helper_event_queue{$raw_key}}) {
   my $event = shift @{$helper_event_queue{$raw_key}};
   $event->{source} = 'unmatched_helper_scan_event';
   push @canonical_events, $event;
  }
 }

 my %hits;
 my $count = 0;
 foreach my $event (@canonical_events) {
  my $kind = $event->{kind} // 'UNKNOWN';
  $hits{$kind} += 1;
  ++$count;
 }

 return {
  canonical_action_ir_count => $count,
  canonical_action_ir_hits  => \%hits,
  canonical_action_ir_nodes => [sort keys %hits],
  canonical_action_ir_events => \@canonical_events,
  canonical_action_ir_fallback_count => $fallback_count,
 }
}

1;
