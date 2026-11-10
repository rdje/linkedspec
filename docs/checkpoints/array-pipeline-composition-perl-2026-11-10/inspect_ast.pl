use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();

my $json = JSON::PP->new->canonical->ascii;
my @expressions = (
 'trim_each([" head "]).set_key("k",1)',
 '[" head "].trim_each().set_key("k",1)',
 'filter_match(["head"],/^head/).set_key("k",1)',
 '["head"].filter_match(/^head/).set_key("k",1)',
 'split_each(["head:tail"],":").set_key("k",1)',
 '["head:tail"].split_each({items="bad";items+=1;":"}).set_key("k",1)',
);
for my $expression (@expressions) {
 my $node = LinkedSpec::ActionIR::AST::parse_action_expr($expression, {deps=>{}});
 my $substitution = LinkedSpec::call_spec_handler_subst('Value', 'return(' . $expression . ')');
 print $json->encode({expression=>$expression, node=>$node, substitution=>$substitution}), "\n";
}
