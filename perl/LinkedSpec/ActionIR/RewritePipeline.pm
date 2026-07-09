#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::RewritePipeline
# Purpose: Canonical ActionIR rewrite owner for dependency assembly and
#          statement-level lowering orchestration.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::RewritePipeline;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();
use LinkedSpec::ActionIR::Trace ();

sub _retired_colon_scalar_slot_diagnostic_expr {
 return 'do { my $__ls_actionir_unsupported_helper = "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read"; undef }'
}

sub _rewrite_exact_retired_colon_scalar_slot {
 my ($code) = @_;
 return undef unless defined $code;
 my $trimmed = $code;
 $trimmed =~ s/^\s+//;
 $trimmed =~ s/\s+\z//;
 return undef unless $trimmed =~ /^:[A-Za-z_][A-Za-z0-9_]*$/o;
 return _retired_colon_scalar_slot_diagnostic_expr()
}

sub _event_continues_implicit_if_flow {
 my ($event) = @_;
 my $contract_id = $event->{contract_id} // '';
 return ($contract_id eq 'elseif_flow' || $contract_id eq 'else_flow') ? 1 : 0
}

sub _flush_implicit_if_closures {
 my ($ctx) = @_;
 my $if_stack = $ctx->{if_stack} || [];
 my @closures;
 while (@$if_stack && $if_stack->[-1]{implicit_close}) {
  pop @$if_stack;
  push @closures, '}';
 }
 return join(' ', @closures)
}

sub _insert_pending_implicit_if_closures_before_stmt {
 my ($rewritten_ref, $ctx, $source_stmt, $event) = @_;
 return unless @{$ctx->{if_stack} || []};
 if (_event_continues_implicit_if_flow($event)) {
  LinkedSpec::ActionIR::Trace::decision(
   owner => 'rewrite_pipeline',
   phase => 'implicit_if',
   label => $ctx->{trace_label},
   decision => 'continues_implicit_if_flow',
   taken => 1,
   context => {
    contract_id => ref($event) eq 'HASH' ? ($event->{contract_id} // '') : '',
    source_stmt => $source_stmt,
   },
  );
  return;
 }

 my $closures = _flush_implicit_if_closures($ctx);
 return unless defined($closures) && length($closures);
 my $closure_count = () = ($closures =~ /\}/g);
 LinkedSpec::ActionIR::Trace::decision(
  owner => 'rewrite_pipeline',
  phase => 'implicit_if',
  label => $ctx->{trace_label},
  decision => 'closure_inserted_before_statement',
  taken => 1,
  context => {
   closure_count => $closure_count,
   source_stmt => $source_stmt,
  },
 );

 my $pos = index($$rewritten_ref, $source_stmt);
 if ($pos >= 0) {
  substr($$rewritten_ref, $pos, 0, $closures.' ');
  return;
 }

 $$rewritten_ref .= ' '.$closures;
}

sub _separator_was_implicit_newline {
 my ($separator) = @_;
 return 0 unless defined($separator) && length($separator);
 return 0 if $separator =~ /;/o;
 return ($separator =~ /[\r\n]/o) ? 1 : 0
}

sub _lowered_statement_needs_terminator {
 my ($lowered_stmt) = @_;
 return 0 unless defined($lowered_stmt) && length($lowered_stmt);
 my $trimmed = $lowered_stmt;
 $trimmed =~ s/^\s+//o;
 $trimmed =~ s/\s+\z//o;
 return 0 unless length($trimmed);
 return 0 if $trimmed =~ /;\z/o;
 return 0 if $trimmed =~ /\{\z/o;
 return 0 if $trimmed =~ /^\}\s*(?:elsif\b|else\b)?/o;
 return 1
}

