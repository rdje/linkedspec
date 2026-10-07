package LinkedSpec::ActionIR::SourceMembership;

use 5.010;
use strict;
use warnings;
use Scalar::Util ();
use LinkedSpec::OwnerDispatch ();
use LinkedSpec::ActionIR::MethodExpr ();

# Reuse the existing helper-role and numeric-slash discriminator. These ranges
# describe data interiors; the original source is never masked or reparsed.
# Quote openers remain eligible because a literal receiver can start there.
sub _literal_source_ranges {
    my ($source) = @_;
    my %helper_patterns = map { $_->[0] => $_->[1] }
        @{LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges($source)};
    my @ranges;
    my $length = length($source);
    for (my $pos = 0; $pos < $length; ++$pos) {
        my $char = substr($source, $pos, 1);
        # Comment membership has a separate owner. Ignore its quote delimiters
        # here so an unmatched comment quote cannot swallow the following line.
        if ($char eq '#') {
            ++$pos while $pos < $length && substr($source, $pos, 1) ne "\n";
            next;
        }
        my $end = LinkedSpec::ActionIR::MethodExpr::_host_quote_end($source, $pos);
        if (!defined($end) && ($char eq '"' || $char eq "'" || $char eq chr(96))) {
            $end = $pos + 1;
            while ($end < $length) {
                my $quoted = substr($source, $end, 1);
                if ($quoted eq '\\') { $end += 2; next }
                ++$end;
                last if $quoted eq $char;
            }
        }
        if (!defined($end) && $char eq '/') {
            $end = $helper_patterns{$pos};
            if (!defined($end)) {
                my $prefix = substr($source, 0, $pos);
                if ($prefix =~ /(?:\A\s*|[\(\[,=~!]\s*)\z/o
                    && 1) {
                    $end = LinkedSpec::ActionIR::MethodExpr::_slash_literal_end($source, $pos);
                }
            }
        }
        next unless defined($end);
        $end = $length if $end > $length;
        push @ranges, [$pos, $end];
        $pos = $end - 1;
    }
    return \@ranges;
}

sub _origin_is_literal_data {
    my ($source, $event, $origin, $ranges) = @_;
    # A foreign callback's source cannot authorize coordinates in this action.
    return 0 unless defined($origin->{source}) && !ref($origin->{source})
        && $origin->{source} eq $source;
    my $span = $origin->{source_span};
    my ($start, $end) = ref($span) eq 'HASH' ? @{$span}{qw(start end)} : ();
    die "(LinkedSpec::ActionIR::SourceMembership) -E- invalid source authority\n"
        unless defined($start) && !ref($start) && $start =~ /\A[0-9]+\z/o
        && defined($end) && !ref($end) && $end =~ /\A[0-9]+\z/o
        && $start <= $end && $end <= length($source)
        && defined($event->{raw}) && !ref($event->{raw})
        && substr($source, $start, $end - $start) eq $event->{raw};
    for my $range (@$ranges) {
        return 1 if $start > $range->[0] && $start < $range->[1];
    }
    return 0;
}

# Unused by compiler discovery until its separately verified integration slice.
# Events without real, reference-bound origins stay opaque to this selector.
# Actual event order and event/argument/origin references are retained.
sub _select_executable_source_events {
    my ($source, $scan) = @_;
    return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
        return $scan unless defined($source) && !ref($source)
            && ref($scan) eq 'HASH' && ref($scan->{events}) eq 'ARRAY'
            && @{$scan->{events}} && ref($scan->{source_origins}) eq 'ARRAY'
            && @{$scan->{source_origins}};
        my %by_event;
        for my $origin (@{$scan->{source_origins}}) {
            next unless ref($origin) eq 'HASH' && ref($origin->{event}) eq 'HASH';
            push @{$by_event{Scalar::Util::refaddr($origin->{event})}}, $origin;
        }
        my $ranges = _literal_source_ranges($source);
        my (@events, @origins);
        my $removed = 0;
        for my $event (@{$scan->{events}}) {
            my $queue = ref($event) eq 'HASH'
                ? $by_event{Scalar::Util::refaddr($event)} : undef;
            my $origin = $queue && @$queue ? shift @$queue : undef;
            if ($origin && _origin_is_literal_data($source, $event, $origin, $ranges)) {
                ++$removed;
                next;
            }
            push @events, $event;
            push @origins, $origin if $origin;
        }
        return $scan unless $removed;
        return {%$scan, events => \@events, source_origins => \@origins};
    });
}

1;
