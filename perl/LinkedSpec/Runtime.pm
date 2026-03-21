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

#------------------------------------------------------------------------------
# Runtime parser state helpers (per-run mutable context only)
#------------------------------------------------------------------------------
sub _emit_parser_source_line {
 my ($runtime_ctx, $chunk) = @_;
 my $emit = (ref($runtime_ctx) eq 'HASH') ? $runtime_ctx->{emit_parser_source_line} : undef;
 return unless ref($emit) eq 'CODE';
 $emit->($chunk);
 return
}

sub _build_runtime_context {
 my ($option) = @_;
 $option = {} unless ref($option) eq 'HASH';

 my @parser_source_chunks;
 my $runtime_ctx_ref = (exists $option->{runtime_ctx_ref}) ? $option->{runtime_ctx_ref} : undef;
 my $ctx = (ref($runtime_ctx_ref) && ref($$runtime_ctx_ref) eq 'HASH')
  ? $$runtime_ctx_ref
  : {};
 $ctx->{top_rule} = undef;
 $ctx->{parser_source_chunks_ref} = \@parser_source_chunks;
 if ($option->{dump_parser_source}) {
  $ctx->{emit_parser_source_line} = sub {
   my ($chunk) = @_;
   push @parser_source_chunks, $chunk;
  };
 } else {
  delete $ctx->{emit_parser_source_line};
 }
 return $ctx
}

sub _capture_runtime_ctx_ref {
 my ($option, $runtime_ctx) = @_;
 return unless ref($option) eq 'HASH' && exists $option->{runtime_ctx_ref};
 my $runtime_ctx_ref = $option->{runtime_ctx_ref};
 my $is_scalar_slot = ref($runtime_ctx_ref) eq 'SCALAR';
 my $is_shared_hash_slot = ref($runtime_ctx_ref) eq 'REF' && ref($$runtime_ctx_ref) eq 'HASH';
 die "(LinkedSpec::Runtime::run_get) -E- option 'runtime_ctx_ref' must be SCALAR ref"
  unless $is_scalar_slot || $is_shared_hash_slot;
 $$runtime_ctx_ref = $runtime_ctx if $is_scalar_slot;
 return
}

sub _set_runtime_ctx_last_error {
 my ($runtime_ctx, %args) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 my $type = defined($args{type}) ? $args{type} : 'runtime_owner';
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
 _capture_runtime_ctx_ref($option, $runtime_ctx);
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
   unless (ref($runtime_ctx->{last_error}) eq 'HASH') {
    _set_runtime_ctx_last_error(
     $runtime_ctx,
     stage => 'run_get_pipeline',
     summary => 'Runtime compile delegation failed',
     detail => $runtime_owner_error,
    );
   }
   return undef;
  }
  return $ret
 })
}

1;
