use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.48.2.6.1: static rule identity is distinct
# from the result/token/observation-target variable grammar.
my $json=JSON::PP->new->canonical->ascii->allow_nonref;
sub plain {
 my ($value)=@_;
 return $value unless ref($value);
 return $value if ref($value) eq 'JSON::PP::Boolean';
 return {map {$_=>plain($value->{$_})} keys %$value} if (reftype($value)//'') eq 'HASH';
 return [map {plain($_)} @$value] if (reftype($value)//'') eq 'ARRAY';
 return "$value";
}
my (@rows,$sequence);
my @cases=map {{name=>$_,operand=>"call( $_ )",callee=>$_,valid=>1}}
 ('Ascii','Ω','Töp',"To\x{0308}p",'töp');
push @cases,map {{name=>$_->[0],operand=>$_->[1],valid=>0}}
 ['bare','Child'],['quoted','call("Child")'],['dynamic','call(cat("Ch","ild"))'],
 ['extra_argument','call(Child, 0)'],['unknown','call(Unknown)'],
 ['suffix','call(Child).copy()'];
for my $case(@cases) {
 for my $operation(qw(recognition observation)) {
  my $callee=$case->{callee}//'Child';my $operand=$case->{operand};
  my $body=$operation eq 'recognition'
   ? "tx = recognition_checkpoint(); matched = recognize_once(tx, $operand); payload = recognition_commit(tx); return(payload)"
   : "value = observe_recognition(observation, $operand); return(array(value, observation[\"rule_label\"]))";
  my $source="Top::\n I { $body }\n$callee:AND\n /c/ -> Payload { return(\"OK\") }\nPayload:AND\n /d/\n";
  my ($input_text,$expected_cursor)=('cd',2);
  if($operation eq 'observation') {
   $source="Top::\n I { $body }\n$callee:AND\n /x/ -> $callee\[0] { return(\"OK\") }\n";
   ($input_text,$expected_cursor)=('x',1);
  }
  my $expected=$operation eq 'recognition'?'OK':['OK',$callee];
  subtest "$operation ".$json->encode($case->{name}) => sub {
   my (%context,@warnings,$build_output);
   local $SIG{__WARN__}=sub{push @warnings,@_};
   my $descriptor;
   {local *STDOUT;open STDOUT,'>:encoding(UTF-8)',\$build_output or die $!;
    $descriptor=LinkedSpec::Get(\$source,return_descriptor=>1,runtime_ctx_ref=>\%context);
   }
   my $row={name=>$case->{name},operation=>$operation,source=>$source,input=>$input_text,expected_cursor=>$expected_cursor,expected=>$expected,valid=>$case->{valid},builds=>ref($descriptor) eq 'HASH'?1:0,error=>$context{last_error}};
   if(!$case->{valid}) {
    ok(!$row->{builds},'unsupported or unknown operand remains rejected');
    is($context{last_error}{type},'compiler_pipeline','compiler owns failure');
    is($context{last_error}{code},$operation eq 'recognition'?'recognition_static_rule_required':'source_location_recursive_observation_operand','specific static operand diagnostic');
   } else {
    ok($row->{builds},'declared static callee compiles') or diag explain $context{last_error};
    if($row->{builds}) {
     my $events=$descriptor->{spec}{Top}{meta}{action_rewriter}{canonical_action_ir_events};
     my ($event)=grep {($_->{kind}//'') eq ($operation eq 'recognition'?'RECOGNIZE_ONCE':'OBSERVE_RECOGNITION')} @$events;
     is($event->{args}{callee},$callee,'ActionIR keeps exact callee identity');
     ok(!exists($event->{args}{operand_kind}),'static rule is not a dynamic operand');
     $row->{event}=$event;
     my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
     my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'unicode-recognition-operands.spec');
     $row->{emitted}=$emitted;
     my $pkg='LinkedSpec::UnicodeOperandTest'.++$sequence;
     my $loaded=eval "package $pkg; $emitted; 1";
     ok($loaded,'generated source independently loads') or diag("$@");
     if($loaded) {
      $row->{emitted}=$emitted;$row->{metadata}=$pkg->can('LinkedSpecGeneratedMetadata')->();
      is($row->{metadata}{format_version},2,'generated format unchanged');
      ok(eval{$pkg->can('ValidateGeneratedPlan')->();1},'generated plan validates');
      my @results;
      for my $route(qw(native emitted)) {
       my $input=$input_text;my ($value,$inner);
       my $ok=eval{$value=$route eq 'native'?$parser->(\$input):$pkg->can('Execute')->(\$input);$inner=$@;1};
       my $error=$@;
       ok($ok&&!$inner&&!exists($context{last_error}),"$route succeeds");
       is($json->encode($value),$json->encode($expected),"$route preserves payload and label identity");
       is(pos($input),$expected_cursor,"$route consumes recognized input");
       push @results,{route=>$route,value=>$value,cursor=>pos($input),error=>defined($error)?"$error":'',inner=>defined($inner)?"$inner":'',context_error=>$context{last_error}};
      }
      $row->{results}=\@results;
     }
    }
   }
   $row->{warnings}=\@warnings;push @rows,$row;
  };
 }
}
if($ENV{LINKEDSPEC_PERL_UNICODE_OPERAND_INTAKE}) {
 open my $fh,'>','.linkedspec-data/verification/perl-unicode-operand-observations.json' or die $!;
 print {$fh} $json->encode(plain(\@rows)),"\n";close $fh or die $!;
}
done_testing();
