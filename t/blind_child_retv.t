use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
# TYPE-REFERENCE-BOOK.1.2.23.3.39.2.5.1 — latest child value precedes post-call code/IT.
my $json=JSON::PP->new->canonical->allow_nonref;
my $rows=$json->decode(q~[{"name":"pipe","source":"Top::|\n => Atom {return(retv)}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":"A","cursor":1}]},{"name":"and","source":"Top::AND\n => Atom {return(retv)}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":"A","cursor":1}]},{"name":"or","source":"Top::OR{2}\n => Atom {return(retv)}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":["A","A"],"cursor":2},{"input":"a","expected":null,"cursor":1}]},{"name":"it","source":"Top::OR{2}\n => Atom\n IT {return(retv)}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":"A","cursor":1}]},{"name":"effect","source":"Top::OR{2}\n I {seen=[]}\n => Atom {push(seen,retv)}\n EX {return(copy(seen))}\n E {return(copy(seen))}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":["A","A"],"cursor":2}]},{"name":"end","source":"Top::|\n => Atom\n E {return(retv)}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":"A","cursor":1}]},{"name":"stale","source":"Top::|\n I {retv=\"OLD\"}\n => Atom {return(retv)}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":"A","cursor":1}]},{"name":"override","source":"Top::|\n => Atom {retv=\"AUTH\";return(retv)}\nAtom:AND\n /a/ -> Atom[0] {return(\"A\")}\n","cases":[{"input":"aa","expected":"AUTH","cursor":1}]},{"name":"nested","source":"Top::|\n => Atom {return(retv)}\nAtom:AND\n /a/ -> Atom[0] {return([\"A\",[\"N\"]])}\n","cases":[{"input":"aa","expected":["A",["N"]],"cursor":1}]},{"name":"zero","source":"Top::|\n => Atom {return(retv)}\nAtom:AND\n /a/ -> Atom[0] {return(0)}\n","cases":[{"input":"aa","expected":0,"cursor":1}]}]~);
my $sequence=0;
for my $row (@$rows) {
 subtest $row->{name} => sub {
  my $source=$row->{source};my %ctx;
  my $native=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);
  ok(ref($native) eq 'CODE','native parser builds');
  my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'blind-child-retv.spec');
  my $package='LinkedSpec::BlindChildRetv'.++$sequence;
  my $loaded=eval "package $package; $emitted; 1";
  ok($loaded,'independent emitted package loads') or diag($@);
  return unless $loaded && ref($native) eq 'CODE';
  no strict 'refs';
  my $metadata=&{$package.'::LinkedSpecGeneratedMetadata'}();
  is($metadata->{format_version},2,'format remains two');
  diag('PERL_BLIND_RETV_INPUT '.$row->{name}.' '.$json->encode({source=>$source,emitted=>$emitted,metadata=>$metadata}));
  for my $case (@{$row->{cases}}) {
   my $a=$case->{input};my $av=eval {$native->(\$a)};my $ae=$@ || $ctx{last_error};
   my $b=$case->{input};my $bv=eval {&{$package.'::Execute'}(\$b)};my $be=$@;
   diag('PERL_BLIND_RETV_ACTUAL '.$row->{name}.' '.$json->encode({input=>$case->{input},native=>$av,fresh=>$bv,native_cursor=>pos($a),fresh_cursor=>pos($b),native_error=>$ae || '',fresh_error=>$be || ''}));
   ok(!$ae,'native has no error');is($be,'','fresh has no error');
   is($json->encode($av),$json->encode($case->{expected}),'native value and kinds');
   is($json->encode($bv),$json->encode($case->{expected}),'fresh value and kinds');
   is(pos($a),$case->{cursor},'native cursor / one child dispatch');
   is(pos($b),$case->{cursor},'fresh cursor / one child dispatch');
  }
 };
}
done_testing();
