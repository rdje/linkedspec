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
# Function: _require_pkg
# Purpose : Lazy-load one owner package through the shared dispatch utility.
# Args    : ($pkg)
# Returns : true on successful require
#------------------------------------------------------------------------------
sub _require_pkg {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg)
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
# Function: _build_runtime_context
# Purpose : Prepare the runtime-owned mutable context used by `run_get(...)`.
# Args    : ($option_hashref)
# Returns : runtime_ctx hashref
#------------------------------------------------------------------------------
sub _build_runtime_context {
 my ($option) = @_;
 return _call_runtime_ctx('prepare_runtime_ctx_for_run_get_option',
  $option,
  owner => 'LinkedSpec::Runtime::run_get',
 )
}

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
# Function: _set_runtime_ctx_last_error
# Purpose : Write one structured runtime-owner error into the active context.
# Args    : ($runtime_ctx, %args)
# Returns : runtime_ctx hashref
#------------------------------------------------------------------------------
sub _set_runtime_ctx_last_error {
 my ($runtime_ctx, %args) = @_;
 return _call_runtime_ctx('set_runtime_ctx_last_error_for_owner', $runtime_ctx, 'runtime_owner', %args)
}

#------------------------------------------------------------------------------
# Function: _set_runtime_ctx_last_error_unless_present
# Purpose : Preserve an existing structured runtime-owner error while providing
#           a fallback error payload when none has been recorded yet.
# Args    : ($runtime_ctx, %args)
# Returns : runtime_ctx hashref
#------------------------------------------------------------------------------
sub _set_runtime_ctx_last_error_unless_present {
 my ($runtime_ctx, %args) = @_;
 return _call_runtime_ctx('set_runtime_ctx_last_error_unless_present_for_owner', $runtime_ctx, 'runtime_owner', %args)
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

 if (ref($option) eq 'HASH' && $option->{return_descr}) {
  return "run_get_pipeline returned invalid descriptor value: $value_desc; expected HASH";
 }

 if (ref($option) eq 'HASH' && ($option->{parse_only} || $option->{generate_only})) {
  my $mode = $option->{parse_only} ? 'parse_only' : 'generate_only';
  return "run_get_pipeline returned invalid $mode value: $value_desc; expected undef";
 }

 return "run_get_pipeline returned invalid parser value: $value_desc; expected CODE";
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

 my $runtime_ctx = _build_runtime_context($option);
 return _call_preserving_err(sub {
  my $ret = eval {
   _require_pkg('LinkedSpec::Compiler') unless LinkedSpec::Compiler->can('run_get_pipeline');
   return LinkedSpec::Compiler::run_get_pipeline(
    $spec_content_ref,
    $option,
    {
     runtime_ctx => $runtime_ctx,
    }
   )
 };
  my $runtime_owner_error = $@;
  if ($runtime_owner_error) {
   _set_runtime_ctx_last_error_unless_present(
    $runtime_ctx,
    stage => 'run_get_pipeline',
    summary => 'Runtime compile delegation failed',
    detail => $runtime_owner_error,
   );
   return undef;
  }
  my $ret_ok = (ref($option) eq 'HASH' && $option->{return_descr})
   ? (defined($ret) && ref($ret) eq 'HASH')
   : ($parse_only || $generate_only)
    ? !defined($ret)
    : (defined($ret) && ref($ret) eq 'CODE');
  unless ($ret_ok) {
   _set_runtime_ctx_last_error_unless_present(
    $runtime_ctx,
    stage => 'run_get_pipeline',
    summary => 'Runtime compile delegation failed',
    detail => _describe_run_get_pipeline_result($ret, $option),
   );
   return undef;
  }
  return $ret
 })
}

1;
