use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();

if (@ARGV && $ARGV[0] eq '--ast') {
 require LinkedSpec::ActionIR::AST;
 for my $source (q{and(true).cat(",x").split(",").last().uppercase()},
                 q{split(cat(and(true),",x"),",")},
                 q{and(true).cat("x").sorted_values()}) {
  print JSON::PP->new->canonical->encode(LinkedSpec::ActionIR::AST::parse_action_expr($source)), "\n";
  print LinkedSpec::call_spec_handler_subst('Top', 'return('.$source.')'), "\n";
 }
 exit;
}

my @cases = (
 [producer=>q{return([and(true),and(false),or(false,true),or(false,0),not(false),not(true)])}],
 [fluent=>q{return([and(true).cat("!"),and(false).cat("!"),or(false,true).cat("!"),or(false,0).cat("!"),not(false).cat("!"),not(true).cat("!")])}],
 [nested=>q{return([cat(and(true),"!"),cat(and(false),"!"),cat(or(false,true),"!"),cat(or(false,0),"!"),cat(not(false),"!"),cat(not(true),"!")])}],
 [bridge=>q{return(and(true).cat(",x").split(",").last().uppercase())}],
 [defaults=>q{return([and(false).coalesce_nonempty("late").cat("!"),and(true).coalesce_nonempty("late").cat("!"),or(false).add(1).coalesce_nonempty(["a","b"]).last().uppercase(),and(false).is_defined().cat("!"),not(false).sorted(),and(true).cat("x").sorted_values()])}],
 [sources=>q{flag=and(false);meta={"flag":or(false,true)};return([flag.cat("!"),[not(false)].first().cat("!"),meta["flag"].cat("!"),{and(false)}.cat("!"),true.cat("!"),false.cat("!")])}],
 [effects=>q{source=true;order="";calls=0;value=and({order=cat(order,"L");calls=num_add(calls,1);source},{order=cat(order,"R");calls=num_add(calls,1);source=false;false}).cat({order=cat(order,"C");"!"});return([value,order,calls,source])}],
 [effects_nested=>q{source=true;order="";calls=0;value=cat(and({order=cat(order,"L");calls=num_add(calls,1);source},{order=cat(order,"R");calls=num_add(calls,1);source=false;false}),{order=cat(order,"C");"!"});return([value,order,calls,source])}],
 [truthiness=>q{return([and("0").cat("!"),or("false").cat("!"),not([]).cat("!"),not({}).cat("!"),not([undef]).cat("!"),not({"a":undef}).cat("!")])}],
 [bridge_nested=>q{return(uppercase(last(split(cat(and(true),",x"),","))))}],
 [default_false=>q{return(and(false).coalesce_nonempty("late").cat("!"))}],
 [default_true=>q{return(and(true).coalesce_nonempty("late").cat("!"))}],
 [default_bridge=>q{return(or(false).add(1).coalesce_nonempty(["a","b"]).last().uppercase())}],
 [defined=>q{return(and(false).is_defined().cat("!"))}],
 [incompatible_array=>q{return(not(false).sorted())}],
 [incompatible_hash=>q{return(and(true).cat("x").sorted_values())}],
 [incompatible=>q{return([not(false).sorted(),and(true).cat("x").sorted_values()])}],
 [arity_direct=>q{return(not({fail("must-not-run")},{fail("must-not-run")}))}],
 [arity_nested=>q{return(cat(not({fail("must-not-run")},{fail("must-not-run")}),"!"))}],
 [arity_known=>q{order="";return(not({order=cat(order,"L");true},{order=cat(order,"R");false}).cat("!"))}],
 [arity=>q{return(not({fail("must-not-run")},{fail("must-not-run")} ).cat("!"))}],
);
my $sequence = 0;
for my $case (@cases) {
 my ($label, $body) = @$case;
 next if @ARGV && !grep { $_ eq $label } @ARGV;
 my $source = 'Top:: I {' . $body . '}';
 my (%context, $dump);
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context,
   dump_parser_source => 1, parser_source_ref => \$dump);
 my $input = 'x';
 my $value = eval { $parser->(\$input) };
 print JSON::PP->new->canonical->allow_nonref->encode({
   route => 'native', label => $label, value => $value,
   error => $context{last_error}, thrown => "$@",
 }), "\n";
 if ($label eq 'fluent' || $label eq 'bridge' || $label eq 'effects' || $label =~ /^(?:arity|default|defined|incompatible|sources)/) {
  print 'LOWERED ', LinkedSpec::call_spec_handler_subst('Top', $body), "\n";
 }
 my $emitted = eval { LinkedSpec::emit_generated_source(\$source,
   source_identity => 'logical-result-assessment.spec') };
 my $emission_error = $@;
 my $package = 'LinkedSpec::LogicalResultAssessment' . ++$sequence;
 my $loaded = defined($emitted) ? eval "package $package; $emitted; 1" : 0;
 my $error = "$emission_error$@";
 my $fresh;
 if ($loaded) {
  my $fresh_input = 'x';
  no strict 'refs';
  $fresh = eval { &{$package . '::Execute'}(\$fresh_input) };
  $error = "$@";
 }
 print JSON::PP->new->canonical->allow_nonref->encode({
   route => 'fresh', label => $label, loaded => $loaded ? 1 : 0,
   value => $fresh, error => $error,
 }), "\n";
}
