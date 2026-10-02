use strict;
use warnings;
use Test::More;
use File::Basename qw(dirname);
use File::Path qw(make_path);
use File::Spec ();
use File::Temp qw(tempdir);
use JSON::PP ();
use Scalar::Util qw(refaddr reftype);

use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::CodeblockRuntime ();
use LinkedSpec::BindingRuntime ();

my $root = dirname(dirname(File::Spec->rel2abs(__FILE__)));
my $scratch_root = File::Spec->catdir($root, '.linkedspec-data', 'scratch');
make_path($scratch_root);
my $scratch = tempdir('codeblock-push-XXXXXX', DIR => $scratch_root, CLEANUP => 1);
my $json = JSON::PP->new->canonical->allow_nonref;

sub error_projection {
 my ($error) = @_;
 return undef unless defined($error) && (ref($error) || length($error));
 while ((reftype($error) // '') eq 'HASH' && ($error->{type} // '') eq 'generated_source_error') {
  $error = $error->{detail};
 }
 return {class => ref($error), %$error} if (reftype($error) // '') eq 'HASH';
 return {text => "$error"}
}

my @cases = (
 {id=>'function_unbound_callable', functions=>'fn inspect() { return(cb()) }', body=>'cb={|| return("outer-callable") }; return(inspect())', expected=>undef, metadata=>{language_agnostic_action_ir_ready=>0,canonical_action_ir_fallback_count=>0,raw_perl_dependency_count=>0,unresolved_helper_count=>1}},
 {id=>'function_with_failure', functions=>'fn apply(callback: codeblock) { value="function"; return(with("shadow",callback)) }', body=>'value="outside"; cb={|x| missing_operation() }; return(apply(cb))', error=>{class=>'LinkedSpec::CodeblockRuntime::Error',kind=>'codeblock_runtime_error',code=>'unknown_helper',name=>'missing_operation'}},
 {id=>'function_external_read', functions=>'fn apply(callback: codeblock) { return(callback()) }', body=>'secret="outer"; cb={|| return(secret) }; return(apply(cb))', expected=>undef},
 {id=>'function_direct_read', functions=>'fn inspect() { return(secret) }', body=>'secret="outer"; return(inspect())', expected=>undef},
 {id=>'function_local_read', functions=>'fn apply(callback: codeblock) { secret="local"; return(callback()) }', body=>'secret="outer"; cb={|| return(secret) }; return(apply(cb))', expected=>'local'},
 {id=>'function_external_write', functions=>'fn apply(callback: codeblock) { return(callback()) }', body=>'secret="outer"; cb={|| secret="inner"; return(secret) }; result=apply(cb); return([result,secret])', expected=>['inner','outer']},
 {id=>'function_local_write', functions=>'fn apply(callback: codeblock) { secret="local"; callback(); return(secret) }', body=>'secret="outer"; cb={|| secret="inner"; return(secret) }; result=apply(cb); return([result,secret])', expected=>['inner','outer']},
 {id=>'function_parameter_read', functions=>'fn apply(secret,callback: codeblock) { return(callback()) }', body=>'secret="outer"; cb={|| return(secret) }; result=apply("argument",cb); return([result,secret])', expected=>['argument','outer']},
 {id=>'function_parameter_write', functions=>'fn apply(secret,callback: codeblock) { callback(); return(secret) }', body=>'secret="outer"; cb={|| secret="changed"; return(secret) }; result=apply("argument",cb); return([result,secret])', expected=>['changed','outer']},
 {id=>'function_unknown_persistence_reset', functions=>'fn apply(callback: codeblock) { first=callback("a"); second=callback("b"); return([first,second]) }', body=>'items=["outside"]; cb={|x| return(push(items,x)) }; first=apply(cb); second=apply(cb); return([first,second,items])', expected=>[[['a'],['a','b']],[['a'],['a','b']],['outside']]},
 {id=>'function_known_persistence', functions=>'fn apply(callback: codeblock) { items=["local"]; first=callback("a"); second=callback("b"); return([first,second,items]) }', body=>'items=["outside"]; cb={|x| return(push(items,x)) }; result=apply(cb); return([result,items])', expected=>[[['local','a'],['local','a','b'],['local','a','b']],['outside']]},
 {id=>'function_nested_callback', functions=>'fn apply(callback,inner: codeblock) { secret="local"; return(callback()) }', body=>'secret="outer"; inner={|| return(secret) }; cb={|| return(inner()) }; return(apply(cb,inner))', expected=>'local'},
 {id=>'function_nested_frames', functions=>'fn inner(callback: codeblock) { return(callback("inner")) }
fn outer(callback: codeblock) { first=callback("outer"); middle=inner(callback); last=callback("after"); return([first,middle,last]) }', body=>'items=["outside"]; cb={|x| return(push(items,x)) }; result=outer(cb); return([result,items])', expected=>[[['outer'],['inner'],['outer','after']],['outside']]},
 {id=>'function_with_persistence_shadow', functions=>'fn apply(callback: codeblock) { value="function"; first=with("a",callback); second=with("b",callback); return([first,second,value]) }', body=>'items=["outside"]; value="outside"; cb={|x| push(items,x); return([items,value]) }; result=apply(cb); return([result,items,value])', expected=>[[[['a'],'a'],[['a','b'],'b'],'function'],['outside'],'outside']},
 {id=>'function_callback_parameter_restore', functions=>'fn apply(callback: codeblock) { item="function"; first=callback("temporary"); return([first,item]) }', body=>'item="outside"; cb={|item| item="changed"; return(item) }; result=apply(cb); return([result,item])', expected=>[['changed','function'],'outside']},
 {id=>'function_private_name_collision', functions=>'fn apply(callback: codeblock) { __ls_user_fn_codeblock_bindings="user"; return([callback(),__ls_user_fn_codeblock_bindings]) }', body=>'__ls_user_fn_codeblock_bindings="outside"; cb={|| return(__ls_user_fn_codeblock_bindings) }; return(apply(cb))', expected=>['user','user']},
 {id=>'selected_push', body=>'seen=[]; cb={|| push(seen,"x"); return(seen) }; return(cb())', expected=>['x']},
 {id=>'absent_target', body=>'cb={|| return(push(items,"x")) }; first=cb(); return([first,items])', expected=>[['x'],['x']]},
 {id=>'null_target', body=>'items=undef; cb={|| return(push(items,"x")) }; return(cb())', expected=>['x']},
 {id=>'argument_once', body=>'items=[]; effects=[]; cb={|| push(items,{ push(effects,"rhs"); return("x") }); return([items,effects]) }; return(cb())', expected=>[['x'],['rhs']]},
 {id=>'post_argument_snapshot', body=>'items=["before"]; cb={|| push(items,{ items=["during"]; return("last") }); return(items) }; return(cb())', expected=>['during','last']},
 {id=>'prior_result', body=>'items=[]; cb={|x| return(push(items,x)) }; first=cb("a"); second=cb("b"); return([first,second,items])', expected=>[['a'],['a','b'],['a','b']]},
 {id=>'copied_parameter', body=>'items=["outside"]; arg=["seed"]; cb={|items| return(push(items,"inside")) }; result=cb(arg); return([result,arg,items])', expected=>[['seed','inside'],['seed'],['outside']]},
 {id=>'nested_parameters', body=>'items=["outside"]; before=undef; inner={|items| return(push(items,"inner")) }; outer={|items| before=inner(items); push(items,"outer"); return([before,items]) }; result=outer(["seed"]); return([result,items])', expected=>[[['seed','inner'],['seed','outer']],['outside']]},
 {id=>'rule_precedence', body=>'seen=[]; outputs=[]; cb={|| push(seen,outputs); return([seen,outputs]) }; return(cb())', rules=>'seen: I { return("rule") }', expected=>[[],['rule']]},
 {id=>'nested_rule_context', body=>'seen=[]; outputs=[]; inner={|| push(seen,outputs); return(outputs) }; outer={|| return(inner()) }; return(outer())', rules=>'seen: I { return("rule") }', expected=>['rule']},
 {id=>'with_context', body=>'seen=[]; cb={|x| return(push(seen,x)) }; return(with("x",cb))', expected=>['x']},
 {id=>'helper_precedence', body=>'seen=[]; push={|| return("wrong") }; cb={|| return(push(seen,"x")) }; return(cb())', expected=>['x']},
 {id=>'parameter_receiver_shadow', body=>'tree=["original"]; cb={|tree| push(tree,"local"); return("OK") }; result=tree.map_leaves!() { return(cb(["arg"])) }; return([result,tree])', expected=>[['OK'],['OK']]},
 {id=>'wrong_kind', body=>'items="wrong"; cb={|| push(items,"x") }; return(cb())', error_text=>qr/binding_kind_mismatch identifier=items expected_kind=array actual_kind=scalar/},
 {id=>'unknown_call', body=>'cb={|| missing_operation("x") }; return(cb())', error=>{class=>'LinkedSpec::CodeblockRuntime::Error',kind=>'codeblock_runtime_error',code=>'unknown_helper',name=>'missing_operation'}},
 {id=>'arity_before_effects', body=>'items=[]; effects=[]; cb={|| push(items,{ push(effects,"bad"); return("x") },"extra") }; return(cb())', error=>{class=>'LinkedSpec::CodeblockRuntime::Error',kind=>'codeblock_runtime_error',code=>'helper_arity_mismatch',helper_name=>'push',actual_arity=>3,expected_arity=>'exactly 2',arguments_evaluated=>0}},
 {id=>'active_receiver', body=>'tree=["original"]; cb={|| push(tree,"bad"); return("OK") }; return(tree.map_leaves!() { return(cb()) })', receiver_error=>1},
);

sub assert_case {
 my ($row, $case, $route) = @_;
 is($row->{load_error}, undef, "$case->{id} $route compiles/loads");
 if (exists($case->{expected})) {
  is($row->{error}, undef, "$case->{id} $route succeeds");
  is_deeply($row->{value}, $case->{expected}, "$case->{id} $route matches independent value");
 } else {
  is($row->{value}, undef, "$case->{id} $route publishes no result on failure");
  if ($route eq 'emitted') {
   is_deeply($row->{carrier}, {
    code=>'generated_execution_failed', stage=>'execute_generated',
    source_identity=>"$case->{id}.spec",
   }, "$case->{id} retains independent generated failure provenance");
  }
  if ($case->{error_text}) {
   like($row->{error}{text} // '', $case->{error_text}, "$case->{id} $route retains kind diagnostic");
  } elsif ($case->{receiver_error}) {
   is($row->{error}{class}, 'LinkedSpec::BindingRuntime::ReceiverMutationError', "$case->{id} $route retains typed receiver error");
   is($row->{error}{code}, 'receiver_mutation_reentrant', "$case->{id} $route rejects actual active slot");
   is($row->{error}{attempt}, 'push', "$case->{id} $route identifies mutation");
  } else {
   is_deeply($row->{error}, $case->{error}, "$case->{id} $route retains exact typed failure");
  }
 }
 if ($route eq 'emitted' && $case->{id} eq 'function_unknown_persistence_reset') {
  is($row->{actual_function_frame_proof}, 'four actual frames; alias control rejected',
   'fresh child checks real shared/fresh working-slot identities and rejects an alias');
 }
}

my @requests;
for my $case (@cases) {
 my $source = ($case->{functions} ? $case->{functions}."\n" : '').'Top:: I { '.$case->{body}." }\n".($case->{rules} // '')."\n";
 my %ctx;
 my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
 my $meta = $descriptor->{spec}{Top}{meta}{action_rewriter};
 is_deeply({map {$_=>$meta->{$_} // 0}
  qw(language_agnostic_action_ir_ready canonical_action_ir_fallback_count raw_perl_dependency_count unresolved_helper_count)},
  $case->{metadata} // {language_agnostic_action_ir_ready=>1,canonical_action_ir_fallback_count=>0,raw_perl_dependency_count=>0,unresolved_helper_count=>0},
  "$case->{id} has exact readiness/fallback/unresolved metadata");
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx);
 my $row = {load_error => ref($parser) eq 'CODE' ? undef : error_projection($ctx{last_error})};
 if (ref($parser) eq 'CODE') {
  my $input = 'x';
  $row->{value} = $parser->(\$input);
  my $last_error = $ctx{last_error};
  $row->{error} = error_projection(ref($last_error) eq 'HASH' ? $last_error->{detail} : undef);
 }
 assert_case($row, $case, 'native');
 my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => "$case->{id}.spec");
 ok(defined($emitted) && length($emitted), "$case->{id} public emitter returns source");
 my $path = File::Spec->catfile($scratch, "$case->{id}.pl");
 open my $fh, '>', $path or die $!;
 print {$fh} $emitted // '';
 close $fh or die $!;
 push @requests, $path;
}

my $runner = File::Spec->catfile($scratch, 'emitted_runner.pl');
open my $runner_fh, '>', $runner or die $!;
print {$runner_fh} <<'RUNNER';
use strict; use warnings; use JSON::PP (); use Scalar::Util qw(reftype refaddr);
use LinkedSpec::CodeblockRuntime ();
my ($output, @sources) = @ARGV; my @rows;
for my $index (0 .. $#sources) {
 open my $fh, '<', $sources[$index] or die $!;
 my $source = do { local $/; <$fh> }; close $fh or die $!;
 my $package = "LinkedSpec::CodeblockPushIndependent::Case$index";
 my $loaded = eval "package $package; $source; 1";
 my $row = {load_error => $loaded ? undef : "$@"};
 if ($loaded) {
  my $input = 'x';
  my @frames;
  my $check_frames = $sources[$index] =~ m{/function_unknown_persistence_reset\.pl\z};
  my $invoke = \&LinkedSpec::CodeblockRuntime::invoke;
  $row->{value} = eval {
   no strict 'refs'; no warnings 'redefine';
   local *LinkedSpec::CodeblockRuntime::invoke = sub {
    push @frames, $_[2] if $check_frames;
    return $invoke->(@_)
   };
   &{"${package}::Execute"}(\$input)
  };
  my $error = $@;
  if (ref($error) || length($error)) {
   if ((reftype($error) // '') eq 'HASH' && ($error->{type} // '') eq 'generated_source_error') {
    $row->{carrier} = {map {$_=>$error->{$_}} qw(code stage source_identity)};
   }
   while ((reftype($error) // '') eq 'HASH' && ($error->{type} // '') eq 'generated_source_error') { $error = $error->{detail} }
   $row->{error} = (reftype($error) // '') eq 'HASH' ? {class=>ref($error), %$error} : {text=>"$error"};
  }
  if ($check_frames) {
   my $valid = sub {
    my ($maps) = @_;
    return @$maps == 4
     && refaddr($maps->[0]) == refaddr($maps->[1])
     && refaddr($maps->[2]) == refaddr($maps->[3])
     && refaddr($maps->[0]) != refaddr($maps->[2])
     && refaddr($maps->[0]{items}) != refaddr($maps->[2]{items});
   };
   die 'actual emitted function frame identity failure' unless $valid->(\@frames);
   die 'aliased emitted frame control accepted' if $valid->([$frames[0],$frames[0],$frames[0],$frames[0]]);
   $row->{actual_function_frame_proof} = 'four actual frames; alias control rejected';
  }
 }
 push @rows, $row;
}
open my $fh, '>', $output or die $!;
print {$fh} JSON::PP->new->canonical->allow_nonref->encode(\@rows);
close $fh or die $!;
RUNNER
close $runner_fh or die $!;
my $output = File::Spec->catfile($scratch, 'observations.json');
is(system($^X, '-I'.File::Spec->catdir($root, 'perl'), $runner, $output, @requests), 0,
 'fresh emitted child executes without the authoring compiler');
open my $output_fh, '<', $output or die $!;
my $rows = $json->decode(do { local $/; <$output_fh> });
close $output_fh or die $!;
is(scalar(@$rows), scalar(@cases), 'fresh child returns every push and function-scope case');
assert_case($rows->[$_], $cases[$_], 'emitted') for 0 .. $#cases;

subtest 'actual caller identities, copy-on-write and failure restoration' => sub {
 my $items = ['outside']; my $effects = []; my $tree = ['original'];
 my $bindings = {items=>\$items, effects=>\$effects, tree=>\$tree, alias=>\$tree};
 my $caller_ref = $bindings->{items};
 my $record = LinkedSpec::ActionIR::AST::parse_action_expr('{|items| push(items,"local"); return(items) }');
 my $arg = ['seed'];
 my $value = LinkedSpec::CodeblockRuntime::invoke($record, [$arg], $bindings, 'parameter');
 is_deeply($value, ['seed','local'], 'temporary copied parameter mutates');
 is_deeply($arg, ['seed'], 'actual argument remains unchanged');
 isnt(refaddr($value), refaddr($arg), 'actual returned aggregate is detached from argument');
 is(refaddr($bindings->{items}), refaddr($caller_ref), 'caller scalar reference mapping restores');
 is_deeply($items, ['outside'], 'caller value was never rebound');
 my $push = LinkedSpec::ActionIR::AST::parse_action_expr('{|x| return(push(items,x)) }');
 my $first = LinkedSpec::CodeblockRuntime::invoke($push, ['a'], $bindings, 'push');
 my $second = LinkedSpec::CodeblockRuntime::invoke($push, ['b'], $bindings, 'push');
 isnt(refaddr($first), refaddr($second), 'later publication has an independent actual array identity');
 is_deeply($first, ['outside','a'], 'later push does not alter the actual prior result');
 is(refaddr($items), refaddr($second), 'mutation returns the current typed target');
 my $bad = LinkedSpec::ActionIR::AST::parse_action_expr('{|items| push(items,"local"); missing_operation() }');
 my $ok = eval { LinkedSpec::CodeblockRuntime::invoke($bad, [['seed']], $bindings, 'failure'); 1 };
 ok(!$ok, 'failure control actually fails');
 is(ref($@), 'LinkedSpec::CodeblockRuntime::Error', 'original typed failure survives restoration');
 is(refaddr($bindings->{items}), refaddr($caller_ref), 'failure restores caller reference identity');
 is_deeply($items, ['outside','a','b'], 'failure leaves caller parameter value intact');
 my $token = bless {tag=>'unique_caller_failure'}, 'LinkedSpec::Test::CallerFailure';
 my $outputs = []; my $calls = 0; my $input = 'x';
 $bindings->{outputs} = \$outputs;
 my $caller_failure = LinkedSpec::ActionIR::AST::parse_action_expr('{|items| push(Child,outputs) }');
 $ok = eval {
  LinkedSpec::CodeblockRuntime::invoke($caller_failure, [['seed']], $bindings, 'caller_failure', [], {
   descriptor=>{spec=>{Child=>sub {++$calls; die $token}}}, input=>\$input, match_info=>{},
  });
  1;
 };
 my $failure = $@;
 ok(!$ok, 'caller rule failure control actually fails');
 is($calls, 1, 'caller rule executes exactly once');
 is(refaddr($failure), refaddr($token), 'restoration rethrows the actual caller failure object');
 is(refaddr($bindings->{items}), refaddr($caller_ref), 'caller failure restores the parameter reference mapping');
 is_deeply($outputs, [], 'failed rule appends no value');
 my $arity = LinkedSpec::ActionIR::AST::parse_action_expr('{|| push(items,{ push(effects,"bad"); return("x") },"extra") }');
 $ok = eval { LinkedSpec::CodeblockRuntime::invoke($arity, [], $bindings, 'arity'); 1 };
 ok(!$ok, 'arity control actually fails');
 is($@->{arguments_evaluated}, 0, 'arity diagnosis precedes arguments');
 is_deeply($effects, [], 'actual caller effect array confirms no argument evaluation');
 my $guarded = LinkedSpec::ActionIR::AST::parse_action_expr('{|| push(alias,"bad") }');
 $ok = eval {
  LinkedSpec::BindingRuntime::map_leaves_mutation(\$tree, 1, 'tree', undef, sub {
   LinkedSpec::CodeblockRuntime::invoke($guarded, [], $bindings, 'guard');
  });
  1;
 };
 ok(!$ok, 'aliased active receiver control actually fails');
 is(ref($@), 'LinkedSpec::BindingRuntime::ReceiverMutationError', 'guard uses scalar identity across alias names');
 is_deeply($tree, ['original'], 'failed traversal preserves actual caller receiver');
};

subtest 'function callbacks use actual fresh working frames' => sub {
 my $source = <<'SPEC';
fn apply(secret,callback: codeblock) {
 first=callback("a"); second=callback("b"); return([first,second,secret])
}
Top:: I {
 items=["outside"]; secret="outside";
 cb={|x| secret=cat(secret,x); return(push(items,x)) };
 first=apply("seed",cb); second=apply("seed",cb); return([first,second,secret,items])
}
SPEC
 my @frames; my @secret_refs; my @records;
 my $original = \&LinkedSpec::CodeblockRuntime::invoke;
 {
  no warnings 'redefine';
  local *LinkedSpec::CodeblockRuntime::invoke = sub {
   push @frames, $_[2]; push @secret_refs, $_[2]{secret}; push @records, $_[0];
   return $original->(@_)
  };
  my %ctx;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref=>\%ctx);
  ok(ref($parser) eq 'CODE', 'actual-frame source compiles');
  my $input='x'; my $value=$parser->(\$input);
  is($ctx{last_error}, undef, 'actual-frame source succeeds');
  is_deeply($value, [[['a'],['a','b'],'seedab'],[['a'],['a','b'],'seedab'],'outside',['outside']],
   'direct function reads observe callback writes; outer slots remain untouched');
 }
 is(scalar(@frames),4,'four real invocation maps observed without copying');
 is(refaddr($frames[0]),refaddr($frames[1]),'callbacks in first function share the actual working frame');
 is(refaddr($frames[2]),refaddr($frames[3]),'callbacks in second function share the actual working frame');
 my $separate = sub { refaddr($_[0][0]) != refaddr($_[0][2]) };
 ok($separate->(\@frames),'different function invocations have different actual frame identities');
 ok(!$separate->([$frames[0],$frames[0],$frames[0],$frames[0]]),
  'deliberately aliased frames fail the same identity observation');
 is(refaddr($secret_refs[0]),refaddr($secret_refs[1]),'function parameter reference remains live across callbacks');
 isnt(refaddr($secret_refs[0]),refaddr($secret_refs[2]),'fresh invocation has a different actual parameter slot');
 is(${$secret_refs[0]},'seedab','retained actual first parameter slot reflects callback writes');
 is(${$secret_refs[2]},'seedab','retained actual second parameter slot reflects callback writes');
 is_deeply([map {scalar(keys %$_)} @records],[8,8,8,8],'actual records retain eight fields without frame storage');
 isnt(refaddr($frames[0]{items}),refaddr($frames[2]{items}),
  'callback-created aggregate slots are independent across invocations');

 my $failed_source='fn apply(callback: codeblock) { value="function"; return(with("shadow",callback)) }' .
  ' Top:: I { value="outside"; cb={|x| missing_operation() }; return(apply(cb)) }';
 my $failed_frame;
 {
  no warnings 'redefine';
  local *LinkedSpec::CodeblockRuntime::invoke = sub { $failed_frame=$_[2]; return $original->(@_) };
  my %ctx; my $parser=LinkedSpec::Get(\$failed_source,runtime_ctx_ref=>\%ctx);my $input='x';
  my $value=$parser->(\$input);
  is($value,undef,'with failure publishes no result');
  is($ctx{last_error}{detail}{code},'unknown_helper','original typed callback failure survives');
 }
 is(${$failed_frame->{value}},'function','with restores the actual function value reference after failure');
};

subtest 'functions cannot borrow rule callable names' => sub {
 my $source='fn inspect() { return(cb()) } Top:: I { cb={|| return("outer-callable") }; return(inspect()) }';
 my $descriptor=LinkedSpec::Get(\$source,return_descriptor=>1);
 ok(ref($descriptor) eq 'HASH','unbound callable keeps diagnostic descriptor route');
 my $meta=$descriptor->{spec}{Top}{meta}{action_rewriter};
 is($meta->{raw_perl_dependency_count}//0,0,'unbound function callable has no raw fallback');
 is($meta->{language_agnostic_action_ir_ready},0,'unbound callable is not claimed ready');
 is_deeply($meta->{unresolved_helpers},['cb'],'unbound callable uses existing unsupported helper diagnostic');
};

done_testing;
