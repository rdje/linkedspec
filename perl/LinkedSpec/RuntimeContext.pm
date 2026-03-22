package LinkedSpec::RuntimeContext;

use 5.010;

sub normalize_runtime_ctx_ref {
 my ($runtime_ctx_ref, %args) = @_;
 return undef unless defined $runtime_ctx_ref;
 my $owner = defined($args{owner}) ? $args{owner} : 'LinkedSpec::RuntimeContext';
 my $is_direct_hashref = ref($runtime_ctx_ref) eq 'HASH';
 my $is_scalar_slot = ref($runtime_ctx_ref) eq 'SCALAR';
 my $is_shared_hash_slot = ref($runtime_ctx_ref) eq 'REF' && ref($$runtime_ctx_ref) eq 'HASH';
 die "($owner) -E- option 'runtime_ctx_ref' must be SCALAR ref or HASH ref"
  unless $is_direct_hashref || $is_scalar_slot || $is_shared_hash_slot;
 return $runtime_ctx_ref
}

sub ensure_runtime_ctx {
 my ($runtime_ctx_ref, %seed) = @_;
 return undef unless ref($runtime_ctx_ref);
 my $runtime_ctx = (ref($runtime_ctx_ref) eq 'HASH')
  ? $runtime_ctx_ref
  : (ref($runtime_ctx_ref) eq 'SCALAR' && ref($$runtime_ctx_ref) eq 'HASH')
   ? $$runtime_ctx_ref
   : (ref($runtime_ctx_ref) eq 'REF' && ref($$runtime_ctx_ref) eq 'HASH')
    ? $$runtime_ctx_ref
    : {};
 foreach my $key (keys %seed) {
  $runtime_ctx->{$key} = $seed{$key};
 }
 $$runtime_ctx_ref = $runtime_ctx if ref($runtime_ctx_ref) eq 'SCALAR';
 return $runtime_ctx
}

sub prepare_runtime_ctx_for_run_get {
 my ($runtime_ctx_ref, %args) = @_;
 my $runtime_ctx = ensure_runtime_ctx($runtime_ctx_ref);
 $runtime_ctx = {} unless ref($runtime_ctx) eq 'HASH';
 clear_runtime_ctx_top_rule($runtime_ctx);
 unless ($args{preserve_spec_identity}) {
  clear_runtime_ctx_spec_name($runtime_ctx);
  clear_runtime_ctx_spec_path($runtime_ctx);
 }
 clear_runtime_ctx_parser_source_chunks_ref($runtime_ctx);
 configure_runtime_ctx_parser_source_capture(
  $runtime_ctx,
  enabled => $args{dump_parser_source} ? 1 : 0,
 );
 return $runtime_ctx
}

sub prepare_runtime_ctx_for_run_get_option {
 my ($option, %args) = @_;
 $option = {} unless ref($option) eq 'HASH';
 my $runtime_ctx_ref = exists($option->{runtime_ctx_ref})
  ? normalize_runtime_ctx_ref(
     $option->{runtime_ctx_ref},
     owner => defined($args{owner}) ? $args{owner} : 'LinkedSpec::RuntimeContext::prepare_runtime_ctx_for_run_get_option',
    )
  : undef;
 return prepare_runtime_ctx_for_run_get(
  $runtime_ctx_ref,
  dump_parser_source => $option->{dump_parser_source} ? 1 : 0,
  preserve_spec_identity => $option->{_preserve_runtime_ctx_spec_identity} ? 1 : 0,
 )
}

sub prepare_runtime_ctx_for_get_parser {
 my ($option, %args) = @_;
 my $runtime_ctx_ref = (ref($option) eq 'HASH' && exists($option->{runtime_ctx_ref}))
  ? normalize_runtime_ctx_ref(
     $option->{runtime_ctx_ref},
     owner => defined($args{owner}) ? $args{owner} : 'LinkedSpec::RuntimeContext::prepare_runtime_ctx_for_get_parser',
    )
  : undef;
 my $runtime_ctx = ensure_runtime_ctx($runtime_ctx_ref);
 return undef unless ref($runtime_ctx) eq 'HASH';
 clear_runtime_ctx_top_rule($runtime_ctx);
 clear_runtime_ctx_spec_path($runtime_ctx);
 clear_runtime_ctx_spec_name($runtime_ctx);
 set_runtime_ctx_spec_name($runtime_ctx, $args{spec_name}) if defined $args{spec_name};
 return $runtime_ctx
}

sub prepare_runtime_ctx_for_run_get_pipeline {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 clear_runtime_ctx_parser_source_chunks_ref($runtime_ctx);
 return $runtime_ctx
}

sub ensure_runtime_ctx_parser_source_chunks_ref {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 if (ref($runtime_ctx->{parser_source_chunks_ref}) ne 'ARRAY') {
  my @parser_source_chunks;
  $runtime_ctx->{parser_source_chunks_ref} = \@parser_source_chunks;
 }
 return $runtime_ctx->{parser_source_chunks_ref}
}

sub get_runtime_ctx_parser_source_chunks_ref {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 return $runtime_ctx->{parser_source_chunks_ref}
}

