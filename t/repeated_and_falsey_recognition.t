use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.39.7: the local group outcome must preserve
# transaction payloads and the existing typed progress rejection.
my $json=JSON::PP->new->canonical->allow_nonref;
my $sequence=0;
for my $case ([zero=>'0',[1,[0,0],9]], [null=>'undef',[1,[undef,undef],9]],
              [zero_width=>'0',undef]) {
 my ($name,$value,$expected)=@$case;
 subtest $name => sub {
  my $body=$name eq 'zero_width'
   ? "Value:AND{1}\n /(?=a)/ -> Value[0] {return($value)}\n"
   : "Value:AND{2}\n /H/\n /cat/ -> Value[1] {return($value)}\n";
  my $source="Top::\n I {tx=recognition_checkpoint();matched=recognize_once(tx,call(Value));payload=recognition_commit(tx);return([matched,payload,cursor_pos()])}\n /never/\n".$body;
  my %ctx;my $native=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);
  ok(ref($native) eq 'CODE','native parser builds');
  my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'repeated-and-falsey-recognition.spec');
  my $package='LinkedSpec::RepeatedAndFalseyRecognition'.++$sequence;
  my $loaded=eval "package $package; $emitted; 1";
  ok($loaded,'independent emitted package loads') or diag($@);
  return unless $loaded && ref($native) eq 'CODE';
  diag('PERL_AND_FALSEY_RECOGNITION_INPUT '.$name.' '.$json->encode({source=>$source,emitted=>$emitted}));
  no strict 'refs';
  for my $route (['native',$native],['fresh',\&{$package.'::Execute'}]) {
   # The caller consumes Value's entry H before the child starts both groups.
   my $input=$name eq 'zero_width'?'a':'HHcatHcat';
   my $result=eval {$route->[1]->(\$input)};my $error=$@;
   diag('PERL_AND_FALSEY_RECOGNITION_ACTUAL '.$name.' '.$json->encode({route=>$route->[0],result=>$result,cursor=>pos($input),error=>"$error"}));
   if ($name eq 'zero_width') {
    like("$error",qr/recognition_zero_progress_repetition/,"$route->[0] retains typed progress rejection");
   } else {
    is("$error",'',"$route->[0] has no error");
    is($json->encode($result),$json->encode($expected),"$route->[0] commits complete falsey groups");
   }
  }
 };
}
done_testing();
