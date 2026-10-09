use strict;
use warnings;
use utf8;
use Test::More;
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::ActionIR::AST::Parser ();

my $parse = \&LinkedSpec::ActionIR::AST::parse_action_expr;
for my $base (0, 7, 23) {
 for my $source ('', '  ', "\r\n", " \r\n\t\x{2003}", undef) {
  my $length = defined($source) ? length($source) : 0;
  my $point = $base + $length;
  my $wanted = {kind => 'raw_perl', reason => 'empty_expression', source => '',
   source_span => {start => $point, end => $point}};
  my $expr = $parse->($source, {base_start => $base});
  is_deeply($expr, $wanted, 'empty expression has ordered original public interval');
  is_deeply(LinkedSpec::ActionIR::AST::parse_action_statement($source, {base_start => $base}),
   {kind => 'action_stmt', source => '', source_span => {start => $point, end => $point},
    drops_value => 1, expr => $wanted}, 'empty statement has ordered original public interval');
  LinkedSpec::ActionIR::AST::Parser::_with_node_constructions(sub {
   my $capture = LinkedSpec::ActionIR::AST::Parser::_capture_node_constructions($parse, $source, {base_start => $base});
   is_deeply(LinkedSpec::ActionIR::AST::Parser::_input_frame_for($capture, $parse, $capture->{value}),
    defined($source) ? {source => $source, raw => '', source_span => {start => $length, end => $length}} : undef,
    'native empty input frame remains ordered independently of public base');
  });
 }
}

# Authored leading/body/trailing pieces define the expected original interval.
# Whitespace inside a quoted body belongs to the literal, not the edge trim.
my @nonempty = (
 ['  ', '"λ😀"', "\r\n", 'string'],
 ["\r\n", 'cat("λ", "😀")', "\t ", 'call'],
 [' ', 'value', '  ', 'variable'],
 [' ', '[1, 2]', ' ', 'array_literal'],
 ['', "\" \t \"", ' ', 'string'],
);
for my $base (0, 23) {
 for my $case (@nonempty) {
  my ($leading, $body, $trailing, $kind) = @$case;
  my $source = $leading . $body . $trailing;
  my $start = length($leading);
  my $end = $start + length($body);
  my $node = $parse->($source, {base_start => $base});
  is_deeply({map { $_ => $node->{$_} } qw(kind source source_span)},
   {kind => $kind, source => $body, source_span => {start => $base + $start, end => $base + $end}},
   'nonempty original public text and interval remain exact');
  LinkedSpec::ActionIR::AST::Parser::_with_node_constructions(sub {
   my $capture = LinkedSpec::ActionIR::AST::Parser::_capture_node_constructions($parse, $source, {base_start => $base});
   is_deeply(LinkedSpec::ActionIR::AST::Parser::_input_frame_for($capture, $parse, $capture->{value}),
    {source => $source, raw => $body, source_span => {start => $start, end => $end}},
    'nonempty native parser interval remains exact');
  });
 }
}
done_testing;
