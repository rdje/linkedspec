package LinkedSpec::Runtime;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _require_pkg {
 my ($pkg) = @_;
 my $file = $pkg;
 $file =~ s{::}{/}go;
 $file .= '.pm';
 my $ok = eval { require $file; 1 };
 die "(LinkedSpec::Runtime::_require_pkg) -E- unable to load '$pkg': $@" unless $ok;
 return 1
}

sub _call_preserving_err {
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

sub _build_runtime_context {
 my ($option) = @_;
 _require_runtime_ctx_can('prepare_runtime_ctx_for_run_get_option');
 return LinkedSpec::RuntimeContext::prepare_runtime_ctx_for_run_get_option(
  $option,
  owner => 'LinkedSpec::Runtime::run_get',
 )
}

sub _require_runtime_ctx_can {
 my ($name) = @_;
 _require_pkg('LinkedSpec::RuntimeContext') unless LinkedSpec::RuntimeContext->can($name);
 return 1
}

sub _set_runtime_ctx_last_error {
 my ($runtime_ctx, %args) = @_;
 $args{type} = 'runtime_owner' unless defined $args{type};
 _require_runtime_ctx_can('set_runtime_ctx_last_error');
 return LinkedSpec::RuntimeContext::set_runtime_ctx_last_error($runtime_ctx, %args)
}

sub _set_runtime_ctx_last_error_unless_present {
 my ($runtime_ctx, %args) = @_;
 $args{type} = 'runtime_owner' unless defined $args{type};
 _require_runtime_ctx_can('set_runtime_ctx_last_error_unless_present');
 return LinkedSpec::RuntimeContext::set_runtime_ctx_last_error_unless_present($runtime_ctx, %args)
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
  return $ret
 })
}

1;
