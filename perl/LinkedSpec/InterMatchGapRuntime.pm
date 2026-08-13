#------------------------------------------------------------------------------
# Package: LinkedSpec::InterMatchGapRuntime
# Purpose: Own private invocation-local inter-match gap state and detached reads.
#------------------------------------------------------------------------------
package LinkedSpec::InterMatchGapRuntime;

use 5.010;
use strict;
use warnings;

use Hash::Util ();
use Scalar::Util qw(blessed refaddr);
use LinkedSpec::RecognitionTransactionRuntime ();
use LinkedSpec::SourceLocation ();

my $ENTRY_SLOT_KEY = '__linkedspec_inter_match_gap_entry_slot';

sub activate {
 my ($descr, $string_ref, $info, $rule) = @_;
 my $guard = LinkedSpec::RecognitionTransactionRuntime::_current_guard(
  $descr, $string_ref, $rule,
 );
 $guard->{gap_state} = {
  committed_gap_cursor => $guard->{entry_cursor},
  accepted_edge_count => 0,
  current_gap => undef,
 };
 $guard->{gap_selected_match_end} = undef;
 $guard->{gap_phase} = 'I';
 return 1
}

sub set_phase {
 my ($descr, $string_ref, $rule, $phase) = @_;
 my $guard = LinkedSpec::RecognitionTransactionRuntime::_current_guard(
  $descr, $string_ref, $rule,
 );
 $guard->{gap_phase} = defined($phase) && !ref($phase) ? "$phase" : '';
 return 1
}

sub install_candidate {
 my ($descr, $string_ref, $minfo, $rule) = @_;
 my $guard = LinkedSpec::RecognitionTransactionRuntime::_current_guard(
  $descr, $string_ref, $rule,
 );
 my $state = _active_state($guard);
 _internal_error('selected match info must be a hash reference')
  unless ref($minfo) eq 'HASH';

 my $match_end = pos($$string_ref);
 my $match_text = $minfo->{match};
 my $match_start = defined($match_end) && defined($match_text)
  ? $match_end - length($match_text)
  : undef;
 _internal_error('selected match has no decoded scalar boundaries')
  unless defined($match_start) && defined($match_end);

 my $kind = $state->{accepted_edge_count} ? 'interstitial' : 'prefix';
 my $span = LinkedSpec::SourceLocation::Runtime::detached_span_record(
  $guard->{info}, $string_ref,
  $state->{committed_gap_cursor}, $match_start, 'gap',
 );
 $state->{current_gap} = {
  source_id => $span->{source_id},
  rule_label => $rule,
  invocation_id => $guard->{identity}{invocation_id},
  edge_ordinal => $state->{accepted_edge_count},
  kind => $kind,
  start => $span->{start},
  end => $span->{end},
  provenance => 'gap',
 };
 $guard->{gap_selected_match_end} = $match_end;
 $guard->{gap_phase} = 'selection';

 my $slot = _selected_slot_record($descr, $rule, $minfo);
 $minfo->{$ENTRY_SLOT_KEY} = {
  owner_invocation_id => $guard->{identity}{invocation_id},
  slot => $slot,
 };
 return 1
}

sub commit_candidate {
 my ($descr, $string_ref, $rule) = @_;
 my $guard = LinkedSpec::RecognitionTransactionRuntime::_current_guard(
  $descr, $string_ref, $rule,
 );
 my $state = _active_state($guard);
 my $current = $state->{current_gap};
 _internal_error('accepted gap commit has no current candidate')
  unless ref($current) eq 'HASH';
 my $cursor = pos($$string_ref);
 my $match_end = $guard->{gap_selected_match_end};
 if (!defined($cursor) || !defined($match_end) || $cursor < $match_end) {
  die LinkedSpec::SourceLocation::Error->new(
   code => 'source_location_cursor_regression',
   phase => 'advance',
   rule_role => $rule,
   invocation_role => 'gap_owner',
   source_id => $current->{source_id},
   start_offset => $match_end,
   end_offset => defined($cursor) ? $cursor : -1,
   originating_edge_or_job => $rule.':capture_gaps_commit',
  )
 }
 $state->{committed_gap_cursor} = 0 + $cursor;
 ++$state->{accepted_edge_count};
 $state->{current_gap} = undef;
 $guard->{gap_selected_match_end} = undef;
 $guard->{gap_phase} = 'post_commit';
 return 1
}

sub install_tail {
 my ($descr, $string_ref, $rule, $phase) = @_;
 my $guard = LinkedSpec::RecognitionTransactionRuntime::_current_guard(
  $descr, $string_ref, $rule,
 );
 my $state = _active_state($guard);
 my $end = length($$string_ref);
 my $span = LinkedSpec::SourceLocation::Runtime::detached_span_record(
  $guard->{info}, $string_ref,
  $state->{committed_gap_cursor}, $end, 'gap',
 );
 $state->{current_gap} = {
  source_id => $span->{source_id},
  rule_label => $rule,
  invocation_id => $guard->{identity}{invocation_id},
  edge_ordinal => $state->{accepted_edge_count},
  kind => 'tail',
  start => $span->{start},
  end => $span->{end},
  provenance => 'gap',
 };
 $guard->{gap_selected_match_end} = undef;
 $guard->{gap_phase} = defined($phase) && !ref($phase) ? "$phase" : '';
 return 1
}

