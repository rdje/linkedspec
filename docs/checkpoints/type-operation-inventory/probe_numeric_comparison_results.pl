use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();

my @cases = (
 [producer => q{return([num_eq(2,2),num_ne(2,3),num_gt(3,2),num_ge(2,2),num_lt(2,3),num_le(2,2),num_eq(2,3),num_ne(2,2),num_gt(2,3),num_ge(2,3),num_lt(3,2),num_le(3,2)])}],
 [boundaries => q{return([num_eq("02","2"),num_eq("-.5",-.5),num_eq(undef,0),num_eq(false,0),num_eq(true,1),num_eq("",0),num_eq("x",0),num_eq([],0),num_eq({},0),num_eq(2),num_eq(2,2,2)])}],
 [short_flow => q{return([2.eq(2).cat("!"),2.ne(3).cat("!"),3.gt(2).cat("!"),2.ge(2).cat("!"),2.lt(3).cat("!"),2.le(2).cat("!"),2.eq(3).coalesce_nonempty("late").cat("!"),2.eq(3).add(2),2.eq(2).cat(",x").split(",").last().uppercase(),2.eq(2).sorted()])}],
 [canonical_flow => q{return([2.num_eq(2).cat("!"),2.num_ne(3).cat("!"),3.num_gt(2).cat("!"),2.num_ge(2).cat("!"),2.num_lt(3).cat("!"),2.num_le(2).cat("!")])}],
 [nested => q{return([cat(num_eq(2,2),"!"),cat(coalesce_nonempty(num_eq(2,3),"late"),"!"),num_add(num_eq(2,3),2),uppercase(last(split(cat(num_eq(2,2),",x"),",")))])}],
 [sources => q{score=2;meta={"n":2};return([score.eq(2),[2].first().eq(2),"aa".length().eq(2),meta.sorted_values().first().eq(2),undef.coalesce_nonempty(2).eq(2),"02".eq(2)])}],
 [invalid_flow => q{return(["x".eq(2).coalesce_nonempty(7).add(1),undef.eq(0).is_undefined().cat("!"),false.eq(0).coalesce_nonempty(7).add(1)])}],
 [effects => q{score=2;order="";value={order=cat(order,"S");score}.eq({order=cat(order,"O");score=3;2}).cat({order=cat(order,"C");score=undef;"!"});return([value,order,score])}],
 [effects_nested => q{score=2;order="";value=cat(num_eq({order=cat(order,"S");score},{order=cat(order,"O");score=3;2}),{order=cat(order,"C");score=undef;"!"});return([value,order,score])}],
 [arity => q{order="";a={order=cat(order,"S");2}.eq();b={order=cat(order,"S");2}.eq({order=cat(order,"O");2},{order=cat(order,"X");3});return([a,b,order])}],
);
my $sequence = 0;
for my $case (@cases) {
 my ($label, $body) = @$case;
 next if !@ARGV && $label eq 'canonical_flow'; # Unsupported names are an opt-in diagnostic only.
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
 if ($label eq 'short_flow' || $label eq 'effects') {
  print 'LOWERED ', LinkedSpec::call_spec_handler_subst('Top', $body), "\n";
 }
 my $emitted = eval { LinkedSpec::emit_generated_source(\$source,
   source_identity => 'numeric-comparison-result-assessment.spec') };
 my $emission_error = $@;
 my $package = 'LinkedSpec::NumericComparisonResultAssessment' . ++$sequence;
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
