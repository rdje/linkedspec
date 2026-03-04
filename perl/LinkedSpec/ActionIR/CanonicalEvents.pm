package LinkedSpec::ActionIR::CanonicalEvents;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ActionIR::CanonicalEvents::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

sub _canonicalize_helper_action_ir_event {
 my ($label, $event, $deps) = @_;

 my $contract_id = $event->{contract_id} // '';
 my $ir_node = $event->{ir_node} // 'HELPER';
 my %args = %{(ref($event->{args}) eq 'HASH') ? $event->{args} : {}};

 my $kind = $ir_node;
 if ($contract_id eq 'call') {
  $kind = 'CALL';
 }
 elsif ($contract_id eq 'return_call') {
  $kind = 'CALL';
  $args{context} = 'return';
 }
 elsif ($contract_id eq 'return_bare') {
  $kind = 'RETURN';
 }
 elsif ($contract_id eq 'exit_bare') {
  $kind = 'EXIT';
 }
 elsif ($contract_id eq 'linecount_prefix_newline_matches') {
  $kind = 'LINE_COUNT';
 }
 elsif ($contract_id eq 'print_capture_substr') {
  $kind = 'PRINT';
 }
 elsif ($contract_id eq 'assign_match_my') {
  $kind = 'ASSIGN';
 }
 elsif ($contract_id eq 'destructure_imatch_list_my') {
  $kind = 'ASSIGN';
 }
 elsif ($contract_id eq 'regex_subst_assignment') {
  $kind = 'REGEX_SUBST';
 }
 elsif ($contract_id eq 'next_bare') {
  $kind = 'NEXT';
 }
 elsif ($contract_id eq 'ref_field_assign') {
  $kind = 'ASSIGN';
 }
 elsif ($contract_id eq 'position_tracking') {
  $kind = 'POSITION_TRACK';
 }
 elsif ($contract_id eq 'print_foreach_iterable') {
  $kind = 'PRINT';
 }
 elsif ($contract_id eq 'return_imatch' || $contract_id eq 'return_array') {
  $kind = 'RETURN';
 }
 elsif ($contract_id eq 'assign_value') {
  $kind = 'ASSIGN';
 }
 elsif ($contract_id eq 'regex_subst') {
  $kind = 'REGEX_SUBST';
 }
 elsif ($contract_id eq 'declare_typed' || $contract_id eq 'declare_alias') {
  $kind = 'DECLARE';
 }
 elsif ($contract_id eq 'push_single_arg') {
  $kind = 'PUSH';
  $args{target} = $label unless defined $args{target};
  $args{target_mode} = 'implicit_current_label';
 }
 elsif ($contract_id eq 'push_target_arg') {
  $kind = 'PUSH';
  $args{target_mode} = 'explicit';
 }
 elsif ($contract_id eq 'push_scope_target_arg') {
  $kind = 'PUSH';
  $args{target_mode} = 'explicit';
 }
 elsif ($contract_id eq 'return_a') {
  $kind = 'RETURN_A';
 }
 elsif ($contract_id eq 'return_general') {
  $kind = 'RETURN';
 }
 elsif ($contract_id eq 'return') {
  $kind = 'RETURN';
 }
 elsif ($contract_id eq 'return_ma') {
  $kind = 'RETURN_MA';
 }
 elsif ($contract_id eq 'return_m') {
  $kind = 'RETURN_M';
 }
 elsif ($contract_id eq 'capture_macro') {
  $kind = 'CAPTURE_MACRO';
 }
 elsif ($contract_id eq 'capture') {
  $kind = 'CAPTURE';
 }
 elsif ($contract_id eq 'capture_if' || $contract_id eq 'capture_if_macro') {
  $kind = 'CAPTURE_IF';
 }
 elsif ($contract_id eq 'ibacktrack' || $contract_id eq 'ibacktrack_macro') {
  $kind = 'IBACKTRACK';
 }
 elsif ($contract_id eq 'backtrack' || $contract_id eq 'backtrack_macro') {
  $kind = 'BACKTRACK';
 }
 elsif ($contract_id eq 'if_flow') {
  $kind = 'IF';
 }
 elsif ($contract_id eq 'elseif_flow') {
  $kind = 'ELIF';
 }
 elsif ($contract_id eq 'else_flow') {
  $kind = 'ELSE';
 }
 elsif ($contract_id eq 'endif_flow') {
  $kind = 'ENDIF';
 }
 elsif ($contract_id eq 'switch_flow') {
  $kind = 'SWITCH';
 }
 elsif ($contract_id eq 'case_flow') {
  $kind = 'CASE';
 }
 elsif ($contract_id eq 'default_flow') {
  $kind = 'DEFAULT';
 }
 elsif ($contract_id eq 'endcase_flow') {
  $kind = 'ENDCASE';
 }
 elsif ($contract_id eq 'endswitch_flow') {
  $kind = 'ENDSWITCH';
 }
 elsif ($contract_id eq 'say_stmt') {
  $kind = 'SAY';
 }
 elsif ($contract_id eq 'print_stmt') {
  $kind = 'PRINT';
 }
 elsif ($contract_id eq 'return_undef') {
  $kind = 'RETURN';
  $args{value} = 'undef';
 }

 return {
  kind        => $kind,
  source      => 'helper_contract',
  contract_id => $contract_id,
  raw         => $event->{raw},
  args        => \%args,
 }
}

sub _build_canonical_action_ir_events {
 my ($label, $code, $helper_events, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $split_action_ir_statements = _require_dep($deps, 'split_action_ir_statements');

 my %helper_event_queue;
 foreach my $helper_event (@$helper_events) {
  my $raw_key = $trim_action_ir_value->($helper_event->{raw});
  next unless defined($raw_key) && length($raw_key);
  my $canonical_event = _canonicalize_helper_action_ir_event($label, $helper_event, $deps);
  push @{$helper_event_queue{$raw_key}}, $canonical_event;
 }

 my @canonical_events;
 my $fallback_count = 0;
 foreach my $statement (@{$split_action_ir_statements->($code)}) {
  if (exists $helper_event_queue{$statement} && @{$helper_event_queue{$statement}}) {
   push @canonical_events, shift @{$helper_event_queue{$statement}};
  } else {
   push @canonical_events, {
    kind        => 'RAW_PERL',
    source      => 'fallback_non_helper_statement',
    contract_id => undef,
    raw         => $statement,
    args        => {code => $statement},
   };
   ++$fallback_count;
  }
 }

 foreach my $raw_key (keys %helper_event_queue) {
  while (@{$helper_event_queue{$raw_key}}) {
   my $event = shift @{$helper_event_queue{$raw_key}};
   $event->{source} = 'unmatched_helper_scan_event';
   push @canonical_events, $event;
  }
 }

 my %hits;
 my $count = 0;
 foreach my $event (@canonical_events) {
  my $kind = $event->{kind} // 'UNKNOWN';
  $hits{$kind} += 1;
  ++$count;
 }

 return {
  canonical_action_ir_count => $count,
  canonical_action_ir_hits  => \%hits,
  canonical_action_ir_nodes => [sort keys %hits],
  canonical_action_ir_events => \@canonical_events,
  canonical_action_ir_fallback_count => $fallback_count,
 }
}

1;
