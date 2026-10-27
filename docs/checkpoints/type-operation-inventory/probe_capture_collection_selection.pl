use strict;
use warnings;
use utf8;
use Cwd qw(getcwd);
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.1.5: finite public source-class intake.
my $root = getcwd();
my $json = JSON::PP->new->canonical->utf8;
my $sequence = 0;
my $variant = shift(@ARGV) // 'default';
die "expected default or and\n" unless $variant eq 'default' || $variant eq 'and';
my $trace_runtime = (shift(@ARGV) // '') eq '--trace-runtime';
sub diagnostic {
 my ($value) = @_;
 return undef unless defined($value) && (ref($value) || length($value));
 if ((reftype($value) // '') eq 'HASH') {
  return {map { $_ => diagnostic($value->{$_}) }
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

Value:AND
 /(?<head>name)/
 /\s*=\s*/
 /(?<value>[A-Za-z_]+)/
 -> Value[1] {separator=match_text()}
 -> Value[2] {ACTION}
SPEC
$template =~ s/Value:AND/Value:/ if $variant eq 'default';
my @cases = (
 ['producers',q{return([entry_groups(),entry_map(),match_groups(),match_map()])},
  [[['name'],{head=>'name'},['Alpha'],{value=>'Alpha'}]]],
 ['named',q{eg=entry_groups();em=entry_map();mg=match_groups();mm=match_map();return([eg[-1].uppercase(),em["head"].uppercase(),mg[-1].uppercase(),mm["value"].uppercase()])},
  [['NAME','NAME','ALPHA','ALPHA']]],
 ['direct',q{return([entry_groups()[-1].uppercase(),entry_map()["head"].uppercase(),match_groups()[-1].uppercase(),match_map()["value"].uppercase()])},
  [['NAME','NAME','ALPHA','ALPHA']]],
 ['existing_fluent',q{return([entry_groups().join_values("|").uppercase(),entry_map().sorted_keys().last(),match_groups().join_values("|").uppercase(),match_map().sorted_keys().last()])},
  [['NAME','head','ALPHA','value']]],
 ['copy_bridge',q{return([copy(entry_groups())[-1].uppercase(),copy(entry_map())["head"].uppercase(),copy(match_groups())[-1].uppercase(),copy(match_map())["value"].uppercase()])},
  [['NAME','NAME','ALPHA','ALPHA']]],
 ['compatibility_aliases',q{return([entry_named_map(),match_named_map()])},
  [[{head=>'name'},{value=>'Alpha'}]]],
);
my @rows;
@cases = ($cases[0]) if $trace_runtime;
for my $case (@cases) {
 my ($id,$action,$expected) = @$case;
 my $source = $template;
 $source =~ s/ACTION/$action/ or die 'missing action marker';
 my %context;
 my $parser = eval {LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context)};
 my $error = $@ || $context{last_error};
 my $value;
 if (ref($parser) eq 'CODE') {
  my $input = 'name=Alpha';
  LinkedSpec::configure_trace(trace_level=>'debug',trace_log_file=>'',trace_log_mode=>'stdout') if $trace_runtime;
  $value = eval {$parser->(\$input)};
  $error = $@ || $context{last_error};
  LinkedSpec::configure_trace(trace_level=>'none',trace_log_file=>'',trace_log_mode=>'stdout') if $trace_runtime;
 }
 my $descriptor = eval {LinkedSpec::Get(\$source,return_descriptor=>1)};
 my $metadata = $descriptor->{spec}{Value}{meta}{action_rewriter};
 my $emitted = eval {LinkedSpec::emit_generated_source(\$source,source_identity=>'capture-collection-selection.spec')};
 my $emission_error = $@;
 my $package = 'LinkedSpec::CaptureCollectionSelection'.++$sequence;
 my $loaded = defined($emitted) && eval "package $package; $emitted;1";
 my $fresh_error = $@ || $emission_error;
 my $fresh;
 if ($loaded) {
  my $input = 'name=Alpha';no strict 'refs';
  $fresh = eval {&{$package.'::Execute'}(\$input)};
  $fresh_error = $@;
 }
 my $lowered = eval {LinkedSpec::call_spec_handler_subst('Value',$action)};
 my $lowered_error = $@;
 push @rows, {
  id=>$id,source=>$source,input=>'name=Alpha',expected=>$expected,
  native=>{value=>$value,error=>diagnostic($error)},
  fresh=>{loaded=>$loaded?JSON::PP::true:JSON::PP::false,value=>$fresh,error=>diagnostic($fresh_error)},
  metadata=>{map {$_=>$metadata->{$_}} qw(raw_perl_dependency_count unresolved_helper_count language_agnostic_action_ir_ready)},
  substitution=>$lowered,
  substitution_error=>diagnostic($lowered_error),
 };
}
print $json->encode({variant=>$variant,scope=>'authored capture-collection source distinctions; no population claim',cases=>\@rows}),"\n";
