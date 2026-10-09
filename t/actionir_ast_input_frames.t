use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::AST::Parser ();

my $available = LinkedSpec::ActionIR::AST::Parser->can('_input_frame_for');
ok($available, 'native AST input frames are available');
if (!$available) { done_testing; exit 1 }
sub scope { LinkedSpec::ActionIR::AST::Parser::_with_node_constructions(@_) }
sub capture { LinkedSpec::ActionIR::AST::Parser::_capture_node_constructions(@_) }
sub frame { LinkedSpec::ActionIR::AST::Parser::_input_frame_for(@_) }
my $parse = \&LinkedSpec::ActionIR::AST::Parser::parse_action_expr;

# Each oracle is authored as ordered pieces; offsets are accumulated, never
# selected by searching equal text or reading the parser's public coordinates.
my @cases = (
 ['twins', ['cat(', 'trim(capture_slice())', ', ', 'trim(capture_slice())', ')'], [1, 3]],
 ['unicode', ['cat(', '"λ😀capture_slice()"', ', ', 'trim(capture_slice())', ')'], [1, 3]],
 ['crlf', [" \r\n cat(\r\n", 'trim(capture_slice())', ",\r\n", 'trim(capture_slice())', "\r\n) \r\n"], [1, 3]],
 ['empty-slots', ['cat(,', 'trim(capture_slice())', ',,', 'trim(capture_slice())', ',)'], [1, 3]],
 ['array', ['[', '"λ😀"', ', ', 'trim(capture_slice())', ']'], [1, 3]],
);
for my $case (@cases) {
 my ($name, $pieces, $argument_pieces) = @$case;
 my $source = join '', @$pieces;
 my @bounds = (0);
 push @bounds, $bounds[-1] + length($_) for @$pieces;
 # The two authored whitespace edges of the CRLF root are independent constants.
 my ($root_start, $root_end) = $name eq 'crlf'
  ? (length(" \r\n "), length($source) - length(" \r\n")) : (0, length($source));
 my $ordinary = $parse->($source, {base_start => 23});
 scope(sub {
  my $result = capture($parse, $source, {base_start => 23});
  my $node = $result->{value};
  is_deeply($node, $ordinary, "$name public AST unchanged");
  is_deeply(frame($result, $parse, $node), {
   source => $source, raw => substr($source, $root_start, $root_end - $root_start),
   source_span => {start => $root_start, end => $root_end},
  }, "$name root uses original input trim, not public base");
  my $args = $name eq 'array' ? $node->{items} : $node->{args};
  for my $index (0, 1) {
   my $piece = $argument_pieces->[$index];
   is_deeply(frame($result, $parse, $args->[$index]), {
    source => $source, raw => $pieces->[$piece],
    source_span => {start => $bounds[$piece], end => $bounds[$piece+1]},
   }, "$name actual argument occurrence follows CSV flush frame");
   next unless $args->[$index]{kind} eq 'call';
   my $child = $args->[$index]{args}[0];
   my $start = $bounds[$piece] + length('trim(');
   is_deeply(frame($result, $parse, $child), {
    source => $source, raw => 'capture_slice()',
    source_span => {start => $start, end => $start + length('capture_slice()')},
   }, "$name nested original frame is explicitly rebased");
  }
 });
}

scope(sub {
 my $source = 'cat("λ😀", "λ😀")';
 my $find = \&LinkedSpec::ActionIR::AST::Parser::_find_piece_offset;
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::AST::Parser::_find_piece_offset = sub { return 0 };
 my $ordinary = $parse->($source);
 my $result = capture($parse, $source);
 is_deeply($result->{value}, $ordinary, 'wrong public search intervention preserves ordinary AST');
 my ($first, $second) = @{$result->{value}{args}};
 is($first->{source_span}{start}, $second->{source_span}{start}, 'public search intervention collapses public twin positions');
 is(frame($result, $parse, $first)->{source_span}{start}, length('cat('), 'first private twin follows original CSV');
 is(frame($result, $parse, $second)->{source_span}{start}, length('cat("λ😀", '), 'second private twin ignores wrong public search');
});

