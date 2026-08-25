#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::Contracts
# Purpose: ActionIR contract catalog owner for helper scanning metadata and
#          lowering-entry dispatch across the supported DSL surface.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::Contracts;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();
use LinkedSpec::ActionIR::ProgressiveSpanDispatch ();
use LinkedSpec::ActionIR::StagedParseJob ();

sub _is_primitive_literal_token {
 my ($expr) = @_;
 return 0 unless defined($expr) && length($expr);
 return 1 if $expr =~ /^-?\d+(?:\.\d+)?$/o;
 return 1 if $expr =~ /^\"(?:\\.|[^\"])*\"$/s || $expr =~ /^'(?:\\.|[^'])*'$/s;
 return 1 if $expr eq 'undef' || $expr eq 'true' || $expr eq 'false';
 return 0
}

sub _lower_two_bare_push_contract {
 my ($matched, $rule_or_target, $destination_or_value) = @_;
 return $matched if _is_primitive_literal_token($destination_or_value);
 return 'do { require LinkedSpec::BindingRuntime; '
  .'my $__ls_push_entry = $$descr{spec}{'.$rule_or_target.'}; '
  .'my $__ls_push_handler = ref($__ls_push_entry) eq "CODE" ? $__ls_push_entry : '
  .'ref($__ls_push_entry) eq "HASH" ? $__ls_push_entry->{handler} : undef; '
  .'if (ref($__ls_push_handler) eq "CODE") { '
  .'$'.$destination_or_value.' = LinkedSpec::BindingRuntime::push_value($'.$destination_or_value.', "'.$destination_or_value.'", '
  .'$__ls_push_handler->($descr, $STRING, $minfo)) '
  .'} else { $'.$rule_or_target.' = LinkedSpec::BindingRuntime::push_value($'.$rule_or_target.', "'.$rule_or_target.'", $'.$destination_or_value.') } }'
}

