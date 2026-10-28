use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.39.7: a group match and its action value
# are separate outcomes, including early returns before remaining slots.
my $json=JSON::PP->new->canonical->allow_nonref;
my $sequence=0;
sub check_group {
 my ($name,$source,$cases)=@_;
 subtest $name => sub {
  my %ctx;
  my $native=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);
  ok(ref($native) eq 'CODE','native parser builds');
  my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'repeated-and-falsey.spec');
  my $package='LinkedSpec::RepeatedAndFalseyTest'.++$sequence;
  my $loaded=eval "package $package; $emitted; 1";
  ok($loaded,'independent emitted package loads') or diag($@);
  return unless $loaded && ref($native) eq 'CODE';
  no strict 'refs';
  my $metadata=&{$package.'::LinkedSpecGeneratedMetadata'}();
  is($metadata->{format_version},2,'format remains two');
  is_deeply($metadata->{plan},[{label=>'Value',family=>'rep_and_acode'}],'minimal existing plan unchanged');
  diag('PERL_AND_FALSEY_INPUT '.$name.' '.$json->encode({source=>$source,emitted=>$emitted,metadata=>$metadata}));
  for my $case (@$cases) {
   my ($input,$expected,$cursor)=@$case;
   my $a=$input;my $av=eval {$native->(\$a)};my $ae=$@ || $ctx{last_error};
   my $b=$input;my $bv=eval {&{$package.'::Execute'}(\$b)};my $be=$@;
   diag('PERL_AND_FALSEY_ACTUAL '.$name.' '.$json->encode({input=>$input,native=>$av,fresh=>$bv,native_cursor=>pos($a),fresh_cursor=>pos($b),native_error=>$ae || '',fresh_error=>$be || ''}));
   ok(!$ae,"$input native has no error");is($be,'',"$input fresh has no error");
   is($json->encode($av),$json->encode($expected),"$input native value and kinds");
   is($json->encode($bv),$json->encode($expected),"$input fresh value and kinds");
   is(pos($a),$cursor,"$input native cursor");is(pos($b),$cursor,"$input fresh cursor");
  }
 };
}

for my $value ([zero=>'0',0],[empty=>'""',''],[null=>'undef',undef],
               [false=>'false',JSON::PP::false],[true=>'true',JSON::PP::true]) {
 check_group($value->[0],
  "Value::AND{2}\n /H/\n /cat/ -> Value[1] {return($value->[1])}\n",
  [['HcatHcat',[$value->[2],$value->[2]],8],['Hcat',undef,4],['HcatHbad',undef,5]]);
}
check_group('early_falsey',
 "Value::AND{2}\n /H/\n /cat/\n -> Value[0] {return(0)}\n",
 [['HH',[0,0],2],['HcatHcat',undef,1],['H',undef,1]]);
check_group('accepted_then_partial_miss',
 "Value::AND{1,2}\n /H/\n /cat/ -> Value[1] {return(0)}\n",
 [['HcatHbad',[0],5],['Hbad',undef,1]]);
check_group('zero_allowed',
 "Value::AND{0,2}\n /H/\n /cat/ -> Value[1] {return(0)}\n",
 [['',[],0],['Hbad',[],1],['Hcat',[0],4]]);
check_group('nonreturn',
 "Value::AND{2}\n /H/\n /cat/ -> Value[1] {x=match_text()}\n",
 [['HcatHcat',[[],[]],8],['Hcat',undef,4]]);
check_group('it_whole_rule_return',
 "Value::AND{2}\n /H/\n /cat/ -> Value[1] {return(0)}\n IT {return(\"IT\")}\n",
 [['HcatHcat','IT',4]]);
check_group('custom_it_replaces_collection',
 "Value::AND{2}\n I {seen=[]}\n /H/\n /cat/ -> Value[1] {return(0)}\n IT {push(seen,cursor_pos())}\n E {return(copy(seen))}\n",
 [['HcatHcat',[4,8],8]]);
check_group('one_group_zero_width',
 "Value::AND{1}\n /(?=a)/ -> Value[0] {return(0)}\n",
 [['a',[0],0]]);
done_testing();
