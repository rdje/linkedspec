package LinkedSpec::BootstrapSpec;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

my $CACHED_BOOTSTRAP_STATE;

sub _require_pkg {
 my ($pkg) = @_;
 my $file = $pkg;
 $file =~ s{::}{/}go;
 $file .= '.pm';
 my $ok = eval { require $file; 1 };
 die "(LinkedSpec::BootstrapSpec::_require_pkg) -E- unable to load '$pkg': $@" unless $ok;
 return 1
}

sub _require_bootstrap_core_pkg {
 _require_pkg('LinkedSpec::BootstrapSpec::Core') unless LinkedSpec::BootstrapSpec::Core->can('build_bootstrap_spec');
 return 1
}

#------------------------------------------------------------------------------
# Function: build_bootstrap_spec
# Purpose : Build and return the hardcoded bootstrap grammar descriptor and its
#           compiled dispatch metadata (registry + gdata).
# Args    : none
# Returns : ($spec_descr, $bootstrap_rule_index_ref, $gdata)
#------------------------------------------------------------------------------
sub build_bootstrap_spec {
 _require_bootstrap_core_pkg();
 return LinkedSpec::BootstrapSpec::Core::build_bootstrap_spec(@_)
}

#------------------------------------------------------------------------------
# Function: cached_bootstrap_state
# Purpose : Lazily build and retain the shared hardcoded bootstrap grammar
#           state used by the runtime/parser-generation entrypoints.
# Args    : none
# Returns : hashref { spec_descr, bootstrap_rule_index, gdata }
#------------------------------------------------------------------------------
sub cached_bootstrap_state {
 return $CACHED_BOOTSTRAP_STATE if ref($CACHED_BOOTSTRAP_STATE) eq 'HASH';

 my ($spec_descr, $bootstrap_rule_index_ref, $gdata) = build_bootstrap_spec();
 $CACHED_BOOTSTRAP_STATE = {
  spec_descr => $spec_descr,
  bootstrap_rule_index => { %{$bootstrap_rule_index_ref || {}} },
  gdata => $gdata,
 };
 return $CACHED_BOOTSTRAP_STATE
}

#------------------------------------------------------------------------------
# Function: run_bootstrap_parse
# Purpose : Execute the hardcoded bootstrap parser against `.spec` content using
#           shared cached bootstrap grammar state unless an explicit state hash
#           is injected for tests or compatibility callers.
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
  my $spec_descr = $bootstrap_state->{spec_descr};
  my $bootstrap_rule_index = $bootstrap_state->{bootstrap_rule_index};
  my $gdata = $bootstrap_state->{gdata};
  $retv = &{$$spec_descr[$$bootstrap_rule_index{SPEC_ROOT}]{handler}}($spec_descr, $spec_content_ref, $gdata);
 } or do {
  $parse_success = 0;
  $error = $@;
 };

 return ($parse_success, $retv, $error);
}

1;
