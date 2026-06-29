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
 return if _event_continues_implicit_if_flow($event);

 my $closures = _flush_implicit_if_closures($ctx);
 return unless defined($closures) && length($closures);

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
 return 1 if $contract_id =~ /^(?:push_single_arg|push_indexed_arg|push_target_arg|push_target_indexed_arg|push_scope_target_arg|push_value|push_nonempty)$/o;
 return 1 if $contract_id =~ /^(?:assign_value|assign_call|assign_call_my|assign_match_my|scalar_assignment_operator|array_append_operator|array_end_mutation_method|hash_index_assignment_operator|set_key_statement)$/o;
 return 1 if $contract_id =~ /^(?:if_flow|elseif_flow|else_flow|endif_flow|switch_flow|case_flow|default_flow|endcase_flow|endswitch_flow)$/o;
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

 my %rewrite_by_id = map { $_->{id} => $_ } @$rewrite_rules;
 my $rewritten = $code;
 my $lower_ctx = {
  if_stack      => [],
  switch_stack  => [],
  switch_counter => 0,
  rewrite_rules => $rewrite_rules,
 };
 my $source_search_pos = 0;
 my $previous_lowered;
 my $canonical_events = $canonical_ir_diag->{canonical_action_ir_events} || [];
 foreach my $event (@$canonical_events) {
  my $source_stmt = $event->{raw};
  next unless defined($source_stmt) && length($source_stmt);

  my $source_pos = index($code, $source_stmt, $source_search_pos);
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
   $source_search_pos = $source_pos + length($source_stmt) if $source_pos >= 0;
   next;
  }

  my $kind = $event->{kind} // '';
  if ($kind eq 'RAW_PERL') {
   $previous_lowered = undef;
   $source_search_pos = $source_pos + length($source_stmt) if $source_pos >= 0;
   next;
  }

  my $contract_id = $event->{contract_id};
  if (!(defined $contract_id && exists $rewrite_by_id{$contract_id})) {
   $previous_lowered = undef;
   $source_search_pos = $source_pos + length($source_stmt) if $source_pos >= 0;
   next;
  }

  my $pos = index($rewritten, $source_stmt);
  if ($pos < 0) {
   $previous_lowered = undef;
   $source_search_pos = $source_pos + length($source_stmt) if $source_pos >= 0;
   next;
  }

  my $lowered_stmt = $rewrite_by_id{$contract_id}{apply}->($source_stmt, $lower_ctx);
  if (!(defined($lowered_stmt) && length($lowered_stmt)) || $lowered_stmt eq $source_stmt) {
   $previous_lowered = undef;
   $source_search_pos = $source_pos + length($source_stmt) if $source_pos >= 0;
   next;
  }
  substr($rewritten, $pos, length($source_stmt), $lowered_stmt);
  if (!$is_unmatched_helper_scan_event) {
   $previous_lowered = {
    lowered_stmt => $lowered_stmt,
    rewritten_end => $pos + length($lowered_stmt),
    source_end => ($source_pos >= 0) ? $source_pos + length($source_stmt) : undef,
    implicit_newline_separator => 0,
   };
  }
  $source_search_pos = $source_pos + length($source_stmt) if $source_pos >= 0;
 }
 my $implicit_closures = _flush_implicit_if_closures($lower_ctx);
 $rewritten .= ' '.$implicit_closures if defined($implicit_closures) && length($implicit_closures);
 if (@{$lower_ctx->{if_stack}} || @{$lower_ctx->{switch_stack}}) {
  return $code;
 }

 return $rewritten
}

sub _build_action_rewrite_rules {
 my ($label, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';
 my $build_action_lowering_contracts = (ref($deps->{build_action_lowering_contracts}) eq 'CODE')
  ? $deps->{build_action_lowering_contracts}
  : undef;
 die "(LinkedSpec::ActionIR::RewritePipeline::_require_dep) -E- missing dependency callback 'build_action_lowering_contracts'"
  unless ref($build_action_lowering_contracts) eq 'CODE';
 my $contracts = $build_action_lowering_contracts->($label);
 return [map {{
  id                 => $_->{id},
  ir_node            => $_->{ir_node},
  diag_name          => $_->{diag_name},
  compatibility_surface => $_->{compatibility_surface} ? 1 : 0,
  unresolved_pattern => $_->{unresolved_pattern},
  apply              => $_->{lower},
 }} @$contracts]
}

sub _rewrite_action_code_with_diagnostics {
 my ($label, $code, $rewrite_rules, $deps) = @_;
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

 $rewrite_rules //= _build_action_rewrite_rules($label, $deps);
 my $ir_diag = $collect_action_helper_ir_nodes->($code, $rewrite_rules);
 my $canonical_ir_diag = $build_canonical_action_ir_events->($label, $code, $ir_diag->{helper_action_ir_events});
 my $rewritten = _lower_action_code_from_canonical_ir($label, $code, $rewrite_rules, $canonical_ir_diag);
 my $diag = $find_unresolved_action_helpers->($rewritten, $rewrite_rules);
 return ($rewritten, {
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
 })
}

1;
