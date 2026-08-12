#------------------------------------------------------------------------------
# Package: LinkedSpec::RecognitionTransactionPolicy
# Purpose: Validate authored transaction linearity and compute recursive
#          recognition effects after the complete Perl rule table exists.
#------------------------------------------------------------------------------
package LinkedSpec::RecognitionTransactionPolicy;

use 5.010;
use strict;
use warnings;

my %NODES_BY_EFFECT = (
 pure_value => [qw(FILTER_MATCH FILTER_NONEMPTY LINE_COUNT MAP_LOWERCASE MAP_UPPERCASE SPLIT_EACH TRIM_EACH UNIQ VALUE_DROP)],
 source_read => [qw(CAPTURE CAPTURE_BETWEEN_MARKS CAPTURE_FROM_MARK CAPTURE_IF CAPTURE_LEN_BETWEEN_MARKS CAPTURE_LEN_FROM_MARK CAPTURE_MACRO CAPTURE_REST CAPTURE_REST_FROM_MARK CAPTURE_REST_LEN CAPTURE_REST_LEN_FROM_MARK CAPTURE_SLICE CAPTURE_SLICE_COL_READ CAPTURE_SLICE_LEN CAPTURE_SLICE_LINE_READ CAPTURE_SLICE_POS_READ CAPTURE_SLICE_UNTIL_CURSOR CAPTURE_SLICE_UNTIL_CURSOR_LEN CAPTURE_UNTIL_BOUNDARY CAPTURE_UNTIL_CURSOR_FROM_MARK CAPTURE_UNTIL_CURSOR_LEN_FROM_MARK CURSOR_COL_READ CURSOR_LINE_READ CURSOR_POS_READ CURSOR_REST CURSOR_REST_LEN IMATCH_COL_READ IMATCH_END_COL_READ IMATCH_END_LINE_READ IMATCH_END_POS_READ IMATCH_GROUP_READ IMATCH_GROUPS_READ IMATCH_LEN_READ IMATCH_LINE_READ IMATCH_NAMED_EXISTS IMATCH_NAMED_MAP_READ IMATCH_NAMED_READ IMATCH_START_COL_READ IMATCH_START_LINE_READ IMATCH_START_POS_READ IMATCH_TEXT_READ INPUT_END_COL_READ INPUT_END_LINE_READ INPUT_END_POS_READ INPUT_LEN_READ INPUT_SLICE_READ INPUT_TEXT_READ MARK_COL_READ MARK_EXISTS MARK_LINE_READ MARK_POS_READ MATCH_COL_READ MATCH_END_COL_READ MATCH_END_LINE_READ MATCH_END_POS_READ MATCH_GROUP_READ MATCH_GROUPS_READ MATCH_LEN_READ MATCH_LINE_READ MATCH_NAMED_EXISTS MATCH_NAMED_MAP_READ MATCH_NAMED_READ MATCH_START_COL_READ MATCH_START_LINE_READ MATCH_START_POS_READ MATCH_TEXT_READ)],
 structured_control => [qw(CASE DEFAULT ELIF ELSE ENDCASE ENDIF ENDSWITCH IF SWITCH)],
 rule_recognition => [qw(CALL)],
 transaction_state => [qw(RECOGNITION_COMMIT RECOGNITION_CHECKPOINT RECOGNITION_ROLLBACK RECOGNIZE_ONCE)],
 cursor_advance => [qw(POSITION_TRACK)],
 capture_boundary_write => [qw(CAPTURE_REST_TAKE CAPTURE_REST_TAKE_LEN CAPTURE_SLICE_START CAPTURE_SLICE_START_FROM_MARK CAPTURE_SLICE_TAKE CAPTURE_SLICE_TAKE_LEN CAPTURE_SLICE_TAKE_UNTIL_CURSOR CAPTURE_SLICE_TAKE_UNTIL_CURSOR_LEN CAPTURE_TAKE_BETWEEN_LEN_MARKS CAPTURE_TAKE_BETWEEN_MARKS CAPTURE_TAKE_FROM_MARK CAPTURE_TAKE_LEN_FROM_MARK CAPTURE_TAKE_REST_FROM_MARK CAPTURE_TAKE_REST_LEN_FROM_MARK CAPTURE_TAKE_UNTIL_CURSOR_FROM_MARK CAPTURE_TAKE_UNTIL_CURSOR_LEN_FROM_MARK MARK_CAPTURE_SLICE)],
 invocation_mark_write => [qw(CLEAR_MARK MARK_COPY MARK_ENTRY_END MARK_ENTRY_START MARK_HERE MARK_INPUT_END MARK_INPUT_START MARK_MATCH_END MARK_MATCH_START)],
 staged_return => [qw(RETURN)],
 binding_write => [qw(ASSIGN DECLARE OBSERVE_RECOGNITION REGEX_SUBST)],
 aggregate_write => [qw(ARRAY_MUTATE PUSH SPLIT)],
 ast_or_object_write => [],
 compatibility_cursor_control => [qw(RESTORE_CURSOR REWIND_ENTRY_START REWIND_MATCH_START SAVE_CURSOR)],
 output => [qw(PRINT SAY)],
 authored_diagnostic => [],
 exit_or_unbounded_control => [qw(EXIT NEXT WHILE)],
 dynamic_callable => [],
 parser_registry_or_staged_dispatch => [],
 external_or_host => [],
 unknown_or_raw => [],
);

