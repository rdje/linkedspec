use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.29.1 — ordinary static names and function fence.
my $json=JSON::PP->new->canonical;
my $sequence=0;
sub capture_source {
 my ($action,$zero)=@_;
 my $head=$zero ? '0' : 'name';
 return "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>$head)(?<empty>)(?<missing>x)?/\n /=/\n /(?<value>Alpha)(?<empty>)(?<missing>x)?/\n -> Value[2] {$action}\n";
}
sub check_source {
 my ($label,$source,$input,$expected,$rule,$unsupported)=@_;
 $rule //= 'Value';$unsupported //= [];
 subtest $label=>sub {
  my %context;
  my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
  my $native_input=$input;
  my $native=eval {$parser->(\$native_input)};
  ok(!$@ && !$context{last_error},'native has no host failure') or diag("$@");
  is($json->encode($native),$json->encode($expected),'native exact values/kinds/effects');
  my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'named-capture-static-names.spec');
  my $package='LinkedSpec::NamedCaptureStaticNames'.++$sequence;
  my $loaded=eval "package $package; $emitted; 1";
  ok($loaded,'fresh parser compiles') or diag($@);
  if ($loaded) {
   my $fresh_input=$input;no strict 'refs';
   my $fresh=eval {&{$package.'::Execute'}(\$fresh_input)};
   ok(!$@,'fresh has no host failure') or diag("$@");
   is($json->encode($fresh),$json->encode($expected),'fresh exact values/kinds/effects');
  }
  my $d=LinkedSpec::Get(\$source,return_descriptor=>1);
  my $m=$d->{spec}{$rule}{meta}{action_rewriter};
  is($m->{raw_perl_dependency_count},0,'typed source with no raw fallback');
  if (@$unsupported) {
   ok(!$m->{language_agnostic_action_ir_ready},'unsupported shape/context stays unready');
   my %names=map{$_=>1}@{$m->{unresolved_helpers} // []};
   ok($names{$_},"explicit unsupported helper $_") for @$unsupported;
  } else {
   is($m->{unresolved_helper_count},0,'static names resolve');
   ok($m->{language_agnostic_action_ir_ready},'ready metadata describes working getters');
  }
 };
}
check_source('bare and quoted names retain capture identity through shadowing and dropped calls',capture_source(q{
 entry_named("head");entry_has("head");match_named("value");match_has("value");
 head="value";value="head";
 return([entry_named(head),entry_has(head),match_named(value),match_has(value),entry_named("head"),entry_has('head'),match_named('value'),match_has("value")]);
}), 'name=Alpha', [['name',1,'Alpha',1,'name',1,'Alpha',1]]);
check_source('literal names preserve zero empty missing and punctuation data',capture_source(q{
 head="head";
 return([entry_named("head"),entry_named('empty'),entry_named("missing"),entry_has("empty"),entry_has("missing"),match_named("value"),match_named('empty'),match_named("missing"),match_has("empty"),match_has("missing"),entry_has(""),match_has("not-a-capture"),entry_has("head'quote"),entry_has("$head")]);
},1), '0=Alpha', [['0','',undef,1,0,'Alpha','',undef,1,0,0,0,0,0]]);
check_source('ordinary getters compose and forward explicit function arguments',
 'fn upper(text){return(text.uppercase())}' . "\n" . capture_source(q{
 return([upper(entry_named("head")),upper(match_named("value")),entry_named("absent").coalesce("fallback").uppercase(),match_has("value").cat("!")]);
}), 'name=Alpha', [['NAME','ALPHA','FALLBACK','1!']]);
check_source('unsupported name shapes use explicit unready markers without operand effects',q{Top:: I {
 touch=0;
 return([entry_named(),entry_has("head","extra"),match_named({touch=1;"value"}),match_has(cat("v","alue")),touch]);
}}, 'x', [undef,undef,undef,undef,0], 'Top', [qw(entry_named entry_has match_named match_has)]);
my @readers=qw(entry_named entry_has match_named match_has input_text input_len input_end_pos input_end_line input_end_col input_slice cursor_pos cursor_line cursor_col cursor_rest cursor_rest_len);
my $body=join(',',map {$_ eq 'input_slice' ? 'input_slice(0,1)' : /_(?:named|has)$/ ? $_.'("head")' : $_.'()'} @readers);
my $function='fn invalid_state(){return(['.$body.'])} Top:: I {return(invalid_state())}';
check_source('pure functions retain parser-state reader fence', $function,'x',[(undef)x@readers],'Top',\@readers);
done_testing;
