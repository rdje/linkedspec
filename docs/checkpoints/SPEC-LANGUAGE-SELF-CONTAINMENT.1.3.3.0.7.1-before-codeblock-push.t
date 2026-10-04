use strict;
use warnings;
use Test::More;
use File::Basename qw(dirname);
use File::Path qw(make_path);
use File::Spec ();
use File::Temp qw(tempdir);
use JSON::PP ();
use Scalar::Util qw(refaddr reftype weaken);

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
 {'body'=>'return(decorate("ab","!"))','expected'=>'!AB','functions'=>'fn decorate(text,prefix) { return(cat(prefix,uppercase(text))) }','id'=>'bridge_fixed_direct'},
 {'body'=>'cb={|| return(decorate("ab","!")) }; return(cb())','expected'=>'!AB','functions'=>'fn decorate(text,prefix) { return(cat(prefix,uppercase(text))) }','id'=>'bridge_fixed_deferred'},
 {'body'=>'return(collect("a","b","c"))','expected'=>['a',['b','c']],'functions'=>'fn collect(first,...rest) { return([first,rest]) }','id'=>'bridge_rest_direct'},
 {'body'=>'cb={|| return(collect("a","b","c")) }; return(cb())','expected'=>['a',['b','c']],'functions'=>'fn collect(first,...rest) { return([first,rest]) }','id'=>'bridge_rest_deferred'},
 {'body'=>'cb={|| return(collect("a")) }; return(cb())','expected'=>['a',[]],'functions'=>'fn collect(first,...rest) { return([first,rest]) }','id'=>'bridge_rest_empty_deferred'},
 {'body'=>'return(apply("inner") { return(value) })','expected'=>'inner','functions'=>'fn apply(value,callback: codeblock) { return(callback()) }','id'=>'bridge_attached_direct'},
 {'body'=>'cb={|| return(apply("inner") { return(value) }) }; return(cb())','expected'=>'inner','functions'=>'fn apply(value,callback: codeblock) { return(callback()) }','id'=>'bridge_attached_deferred'},
 {'body'=>'return(apply("inner",{ return(value) }))','expected'=>'inner','functions'=>'fn apply(value,callback: codeblock) { return(callback()) }','id'=>'bridge_parenthesized_direct'},
 {'body'=>'cb={|| return(apply("inner",{ return(value) })) }; return(cb())','expected'=>'inner','functions'=>'fn apply(value,callback: codeblock) { return(callback()) }','id'=>'bridge_parenthesized_deferred'},
 {'body'=>'value="outer"; inner={|| return(value) }; cb={|| return(apply("inner",inner)) }; return(cb())','expected'=>'inner','functions'=>'fn apply(value,callback: codeblock) { return(callback()) }','id'=>'bridge_bound_deferred'},
 {'body'=>'effects=[]; result=join({ push(effects,"a"); return("A") },{ push(effects,"b"); return("B") }); return([result,effects])','expected'=>['AB',['a','b']],'functions'=>'fn join(a,b) { return(cat(a,b)) }','id'=>'bridge_ordered_direct'},
 {'body'=>'effects=[]; cb={|| result=join({ push(effects,"a"); return("A") },{ push(effects,"b"); return("B") }); return([result,effects]) }; return(cb())','expected'=>['AB',['a','b']],'functions'=>'fn join(a,b) { return(cat(a,b)) }','id'=>'bridge_ordered_deferred'},
 {'body'=>'cb={|| return(outer("ab")) }; return(cb())','expected'=>'!AB','functions'=>'fn inner(x) { return(uppercase(x)) }
fn outer(x) { return(cat("!",inner(x))) }','id'=>'bridge_nested_deferred'},
 {'body'=>'decorate={|text,prefix| return("slot") }; cb={|| return(decorate("x","!")) }; return(cb())','expected'=>'!x','functions'=>'fn decorate(text,prefix) { return(cat(prefix,text)) }','id'=>'bridge_precedence_deferred'},
 {'body'=>'cb={|| return(decorate("x")) }; return(cb())','error'=>{'arguments_evaluated'=>0,'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'user_function_arity_mismatch','expected'=>'exactly 2','function_name'=>'decorate','got'=>1,'kind'=>'codeblock_runtime_error'},'functions'=>'fn decorate(text,prefix) { return(cat(prefix,text)) }','id'=>'bridge_wrong_arity_deferred'},
 {'body'=>'return(apply("x",{}))','error'=>{'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'final_argument_not_codeblock','kind'=>'codeblock_runtime_error','value_kind'=>'harray'},'functions'=>'fn apply(value,callback: codeblock) { return(callback()) }','id'=>'bridge_wrong_final_kind_direct'},
 {'body'=>'cb={|| return(apply("x",{})) }; return(cb())','error'=>{'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'final_argument_not_codeblock','kind'=>'codeblock_runtime_error','value_kind'=>'harray'},'functions'=>'fn apply(value,callback: codeblock) { return(callback()) }','id'=>'bridge_wrong_final_kind_deferred'},
 {'body'=>'cb={|| return(id(value:"x")) }; return(cb())','error'=>{'arguments_evaluated'=>0,'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'user_function_keyword_arguments_unsupported','function_name'=>'id','got'=>1,'kind'=>'codeblock_runtime_error'},'functions'=>'fn id(value) { return(value) }','id'=>'bridge_keyword_deferred'},
 {'body'=>'return(repeat("x"))','expected'=>undef,'functions'=>'fn repeat(value) { return(repeat(value)) }','id'=>'bridge_function_recursion_direct','metadata'=>{'canonical_action_ir_fallback_count'=>0,'language_agnostic_action_ir_ready'=>0,'raw_perl_dependency_count'=>0,'unresolved_helper_count'=>1}},
 {'body'=>'cb={|| return(repeat("x")) }; return(cb())','error'=>{'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'user_function_recursion_unsupported','cycle'=>['repeat','repeat'],'function_name'=>'repeat','kind'=>'codeblock_runtime_error'},'functions'=>'fn repeat(value) { return(repeat(value)) }','id'=>'bridge_function_recursion_deferred'},
 {'body'=>'cb={|| return(apply(cb)) }; return(cb())','error'=>{'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'codeblock_recursion_unsupported','cycle'=>['cb','callback'],'kind'=>'codeblock_runtime_error'},'functions'=>'fn apply(callback: codeblock) { return(callback()) }','id'=>'bridge_callback_function_cycle'},
 {'body'=>'cb={|| return(missing_operation("x")) }; return(cb())','error'=>{'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'unknown_helper','kind'=>'codeblock_runtime_error','name'=>'missing_operation'},'functions'=>'','id'=>'bridge_unknown_deferred'},
 {'body'=>'cb={|| return("ok") }; return(cb())','expected'=>'ok','functions'=>'fn unused() { return(missing_operation()) }','id'=>'bridge_unrelated_unsupported_definition'},
 {'body'=>'temp="outer"; return(f(temp))','expected'=>undef,'functions'=>'fn f(value) { temp="inner"; return(value) }','id'=>'bridge_startup32_control'},
 {'body'=>'outerBlock={|callback,...rest| return(callback(rest[0],rest[1])) }; middleBlock={|callback,...rest| return(callback(rest[0],rest[1])) }; finishBlock={|left,right| return(left) }; return(outerBlock(middleBlock,finishBlock,"done"))','expected'=>'done','id'=>'bridge_equal_independent_callbacks'},
 {'body'=>'cb={|self| fresh=copy(self); return(fresh(fresh)) }; return(cb(cb))','error'=>{'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'codeblock_recursion_unsupported','cycle'=>['cb','fresh'],'kind'=>'codeblock_runtime_error'},'id'=>'bridge_cloned_callback_cycle'},
 {'body'=>'cb={|self| items=[]; push(items,self); fresh=items[0]; return(fresh(fresh)) }; return(cb(cb))','error'=>{'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'codeblock_recursion_unsupported','cycle'=>['cb','fresh'],'kind'=>'codeblock_runtime_error'},'id'=>'bridge_aggregate_callback_cycle'},
 {'body'=>'cb={|self| fresh=duplicate(self); return(fresh(fresh)) }; return(cb(cb))','error'=>{'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'codeblock_recursion_unsupported','cycle'=>['cb','fresh'],'kind'=>'codeblock_runtime_error'},'functions'=>'fn duplicate(record) { return(copy(record)) }','id'=>'bridge_compiled_copy_cycle'},
 {'body'=>'cb={|| first=collect("a"); second=collect(); return([first,second]) }; return(cb())','expected'=>[['a','tag'],['tag']],'functions'=>'fn collect(...items) { push(items,"tag"); return(items) }','id'=>'bridge_rest_fresh'},
 {'body'=>'secret="outside"; cb={|| result=inspect(); return([result,secret]) }; return(cb())','expected'=>[undef,'outside'],'functions'=>'fn inspect() { return(secret) }','id'=>'bridge_fresh_scope'},
 {'body'=>'cb={|| return(apply({|| return("inner") })) }; return(cb())','expected'=>'inner','functions'=>'fn apply(cb: codeblock) { return(cb()) }','id'=>'bridge_same_name_distinct_frames'},
 {'body'=>'next={|| return("end") }; cb={|| return(apply(next)) }; outer={|| return(apply(cb)) }; return(outer())','error'=>{'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'user_function_recursion_unsupported','cycle'=>['apply','apply'],'function_name'=>'apply','kind'=>'codeblock_runtime_error'},'functions'=>'fn apply(callback: codeblock) { return(callback()) }','id'=>'bridge_dynamic_function_cycle'},
 {'body'=>'next={|| return("end") }; cb={|| return(outer(next)) }; root={|| return(outer(cb)) }; return(root())','error'=>{'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'user_function_recursion_unsupported','cycle'=>['outer','inner','outer'],'function_name'=>'outer','kind'=>'codeblock_runtime_error'},'functions'=>'fn inner(callback: codeblock) { return(callback()) }
fn outer(callback: codeblock) { return(inner(callback)) }','id'=>'bridge_static_dynamic_function_cycle'},
 {'body'=>'cb={|| return(reveal("value")) }; return(cb())','expected'=>['value','local','marker'],'functions'=>'fn reveal(__ls_registered_fn_args) { __ls_registered_fn_context="local"; __ls_codeblock_invocation="marker"; return([__ls_registered_fn_args,__ls_registered_fn_context,__ls_codeblock_invocation]) }','id'=>'bridge_private_names'},
 {'body'=>'cb={|| return(bad()) }; return(cb())','error'=>{'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'user_function_body_unsupported','function_name'=>'bad','kind'=>'codeblock_runtime_error','unresolved_helpers'=>['missing_operation']},'functions'=>'fn bad() { return(missing_operation()) }','id'=>'bridge_unsupported_body'},
 {'body'=>'effects=[]; cb={|| return(pair({ push(effects,"bad"); return("x") })) }; return(cb())','error'=>{'arguments_evaluated'=>0,'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'user_function_arity_mismatch','expected'=>'exactly 2','function_name'=>'pair','got'=>1,'kind'=>'codeblock_runtime_error'},'functions'=>'fn pair(first,second) { return([first,second]) }','id'=>'bridge_arity_effects'},
 {'body'=>'effects=[]; cb={|| return(pair({ push(effects,"bad"); return("x") },second:"y")) }; return(cb())','error'=>{'arguments_evaluated'=>0,'class'=>'LinkedSpec::CodeblockRuntime::Error','code'=>'user_function_keyword_arguments_unsupported','function_name'=>'pair','got'=>1,'kind'=>'codeblock_runtime_error'},'functions'=>'fn pair(first,second) { return([first,second]) }','id'=>'bridge_keyword_effects'},
 {id=>'function_unbound_callable', functions=>'fn inspect() { return(cb()) }', body=>'cb={|| return("outer-callable") }; return(inspect())', expected=>undef, metadata=>{language_agnostic_action_ir_ready=>0,canonical_action_ir_fallback_count=>0,raw_perl_dependency_count=>0,unresolved_helper_count=>1}},
 {id=>'bridge_failure_restore', functions=>'fn fail(callback: codeblock) { return(callback("temporary")) }', body=>'item="outside"; cb={|item| missing_operation() }; outer={|| return(fail(cb)) }; return(outer())', error=>{class=>'LinkedSpec::CodeblockRuntime::Error',kind=>'codeblock_runtime_error',code=>'unknown_helper',name=>'missing_operation'}},
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
 if ($route eq 'emitted' && $case->{id} eq 'bridge_rest_fresh') {
  is($row->{actual_bridge_rest_proof}, 'two actual rest results; alias control rejected',
   'fresh child checks real compiled rest identities and rejects an alias');
 }
 if ($route eq 'emitted' && $case->{id} =~ /\Abridge_(?:arity_effects|keyword_effects|ordered_deferred)\z/) {
  is($row->{actual_bridge_effects_proof}, 'actual effects and compiled entry count agree',
   "$case->{id} fresh child checks actual operand effects and handler entries");
 }
 if ($route eq 'emitted' && $case->{id} eq 'bridge_failure_restore') {
  is($row->{actual_bridge_failure_proof}, 'actual exception and restored context agree',
   'fresh child checks actual typed exception identity and restored function/caller state');
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
  my @rest_results;
  my ($effects_binding, $handler_entries, $actual_error, $actual_context, $caller_item) = (undef, 0);
  my $check_frames = $sources[$index] =~ m{/function_unknown_persistence_reset\.pl\z};
  my $check_rest = $sources[$index] =~ m{/bridge_rest_fresh\.pl\z};
  my $check_effects = $sources[$index] =~ m{/bridge_(arity_effects|keyword_effects|ordered_deferred)\.pl\z} ? $1 : undef;
  my $check_failure = $sources[$index] =~ m{/bridge_failure_restore\.pl\z};
  my $invoke = \&LinkedSpec::CodeblockRuntime::invoke;
  $row->{value} = eval {
   no strict 'refs'; no warnings 'redefine';
   local *LinkedSpec::CodeblockRuntime::invoke = sub {
    push @frames, $_[2] if $check_frames;
    $effects_binding = $_[2]{effects} if defined($check_effects) && !$effects_binding;
    $caller_item = $_[2]{item} if $check_failure && !$caller_item;
    if ((defined($check_effects) || $check_failure) && ref($_[5]) eq 'HASH') {
     my $name = $check_failure ? 'fail' : $check_effects eq 'ordered_deferred' ? 'join' : 'pair';
     my $functions = $_[5]{registered_functions};
     my $entry = ref($functions) eq 'HASH' ? $functions->{$name} : undef;
     if (ref($entry) eq 'HASH' && ref($entry->{call}) eq 'CODE') {
      my $call = $entry->{call};
      local $entry->{call} = sub {
       ++$handler_entries; $actual_context = $_[1];
       my $value; my $ok = eval { $value = $call->(@_); 1 };
       $actual_error = $@ unless $ok;
       die $actual_error unless $ok;
       return $value;
      };
      return $invoke->(@_);
     }
    }
    if ($check_rest && ref($_[5]) eq 'HASH') {
     my $functions = $_[5]{registered_functions};
     my $entry = ref($functions) eq 'HASH' ? $functions->{collect} : undef;
     if (ref($entry) eq 'HASH' && ref($entry->{call}) eq 'CODE') {
      my $call = $entry->{call};
      local $entry->{call} = sub { my $value=$call->(@_); push @rest_results,$value; return $value };
      return $invoke->(@_);
     }
    }
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
  if (defined($check_effects)) {
   my $positive = $check_effects eq 'ordered_deferred';
   my $valid = $effects_binding
    && JSON::PP->new->canonical->encode($$effects_binding) eq ($positive ? '["a","b"]' : '[]')
    && $handler_entries == ($positive ? 1 : 0);
   $row->{actual_bridge_effects_proof} = $valid ? 'actual effects and compiled entry count agree'
    : 'actual effect/entry observation failed';
  }
  if ($check_failure) {
   my $valid = ref($actual_error) && ref($error) && refaddr($actual_error) == refaddr($error)
    && $actual_context && JSON::PP->new->canonical->encode($actual_context->{active_functions}) eq '[]'
    && $caller_item && $$caller_item eq 'outside';
   $row->{actual_bridge_failure_proof} = $valid ? 'actual exception and restored context agree'
    : 'actual exception/state observation failed';
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
  if ($check_rest) {
   my $distinct = sub {
    my ($values)=@_;
    return @$values == 2 && ref($values->[0]) eq 'ARRAY' && ref($values->[1]) eq 'ARRAY'
     && refaddr($values->[0]) != refaddr($values->[1]);
   };
   my $valid = $distinct->(\@rest_results)
    && !$distinct->([$rest_results[0],$rest_results[0]])
    && JSON::PP->new->canonical->encode(\@rest_results) eq '[["a","tag"],["tag"]]';
   $row->{actual_bridge_rest_proof} = $valid ? 'two actual rest results; alias control rejected'
    : 'actual compiled rest identity failure';
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

subtest 'registered bridge retains actual values, errors and restored state' => sub {
 my $source='fn gather(...items) { return(items) }' .
  ' Top:: I { cb={|| first=gather("a"); second=gather("b"); return([first,second]) }; return(cb()) }';
 my (@results,@arguments,@contexts,@records);
 my $invoke=\&LinkedSpec::CodeblockRuntime::invoke;
 my ($value,%ctx);
 {
  no warnings 'redefine';
  local *LinkedSpec::CodeblockRuntime::invoke = sub {
   push @records,$_[0];
   my $functions=$_[5]{registered_functions};
   my $entry=ref($functions) eq 'HASH' ? $functions->{gather} : undef;
   return $invoke->(@_) unless ref($entry) eq 'HASH' && ref($entry->{call}) eq 'CODE';
   my $call=$entry->{call};
   local $entry->{call}=sub {
    push @arguments,$_[0]; push @contexts,$_[1];
    my $result=$call->(@_); push @results,$result; return $result;
   };
   return $invoke->(@_);
  };
  my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx); my $input='x'; $value=$parser->(\$input);
 }
 is($ctx{last_error},undef,'actual compiled rest source succeeds');
 is_deeply($value,[['a'],['b']],'source result matches independent rest oracle');
 my $distinct=sub { @{$_[0]} == 2 && refaddr($_[0][0]) != refaddr($_[0][1]) };
 ok($distinct->(\@results),'compiled function returns actual distinct rest arrays');
 ok(!$distinct->([$results[0],$results[0]]),'same observation rejects deliberately aliased results');
 ok($distinct->(\@arguments),'caller argument arrays are actual separate invocation values');
 is_deeply([map {$_->{active_functions}} @contexts],[[],[]],'actual invocation contexts restore active functions');
 is_deeply([map {scalar(keys %$_)} @records],[8],'actual codeblock stores no registry or origin field');
 if (@results == 2) {
  push @{$results[0]},'mutation';
  is_deeply($results[1],['b'],'mutating one retained actual rest value leaves the other intact');
  is_deeply($value,[['a'],['b']],'actual returned outer arrays are detached from retained callee values');
 } else {
  fail('requires two actual callee results to prove independent mutation');
  fail('requires actual callee results to prove detached outer arrays');
 }

 for my $control (
  ['arity','pair({ push(effects,"bad"); return("x") })','user_function_arity_mismatch',[],0],
  ['keyword','pair({ push(effects,"bad"); return("x") },second:"y")','user_function_keyword_arguments_unsupported',[],0],
  ['positive','pair({ push(effects,"a"); return("A") },{ push(effects,"b"); return("B") })',undef,['a','b'],1],
 ) {
  my ($id,$call_source,$error_code,$effects,$expected_calls)=@$control;
  my $control_source='fn pair(first,second) { return([first,second]) } Top:: I { effects=[]; cb={|| return('.$call_source.') }; return(cb()) }';
  my ($binding,$calls)= (undef,0); my %control_ctx;
  {
   no warnings 'redefine';
   local *LinkedSpec::CodeblockRuntime::invoke=sub {
    $binding=$_[2]{effects};
    my $functions=$_[5]{registered_functions};
    my $entry=ref($functions) eq 'HASH' ? $functions->{pair} : undef;
    return $invoke->(@_) unless ref($entry) eq 'HASH' && ref($entry->{call}) eq 'CODE';
    my $call=$entry->{call};
    local $entry->{call}=sub {++$calls; return $call->(@_)};
    return $invoke->(@_);
   };
   my $parser=LinkedSpec::Get(\$control_source,runtime_ctx_ref=>\%control_ctx);my $input='x';$parser->(\$input);
  }
  is_deeply($$binding,$effects,"$id checks actual caller effects rather than the serialized counter");
  is($calls,$expected_calls,"$id observes actual compiled handler entry count");
  is($control_ctx{last_error}{detail}{code},$error_code,"$id retains the selected typed failure");
 }

 my $failed_source='fn fail(callback: codeblock) { return(callback("temporary")) } Top:: I { item="outside"; cb={|item| missing_operation() }; outer={|| return(fail(cb)) }; return(outer()) }';
 my ($actual_error,$actual_context,$caller_item); my %failed_ctx;
 {
  no warnings 'redefine';
  local *LinkedSpec::CodeblockRuntime::invoke=sub {
   $caller_item=$_[2]{item} unless $caller_item;
   my $functions=$_[5]{registered_functions};
   my $entry=ref($functions) eq 'HASH' ? $functions->{fail} : undef;
   return $invoke->(@_) unless ref($entry) eq 'HASH' && ref($entry->{call}) eq 'CODE';
   my $call=$entry->{call};
   local $entry->{call}=sub {
    $actual_context=$_[1];my $result;my $ok=eval {$result=$call->(@_);1};
    $actual_error=$@ unless $ok;die $actual_error unless $ok;return $result;
   };
   return $invoke->(@_);
  };
  my $parser=LinkedSpec::Get(\$failed_source,runtime_ctx_ref=>\%failed_ctx);my $input='x';$parser->(\$input);
 }
 is(refaddr($failed_ctx{last_error}{detail}),refaddr($actual_error),'actual typed callback exception survives the compiled bridge');
 is_deeply($actual_context ? $actual_context->{active_functions} : undef,[],
  'failure restores the actual function recursion state');
 is($$caller_item,'outside','failure preserves the actual unrelated caller slot');

 unless (LinkedSpec::CodeblockRuntime->can('_codeblock_origin')) {
  fail('requires opaque callable origins to prove copy/independence/lifetime');
  return;
 }
 my $record=LinkedSpec::ActionIR::AST::parse_action_expr('{|| return("value") }');
 my $copy=LinkedSpec::CodeblockRuntime::_copy_value($record);
 my $independent=LinkedSpec::ActionIR::AST::parse_action_expr('{|| return("value") }');
 is(refaddr(LinkedSpec::CodeblockRuntime::_codeblock_origin($record)),
  refaddr(LinkedSpec::CodeblockRuntime::_codeblock_origin($copy)),'copied callable retains actual opaque origin');
 isnt(refaddr(LinkedSpec::CodeblockRuntime::_codeblock_origin($record)),
  refaddr(LinkedSpec::CodeblockRuntime::_codeblock_origin($independent)),'equal independently constructed callable has a distinct origin');
 my $marker=LinkedSpec::CodeblockRuntime::_codeblock_origin($record);
 my $weak_ast=$record->{body_ast};weaken($weak_ast);undef $record;undef $copy;
 is($weak_ast,undef,'retaining opaque identity metadata does not retain the callable AST or environment');
};

done_testing;