my ($saved, $node);
scope(sub {
 my $source = 'cat("a", "a")';
 $saved = capture($parse, $source);
 $node = $saved->{value};
 ok(!frame({%$saved}, $parse, $node), 'copied native capture denied');
 ok(!frame($saved, sub { $parse->(@_) }, $node), 'foreign native callback denied');
 ok(!frame($saved, $parse, {%$node}), 'copied native node denied');
 my $f = frame($saved, $parse, $node);
 $f->{source_span}{start} = 999;
 is(frame($saved, $parse, $node)->{source_span}{start}, 0, 'native frame description detached');
 $node->{args}[0]{value} = 'changed';
 ok(!frame($saved, $parse, $node->{args}[1]), 'changed native ancestor denies frame');
 $node->{args}[0]{value} = 'a';
 scope(sub { ok(!frame($saved, $parse, $node), 'nested native scope denied') });
 ok(frame($saved, $parse, $node), 'outer native scope restored');
});
ok(!frame($saved, $parse, $node), 'expired native scope denied');

scope(sub {
 for my $mode (qw(foreign changed copied manual)) {
  my $callback = sub {
   return LinkedSpec::ActionIR::AST::Parser::_node('raw_perl', $_[0], 0, length($_[0])) if $mode eq 'manual';
   $_[0] = 'cat("changed", "changed")' if $mode eq 'changed';
   my $value = $parse->($mode eq 'foreign' ? 'cat("foreign", "foreign")' : $_[0]);
   return $mode eq 'copied' ? {%$value} : $value
  };
  my $source = 'cat("a", "a")';
  my $result = capture($callback, $source);
  ok(!frame($result, $callback, $result->{value}), "$mode input has no native original frame");
 }
 my $result = capture($parse, 'items.count()');
 ok(frame($result, $parse, $result->{value}), 'unsupported child route still has explicit native root');
 ok(!frame($result, $parse, $result->{value}{receiver}), 'unsupported fluent child route conservatively declines');
 my $assignment = capture($parse, 'items = cat("a", "a")');
 ok(frame($assignment, $parse, $assignment->{value}), 'unsupported split preserves its explicit native root');
 ok(!frame($assignment, $parse, $assignment->{value}{value}), 'foreign native input root cannot borrow parent frame');
});

scope(sub {
 my ($count, $returned) = (0);
 my $split = \&LinkedSpec::ActionIR::AST::Parser::_split_top_level_csv;
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::AST::Parser::_split_top_level_csv = sub {
  ++$count;
  my $parts = $split->(@_);
  $returned = [@$parts];
  return $returned
 };
 my $source = 'cat("a", "a")';
 my $ordinary = $parse->($source);
 $count = 0;
 my $result = capture($parse, $source);
 is($count, 1, 'actual CSV callback invoked once');
 is_deeply($result->{value}, $ordinary, 'copied CSV ordinary public AST preserved');
 ok(!frame($result, $parse, $result->{value}{args}[0]), 'copied CSV return cannot grant argument frame');
});

scope(sub {
 my $failure = bless {}, 'ASTInput::Failure';
 my $callback = sub {
  eval { capture(sub { die $failure }, $_[0]); 1 };
  is(refaddr($@), refaddr($failure), 'nested input exception retained');
  return $parse->($_[0])
 };
 my $source = 'cat("outer", "outer")';
 $@ = 'input-caller-error';
 my $result = capture($callback, $source);
 my $error = $@;
 ok(frame($result, $callback, $result->{value}), 'outer input frame restored after nested fatal capture');
 is($error, 'input-caller-error', 'input capture preserves successful caller error');
});

# Native frame expectations use the actual leading trim independently of the
# public base, including an ordered zero-width result for all-whitespace input.
for my $source ('', '  ', "\r\n", " \r\n\t\x{2003}") {
 my $ordinary = $parse->($source, {base_start => 7});
 scope(sub {
  my $result = capture($parse, $source, {base_start => 7});
  is_deeply($result->{value}, $ordinary, 'empty native collection preserves ordinary public AST');
  is_deeply(frame($result, $parse, $result->{value}), {
   source => $source, raw => '', source_span => {start => length($source), end => length($source)},
  }, 'empty native frame is ordered after original leading whitespace');
 });
}

done_testing;
