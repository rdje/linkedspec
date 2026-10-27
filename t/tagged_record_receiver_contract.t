use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

sub slurp {
 my ($path)=@_;
 open my $file,'<',$path or die "$path: $!";
 local $/;
 return <$file>;
}
my $json=JSON::PP->new->canonical;
my $sequence=0;
sub check_records {
 my ($label,$source,$expected)=@_;
 my %context;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
 my $input='x';
 my $actual=eval { $parser->(\$input) };
 is("$@",'',"$label native has no thrown error");
 is($context{last_error},undef,"$label native has no handler error");
 is($json->encode($actual),$json->encode($expected),"$label native values/kinds/effects");
 my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'tagged-record-receiver.spec');
 my $package='LinkedSpec::TaggedRecordReceiverGenerated'.++$sequence;
 my $loaded=eval "package $package; $emitted; 1";
 ok($loaded,"$label fresh parser compiles") or diag($@);
 if ($loaded) {
  my $input='x';
  no strict 'refs';
  my $value=eval { &{$package.'::Execute'}(\$input) };
  is("$@",'',"$label fresh has no thrown error");
  is($json->encode($value),$json->encode($expected),"$label fresh values/kinds/effects");
 }
}
check_records('tagged String receiver',slurp('tests/fixtures/tagged_record_receiver_values.spec'),
 $json->decode(slurp('tests/fixtures/tagged_record_receiver_values.json')));
check_records('minimum receiver shape',q{Top:: I { order="";bad0={order=cat(order,"S");"a,b"}.split_tagged_records().count();bad1={order=cat(order,"S");"a,b"}.split_tagged_records({order=cat(order,"D");","}).take({order=cat(order,"C");1});return([bad0,bad1,order]); }},[undef,undef,'']);
done_testing() unless caller;
1;
