use strict;
use warnings;
use utf8;
use JSON::PP ();
use Scalar::Util qw(reftype);
use B ();
use LinkedSpec ();
binmode STDOUT, ':encoding(UTF-8)';
$| = 1;

if (@ARGV && $ARGV[0] eq '--ast') {
 require LinkedSpec::ActionIR::AST;
 for my $source (q{" a ".trim().sorted()},
                 q{{"a"}.uppercase().take({print("must-not-run");1})},
                 q{0.rm_prefix("x").add(1)},
                 q{0.rm_prefix("x")},q{rm_prefix(0,"x")}) {
  print JSON::PP->new->canonical->encode(LinkedSpec::ActionIR::AST::parse_action_expr($source)), "\n";
  print LinkedSpec::call_spec_handler_subst('Top', 'return('.$source.')'), "\n";
 }
 exit;
}
sub error_snapshot {
 my ($error) = @_;
 return $error unless ref($error);
 my $kind = reftype($error) // '';
 return { map { $_ => error_snapshot($error->{$_}) } keys %$error } if $kind eq 'HASH';
 return [map { error_snapshot($_) } @$error] if $kind eq 'ARRAY';
 return "$error";
}

my @cases = (
 [substring_bounds=>q{return([substr(undef,0),substr("abc",undef),substr("abc",1.5),substr("abc",-1,1),substr("abc",0,1.5),substr("abc",0,-1),substr("abc",true),substr("abc",0,undef)])}],
 [kind_flags=>q{return([rm_prefix(0,"x"),rm_suffix(0,"x"),replace_substr(0,"","X"),0,"0"]) }],
 [boundary_plain=>q{return([" a ".trim().sorted(),"a".uppercase().sorted_values()])}],
 [identity_values=>q{return([0.replace_substr("","X"),0.rm_prefix("x"),false.rm_suffix("x"),0.rm_prefix("x").add(1),"0".rm_prefix("x")])}],
 [identity_free_selector=>q{values=["zero","one"];values[rm_prefix(0,"x")]="updated";return(values)}],
 [identity_replace_selector=>q{values=["zero","one"];values[replace_substr(0,"","X")]="updated";return(values)}],
 [identity_suffix_selector=>q{values=["zero","one"];values[rm_suffix(0,"x")]="updated";return(values)}],
 [identity_named_selector=>q{values=["zero","one"];key=rm_prefix(0,"x");values[key]="updated";return(values)}],
 [producer=>q{return([trim(" a "),lowercase("AB"),uppercase("ab"),replace_substr("a-b","-","_"),rm_prefix("pre_a","pre_"),rm_suffix("a_end","_end"),substr("abc",1),cat("a","b"),trim(undef),cat(undef,"x"),replace_substr(0,"","X"),rm_prefix(0,"x"),rm_suffix(false,"x")])}],
 [fluent=>q{return([" a ".trim().cat("!"),"AB".lowercase().cat("!"),"ab".uppercase().cat("!"),"a-b".replace_substr("-","_").cat("!"),"pre_a".rm_prefix("pre_").cat("!"),"a_end".rm_suffix("_end").cat("!"),"abc".substr(1).cat("!"),"a".cat("b").cat("!")])}],
 [nested=>q{return([cat(trim(" a "),"!"),cat(lowercase("AB"),"!"),cat(uppercase("ab"),"!"),cat(replace_substr("a-b","-","_"),"!"),cat(rm_prefix("pre_a","pre_"),"!"),cat(rm_suffix("a_end","_end"),"!"),cat(substr("abc",1),"!"),cat(cat("a","b"),"!")])}],
 [bridge=>q{return([" a,b ".trim().split(",").last().uppercase(),"A,B".lowercase().split(",").last().uppercase(),"a,b".uppercase().split(",").last(),"a-b".replace_substr("-",",").split(",").last().uppercase(),"pre_a,b".rm_prefix("pre_").split(",").last().uppercase(),"a,b_end".rm_suffix("_end").split(",").last().uppercase(),"za,b".substr(1).split(",").last().uppercase(),"a".cat(",b").split(",").last().uppercase()])}],
 [boundary=>q{order="";value={order=cat(order,"S");" a "}.trim().cat({order=cat(order,"C");"!"}).take({order=cat(order,"A");1});return([value,order,"a".uppercase().sorted_values()," a ".trim().sorted()])}],
 [shapes=>q{order="";a={order=cat(order,"S");" a "}.trim({order=cat(order,"A");1});b={order=cat(order,"S");"ab"}.replace_substr({order=cat(order,"A");"a"});c={order=cat(order,"S");"ab"}.rm_prefix();d={order=cat(order,"S");"ab"}.substr();e={order=cat(order,"S");"ab"}.cat();return([a,b,c,d,e,order])}],
 [effects=>q{source="a-b";order="";calls=0;value={order=cat(order,"S");calls=num_add(calls,1);source}.replace_substr({order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"}).cat({order=cat(order,"C");source=undef;"!"});return([value,order,calls,source])}],
 [effects_nested=>q{source="a-b";order="";calls=0;chosen={order=cat(order,"S");calls=num_add(calls,1);source};replaced=replace_substr(chosen,{order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"});value=cat(replaced,{order=cat(order,"C");source=undef;"!"});return([value,order,calls,source])}],
 [identity=>q{values=["zero","one"];values[0.rm_prefix("x")]="updated";return([0.replace_substr("","X"),0.rm_prefix("x"),false.rm_suffix("x"),0.rm_prefix("x").add(1),"0".rm_prefix("x"),values])}],
 [unicode=>q{return([lowercase("ΟΣ"),"ΟΣ".lowercase(),uppercase("Straße ﬃ"),"Straße ﬃ".uppercase(),"a🙂b".substr(1,1),"a🙂b".substr(1,1).cat("!")])}],
 [sources=>q{text=" a ";meta={"name":" a "};return([text.trim().uppercase(),[" a "].first().trim().uppercase(),meta["name"].trim().uppercase(),{" a "}.trim().uppercase(),trim(" a ").uppercase(),[].first().trim(),undef.cat("x").uppercase(),"".trim().cat("!")])}],
);
sub value_flags {
 my ($value) = @_;
 return undef unless ref($value) eq 'ARRAY';
 return [map {
  my $copy = $_;
  my $flags = B::svref_2object(\$copy)->FLAGS;
  { string => ($flags & B::SVf_POK()) ? 1 : 0,
    integer => ($flags & B::SVf_IOK()) ? 1 : 0 }
 } @$value];
}
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
   flags => $label eq 'kind_flags' ? value_flags($value) : undef,
   error => defined($context{last_error}) ? error_snapshot($context{last_error}) : undef, thrown => "$@",
 }), "\n";
 if ($label =~ /^(?:fluent|bridge|effects|boundary|shapes|sources|identity)/) {
  print 'LOWERED ', LinkedSpec::call_spec_handler_subst('Top', $body), "\n";
 }
 my $emitted = eval { LinkedSpec::emit_generated_source(\$source,
   source_identity => 'scalar-string-assessment.spec') };
 my $emission_error = $@;
 my $package = 'LinkedSpec::ScalarStringAssessment' . ++$sequence;
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
   flags => $label eq 'kind_flags' ? value_flags($fresh) : undef,
 }), "\n";
}
