use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
# TYPE-REFERENCE-BOOK.1.2.23.3.39.9.2 — completed parent acceptance is independent of value.
my $json=JSON::PP->new->canonical->allow_nonref;
my $rows=$json->decode(q~[{"name":"or","source":"Top::\n I {tx=recognition_checkpoint();matched=recognize_once(tx,call(Value));payload=recognition_commit(tx);return([matched,payload,cursor_pos()])}\n /never/\nValue:OR{2}\n => Part\n EX {return(undef)}\n E {return(undef)}\nPart:|\n /a/ -> Part[0] {return(1)}\n","cases":[{"input":"aa","expected":[1,null,2],"cursor":2},{"input":"a","expected":[0,null,1],"cursor":1},{"input":"","expected":[0,null,0],"cursor":0}]},{"name":"and","source":"Top::\n I {tx=recognition_checkpoint();matched=recognize_once(tx,call(Value));payload=recognition_commit(tx);return([matched,payload,cursor_pos()])}\n /never/\nValue:AND{2}\n => Part\n EX {return(undef)}\n E {return(undef)}\nPart:|\n /a/ -> Part[0] {return(1)}\n","cases":[{"input":"aa","expected":[1,null,2],"cursor":2},{"input":"a","expected":[0,null,1],"cursor":1},{"input":"","expected":[0,null,0],"cursor":0}]},{"name":"partial","source":"Top::\n I {tx=recognition_checkpoint();matched=recognize_once(tx,call(Value));payload=recognition_commit(tx);return([matched,payload,cursor_pos()])}\n /never/\nValue:AND{1,2}\n => First\n => Second\nFirst:AND\n /a/ -> First[0] {return(\"A\")}\nSecond:AND\n /b/ -> Second[0] {return(\"B\")}\n","cases":[{"input":"aba","expected":[1,[["A","B"]],3],"cursor":3},{"input":"a","expected":[0,null,1],"cursor":1},{"input":"abab","expected":[1,[["A","B"],["A","B"]],4],"cursor":4}]},{"name":"zero_min","source":"Top::\n I {tx=recognition_checkpoint();matched=recognize_once(tx,call(Value));payload=recognition_commit(tx);return([matched,payload,cursor_pos()])}\n /never/\nValue:OR{0,1}\n => Part\n EX {return(undef)}\n E {return(undef)}\nPart:|\n /a/ -> Part[0] {return(1)}\n","cases":[{"input":"aa","expected":[1,null,1],"cursor":1},{"input":"","expected":[0,null,0],"cursor":0}]},{"name":"post_null","source":"Top::\n I {tx=recognition_checkpoint();matched=recognize_once(tx,call(Value));payload=recognition_commit(tx);return([matched,payload,cursor_pos()])}\n /never/\nValue:OR{2}\n => Part {return(undef)}\nPart:|\n /a/ -> Part[0] {return(1)}\n","cases":[{"input":"aa","expected":[1,[null,null],2],"cursor":2}]},{"name":"it_null","source":"Top::\n I {tx=recognition_checkpoint();matched=recognize_once(tx,call(Value));payload=recognition_commit(tx);return([matched,payload,cursor_pos()])}\n /never/\nValue:OR{2}\n => Part\n IT {return(undef)}\nPart:|\n /a/ -> Part[0] {return(1)}\n","cases":[{"input":"aa","expected":[1,null,1],"cursor":1}]},{"name":"caller_mark","source":"Top::\n I {mark_here(origin);tx=recognition_checkpoint();matched=recognize_once(tx,call(Value));payload=recognition_commit(tx);return([matched,payload,cursor_pos(),mark_pos(origin)])}\n /never/\nValue:OR{2}\n => Part\n EX {return(undef)}\n E {return(undef)}\nPart:|\n /a/ -> Part[0] {return(1)}\n","cases":[{"input":"aa","expected":[1,null,2,0],"cursor":2},{"input":"a","expected":[0,null,1,0],"cursor":1}]},{"name":"observation","source":"Top::\n I {value=observe_recognition(observation,call(Value));return([value,observation[\"outcome\"],observation[\"accepted_exit\"],observation[\"selected_match\"],cursor_pos()])}\n /never/\nValue:OR{2}\n => Part\nPart:|\n /a/ -> Part[0] {return(1)}\n","cases":[{"input":"aa","expected":[[1,1],"accepted",{"source_id":"input","offset":2},null,2],"cursor":2},{"input":"a","expected":[null,"failed",null,null,1],"cursor":1},{"input":"","expected":[null,"failed",null,null,0],"cursor":0}]},{"name":"pure_observation","source":"Top::\n I {value=observe_recognition(observation,call(Coordinator));return([value,observation[\"outcome\"],observation[\"accepted_exit\"],observation[\"selected_match\"],cursor_pos()])}\n /never/\nCoordinator:\n I {return(undef)}\n","cases":[{"input":"","expected":[null,"accepted",{"source_id":"input","offset":0},null,0],"cursor":0}]},{"name":"progress","source":"Top::\n I {tx=recognition_checkpoint();matched=recognize_once(tx,call(Value));payload=recognition_commit(tx);return([matched,payload,cursor_pos()])}\n /never/\nValue:OR{1}\n => Part\nPart:AND\n /(?=a)/ -> Part[0] {return(1)}\n","cases":[{"input":"a","expected":null,"cursor":0,"error_contains":"recognition_zero_progress_repetition"}]}]~);
my $sequence=0;
for my $row (@$rows) {
 subtest $row->{name} => sub {
  my $source=$row->{source};my %ctx;
  my $native=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);
  ok(ref($native) eq 'CODE','native parser builds');
  my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'blind-parent-acceptance.spec');
  my $package='LinkedSpec::BlindParentAcceptance'.++$sequence;
  my $loaded=eval "package $package; $emitted; 1";
  ok($loaded,'independent emitted package loads') or diag($@);
  return unless $loaded && ref($native) eq 'CODE';
  no strict 'refs';
  my $metadata=&{$package.'::LinkedSpecGeneratedMetadata'}();
  is($metadata->{format_version},2,'format remains two');
  diag('PERL_BLIND_PARENT_INPUT '.$row->{name}.' '.$json->encode({source=>$source,emitted=>$emitted,metadata=>$metadata}));
  for my $case (@{$row->{cases}}) {
   my $a=$case->{input};my $av=eval {$native->(\$a)};my $ae=$@ || $ctx{last_error};$ae=defined($ae) ? "$ae" : '';
   my $b=$case->{input};my $bv=eval {&{$package.'::Execute'}(\$b)};my $be="$@";
   diag('PERL_BLIND_PARENT_ACTUAL '.$row->{name}.' '.$json->encode({input=>$case->{input},native=>$av,fresh=>$bv,native_cursor=>pos($a),fresh_cursor=>pos($b),native_error=>$ae || '',fresh_error=>$be || ''}));
   if ($case->{error_contains}) {
    like($ae,qr/\Q$case->{error_contains}\E/,'native typed error remains');like($be,qr/\Q$case->{error_contains}\E/,'fresh typed error remains');
   } else {
   ok(!$ae,'native has no error');is($be,'','fresh has no error');
   is($json->encode($av),$json->encode($case->{expected}),'native value and kinds');
   is($json->encode($bv),$json->encode($case->{expected}),'fresh value and kinds');
   }
   is(pos($a),$case->{cursor},'native cursor / one child dispatch');
   is(pos($b),$case->{cursor},'fresh cursor / one child dispatch');
  }
 };
}
done_testing();