sub entry_slot {
 my ($descr, $string_ref, $rule) = @_;
 my $guard = LinkedSpec::RecognitionTransactionRuntime::_current_guard(
  $descr, $string_ref, $rule,
 );
 my $entry = ref($guard->{info}) eq 'HASH'
  ? $guard->{info}{$ENTRY_SLOT_KEY}
  : undef;
 return undef unless ref($entry) eq 'HASH' && ref($entry->{slot}) eq 'HASH';
 my $guards = $guard->{context}{guards};
 return undef unless ref($guards) eq 'ARRAY' && @$guards >= 2;
 my $parent = $guards->[-2];
 return undef unless ref($parent) eq 'LinkedSpec::RecognitionTransactionRuntime::InvocationGuard';
 return undef unless ref($parent->{gap_state}) eq 'HASH'
  && ref($parent->{gap_state}{current_gap}) eq 'HASH';
 return undef unless ($entry->{owner_invocation_id} // '') eq
  ($parent->{identity}{invocation_id} // '');
 return undef unless ($entry->{slot}{target_rule} // '') eq ($rule // '');
 return {%{$entry->{slot}}}
}

sub gap_span {
 my ($descr, $string_ref, $rule) = @_;
 my $gap = _current_gap($descr, $string_ref, $rule, 'gap_span');
 return {
  source_id => $gap->{source_id},
  start => $gap->{start},
  end => $gap->{end},
  provenance => $gap->{provenance},
 }
}

sub gap_text {
 my ($descr, $string_ref, $rule) = @_;
 my $guard = LinkedSpec::RecognitionTransactionRuntime::_current_guard(
  $descr, $string_ref, $rule,
 );
 my $gap = _current_gap($descr, $string_ref, $rule, 'gap_text');
 return LinkedSpec::SourceLocation::Runtime::span_text(
  $guard->{info}, $string_ref, $gap->{start}, $gap->{end}, 'gap',
 )
}

sub gap_kind {
 my ($descr, $string_ref, $rule) = @_;
 my $gap = _current_gap($descr, $string_ref, $rule, 'gap_kind');
 return $gap->{kind}
}

sub is_error {
 my ($error) = @_;
 return 1 if blessed($error) && $error->isa('LinkedSpec::InterMatchGapRuntime::Error');
 return 0 unless blessed($error) && $error->isa('LinkedSpec::SourceLocation::Error');
 return 0 unless ($error->{code} // '') eq 'source_location_cursor_regression';
 return ($error->{originating_edge_or_job} // '') =~ /:capture_gaps_commit\z/o ? 1 : 0
}

sub _current_gap {
 my ($descr, $string_ref, $rule, $accessor) = @_;
 my $guard = LinkedSpec::RecognitionTransactionRuntime::_current_guard(
  $descr, $string_ref, $rule,
 );
 my $state = $guard->{gap_state};
 return $state->{current_gap}
  if ref($state) eq 'HASH' && ref($state->{current_gap}) eq 'HASH';
 my $source_id = ref($guard->{info}) eq 'HASH'
  ? $guard->{info}{source_location_source_id}
  : undef;
 die LinkedSpec::InterMatchGapRuntime::Error->new(
  code => 'gap_capture_context_unavailable',
  phase => $guard->{gap_phase} // '',
  rule_label => $rule,
  source_id => defined($source_id) ? $source_id : 'input',
  invocation_id => $guard->{identity}{invocation_id},
  accessor => $accessor,
 )
}

sub _active_state {
 my ($guard) = @_;
 my $state = $guard->{gap_state};
 _internal_error('active invocation has no capture-gaps state')
  unless ref($state) eq 'HASH';
 return $state
}

sub _selected_slot_record {
 my ($descr, $rule, $minfo) = @_;
 my $choice_index = $minfo->{index};
 my $rows = ref($descr->{dependency_slot_map}) eq 'HASH'
  ? $descr->{dependency_slot_map}{$rule}
  : undef;
 $rows = $descr->{spec}{$rule}{dependency_refs}
  unless ref($rows) eq 'ARRAY';
 my $row = ref($rows) eq 'ARRAY' && defined($choice_index)
  ? $rows->[$choice_index]
  : undef;
 _internal_error('selected action edge has no dependency-slot provenance')
  unless ref($row) eq 'HASH';
 my $target_rule = $row->{label};
 my $regex_index = 0 + $row->{idx};
 my $slot_id = $row->{target_slot_id};
 if (!defined($slot_id)) {
  my $target_entry = $descr->{spec}{$target_rule};
  my $regex_slots = ref($target_entry) eq 'HASH'
   && ref($target_entry->{meta}) eq 'HASH'
   ? $target_entry->{meta}{regex_slots}
   : undef;
  if (ref($regex_slots) eq 'ARRAY' && ref($regex_slots->[$regex_index]) eq 'HASH') {
   $slot_id = $regex_slots->[$regex_index]{slot_id};
  }
 }
 return {
  target_rule => $target_rule,
  regex_index => $regex_index,
  slot_id => $slot_id,
  selector_kind => $row->{selector_kind} // 'unindexed',
  authored_selector => $row->{authored_selector},
 }
}

sub _internal_error {
 my ($detail) = @_;
 die "(LinkedSpec::InterMatchGapRuntime) -E- $detail\n"
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::InterMatchGapRuntime::Error
# Purpose: Portable private live gap-context diagnostic.
#------------------------------------------------------------------------------
package LinkedSpec::InterMatchGapRuntime::Error;

use 5.010;
use strict;
use warnings;
use overload '""' => 'as_string', fallback => 1;

sub new {
 my ($class, %fields) = @_;
 my $self = bless {%fields}, $class;
 Hash::Util::lock_hashref($self);
 return $self
}

sub as_string {
 my ($self) = @_;
 return 'LINKEDSPEC_INTER_MATCH_GAP_ERROR:'.($self->{code} // 'inter_match_gap_error')
}

1;
