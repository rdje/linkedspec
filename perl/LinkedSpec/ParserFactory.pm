#------------------------------------------------------------------------------
# Package: LinkedSpec::ParserFactory
# Purpose: Public parser-factory owner that validates spec names, resolves
#          `.spec` files, loads source content, and delegates compilation.
#------------------------------------------------------------------------------
package LinkedSpec::ParserFactory;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::OwnerDispatch ();

#------------------------------------------------------------------------------
# Function: _require_dep
# Purpose : Validate and return one injected dependency callback by name.
# Args    : ($deps, $name)
# Returns : coderef dependency callback
#------------------------------------------------------------------------------
sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ParserFactory::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
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
# Function: _require_pkg_cb
# Purpose : Resolve one named callback from a lazily loaded owner package.
# Args    : ($pkg, $name)
# Returns : coderef for the requested callback
#------------------------------------------------------------------------------
sub _require_pkg_cb {
 my ($pkg, $name) = @_;
 return LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, $pkg, $name)
}

#------------------------------------------------------------------------------
# Function: _require_pkg_value
# Purpose : Resolve one named callback from a lazily loaded owner package and
#           invoke it to obtain a dependency value.
# Args    : ($pkg, $name)
# Returns : callback return value
#------------------------------------------------------------------------------
sub _require_pkg_value {
 my ($pkg, $name) = @_;
 return LinkedSpec::OwnerDispatch::require_pkg_value(__PACKAGE__, $pkg, $name)
}

#------------------------------------------------------------------------------
# Function: _require_value_dep
# Purpose : Validate and return one injected dependency value by name.
# Args    : ($deps, $name)
# Returns : dependency value
#------------------------------------------------------------------------------
sub _require_value_dep {
 my ($deps, $name) = @_;
 die "(LinkedSpec::ParserFactory::_require_value_dep) -E- missing dependency value '$name'"
 unless ref($deps) eq 'HASH' && exists $deps->{$name};
 return $deps->{$name}
}

#------------------------------------------------------------------------------
# Function: _default_deps
# Purpose : Build the default parser-factory dependency map for trace, resolve,
#           load, and compile ownership.
# Args    : ()
# Returns : hashref default dependency map
#------------------------------------------------------------------------------
sub _default_deps {
 return LinkedSpec::OwnerDispatch::build_dep_bundle(__PACKAGE__, undef, [
  { dep => 'apply_trace_options', pkg => 'LinkedSpec::Trace', cb => '_apply_trace_options' },
  { dep => 'trace_enter', pkg => 'LinkedSpec::Trace', cb => 'trace_enter' },
  { dep => 'trace_exit', pkg => 'LinkedSpec::Trace', cb => 'trace_exit' },
  { dep => 'trace_decision', pkg => 'LinkedSpec::Trace', cb => 'trace_decision' },
  { dep => 'validate_spec_name', pkg => 'LinkedSpec::Resolver', cb => 'validate_spec_name' },
  { dep => 'resolve_spec_path', pkg => 'LinkedSpec::Resolver', cb => 'resolve_spec_path' },
  { dep => 'load_spec_content', pkg => 'LinkedSpec::Resolver', cb => 'load_spec_content' },
  { dep => 'compile_spec', pkg => 'LinkedSpec::Runtime', cb => 'run_get' },
  { type => 'value', dep => 'dump_low', pkg => 'LinkedSpec::Trace', cb => 'DUMP_LOW' },
  { type => 'value', dep => 'dump_medium', pkg => 'LinkedSpec::Trace', cb => 'DUMP_MEDIUM' },
 ])
}

#------------------------------------------------------------------------------
# Function: _describe_compile_spec_result
# Purpose : Explain one malformed parser-factory compile result shape for the
#           active public parser-factory mode.
# Args    : ($parser, $option_hashref)
# Returns : string detail describing the invalid result
#------------------------------------------------------------------------------
sub _describe_compile_spec_result {
 my ($parser, $option) = @_;
 my $value_desc = !defined($parser)
  ? 'undef'
  : ref($parser) ? ref($parser) : 'SCALAR';

 if (ref($option) eq 'HASH' && $option->{return_descr}) {
  return "compile_spec returned invalid descriptor value: $value_desc; expected HASH";
 }

 if (ref($option) eq 'HASH' && ($option->{parse_only} || $option->{generate_only})) {
  my $mode = $option->{parse_only} ? 'parse_only' : 'generate_only';
  return "compile_spec returned invalid $mode value: $value_desc; expected undef";
 }

 return 'compile_spec returned undef without structured runtime context'
  unless defined($parser);
 return "compile_spec returned invalid parser value: $value_desc; expected CODE";
}

#------------------------------------------------------------------------------
# Function: _prepare_runtime_ctx_for_get_parser
# Purpose : Prepare the runtime context for `get_parser(...)` orchestration.
# Args    : ($option_hashref, %args)
# Returns : runtime_ctx hashref
#------------------------------------------------------------------------------
sub _prepare_runtime_ctx_for_get_parser {
 my ($option, %args) = @_;
 return _call_runtime_ctx('prepare_runtime_ctx_for_get_parser',
  $option,
  owner => 'LinkedSpec::ParserFactory::run_get_parser',
  %args,
 )
}

