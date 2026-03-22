package LinkedSpec::ParserFactory;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ParserFactory::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
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

sub _require_pkg {
 my ($pkg) = @_;
 return _call_preserving_err(sub {
  my $file = $pkg;
  $file =~ s{::}{/}go;
  $file .= '.pm';
  my $ok = eval { require $file; 1 };
  die "(LinkedSpec::ParserFactory::_require_pkg) -E- unable to load '$pkg': $@" unless $ok;
  return 1
 })
}

sub _require_pkg_cb {
 my ($pkg, $name) = @_;
 return _call_preserving_err(sub {
  _require_pkg($pkg) unless $pkg->can($name);
  my $code = $pkg->can($name);
  die "(LinkedSpec::ParserFactory::_require_pkg_cb) -E- missing callback '$pkg\::$name'"
   unless ref($code) eq 'CODE';
  return $code
 })
}

sub _require_pkg_value {
 my ($pkg, $name) = @_;
 return _call_preserving_err(sub {
  my $cb = _require_pkg_cb($pkg, $name);
  return $cb->()
 })
}

sub _require_value_dep {
 my ($deps, $name) = @_;
 die "(LinkedSpec::ParserFactory::_require_value_dep) -E- missing dependency value '$name'"
 unless ref($deps) eq 'HASH' && exists $deps->{$name};
 return $deps->{$name}
}

sub _default_deps {
 return {
  apply_trace_options => _require_pkg_cb('LinkedSpec::Trace', '_apply_trace_options'),
  trace_enter => _require_pkg_cb('LinkedSpec::Trace', 'trace_enter'),
  trace_exit => _require_pkg_cb('LinkedSpec::Trace', 'trace_exit'),
  trace_decision => _require_pkg_cb('LinkedSpec::Trace', 'trace_decision'),
  validate_spec_name => _require_pkg_cb('LinkedSpec::Resolver', 'validate_spec_name'),
  resolve_spec_path => _require_pkg_cb('LinkedSpec::Resolver', 'resolve_spec_path'),
  load_spec_content => _require_pkg_cb('LinkedSpec::Resolver', 'load_spec_content'),
  compile_spec => _require_pkg_cb('LinkedSpec::Runtime', 'run_get'),
  dump_low => _require_pkg_value('LinkedSpec::Trace', 'DUMP_LOW'),
  dump_medium => _require_pkg_value('LinkedSpec::Trace', 'DUMP_MEDIUM'),
 }
}

sub _prepare_runtime_ctx_for_get_parser {
 my ($option, %args) = @_;
 return _call_runtime_ctx('prepare_runtime_ctx_for_get_parser',
  $option,
  owner => 'LinkedSpec::ParserFactory::run_get_parser',
  %args,
 )
}

sub _call_runtime_ctx {
 my ($subname, @args) = @_;
 return _call_preserving_err(sub {
  _require_pkg('LinkedSpec::RuntimeContext') unless LinkedSpec::RuntimeContext->can($subname);
  no strict 'refs';
  return &{"LinkedSpec::RuntimeContext::${subname}"}(@args);
 })
}

sub _set_runtime_ctx_last_error {
 my ($runtime_ctx, %args) = @_;
 return _call_runtime_ctx('set_runtime_ctx_last_error_for_owner', $runtime_ctx, 'parser_factory', %args)
}

sub _set_runtime_ctx_last_error_unless_present {
 my ($runtime_ctx, %args) = @_;
 return _call_runtime_ctx('set_runtime_ctx_last_error_unless_present_for_owner', $runtime_ctx, 'parser_factory', %args)
}

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

  my $spec_name_ok = eval { $validate_spec_name->($spec_name, $trace_scope) };
  my $validate_spec_name_error = $@;
  if ($validate_spec_name_error) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'validate_spec_name',
    summary => 'Spec name validation failed',
    detail => $validate_spec_name_error,
   );
   return undef
  }

  unless ($spec_name_ok) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'validate_spec_name',
    summary => 'Invalid spec name',
    detail => 'validate_spec_name rejected the requested parser name',
   );
   return undef
  }

  my $spec_path = eval { $resolve_spec_path->($spec_name, $trace_scope) };
  my $resolve_spec_path_error = $@;
  if ($resolve_spec_path_error) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'resolve_spec_path',
    summary => 'Spec resolution failed',
    detail => $resolve_spec_path_error,
   );
   return undef;
  }
  unless (defined $spec_path) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'resolve_spec_path',
    summary => 'Spec resolution failed',
    detail => 'resolve_spec_path returned undef for the requested parser name',
  );
  return undef;
 }
 _set_runtime_ctx_spec_path($runtime_ctx, $spec_path);

  my $content = eval { $load_spec_content->($spec_path, $trace_scope) };
  my $load_spec_content_error = $@;
  if ($load_spec_content_error) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'load_spec_content',
    summary => 'Spec file load failed',
    detail => $load_spec_content_error,
   );
   return undef;
  }
  unless (defined $content) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'load_spec_content',
    summary => 'Spec file load failed',
    detail => "load_spec_content returned undef for '$spec_path'",
   );
   return undef;
  }
  my %forward_opt_hash = %opt_hash;
  delete $forward_opt_hash{trace_reset_log} if exists $forward_opt_hash{trace_reset_log};
  $forward_opt_hash{_preserve_runtime_ctx_spec_identity} = 1 if defined $runtime_ctx;
  my $parser = eval { $compile_spec->(\$content, \%forward_opt_hash) };
  my $compile_spec_error = $@;
  if ($compile_spec_error) {
   _set_runtime_ctx_last_error_unless_present(
    $runtime_ctx,
    stage => 'compile_spec',
    summary => 'Spec compilation failed',
    detail => $compile_spec_error,
   );
   return undef;
  }
  if (!defined($parser)) {
   _set_runtime_ctx_last_error_unless_present(
    $runtime_ctx,
    stage => 'compile_spec',
    summary => 'Spec compilation failed',
    detail => 'compile_spec returned undef without structured runtime context',
   );
  }
  $trace_decision->('get_parser_compilation_result', defined($parser) ? 1 : 0, defined($parser) ? 'parser coderef generated' : 'Get() returned undef', $dump_medium);
  $trace_exit->(
   $trace_scope,
   {
    status => defined($parser) ? 'ok' : 'error',
    spec_path => $spec_path,
    parser_ref => ref($parser) || '',
   },
   $dump_low
  );
  return $parser;
 })
}

1;
