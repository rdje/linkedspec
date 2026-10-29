use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::RecognitionTransactionRuntime ();

# TYPE-REFERENCE-BOOK.1.2.23.3.48.2.6: rule labels, not host identifiers.
my $json=JSON::PP->new->canonical->allow_nonref;
sub read_json {
 my ($path)=@_;
 open my $fh,'<:encoding(UTF-8)',$path or die "$path: $!";
 local $/;my $s=<$fh>;close $fh or die $!;
 return $json->decode($s);
}
my $contract=read_json('capability_conformance/unicode_rule_label_contract.json');
sub enter_label {
 my ($label)=@_;
 my ($input,$boundary)=('x',0);pos($input)=0;
 my (%descriptor,%info);
 my $guard=LinkedSpec::RecognitionTransactionRuntime::enter_invocation(
  \%descriptor,\$input,\%info,\$boundary,$label);
 return defined($guard);
}
subtest 'pinned rule membership at invocation boundary' => sub {
 for my $row(@{$contract->{positive_fixtures}}) {
  my $ok=eval{enter_label($row->{label})};
  ok($ok,"accepts $row->{id}") or diag("$@");
 }
 for my $row(@{$contract->{negative_fixtures}}, {id=>'undefined',label=>undef},{id=>'reference',label=>[]}) {
  my $ok=eval{enter_label($row->{label});1};my $error=$@;
  ok(!$ok,"rejects $row->{id}");
  like($error,qr/rule must be a bare identifier/, 'existing failure detail preserved');
 }
};
subtest 'observation callee keeps strict rule membership' => sub {
 for my $row(@{$contract->{negative_fixtures}}, {id=>'undefined',label=>undef},{id=>'reference',label=>[]}) {
  my ($input,$boundary,$target)=('x',0,undef);pos($input)=0;
  my (%descriptor,%info);
  my $guard=LinkedSpec::RecognitionTransactionRuntime::enter_invocation(
   \%descriptor,\$input,\%info,\$boundary,'Top');
  my $ok=eval{LinkedSpec::RecognitionTransactionRuntime::observe_static(
   \%descriptor,\$input,\%info,\$boundary,\$target,$row->{label},'Top');1};
  my $error=$@;
  ok(!$ok,"rejects $row->{id}");
  like($error,qr/recursive observation callee must be a bare identifier/,'callee failure detail preserved');
 }
};
subtest 'pinned observation callee identity at runtime boundary' => sub {
 for my $row(@{$contract->{positive_fixtures}}) {
  my ($input,$boundary,$target)=('x',0,undef);pos($input)=0;
  my (%descriptor,%info);my $label=$row->{label};
  $descriptor{spec}{$label}=sub {
   my ($descr,$string_ref,$child_info)=@_;
   my $child_boundary=0;
   my $guard=LinkedSpec::RecognitionTransactionRuntime::enter_invocation(
    $descr,$string_ref,$child_info,\$child_boundary,$label);
   return 'OK';
  };
  my $guard=LinkedSpec::RecognitionTransactionRuntime::enter_invocation(
   \%descriptor,\$input,\%info,\$boundary,'RuntimeObserver');
  my $value=eval{LinkedSpec::RecognitionTransactionRuntime::observe_static(
   \%descriptor,\$input,\%info,\$boundary,\$target,$label,'RuntimeObserver')};
  is($@,'',"accepts $row->{id}");
  is($value,'OK','callee payload preserved');
  is(ref($target) eq 'HASH'?$target->{rule_label}:undef,$label,'exact scalar identity retained');
 }
};

my (@observations,$sequence);
for my $label('Ascii','Ω','Töp',"To\x{0308}p",'töp') {
 for my $route(qw(root blind direct recognition observation)) {
  next if $label ne 'Ascii' && ($route eq 'recognition' || $route eq 'observation');
  my $child="$label:AND\n /x/ -> $label\[0] { return(\"OK\") }\n";
  my $source=$route eq 'root'?"$label\::|\n /x/ -> $label\[0] { return(\"OK\") }\n"
   :$route eq 'blind'?"Top::|\n => $label { return(\"OK\") }\n$child"
   :$route eq 'direct'?"Top::\n I { return(call($label)) }\n$child"
   :$route eq 'recognition'?"Top::\n I { tx = recognition_checkpoint(); matched = recognize_once(tx, call($label)); payload = recognition_commit(tx); return(payload) }\n$child"
   :"Top::\n I { value = observe_recognition(observation, call($label)); return(array(value, observation[\"rule_label\"])) }\n$child";
  my ($input_text,$expected_cursor)=('x',1);
  if($route eq 'recognition') {
   $source="Top::\n I { tx = recognition_checkpoint(); matched = recognize_once(tx, call($label)); payload = recognition_commit(tx); return(payload) }\n$label:AND\n /c/ -> Payload { return(\"OK\") }\nPayload:AND\n /d/\n";
   ($input_text,$expected_cursor)=('cd',2);
  }
  my $expected=$route eq 'observation'?['OK',$label]:'OK';
  subtest "$route label ".$json->ascii->encode($label) => sub {
   my (%context,@warnings);
   local $SIG{__WARN__}=sub{push @warnings,@_};
   my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
   ok(ref($parser) eq 'CODE','public source compiles') or diag explain \%context;
   return unless ref($parser) eq 'CODE';
   my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'unicode-rule-runtime.spec');
   my $package='LinkedSpec::UnicodeRuleRuntimeTest'.++$sequence;
   my $loaded=eval "package $package; $emitted; 1";
   ok($loaded,'emitted source independently loads') or diag("$@");
   return unless $loaded;
   my $metadata=$package->can('LinkedSpecGeneratedMetadata')->();
   is($metadata->{format_version},2,'format unchanged');
   ok(eval{$package->can('ValidateGeneratedPlan')->();1},'plan validates');
   my @results;
   for my $execution(qw(native emitted)) {
    my $input=$input_text;my ($value,$inner);
    my $ok=eval{$value=$execution eq 'native'?$parser->(\$input):$package->can('Execute')->(\$input);$inner=$@;1};
    my $error=$@;
    ok($ok&&!$inner&&!defined($context{last_error}),"$execution succeeds") or diag explain($error,$inner,\%context);
    is($json->encode($value),$json->encode($expected),"$execution preserves value and exact label identity");
    is(pos($input),$expected_cursor,"$execution consumes input");
    push @results,{route=>$execution,value=>$value,cursor=>pos($input),error=>"$error",inner=>"$inner",context_error=>$context{last_error}};
   }
   # Existing AND emission warnings have their own repair owner40.1.1.
   push @observations,{label=>$label,route=>$route,source=>$source,input=>$input_text,expected_cursor=>$expected_cursor,emitted=>$emitted,metadata=>$metadata,expected=>$expected,results=>\@results,warnings=>\@warnings};
  };
 }
}
if($ENV{LINKEDSPEC_PERL_UNICODE_GUARD_INTAKE}) {
 open my $fh,'>:encoding(UTF-8)','.linkedspec-data/verification/perl-unicode-guard-observations.json' or die $!;
 print {$fh} $json->encode(\@observations),"\n";close $fh or die $!;
}
done_testing();