#------------------------------------------------------------------------------
# Function: _call_runtime_ctx
# Purpose : Lazy-load and invoke one `RuntimeContext` helper through the shared
#           owner-dispatch seam.
# Args    : ($subname, @args)
# Returns : delegated helper return value
#------------------------------------------------------------------------------
sub _call_runtime_ctx {
 my ($subname, @args) = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(__PACKAGE__, 'LinkedSpec::RuntimeContext', $subname, @args)
}

#------------------------------------------------------------------------------
# Function: _set_runtime_ctx_last_error
# Purpose : Write one structured parser-factory error into the active context.
# Args    : ($runtime_ctx, %args)
# Returns : runtime_ctx hashref
#------------------------------------------------------------------------------
sub _set_runtime_ctx_last_error {
 my ($runtime_ctx, %args) = @_;
 return _call_runtime_ctx('set_runtime_ctx_last_error_for_owner', $runtime_ctx, 'parser_factory', %args)
}

#------------------------------------------------------------------------------
# Function: _set_runtime_ctx_last_error_unless_present
# Purpose : Preserve an existing structured parser-factory error while writing
#           one fallback error payload only when none exists yet.
# Args    : ($runtime_ctx, %args)
# Returns : runtime_ctx hashref
#------------------------------------------------------------------------------
sub _set_runtime_ctx_last_error_unless_present {
 my ($runtime_ctx, %args) = @_;
 return _call_runtime_ctx('set_runtime_ctx_last_error_unless_present_for_owner', $runtime_ctx, 'parser_factory', %args)
}

#------------------------------------------------------------------------------
# Function: _set_runtime_ctx_spec_path
# Purpose : Record the resolved spec path in the active runtime context.
# Args    : ($runtime_ctx, $spec_path)
# Returns : runtime_ctx hashref
#------------------------------------------------------------------------------
sub _set_runtime_ctx_spec_path {
 my ($runtime_ctx, $spec_path) = @_;
 return _call_runtime_ctx('set_runtime_ctx_spec_path', $runtime_ctx, $spec_path)
}

