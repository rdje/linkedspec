#------------------------------------------------------------------------------
# Package: LinkedSpec::Runtime
# Purpose: Public `Get(...)` runtime owner that prepares runtime context state
#          and delegates the real compile pipeline into `Compiler.pm`.
#------------------------------------------------------------------------------
package LinkedSpec::Runtime;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::OwnerDispatch ();

#------------------------------------------------------------------------------
# Function: _call_runtime_ctx
# Purpose : Lazy-load and invoke one `RuntimeContext` helper through the local
#           runtime-owner compatibility seam.
# Args    : ($subname, @args)
# Returns : delegated helper return value
#------------------------------------------------------------------------------
sub _call_runtime_ctx {
 my ($subname, @args) = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(__PACKAGE__, 'LinkedSpec::RuntimeContext', $subname, @args)
}

#------------------------------------------------------------------------------
# Function: _describe_run_get_pipeline_result
# Purpose : Explain one malformed compiler result shape for the active runtime
#           owner mode instead of accepting arbitrary defined values as success.
# Args    : ($ret, $option_hashref)
# Returns : string detail describing the invalid result
#------------------------------------------------------------------------------
sub _describe_run_get_pipeline_result {
 my ($ret, $option) = @_;
 my $value_desc = !defined($ret)
  ? 'undef'
  : ref($ret) ? ref($ret) : 'SCALAR';

 return 'run_get_pipeline returned undef without structured runtime context'
  unless defined($ret);

 if (ref($option) eq 'HASH' && $option->{return_descriptor}) {
  return "run_get_pipeline returned invalid descriptor value: $value_desc; expected HASH";
 }

 if (ref($option) eq 'HASH' && ($option->{parse_only} || $option->{generate_only})) {
  my $mode = $option->{parse_only} ? 'parse_only' : 'generate_only';
  return "run_get_pipeline returned invalid $mode value: $value_desc; expected undef";
 }

 return "run_get_pipeline returned invalid parser value: $value_desc; expected CODE";
}

sub _run_get_pipeline_cb {
 return LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, 'LinkedSpec::Compiler', 'run_get_pipeline')
}

#------------------------------------------------------------------------------
# Function: run_get
# Purpose : Own `Get` entrypoint orchestration glue for parser-source capture
#           and compiler pipeline invocation against injected runtime state.
# Args    : ($spec_content_ref, $option_hashref)
# Returns : parser coderef | descriptor hashref | undef
#------------------------------------------------------------------------------
sub run_get {
 my ($spec_content_ref, $option) = @_;
 $option = {} unless ref($option) eq 'HASH';
 my $parse_only = $option->{parse_only} ? 1 : 0;
 my $generate_only = $option->{generate_only} ? 1 : 0;

 my $runtime_ctx = _call_runtime_ctx(
  'prepare_runtime_ctx_for_run_get_option',
  $option,
  owner => 'LinkedSpec::Runtime::run_get',
 );
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  my $ret = eval {
   my $run_get_pipeline = _run_get_pipeline_cb();
   return $run_get_pipeline->(
    $spec_content_ref,
    $option,
    {
     runtime_ctx => $runtime_ctx,
    }
   )
 };
  my $runtime_owner_error = $@;
  if ($runtime_owner_error) {
   _call_runtime_ctx(
    'set_runtime_ctx_last_error_unless_present_for_owner',
    $runtime_ctx,
    'runtime_owner',
    stage => 'run_get_pipeline',
    summary => 'Runtime compile delegation failed',
    detail => $runtime_owner_error,
    handler_source_label => _call_runtime_ctx('build_runtime_ctx_top_rule_handler_source_label', $runtime_ctx),
   );
   return undef;
  }
  my $ret_ok = (ref($option) eq 'HASH' && $option->{return_descriptor})
   ? (defined($ret) && ref($ret) eq 'HASH')
   : ($parse_only || $generate_only)
    ? !defined($ret)
    : (defined($ret) && ref($ret) eq 'CODE');
  unless ($ret_ok) {
   _call_runtime_ctx(
    'set_runtime_ctx_last_error_unless_present_for_owner',
    $runtime_ctx,
    'runtime_owner',
    stage => 'run_get_pipeline',
    summary => 'Runtime compile delegation failed',
    detail => _describe_run_get_pipeline_result($ret, $option),
    handler_source_label => _call_runtime_ctx('build_runtime_ctx_top_rule_handler_source_label', $runtime_ctx),
   );
   return undef;
  }
  return $ret
 })
}

1;
