use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.1.5: existing registered final-block vocabulary.
my @rows;
for my $body ('split("a,b",",")[0]', '["a","b"][0]') {
 for my $form (qw(literal attached parenthesized)) {
 my $argument = $form eq 'literal' ? "{|| return($body)}" : "{return($body)}";
 my $call = $form eq 'attached' ? "apply() $argument" : "apply($argument)";
 my $source = "fn apply(callback: codeblock) {return(callback())}\nTop:: I {return($call)}";
 my %context;
 my $parser = LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
 my $input = 'x';my $value = eval {$parser->(\$input)};
 my $error = $@ || $context{last_error};
 my $detail = (reftype($error)//'') eq 'HASH' ? $error->{detail} : undef;
 my $descriptor = LinkedSpec::Get(\$source,return_descriptor=>1);
 my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
 push @rows, {
  source=>$source,value=>$value,
  form=>$form,
  detail=>(reftype($detail)//'') eq 'HASH' ? {map {$_=>$detail->{$_}} qw(code kind)} : undef,
  metadata=>{map {$_=>$metadata->{$_}} qw(raw_perl_dependency_count unresolved_helper_count language_agnostic_action_ir_ready)},
 };
 }
}
print JSON::PP->new->canonical->encode({scope=>'two existing final-body expressions in three admitted callback spellings; no population claim',cases=>\@rows}),"\n";
