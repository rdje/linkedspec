use strict;
use warnings;
use Cwd qw(getcwd);
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST::Parser ();

# TYPE-REFERENCE-BOOK.1.2.23.1.7: finite readonly context-scalar result boundary.
my $root = getcwd();
my $sequence = 0;
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
my $template = <<'SPEC';
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>name)/
 /=/
 /(?<value>Alpha)/
 -> Value[2] {ACTION}
SPEC
my @cases = (
 ['producers', q{return([entry_text(),match_text(),match_len(),match_has(value),input_text(),input_len(),cursor_rest()])},
  [['name','Alpha',5,1,'name=Alpha',10,'']]],
 ['named_string_flow', q{a=match_text();b=input_text();return([a.lowercase().split("l")[-1].uppercase(),b.split("=")[-1].uppercase()])},
  [['PHA','ALPHA']]],
 ['direct_string_flow', q{return([match_text().lowercase().split("l")[-1].uppercase(),input_text().split("=")[-1].uppercase()])},
  [['PHA','ALPHA']]],
 ['direct_scalar_flow', q{return([match_len().add(1),input_len().cat("!"),match_has(value).cat("!"),cursor_rest().coalesce("missing").cat("!")])},
  [[6,'10!','1!','!']]],
 ['named_kind_rejection', q{order="";a=match_text();b=match_len();x=a.take({order=cat(order,"A");1});y=b.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([x,y,order])},
  [[undef,undef,'']]],
 ['direct_kind_rejection', q{order="";x=match_text().take({order=cat(order,"A");1});y=match_len().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([x,y,order])},
  [[undef,undef,'']]],
);
push @cases,
 ['quoted_capture_name',q{return([match_has("value"),entry_has("head")])},[[1,1]]],
 ['constant_scalar_root_consumers',q{a="Alpha";b=5;return(["Alpha".take(1),5.set_key("k",1),a.take(1),b.set_key("k",1),match_text().take(1),match_len().set_key("k",1)])},[[undef,undef,undef,undef,undef,undef]]],
 ['normalized_scalar_root_consumers',q{order="";x=match_text().cat("").take({order=cat(order,"A");1});y=match_len().add(0).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([x,y,order])},[[undef,undef,""]]];
push @cases,
 ['named_input_cursor_defaults',q{a=input_text();b=input_len();c=cursor_rest();d=cursor_rest_len();return([a.coalesce("late").split("=")[-1].uppercase(),b.coalesce(0).add(1),c.coalesce("late").cat("!"),d.coalesce(7).add(1)])},[['ALPHA',11,'!',1]]],
 ['direct_input_cursor_defaults',q{return([input_text().coalesce("late").split("=")[-1].uppercase(),input_len().coalesce(0).add(1),cursor_rest().coalesce("late").cat("!"),cursor_rest_len().coalesce(7).add(1)])},[['ALPHA',11,'!',1]]],
 ['input_cursor_consumer_rejection',q{order="";x=input_text().take({order=cat(order,"A");1});y=input_len().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([x,y,order])},[[undef,undef,'']]];
my @rows;
for my $case (@cases) {
 next if @ARGV && !grep {$_ eq $case->[0]} @ARGV;
 my ($id,$action,$expected) = @$case;
 my $source = $template; $source =~ s/ACTION/$action/ or die "missing action";
 my %context;
 my $parser = eval {LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context)};
 my $error = $@ || $context{last_error};
 my $value;
 if (ref($parser) eq 'CODE') {
  my $input = 'name=Alpha';
  $value = eval {$parser->(\$input)};
  $error = $@ || $context{last_error};
 }
 my $descriptor = eval {LinkedSpec::Get(\$source,return_descriptor=>1)};
 my $descriptor_error = $@;
 my $metadata = $descriptor->{spec}{Value}{meta}{action_rewriter};
 my $emitted = eval {LinkedSpec::emit_generated_source(\$source,source_identity=>'context-scalar-results.spec')};
 my $emission_error = $@;
 my $package = 'LinkedSpec::ContextScalarResultIntake'.++$sequence;
 my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
 my $load_error = $@;
 my ($fresh,$fresh_error);
 if ($loaded) {
  my $input = 'name=Alpha'; no strict 'refs';
  $fresh = eval {&{$package.'::Execute'}(\$input)};
  $fresh_error = $@;
 }
 my $substitution = eval {LinkedSpec::call_spec_handler_subst('Value',$action)};
 push @rows, {
  id=>$id,source=>$source,input=>'name=Alpha',expected=>$expected,
  native=>{value=>$value,error=>diagnostic($error)},
  fresh=>{value=>$fresh,loaded=>$loaded ? JSON::PP::true : JSON::PP::false,
   emission_error=>diagnostic($emission_error),load_error=>diagnostic($load_error),error=>diagnostic($fresh_error)},
  metadata=>{map {$_=>$metadata->{$_}} qw(raw_perl_dependency_count unresolved_helper_count language_agnostic_action_ir_ready)},
  descriptor_error=>diagnostic($descriptor_error),substitution=>$substitution,
 };
}
print JSON::PP->new->canonical->utf8->encode({scope=>'finite authored readonly scalar producer, named/direct consumer and capture-name distinctions; Value metadata/substitution corrected; no population claim',cases=>\@rows}),"\n";
