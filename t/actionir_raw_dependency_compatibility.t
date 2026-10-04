use strict;
use warnings;
use Test::More;
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();

my $warmup = 'Top:: I { return(0) }';
LinkedSpec::Get(\$warmup, return_descriptor => 1);

my @canonical = (
 'my $retv = call(Leaf)',
 '$retv = call(Leaf)',
 'push @Top, call(Leaf)',
 'push @Top, call(Leaf)->[1]',
 'return call(Leaf)',
 'return 1',
 'return',
 'exit',
 'exit 1',
 'exit(2)',
 'my $retv; my @matches',
 'my @startline = substr($$STRING, 0, $IPOS) =~ /\n/g',
 'my @matches; my $last_pos=$IPOS; $last_pos = pos($$STRING); $IPOS = pos $$STRING; my $shift = $LSPOS - $last_pos - length($LMATCH); push @matches, substr($$STRING, $last_pos, $shift) if $shift',
 '$args =~ s/\s*\)\s*$//',
 'my $args = $IMATCH',
 'my ($attribute_name, $value) = @IMATCH_LIST',
 'print "perl_dquotes:<<$_>>\n" foreach (@matches)',
 'my @parts = grep { length($_) } map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } split /\s*,\s*/, $args',
 '$prev_node_type = $retv->{type}',
 'return((items += "x").count()); return((meta["last"] = value).count_keys())',
);
for my $source (@canonical) {
 subtest "canonical coverage: $source" => sub {
  my ($rewritten, $diag) = LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics('Top', $source);
  is($diag->{canonical_action_ir_fallback_count}, 0, 'existing canonical contract owns the statement');
  is_deeply($diag->{raw_perl_expression_dependencies}, [], 'no false added expression dependency');
 };
}

my @raw = (
 ['canonical outer return', 'return(i+1)', ['i+1']],
 ['bare return payload', 'return i+1', ['i+1']],
 ['bare exit payload', 'exit i+1', ['i+1']],
 ['legacy neighbor', 'my $retv = call(Leaf); i=i+1; return(i)', ['i+1']],
 ['grouped mutation inner value', 'return((items += i+1).count())', ['i+1']],
 ['deferred grouped mutation', 'cb={|| return((items += "x").count()) }; return(cb())', ['(items += "x")']],
 ['unresolved host operand', 'return(Leaf, $x)', ['$x']],
);
for my $case (@raw) {
 subtest "raw remains visible: $case->[0]" => sub {
  my ($rewritten, $diag) = LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics('Top', $case->[1]);
  my @expected;
  for my $token (@{$case->[2]}) {
   my $start = index($case->[1], $token);
   push @expected, {source => $token, reason => 'unsupported_expression',
    source_span => {start => $start, end => $start + length($token)}, source_unit => 0};
  }
  is_deeply($diag->{raw_perl_expression_dependencies}, \@expected, 'authored independent occurrence/source/span oracle');
 };
}
done_testing();