my @ALLOWED_EFFECTS = qw(
 pure_value source_read structured_control rule_recognition transaction_state cursor_advance
 capture_boundary_write invocation_mark_write staged_return
);
my @REJECTED_EFFECTS = qw(
 binding_write aggregate_write ast_or_object_write compatibility_cursor_control output
 authored_diagnostic exit_or_unbounded_control dynamic_callable parser_registry_or_staged_dispatch
 external_or_host unknown_or_raw
);
my %KNOWN_EFFECT = map { $_ => 1 } (@ALLOWED_EFFECTS, @REJECTED_EFFECTS);
my %EFFECT_BY_NODE = map {
 my $effect = $_;
 map { $_ => $effect } @{$NODES_BY_EFFECT{$effect}}
} keys %NODES_BY_EFFECT;

sub validate_rule_rows {
 my ($rows) = @_;
 return _diagnostic('recognition_unknown_effect', '<compiler>', '<rule-table>', effect => 'unknown_or_raw')
  unless ref($rows) eq 'ARRAY';

 my %rule;
 for my $row (@$rows) {
  next unless ref($row) eq 'ARRAY' && @$row == 2;
  my ($label, $info) = @$row;
  next unless defined($label) && ref($info) eq 'HASH';
  my $rewriter = ref($info->{meta}) eq 'HASH' && ref($info->{meta}{action_rewriter}) eq 'HASH'
   ? $info->{meta}{action_rewriter}
   : {};
  my @events = grep { ref($_) eq 'HASH' } @{$rewriter->{canonical_action_ir_events} // []};
  my %base;
  my %calls;
  for my $event (@events) {
   my $kind = $event->{kind} // '';
   my $effect = $EFFECT_BY_NODE{$kind};
   $effect = 'unknown_or_raw' unless defined($effect) && $KNOWN_EFFECT{$effect};
   $base{$effect} = 1;
   if ($kind eq 'CALL' || $kind eq 'RECOGNIZE_ONCE') {
    my $callee = ref($event->{args}) eq 'HASH' ? $event->{args}{callee} : undef;
    $calls{$callee} = 1 if defined($callee) && !ref($callee) && length($callee);
   }
  }
  my $dependency_refs = $info->{dependency_refs};
  $base{unknown_or_raw} = 1
   if defined($dependency_refs) && ref($dependency_refs) ne 'ARRAY';
  for my $dependency (@{ref($dependency_refs) eq 'ARRAY' ? $dependency_refs : []}) {
   my $callee = ref($dependency) eq 'HASH' ? $dependency->{label} : undef;
   $calls{$callee} = 1 if defined($callee) && !ref($callee) && length($callee);
  }
  $base{unknown_or_raw} = 1
   if ($rewriter->{canonical_action_ir_fallback_count} // 0)
   || ($rewriter->{unresolved_helper_count} // 0);
  $rule{$label} = {
   info => $info,
   events => \@events,
   base => \%base,
   calls => \%calls,
   effects => {%base},
  };
 }

 for my $label (sort keys %rule) {
  my $diag = _validate_transaction_shape($label, $rule{$label}{events}, \%rule);
  return $diag if ref($diag) eq 'HASH';
 }

 my $changed = 1;
 while ($changed) {
  $changed = 0;
  for my $label (sort keys %rule) {
   for my $callee (sort keys %{$rule{$label}{calls}}) {
    unless (exists $rule{$callee}) {
     unless ($rule{$label}{effects}{unknown_or_raw}) {
      $rule{$label}{effects}{unknown_or_raw} = 1;
      $changed = 1;
     }
     next;
    }
    for my $effect (keys %{$rule{$callee}{effects}}) {
     next if $rule{$label}{effects}{$effect};
     $rule{$label}{effects}{$effect} = 1;
     $changed = 1;
    }
   }
  }
 }

 for my $owner (sort keys %rule) {
  for my $event (@{$rule{$owner}{events}}) {
   next unless ($event->{kind} // '') eq 'RECOGNIZE_ONCE';
   my $args = ref($event->{args}) eq 'HASH' ? $event->{args} : {};
   my $callee = $args->{callee};
   my $origin = $owner.':recognize_once';
   next unless defined($callee) && exists $rule{$callee};
   for my $effect (@REJECTED_EFFECTS) {
    next unless $rule{$callee}{effects}{$effect};
    return _diagnostic(
     $effect eq 'unknown_or_raw' ? 'recognition_unknown_effect' : 'recognition_effect_forbidden',
     $callee,
     $origin,
     effect => $effect,
    );
   }
  }
 }
 return undef
}

sub _validate_transaction_shape {
 my ($label, $events, $rules) = @_;
 my @checkpoint = grep { ($_->{kind} // '') eq 'RECOGNITION_CHECKPOINT' } @$events;
 my @attempt = grep { ($_->{kind} // '') eq 'RECOGNIZE_ONCE' } @$events;
 my @commit = grep { ($_->{kind} // '') eq 'RECOGNITION_COMMIT' } @$events;
 my @rollback = grep { ($_->{kind} // '') eq 'RECOGNITION_ROLLBACK' } @$events;
 return undef unless @checkpoint || @attempt || @commit || @rollback;
 my $origin = $label.':recognition_transaction';
 return _diagnostic('recognition_nesting_forbidden', $label, $origin) if @checkpoint > 1;
 return _diagnostic('recognition_attempt_count', $label, $origin, count => scalar(@attempt))
  unless @checkpoint == 1 && @attempt == 1;
 my $token = $checkpoint[0]{args}{token};
 return _diagnostic('recognition_token_expected', $label, $origin)
 unless defined($token) && !ref($token) && $token =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 for my $event (@attempt, @commit, @rollback) {
  return _diagnostic('recognition_token_escape', $label, $origin, escape => 'token_slot_mismatch')
   unless ref($event->{args}) eq 'HASH' && ($event->{args}{token} // '') eq $token;
 }
 my ($checkpoint_index) = grep {
  ($events->[$_]{kind} // '') eq 'RECOGNITION_CHECKPOINT'
 } 0 .. $#$events;
 my ($attempt_index) = grep {
  ($events->[$_]{kind} // '') eq 'RECOGNIZE_ONCE'
 } 0 .. $#$events;
 return _diagnostic('recognition_token_expected', $label, $origin)
  unless defined($checkpoint_index) && defined($attempt_index) && $checkpoint_index < $attempt_index;
 my $terminal_count = @commit + @rollback;
 return _diagnostic('recognition_terminal_required', $label, $origin) unless $terminal_count;
 my $path_counts = _terminal_path_counts($events, $attempt_index + 1, scalar(@$events), [0]);
 return _diagnostic('recognition_terminal_required', $label, $origin)
  unless ref($path_counts) eq 'ARRAY' && @$path_counts;
 return _diagnostic('recognition_terminal_required', $label, $origin)
  if grep { $_ == 0 } @$path_counts;
 return _diagnostic('recognition_token_reused', $label, $origin, operation => 'terminal')
  if grep { $_ > 1 } @$path_counts;
 my $args = ref($attempt[0]{args}) eq 'HASH' ? $attempt[0]{args} : {};
 my $callee = $args->{callee};
 return _diagnostic(
  'recognition_static_rule_required',
  $label,
  $label.':recognize_once',
  operand => defined($args->{operand}) ? $args->{operand} : '<missing>',
 ) unless defined($callee) && !ref($callee) && exists $rules->{$callee};

 for my $event (@$events) {
  next if ($event->{kind} // '') =~ /\A(?:RECOGNITION_CHECKPOINT|RECOGNIZE_ONCE|RECOGNITION_COMMIT|RECOGNITION_ROLLBACK)\z/o;
  my $raw = $event->{raw};
  next unless defined($raw) && !ref($raw) && $raw =~ /\b\Q$token\E\b/o;
  return _diagnostic('recognition_token_escape', $label, $origin, escape => 'authored_use');
 }
 return undef
}

sub _terminal_path_counts {
 my ($events, $start, $end, $initial) = @_;
 my @counts = @$initial;
 my $index = $start;
 while ($index < $end) {
  my $kind = $events->[$index]{kind} // '';
  if ($kind eq 'RECOGNITION_COMMIT' || $kind eq 'RECOGNITION_ROLLBACK') {
   ++$_ for @counts;
   ++$index;
   next;
  }
  if ($kind eq 'IF') {
   my ($endif, $branches, $has_else) = _if_branch_ranges($events, $index, $end);
   return undef unless defined($endif) && ref($branches) eq 'ARRAY' && @$branches;
   my @branched;
   for my $range (@$branches) {
    my $branch_counts = _terminal_path_counts(
     $events,
     $range->[0],
     $range->[1],
     [@counts],
    );
    return undef unless ref($branch_counts) eq 'ARRAY';
    push @branched, @$branch_counts;
   }
   push @branched, @counts unless $has_else;
   @counts = @branched;
   $index = $endif + 1;
   next;
  }
  return undef if $kind eq 'ELIF' || $kind eq 'ELSE' || $kind eq 'ENDIF';
  ++$index;
 }
 return \@counts
}

sub _if_branch_ranges {
 my ($events, $if_index, $end) = @_;
 my @ranges;
 my $branch_start = $if_index + 1;
 my $depth = 0;
 my $has_else = 0;
 for (my $index = $branch_start; $index < $end; ++$index) {
  my $kind = $events->[$index]{kind} // '';
  if ($kind eq 'IF') {
   ++$depth;
   next;
  }
  if ($kind eq 'ENDIF') {
   if ($depth) {
    --$depth;
    next;
   }
   push @ranges, [$branch_start, $index];
   return ($index, \@ranges, $has_else);
  }
  next unless !$depth && ($kind eq 'ELIF' || $kind eq 'ELSE');
  push @ranges, [$branch_start, $index];
  $branch_start = $index + 1;
  $has_else = 1 if $kind eq 'ELSE';
 }
 return
}

sub _diagnostic {
 my ($code, $rule, $origin, %fields) = @_;
 return {
  code => $code,
  rule => $rule,
  origin => $origin,
  %fields,
 }
}

1;
