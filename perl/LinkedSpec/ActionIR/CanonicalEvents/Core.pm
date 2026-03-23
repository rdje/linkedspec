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
 capture_from_mark                => 'CAPTURE_FROM_MARK',
 capture_take_from_mark           => 'CAPTURE_TAKE_FROM_MARK',
 capture_between_marks            => 'CAPTURE_BETWEEN_MARKS',
 mark_here                        => 'MARK_HERE',
 mark_match_start                 => 'MARK_MATCH_START',
 clear_mark                       => 'CLEAR_MARK',
 mark_exists                      => 'MARK_EXISTS',
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
