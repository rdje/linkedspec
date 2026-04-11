#------------------------------------------------------------------------------
# Package: LinkedSpec::BootstrapSpec
# Purpose: Hardcoded bootstrap grammar owner that exposes cached bootstrap state
#          and the runtime bootstrap parse entrypoint for `.spec` compilation.
#------------------------------------------------------------------------------
package LinkedSpec::BootstrapSpec;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::OwnerDispatch ();

my $CACHED_BOOTSTRAP_STATE;

#------------------------------------------------------------------------------
# Function: _require_pkg
# Purpose : Lazy-load one owner package through the shared dispatch helper.
# Args    : ($pkg)
# Returns : true on successful require
#------------------------------------------------------------------------------
sub _require_pkg {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg)
}

#------------------------------------------------------------------------------
# Function: _require_bootstrap_core_pkg
# Purpose : Lazy-load the extracted bootstrap-core owner.
# Args    : ()
# Returns : true when `BootstrapSpec::Core` is available
#------------------------------------------------------------------------------
sub _require_bootstrap_core_pkg {
 _require_pkg('LinkedSpec::BootstrapSpec::Core') unless LinkedSpec::BootstrapSpec::Core->can('build_bootstrap_spec');
 return 1
}

#------------------------------------------------------------------------------
# Function: _call_preserving_err
# Purpose : Execute callback without clobbering caller-visible successful `$@`.
# Args    : ($cb)
# Returns : callback return value in caller context
#------------------------------------------------------------------------------
sub _call_preserving_err {
 my ($cb) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err($cb)
}

#------------------------------------------------------------------------------
# Function: build_bootstrap_spec
# Purpose : Build and return the hardcoded bootstrap grammar descriptor and its
#           bootstrap rule index plus parser dispatch state.
# Args    : none
# Returns : ($rule_descriptors, $bootstrap_rule_index_ref, $dispatch_state)
#------------------------------------------------------------------------------
sub build_bootstrap_spec {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_bootstrap_core_pkg();
  return LinkedSpec::BootstrapSpec::Core::build_bootstrap_spec(@args)
 })
}

#------------------------------------------------------------------------------
# Function: cached_bootstrap_state
# Purpose : Lazily build and retain the shared hardcoded bootstrap grammar
#           state used by the runtime/parser-generation entrypoints.
# Args    : none
# Returns : hashref { rule_descriptors, bootstrap_rule_index, dispatch_state }
#------------------------------------------------------------------------------
sub cached_bootstrap_state {
 return $CACHED_BOOTSTRAP_STATE if ref($CACHED_BOOTSTRAP_STATE) eq 'HASH';

 my ($rule_descriptors, $bootstrap_rule_index_ref, $dispatch_state) = build_bootstrap_spec();
 $CACHED_BOOTSTRAP_STATE = {
  rule_descriptors => $rule_descriptors,
  bootstrap_rule_index => { %{$bootstrap_rule_index_ref || {}} },
  dispatch_state => $dispatch_state,
 };
 return $CACHED_BOOTSTRAP_STATE
}

#------------------------------------------------------------------------------
# Function: run_bootstrap_parse
# Purpose : Execute the hardcoded bootstrap parser against `.spec` content using
#           shared cached bootstrap grammar state unless an explicit state hash
#           is injected for tests or controlled internal callers.
# Args    : ($spec_content_ref, $bootstrap_state?)
# Returns : ($parse_success, $retv, $error)
#------------------------------------------------------------------------------
sub run_bootstrap_parse {
 my ($spec_content_ref, $bootstrap_state) = @_;
 $bootstrap_state = cached_bootstrap_state() unless ref($bootstrap_state) eq 'HASH';

 my $retv;
 my $parse_success = 1;
 my $error = '';
 eval {
  my $rule_descriptors = $bootstrap_state->{rule_descriptors};
  my $bootstrap_rule_index = $bootstrap_state->{bootstrap_rule_index};
  my $dispatch_state = $bootstrap_state->{dispatch_state};
  $retv = &{$$rule_descriptors[$$bootstrap_rule_index{SPEC_ROOT}]{handler}}($rule_descriptors, $spec_content_ref, $dispatch_state);
 } or do {
  $parse_success = 0;
  $error = $@;
 };

 return ($parse_success, $retv, $error);
}

1;
