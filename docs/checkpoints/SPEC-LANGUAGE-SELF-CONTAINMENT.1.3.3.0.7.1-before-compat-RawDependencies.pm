package LinkedSpec::ActionIR::RawDependencies;

use 5.010;
use strict;
use warnings;
use LinkedSpec::ActionIR::AST ();

# Whole-statement fallbacks already count their raw source. Span identity keeps
# control aliases singular and equal text at separate occurrences distinct.
sub collect_expression_dependencies {
 my ($source, $events) = @_;
 return [] unless defined($source) && length($source);
 my %covered = map { ($_->{raw} => 1) } grep {
  ref($_) eq 'HASH' && ($_->{kind} // '') eq 'RAW_PERL' && defined($_->{raw})
 } @{ref($events) eq 'ARRAY' ? $events : []};
 my $block = LinkedSpec::ActionIR::AST::parse_action_block($source);
 my %found;
 my $visit;
 $visit = sub {
  my ($node) = @_;
  if (ref($node) eq 'ARRAY') {
   $visit->($_) for @$node;
   return;
  }
  return unless ref($node) eq 'HASH';
  if (($node->{kind} // '') eq 'raw_perl'
   && ($node->{reason} // '') eq 'unsupported_expression'
   && defined($node->{source}) && length($node->{source})) {
   my $span = $node->{source_span};
   my ($start, $end) = @{$span}{qw(start end)};
   die "Raw dependency AST span does not identify action-unit source\n"
    unless defined($start) && defined($end) && $start >= 0 && $end > $start
     && $end <= length($source)
     && substr($source, $start, $end - $start) eq $node->{source};
   my $key = join(':', $start, $end, $node->{reason});
   $found{$key} ||= {
    source => $node->{source}, reason => $node->{reason},
    source_span => {start => $start, end => $end}, source_unit => 0,
   };
   return;
  }
  for my $key (sort keys %$node) {
   next if $key eq 'source' || $key eq 'source_span';
   $visit->($node->{$key});
  }
 };
 for my $statement (@{$block->{statements} || []}) {
  next if $covered{$statement->{source}};
  $visit->($statement);
 }
 undef $visit;
 return [sort {
  $a->{source_span}{start} <=> $b->{source_span}{start}
   || $a->{source_span}{end} <=> $b->{source_span}{end}
   || $a->{reason} cmp $b->{reason}
 } values %found];
}

1;
