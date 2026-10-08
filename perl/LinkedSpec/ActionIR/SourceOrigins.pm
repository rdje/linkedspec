# Private original-source authority across compiler event copies. No public
# event fields or replacement decisions belong to this owner.
package LinkedSpec::ActionIR::SourceOrigins;

use 5.010;
use Scalar::Util ();

# This dynamic scope is private to one rewrite invocation. Entries retain the
# actual event references, preventing address reuse while copies are assembled.
our $_invocation;

sub _with_source_origins {
 my ($source, $callback) = @_;
 local $_invocation = {source => $source, events => {}};
 if (!defined wantarray) {
  $callback->();
  return
 }
 return $callback->()
}

sub _is_active_for {
 my ($source) = @_;
 return ref($_invocation) eq 'HASH'
  && defined($source) && !ref($source)
  && defined($_invocation->{source}) && !ref($_invocation->{source})
  && $_invocation->{source} eq $source
}

sub _remember_source_origin {
 my ($event, $origin) = @_;
 return $event unless ref($event) eq 'HASH' && ref($origin) eq 'HASH'
  && ref($origin->{event}) eq 'HASH'
  && Scalar::Util::refaddr($origin->{event}) == Scalar::Util::refaddr($event)
  && _is_active_for($origin->{source});
 my $span = $origin->{source_span};
 my ($start, $end) = ref($span) eq 'HASH' ? @{$span}{qw(start end)} : ();
 return $event unless defined($start) && !ref($start) && $start =~ /\A[0-9]+\z/o
  && defined($end) && !ref($end) && $end =~ /\A[0-9]+\z/o
  && $start <= $end && $end <= length($origin->{source})
  && defined($event->{raw}) && !ref($event->{raw})
  && substr($origin->{source}, $start, $end - $start) eq $event->{raw};

 my $key = Scalar::Util::refaddr($event);
 my $previous = $_invocation->{events}{$key};
 if ($previous) {
  # One reference reused for distinct occurrences cannot select either one.
  $previous->{ambiguous} = 1 if $previous->{start} != $start || $previous->{end} != $end;
  return $event
 }
 $_invocation->{events}{$key} = {
  event => $event, raw => $event->{raw}, start => 0 + $start, end => 0 + $end,
 };
 return $event
}

sub _remember_selected_source_origins {
 my ($events, $origins) = @_;
 return unless ref($_invocation) eq 'HASH'
  && ref($events) eq 'ARRAY' && ref($origins) eq 'ARRAY';
 my %selected = map { Scalar::Util::refaddr($_) => 1 } grep { ref($_) eq 'HASH' } @$events;
 for my $origin (@$origins) {
  next unless ref($origin) eq 'HASH' && ref($origin->{event}) eq 'HASH'
   && $selected{Scalar::Util::refaddr($origin->{event})};
  _remember_source_origin($origin->{event}, $origin);
 }
 return
}

sub _origin_for {
 my ($event) = @_;
 return undef unless ref($_invocation) eq 'HASH' && ref($event) eq 'HASH';
 my $entry = $_invocation->{events}{Scalar::Util::refaddr($event)};
 return undef unless $entry && !$entry->{ambiguous}
  && defined($event->{raw}) && !ref($event->{raw}) && $event->{raw} eq $entry->{raw};
 # Return detached coordinates; callers cannot mutate the stored authority.
 return {
  source => $_invocation->{source}, raw => $entry->{raw},
  source_span => {start => $entry->{start}, end => $entry->{end}},
 }
}

sub _copy_source_origin {
 my ($original, $copy) = @_;
 my $origin = _origin_for($original);
 return $copy unless $origin;
 return _remember_source_origin($copy, {%$origin, event => $copy})
}

sub _remember_statement_origin {
 my ($event, $frame) = @_;
 return $event unless ref($event) eq 'HASH' && ref($frame) eq 'HASH'
  && defined($frame->{raw}) && !ref($frame->{raw})
  && defined($event->{raw}) && !ref($event->{raw}) && $event->{raw} eq $frame->{raw};
 return _remember_source_origin($event, {%$frame, event => $event})
}

1;