sub _insert_pending_newline_terminator {
 my ($rewritten_ref, $previous_lowered) = @_;
 return unless ref($previous_lowered) eq 'HASH';
 return unless $previous_lowered->{implicit_newline_separator};
 return unless _lowered_statement_needs_terminator($previous_lowered->{lowered_stmt});
 my $insert_pos = $previous_lowered->{rewritten_end};
 return unless defined($insert_pos) && $insert_pos >= 0 && $insert_pos <= length($$rewritten_ref);
 substr($$rewritten_ref, $insert_pos, 0, ';');
 $previous_lowered->{rewritten_end} = $insert_pos + 1;
 return
}

sub _unmatched_event_is_statement_level {
 my ($event) = @_;
 return 0 unless ref($event) eq 'HASH';
 my $contract_id = $event->{contract_id} // '';
 return 1 if $contract_id =~ /^(?:call|return_call|return_general|return|return_array|return_bare|return_undef)$/o;
 return 1 if $contract_id =~ /^(?:declare_typed|declare_alias)$/o;
 return 1 if $contract_id =~ /^(?:push_single_arg|push_indexed_arg|push_target_arg|push_target_indexed_arg|push_scope_target_arg|push)$/o;
 return 1 if $contract_id =~ /^(?:set_value|assign_call|assign_call_my|assign_match_my|scalar_assignment_operator|array_append_operator|array_end_mutation_method|hash_index_assignment_operator|set_key_statement)$/o;
 return 1 if $contract_id eq 'value_drop_statement';
 return 1 if $contract_id =~ /^(?:if_flow|elseif_flow|else_flow|endif_flow|while_flow|switch_flow|case_flow|default_flow|endcase_flow|endswitch_flow)$/o;
 return 1 if $contract_id =~ /^(?:say_stmt|print_stmt|print_each|exit_now|exit_bare|next_stmt|next_bare|regex_subst|regex_subst_assignment)$/o;
 return 0
}

