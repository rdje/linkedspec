use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::AST::Parser ();

my $available = LinkedSpec::ActionIR::AST::Parser->can('_with_node_constructions')
 && LinkedSpec::ActionIR::AST::Parser->can('_capture_node_constructions')
 && LinkedSpec::ActionIR::AST::Parser->can('_construction_for');
ok($available, 'private AST construction collector is available');
if (!$available) { done_testing; exit 1 }

sub scope { LinkedSpec::ActionIR::AST::Parser::_with_node_constructions(@_) }
sub capture { LinkedSpec::ActionIR::AST::Parser::_capture_node_constructions(@_) }
sub description { LinkedSpec::ActionIR::AST::Parser::_construction_for(@_) }
my $parse = \&LinkedSpec::ActionIR::AST::Parser::parse_action_expr;

# Expectations come from authored pieces, not the parser's offset search.
my @pieces = ('cat(', '"λ😀"', ', ', '"λ😀"', ')');
my $source = join '', @pieces;
my @bounds = (0);
push @bounds, $bounds[-1] + length($_) for @pieces;
my $ordinary = $parse->($source);
my ($saved, $saved_node);
scope(sub {
 my $result = capture($parse, $source);
 my $node = $result->{value};
 ($saved, $saved_node) = ($result, $node);
 is_deeply($node, $ordinary, 'public AST unchanged by collection');
 is_deeply(description($result, $parse, $node), {
  kind => 'call', source => $source, source_span => {start => 0, end => $bounds[-1]},
 }, 'actual root has independent construction description');
 for my $index (0, 1) {
  my $piece = $index ? 3 : 1;
  is_deeply(description($result, $parse, $node->{args}[$index]), {
   kind => 'string', source => $pieces[$piece],
   source_span => {start => $bounds[$piece], end => $bounds[$piece+1]},
  }, 'actual child keeps its independently authored occurrence');
 }
 isnt(refaddr($node->{args}[0]), refaddr($node->{args}[1]), 'equal children are distinct actual constructions');
 ok(!description({%$result}, $parse, $node), 'copied capture denied');
 ok(!description($result, sub { $parse->(@_) }, $node), 'foreign callback denied');
 ok(!description($result, $parse, {%$node}), 'copied root denied');
 my $d = description($result, $parse, $node);
 $d->{source_span}{start} = 999;
 is_deeply(description($result, $parse, $node), {
  kind => 'call', source => $source, source_span => {start => 0, end => $bounds[-1]},
 }, 'returned description is detached');
 $result->{construction}{source} = 'forged';
 is(description($result, $parse, $node)->{source}, $source, 'descriptive capture field is not identity authority');
 $result->{value} = {%$node};
 ok(!description($result, $parse, $node), 'changed capture value denied');
 $result->{value} = $node;
 $node->{source} .= '!';
 ok(!description($result, $parse, $node), 'mutated constructed scalar denied');
 $node->{source} = $source;
 my $child = $node->{args}[0];
 $node->{args}[0] = {%$child};
 ok(!description($result, $parse, $node), 'equal replacement descendant denied');
 $node->{args}[0] = $child;
 $node->{kind} = 'changed';
 ok(!description($result, $parse, $child), 'changed ancestor denies child lookup');
 $node->{kind} = 'call';
 $node->{args}[0]{value} = 'changed';
 ok(!description($result, $parse, $node), 'changed nested scalar denied');
 $node->{args}[0]{value} = 'λ😀';
 ok(description($result, $parse, $node), 'exact original construction can be restored');
 scope(sub { ok(!description($result, $parse, $node), 'nested scope cannot borrow capture') });
 ok(description($result, $parse, $node), 'outer scope restored');
});
ok(!description($saved, $parse, $saved_node), 'expired construction scope denied');
scope(sub { ok(!description($saved, $parse, $saved_node), 'equal fresh scope cannot borrow capture') });

scope(sub {
 my $foreign = $parse->($source);
 for my $mode (qw(copied foreign changed opaque undef)) {
  my $callback = sub {
   return $foreign if $mode eq 'foreign';
   return 'opaque' if $mode eq 'opaque';
   return undef if $mode eq 'undef';
   my $node = $parse->($_[0]);
   return {%$node} if $mode eq 'copied';
   $node->{source_span}{start} = 1;
   return $node
  };
  my $result = capture($callback, $source);
  ok(!$result->{construction}, "$mode return has no construction grant");
  ok(!description($result, $callback, $result->{value}), "$mode return cannot borrow a recorded node");
  is($result->{value}, 'opaque', 'opaque ordinary return retained') if $mode eq 'opaque';
  is(refaddr($result->{value}), refaddr($foreign), 'foreign ordinary reference retained') if $mode eq 'foreign';
 }
 my ($discarded, $actual);
 my $callback = sub {
  $discarded = $parse->('"discarded"');
  $actual = $parse->($_[0]);
  return $actual
 };
 my $result = capture($callback, $source);
 is(refaddr($result->{value}), refaddr($actual), 'actual callback return retained');
 ok(!description($result, $callback, $discarded), 'unreturned construction denied');
 ok(description($result, $callback, $actual), 'actual returned root selected among constructions');
});

