use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();

my @cases = (
 [producer => q{return([num_abs(-3),num_floor(3.7),num_ceil(3.2),num_round(2.5),num_add(2,3),num_sub(5,2),num_mul(2,3),num_div(7,2),num_mod(7,3),num_clamp(12,0,10),num_min(8,3),num_max(2,5)])}],
 [fluent => q{return([-3.abs().cat("!"),3.7.floor().cat("!"),3.2.ceil().cat("!"),2.5.round().cat("!"),2.add(3).cat("!"),5.sub(2).cat("!"),2.mul(3).cat("!"),7.div(2).cat("!"),7.mod(3).cat("!"),12.clamp(0,10).cat("!"),8.min(3).cat("!"),2.max(5).cat("!")])}],
 [nested => q{return([cat(num_abs(-3),"!"),cat(num_floor(3.7),"!"),cat(num_ceil(3.2),"!"),cat(num_round(2.5),"!"),cat(num_add(2,3),"!"),cat(num_sub(5,2),"!"),cat(num_mul(2,3),"!"),cat(num_div(7,2),"!"),cat(num_mod(7,3),"!"),cat(num_clamp(12,0,10),"!"),cat(num_min(8,3),"!"),cat(num_max(2,5),"!")])}],
 [bridge => q{return(2.add(1).cat(",x").split(",").last().uppercase())}],
 [sources => q{score=2;return([num_add(2,3).cat("!"),[2].first().add(3).cat("!"),["a","b"].count().add(3).cat("!"),[1,1].sum().add(3).cat("!")," 2 ".trim().add(3).cat("!"),score.add(3).cat("!")])}],
 [source_control => q{return([num_add(2,3).cat("!"),[2].first().add(3).cat("!"),["a","b"].count().add(3).cat("!"),[1,1].sum().add(3).cat("!")])}],
 [invalid => q{return([num_div(2,0),num_mod(2.5,2),num_clamp(2,3,1),num_add(false,1),num_add(undef,1),num_add("x",1),num_add([],1),num_add({},1),2.div(0).coalesce_nonempty(7).add(1),0.add(0).coalesce_nonempty("late").cat("!")])}],
 [invalid_control => q{return([num_div(2,0),num_mod(2.5,2),num_clamp(2,3,1),num_add(false,1),num_add(undef,1),num_add("x",1),num_add([],1),num_add({},1),num_add(coalesce_nonempty(num_div(2,0),7),1),cat(coalesce_nonempty(num_add(0,0),"late"),"!")])}],
 [overloads => q{order="";array_min={order=cat(order,"A");[2,4]}.min().add(1);scalar_min={order=cat(order,"S");5}.min({order=cat(order,"O");3}).add(1);return([array_min,scalar_min,order,[2,4].max().add(1),[2,4].sum().min(3).add(1)])}],
 [effects => q{score=2;order="";value={order=cat(order,"S");score}.add({order=cat(order,"O");score=9;3}).cat({order=cat(order,"C");score=undef;"!"});return([value,order,score])}],
 [effects_nested => q{score=2;order="";value=cat(num_add({order=cat(order,"S");score},{order=cat(order,"O");score=9;3}),{order=cat(order,"C");score=undef;"!"});return([value,order,score])}],
 [arity => q{order="";a={order=cat(order,"S");2}.abs({order=cat(order,"O");3});b={order=cat(order,"S");2}.add();c={order=cat(order,"S");2}.clamp({order=cat(order,"O");0});return([a,b,c,order])}],
);
my $sequence = 0;
for my $case (@cases) {
 my ($label, $body) = @$case;
 next if @ARGV && $label ne $ARGV[0];
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
 if ($label eq 'fluent' || $label eq 'effects') {
  print 'LOWERED ', LinkedSpec::call_spec_handler_subst('Top', $body), "\n";
 }
 my $emitted = eval { LinkedSpec::emit_generated_source(\$source,
   source_identity => 'scalar-arithmetic-result-assessment.spec') };
 my $emission_error = $@;
 my $package = 'LinkedSpec::ScalarArithmeticResultAssessment' . ++$sequence;
 my $loaded = defined($emitted) ? eval "package $package; $emitted; 1" : 0;
 my $error = $emission_error || $@;
 my $fresh;
 if ($loaded) {
  my $fresh_input = 'x';
  no strict 'refs';
  $fresh = eval { &{$package . '::Execute'}(\$fresh_input) };
  $error = $@;
 }
 print JSON::PP->new->canonical->allow_nonref->encode({
   route => 'fresh', label => $label, loaded => $loaded ? 1 : 0,
   value => $fresh, error => $error,
 }), "\n";
}
