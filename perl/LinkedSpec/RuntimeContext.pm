 #------------------------------------------------------------------------------
 # Package: LinkedSpec::RuntimeContext
 # Purpose: Own shared runtime context state, structured last_error payloads,
 #          and parser-source capture helpers across the compile/runtime path.
 #------------------------------------------------------------------------------
package LinkedSpec::RuntimeContext;

use 5.010;

sub normalize_runtime_ctx_ref {
 my ($runtime_ctx_ref, %args) = @_;
 return undef unless defined $runtime_ctx_ref;
 my $owner = defined($args{owner}) ? $args{owner} : 'LinkedSpec::RuntimeContext';
 my $is_direct_hashref = ref($runtime_ctx_ref) eq 'HASH';
 my $is_plain_scalar_slot = ref($runtime_ctx_ref) eq 'SCALAR';
 my $is_populated_scalar_slot = ref($runtime_ctx_ref) eq 'REF' && ref($$runtime_ctx_ref) eq 'HASH';
 die "($owner) -E- option 'runtime_ctx_ref' must be a runtime context hashref or scalar slot"
  unless $is_direct_hashref || $is_plain_scalar_slot || $is_populated_scalar_slot;
 return $runtime_ctx_ref
}

sub ensure_runtime_ctx {
 my ($runtime_ctx_ref, %seed) = @_;
 return undef unless ref($runtime_ctx_ref);
 # A scalar slot passed as \$ctx reports SCALAR before LinkedSpec stores a
 # hashref there, then REF once $ctx already contains that hashref.
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
 clear_runtime_ctx_last_error($runtime_ctx);
 clear_runtime_ctx_top_rule($runtime_ctx);
 set_runtime_ctx_top_rule($runtime_ctx, $args{top_rule})
  if defined($args{top_rule}) && length($args{top_rule});
 unless ($args{preserve_spec_identity}) {
  clear_runtime_ctx_spec_identity($runtime_ctx);
 }
 clear_runtime_ctx_parser_source_capture($runtime_ctx, ensure_storage => 1);
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
  top_rule => $option->{top_rule},
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
 clear_runtime_ctx_last_error($runtime_ctx);
 clear_runtime_ctx_top_rule($runtime_ctx);
 clear_runtime_ctx_spec_identity($runtime_ctx);
 clear_runtime_ctx_parser_source_capture($runtime_ctx);
 set_runtime_ctx_spec_name($runtime_ctx, $args{spec_name}) if defined $args{spec_name};
 set_runtime_ctx_top_rule($runtime_ctx, $option->{top_rule})
  if ref($option) eq 'HASH' && defined($option->{top_rule}) && length($option->{top_rule});
 return $runtime_ctx
}

sub prepare_runtime_ctx_for_run_get_pipeline {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 clear_runtime_ctx_parser_source_chunks_ref($runtime_ctx);
 return $runtime_ctx
}

