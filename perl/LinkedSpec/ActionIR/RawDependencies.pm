package LinkedSpec::ActionIR::RawDependencies;

use 5.010;
use strict;
use warnings;
use LinkedSpec::ActionIR::AST ();

# These sanctioned compatibility contracts own complete legacy statements. A
# canonical outer helper never covers its arbitrary expression descendants.
my %WHOLE_LEGACY_CONTRACT = map { ($_ => 1) } qw(
 assign_call_my assign_call push_child_call_builtin
 push_child_call_indexed_builtin return_call my_declare_bare assign_match_my
 destructure_imatch_list_my regex_subst_assignment next_bare ref_field_assign
 position_tracking print_foreach_iterable split_trim_filter_assignment
 linecount_prefix_newline_matches print_capture_substr
);

sub _parse_dependency_expr {
 my ($source, $start) = @_;
 local $@;
 return eval { LinkedSpec::ActionIR::AST::parse_action_expr($source, {base_start => $start}) }
}

sub _ordinary_assignment_group {
 my ($node) = @_;
 my $source = $node->{source};
 my $start = $node->{source_span}{start};
 while (LinkedSpec::ActionIR::AST::Parser::_outer_delimiter_is_balanced($source, '(', ')')) {
  $source = substr($source, 1, length($source) - 2);
  ++$start;
  my $leading = $source =~ /\A(\s*)/ ? length($1) : 0;
  $start += $leading;
  $source =~ s/\A\s+|\s+\z//g;
 }
 return undef if $source eq $node->{source};
 my $inner = _parse_dependency_expr($source, $start);
 return undef unless ref($inner) eq 'HASH'
  && ($inner->{kind} // '') =~ /\Aassign_(?:scalar|array_append|hash_index|nested_access)\z/;
 return $inner
}

# Whole-statement fallbacks already count their raw source. Span identity keeps
# control aliases singular and equal text at separate occurrences distinct.
sub collect_expression_dependencies {
 my ($source, $events) = @_;
 return [] unless defined($source) && length($source);
 my %covered = map { ($_->{raw} => 1) } grep {
  ref($_) eq 'HASH' && ($_->{kind} // '') eq 'RAW_PERL' && defined($_->{raw})
 } @{ref($events) eq 'ARRAY' ? $events : []};
 my %legacy = map { ($_->{raw} => $_) } grep {
  ref($_) eq 'HASH' && ($_->{source} // '') eq 'helper_contract'
   && defined($_->{raw}) && ($WHOLE_LEGACY_CONTRACT{$_->{contract_id} // ''}
    || ($_->{contract_id} // '') eq 'return_bare' || ($_->{contract_id} // '') eq 'exit_bare')
 } @{ref($events) eq 'ARRAY' ? $events : []};
 my $block = LinkedSpec::ActionIR::AST::parse_action_block($source);
 my %found;
 my $visit;
 $visit = sub {
  my ($node, $deferred) = @_;
  if (ref($node) eq 'ARRAY') {
   $visit->($_, $deferred) for @$node;
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
   if (!$deferred && exists($legacy{$node->{source}})) {
    my $event = $legacy{$node->{source}};
    my $contract = $event->{contract_id};
    if ($contract eq 'return_bare' || $contract eq 'exit_bare') {
     my $payload = $event->{args}{payload};
     if (defined($payload) && !ref($payload)) {
      return unless length($payload);
      my $offset = index($node->{source}, $payload, $contract eq 'return_bare' ? 6 : 4);
      if ($offset >= 0) {
       my $inner = _parse_dependency_expr($payload, $start + $offset);
       if (ref($inner) eq 'HASH') {
        $visit->($inner, 0);
        return;
       }
      }
     }
    } else {
     return;
    }
   }
   if (!$deferred) {
    my $inner = _ordinary_assignment_group($node);
    if ($inner) {
     $visit->($inner, 0);
     return;
    }
   }
   my $key = join(':', $start, $end, $node->{reason});
   $found{$key} ||= {
    source => $node->{source}, reason => $node->{reason},
    source_span => {start => $start, end => $end}, source_unit => 0,
   };
   return;
  }
  for my $key (sort keys %$node) {
   next if $key eq 'source' || $key eq 'source_span';
   $visit->($node->{$key}, $deferred || ($node->{kind} // '') eq 'codeblock_literal');
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
