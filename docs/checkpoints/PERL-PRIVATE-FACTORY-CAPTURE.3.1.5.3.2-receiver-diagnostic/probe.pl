use strict;
use warnings;
use JSON::PP;
use LinkedSpec;
my @rows;
for my $tail (q{meta.copy()}, q{copy(meta)}, q{meta.copy().flat_hash().count_keys()}) {
 my $action = q{meta = {"k": "v"}; return(}.$tail.q{)};
 my $spec = "Top::\n /x/ -> Done { $action }\n\nDone::\n /[a-z]+/\n";
 my ($value, $lowered);
 my $ok = eval {
  $lowered = LinkedSpec::call_spec_handler_subst('Top', $action);
  my $parser = LinkedSpec::Get(\$spec);
  my $input = 'xhello';
  $value = $parser->(\$input);
  1;
 };
 push @rows, {tail=>$tail, lowered=>$lowered, value=>$value, error=>$ok ? undef : "$@"};
}
my $legacy = eval {
 LinkedSpec::ActionIR::MethodLowering::_normalize_hash_receiver_value_chain_expr(
  'meta.copy()', {trim_action_ir_value=>sub {$_[0]},
                  parse_method_function_expr=>sub {{method=>'copy',args=>[]}},
                  bare_symbol_kind=>sub {'hash'}});
};
print JSON::PP->new->canonical->pretty->encode({public=>\@rows,
 legacy=>{value=>$legacy,error=>"$@"}});
