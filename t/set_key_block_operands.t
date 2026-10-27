use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST::Parser ();

my $json = JSON::PP->new->canonical;
my $sequence = 0;
sub slurp {
 my ($path) = @_;
 open my $file, '<:encoding(UTF-8)', $path or die "$path: $!";
 local $/; return <$file>;
}
sub routes {
 my ($source) = @_;
 my %context;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
 my $input = 'x';
 my $native = eval { $parser->(\$input) };
 my $error = $@ || $context{last_error};
 my $emitted = LinkedSpec::emit_generated_source(\$source,
  source_identity => 'set-key-block-operands.spec');
 my $package = 'LinkedSpec::SetKeyBlockOperands'.++$sequence;
 my $loaded = eval "package $package; $emitted; 1";
 ok($loaded, 'fresh key-operand parser compiles') or diag($@);
 my ($fresh, $fresh_error);
 if ($loaded) {
  my $input = 'x'; no strict 'refs';
  $fresh = eval { &{$package.'::Execute'}(\$input) };
  $fresh_error = $@;
 }
 return ([native => $native, $error], [fresh => $fresh, $fresh_error]);
}
sub metadata {
 my ($source) = @_;
 return LinkedSpec::Get(\$source, return_descriptor => 1)->{spec}{Top}{meta}{action_rewriter};
}
sub check_source {
 my ($label, $source, $expected) = @_;
 subtest $label => sub {
  for my $row (routes($source)) {
   my ($route, $value, $error) = @$row;
   ok(!$error, "$route no runtime error") or diag("$error");
   is($json->encode($value), $json->encode($expected), "$route exact values/kinds/effects");
  }
  my $meta = metadata($source);
  is($meta->{raw_perl_dependency_count}, 0, 'key operands stay typed');
  is($meta->{unresolved_helper_count}, 0, 'key helpers remain resolved');
  ok($meta->{language_agnostic_action_ir_ready}, 'key operand readiness describes working lowering');
 };
}
# TYPE-REFERENCE-BOOK.1.2.23.3.28.1 — existing eager keys and legacy roots.
check_source('value fluent selected and statement blocks keep local returns and order',q{Top:: I {
 meta={"old":1};order="";
 a=set_key(meta,{order=cat(order,"K");return("a");order="bad"},{order=cat(order,"V");2});
 b=meta.set_key({order=cat(order,"K");return("b");order="bad"},{order=cat(order,"V");3});
 set_key(meta,{order=cat(order,"K");return("c");order="bad"},{order=cat(order,"V");4});
 d=meta.copy().set_key({order=cat(order,"K");return("d");order="bad"},{order=cat(order,"V");5});
 return([a,b,meta,d,order]);
}},[{old=>1,a=>2},{old=>1,b=>3},{old=>1,c=>4},{old=>1,c=>4,d=>5},'KVKVKVKV']);
check_source('source and nonblock keys captured before later operands',q{Top:: I {
 meta={"old":1};key="before";
 a=set_key(meta,key,{key="after";2});
 key="again";b=meta.copy().set_key(key,{key="last";3});
 key="stored";set_key(meta,key,{key="last";7});
 key="operator";meta[key]={key="last";8};
 source={"old":1};
 c=set_key(source,{source["old"]=9;return("new")},{source={"changed":4};5});
 return([a,b,c,meta,source,key]);
}},[{old=>1,before=>2},{old=>1,again=>3},{old=>1,new=>5},{old=>1,stored=>7,operator=>8},{changed=>4},'last']);
check_source('existing scalar first-consumer fallbacks and normalized guards stay distinct',q{Top:: I {
 a="text";b=5;order="";
 x=b.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
 y=b.add(0).set_key({order=cat(order,"X");"x"},{order=cat(order,"Y");2});
 return(["text".take(1),5.set_key("key",1),a.take(1),x,y,order,a,b]);
}},[[],{key=>1},[],{k=>1},undef,'KV','text',5]);
done_testing;
