use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::CodeblockRuntime ();
use LinkedSpec::BindingRuntime ();

my $body = <<'BODY';
 value = "outer"; seen = "";
 chosen = with(7) { seen = cat(seen,"a"); return(value) };
 receiver = "x".with() { return(cat(value,"!")) }.cat("?");
 nested = with(2) { inner = with(3) { return(value) }; return([value,inner]) };
 empty = with() { return(is_undefined(value)) };
 callable = {|| return(9) }; called = with(callable) { return(value()) };
 explicit = with(4, {|item| return(num_add(item,1)) });
 callback = {|item| return(num_add(item,2)) }; dynamic = with(4, callback);
 rebound = with(1) { value = 8; return(value) };
 invalid = with({ seen = cat(seen,"bad"); 1 }, 2) { return(value) };
 invalid_receiver = { seen = cat(seen,"bad"); "x" }.with(7) { return(value) };
 return([chosen,receiver,nested,empty,called,explicit,dynamic,rebound,value,seen,invalid,invalid_receiver]);
BODY

my $expected = [7,'x!?',[2,3],1,9,5,6,8,'outer','a',undef,undef];
my $json = JSON::PP->new->canonical;
my $ordinary = "Top:: I { $body }";
my $deferred = 'fn relay_block(callback: codeblock) { return(callback()) }' . "\n" .
    "Top:: I { trial = {|| $body }; return([trial(),relay_block(trial)]) }";
for my $case ([$ordinary,$expected,'ordinary'], [$deferred,[$expected,$expected],'deferred']) {
    my %context;
    my $parser = LinkedSpec::Get(\$case->[0], runtime_ctx_ref => \%context);
    my $input = 'x';
    my $actual = $parser->(\$input);
    is($context{last_error}, undef, "$case->[2] has no runtime error");
    is($json->encode($actual), $json->encode($case->[1]), "$case->[2] with matches scoped contract");
}

my $emitted = LinkedSpec::emit_generated_source(\$deferred,
    source_identity => 'deferred-with.spec');
my $loaded = eval "package LinkedSpec::DeferredWithGenerated; $emitted; 1";
ok($loaded, 'emitted with parser compiles') or diag($@);
if ($loaded) {
    my $input = 'x';
    is($json->encode(LinkedSpec::DeferredWithGenerated::Execute(\$input)),
        $json->encode([$expected,$expected]), 'fresh with keeps caller frames and results');
}

my $value = 'outer';
my $present = 1;
my $callback = LinkedSpec::ActionIR::AST::parse_action_expr('{|| value["x"] = 2 }');
my %bindings = (value => \$value, cb => \$callback);
my %presence = (value => \$present);
my $runner = LinkedSpec::ActionIR::AST::parse_action_expr(
    '{|| return(with(undef) { return(cb()) }) }');
my $failure;
eval { LinkedSpec::CodeblockRuntime::invoke($runner, [], \%bindings, 'scoped-error', undef, {}, \%presence); 1 }
    or $failure = $@;
ok(LinkedSpec::BindingRuntime::is_nested_write_error($failure), 'scoped null reaches the typed write conflict');
is($value, 'outer', 'error restores outer value');
is(refaddr($bindings{value}), refaddr(\$value), 'error restores caller slot identity');
is(refaddr($presence{value}), refaddr(\$present), 'error restores presence slot identity');
is($present, 1, 'error preserves caller presence');

done_testing() unless caller;
1;
