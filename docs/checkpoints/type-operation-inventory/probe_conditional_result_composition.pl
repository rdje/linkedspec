use strict;
use warnings;
use Cwd qw(getcwd);
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST::Parser ();

# TYPE-REFERENCE-BOOK.1.2.23.1.6: finite existing inline-value producer boundary.
my $root = getcwd();
my $sequence = 0;
my $mode = shift(@ARGV) // '';
die "expected --condition-controls or --ast-controls\n"
 unless $mode eq '' || $mode eq '--condition-controls' || $mode eq '--ast-controls';
my $condition_controls = $mode eq '--condition-controls';
if ($mode eq '--ast-controls') {
 my @sources = ('if(true,["a","b"],["bad"])',
  'switch("k",case("k",["a","b"]),default(["bad"]))');
 my @rows = map {{source=>$_,ast=>LinkedSpec::ActionIR::AST::Parser::parse_action_expr($_)}}
  map {($_,$_.'[-1]')} @sources;
 print JSON::PP->new->canonical->utf8->encode({scope=>'existing inline producers and direct bracket AST distinction; no population claim',cases=>\@rows}),"\n";
 exit;
}
sub diagnostic {
 my ($value) = @_;
 return undef unless defined($value) && (ref($value) || length($value));
 if ((reftype($value) // '') eq 'HASH') {
  return {map {$_ => diagnostic($value->{$_})}
   grep {exists $value->{$_}} qw(type stage code kind detail helper_name name summary)};
 }
 my $text = "$value";
 $text =~ s/\Q$root\E/./g;
 return $text;
}
my @cases = (
 ['producers', q{return([if(true,["a","b"],["bad"]),switch("k",case("k",["a","b"]),default(["bad"]))])},
  [['a','b'],['a','b']]],
 ['named', q{a=if(true,["a","b"],["bad"]);b=switch("k",case("k",["a","b"]),default(["bad"]));return([a[-1].uppercase(),b.last().uppercase()])},
  ['B','B']],
 ['direct_methods', q{return([if(true,["a","b"],["bad"]).last().uppercase(),switch("k",case("k",["a","b"]),default(["bad"])).last().uppercase()])},
  ['B','B']],
 ['direct_brackets', q{return([if(true,["a","b"],["bad"])[-1].uppercase(),switch("k",case("k",["a","b"]),default(["bad"]))[-1].uppercase()])},
  ['B','B']],
 ['scalar_methods', q{return([if(false,"bad"," a ").trim().uppercase(),switch("k",case("k",2),default(0)).add(3)])},
  ['A',5]],
 ['lazy_producer', q{order="";selected=if({order=cat(order,"C");true},{order=cat(order,"T");["a","b"]},{order=cat(order,"F");["bad"]});return([selected,order])},
  [['a','b'],'CT']],
);
@cases = (
 ['named_condition', q{order="";flag={order=cat(order,"C");true};selected=if(flag,{order=cat(order,"T");["a","b"]},{order=cat(order,"F");["bad"]});return([selected,order])},
  [['a','b'],'CT']],
 ['block_payload', q{order="";selected=if(true,{order=cat(order,"T");["a","b"]},{order=cat(order,"F");["bad"]});return([selected,order])},
  [['a','b'],'T']],
 ['elseif_condition', q{order="";selected=if(false,["bad"],elseif({order=cat(order,"E");true},{order=cat(order,"T");["a","b"]}),else({order=cat(order,"F");["bad"]}));return([selected,order])},
  [['a','b'],'ET']],
 ['switch_subject', q{order="";selected=switch({order=cat(order,"S");"k"},case("k",{order=cat(order,"T");["a","b"]}),default({order=cat(order,"F");["bad"]}));return([selected,order])},
  [['a','b'],'ST']],
) if $condition_controls;
my @rows;
for my $case (@cases) {
 my ($id,$action,$expected) = @$case;
 my $source = "Top:: I {$action}";
 my %context;
 my $parser = eval {LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context)};
 my $error = $@ || $context{last_error};
 my $value;
 if (ref($parser) eq 'CODE') {
  my $input = 'x';
  $value = eval {$parser->(\$input)};
  $error = $@ || $context{last_error};
 }
 my $descriptor = eval {LinkedSpec::Get(\$source,return_descriptor=>1)};
 my $descriptor_error = $@;
 my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
 my $emitted = eval {LinkedSpec::emit_generated_source(\$source,source_identity=>'conditional-result-composition.spec')};
 my $emission_error = $@;
 my $package = 'LinkedSpec::ConditionalResultIntake'.++$sequence;
 my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
 my $load_error = $@;
 my ($fresh,$fresh_error);
 if ($loaded) {
  my $input = 'x'; no strict 'refs';
  $fresh = eval {&{$package.'::Execute'}(\$input)};
  $fresh_error = $@;
 }
 my $substitution = eval {LinkedSpec::call_spec_handler_subst('Top',$action)};
 push @rows, {
  id=>$id,source=>$source,input=>'x',expected=>$expected,
  native=>{value=>$value,error=>diagnostic($error)},
  fresh=>{value=>$fresh,loaded=>$loaded ? JSON::PP::true : JSON::PP::false,
   emission_error=>diagnostic($emission_error),load_error=>diagnostic($load_error),error=>diagnostic($fresh_error)},
  metadata=>{map {$_=>$metadata->{$_}} qw(raw_perl_dependency_count unresolved_helper_count language_agnostic_action_ir_ready)},
  descriptor_error=>diagnostic($descriptor_error),substitution=>$substitution,
 };
}
print JSON::PP->new->canonical->utf8->encode({scope=>
 $condition_controls ? 'four authored inline condition, payload and subject controls; no population claim'
 : 'six authored ordinary inline-control producer and composition distinctions; no population claim',cases=>\@rows}),"\n";
