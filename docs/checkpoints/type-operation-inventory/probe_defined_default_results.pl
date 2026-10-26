use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
$| = 1;

if (@ARGV && $ARGV[0] eq '--ast') {
 require LinkedSpec::ActionIR::AST;
 for my $source (q{undef.coalesce(" chosen ").trim().uppercase()},
                 q{2.div(0).coalesce(7).add(1)},
                 q{[].first().coalesce(["a"]).last().uppercase()},
                 q{{"b":"b","a":"a"}.coalesce({"late":1}).sorted_values().first().uppercase()}) {
  print JSON::PP->new->canonical->encode(LinkedSpec::ActionIR::AST::parse_action_expr($source)), "\n";
  print LinkedSpec::call_spec_handler_subst('Top', 'return('.$source.')'), "\n";
 }
 exit;
}

sub error_snapshot {
 my ($error) = @_;
 return { %$error } if ref($error) eq 'HASH';
 return "$error";
}

my @cases = (
 [hash_consumer_nested=>q{meta={"a":"a","b":"b"};order="";chosen=coalesce(undef,meta);key={order=cat(order,"C");meta["a"]="z";"a"};picked=pick_keys(chosen,key);value=uppercase(first(sorted_values(picked)));return([value,order,meta])}],
 [hash_consumer=>q{meta={"a":"a","b":"b"};order="";value=undef.coalesce(meta).pick_keys({order=cat(order,"C");meta["a"]="z";"a"}).sorted_values().first().uppercase();return([value,order,meta])}],
 [hash_consumer_nested_block=>q{meta={"a":"a","b":"b"};order="";chosen=coalesce(undef,meta);picked=pick_keys(chosen,{order=cat(order,"C");meta["a"]="z";"a"});value=uppercase(first(sorted_values(picked)));return([value,order,meta])}],
 [prefix_effects=>q{order="";value={order=cat(order,"S");undef}.coalesce("kept").cat({order=cat(order,"C");"!"}).sorted_values();return([value,order])}],
 [copy_control=>q{items=["a","b"];meta={"a":"a","b":"b"};chosen_items=coalesce(undef,items);chosen_meta=coalesce(undef,meta);items[0]="z";meta["a"]="z";return([chosen_items,chosen_meta,items,meta])}],
 [free_selector=>q{values=["zero","one"];values[coalesce(undef,1)]="updated";return(values)}],
 [receiver_selector=>q{values=["zero","one"];values[undef.coalesce(1)]="updated";return(values)}],
 [producer=>q{return([coalesce(undef,"fallback"),coalesce("","fallback"),coalesce(0,7),coalesce(false,true),coalesce(undef,undef),coalesce(undef,[2,3]),coalesce(undef,{"b":"b","a":"a"})])}],
 [fluent=>q{return([undef.coalesce(" chosen ").trim().uppercase(),"".coalesce("late").cat("!"),0.coalesce(7).add(1),false.coalesce(true).cat("!"),undef.coalesce(undef," chosen ").trim().uppercase()])}],
 [nested=>q{return([uppercase(trim(coalesce(undef," chosen "))),cat(coalesce("","late"),"!"),num_add(coalesce(0,7),1),cat(coalesce(false,true),"!"),uppercase(trim(coalesce(undef,undef," chosen ")))])}],
 [bridge=>q{return([undef.coalesce(["a","b"]).last().uppercase(),undef.coalesce({"b":"b","a":"a"}).sorted_values().first().uppercase(),coalesce(undef,["a","b"]).last().uppercase()])}],
 [bridge_nested=>q{return([uppercase(last(coalesce(undef,["a","b"]))),uppercase(first(sorted_values(coalesce(undef,{"b":"b","a":"a"}))))])}],
 [retained=>q{return([[].coalesce(["late"]).count(),{}.coalesce({"late":1}).count_keys(),["a","b"].coalesce(["late"]).last().uppercase(),{"b":"b","a":"a"}.coalesce({"late":1}).sorted_values().first().uppercase()])}],
 [retained_nested=>q{return([count(coalesce([],["late"])),count_keys(coalesce({},{"late":1})),uppercase(last(coalesce(["a","b"],["late"]))),uppercase(first(sorted_values(coalesce({"b":"b","a":"a"},{"late":1}))))])}],
 [sources=>q{score=undef;meta={"n":undef};return([score.coalesce("x").uppercase(),[].first().coalesce("x").uppercase(),meta["n"].coalesce("x").uppercase(),2.div(0).coalesce(7).add(1),"".trim().coalesce("late").cat("!"),and(false).coalesce(true).cat("!")])}],
 [effects=>q{calls=0;order="";source=undef;fallback=["a","b"];value={order=cat(order,"S");calls=num_add(calls,1);source}.coalesce({order=cat(order,"D");source=1;fallback},{order=cat(order,"L");["late"]}).join_values({order=cat(order,"C");fallback=["z"];":"}).uppercase();return([value,order,calls,source,fallback])}],
 [effects_nested=>q{calls=0;order="";source=undef;fallback=["a","b"];chosen=coalesce({order=cat(order,"S");calls=num_add(calls,1);source},{order=cat(order,"D");source=1;fallback},{order=cat(order,"L");["late"]});value=uppercase(join_values({order=cat(order,"C");fallback=["z"];":"},chosen));return([value,order,calls,source,fallback])}],
 [lazy=>q{hits=0;a="".coalesce({hits=num_add(hits,1);"late"});b=false.coalesce({hits=num_add(hits,1);true});c=0.coalesce({hits=num_add(hits,1);7});d="safe".coalesce({target=1;target[0]=2;"bad"});return([a,b,c,d,hits])}],
 [lazy_nested=>q{hits=0;a=coalesce("",{hits=num_add(hits,1);"late"});b=coalesce(false,{hits=num_add(hits,1);true});c=coalesce(0,{hits=num_add(hits,1);7});d=coalesce("safe",{target=1;target[0]=2;"bad"});return([a,b,c,d,hits])}],
 [arity=>q{order="";a={order=cat(order,"S");undef}.coalesce();b="kept".coalesce();return([a,b,order])}],
 [free_one=>q{return(coalesce("kept"))}],
 [exhaustion=>q{return([undef.coalesce(undef),undef.coalesce(undef,undef),coalesce(undef,undef),"".coalesce(undef)])}],
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
 if ($label eq 'fluent' || $label eq 'bridge' || $label eq 'effects' || $label =~ /^(?:arity|default|defined|incompatible|sources|hash_consumer|prefix_effects)/) {
  print 'LOWERED ', LinkedSpec::call_spec_handler_subst('Top', $body), "\n";
 }
 my $emitted = eval { LinkedSpec::emit_generated_source(\$source,
   source_identity => 'defined-default-assessment.spec') };
 my $emission_error = $@;
 my $package = 'LinkedSpec::DefinedDefaultAssessment' . ++$sequence;
 my $loaded = defined($emitted) ? eval "package $package; $emitted; 1" : 0;
 my $error = error_snapshot($emission_error || $@);
 my $fresh;
 if ($loaded) {
  my $fresh_input = 'x';
  no strict 'refs';
  $fresh = eval { &{$package . '::Execute'}(\$fresh_input) };
  $error = error_snapshot($@);
 }
 print JSON::PP->new->canonical->allow_nonref->encode({
   route => 'fresh', label => $label, loaded => $loaded ? 1 : 0,
   value => $fresh, error => $error,
 }), "\n";
}
