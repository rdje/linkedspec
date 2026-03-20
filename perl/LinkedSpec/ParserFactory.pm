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

sub _get_runtime_ctx_ref {
 my ($option) = @_;
 return undef unless ref($option) eq 'HASH' && exists $option->{runtime_ctx_ref};
 my $runtime_ctx_ref = $option->{runtime_ctx_ref};
 my $is_scalar_slot = ref($runtime_ctx_ref) eq 'SCALAR';
 my $is_shared_hash_slot = ref($runtime_ctx_ref) eq 'REF' && ref($$runtime_ctx_ref) eq 'HASH';
 die "(LinkedSpec::ParserFactory::run_get_parser) -E- option 'runtime_ctx_ref' must be SCALAR ref"
  unless $is_scalar_slot || $is_shared_hash_slot;
 return $runtime_ctx_ref
}

sub _ensure_runtime_ctx {
 my ($runtime_ctx_ref, %seed) = @_;
 return undef unless ref($runtime_ctx_ref);
 my $runtime_ctx = (ref($$runtime_ctx_ref) eq 'HASH') ? $$runtime_ctx_ref : {};
 foreach my $key (keys %seed) {
  $runtime_ctx->{$key} = $seed{$key};
 }
 $$runtime_ctx_ref = $runtime_ctx if ref($runtime_ctx_ref) eq 'SCALAR';
 return $runtime_ctx
}

sub _set_runtime_ctx_last_error {
 my ($runtime_ctx, %args) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 my $type = defined($args{type}) ? $args{type} : 'parser_factory';
 my $stage = defined($args{stage}) ? $args{stage} : '';
 my $error = {
  type    => $type,
  stage   => $stage,
  owner_stage => length($stage) ? "$type:$stage" : $type,
  summary => defined($args{summary}) ? $args{summary} : '',
  detail  => defined($args{detail}) ? $args{detail} : '',
  spec_name => defined($runtime_ctx->{spec_name}) ? $runtime_ctx->{spec_name} : '',
  spec_path => defined($runtime_ctx->{spec_path}) ? $runtime_ctx->{spec_path} : '',
 };
 $runtime_ctx->{last_error} = $error;
 return $error
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
  my $runtime_ctx_ref = _get_runtime_ctx_ref(\%opt_hash);
  my $runtime_ctx = _ensure_runtime_ctx($runtime_ctx_ref, spec_name => $spec_name);
  $deps = _default_deps() unless ref($deps) eq 'HASH';

  my $apply_trace_options = _require_dep($deps, 'apply_trace_options');
  my $trace_enter = _require_dep($deps, 'trace_enter');
  my $trace_exit = _require_dep($deps, 'trace_exit');
  my $trace_decision = _require_dep($deps, 'trace_decision');
  my $validate_spec_name = _require_dep($deps, 'validate_spec_name');
  my $resolve_spec_path = _require_dep($deps, 'resolve_spec_path');
  my $load_spec_content = _require_dep($deps, 'load_spec_content');
  my $compile_spec = _require_dep($deps, 'compile_spec');
  my $dump_low = _require_value_dep($deps, 'dump_low');
  my $dump_medium = _require_value_dep($deps, 'dump_medium');

  $apply_trace_options->(\%opt_hash) if %opt_hash;
  my $trace_scope = $trace_enter->('LinkedSpec::get_parser', {
   spec_name => $spec_name,
   option_keys => [sort keys %opt_hash],
  }, $dump_low);

  unless ($validate_spec_name->($spec_name, $trace_scope)) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'validate_spec_name',
    summary => 'Invalid spec name',
    detail => 'validate_spec_name rejected the requested parser name',
   );
   return undef
  }

  my $spec_path = $resolve_spec_path->($spec_name, $trace_scope);
  unless (defined $spec_path) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'resolve_spec_path',
    summary => 'Spec resolution failed',
    detail => 'resolve_spec_path returned undef for the requested parser name',
   );
   return undef;
  }
  $runtime_ctx->{spec_path} = $spec_path if ref($runtime_ctx) eq 'HASH';

  my $content = $load_spec_content->($spec_path, $trace_scope);
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
  my $parser = $compile_spec->(\$content, \%forward_opt_hash);
  if (!defined($parser) && ref($runtime_ctx) eq 'HASH' && ref($runtime_ctx->{last_error}) ne 'HASH') {
   _set_runtime_ctx_last_error(
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
