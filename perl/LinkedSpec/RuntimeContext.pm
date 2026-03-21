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

sub ensure_runtime_ctx_parser_source_chunks_ref {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 if (ref($runtime_ctx->{parser_source_chunks_ref}) ne 'ARRAY') {
  my @parser_source_chunks;
  $runtime_ctx->{parser_source_chunks_ref} = \@parser_source_chunks;
 }
 return $runtime_ctx->{parser_source_chunks_ref}
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

sub clear_runtime_ctx_last_error {
 my ($runtime_ctx) = @_;
 return unless ref($runtime_ctx) eq 'HASH';
 delete $runtime_ctx->{last_error};
 return
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
  spec_name => defined($runtime_ctx->{spec_name}) ? $runtime_ctx->{spec_name} : '',
  spec_path => defined($runtime_ctx->{spec_path}) ? $runtime_ctx->{spec_path} : '',
 };
 $error->{rule_label} = $args{rule_label} if defined $args{rule_label};
 $error->{handler_variant} = $args{handler_variant} if defined $args{handler_variant};
 $runtime_ctx->{last_error} = $error;
 return $error
}

1;