scope(sub {
 my ($count, $context, $opts_seen) = (0);
 my $opts = {base_start => 17};
 my $callback = sub {
  ++$count;
  $context = defined(wantarray) ? (wantarray ? 'list' : 'scalar') : 'void';
  $opts_seen = $_[1];
  $_[0] = '"aliased"';
  return $parse->($_[0], $_[1])
 };
 my $argument = '"before"';
 $@ = 'caller-error';
 my $result = capture($callback, $argument, $opts);
 my $error = $@;
 is($count, 1, 'exactly one callback invocation');
 is($context, 'scalar', 'parse callback scalar context preserved');
 is(refaddr($opts_seen), refaddr($opts), 'argument reference identity preserved');
 is($argument, '"aliased"', 'scalar argument alias preserved');
 is($error, 'caller-error', 'successful caller error preserved');
 is(description($result, $callback, $result->{value})->{source_span}{start}, 17,
  'explicit public base remains descriptive');
});

scope(sub {
 my $failure = bless {}, 'ASTConstruction::Failure';
 my ($inner, $inner_node, $outer_node);
 my $fatal = sub { die $failure };
 my $outer = sub {
  $inner = capture($parse, '"inner"');
  $inner_node = $inner->{value};
  eval { capture($fatal, 'ignored'); 1 };
  is(refaddr($@), refaddr($failure), 'fatal callback exception identity retained');
  $outer_node = $parse->($_[0]);
  return $outer_node
 };
 my $result = capture($outer, $source);
 ok(description($result, $outer, $outer_node), 'outer recorder restored after nested fatal capture');
 ok(description($inner, $parse, $inner_node), 'actual nested capture retains its own construction');
 ok(!description($result, $outer, $inner_node), 'nested construction cannot attach to outer capture');
 eval { scope(sub { capture($fatal, 'ignored') }); 1 };
 is(refaddr($@), refaddr($failure), 'fatal scope exception identity retained');
 ok(description($result, $outer, $outer_node), 'outer registry restored after nested fatal scope');
});

my $outside_count = 0;
my $outside = capture(sub { ++$outside_count; return 'outside' });
is($outside->{value}, 'outside', 'outside-scope ordinary return preserved');
is($outside_count, 1, 'outside-scope callback still called once');
ok(!$outside->{construction}, 'outside scope has no construction description');
my ($void, @list, $scalar);
scope(sub { $void = defined(wantarray) ? 'defined' : 'void' });
@list = scope(sub { return (1, 2) });
$scalar = scope(sub { return defined(wantarray) && !wantarray ? 'scalar' : 'wrong' });
is($void, 'void', 'scope work void context preserved');
is_deeply(\@list, [1, 2], 'scope work list context preserved');
is($scalar, 'scalar', 'scope work scalar context preserved');

# Direct constructor calls retain their original context with and without a
# collector. Only ordinary hash constructors are recorded; void stays void.
for my $active (0, 1) {
 my @contexts;
 my $node = \&LinkedSpec::ActionIR::AST::node;
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::AST::node = sub {
  push @contexts, defined(wantarray) ? (wantarray ? 'list' : 'scalar') : 'void';
  return $node->(@_)
 };
 my $work = sub {
  LinkedSpec::ActionIR::AST::Parser::_node('raw_perl', 'x', 0, 1);
  my @nodes = LinkedSpec::ActionIR::AST::Parser::_node('raw_perl', 'x', 0, 1);
  my $single = LinkedSpec::ActionIR::AST::Parser::_node('raw_perl', 'x', 0, 1);
  return $single
 };
 $active ? scope(sub { capture($work) }) : $work->();
 is_deeply(\@contexts, [qw(void list scalar)], "constructor contexts preserved with collection=$active");
}

for my $text (
 'items += array("λ", "λ")',
 'meta[key][index] = { key : value }',
 'items.map_leaves() { return(cat(index, "=", value)) }.count()',
 'if(flag) { set(x,"a") }',
 'switch(kind) { case("a") { return("A") }; default { return("D") } }',
 'host_unknown + 1',
 " \r\n cat(\r\n\"λ😀\",\r\n\"λ😀\"\r\n) \r\n",
 'cat(,"λ😀",,"λ😀",)',
) {
 my $before = $parse->($text);
 scope(sub {
  my $result = capture($parse, $text);
  is_deeply($result->{value}, $before, 'representative public AST remains exact');
  ok(description($result, $parse, $result->{value}), 'representative actual root remains eligible');
 });
}
my $block_parse = \&LinkedSpec::ActionIR::AST::Parser::parse_action_block;
my $block_source = 'set(x,"λ"); if(flag) { return(cat("λ", "λ")) }';
my $block_before = $block_parse->($block_source);
scope(sub {
 my $result = capture($block_parse, $block_source);
 is_deeply($result->{value}, $block_before, 'public block AST remains exact');
 ok(description($result, $block_parse, $result->{value}), 'actual block root construction retained');
});

done_testing;
