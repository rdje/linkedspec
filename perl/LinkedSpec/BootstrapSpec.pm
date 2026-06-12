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

# spec.spec parser cache — lazily built once via the bootstrap parser.
# (MEDIUM-IMPACT.3.5: dual-path — bootstrap primary, spec.spec secondary)
my $SPEC_SPEC_PARSER;
our $SPEC_SPEC_BUILDING = 0;   # guard against recursive bootstrap (must be package var for local())

#------------------------------------------------------------------------------
# _build_spec_spec_parser — build and cache the spec.spec-generated parser.
# Uses the hardcoded bootstrap to compile spec.spec, then caches the result.
# Returns CODE ref on success, undef otherwise.
#------------------------------------------------------------------------------
sub _build_spec_spec_parser {
    return $SPEC_SPEC_PARSER if defined($SPEC_SPEC_PARSER);
    return undef if $SPEC_SPEC_BUILDING;

    local $SPEC_SPEC_BUILDING = 1;

    # Resolve spec.spec path relative to perl module root (perl/../specs/spec.spec)
    my $module_dir = (File::Basename::fileparse(__FILE__))[1];
    my $perl_root = File::Basename::dirname($module_dir);
    my $repo_root = File::Basename::dirname($perl_root);
    my $spec_spec_path = "$repo_root/specs/spec.spec";
    return undef unless -f $spec_spec_path && -r $spec_spec_path;

    my $content;
    {
        local $/;
        open(my $fh, '<', $spec_spec_path) or return undef;
        $content = <$fh>;
        close($fh);
    }
    return undef unless defined($content) && length($content);

    # Compile spec.spec — this uses the hardcoded bootstrap internally
    my $parser = eval { LinkedSpec::Get(\$content) };
    return undef if $@ || !$parser || ref($parser) ne 'CODE';

    $SPEC_SPEC_PARSER = $parser;
    return $parser;
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
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  my $build_bootstrap_spec_cb = LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, 'LinkedSpec::BootstrapSpec::Core', 'build_bootstrap_spec');
  return $build_bootstrap_spec_cb->(@args)
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

 # Run spec.spec-generated parser for diagnostic comparison (MEDIUM-IMPACT.3.5).
 # Result stored in $bootstrap_state for access via descriptor metadata.
 # Format differs from bootstrap, so bootstrap always runs as primary.
 my $ss_parser = _build_spec_spec_parser();
 if (defined($ss_parser) && !$SPEC_SPEC_BUILDING) {
  pos($$spec_content_ref) = 0 if ref($spec_content_ref) eq 'SCALAR';
  my $result = eval { $ss_parser->($spec_content_ref) };
  if (!$@ && defined($result) && ref($result) eq 'ARRAY' && @$result) {
   $bootstrap_state->{spec_spec_result} = $result;
  }
  # Reset position for the bootstrap parser (primary path)
  pos($$spec_content_ref) = 0 if ref($spec_content_ref) eq 'SCALAR';
 }

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
