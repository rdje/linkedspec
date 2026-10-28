use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
# TYPE-REFERENCE-BOOK.1.2.23.3.39.9.1 — acceptance and post-call payload are separate.
my $json=JSON::PP->new->canonical->allow_nonref;
my $rows=$json->decode(q~[{"name":"or_zero","source":"Top::OR{2}\n => Atom {return(0)}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":[0,0],"cursor":2},{"input":"a","expected":null,"cursor":1},{"input":"ab","expected":null,"cursor":1}]},{"name":"or_false","source":"Top::OR{2}\n => Atom {return(false)}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":[false,false],"cursor":2},{"input":"a","expected":null,"cursor":1},{"input":"ab","expected":null,"cursor":1}]},{"name":"or_empty","source":"Top::OR{2}\n => Atom {return(\"\")}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":["",""],"cursor":2},{"input":"a","expected":null,"cursor":1},{"input":"ab","expected":null,"cursor":1}]},{"name":"or_null","source":"Top::OR{2}\n => Atom {return(undef)}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":[null,null],"cursor":2},{"input":"a","expected":null,"cursor":1},{"input":"ab","expected":null,"cursor":1}]},{"name":"and_zero","source":"Top::AND{2}\n => Atom {return(0)}\n => Tail\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\nTail:AND\n /b/ -> Tail[0] {return(\"B\")}\n","cases":[{"input":"aa","expected":[0,0],"cursor":2},{"input":"a","expected":null,"cursor":1},{"input":"ab","expected":null,"cursor":1}]},{"name":"and_false","source":"Top::AND{2}\n => Atom {return(false)}\n => Tail\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\nTail:AND\n /b/ -> Tail[0] {return(\"B\")}\n","cases":[{"input":"aa","expected":[false,false],"cursor":2},{"input":"a","expected":null,"cursor":1},{"input":"ab","expected":null,"cursor":1}]},{"name":"and_empty","source":"Top::AND{2}\n => Atom {return(\"\")}\n => Tail\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\nTail:AND\n /b/ -> Tail[0] {return(\"B\")}\n","cases":[{"input":"aa","expected":["",""],"cursor":2},{"input":"a","expected":null,"cursor":1},{"input":"ab","expected":null,"cursor":1}]},{"name":"and_null","source":"Top::AND{2}\n => Atom {return(undef)}\n => Tail\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\nTail:AND\n /b/ -> Tail[0] {return(\"B\")}\n","cases":[{"input":"aa","expected":[null,null],"cursor":2},{"input":"a","expected":null,"cursor":1},{"input":"ab","expected":null,"cursor":1}]},{"name":"nested","source":"Top::OR{2}\n => Atom {return([\"N\",cursor_pos()])}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":[["N",1],["N",2]],"cursor":2},{"input":"a","expected":null,"cursor":1}]},{"name":"implicit_partial","source":"Top::AND{1,2}\n => Atom\n => Tail\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\nTail:AND\n /b/ -> Tail[0] {return(\"B\")}\n","cases":[{"input":"abab","expected":[["A","B"],["A","B"]],"cursor":4},{"input":"aba","expected":[["A","B"]],"cursor":3},{"input":"a","expected":null,"cursor":1}]},{"name":"zero_min","source":"Top::AND{0,2}\n => Atom\n => Tail\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\nTail:AND\n /b/ -> Tail[0] {return(\"B\")}\n","cases":[{"input":"","expected":[],"cursor":0},{"input":"a","expected":[],"cursor":1},{"input":"ab","expected":[["A","B"]],"cursor":2}]},{"name":"custom_it","source":"Top::OR{2}\n => Atom {return(0)}\n IT {cursor_pos()}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":[],"cursor":2}]},{"name":"it_return","source":"Top::OR{2}\n => Atom {return(0)}\n IT {return(\"IT\")}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":"IT","cursor":1}]},{"name":"ordinary_zero","source":"Top::OR{1}\n => Atom {return(0)}\nAtom:AND\n /(?=a)/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"a","expected":null,"cursor":0}]},{"name":"recognition_zero","source":"Top::\n I {tx=recognition_checkpoint();matched=recognize_once(tx,call(Value));payload=recognition_commit(tx);return(matched)}\n /never/\nValue:OR{1}\n => Atom {return(0)}\nAtom:AND\n /(?=a)/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"a","expected":null,"cursor":0,"error_contains":"recognition_zero_progress_repetition"}]}]~);
my $sequence=0;
for my $row (@$rows) {
 subtest $row->{name} => sub {
  my $source=$row->{source};my %ctx;
  my $native=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);
  ok(ref($native) eq 'CODE','native parser builds');
  my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'blind-falsey-group.spec');
  my $package='LinkedSpec::BlindFalseyGroup'.++$sequence;
  my $loaded=eval "package $package; $emitted; 1";
  ok($loaded,'independent emitted package loads') or diag($@);
  return unless $loaded && ref($native) eq 'CODE';
  no strict 'refs';
  my $metadata=&{$package.'::LinkedSpecGeneratedMetadata'}();
  is($metadata->{format_version},2,'format remains two');
  diag('PERL_BLIND_FALSEY_INPUT '.$row->{name}.' '.$json->encode({source=>$source,emitted=>$emitted,metadata=>$metadata}));
  for my $case (@{$row->{cases}}) {
   my $a=$case->{input};my $av=eval {$native->(\$a)};my $ae=$@ || $ctx{last_error};$ae=defined($ae) ? "$ae" : '';
   my $b=$case->{input};my $bv=eval {&{$package.'::Execute'}(\$b)};my $be="$@";
   diag('PERL_BLIND_FALSEY_ACTUAL '.$row->{name}.' '.$json->encode({input=>$case->{input},native=>$av,fresh=>$bv,native_cursor=>pos($a),fresh_cursor=>pos($b),native_error=>$ae || '',fresh_error=>$be || ''}));
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
