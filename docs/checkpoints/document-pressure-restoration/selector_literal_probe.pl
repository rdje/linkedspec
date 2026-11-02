use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();

my $json = JSON::PP->new->canonical(1)->allow_nonref(1);
for my $token (qw(true false undef null nothing True FALSE items)) {
 print $json->encode({token=>$token,
  node=>LinkedSpec::ActionIR::AST::parse_action_expr('array('.$token.')')}),"\n";
}
my $spec = 'Top:: I {return([array(true),array(false),array(undef)])}';
my %context;
my $parser = LinkedSpec::Get(\$spec, runtime_ctx_ref=>\%context);
my ($value, $thrown);
if (ref($parser) eq 'CODE') {
 my $input = 'x';
 $value = eval {$parser->(\$input)};
 $thrown = "$@";
}
print $json->encode({route=>'native',spec=>$spec,built=>ref($parser) eq 'CODE'?1:0,
 value=>$value,thrown=>$thrown,error=>$context{last_error}}),"\n";
