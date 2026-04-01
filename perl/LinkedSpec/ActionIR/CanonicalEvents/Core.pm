#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::CanonicalEvents::Core
# Purpose: Canonical ActionIR event-kind mapping shared by the direct
#          contract-event normalization path.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::CanonicalEvents::Core;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $canonical_events_dir = File::Basename::dirname($module_dir);
 my $action_ir_dir = File::Basename::dirname($canonical_events_dir);
 my $linked_spec_dir = File::Basename::dirname($action_ir_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

my %DIRECT_KIND_BY_CONTRACT_ID = (
 call                             => 'CALL',
 return_bare                      => 'RETURN',
 exit_bare                        => 'EXIT',
 linecount_prefix_newline_matches => 'LINE_COUNT',
 print_capture_substr             => 'PRINT',
 assign_match_my                  => 'ASSIGN',
 destructure_imatch_list_my       => 'ASSIGN',
 regex_subst_assignment           => 'REGEX_SUBST',
 next_bare                        => 'NEXT',
 ref_field_assign                 => 'ASSIGN',
 position_tracking                => 'POSITION_TRACK',
 print_foreach_iterable           => 'PRINT',
 assign_value                     => 'ASSIGN',
 regex_subst                      => 'REGEX_SUBST',
 return_a                         => 'RETURN_A',
 return_general                   => 'RETURN',
 return                           => 'RETURN',
 return_ma                        => 'RETURN_MA',
 return_m                         => 'RETURN_M',
 capture_macro                    => 'CAPTURE_MACRO',
 capture                          => 'CAPTURE',
 capture_slice                    => 'CAPTURE_SLICE',
 capture_slice_len                => 'CAPTURE_SLICE_LEN',
 capture_slice_until_cursor       => 'CAPTURE_SLICE_UNTIL_CURSOR',
 capture_slice_until_cursor_len   => 'CAPTURE_SLICE_UNTIL_CURSOR_LEN',
 capture_take_until_cursor        => 'CAPTURE_SLICE_TAKE_UNTIL_CURSOR',
 capture_take_until_cursor_len    => 'CAPTURE_SLICE_TAKE_UNTIL_CURSOR_LEN',
 capture_slice_pos                => 'CAPTURE_SLICE_POS_READ',
 capture_slice_line               => 'CAPTURE_SLICE_LINE_READ',
 capture_slice_col                => 'CAPTURE_SLICE_COL_READ',
 capture_slice_length             => 'CAPTURE_SLICE_LEN',
 start_capture_slice              => 'CAPTURE_SLICE_START',
 start_capture_slice_from_mark    => 'CAPTURE_SLICE_START_FROM_MARK',
 capture_slice_here               => 'CAPTURE_SLICE_START',
 capture_rest                     => 'CAPTURE_REST',
 capture_rest_len                 => 'CAPTURE_REST_LEN',
 capture_rest_length              => 'CAPTURE_REST_LEN',
 capture_take_slice               => 'CAPTURE_SLICE_TAKE',
 capture_from_rule_start          => 'CAPTURE_SLICE',
 capture_len_from_rule_start      => 'CAPTURE_SLICE_LEN',
 capture_from_mark                => 'CAPTURE_FROM_MARK',
 capture_len_from_mark            => 'CAPTURE_LEN_FROM_MARK',
 capture_take_from_mark           => 'CAPTURE_TAKE_FROM_MARK',
 capture_rest_from_mark           => 'CAPTURE_REST_FROM_MARK',
 capture_rest_len_from_mark       => 'CAPTURE_REST_LEN_FROM_MARK',
 capture_until_cursor_from_mark   => 'CAPTURE_UNTIL_CURSOR_FROM_MARK',
 capture_until_cursor_len_from_mark => 'CAPTURE_UNTIL_CURSOR_LEN_FROM_MARK',
 capture_take_until_cursor_from_mark => 'CAPTURE_TAKE_UNTIL_CURSOR_FROM_MARK',
 capture_take_until_cursor_len_from_mark => 'CAPTURE_TAKE_UNTIL_CURSOR_LEN_FROM_MARK',
 capture_between_marks            => 'CAPTURE_BETWEEN_MARKS',
 capture_len_between_marks        => 'CAPTURE_LEN_BETWEEN_MARKS',
 capture_take_between_marks       => 'CAPTURE_TAKE_BETWEEN_MARKS',
 mark_here                        => 'MARK_HERE',
 mark_entry_start                 => 'MARK_ENTRY_START',
 mark_entry_end                   => 'MARK_ENTRY_END',
 mark_match_start                 => 'MARK_MATCH_START',
 mark_match_end                   => 'MARK_MATCH_END',
 mark_copy                        => 'MARK_COPY',
 mark_capture_slice               => 'MARK_CAPTURE_SLICE',
 clear_mark                       => 'CLEAR_MARK',
 mark_exists                      => 'MARK_EXISTS',
 mark_pos                         => 'MARK_POS_READ',
 mark_line                        => 'MARK_LINE_READ',
 mark_col                         => 'MARK_COL_READ',
 cursor_pos                       => 'CURSOR_POS_READ',
 cursor_line                      => 'CURSOR_LINE_READ',
 cursor_col                       => 'CURSOR_COL_READ',
 cursor_rest                      => 'CURSOR_REST',
 cursor_rest_len                  => 'CURSOR_REST_LEN',
 entry_text                       => 'IMATCH_TEXT_READ',
 entry_group                      => 'IMATCH_GROUP_READ',
 entry_groups                     => 'IMATCH_GROUPS_READ',
  entry_named                      => 'IMATCH_NAMED_READ',
 entry_has                        => 'IMATCH_NAMED_EXISTS',
 entry_map                        => 'IMATCH_NAMED_MAP_READ',
 entry_named_map                  => 'IMATCH_NAMED_MAP_READ',
 entry_line                       => 'IMATCH_LINE_READ',
 entry_start_line                 => 'IMATCH_START_LINE_READ',
 entry_col                        => 'IMATCH_COL_READ',
 entry_start_col                  => 'IMATCH_START_COL_READ',
 entry_len                        => 'IMATCH_LEN_READ',
 entry_start_pos                  => 'IMATCH_START_POS_READ',
 entry_end_pos                    => 'IMATCH_END_POS_READ',
 entry_end_line                   => 'IMATCH_END_LINE_READ',
 entry_end_col                    => 'IMATCH_END_COL_READ',
 match_start_line                 => 'MATCH_START_LINE_READ',
 match_line                       => 'MATCH_LINE_READ',
 match_start_col                  => 'MATCH_START_COL_READ',
 match_col                        => 'MATCH_COL_READ',
 match_text                       => 'MATCH_TEXT_READ',
 match_group                      => 'MATCH_GROUP_READ',
 match_groups                     => 'MATCH_GROUPS_READ',
 match_named                      => 'MATCH_NAMED_READ',
 match_has                        => 'MATCH_NAMED_EXISTS',
 match_map                        => 'MATCH_NAMED_MAP_READ',
 match_named_map                  => 'MATCH_NAMED_MAP_READ',
 match_len                        => 'MATCH_LEN_READ',
 match_start_pos                  => 'MATCH_START_POS_READ',
 match_end_pos                    => 'MATCH_END_POS_READ',
 match_end_line                   => 'MATCH_END_LINE_READ',
 match_end_col                    => 'MATCH_END_COL_READ',
 if_flow                          => 'IF',
 elseif_flow                      => 'ELIF',
 else_flow                        => 'ELSE',
 endif_flow                       => 'ENDIF',
 switch_flow                      => 'SWITCH',
 case_flow                        => 'CASE',
 default_flow                     => 'DEFAULT',
 endcase_flow                     => 'ENDCASE',
 endswitch_flow                   => 'ENDSWITCH',
 say_stmt                         => 'SAY',
 print_stmt                       => 'PRINT',
);

sub _event_args_hash {
 my ($event) = @_;
 return %{(ref($event->{args}) eq 'HASH') ? $event->{args} : {}}
}

sub _kind_override_for_contract_id {
 my ($contract_id) = @_;
 return $DIRECT_KIND_BY_CONTRACT_ID{$contract_id} if exists $DIRECT_KIND_BY_CONTRACT_ID{$contract_id};
 return 'CALL'      if $contract_id eq 'return_call';
 return 'RETURN'    if $contract_id eq 'return_imatch' || $contract_id eq 'return_array';
 return 'DECLARE'   if $contract_id eq 'declare_typed' || $contract_id eq 'declare_alias';
 return 'PUSH'      if $contract_id eq 'push_single_arg' || $contract_id eq 'push_target_arg' || $contract_id eq 'push_scope_target_arg';
 return 'CAPTURE_IF' if $contract_id eq 'capture_if' || $contract_id eq 'capture_if_macro';
 return 'IBACKTRACK' if $contract_id eq 'ibacktrack' || $contract_id eq 'ibacktrack_macro';
 return 'BACKTRACK'  if $contract_id eq 'backtrack' || $contract_id eq 'backtrack_macro';
 return undef
}

sub _canonical_kind {
 my ($contract_id, $ir_node) = @_;
 my $kind = defined($ir_node) && length($ir_node) ? $ir_node : 'HELPER';
 my $override = _kind_override_for_contract_id($contract_id);
 return defined($override) ? $override : $kind
}

sub _normalize_canonical_args {
 my ($contract_id, $label, $args_ref) = @_;
 my %args = %{(ref($args_ref) eq 'HASH') ? $args_ref : {}};

 if ($contract_id eq 'return_call') {
  $args{context} = 'return';
 }
 elsif ($contract_id eq 'push_single_arg') {
  $args{target} = $label unless defined $args{target};
  $args{target_mode} = 'implicit_current_label';
 }
 elsif ($contract_id eq 'push_target_arg' || $contract_id eq 'push_scope_target_arg') {
  $args{target_mode} = 'explicit';
 }
 elsif ($contract_id eq 'return_undef') {
  $args{value} = 'undef';
 }

 return \%args
}

sub canonicalize_helper_action_ir_event {
 my ($label, $event) = @_;
 my $contract_id = $event->{contract_id} // '';
 my $ir_node = $event->{ir_node};
 my %base_args = _event_args_hash($event);

 return {
  kind        => _canonical_kind($contract_id, $ir_node),
  source      => 'helper_contract',
  contract_id => $contract_id,
  raw         => $event->{raw},
  args        => _normalize_canonical_args($contract_id, $label, \%base_args),
 }
}

1;