sub clear_runtime_ctx_parser_source_chunks_ref {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 my $parser_source_chunks_ref = ensure_runtime_ctx_parser_source_chunks_ref($runtime_ctx);
 @$parser_source_chunks_ref = ();
 return $parser_source_chunks_ref
}

sub configure_runtime_ctx_parser_source_capture {
 my ($runtime_ctx, %args) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 my $parser_source_chunks_ref = ensure_runtime_ctx_parser_source_chunks_ref($runtime_ctx);
 if ($args{enabled}) {
  $runtime_ctx->{emit_parser_source_line} = sub {
   my ($chunk) = @_;
   push @$parser_source_chunks_ref, $chunk;
  };
 } else {
  delete $runtime_ctx->{emit_parser_source_line};
 }
 return $parser_source_chunks_ref
}

sub emit_runtime_ctx_parser_source_line {
 my ($runtime_ctx, $chunk) = @_;
 my $emit = (ref($runtime_ctx) eq 'HASH') ? $runtime_ctx->{emit_parser_source_line} : undef;
 return unless ref($emit) eq 'CODE';
 $emit->($chunk);
 return
}

sub flush_runtime_ctx_parser_source {
 my ($runtime_ctx, $parser_source_ref) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 my $parser_source_chunks_ref = get_runtime_ctx_parser_source_chunks_ref($runtime_ctx);
 my $parser_source = (ref($parser_source_chunks_ref) eq 'ARRAY') ? join('', @$parser_source_chunks_ref) : '';
 if (ref($parser_source_ref) eq 'SCALAR') {
  $$parser_source_ref = $parser_source;
 } else {
  print $parser_source;
 }
 return $parser_source
}

sub clear_runtime_ctx_top_rule {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 $runtime_ctx->{top_rule} = undef;
 return $runtime_ctx->{top_rule}
}

sub clear_runtime_ctx_spec_name {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 $runtime_ctx->{spec_name} = undef;
 return $runtime_ctx->{spec_name}
}

sub get_runtime_ctx_spec_name {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 return $runtime_ctx->{spec_name}
}

sub set_runtime_ctx_spec_name {
 my ($runtime_ctx, $spec_name) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 $runtime_ctx->{spec_name} = $spec_name if defined $spec_name;
 return $runtime_ctx->{spec_name}
}

sub get_runtime_ctx_top_rule {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 return $runtime_ctx->{top_rule}
}

sub set_runtime_ctx_top_rule {
 my ($runtime_ctx, $top_rule) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 $runtime_ctx->{top_rule} = $top_rule if defined $top_rule;
 return $runtime_ctx->{top_rule}
}

sub clear_runtime_ctx_spec_path {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 $runtime_ctx->{spec_path} = undef;
 return $runtime_ctx->{spec_path}
}

sub get_runtime_ctx_spec_path {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 return $runtime_ctx->{spec_path}
}

sub set_runtime_ctx_spec_path {
 my ($runtime_ctx, $spec_path) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 $runtime_ctx->{spec_path} = $spec_path if defined $spec_path;
 return $runtime_ctx->{spec_path}
}

sub clear_runtime_ctx_last_error {
 my ($runtime_ctx) = @_;
 return unless ref($runtime_ctx) eq 'HASH';
 delete $runtime_ctx->{last_error};
 return
}

sub get_runtime_ctx_last_error {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 return $runtime_ctx->{last_error}
}

sub has_structured_runtime_ctx_last_error {
 my ($runtime_ctx) = @_;
 my $last_error = get_runtime_ctx_last_error($runtime_ctx);
 return ref($last_error) eq 'HASH' ? 1 : 0
}

sub has_runtime_ctx_last_error_type {
 my ($runtime_ctx, $type) = @_;
 return 0 unless defined $type && length $type;
 my $last_error = get_runtime_ctx_last_error($runtime_ctx);
 return 0 unless ref($last_error) eq 'HASH';
 return (($last_error->{type} // '') eq $type) ? 1 : 0
}

sub get_runtime_ctx_last_error_detail {
 my ($runtime_ctx) = @_;
 my $last_error = get_runtime_ctx_last_error($runtime_ctx);
 return '' unless ref($last_error) eq 'HASH';
 return defined($last_error->{detail}) ? $last_error->{detail} : ''
}

sub set_runtime_ctx_last_error {
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
  spec_name => defined(get_runtime_ctx_spec_name($runtime_ctx)) ? get_runtime_ctx_spec_name($runtime_ctx) : '',
  spec_path => defined(get_runtime_ctx_spec_path($runtime_ctx)) ? get_runtime_ctx_spec_path($runtime_ctx) : '',
 };
 $error->{rule_label} = $args{rule_label} if defined $args{rule_label};
 $error->{handler_variant} = $args{handler_variant} if defined $args{handler_variant};
 $runtime_ctx->{last_error} = $error;
 return $error
}

sub set_runtime_ctx_last_error_unless_present {
 my ($runtime_ctx, %args) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 return $runtime_ctx->{last_error} if has_structured_runtime_ctx_last_error($runtime_ctx);
 return set_runtime_ctx_last_error($runtime_ctx, %args)
}

1;