sub prepare_runtime_ctx_for_build_compiled_rule_table {
 my ($option, %args) = @_;
 return undef unless ref($option) eq 'HASH' && exists($option->{runtime_ctx_ref});
 my $runtime_ctx_ref = normalize_runtime_ctx_ref(
  $option->{runtime_ctx_ref},
  owner => defined($args{owner}) ? $args{owner} : 'LinkedSpec::RuntimeContext::prepare_runtime_ctx_for_build_compiled_rule_table',
 );
 my $runtime_ctx = ensure_runtime_ctx($runtime_ctx_ref);
 return undef unless ref($runtime_ctx) eq 'HASH';
 clear_runtime_ctx_last_error($runtime_ctx);
 clear_runtime_ctx_spec_identity($runtime_ctx);
 clear_runtime_ctx_top_rule($runtime_ctx);
 clear_runtime_ctx_parser_source_capture($runtime_ctx, ensure_storage => 1);
 set_runtime_ctx_top_rule($runtime_ctx, $args{top_rule})
  if defined($args{top_rule}) && length($args{top_rule});
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

sub clear_runtime_ctx_parser_source_capture {
 my ($runtime_ctx, %args) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 my $parser_source_chunks_ref = $args{ensure_storage}
  ? ensure_runtime_ctx_parser_source_chunks_ref($runtime_ctx)
  : get_runtime_ctx_parser_source_chunks_ref($runtime_ctx);
 @$parser_source_chunks_ref = () if ref($parser_source_chunks_ref) eq 'ARRAY';
 delete $runtime_ctx->{emit_parser_source_line};
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

sub clear_runtime_ctx_spec_identity {
 my ($runtime_ctx) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 clear_runtime_ctx_spec_name($runtime_ctx);
 clear_runtime_ctx_spec_path($runtime_ctx);
 return $runtime_ctx
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

sub build_generated_handler_source_label {
 my (%args) = @_;
 my $label = defined($args{label}) && length($args{label}) ? $args{label} : '<unknown_rule>';
 my $handler_variant = defined($args{handler_variant}) ? $args{handler_variant} : undef;
 return defined($handler_variant) && length($handler_variant)
  ? "LinkedSpec::generated_handler:$label:$handler_variant"
  : "LinkedSpec::generated_handler:$label"
}

sub build_runtime_ctx_top_rule_handler_source_label {
 my ($runtime_ctx, %args) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 my $top_rule = get_runtime_ctx_top_rule($runtime_ctx);
 return undef unless defined($top_rule) && length($top_rule);
 return build_generated_handler_source_label(
  label => $top_rule,
  handler_variant => $args{handler_variant},
 )
}

sub build_runtime_ctx_rule_or_top_handler_source_label {
 my ($runtime_ctx, $rule_label, %args) = @_;
 if (defined($rule_label) && length($rule_label)) {
  return build_generated_handler_source_label(
   label => $rule_label,
   handler_variant => $args{handler_variant},
  )
 }
 return build_runtime_ctx_top_rule_handler_source_label($runtime_ctx, %args)
}

sub build_rule_meta_handler_source_label {
 my (%args) = @_;
 my $rule_meta = $args{rule_meta};
 my $handler_variant = (ref($rule_meta) eq 'HASH') ? $rule_meta->{selected_handler_variant} : undef;
 return build_generated_handler_source_label(
  label => $args{label},
  handler_variant => $handler_variant,
 )
}

#------------------------------------------------------------------------------
# Function: set_runtime_ctx_last_error
# Purpose : Store one normalized structured failure payload on the shared
#           runtime context, including known spec and top-rule identity.
# Args    : ($runtime_ctx, %error_fields)
# Returns : $error_hashref | undef
#------------------------------------------------------------------------------
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
  top_rule => defined(get_runtime_ctx_top_rule($runtime_ctx)) ? get_runtime_ctx_top_rule($runtime_ctx) : '',
 };
 $error->{rule_label} = $args{rule_label} if defined $args{rule_label};
 $error->{handler_variant} = $args{handler_variant} if defined $args{handler_variant};
 $error->{handler_source_label} = $args{handler_source_label} if defined $args{handler_source_label};
 for my $field (qw/code option_name target target_rule targets regex_index regex_count ownerships
                   expected_contract actual_contract entry_rule rule origin effect operand escape
                   operation count cycle start_offset end_offset rule_role source_id line slot_name
                   first_line authored_selector family cursor_policy edge_ownership execution_shape
                   marker marker_line binding_name operand_kind originating_edge_or_job/) {
  $error->{$field} = $args{$field} if exists $args{$field};
 }
 $runtime_ctx->{last_error} = $error;
 return $error
}

sub set_runtime_ctx_last_error_for_owner {
 my ($runtime_ctx, $default_type, %args) = @_;
 $args{type} = $default_type if defined($default_type) && length($default_type) && !defined($args{type});
 return set_runtime_ctx_last_error($runtime_ctx, %args)
}

sub set_runtime_ctx_last_error_unless_present {
 my ($runtime_ctx, %args) = @_;
 return undef unless ref($runtime_ctx) eq 'HASH';
 return $runtime_ctx->{last_error} if has_structured_runtime_ctx_last_error($runtime_ctx);
 return set_runtime_ctx_last_error($runtime_ctx, %args)
}

sub set_runtime_ctx_last_error_unless_present_for_owner {
 my ($runtime_ctx, $default_type, %args) = @_;
 $args{type} = $default_type if defined($default_type) && length($default_type) && !defined($args{type});
 return set_runtime_ctx_last_error_unless_present($runtime_ctx, %args)
}

1;