#------------------------------------------------------------------------------
# Function: run_get_parser
# Purpose : Orchestrate public parser-factory flow: trace setup, spec validation,
#           resolution/loading and compilation via injected runtime compile callback.
# Args    : ($spec_name, $option_hashref, $deps_opt)
# Returns : parser coderef or undef
#------------------------------------------------------------------------------
sub run_get_parser {
 my ($spec_name, $option, $deps) = @_;
 return _call_preserving_err(sub {
  my %opt_hash = (ref($option) eq 'HASH') ? %{$option} : ();
  my $runtime_ctx = _prepare_runtime_ctx_for_get_parser(\%opt_hash, spec_name => $spec_name);
  my ($apply_trace_options, $trace_enter, $trace_exit, $trace_decision, $validate_spec_name,
      $resolve_spec_path, $load_spec_content, $compile_spec, $dump_low, $dump_medium, $trace_scope);
  my $setup_ok = eval {
   $deps = _default_deps() unless ref($deps) eq 'HASH';

   $apply_trace_options = _require_dep($deps, 'apply_trace_options');
   $trace_enter = _require_dep($deps, 'trace_enter');
   $trace_exit = _require_dep($deps, 'trace_exit');
   $trace_decision = _require_dep($deps, 'trace_decision');
   $validate_spec_name = _require_dep($deps, 'validate_spec_name');
   $resolve_spec_path = _require_dep($deps, 'resolve_spec_path');
   $load_spec_content = _require_dep($deps, 'load_spec_content');
   $compile_spec = _require_dep($deps, 'compile_spec');
   $dump_low = _require_value_dep($deps, 'dump_low');
   $dump_medium = _require_value_dep($deps, 'dump_medium');

   $apply_trace_options->(\%opt_hash) if %opt_hash;
   $trace_scope = $trace_enter->('LinkedSpec::get_parser', {
    spec_name => $spec_name,
    option_keys => [sort keys %opt_hash],
   }, $dump_low);
   1;
  };
  my $setup_error = $@;
  unless ($setup_ok) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'prepare_parser_factory',
    summary => 'Parser factory setup failed',
    detail => $setup_error,
   );
   return undef;
  }

  my %validate_spec_name_failure;
  my $spec_name_ok = eval {
   $validate_spec_name->(
    $spec_name,
    $trace_scope,
    {
     on_failure => sub {
      %validate_spec_name_failure = @_;
      return 1;
     },
    },
   )
  };
  my $validate_spec_name_error = $@;
  if ($validate_spec_name_error) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'validate_spec_name',
    summary => defined($validate_spec_name_failure{summary}) && length($validate_spec_name_failure{summary})
     ? $validate_spec_name_failure{summary}
     : 'Spec name validation failed',
    detail => defined($validate_spec_name_failure{detail}) && length($validate_spec_name_failure{detail})
     ? $validate_spec_name_failure{detail}
     : $validate_spec_name_error,
   );
   return undef
  }

  unless ($spec_name_ok) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'validate_spec_name',
    summary => defined($validate_spec_name_failure{summary}) && length($validate_spec_name_failure{summary})
     ? $validate_spec_name_failure{summary}
     : 'Invalid spec name',
    detail => defined($validate_spec_name_failure{detail}) && length($validate_spec_name_failure{detail})
     ? $validate_spec_name_failure{detail}
     : 'validate_spec_name rejected the requested parser name',
   );
   return undef
  }

  my %resolve_spec_path_failure;
  my $spec_path = eval {
   $resolve_spec_path->(
    $spec_name,
    $trace_scope,
    {
     on_failure => sub {
      %resolve_spec_path_failure = @_;
      return 1;
     },
    },
   )
  };
  my $resolve_spec_path_error = $@;
  if ($resolve_spec_path_error) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'resolve_spec_path',
    summary => defined($resolve_spec_path_failure{summary}) && length($resolve_spec_path_failure{summary})
     ? $resolve_spec_path_failure{summary}
     : 'Spec resolution failed',
    detail => defined($resolve_spec_path_failure{detail}) && length($resolve_spec_path_failure{detail})
     ? $resolve_spec_path_failure{detail}
     : $resolve_spec_path_error,
   );
   return undef;
  }
  unless (defined $spec_path) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'resolve_spec_path',
    summary => defined($resolve_spec_path_failure{summary}) && length($resolve_spec_path_failure{summary})
     ? $resolve_spec_path_failure{summary}
     : 'Spec resolution failed',
    detail => defined($resolve_spec_path_failure{detail}) && length($resolve_spec_path_failure{detail})
     ? $resolve_spec_path_failure{detail}
     : 'resolve_spec_path returned undef for the requested parser name',
  );
  return undef;
 }
 _set_runtime_ctx_spec_path($runtime_ctx, $spec_path);

  my %load_spec_content_failure;
  my $content = eval {
   $load_spec_content->(
    $spec_path,
    $trace_scope,
    {
     on_failure => sub {
      %load_spec_content_failure = @_;
      return 1;
     },
    },
   )
  };
  my $load_spec_content_error = $@;
  if ($load_spec_content_error) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'load_spec_content',
    summary => defined($load_spec_content_failure{summary}) && length($load_spec_content_failure{summary})
     ? $load_spec_content_failure{summary}
     : 'Spec file load failed',
    detail => defined($load_spec_content_failure{detail}) && length($load_spec_content_failure{detail})
     ? $load_spec_content_failure{detail}
     : $load_spec_content_error,
   );
   return undef;
  }
  unless (defined $content) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'load_spec_content',
    summary => defined($load_spec_content_failure{summary}) && length($load_spec_content_failure{summary})
     ? $load_spec_content_failure{summary}
     : 'Spec file load failed',
    detail => defined($load_spec_content_failure{detail}) && length($load_spec_content_failure{detail})
     ? $load_spec_content_failure{detail}
     : "load_spec_content returned undef for '$spec_path'",
   );
   return undef;
  }
  my %forward_opt_hash = %opt_hash;
  delete $forward_opt_hash{trace_reset_log} if exists $forward_opt_hash{trace_reset_log};
  $forward_opt_hash{_preserve_runtime_ctx_spec_identity} = 1 if defined $runtime_ctx;
  my $parser = eval { $compile_spec->(\$content, \%forward_opt_hash) };
  my $compile_spec_error = $@;
  my $parser_ok =
     $forward_opt_hash{return_descr} ? (defined($parser) && ref($parser) eq 'HASH')
   : ($forward_opt_hash{parse_only} || $forward_opt_hash{generate_only}) ? !defined($parser)
   : defined($parser) && ref($parser) eq 'CODE';
  if ($compile_spec_error) {
   _set_runtime_ctx_last_error_unless_present(
    $runtime_ctx,
    stage => 'compile_spec',
    summary => 'Spec compilation failed',
    detail => $compile_spec_error,
   );
   return undef;
  }
  if (!$parser_ok) {
   _set_runtime_ctx_last_error_unless_present(
    $runtime_ctx,
    stage => 'compile_spec',
    summary => 'Spec compilation failed',
    detail => _describe_compile_spec_result($parser, \%forward_opt_hash),
   );
   $parser = undef;
  }
  $trace_decision->(
   'get_parser_compilation_result',
   $parser_ok ? 1 : 0,
   $parser_ok
    ? ($forward_opt_hash{return_descr}
       ? 'descriptor hash generated'
       : ($forward_opt_hash{parse_only} || $forward_opt_hash{generate_only})
        ? 'mode-only compile path completed'
        : 'parser coderef generated')
    : 'Get() returned invalid compile result',
   $dump_medium
  );
  $trace_exit->(
   $trace_scope,
   {
    status => $parser_ok ? 'ok' : 'error',
    spec_path => $spec_path,
    parser_ref => ref($parser) || '',
   },
   $dump_low
  );
  return $parser;
 })
}

1;