sub _lower_child_call_push_builtin {
 my ($target, $callee, $index, $bare_symbol_kind) = @_;
 my $value = '&{$$descr{spec}{'.$callee.'}{handler}}($descr, $STRING, $minfo)';
 $value .= '->['.$index.']' if defined $index;
 if (ref($bare_symbol_kind) eq 'CODE'
  && (($bare_symbol_kind->($target) // '') eq 'scalar')) {
  return 'do { require LinkedSpec::BindingRuntime; $'.$target.' = '
   .'LinkedSpec::BindingRuntime::push_value($'.$target.', "'.$target.'", '.$value.') }';
 }
 return 'push @'.$target.', '.$value
}

sub _quote_recognition_transaction_string {
 my ($value) = @_;
 $value = '' unless defined $value;
 $value =~ s/\\/\\\\/g;
 $value =~ s/'/\\'/g;
 $value =~ s/\r/\\r/g;
 $value =~ s/\n/\\n/g;
 return "'$value'"
}

sub _build_recursive_observation_contracts {
 my ($label) = @_;
 return [
  {
   id                 => 'observe_recognition',
   ir_node            => 'OBSERVE_RECOGNITION',
   diag_name          => 'observe_recognition',
   unresolved_pattern => qr/\bobserve_recognition\s*\(/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $args = ref($ctx) eq 'HASH' && ref($ctx->{event}) eq 'HASH'
     ? $ctx->{event}{args}
     : undef;
    return $code unless ref($args) eq 'HASH';
    my ($result, $target, $callee) = @{$args}{qw/result target callee/};
    return $code unless defined($result) && $result =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o
     && defined($target) && $target =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o
     && defined($callee) && $callee =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
    return '$'.$result.' = LinkedSpec::RecognitionTransactionRuntime::observe_static('
     .'$descr, $STRING, $info, \\$IPOS, \\$'.$target.', '
     ._quote_recognition_transaction_string($callee).', '
     ._quote_recognition_transaction_string($label).', '
     .'(ref($minfo) eq "HASH" ? $minfo : undef))'
   },
  },
 ]
}

sub _build_inter_match_gap_contracts {
 my ($label) = @_;
 my @specs = (
  {name => 'entry_slot', ir_node => 'ENTRY_SLOT_READ'},
  {name => 'gap_span', ir_node => 'GAP_SPAN_READ'},
  {name => 'gap_text', ir_node => 'GAP_TEXT_READ'},
  {name => 'gap_kind', ir_node => 'GAP_KIND_READ'},
 );
 return [map {
  my $name = $_->{name};
  {
   id => $name,
   ir_node => $_->{ir_node},
   diag_name => $name,
   unresolved_pattern => qr/\b\Q$name\E\s*\(\s*\)/o,
   lower => sub {
    my ($code) = @_;
    $code =~ s/\b\Q$name\E\s*\(\s*\)/LinkedSpec::InterMatchGapRuntime::$name(\$descr, \$STRING, '\Q$label\E')/g;
    return $code
   },
  }
 } @specs]
}

#------------------------------------------------------------------------------
# Function: _build_recognition_transaction_contracts
# Purpose : Own the four exact authored transaction statements and preserve
#           their token/result/static-callee fields in dedicated ActionIR.
#------------------------------------------------------------------------------
sub _build_recognition_transaction_contracts {
 my ($label) = @_;
 return [
  {
   id                 => 'recognition_checkpoint',
   ir_node            => 'RECOGNITION_CHECKPOINT',
   diag_name          => 'recognition_checkpoint',
   unresolved_pattern => qr/\brecognition_checkpoint\s*\(/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $args = ref($ctx) eq 'HASH' && ref($ctx->{event}) eq 'HASH'
     ? $ctx->{event}{args}
     : undef;
    my $token = ref($args) eq 'HASH' ? $args->{token} : undef;
    return $code unless defined($token) && $token =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
    return 'my $'.$token.' = LinkedSpec::RecognitionTransactionRuntime::begin('
     .'$descr, $STRING, $info, \\$IPOS, '. _quote_recognition_transaction_string($label)
     .', '. _quote_recognition_transaction_string($token) .')'
   },
  },
  {
   id                 => 'recognize_once',
   ir_node            => 'RECOGNIZE_ONCE',
   diag_name          => 'recognize_once',
   unresolved_pattern => qr/\brecognize_once\s*\(/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $args = ref($ctx) eq 'HASH' && ref($ctx->{event}) eq 'HASH'
     ? $ctx->{event}{args}
     : undef;
    return $code unless ref($args) eq 'HASH';
    my ($matched, $token, $callee, $operand) = @{$args}{qw/matched token callee operand/};
    return $code unless defined($matched) && $matched =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o
     && defined($token) && $token =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
    my $callee_expr = defined($callee)
     ? _quote_recognition_transaction_string($callee)
     : 'undef';
    return 'my $'.$matched.' = LinkedSpec::RecognitionTransactionRuntime::attempt_static('
     .'$descr, $STRING, $info, \\$IPOS, $'.$token.', '.$callee_expr.', '
     ._quote_recognition_transaction_string($label).')'
   },
  },
  {
   id                 => 'recognition_commit',
   ir_node            => 'RECOGNITION_COMMIT',
   diag_name          => 'recognition_commit',
   unresolved_pattern => qr/\brecognition_commit\s*\(/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $args = ref($ctx) eq 'HASH' && ref($ctx->{event}) eq 'HASH'
     ? $ctx->{event}{args}
     : undef;
    return $code unless ref($args) eq 'HASH';
    my ($payload, $token) = @{$args}{qw/payload token/};
    return $code unless defined($payload) && $payload =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o
     && defined($token) && $token =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
    return 'my $'.$payload.' = LinkedSpec::RecognitionTransactionRuntime::finish_commit('
     .'$descr, $STRING, $info, \\$IPOS, $'.$token.', '
     ._quote_recognition_transaction_string($label).')'
   },
  },
  {
   id                 => 'recognition_rollback',
   ir_node            => 'RECOGNITION_ROLLBACK',
   diag_name          => 'recognition_rollback',
   unresolved_pattern => qr/\brecognition_rollback\s*\(/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $args = ref($ctx) eq 'HASH' && ref($ctx->{event}) eq 'HASH'
     ? $ctx->{event}{args}
     : undef;
    my $token = ref($args) eq 'HASH' ? $args->{token} : undef;
    return $code unless defined($token) && $token =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
    return 'LinkedSpec::RecognitionTransactionRuntime::finish_rollback('
     .'$descr, $STRING, $info, \\$IPOS, $'.$token.', '
     ._quote_recognition_transaction_string($label).')'
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: default_deps_for_package
# Purpose : Build the default contracts dependency bundle for one owner
#           package.
# Args    : ($pkg)
# Returns : hashref of dependency callbacks
#------------------------------------------------------------------------------
sub default_deps_for_package {
 my ($pkg) = @_;
 my $deps = LinkedSpec::OwnerDispatch::build_dep_map(
  __PACKAGE__,
  $pkg,
  [
   'lower_return_general_statement',
   'lower_assign_method_statement',
   'lower_scalar_assignment_operator_statement',
   'lower_array_append_operator_statement',
   'lower_array_end_mutation_method_statement',
   'lower_hash_index_assignment_operator_statement',
   'lower_set_key_statement',
   'lower_push_statement',
   'lower_regex_subst_statement',
   'lower_array_pipeline_expr',
   'lower_if_flow_statement',
   'lower_elseif_flow_statement',
   'lower_else_flow_statement',
   'lower_endif_flow_statement',
   'lower_while_flow_statement',
   'lower_switch_flow_statement',
   'lower_case_flow_statement',
   'lower_default_flow_statement',
   'lower_endcase_flow_statement',
   'lower_endswitch_flow_statement',
   'lower_say_statement',
   'lower_print_statement',
   'lower_print_each_statement',
   'lower_exit_now_statement',
   'lower_return_undef_statement',
   'lower_method_value_expr',
  ],
 );
 if (defined($pkg) && length($pkg) && $pkg->can('_lower_dropped_value_statement')) {
  $deps->{lower_dropped_value_statement} = $pkg->can('_lower_dropped_value_statement');
 }
 return $deps
}

sub _require_lowering_deps {
 my ($deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::Contracts::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb
 };
 my $lower_method_value_expr = $require_dep->('lower_method_value_expr');
 my $lower_dropped_value_statement = (ref($deps) eq 'HASH' && ref($deps->{lower_dropped_value_statement}) eq 'CODE')
  ? $deps->{lower_dropped_value_statement}
  : sub {
   my ($code) = @_;
   my $lowered = $lower_method_value_expr->($code);
   return undef unless defined($lowered) && length($lowered);
   return undef if defined($code) && $lowered eq $code;
   $lowered = '+'.$lowered if $lowered =~ /^\s*\{/s;
   return 'do { '.$lowered.'; undef }'
  };
 return {
  lower_return_general_statement => $require_dep->('lower_return_general_statement'),
  lower_assign_method_statement  => $require_dep->('lower_assign_method_statement'),
  lower_scalar_assignment_operator_statement => $require_dep->('lower_scalar_assignment_operator_statement'),
  lower_array_append_operator_statement => $require_dep->('lower_array_append_operator_statement'),
  lower_array_end_mutation_method_statement => $require_dep->('lower_array_end_mutation_method_statement'),
  lower_hash_index_assignment_operator_statement => $require_dep->('lower_hash_index_assignment_operator_statement'),
  lower_set_key_statement        => $require_dep->('lower_set_key_statement'),
  lower_push_statement           => $require_dep->('lower_push_statement'),
  lower_regex_subst_statement    => $require_dep->('lower_regex_subst_statement'),
  lower_array_pipeline_expr      => $require_dep->('lower_array_pipeline_expr'),
  lower_if_flow_statement        => $require_dep->('lower_if_flow_statement'),
  lower_elseif_flow_statement    => $require_dep->('lower_elseif_flow_statement'),
  lower_else_flow_statement      => $require_dep->('lower_else_flow_statement'),
  lower_endif_flow_statement     => $require_dep->('lower_endif_flow_statement'),
  lower_while_flow_statement     => $require_dep->('lower_while_flow_statement'),
  lower_switch_flow_statement    => $require_dep->('lower_switch_flow_statement'),
  lower_case_flow_statement      => $require_dep->('lower_case_flow_statement'),
  lower_default_flow_statement   => $require_dep->('lower_default_flow_statement'),
  lower_endcase_flow_statement   => $require_dep->('lower_endcase_flow_statement'),
  lower_endswitch_flow_statement => $require_dep->('lower_endswitch_flow_statement'),
  lower_say_statement            => $require_dep->('lower_say_statement'),
  lower_print_statement          => $require_dep->('lower_print_statement'),
  lower_print_each_statement     => $require_dep->('lower_print_each_statement'),
  lower_exit_now_statement       => $require_dep->('lower_exit_now_statement'),
  lower_return_undef_statement   => $require_dep->('lower_return_undef_statement'),
  lower_method_value_expr        => $lower_method_value_expr,
  lower_dropped_value_statement  => $lower_dropped_value_statement,
 }
}

sub _build_mark_trace_call {
 my (%args) = @_;
 return '_trace_runtime_mark_event('
  ."operation => '$args{operation}', "
  ."rule_label => '$args{label}', "
  ."mark_name => '$args{mark_name}', "
  ."string_ref => \$STRING, "
  ."mark_pos => $args{mark_pos_expr}, "
  ."left_edge => (defined(\$LSPOS) && defined(\$LMATCH) ? \$LSPOS - length \$LMATCH : pos \$\$STRING), "
  ."parser_pos => pos \$\$STRING"
  .')'
}

#------------------------------------------------------------------------------
# Function: typed_source_projection_rows
# Purpose : Return the detached neutral catalog for every Perl source-boundary
#           compatibility helper.
#------------------------------------------------------------------------------
sub typed_source_projection_rows {
 return {
  capture_mark => [
   [capture_between => 'span_text'],
   [capture_from => 'span_text'],
   [capture_len_between => 'span_length'],
   [capture_len_from => 'span_length'],
   [capture_rest => 'span_text'],
   [capture_rest_from => 'span_text'],
   [capture_rest_len => 'span_length'],
   [capture_rest_len_from => 'span_length'],
   [capture_slice => 'span_text'],
   [capture_slice_col => 'span_start_column'],
   [capture_slice_len => 'span_length'],
   [capture_slice_line => 'span_start_line'],
   [capture_slice_pos => 'span_start_offset'],
   [capture_slice_until_cursor => 'span_text'],
   [capture_slice_until_cursor_len => 'span_length'],
   [capture_until_boundary => 'span_text'],
   [capture_take => 'span_text'],
   [capture_take_between => 'span_text'],
   [capture_take_between_len => 'span_length'],
   [capture_take_len => 'span_length'],
   [capture_take_len_from => 'span_length'],
   [capture_take_rest => 'span_text'],
   [capture_take_rest_from => 'span_text'],
   [capture_take_rest_len => 'span_length'],
   [capture_take_rest_len_from => 'span_length'],
   [capture_take_until_cursor => 'span_text'],
   [capture_take_until_cursor_from => 'span_text'],
   [capture_take_until_cursor_len => 'span_length'],
   [capture_take_until_cursor_len_from => 'span_length'],
   [capture_until_cursor_from => 'span_text'],
   [capture_until_cursor_len_from => 'span_length'],
   [mark_capture_slice => 'capture_boundary_write_position'],
   [mark_copy => 'mark_write_position'],
   [mark_exists => 'mark_exists'],
   [mark_here => 'mark_write_position'],
   [mark_input_end => 'mark_write_position'],
   [mark_input_start => 'mark_write_position'],
   [mark_pos => 'mark_read_offset'],
   [start_capture_slice => 'capture_boundary_write_position'],
   [start_capture_slice_from => 'capture_boundary_write_position'],
   [clear_mark => 'mark_delete'],
   [mark_col => 'mark_read_column'],
   [mark_entry_end => 'mark_write_position'],
   [mark_entry_start => 'mark_write_position'],
   [mark_line => 'mark_read_line'],
   [mark_match_end => 'mark_write_position'],
   [mark_match_start => 'mark_write_position'],
  ],
  entry_match => [
   [entry_col => 'span_start_column'],
   [entry_end_col => 'position_column'],
   [entry_end_line => 'position_line'],
   [entry_end_pos => 'position_offset'],
   [entry_group => 'capture_group_text'],
   [entry_groups => 'capture_group_list'],
   [entry_has => 'capture_group_exists'],
   [entry_len => 'span_length'],
   [entry_line => 'span_start_line'],
   [entry_map => 'capture_group_map'],
   [entry_named => 'capture_group_text'],
   [entry_start_col => 'span_start_column'],
   [entry_start_line => 'span_start_line'],
   [entry_start_pos => 'span_start_offset'],
   [entry_text => 'span_text'],
   [match_col => 'span_start_column'],
   [match_end_col => 'position_column'],
   [match_end_line => 'position_line'],
   [match_end_pos => 'position_offset'],
   [match_group => 'capture_group_text'],
   [match_groups => 'capture_group_list'],
   [match_has => 'capture_group_exists'],
   [match_len => 'span_length'],
   [match_line => 'span_start_line'],
   [match_map => 'capture_group_map'],
   [match_named => 'capture_group_text'],
   [match_start_col => 'span_start_column'],
   [match_start_line => 'span_start_line'],
   [match_start_pos => 'span_start_offset'],
   [match_text => 'span_text'],
  ],
  input_cursor => [
   [cursor_col => 'position_column'],
   [cursor_line => 'position_line'],
   [cursor_pos => 'cursor_position'],
   [cursor_rest => 'span_text'],
   [cursor_rest_len => 'span_length'],
   [input_end_col => 'position_column'],
   [input_end_line => 'position_line'],
   [input_end_pos => 'position_offset'],
   [input_len => 'source_length'],
   [input_slice => 'source_slice_text'],
   [input_text => 'source_text'],
  ],
  cursor_control => [
   [restore_cursor => 'cursor_state_write_compatibility'],
   [rewind_entry_start => 'cursor_state_write_compatibility'],
   [rewind_match_start => 'cursor_state_write_compatibility'],
   [save_cursor => 'cursor_checkpoint_compatibility'],
  ],
 }
}

#------------------------------------------------------------------------------
# Function: _build_call_and_dispatch_contracts
# Purpose : Contracts that dispatch/call parser handlers and push results.
#------------------------------------------------------------------------------
sub _build_call_and_dispatch_contracts {
 my ($label, $deps) = @_;
 my $bare_symbol_kind = (ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE')
  ? $deps->{bare_symbol_kind}
  : sub { return undef };
 return [
  {
   id                 => 'call',
   ir_node            => 'CALL',
   diag_name          => 'call',
   unresolved_pattern => qr/\bcall\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcall\s*\(\s*(\w+)\s*\)/&{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'push_single_arg',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   unresolved_pattern => qr/\bpush\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s*\(\s*(\w+)\s*\)/push \@$label, &{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'push_indexed_arg',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   unresolved_pattern => qr/\bpush\s*\(\s*\w+\s*,\s*\d+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s*\(\s*(\w+)\s*,\s*(\d+)\s*\)/push \@$label, &{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)->[$2]/g;
    return $code
   },
  },
  {
   id                 => 'push_target_arg',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   unresolved_pattern => qr/\bpush\s*\(\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s*\(\s*(\w+)\s*,\s*(\w+)\s*\)/_lower_two_bare_push_contract($&, $1, $2)/ge;
    return $code
   },
  },
  {
   id                 => 'push_target_indexed_arg',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   unresolved_pattern => qr/\bpush\s*\(\s*\w+\s*,\s*\w+\s*,\s*\d+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s*\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\d+)\s*\)/push \@$2, &{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)->[$3]/g;
    return $code
   },
  },
  {
   id                 => 'push_scope_target_arg',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   unresolved_pattern => qr/\bpush\s*\(\s*\w+\s*,\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s*\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*\)/push \@$3, &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'assign_call_my',
   ir_node            => 'CALL',
   diag_name          => 'assign_call_my',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bmy\s+\$\w+\s*=\s*call\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmy\s+(\$\w+)\s*=\s*call\s*\(\s*(\w+)\s*\)/my $1 = &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'assign_call',
   ir_node            => 'CALL',
   diag_name          => 'assign_call',
   compatibility_surface => 1,
   unresolved_pattern => qr/\$\w+\s*=\s*call\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/(\$\w+)\s*=\s*call\s*\(\s*(\w+)\s*\)/$1 = &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'push_child_call_indexed_builtin',
   ir_node            => 'CALL',
   diag_name          => 'push_child_call_indexed_builtin',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bpush\s+\@\w+\s*,\s*call\s*\(\s*\w+\s*\)\s*->\s*\[\s*\d+\s*\]/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s+\@(\w+)\s*,\s*call\s*\(\s*(\w+)\s*\)\s*->\s*\[\s*(\d+)\s*\]/_lower_child_call_push_builtin($1, $2, $3, $bare_symbol_kind)/ge;
    return $code
   },
  },
  {
   id                 => 'push_child_call_builtin',
   ir_node            => 'CALL',
   diag_name          => 'push_child_call_builtin',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bpush\s+\@\w+\s*,\s*call\s*\(\s*\w+\s*\)(?!\s*->\s*\[)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bpush\s+\@(\w+)\s*,\s*call\s*\(\s*(\w+)\s*\)(?!\s*->\s*\[)/_lower_child_call_push_builtin($1, $2, undef, $bare_symbol_kind)/ge;
    return $code
   },
  },
  {
   id                 => 'return_call',
   ir_node            => 'CALL',
   diag_name          => 'return_call',
   compatibility_surface => 1,
   unresolved_pattern => qr/\breturn\s+call\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\breturn\s+call\s*\(\s*(\w+)\s*\)/return &{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_return_contracts
# Purpose : Contracts that lower return-related helper surfaces.
#------------------------------------------------------------------------------
sub _build_return_contracts {
 my ($label, $d) = @_;
 return [
  {
   id                 => 'return_general',
   ir_node            => 'RETURN',
   diag_name          => 'return',
   unresolved_pattern => qr/\breturn\s*\(\s*(?:\[|\{|\"|'|-?\d+(?:\.\d+)?|array\s*\(|hash\s*\(|flat_array\s*\(|flat_hash\s*\(|flat\s*\(|(?:and|or|not|entry_text|match_text|entry_group|match_group|entry_groups|match_groups|input_text|input_len|input_slice)\s*\()/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_return_general_statement};
    $code =~ s/\b(?<expr>return\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'return',
   ir_node            => 'RETURN',
   diag_name          => 'return',
   unresolved_pattern => qr/\breturn\s*\(\s*\w+\s*,/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_return_general_statement};
    $code =~ s/\b(?<expr>return\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/do {
     my $expr = $+{expr};
     my $lowered = $lower->($expr);
     (defined($lowered) && length($lowered) && $expr =~ m{^\s*return\s*\(\s*\Q$label\E\s*,}) ? $lowered : $&;
    }/ge;
    return $code
   },
  },
  {
   id                 => 'return_bare',
   ir_node            => 'RETURN',
   diag_name          => 'return',
   compatibility_surface => 1,
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'return_undef',
   ir_node            => 'RETURN',
   diag_name          => 'return_undef',
   unresolved_pattern => qr/\breturn_undef\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_return_undef_statement};
    $code =~ s/\b(?<expr>return_undef\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_capture_and_cursor_contracts
# Purpose : Contracts that normalize capture and cursor-control helpers.
#------------------------------------------------------------------------------
sub _build_capture_and_cursor_contracts {
 my ($label, $d) = @_;
 $d = {} unless ref($d) eq 'HASH';
 return [
  {
   id                 => 'capture_macro',
   ir_node            => 'CAPTURE_MACRO',
   diag_name          => 'capture_macro',
   unresolved_pattern => qr/\$CAPTURE\b/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\$CAPTURE\b/substr\(\$\$STRING, \$IPOS, \$LSPOS - \$IPOS - length \$LMATCH\)/g;
    return $code
   },
  },
  {
   id                 => 'capture',
   ir_node            => 'CAPTURE',
   diag_name          => 'capture',
   unresolved_pattern => qr/\bcapture\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcapture\s*\(\s*\w+\s*\)/push \@$label, substr\(\$\$STRING, \$IPOS, \$LSPOS - \$IPOS - length \$LMATCH\)/g;
    return $code
   },
  },
  {
   id                 => 'capture_if',
   ir_node            => 'CAPTURE_IF',
   diag_name          => 'capture_if',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bcapture_if\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{\bcapture_if\s*\(\s*\w+\s*\)}{q{my $capt = substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH); $capt =~ s/^\s*|\s*$//go; push @} . $label . q{, $capt if $capt}}ge;
    return $code
   },
  },
  {
   id                 => 'capture_if_macro',
   ir_node            => 'CAPTURE_IF',
   diag_name          => 'CAPTURE_IF',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bCAPTURE_IF\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{\bCAPTURE_IF\s*\(\s*\)}{q{my $capt = substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH); $capt =~ s/^\s*|\s*$//go; push @} . $label . q{, $capt if $capt}}ge;
    return $code
   },
  },
  {
   id                 => 'capture_slice',
   ir_node            => 'CAPTURE_SLICE',
   diag_name          => 'capture_slice',
   unresolved_pattern => qr/\bcapture_slice\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_slice\s*\(\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $IPOS, $LSPOS - length($LMATCH), "capture_slice") }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_slice_len',
   ir_node            => 'CAPTURE_SLICE_LEN',
   diag_name          => 'capture_slice_len',
   unresolved_pattern => qr/\bcapture_slice_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_slice_len\s*\(\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $IPOS, $LSPOS - length($LMATCH), "capture_slice_len") }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_slice_until_cursor',
   ir_node            => 'CAPTURE_SLICE_UNTIL_CURSOR',
   diag_name          => 'capture_slice_until_cursor',
   unresolved_pattern => qr/\bcapture_slice_until_cursor\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_slice_until_cursor\s*\(\s*\)
    }{
     'do { my $__ls_cursor = pos $$STRING; (defined($__ls_cursor) && defined($IPOS) && $__ls_cursor >= $IPOS) ? LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $IPOS, $__ls_cursor, "capture_slice_until_cursor") : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_slice_until_cursor_len',
   ir_node            => 'CAPTURE_SLICE_UNTIL_CURSOR_LEN',
   diag_name          => 'capture_slice_until_cursor_len',
   unresolved_pattern => qr/\bcapture_slice_until_cursor_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_slice_until_cursor_len\s*\(\s*\)
    }{
     'do { my $__ls_cursor = pos $$STRING; (defined($__ls_cursor) && defined($IPOS) && $__ls_cursor >= $IPOS) ? LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $IPOS, $__ls_cursor, "capture_slice_until_cursor_len") : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_until_boundary',
   ir_node            => 'CAPTURE_UNTIL_BOUNDARY',
   diag_name          => 'capture_until_boundary',
   unresolved_pattern => qr/\bcapture_until_boundary\s*\(\s*(?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|\w+)(?:\s*,\s*(?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|\w+))*\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_until_boundary\s*\(\s*(?<boundaries>(?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|\w+)(?:\s*,\s*(?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|\w+))*)\s*\)
    }{
     my @boundary_labels;
     for my $boundary (split(/\s*,\s*/, $+{boundaries})) {
      if ($boundary =~ /\A(["'])(.*)\1\z/s) {
       $boundary = $2;
       $boundary =~ s/\\(["'\\])/$1/g;
      }
      $boundary =~ s/\\/\\\\/g;
      $boundary =~ s/'/\\'/g;
      push @boundary_labels, "'$boundary'" if length($boundary);
     }
     my $labels = join(', ', @boundary_labels);
     'do { my @__ls_boundary_labels = ('.$labels.'); my $__ls_saved_cursor = pos $$STRING; my $__ls_capture_start = defined($__ls_saved_cursor) ? $__ls_saved_cursor : 0; my $__ls_boundary_start; my $__ls_boundary_valid = 0; for my $__ls_boundary_label (@__ls_boundary_labels) { LinkedSpec::SourceLocation::Runtime::cursor_state_write_compatibility($info, $STRING, $__ls_saved_cursor, "capture_until_boundary_probe") if defined($__ls_saved_cursor); my $__ls_boundary_rule = (ref($$descr{spec}) eq "HASH") ? $$descr{spec}{$__ls_boundary_label} : undef; next unless ref($__ls_boundary_rule) eq "HASH" && ref($__ls_boundary_rule->{re}) eq "ARRAY" && @{$__ls_boundary_rule->{re}}; my $__ls_boundary_re = LinkedRE::oredRE(@{$__ls_boundary_rule->{re}}); $__ls_boundary_valid = 1; my $__ls_boundary_info = LinkedRE::or($STRING, $__ls_boundary_re, $info); next unless defined($__ls_boundary_info); my $__ls_candidate_start = (pos $$STRING) - length($__ls_boundary_info->{match}); $__ls_boundary_start = $__ls_candidate_start if !defined($__ls_boundary_start) || $__ls_candidate_start < $__ls_boundary_start; } $__ls_boundary_start = LinkedSpec::SourceLocation::Runtime::source_length($info, $STRING, "capture_until_boundary") if $__ls_boundary_valid && !defined($__ls_boundary_start); if ($__ls_boundary_valid && $__ls_boundary_start >= $__ls_capture_start) { LinkedSpec::SourceLocation::Runtime::cursor_state_write_compatibility($info, $STRING, $__ls_boundary_start, "capture_until_boundary"); LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $__ls_capture_start, $__ls_boundary_start, "capture_until_boundary") } else { LinkedSpec::SourceLocation::Runtime::cursor_state_write_compatibility($info, $STRING, $__ls_saved_cursor, "capture_until_boundary_restore") if defined($__ls_saved_cursor); undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_until_cursor',
   ir_node            => 'CAPTURE_SLICE_TAKE_UNTIL_CURSOR',
   diag_name          => 'capture_take_until_cursor',
   unresolved_pattern => qr/\bcapture_take_until_cursor\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_until_cursor\s*\(\s*\)
    }{
     'do { my $__ls_cursor = pos $$STRING; if (defined($__ls_cursor) && defined($IPOS) && $__ls_cursor >= $IPOS) { my $__ls_capture = LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $IPOS, $__ls_cursor, "capture_take_until_cursor"); $IPOS = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position($info, $STRING, $__ls_cursor, "capture_take_until_cursor"); $__ls_capture } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_until_cursor_len',
   ir_node            => 'CAPTURE_SLICE_TAKE_UNTIL_CURSOR_LEN',
   diag_name          => 'capture_take_until_cursor_len',
   unresolved_pattern => qr/\bcapture_take_until_cursor_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_until_cursor_len\s*\(\s*\)
    }{
     'do { my $__ls_cursor = pos $$STRING; if (defined($__ls_cursor) && defined($IPOS) && $__ls_cursor >= $IPOS) { my $__ls_capture_len = LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $IPOS, $__ls_cursor, "capture_take_until_cursor_len"); $IPOS = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position($info, $STRING, $__ls_cursor, "capture_take_until_cursor_len"); $__ls_capture_len } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_slice_line',
   ir_node            => 'CAPTURE_SLICE_LINE_READ',
   diag_name          => 'capture_slice_line',
   unresolved_pattern => qr/\bcapture_slice_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcapture_slice_line\s*\(\s*\)/do { my \$__ls_capture_pos = defined(\$IPOS) ? \$IPOS : 0; LinkedSpec::SourceLocation::Runtime::span_start_line(\$info, \$STRING, \$__ls_capture_pos, \$__ls_capture_pos, "capture_slice_line") }/g;
    return $code
   },
  },
  {
   id                 => 'capture_slice_col',
   ir_node            => 'CAPTURE_SLICE_COL_READ',
   diag_name          => 'capture_slice_col',
   unresolved_pattern => qr/\bcapture_slice_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcapture_slice_col\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::span_start_column(\$info, \$STRING, defined(\$IPOS) ? \$IPOS : 0, defined(\$IPOS) ? \$IPOS : 0, "capture_slice_col") }/g;
    return $code
   },
  },
  {
   id                 => 'capture_slice_pos',
   ir_node            => 'CAPTURE_SLICE_POS_READ',
   diag_name          => 'capture_slice_pos',
   unresolved_pattern => qr/\bcapture_slice_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcapture_slice_pos\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::span_start_offset(\$info, \$STRING, \$IPOS, \$IPOS, "capture_slice_pos") }/g;
    return $code
   },
  },
  {
   id                 => 'capture_slice_length',
   ir_node            => 'CAPTURE_SLICE_LEN',
   diag_name          => 'capture_slice_len',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bcapture_slice_length\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_slice_length\s*\(\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $IPOS, $LSPOS - length($LMATCH), "capture_slice_length") }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'start_capture_slice',
   ir_node            => 'CAPTURE_SLICE_START',
   diag_name          => 'start_capture_slice',
   unresolved_pattern => qr/\bstart_capture_slice\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bstart_capture_slice\s*\(\s*\)
    }{
     'do { $IPOS = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position($info, $STRING, pos $$STRING, "start_capture_slice") }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'start_capture_slice_from_mark',
   ir_node            => 'CAPTURE_SLICE_START_FROM_MARK',
   diag_name          => 'start_capture_slice_from',
   unresolved_pattern => qr/\bstart_capture_slice_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bstart_capture_slice_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "start_capture_slice_from"); defined($__ls_mark) ? ($IPOS = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position($info, $STRING, $__ls_mark, "start_capture_slice_from")) : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_slice_here',
   ir_node            => 'CAPTURE_SLICE_START',
   diag_name          => 'start_capture_slice',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bcapture_slice_here\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_slice_here\s*\(\s*\)
    }{
     'do { $IPOS = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position($info, $STRING, pos $$STRING, "capture_slice_here") }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_rest',
   ir_node            => 'CAPTURE_REST',
   diag_name          => 'capture_rest',
   unresolved_pattern => qr/\bcapture_rest\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_rest\s*\(\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $IPOS, LinkedSpec::SourceLocation::Runtime::source_length($info, $STRING, "capture_rest"), "capture_rest") }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_rest_len',
   ir_node            => 'CAPTURE_REST_LEN',
   diag_name          => 'capture_rest_len',
   unresolved_pattern => qr/\bcapture_rest_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_rest_len\s*\(\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $IPOS, LinkedSpec::SourceLocation::Runtime::source_length($info, $STRING, "capture_rest_len"), "capture_rest_len") }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_rest_length',
   ir_node            => 'CAPTURE_REST_LEN',
   diag_name          => 'capture_rest_len',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bcapture_rest_length\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_rest_length\s*\(\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $IPOS, LinkedSpec::SourceLocation::Runtime::source_length($info, $STRING, "capture_rest_length"), "capture_rest_length") }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_rest',
   ir_node            => 'CAPTURE_REST_TAKE',
   diag_name          => 'capture_take_rest',
   unresolved_pattern => qr/\bcapture_take_rest\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_rest\s*\(\s*\)
    }{
     'do { my $__ls_end = LinkedSpec::SourceLocation::Runtime::source_length($info, $STRING, "capture_take_rest"); if (defined($IPOS) && $__ls_end >= $IPOS) { my $__ls_capture = LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $IPOS, $__ls_end, "capture_take_rest"); $IPOS = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position($info, $STRING, $__ls_end, "capture_take_rest"); $__ls_capture } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_rest_len',
   ir_node            => 'CAPTURE_REST_TAKE_LEN',
   diag_name          => 'capture_take_rest_len',
   unresolved_pattern => qr/\bcapture_take_rest_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_rest_len\s*\(\s*\)
    }{
     'do { my $__ls_end = LinkedSpec::SourceLocation::Runtime::source_length($info, $STRING, "capture_take_rest_len"); if (defined($IPOS) && $__ls_end >= $IPOS) { my $__ls_capture_len = LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $IPOS, $__ls_end, "capture_take_rest_len"); $IPOS = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position($info, $STRING, $__ls_end, "capture_take_rest_len"); $__ls_capture_len } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_slice',
   ir_node            => 'CAPTURE_SLICE_TAKE',
   diag_name          => 'capture_take',
   unresolved_pattern => qr/\bcapture_take\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take\s*\(\s*\)
    }{
     'do { my $__ls_end = $LSPOS - length($LMATCH); my $__ls_capture = LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $IPOS, $__ls_end, "capture_take"); $IPOS = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position($info, $STRING, pos $$STRING, "capture_take"); $__ls_capture }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_slice_len',
   ir_node            => 'CAPTURE_SLICE_TAKE_LEN',
   diag_name          => 'capture_take_len',
   unresolved_pattern => qr/\bcapture_take_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_len\s*\(\s*\)
    }{
     'do { my $__ls_end = $LSPOS - length($LMATCH); my $__ls_capture_len = LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $IPOS, $__ls_end, "capture_take_len"); $IPOS = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position($info, $STRING, pos $$STRING, "capture_take_len"); $__ls_capture_len }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_from_rule_start',
   ir_node            => 'CAPTURE_SLICE',
   diag_name          => 'capture_slice',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bcapture_from_rule_start\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_from_rule_start\s*\(\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $IPOS, $LSPOS - length($LMATCH), "capture_from_rule_start") }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_len_from_rule_start',
   ir_node            => 'CAPTURE_SLICE_LEN',
   diag_name          => 'capture_slice_len',
   compatibility_surface => 1,
   unresolved_pattern => qr/\bcapture_len_from_rule_start\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_len_from_rule_start\s*\(\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $IPOS, $LSPOS - length($LMATCH), "capture_len_from_rule_start") }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_from_mark',
   ir_node            => 'CAPTURE_FROM_MARK',
   diag_name          => 'capture_from',
   unresolved_pattern => qr/\bcapture_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "capture_from"); defined($__ls_mark) ? LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $__ls_mark, $LSPOS - length($LMATCH), "capture_from") : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_len_from_mark',
   ir_node            => 'CAPTURE_LEN_FROM_MARK',
   diag_name          => 'capture_len_from',
   unresolved_pattern => qr/\bcapture_len_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_len_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "capture_len_from"); defined($__ls_mark) ? LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $__ls_mark, $LSPOS - length($LMATCH), "capture_len_from") : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_from_mark',
   ir_node            => 'CAPTURE_TAKE_FROM_MARK',
   diag_name          => 'capture_take',
   unresolved_pattern => qr/\bcapture_take\s*\(\s*\w+\s*\)/o,
  lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "capture_take"); if (defined($__ls_mark)) { my $__ls_capture = LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $__ls_mark, $LSPOS - length($LMATCH), "capture_take"); my $__ls_new_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', pos $$STRING, "capture_take"); '. _build_mark_trace_call(operation => 'capture_take', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_new_mark') .'; $__ls_capture } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_len_from_mark',
   ir_node            => 'CAPTURE_TAKE_LEN_FROM_MARK',
   diag_name          => 'capture_take_len_from',
   unresolved_pattern => qr/\bcapture_take_len_from\s*\(\s*\w+\s*\)/o,
  lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_len_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "capture_take_len_from"); if (defined($__ls_mark)) { my $__ls_capture_len = LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $__ls_mark, $LSPOS - length($LMATCH), "capture_take_len_from"); my $__ls_new_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', pos $$STRING, "capture_take_len_from"); '. _build_mark_trace_call(operation => 'capture_take_len_from', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_new_mark') .'; $__ls_capture_len } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_rest_from_mark',
   ir_node            => 'CAPTURE_REST_FROM_MARK',
   diag_name          => 'capture_rest_from',
   unresolved_pattern => qr/\bcapture_rest_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_rest_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "capture_rest_from"); defined($__ls_mark) ? LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $__ls_mark, LinkedSpec::SourceLocation::Runtime::source_length($info, $STRING, "capture_rest_from"), "capture_rest_from") : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_rest_len_from_mark',
   ir_node            => 'CAPTURE_REST_LEN_FROM_MARK',
   diag_name          => 'capture_rest_len_from',
   unresolved_pattern => qr/\bcapture_rest_len_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_rest_len_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "capture_rest_len_from"); defined($__ls_mark) ? LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $__ls_mark, LinkedSpec::SourceLocation::Runtime::source_length($info, $STRING, "capture_rest_len_from"), "capture_rest_len_from") : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_rest_from_mark',
   ir_node            => 'CAPTURE_TAKE_REST_FROM_MARK',
   diag_name          => 'capture_take_rest_from',
   unresolved_pattern => qr/\bcapture_take_rest_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_rest_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "capture_take_rest_from"); my $__ls_end = LinkedSpec::SourceLocation::Runtime::source_length($info, $STRING, "capture_take_rest_from"); if (defined($__ls_mark) && $__ls_end >= $__ls_mark) { my $__ls_capture = LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $__ls_mark, $__ls_end, "capture_take_rest_from"); my $__ls_new_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', $__ls_end, "capture_take_rest_from"); '. _build_mark_trace_call(operation => 'capture_take_rest_from', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_new_mark') .'; $__ls_capture } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_rest_len_from_mark',
   ir_node            => 'CAPTURE_TAKE_REST_LEN_FROM_MARK',
   diag_name          => 'capture_take_rest_len_from',
   unresolved_pattern => qr/\bcapture_take_rest_len_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_rest_len_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "capture_take_rest_len_from"); my $__ls_end = LinkedSpec::SourceLocation::Runtime::source_length($info, $STRING, "capture_take_rest_len_from"); if (defined($__ls_mark) && $__ls_end >= $__ls_mark) { my $__ls_capture_len = LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $__ls_mark, $__ls_end, "capture_take_rest_len_from"); my $__ls_new_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', $__ls_end, "capture_take_rest_len_from"); '. _build_mark_trace_call(operation => 'capture_take_rest_len_from', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_new_mark') .'; $__ls_capture_len } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_until_cursor_from_mark',
   ir_node            => 'CAPTURE_UNTIL_CURSOR_FROM_MARK',
   diag_name          => 'capture_until_cursor_from',
   unresolved_pattern => qr/\bcapture_until_cursor_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_until_cursor_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "capture_until_cursor_from"); my $__ls_cursor = pos $$STRING; (defined($__ls_mark) && defined($__ls_cursor) && $__ls_cursor >= $__ls_mark) ? LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $__ls_mark, $__ls_cursor, "capture_until_cursor_from") : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_until_cursor_len_from_mark',
   ir_node            => 'CAPTURE_UNTIL_CURSOR_LEN_FROM_MARK',
   diag_name          => 'capture_until_cursor_len_from',
   unresolved_pattern => qr/\bcapture_until_cursor_len_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_until_cursor_len_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "capture_until_cursor_len_from"); my $__ls_cursor = pos $$STRING; (defined($__ls_mark) && defined($__ls_cursor) && $__ls_cursor >= $__ls_mark) ? LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $__ls_mark, $__ls_cursor, "capture_until_cursor_len_from") : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_until_cursor_from_mark',
   ir_node            => 'CAPTURE_TAKE_UNTIL_CURSOR_FROM_MARK',
   diag_name          => 'capture_take_until_cursor_from',
   unresolved_pattern => qr/\bcapture_take_until_cursor_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_until_cursor_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "capture_take_until_cursor_from"); my $__ls_cursor = pos $$STRING; if (defined($__ls_mark) && defined($__ls_cursor) && $__ls_cursor >= $__ls_mark) { my $__ls_capture = LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $__ls_mark, $__ls_cursor, "capture_take_until_cursor_from"); my $__ls_new_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', $__ls_cursor, "capture_take_until_cursor_from"); '. _build_mark_trace_call(operation => 'capture_take_until_cursor', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_new_mark') .'; $__ls_capture } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_until_cursor_len_from_mark',
   ir_node            => 'CAPTURE_TAKE_UNTIL_CURSOR_LEN_FROM_MARK',
   diag_name          => 'capture_take_until_cursor_len_from',
   unresolved_pattern => qr/\bcapture_take_until_cursor_len_from\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_until_cursor_len_from\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "capture_take_until_cursor_len_from"); my $__ls_cursor = pos $$STRING; if (defined($__ls_mark) && defined($__ls_cursor) && $__ls_cursor >= $__ls_mark) { my $__ls_capture_len = LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $__ls_mark, $__ls_cursor, "capture_take_until_cursor_len_from"); my $__ls_new_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', $__ls_cursor, "capture_take_until_cursor_len_from"); '. _build_mark_trace_call(operation => 'capture_take_until_cursor_len', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_new_mark') .'; $__ls_capture_len } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_between_marks',
   ir_node            => 'CAPTURE_BETWEEN_MARKS',
   diag_name          => 'capture_between',
   unresolved_pattern => qr/\bcapture_between\s*\(\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_between\s*\(\s*(?<start>\w+)\s*,\s*(?<end>\w+)\s*\)
    }{
     'do { my $__ls_start = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{start}.'\', "capture_between"); my $__ls_end = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{end}.'\', "capture_between"); (defined($__ls_start) && defined($__ls_end) && $__ls_end >= $__ls_start) ? LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $__ls_start, $__ls_end, "capture_between") : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_len_between_marks',
   ir_node            => 'CAPTURE_LEN_BETWEEN_MARKS',
   diag_name          => 'capture_len_between',
   unresolved_pattern => qr/\bcapture_len_between\s*\(\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_len_between\s*\(\s*(?<start>\w+)\s*,\s*(?<end>\w+)\s*\)
    }{
     'do { my $__ls_start = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{start}.'\', "capture_len_between"); my $__ls_end = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{end}.'\', "capture_len_between"); (defined($__ls_start) && defined($__ls_end) && $__ls_end >= $__ls_start) ? LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $__ls_start, $__ls_end, "capture_len_between") : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_between_marks',
   ir_node            => 'CAPTURE_TAKE_BETWEEN_MARKS',
   diag_name          => 'capture_take_between',
   unresolved_pattern => qr/\bcapture_take_between\s*\(\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_between\s*\(\s*(?<start>\w+)\s*,\s*(?<end>\w+)\s*\)
    }{
     'do { my $__ls_start = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{start}.'\', "capture_take_between"); my $__ls_end = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{end}.'\', "capture_take_between"); if (defined($__ls_start) && defined($__ls_end) && $__ls_end >= $__ls_start) { my $__ls_capture = LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $__ls_start, $__ls_end, "capture_take_between"); my $__ls_new_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{start}.'\', $__ls_end, "capture_take_between"); '. _build_mark_trace_call(operation => 'capture_take_between', label => $label, mark_name => $+{start}, mark_pos_expr => '$__ls_new_mark') .'; $__ls_capture } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'capture_take_between_len_marks',
   ir_node            => 'CAPTURE_TAKE_BETWEEN_LEN_MARKS',
   diag_name          => 'capture_take_between_len',
   unresolved_pattern => qr/\bcapture_take_between_len\s*\(\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcapture_take_between_len\s*\(\s*(?<start>\w+)\s*,\s*(?<end>\w+)\s*\)
    }{
     'do { my $__ls_start = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{start}.'\', "capture_take_between_len"); my $__ls_end = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{end}.'\', "capture_take_between_len"); if (defined($__ls_start) && defined($__ls_end) && $__ls_end >= $__ls_start) { my $__ls_capture_len = LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $__ls_start, $__ls_end, "capture_take_between_len"); my $__ls_new_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{start}.'\', $__ls_end, "capture_take_between_len"); '. _build_mark_trace_call(operation => 'capture_take_between_len', label => $label, mark_name => $+{start}, mark_pos_expr => '$__ls_new_mark') .'; $__ls_capture_len } else { undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_input_start',
   ir_node            => 'MARK_INPUT_START',
   diag_name          => 'mark_input_start',
   unresolved_pattern => qr/\bmark_input_start\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_input_start\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', 0, "mark_input_start"); '. _build_mark_trace_call(operation => 'mark_input_start', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark') .'; 1 }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_input_end',
   ir_node            => 'MARK_INPUT_END',
   diag_name          => 'mark_input_end',
   unresolved_pattern => qr/\bmark_input_end\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_input_end\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', LinkedSpec::SourceLocation::Runtime::source_length($info, $STRING, "mark_input_end"), "mark_input_end"); '. _build_mark_trace_call(operation => 'mark_input_end', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark') .'; 1 }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_here',
   ir_node            => 'MARK_HERE',
   diag_name          => 'mark_here',
   unresolved_pattern => qr/\bmark_here\s*\(\s*\w+\s*\)/o,
  lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_here\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', pos $$STRING, "mark_here"); '. _build_mark_trace_call(operation => 'mark_here', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark') .'; $__ls_mark }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_entry_start',
   ir_node            => 'MARK_ENTRY_START',
   diag_name          => 'mark_entry_start',
   unresolved_pattern => qr/\bmark_entry_start\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_entry_start\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', $IPOS - length($IMATCH), "mark_entry_start"); '. _build_mark_trace_call(operation => 'mark_entry_start', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark') .'; $__ls_mark }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_entry_end',
   ir_node            => 'MARK_ENTRY_END',
   diag_name          => 'mark_entry_end',
   unresolved_pattern => qr/\bmark_entry_end\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_entry_end\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', $IPOS, "mark_entry_end"); '. _build_mark_trace_call(operation => 'mark_entry_end', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark') .'; $__ls_mark }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_match_start',
   ir_node            => 'MARK_MATCH_START',
   diag_name          => 'mark_match_start',
   unresolved_pattern => qr/\bmark_match_start\s*\(\s*\w+\s*\)/o,
  lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_match_start\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', $LSPOS - length($LMATCH), "mark_match_start"); '. _build_mark_trace_call(operation => 'mark_match_start', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark') .'; $__ls_mark }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_match_end',
   ir_node            => 'MARK_MATCH_END',
   diag_name          => 'mark_match_end',
   unresolved_pattern => qr/\bmark_match_end\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_match_end\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', $LSPOS, "mark_match_end"); '. _build_mark_trace_call(operation => 'mark_match_end', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark') .'; $__ls_mark }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_copy',
   ir_node            => 'MARK_COPY',
   diag_name          => 'mark_copy',
   unresolved_pattern => qr/\bmark_copy\s*\(\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_copy\s*\(\s*(?<target>\w+)\s*,\s*(?<source>\w+)\s*\)
    }{
     'do { my $__ls_source = LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{source}.'\', "mark_copy"); if (defined($__ls_source)) { my $__ls_target = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{target}.'\', $__ls_source, "mark_copy"); '. _build_mark_trace_call(operation => 'mark_copy', label => $label, mark_name => $+{target}, mark_pos_expr => '$__ls_target') .'; $__ls_target } else { LinkedSpec::SourceLocation::Runtime::mark_delete($info, \''.$label.'\', \''.$+{target}.'\'); undef } }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_capture_slice',
   ir_node            => 'MARK_CAPTURE_SLICE',
   diag_name          => 'mark_capture_slice',
   unresolved_pattern => qr/\bmark_capture_slice\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_capture_slice\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { my $__ls_capture_boundary = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position($info, $STRING, $IPOS, "mark_capture_slice"); my $__ls_mark = LinkedSpec::SourceLocation::Runtime::mark_write_position($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', $__ls_capture_boundary, "mark_capture_slice"); '. _build_mark_trace_call(operation => 'mark_capture_slice', label => $label, mark_name => $+{mark}, mark_pos_expr => '$__ls_mark') .'; $__ls_mark }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'clear_mark',
   ir_node            => 'CLEAR_MARK',
   diag_name          => 'clear_mark',
   unresolved_pattern => qr/\bclear_mark\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bclear_mark\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::mark_delete($info, \''.$label.'\', \''.$+{mark}.'\') }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_exists',
   ir_node            => 'MARK_EXISTS',
   diag_name          => 'mark_exists',
   unresolved_pattern => qr/\bmark_exists\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_exists\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::mark_exists($info, \''.$label.'\', \''.$+{mark}.'\') }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_pos',
   ir_node            => 'MARK_POS_READ',
   diag_name          => 'mark_pos',
   unresolved_pattern => qr/\bmark_pos\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_pos\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::mark_read_offset($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "mark_pos") }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_line',
   ir_node            => 'MARK_LINE_READ',
   diag_name          => 'mark_line',
   unresolved_pattern => qr/\bmark_line\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_line\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::mark_read_line($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "mark_line") }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'mark_col',
   ir_node            => 'MARK_COL_READ',
   diag_name          => 'mark_col',
   unresolved_pattern => qr/\bmark_col\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmark_col\s*\(\s*(?<mark>\w+)\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::mark_read_column($info, $STRING, \''.$label.'\', \''.$+{mark}.'\', "mark_col") }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'cursor_pos',
   ir_node            => 'CURSOR_POS_READ',
   diag_name          => 'cursor_pos',
   unresolved_pattern => qr/\bcursor_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcursor_pos\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::cursor_position(\$info, \$STRING, pos \$\$STRING, "cursor_pos") }/g;
    return $code
   },
  },
  {
   id                 => 'cursor_line',
   ir_node            => 'CURSOR_LINE_READ',
   diag_name          => 'cursor_line',
   unresolved_pattern => qr/\bcursor_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcursor_line\s*\(\s*\)/do { my \$__ls_cursor_pos = pos \$\$STRING; LinkedSpec::SourceLocation::Runtime::position_line(\$info, \$STRING, defined(\$__ls_cursor_pos) ? \$__ls_cursor_pos : 0, "cursor_line") }/g;
    return $code
   },
  },
  {
   id                 => 'cursor_col',
   ir_node            => 'CURSOR_COL_READ',
   diag_name          => 'cursor_col',
   unresolved_pattern => qr/\bcursor_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bcursor_col\s*\(\s*\)/do { my \$__ls_cursor_pos = pos \$\$STRING; LinkedSpec::SourceLocation::Runtime::position_column(\$info, \$STRING, defined(\$__ls_cursor_pos) ? \$__ls_cursor_pos : 0, "cursor_col") }/g;
    return $code
   },
  },
  {
   id                 => 'cursor_rest',
   ir_node            => 'CURSOR_REST',
   diag_name          => 'cursor_rest',
   unresolved_pattern => qr/\bcursor_rest\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcursor_rest\s*\(\s*\)
    }{
     'do { my $__ls_cursor = pos $$STRING; defined($__ls_cursor) ? LinkedSpec::SourceLocation::Runtime::span_text($info, $STRING, $__ls_cursor, LinkedSpec::SourceLocation::Runtime::source_length($info, $STRING, "cursor_rest"), "cursor_rest") : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'cursor_rest_len',
   ir_node            => 'CURSOR_REST_LEN',
   diag_name          => 'cursor_rest_len',
   unresolved_pattern => qr/\bcursor_rest_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bcursor_rest_len\s*\(\s*\)
    }{
     'do { my $__ls_cursor = pos $$STRING; defined($__ls_cursor) ? LinkedSpec::SourceLocation::Runtime::span_length($info, $STRING, $__ls_cursor, LinkedSpec::SourceLocation::Runtime::source_length($info, $STRING, "cursor_rest_len"), "cursor_rest_len") : undef }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'input_slice',
   ir_node            => 'INPUT_SLICE_READ',
   diag_name          => 'input_slice',
   unresolved_pattern => qr/\binput_slice\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_method_value_expr};
    return $code unless ref($lower) eq 'CODE';
    $code =~ s/\b(?<expr>input_slice\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'input_text',
   ir_node            => 'INPUT_TEXT_READ',
   diag_name          => 'input_text',
   unresolved_pattern => qr/\binput_text\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\binput_text\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::source_text(\$info, \$STRING, "input_text") }/g;
    return $code
   },
  },
  {
   id                 => 'input_len',
   ir_node            => 'INPUT_LEN_READ',
   diag_name          => 'input_len',
   unresolved_pattern => qr/\binput_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\binput_len\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::source_length(\$info, \$STRING, "input_len") }/g;
    return $code
   },
  },
  {
   id                 => 'input_end_pos',
   ir_node            => 'INPUT_END_POS_READ',
   diag_name          => 'input_end_pos',
   unresolved_pattern => qr/\binput_end_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\binput_end_pos\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::position_offset(\$info, \$STRING, length(\$\$STRING), "input_end_pos") }/g;
    return $code
   },
  },
  {
   id                 => 'input_end_line',
   ir_node            => 'INPUT_END_LINE_READ',
   diag_name          => 'input_end_line',
   unresolved_pattern => qr/\binput_end_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\binput_end_line\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::position_line(\$info, \$STRING, length(\$\$STRING), "input_end_line") }/g;
    return $code
   },
  },
  {
   id                 => 'input_end_col',
   ir_node            => 'INPUT_END_COL_READ',
   diag_name          => 'input_end_col',
   unresolved_pattern => qr/\binput_end_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\binput_end_col\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::position_column(\$info, \$STRING, length(\$\$STRING), "input_end_col") }/g;
    return $code
   },
  },
  {
   id                 => 'entry_text',
   ir_node            => 'IMATCH_TEXT_READ',
   diag_name          => 'entry_text',
   unresolved_pattern => qr/\bentry_text\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_text\s*\(\s*\)/do { defined(\$IMATCH) ? LinkedSpec::SourceLocation::Runtime::span_text(\$info, \$STRING, \$IPOS - length(\$IMATCH), \$IPOS, "entry_text") : undef }/g;
    return $code
   },
  },
  {
   id                 => 'entry_group',
   ir_node            => 'IMATCH_GROUP_READ',
   diag_name          => 'entry_group',
   unresolved_pattern => qr/\bentry_group\s*\(\s*\d+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bentry_group\s*\(\s*(?<index>\d+)\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::capture_group_text(scalar(@IMATCH_LIST) > '.$+{index}.' ? $IMATCH_LIST['.$+{index}.'] : undef) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'entry_groups',
   ir_node            => 'IMATCH_GROUPS_READ',
   diag_name          => 'entry_groups',
   unresolved_pattern => qr/\bentry_groups\s*\(\s*\)/o,
  lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_groups\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::capture_group_list([\@IMATCH_LIST]) }/g;
    return $code
   },
  },
  {
   id                 => 'entry_named',
   ir_node            => 'IMATCH_NAMED_READ',
   diag_name          => 'entry_named',
   unresolved_pattern => qr/\bentry_named\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bentry_named\s*\(\s*(?<name>\w+)\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::capture_group_text(exists $IMATCH_HASH{\''.$+{name}.'\'} ? $IMATCH_HASH{\''.$+{name}.'\'} : undef) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'entry_has',
   ir_node            => 'IMATCH_NAMED_EXISTS',
   diag_name          => 'entry_has',
   unresolved_pattern => qr/\bentry_has\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bentry_has\s*\(\s*(?<name>\w+)\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::capture_group_exists(exists $IMATCH_HASH{\''.$+{name}.'\'}) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'entry_map',
   ir_node            => 'IMATCH_NAMED_MAP_READ',
   diag_name          => 'entry_map',
   unresolved_pattern => qr/\bentry_map\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_map\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::capture_group_map(+{\%IMATCH_HASH}) }/g;
    return $code
   },
  },
  {
   id                 => 'entry_named_map',
   ir_node            => 'IMATCH_NAMED_MAP_READ',
   diag_name          => 'entry_named_map',
   unresolved_pattern => qr/\bentry_named_map\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_named_map\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::capture_group_map(+{\%IMATCH_HASH}) }/g;
    return $code
   },
  },
  {
   id                 => 'entry_line',
   ir_node            => 'IMATCH_LINE_READ',
   diag_name          => 'entry_line',
   unresolved_pattern => qr/\bentry_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_line\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::span_start_line(\$info, \$STRING, \$IPOS - length(\$IMATCH), \$IPOS, "entry_line") }/g;
    return $code
   },
  },
  {
   id                 => 'entry_start_line',
   ir_node            => 'IMATCH_START_LINE_READ',
   diag_name          => 'entry_start_line',
   unresolved_pattern => qr/\bentry_start_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_start_line\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::span_start_line(\$info, \$STRING, \$IPOS - length(\$IMATCH), \$IPOS, "entry_start_line") }/g;
    return $code
   },
  },
  {
   id                 => 'entry_col',
   ir_node            => 'IMATCH_COL_READ',
   diag_name          => 'entry_col',
   unresolved_pattern => qr/\bentry_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_col\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::span_start_column(\$info, \$STRING, \$IPOS - length(\$IMATCH), \$IPOS, "entry_col") }/g;
    return $code
   },
  },
  {
   id                 => 'entry_start_col',
   ir_node            => 'IMATCH_START_COL_READ',
   diag_name          => 'entry_start_col',
   unresolved_pattern => qr/\bentry_start_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_start_col\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::span_start_column(\$info, \$STRING, \$IPOS - length(\$IMATCH), \$IPOS, "entry_start_col") }/g;
    return $code
   },
  },
  {
   id                 => 'entry_len',
   ir_node            => 'IMATCH_LEN_READ',
   diag_name          => 'entry_len',
   unresolved_pattern => qr/\bentry_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_len\s*\(\s*\)/do { defined(\$IMATCH) ? LinkedSpec::SourceLocation::Runtime::span_length(\$info, \$STRING, \$IPOS - length(\$IMATCH), \$IPOS, "entry_len") : length(\$IMATCH) }/g;
    return $code
   },
  },
  {
   id                 => 'entry_start_pos',
   ir_node            => 'IMATCH_START_POS_READ',
   diag_name          => 'entry_start_pos',
   unresolved_pattern => qr/\bentry_start_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_start_pos\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::span_start_offset(\$info, \$STRING, \$IPOS - length(\$IMATCH), \$IPOS, "entry_start_pos") }/g;
    return $code
   },
  },
  {
   id                 => 'entry_end_pos',
   ir_node            => 'IMATCH_END_POS_READ',
   diag_name          => 'entry_end_pos',
   unresolved_pattern => qr/\bentry_end_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_end_pos\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::position_offset(\$info, \$STRING, \$IPOS, "entry_end_pos") }/g;
    return $code
   },
  },
  {
   id                 => 'entry_end_line',
   ir_node            => 'IMATCH_END_LINE_READ',
   diag_name          => 'entry_end_line',
   unresolved_pattern => qr/\bentry_end_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_end_line\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::position_line(\$info, \$STRING, \$IPOS, "entry_end_line") }/g;
    return $code
   },
  },
  {
   id                 => 'entry_end_col',
   ir_node            => 'IMATCH_END_COL_READ',
   diag_name          => 'entry_end_col',
   unresolved_pattern => qr/\bentry_end_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bentry_end_col\s*\(\s*\)/do { my \$__ls_entry_end_col = LinkedSpec::SourceLocation::Runtime::position_column(\$info, \$STRING, \$IPOS, "entry_end_col"); defined(\$__ls_entry_end_col) ? \$__ls_entry_end_col : 0 }/g;
    return $code
   },
  },
  {
   id                 => 'match_start_pos',
   ir_node            => 'MATCH_START_POS_READ',
   diag_name          => 'match_start_pos',
   unresolved_pattern => qr/\bmatch_start_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_start_pos\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::span_start_offset(\$info, \$STRING, \$LSPOS - length(\$LMATCH), \$LSPOS, "match_start_pos") }/g;
    return $code
   },
  },
  {
   id                 => 'match_text',
   ir_node            => 'MATCH_TEXT_READ',
   diag_name          => 'match_text',
   unresolved_pattern => qr/\bmatch_text\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_text\s*\(\s*\)/do { defined(\$LMATCH) ? LinkedSpec::SourceLocation::Runtime::span_text(\$info, \$STRING, \$LSPOS - length(\$LMATCH), \$LSPOS, "match_text") : undef }/g;
    return $code
   },
  },
  {
   id                 => 'match_group',
   ir_node            => 'MATCH_GROUP_READ',
   diag_name          => 'match_group',
   unresolved_pattern => qr/\bmatch_group\s*\(\s*\d+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmatch_group\s*\(\s*(?<index>\d+)\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::capture_group_text(scalar(@LMATCH_LIST) > '.$+{index}.' ? $LMATCH_LIST['.$+{index}.'] : undef) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'match_groups',
   ir_node            => 'MATCH_GROUPS_READ',
   diag_name          => 'match_groups',
   unresolved_pattern => qr/\bmatch_groups\s*\(\s*\)/o,
  lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_groups\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::capture_group_list([\@LMATCH_LIST]) }/g;
    return $code
   },
  },
  {
   id                 => 'match_named',
   ir_node            => 'MATCH_NAMED_READ',
   diag_name          => 'match_named',
   unresolved_pattern => qr/\bmatch_named\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmatch_named\s*\(\s*(?<name>\w+)\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::capture_group_text(exists $LMATCH_HASH{\''.$+{name}.'\'} ? $LMATCH_HASH{\''.$+{name}.'\'} : undef) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'match_has',
   ir_node            => 'MATCH_NAMED_EXISTS',
   diag_name          => 'match_has',
   unresolved_pattern => qr/\bmatch_has\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s{
     \bmatch_has\s*\(\s*(?<name>\w+)\s*\)
    }{
     'do { LinkedSpec::SourceLocation::Runtime::capture_group_exists(exists $LMATCH_HASH{\''.$+{name}.'\'}) }'
    }gex;
    return $code
   },
  },
  {
   id                 => 'match_map',
   ir_node            => 'MATCH_NAMED_MAP_READ',
   diag_name          => 'match_map',
   unresolved_pattern => qr/\bmatch_map\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_map\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::capture_group_map(+{\%LMATCH_HASH}) }/g;
    return $code
   },
  },
  {
   id                 => 'match_named_map',
   ir_node            => 'MATCH_NAMED_MAP_READ',
   diag_name          => 'match_named_map',
   unresolved_pattern => qr/\bmatch_named_map\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_named_map\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::capture_group_map(+{\%LMATCH_HASH}) }/g;
    return $code
   },
  },
  {
   id                 => 'match_len',
   ir_node            => 'MATCH_LEN_READ',
   diag_name          => 'match_len',
   unresolved_pattern => qr/\bmatch_len\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_len\s*\(\s*\)/do { defined(\$LMATCH) ? LinkedSpec::SourceLocation::Runtime::span_length(\$info, \$STRING, \$LSPOS - length(\$LMATCH), \$LSPOS, "match_len") : length(\$LMATCH) }/g;
    return $code
   },
  },
  {
   id                 => 'match_end_pos',
   ir_node            => 'MATCH_END_POS_READ',
   diag_name          => 'match_end_pos',
   unresolved_pattern => qr/\bmatch_end_pos\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_end_pos\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::position_offset(\$info, \$STRING, \$LSPOS, "match_end_pos") }/g;
    return $code
   },
  },
  {
   id                 => 'match_end_line',
   ir_node            => 'MATCH_END_LINE_READ',
   diag_name          => 'match_end_line',
   unresolved_pattern => qr/\bmatch_end_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_end_line\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::position_line(\$info, \$STRING, \$LSPOS, "match_end_line") }/g;
    return $code
   },
  },
  {
   id                 => 'match_end_col',
   ir_node            => 'MATCH_END_COL_READ',
   diag_name          => 'match_end_col',
   unresolved_pattern => qr/\bmatch_end_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_end_col\s*\(\s*\)/do { my \$__ls_match_end_col = LinkedSpec::SourceLocation::Runtime::position_column(\$info, \$STRING, \$LSPOS, "match_end_col"); defined(\$__ls_match_end_col) ? \$__ls_match_end_col : 0 }/g;
    return $code
   },
  },
  {
   id                 => 'match_start_line',
   ir_node            => 'MATCH_START_LINE_READ',
   diag_name          => 'match_start_line',
   unresolved_pattern => qr/\bmatch_start_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_start_line\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::span_start_line(\$info, \$STRING, \$LSPOS - length(\$LMATCH), \$LSPOS, "match_start_line") }/g;
    return $code
   },
  },
  {
   id                 => 'match_line',
   ir_node            => 'MATCH_LINE_READ',
   diag_name          => 'match_line',
   unresolved_pattern => qr/\bmatch_line\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_line\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::span_start_line(\$info, \$STRING, \$LSPOS - length(\$LMATCH), \$LSPOS, "match_line") }/g;
    return $code
   },
  },
  {
   id                 => 'match_start_col',
   ir_node            => 'MATCH_START_COL_READ',
   diag_name          => 'match_start_col',
   unresolved_pattern => qr/\bmatch_start_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_start_col\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::span_start_column(\$info, \$STRING, \$LSPOS - length(\$LMATCH), \$LSPOS, "match_start_col") }/g;
    return $code
   },
  },
  {
   id                 => 'match_col',
   ir_node            => 'MATCH_COL_READ',
   diag_name          => 'match_col',
   unresolved_pattern => qr/\bmatch_col\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bmatch_col\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::span_start_column(\$info, \$STRING, \$LSPOS - length(\$LMATCH), \$LSPOS, "match_col") }/g;
    return $code
   },
  },
  {
   id                 => 'save_cursor',
   ir_node            => 'SAVE_CURSOR',
   diag_name          => 'save_cursor',
   unresolved_pattern => qr/\bsave_cursor\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bsave_cursor\s*\(\s*\)/do { LinkedSpec::SourceLocation::Runtime::cursor_checkpoint_compatibility(\$info, \$STRING, pos(\$\$STRING), "save_cursor") }/g;
    return $code
   },
  },
  {
   id                 => 'restore_cursor',
   ir_node            => 'RESTORE_CURSOR',
   diag_name          => 'restore_cursor',
   unresolved_pattern => qr/\brestore_cursor\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\brestore_cursor\s*\(\s*\)/do { my \$__ls_cursor_stack = ref(\$\$info{cursor_stack}) eq 'ARRAY' ? \$\$info{cursor_stack} : undef; if (\$__ls_cursor_stack && \@{\$__ls_cursor_stack}) { my \$__ls_saved_cursor = pop \@{\$__ls_cursor_stack}; LinkedSpec::SourceLocation::Runtime::cursor_state_write_compatibility(\$info, \$STRING, \$__ls_saved_cursor, "restore_cursor") if defined(\$__ls_saved_cursor); } undef }/g;
    return $code
   },
  },
  {
   id                 => 'rewind_entry_start',
   ir_node            => 'REWIND_ENTRY_START',
   diag_name          => 'rewind_entry_start',
   unresolved_pattern => qr/\brewind_entry_start\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\brewind_entry_start\s*\(\s*\)/LinkedSpec::SourceLocation::Runtime::cursor_state_write_compatibility(\$info, \$STRING, \$IPOS - length(\$IMATCH), "rewind_entry_start")/g;
    return $code
   },
  },
  {
   id                 => 'rewind_match_start',
   ir_node            => 'REWIND_MATCH_START',
   diag_name          => 'rewind_match_start',
   unresolved_pattern => qr/\brewind_match_start\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\brewind_match_start\s*\(\s*\)/LinkedSpec::SourceLocation::Runtime::cursor_state_write_compatibility(\$info, \$STRING, \$LSPOS - length(\$LMATCH), "rewind_match_start")/g;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_passthrough_ir_contracts
# Purpose : Canonical IR-only contracts that do not rewrite source text.
#------------------------------------------------------------------------------
sub _build_passthrough_ir_contracts {
 return [
  { id => 'exit_bare',                       ir_node => 'EXIT',           diag_name => 'exit',              compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'linecount_prefix_newline_matches',ir_node => 'LINE_COUNT',     diag_name => 'line_count',        compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'print_capture_substr',            ir_node => 'PRINT',          diag_name => 'print',             compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'my_declare_bare',                 ir_node => 'DECLARE',        diag_name => 'raw_lexical_binding', compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'assign_match_my',                 ir_node => 'ASSIGN',         diag_name => 'raw_assignment',    compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'destructure_imatch_list_my',      ir_node => 'ASSIGN',         diag_name => 'raw_assignment',    compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'regex_subst_assignment',          ir_node => 'REGEX_SUBST',    diag_name => 'substr',            compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'next_bare',                       ir_node => 'NEXT',           diag_name => 'next',              compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'ref_field_assign',                ir_node => 'ASSIGN',         diag_name => 'raw_assignment',    compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'position_tracking',               ir_node => 'POSITION_TRACK', diag_name => 'position_tracking', compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'print_foreach_iterable',          ir_node => 'PRINT',          diag_name => 'print',             compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
  { id => 'split_trim_filter_assignment',    ir_node => 'ASSIGN',         diag_name => 'raw_assignment',    compatibility_surface => 1, unresolved_pattern => undef, lower => sub { my ($code) = @_; return $code } },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_assignment_and_regex_contracts
# Purpose : Contracts that lower assignment and substitution helper methods.
#------------------------------------------------------------------------------
sub _build_assignment_and_regex_contracts {
 my ($d) = @_;
 return [
  {
   id                 => 'push',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   # SPEC-FORMAT-TERSE.1.3.2 — `push(target, value)` is the terse explicit-value
   # append spelling only for shapes that do not collide with child-call
   # `push(Rule[, target[, index]])`; bare child-call forms keep precedence.
   unresolved_pattern => qr/\bpush\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_push_statement};
    $code =~ s/\b(?<expr>push\s*(?<PAREN>\((?:[^\(\)\"\\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'scalar_assignment_operator',
   ir_node            => 'ASSIGN',
   diag_name          => 'scalar_assignment_operator',
   unresolved_pattern => qr/^\s*[A-Za-z_][A-Za-z0-9_]*\s*=(?!=|>)/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_scalar_assignment_operator_statement};
    return $lower->($code) || $code
   },
  },
  {
   id                 => 'array_append_operator',
   ir_node            => 'PUSH',
   diag_name          => 'array_append_operator',
   unresolved_pattern => qr/^\s*[A-Za-z_][A-Za-z0-9_]*\s*\+=/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_append_operator_statement};
    return $lower->($code) || $code
   },
  },
  {
   id                 => 'array_end_mutation_method',
   ir_node            => 'ARRAY_MUTATE',
   diag_name          => 'array_end_mutation_method',
   unresolved_pattern => qr/^\s*(?:[A-Za-z_][A-Za-z0-9_]*|array\s*\().*\.\s*(?:push_front|push_back|pop_front|pop_back)\s*\(/so,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_end_mutation_method_statement};
    return $lower->($code) || $code
   },
  },
  {
   id                 => 'hash_index_assignment_operator',
   ir_node            => 'ASSIGN',
   diag_name          => 'hash_index_assignment_operator',
   unresolved_pattern => qr/^\s*[A-Za-z_][A-Za-z0-9_]*\s*\[.*\]\s*=(?!=|>)/so,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_hash_index_assignment_operator_statement};
    return $lower->($code) || $code
   },
  },
  {
   id                 => 'set_value',
   ir_node            => 'ASSIGN',
   diag_name          => 'set',
   unresolved_pattern => qr/\bset\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_assign_method_statement};
    $code =~ s/\b(?<expr>set\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))(?!\s*\.)/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'set_key_statement',
   ir_node            => 'ASSIGN',
   diag_name          => 'set_key',
   unresolved_pattern => qr/^\s*set_key\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_set_key_statement};
    return $lower->($code) || $code
   },
  },
  {
   id                 => 'regex_subst',
   ir_node            => 'REGEX_SUBST',
   diag_name          => 'substr',
   unresolved_pattern => qr/\b(?:substr|regex_subst)\s*\(\s*(?:(?:\w+)\s*,\s*)?(?::\w+|\w+)\s*,/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_regex_subst_statement};
    $code =~ s/\b(?:substr|regex_subst)\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<target>:\w+|\w+)\s*,\s*(?<pattern>(?:\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|\/(?:\\.|[^\/])*\/))\s*,\s*(?<replacement>(?:\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|\/\/|\/(?:\\.|[^\/])*\/))\s*,\s*(?<flags>\w*)\s*\)/$lower->($+{target}, $+{pattern}, $+{replacement}, $+{flags}) || $&/ge;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_array_pipeline_contracts