sub _unmatched_event_is_inside_ambiguous_raw_statement {
 my ($event, $events) = @_;
 return 0 unless ref($event) eq 'HASH' && ref($events) eq 'ARRAY';
 my $event_raw = $event->{raw};
 return 0 unless defined($event_raw) && length($event_raw);

 foreach my $raw_event (@$events) {
  next unless ref($raw_event) eq 'HASH';
  next unless ($raw_event->{kind} // '') eq 'RAW_PERL';
  my $raw_statement = $raw_event->{raw};
  next unless defined($raw_statement) && length($raw_statement);
  next unless index($raw_statement, $event_raw) >= 0;

  my $statement_level_count = 0;
  foreach my $candidate (@$events) {
   next unless ref($candidate) eq 'HASH';
   next unless (($candidate->{source} // '') eq 'unmatched_helper_scan_event');
   next unless _unmatched_event_is_statement_level($candidate);
   my $candidate_raw = $candidate->{raw};
   next unless defined($candidate_raw) && length($candidate_raw);
   ++$statement_level_count if index($raw_statement, $candidate_raw) >= 0;
   return 1 if $statement_level_count >= 2;
  }
 }

 return 0
}

sub _flexible_source_stmt_regex {
 my ($source_stmt) = @_;
 return undef unless defined($source_stmt) && length($source_stmt);
 return undef unless $source_stmt =~ /^\s*[A-Za-z_][A-Za-z0-9_]*\s*\(/o;

 my $pattern = '';
 my $in_single_quote = 0;
 my $in_double_quote = 0;
 my $escape_next = 0;
 foreach my $char (split //, $source_stmt) {
  if ($in_single_quote) {
   $pattern .= quotemeta($char);
   if ($escape_next) { $escape_next = 0; }
   elsif ($char eq '\\') { $escape_next = 1; }
   elsif ($char eq "'") { $in_single_quote = 0; }
   next;
  }
  if ($in_double_quote) {
   $pattern .= quotemeta($char);
   if ($escape_next) { $escape_next = 0; }
   elsif ($char eq '\\') { $escape_next = 1; }
   elsif ($char eq '"') { $in_double_quote = 0; }
   next;
  }
  if ($char eq "'") { $in_single_quote = 1; $pattern .= quotemeta($char); next; }
  if ($char eq '"') { $in_double_quote = 1; $pattern .= quotemeta($char); next; }
  if ($char =~ /\s/o) { $pattern .= '\\s*'; next; }
  if ($char eq ',') { $pattern .= '\\s*,\\s*'; next; }
  if ($char eq '(') { $pattern .= '\\(\\s*'; next; }
  if ($char eq ')') { $pattern .= '\\s*\\)'; next; }
  $pattern .= quotemeta($char);
 }

 return qr/$pattern/s
}

sub _source_stmt_span_has_invalid_boundary {
 my ($text, $source_stmt, $pos, $len) = @_;
 return 0 unless defined($text) && defined($source_stmt);
 return 0 unless defined($pos) && $pos >= 0;
 return 0 unless defined($len) && $len >= 0;

 my $trimmed = $source_stmt;
 $trimmed =~ s/^\s+//o;
 $trimmed =~ s/\s+\z//o;
 return 0 unless length($trimmed);

 if ($trimmed =~ /^[A-Za-z_][A-Za-z0-9_]*/o) {
  my $leading_ws_len = 0;
  $leading_ws_len = length($1) if $source_stmt =~ /^(\s+)/o;
  my $identifier_pos = $pos + $leading_ws_len;
  if ($identifier_pos > 0) {
   my $before = substr($text, $identifier_pos - 1, 1);
   return 1 if defined($before) && $before =~ /[\$\@\%A-Za-z0-9_]/o;
  }
 }

 if ($trimmed =~ /[A-Za-z0-9_]\z/o) {
  my $after_pos = $pos + $len;
  if ($after_pos < length($text)) {
   my $after = substr($text, $after_pos, 1);
   return 1 if defined($after) && $after =~ /[A-Za-z0-9_]/o;
  }
 }

 return 0
}

sub _find_source_stmt_span {
 my ($text, $source_stmt, $start_pos) = @_;
 return (-1, 0) unless defined($text) && defined($source_stmt);
 $start_pos = 0 unless defined($start_pos) && $start_pos >= 0;

 my $scan_pos = $start_pos;
 while (1) {
  my $pos = index($text, $source_stmt, $scan_pos);
  last if $pos < 0;
  my $len = length($source_stmt);
  return ($pos, $len) unless _source_stmt_span_has_invalid_boundary($text, $source_stmt, $pos, $len);
  $scan_pos = $pos + 1;
 }

 my $regex = _flexible_source_stmt_regex($source_stmt);
 return (-1, 0) unless $regex;
 my $tail = substr($text, $start_pos);
 while ($tail =~ /$regex/g) {
  my $pos = $start_pos + $-[0];
  my $len = $+[0] - $-[0];
  return ($pos, $len) unless _source_stmt_span_has_invalid_boundary($text, $source_stmt, $pos, $len);
 }
 return (-1, 0)
}

sub default_deps_for_package {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::build_dep_map(
  __PACKAGE__,
  $pkg,
  [
   'build_action_lowering_contracts',
   'collect_action_helper_ir_nodes',
   'build_canonical_action_ir_events',
   'find_unresolved_action_helpers',
  ],
 )
}

sub _lower_action_code_from_canonical_ir {
 my ($label, $code, $rewrite_rules, $canonical_ir_diag) = @_;
 my $scope = LinkedSpec::ActionIR::Trace::enter(
  package => __PACKAGE__,
  owner => 'rewrite_pipeline',
  phase => 'lower_action_code_from_canonical_ir',
  label => $label,
  details => {
   label => defined($label) ? $label : '<undef>',
   code_len => defined($code) ? length($code) : 0,
   canonical_action_ir_count => ref($canonical_ir_diag) eq 'HASH'
    ? scalar(@{$canonical_ir_diag->{canonical_action_ir_events} || []})
    : 0,
  },
 );

 my %rewrite_by_id = map { $_->{id} => $_ } @$rewrite_rules;
 my $rewritten = $code;
 my $lower_ctx = {
  if_stack      => [],
  switch_stack  => [],
  switch_counter => 0,
  while_counter  => 0,
  rewrite_rules => $rewrite_rules,
  trace_label => $label,
 };
 my $source_search_pos = 0;
 my $previous_lowered;
 my $canonical_events = $canonical_ir_diag->{canonical_action_ir_events} || [];
 foreach my $event (@$canonical_events) {
  my $source_stmt = $event->{raw};
  next unless defined($source_stmt) && length($source_stmt);

  my ($source_pos, $source_len) = _find_source_stmt_span($code, $source_stmt, $source_search_pos);
  if (
   defined($previous_lowered) &&
   $source_pos >= 0 &&
   defined($previous_lowered->{source_end}) &&
   $source_pos >= $previous_lowered->{source_end}
  ) {
   my $separator = substr($code, $previous_lowered->{source_end}, $source_pos - $previous_lowered->{source_end});
   $previous_lowered->{implicit_newline_separator} = _separator_was_implicit_newline($separator);
   _insert_pending_newline_terminator(\$rewritten, $previous_lowered);
  }

  _insert_pending_implicit_if_closures_before_stmt(\$rewritten, $lower_ctx, $source_stmt, $event);

  my $is_unmatched_helper_scan_event = (($event->{source} // '') eq 'unmatched_helper_scan_event') ? 1 : 0;
  if ($is_unmatched_helper_scan_event && _unmatched_event_is_inside_ambiguous_raw_statement($event, $canonical_events)) {
   LinkedSpec::ActionIR::Trace::decision(
    owner => 'rewrite_pipeline',
    phase => 'lower_action_code_from_canonical_ir',
    label => $label,
    decision => 'skip_ambiguous_unmatched_event',
    taken => 1,
    context => {
     contract_id => $event->{contract_id},
     raw => $source_stmt,
    },
   );
   $source_search_pos = $source_pos + length($source_stmt) if $source_pos >= 0;
   next;
  }

  my $kind = $event->{kind} // '';
  if ($kind eq 'RAW_PERL') {
   LinkedSpec::ActionIR::Trace::decision(
    owner => 'rewrite_pipeline',
    phase => 'lower_action_code_from_canonical_ir',
    label => $label,
    decision => 'raw_perl_fallback',
    taken => 1,
    context => {
     raw => $source_stmt,
     source => $event->{source} // '',
    },
   );
   $previous_lowered = undef;
   $source_search_pos = $source_pos + $source_len if $source_pos >= 0;
   next;
  }

  my $contract_id = $event->{contract_id};
  if (!(defined $contract_id && exists $rewrite_by_id{$contract_id})) {
   LinkedSpec::ActionIR::Trace::decision(
    owner => 'rewrite_pipeline',
    phase => 'lower_action_code_from_canonical_ir',
    label => $label,
    decision => 'missing_rewrite_contract',
    taken => 1,
    context => {
     contract_id => defined($contract_id) ? $contract_id : '<undef>',
     raw => $source_stmt,
    },
   );
   $previous_lowered = undef;
   $source_search_pos = $source_pos + $source_len if $source_pos >= 0;
   next;
  }

  my ($pos, $replace_len) = _find_source_stmt_span($rewritten, $source_stmt, 0);
  if ($pos < 0) {
   LinkedSpec::ActionIR::Trace::decision(
    owner => 'rewrite_pipeline',
    phase => 'lower_action_code_from_canonical_ir',
    label => $label,
    decision => 'source_span_missing',
    taken => 1,
    context => {
     contract_id => $contract_id,
     raw => $source_stmt,
    },
   );
   $previous_lowered = undef;
   $source_search_pos = $source_pos + $source_len if $source_pos >= 0;
   next;
  }

  my $lowered_stmt = $rewrite_by_id{$contract_id}{apply}->($source_stmt, $lower_ctx);
  if (!(defined($lowered_stmt) && length($lowered_stmt)) || $lowered_stmt eq $source_stmt) {
   LinkedSpec::ActionIR::Trace::decision(
    owner => 'rewrite_pipeline',
    phase => 'lower_action_code_from_canonical_ir',
    label => $label,
    decision => 'lowering_noop',
    taken => 1,
    context => {
     contract_id => $contract_id,
     raw => $source_stmt,
     lowered_defined => defined($lowered_stmt) ? 1 : 0,
    },
   );
   $previous_lowered = undef;
   $source_search_pos = $source_pos + $source_len if $source_pos >= 0;
   next;
  }
  substr($rewritten, $pos, $replace_len, $lowered_stmt);
  LinkedSpec::ActionIR::Trace::decision(
   owner => 'rewrite_pipeline',
   phase => 'lower_action_code_from_canonical_ir',
   label => $label,
   decision => $is_unmatched_helper_scan_event ? 'unmatched_helper_event_rewritten' : 'statement_rewritten',
   taken => 1,
   context => {
    contract_id => $contract_id,
    raw => $source_stmt,
    lowered => $lowered_stmt,
   },
  );
  if (!$is_unmatched_helper_scan_event) {
   $previous_lowered = {
    lowered_stmt => $lowered_stmt,
    rewritten_end => $pos + length($lowered_stmt),
    source_end => ($source_pos >= 0) ? $source_pos + $source_len : undef,
    implicit_newline_separator => 0,
   };
  }
  $source_search_pos = $source_pos + $source_len if $source_pos >= 0;
 }
 my $implicit_closures = _flush_implicit_if_closures($lower_ctx);
 if (defined($implicit_closures) && length($implicit_closures)) {
  my $closure_count = () = ($implicit_closures =~ /\}/g);
  LinkedSpec::ActionIR::Trace::decision(
   owner => 'rewrite_pipeline',
   phase => 'implicit_if',
   label => $label,
   decision => 'closure_appended_at_end',
   taken => 1,
   context => {
    closure_count => $closure_count,
   },
  );
  $rewritten .= ' '.$implicit_closures;
 }
	 if (@{$lower_ctx->{if_stack}} || @{$lower_ctx->{switch_stack}}) {
  LinkedSpec::ActionIR::Trace::decision(
   owner => 'rewrite_pipeline',
   phase => 'lower_action_code_from_canonical_ir',
   label => $label,
   decision => 'unbalanced_flow_stack',
   taken => 1,
   context => {
    if_stack => scalar(@{$lower_ctx->{if_stack}}),
    switch_stack => scalar(@{$lower_ctx->{switch_stack}}),
   },
  );
  LinkedSpec::ActionIR::Trace::exit_scope(
   $scope,
   {
    status => 'fallback_original',
    label => defined($label) ? $label : '<undef>',
    rewritten_len => defined($code) ? length($code) : 0,
   },
  );
	  return $code;
	 }

	 my $retired_colon_scalar_slot = _rewrite_exact_retired_colon_scalar_slot($rewritten);
	 if (defined($retired_colon_scalar_slot) && length($retired_colon_scalar_slot)) {
	  LinkedSpec::ActionIR::Trace::decision(
	   owner => 'rewrite_pipeline',
	   phase => 'lower_action_code_from_canonical_ir',
	   label => $label,
	   decision => 'retired_colon_scalar_slot',
	   taken => 1,
	   context => {},
	  );
	  $rewritten = $retired_colon_scalar_slot;
	 }

	 LinkedSpec::ActionIR::Trace::exit_scope(
  $scope,
  {
   status => 'ok',
   label => defined($label) ? $label : '<undef>',
   rewritten_len => defined($rewritten) ? length($rewritten) : 0,
  },
 );
 return $rewritten
}

sub _build_action_rewrite_rules {
 my ($label, $deps) = @_;
 my $scope = LinkedSpec::ActionIR::Trace::enter(
  package => __PACKAGE__,
  owner => 'rewrite_pipeline',
  phase => 'build_action_rewrite_rules',
  label => $label,
  details => {
   label => defined($label) ? $label : '<undef>',
  },
 );
 $deps = {} unless ref($deps) eq 'HASH';
 my $build_action_lowering_contracts = (ref($deps->{build_action_lowering_contracts}) eq 'CODE')
  ? $deps->{build_action_lowering_contracts}
  : undef;
 die "(LinkedSpec::ActionIR::RewritePipeline::_require_dep) -E- missing dependency callback 'build_action_lowering_contracts'"
  unless ref($build_action_lowering_contracts) eq 'CODE';
 my $contracts = $build_action_lowering_contracts->($label);
 my $rules = [map {{
  id                 => $_->{id},
  ir_node            => $_->{ir_node},
  diag_name          => $_->{diag_name},
  compatibility_surface => $_->{compatibility_surface} ? 1 : 0,
  unresolved_pattern => $_->{unresolved_pattern},
  apply              => $_->{lower},
 }} @$contracts];
 LinkedSpec::ActionIR::Trace::decision(
  owner => 'rewrite_pipeline',
  phase => 'build_action_rewrite_rules',
  label => $label,
  decision => 'contracts_built',
  taken => ref($rules) eq 'ARRAY',
  context => {
   rewrite_rule_count => ref($rules) eq 'ARRAY' ? scalar(@$rules) : 0,
  },
 );
 LinkedSpec::ActionIR::Trace::exit_scope(
  $scope,
  {
   status => 'ok',
   label => defined($label) ? $label : '<undef>',
   rewrite_rule_count => ref($rules) eq 'ARRAY' ? scalar(@$rules) : 0,
  },
 );
 return $rules
}

sub _rewrite_action_code_with_diagnostics {
 my ($label, $code, $rewrite_rules, $deps) = @_;
 my $scope = LinkedSpec::ActionIR::Trace::enter(
  package => __PACKAGE__,
  owner => 'rewrite_pipeline',
  phase => 'rewrite_action_code_with_diagnostics',
  label => $label,
  details => {
   label => defined($label) ? $label : '<undef>',
   code_len => defined($code) ? length($code) : 0,
   rewrite_rules_supplied => ref($rewrite_rules) eq 'ARRAY' ? 1 : 0,
   rewrite_rule_count => ref($rewrite_rules) eq 'ARRAY' ? scalar(@$rewrite_rules) : 0,
  },
 );
 $deps = {} unless ref($deps) eq 'HASH';
 my $collect_action_helper_ir_nodes = (ref($deps->{collect_action_helper_ir_nodes}) eq 'CODE')
  ? $deps->{collect_action_helper_ir_nodes}
  : undef;
 die "(LinkedSpec::ActionIR::RewritePipeline::_require_dep) -E- missing dependency callback 'collect_action_helper_ir_nodes'"
  unless ref($collect_action_helper_ir_nodes) eq 'CODE';
 my $build_canonical_action_ir_events = (ref($deps->{build_canonical_action_ir_events}) eq 'CODE')
  ? $deps->{build_canonical_action_ir_events}
  : undef;
 die "(LinkedSpec::ActionIR::RewritePipeline::_require_dep) -E- missing dependency callback 'build_canonical_action_ir_events'"
  unless ref($build_canonical_action_ir_events) eq 'CODE';
 my $find_unresolved_action_helpers = (ref($deps->{find_unresolved_action_helpers}) eq 'CODE')
  ? $deps->{find_unresolved_action_helpers}
  : undef;
 die "(LinkedSpec::ActionIR::RewritePipeline::_require_dep) -E- missing dependency callback 'find_unresolved_action_helpers'"
  unless ref($find_unresolved_action_helpers) eq 'CODE';

 my $rewrite_rules_supplied = ref($rewrite_rules) eq 'ARRAY' ? 1 : 0;
 $rewrite_rules //= _build_action_rewrite_rules($label, $deps);
 LinkedSpec::ActionIR::Trace::decision(
  owner => 'rewrite_pipeline',
  phase => 'rewrite_action_code_with_diagnostics',
  label => $label,
  decision => 'rewrite_rules_built',
  taken => $rewrite_rules_supplied ? 0 : 1,
  context => {
   rewrite_rule_count => ref($rewrite_rules) eq 'ARRAY' ? scalar(@$rewrite_rules) : 0,
   rewrite_rules_supplied => $rewrite_rules_supplied,
  },
 );
 my $ir_diag = $collect_action_helper_ir_nodes->($code, $rewrite_rules);
 LinkedSpec::ActionIR::Trace::decision(
  owner => 'rewrite_pipeline',
  phase => 'rewrite_action_code_with_diagnostics',
  label => $label,
  decision => 'helper_events_collected',
  taken => ref($ir_diag) eq 'HASH' && ($ir_diag->{helper_action_ir_count} || 0) > 0,
  context => {
   helper_action_ir_count => ref($ir_diag) eq 'HASH' ? ($ir_diag->{helper_action_ir_count} || 0) : 0,
  },
 );
 my $canonical_ir_diag = $build_canonical_action_ir_events->($label, $code, $ir_diag->{helper_action_ir_events});
 LinkedSpec::ActionIR::Trace::decision(
  owner => 'rewrite_pipeline',
  phase => 'rewrite_action_code_with_diagnostics',
  label => $label,
  decision => 'canonical_raw_perl_fallback',
  taken => ref($canonical_ir_diag) eq 'HASH' && ($canonical_ir_diag->{canonical_action_ir_fallback_count} || 0) > 0,
  context => {
   canonical_action_ir_count => ref($canonical_ir_diag) eq 'HASH' ? ($canonical_ir_diag->{canonical_action_ir_count} || 0) : 0,
   fallback_count => ref($canonical_ir_diag) eq 'HASH' ? ($canonical_ir_diag->{canonical_action_ir_fallback_count} || 0) : 0,
  },
 );
 my $rewritten = _lower_action_code_from_canonical_ir($label, $code, $rewrite_rules, $canonical_ir_diag);
 my $diag = $find_unresolved_action_helpers->($rewritten, $rewrite_rules);
 LinkedSpec::ActionIR::Trace::decision(
  owner => 'rewrite_pipeline',
  phase => 'rewrite_action_code_with_diagnostics',
  label => $label,
  decision => 'unresolved_helpers_found',
  taken => ref($diag) eq 'HASH' && ($diag->{unresolved_helper_count} || 0) > 0,
  context => {
   unresolved_helper_count => ref($diag) eq 'HASH' ? ($diag->{unresolved_helper_count} || 0) : 0,
  },
 );
 my $result_diag = {
  %$diag,
  helper_action_ir_count => $ir_diag->{helper_action_ir_count},
  helper_action_ir_hits  => $ir_diag->{helper_action_ir_hits},
  helper_action_ir_nodes => $ir_diag->{helper_action_ir_nodes},
  helper_action_ir_events => $ir_diag->{helper_action_ir_events},
  canonical_action_ir_count => $canonical_ir_diag->{canonical_action_ir_count},
  canonical_action_ir_hits  => $canonical_ir_diag->{canonical_action_ir_hits},
  canonical_action_ir_nodes => $canonical_ir_diag->{canonical_action_ir_nodes},
  canonical_action_ir_events => $canonical_ir_diag->{canonical_action_ir_events},
  canonical_action_ir_fallback_count => $canonical_ir_diag->{canonical_action_ir_fallback_count},
 };
 LinkedSpec::ActionIR::Trace::exit_scope(
  $scope,
  {
   status => 'ok',
   label => defined($label) ? $label : '<undef>',
   rewritten_len => defined($rewritten) ? length($rewritten) : 0,
   helper_action_ir_count => $result_diag->{helper_action_ir_count} || 0,
   canonical_action_ir_fallback_count => $result_diag->{canonical_action_ir_fallback_count} || 0,
   unresolved_helper_count => $result_diag->{unresolved_helper_count} || 0,
  },
 );
 return ($rewritten, $result_diag)
}

1;