# Purpose : Contracts for array pipeline helper lowering.
#------------------------------------------------------------------------------
sub _build_array_pipeline_contracts {
 my ($d) = @_;
 return [
  {
   id                 => 'split_array',
   ir_node            => 'SPLIT',
   diag_name          => 'split',
   unresolved_pattern => qr/\bsplit\s*\(\s*(?:(?:\w+)\s*,\s*)?(?:array\s*\(\s*\w+\s*\)|\w+)\s*,\s*(?::\w+|\w+)/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>split\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'split_each',
   ir_node            => 'SPLIT_EACH',
   diag_name          => 'split_each',
   unresolved_pattern => qr/\bsplit_each\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>split_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'trim_each',
   ir_node            => 'TRIM_EACH',
   diag_name          => 'trim_each',
   unresolved_pattern => qr/\btrim_each\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>trim_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'filter_nonempty',
   ir_node            => 'FILTER_NONEMPTY',
   diag_name          => 'filter_nonempty',
   unresolved_pattern => qr/\bfilter_nonempty\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>filter_nonempty\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'lowercase_each',
   ir_node            => 'MAP_LOWERCASE',
   diag_name          => 'lowercase_each',
   unresolved_pattern => qr/\blowercase_each\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>lowercase_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'uppercase_each',
   ir_node            => 'MAP_UPPERCASE',
   diag_name          => 'uppercase_each',
   unresolved_pattern => qr/\buppercase_each\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>uppercase_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'uniq_array',
   ir_node            => 'UNIQ',
   diag_name          => 'uniq',
   unresolved_pattern => qr/\buniq\s*\(/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>uniq\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'filter_match',
   ir_node            => 'FILTER_MATCH',
   diag_name          => 'filter_match',
   unresolved_pattern => qr/\bfilter_match\s*\(/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_array_pipeline_expr};
    $code =~ s/\b(?<expr>filter_match\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}) || $&/ge;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_dropped_value_contracts
# Purpose : Contracts for supported value expressions used as standalone
#           statements. Their values are intentionally discarded.
#------------------------------------------------------------------------------
sub _build_dropped_value_contracts {
 my ($d) = @_;
 my $value_call_re = qr/(?:and|or|not|trim|lowercase|uppercase|length|substr|replace_substr|rm_prefix|rm_suffix|cat|str_eq|str_ne|str_gt|str_ge|str_lt|str_le|starts_with|ends_with|contains_substr|matches|coalesce|coalesce_nonempty|num_abs|num_floor|num_ceil|num_round|num_add|num_sub|num_mul|num_div|num_mod|num_clamp|num_min|num_max|num_eq|num_ne|num_gt|num_ge|num_lt|num_le|abs|floor|ceil|round|sum|avg|median|range|add|sub|mul|div|mod|clamp|min|max|eq|ne|gt|ge|lt|le|array|hash|copy|flat|flat_array|flat_hash|count|first|last|drop_front|take|slice|take_last|drop_back|concat_arrays|split|split_tagged_records|sorted|reversed|contains|index_of|split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match|count_keys|sorted_keys|sorted_values|has_key|merge_hash|rename_key|drop_keys|pick_keys|join_values|entry_groups|match_groups|entry_map|entry_named_map|match_map|match_named_map|num_sum|num_avg|num_median|num_range)/;
 my $receiver_method_re = qr/(?:trim|lowercase|uppercase|length|sorted|reversed|count|first|last|is_empty|is_nonempty|flat_hash|count_keys|sorted_keys|sorted_values|abs|floor|ceil|round)/;
 my $literal_receiver_re = qr/(?:"(?:\\.|[^\"])*"|'(?:\\.|[^'])*'|-?\d+(?:\.\d+)?|[A-Za-z_][A-Za-z0-9_]*(?!\s*\())/;
 my $value_drop_statement_re = qr/^\s*(?:(?:$value_call_re)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))|(?:$literal_receiver_re)\s*\.\s*(?:$receiver_method_re)\s*\(\s*\))\s*\z/so;
 return [
  {
   id                 => 'value_drop_statement',
   ir_node            => 'VALUE_DROP',
   diag_name          => 'value_drop',
   unresolved_pattern => $value_drop_statement_re,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_dropped_value_statement};
    return $lower->($code) || $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_flow_control_contracts
# Purpose : Contracts that lower structured flow-control helper forms.
#------------------------------------------------------------------------------
sub _build_flow_control_contracts {
 my ($d) = @_;
 return [
  {
   id                 => 'if_flow',
   ir_node            => 'IF',
   diag_name          => 'if',
   unresolved_pattern => qr/\b(?:if|i|when)\((?<PAREN>(?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|\((?&PAREN)*\))*)\)(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_if_flow_statement};
    $code =~ s/\b(?<expr>(?:if|i|when)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?)/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'elseif_flow',
   ir_node            => 'ELIF',
   diag_name          => 'elseif',
   unresolved_pattern => qr/\b(?:elif|elseif)\((?<PAREN>(?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|\((?&PAREN)*\))*)\)(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_elseif_flow_statement};
    $code =~ s/\b(?<expr>(?:elif|elseif)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?)/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'else_flow',
   ir_node            => 'ELSE',
   diag_name          => 'else',
   unresolved_pattern => qr/(?:^\s*(?:else|otherwise)\b\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?\s*$|^\s*(?:else|otherwise)\s*$)/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_else_flow_statement};
    $code =~ s/^\s*(?<expr>(?:else|otherwise)\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?)\s*$/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'endif_flow',
   ir_node            => 'ENDIF',
   diag_name          => 'endif',
   unresolved_pattern => qr/^\s*endif\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?\s*$/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_endif_flow_statement};
    $code =~ s/^\s*(?<expr>endif\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?)\s*$/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'while_flow',
   ir_node            => 'WHILE',
   diag_name          => 'while',
   unresolved_pattern => qr/\bwhile\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_while_flow_statement};
    $code =~ s/^\s*(?<expr>while\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?)\s*$/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'switch_flow',
   ir_node            => 'SWITCH',
   diag_name          => 'switch',
   unresolved_pattern => qr/\bswitch\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_switch_flow_statement};
    $code =~ s/^\s*(?<expr>switch\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?)\s*$/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'case_flow',
   ir_node            => 'CASE',
   diag_name          => 'case',
   unresolved_pattern => qr/\bcase\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_case_flow_statement};
    $code =~ s/\b(?<expr>case\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?)/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'default_flow',
   ir_node            => 'DEFAULT',
   diag_name          => 'default',
   unresolved_pattern => qr/(?:^\s*default\b\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?\s*$|^\s*default\s*$)/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_default_flow_statement};
    $code =~ s/^\s*(?<expr>default\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?(?:\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?)\s*$/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'endcase_flow',
   ir_node            => 'ENDCASE',
   diag_name          => 'endcase',
   unresolved_pattern => qr/^\s*endcase\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?\s*$/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_endcase_flow_statement};
    $code =~ s/^\s*(?<expr>endcase\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?)\s*$/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'endswitch_flow',
   ir_node            => 'ENDSWITCH',
   diag_name          => 'endswitch',
   unresolved_pattern => qr/^\s*endswitch\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?\s*$/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_endswitch_flow_statement};
    $code =~ s/^\s*(?<expr>endswitch\b(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?)\s*$/$lower->($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _build_emit_and_declare_contracts
# Purpose : Contracts for output statements and declaration lowering.
#------------------------------------------------------------------------------
sub _build_emit_and_declare_contracts {
 my ($label, $d) = @_;
 return [
  {
   id                 => 'say_stmt',
   ir_node            => 'SAY',
   diag_name          => 'say',
   unresolved_pattern => qr/\bsay\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_say_statement};
    $code =~ s/\b(?<expr>say\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}, $label) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'print_each',
   ir_node            => 'PRINT',
   diag_name          => 'print_each',
   unresolved_pattern => qr/\bprint_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_print_each_statement};
    $code =~ s/\b(?<expr>print_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}, $label) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'print_stmt',
   ir_node            => 'PRINT',
   diag_name          => 'print',
   unresolved_pattern => qr/\bprint\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
    my $lower = $d->{lower_print_statement};
    $code =~ s/\b(?<expr>print\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}, $label) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'exit_now',
   ir_node            => 'EXIT',
   diag_name          => 'exit_now',
   unresolved_pattern => qr/\bexit_now\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code) = @_;
    my $lower = $d->{lower_exit_now_statement};
    $code =~ s/\b(?<expr>exit_now\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/$lower->($+{expr}, $label) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'next_stmt',
   ir_node            => 'NEXT',
   diag_name          => 'next',
   unresolved_pattern => qr/\bnext\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\bnext\s*\(\s*\)/next/g;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: build_action_lowering_contracts
# Purpose : Build all lowering contracts by composing responsibility-specific
#           contract groups.
#------------------------------------------------------------------------------
sub build_action_lowering_contracts {
 my ($label, $deps) = @_;
 my $d = _require_lowering_deps($deps);
 return [
  @{_build_call_and_dispatch_contracts($label, $deps)},
  @{_build_recursive_observation_contracts($label)},
  @{_build_inter_match_gap_contracts($label)},
  @{_build_recognition_transaction_contracts($label)},
  @{LinkedSpec::ActionIR::StagedParseJob::build_contracts($label)},
  @{LinkedSpec::ActionIR::ProgressiveSpanDispatch::build_contracts($label)},
  @{_build_return_contracts($label, $d)},
  @{_build_capture_and_cursor_contracts($label, $d)},
  @{_build_passthrough_ir_contracts()},
  @{_build_assignment_and_regex_contracts($d)},
  @{_build_array_pipeline_contracts($d)},
  @{_build_dropped_value_contracts($d)},
  @{_build_flow_control_contracts($d)},
  @{_build_emit_and_declare_contracts($label, $d)},
 ]
}

1;
