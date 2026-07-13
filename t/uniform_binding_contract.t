use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use JSON::PP ();
use Test::More;

use LinkedSpec ();

sub slurp {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "Could not read '$path': $!";
 local $/;
 return <$fh>
}

sub run_spec {
 my ($source, $input, $message) = @_;
 my %runtime_ctx;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%runtime_ctx);
 ok(ref($parser) eq 'CODE', "$message compiles");
 return (undef, \%runtime_ctx) unless ref($parser) eq 'CODE';
 my $runtime_input = $input;
 return ($parser->(\$runtime_input), \%runtime_ctx)
}

my $contract_path = File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'uniform_binding_contract.json',
);
my $json = JSON::PP->new->canonical(1)->allow_nonref(1);
my $contract = $json->decode(slurp($contract_path));

is($contract->{contract_id}, 'linkedspec-uniform-binding-v1', 'loads the adopted uniform-binding contract');

subtest 'contract future fixture executes live and from standalone generated source' => sub {
 my $fixture = $contract->{fixture};
 my ($result, $ctx) = run_spec($fixture->{spec_source}, $fixture->{input}, 'uniform-binding future fixture');
 is_deeply($result, $fixture->{expected}, 'live Perl matches the deterministic neutral fixture');
 ok(!exists($ctx->{last_error}), 'live neutral fixture leaves structured runtime error clear');

 my $source = LinkedSpec::emit_generated_source(
  \$fixture->{spec_source},
  source_identity => 'uniform-binding-fixture.spec',
 );
 ok(defined($source) && length($source), 'uniform-binding fixture emits standalone source');
 unlike($source, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER/, 'generated fixture has no unsupported-helper residue');
 my $package = 'LinkedSpec::UniformBindingContractGenerated';
 my $loaded = eval "package $package; $source; 1";
 ok($loaded, 'standalone uniform-binding source loads') or diag($@);
 if ($loaded) {
  no strict 'refs';
  my $input = $fixture->{input};
  my $generated_result;
  my $execute_ok = eval {
   $generated_result = &{"${package}::Execute"}(\$input);
   1;
  };
  ok($execute_ok, 'standalone generated execution completes') or diag($@);
  is_deeply($generated_result, $fixture->{expected}, 'standalone generated execution matches the fixture')
   if $execute_ok;
 }
};

subtest 'bare mutations auto-create and return updated typed bindings' => sub {
 my $spec = <<'SPEC';
Top::
 /x/ -> Done {
   first_push = push(items, "a")
   pushed = push(items, "b")
   split(parts, "c,d", ",")
   meta["stage"] = "ok"
   return({ "items" : items, "first_push" : first_push, "pushed" : pushed, "parts" : parts, "meta" : meta })
 }
Done::
 /x/
SPEC
 my ($result, $ctx) = run_spec($spec, 'xx', 'bare mutation fixture');
 is_deeply(
  $result,
  {
   items => ['a', 'b'],
   first_push => ['a'],
   pushed => ['a', 'b'],
   parts => ['c', 'd'],
   meta => {stage => 'ok'},
  },
  'push, split, and hash-index mutation share bare typed bindings and return independent updates',
 );
 ok(!exists($ctx->{last_error}), 'bare mutation fixture leaves structured runtime error clear');
};

subtest 'bare in-place collection helpers update one binding and return snapshots' => sub {
 my $spec = <<'SPEC';
Top::
 /x/ -> Done {
   items = [" a ", "", "b"]
   trimmed = trim_each(items)
   filtered = filter_nonempty(items)
   return([trimmed, filtered, items])
 }
Done::
 /x/
SPEC
 my ($result, $ctx) = run_spec($spec, 'xx', 'bare collection mutation fixture');
 is_deeply(
  $result,
  [['a', '', 'b'], ['a', 'b'], ['a', 'b']],
  'collection transforms return independent values and leave the binding at the latest update',
 );
 ok(!exists($ctx->{last_error}), 'bare collection mutation leaves structured runtime error clear');
};

subtest 'all array-end methods return independent updated arrays' => sub {
 my $spec = <<'SPEC';
Top::
 /x/ -> Done {
   items = ["a", "b", "c"]
   after_push_back = items.push_back("d")
   after_push_front = items.push_front("z")
   after_pop_back = items.pop_back()
   after_pop_front = items.pop_front()
   count = items.push_back("e").count()
   return({
     "items" : items,
     "after_push_back" : after_push_back,
     "after_push_front" : after_push_front,
     "after_pop_back" : after_pop_back,
     "after_pop_front" : after_pop_front,
     "count" : count
   })
 }
Done::
 /x/
SPEC
 my ($result, $ctx) = run_spec($spec, 'xx', 'array-end result fixture');
 is_deeply(
  $result,
  {
   items => ['a', 'b', 'c', 'e'],
   after_push_back => ['a', 'b', 'c', 'd'],
   after_push_front => ['z', 'a', 'b', 'c', 'd'],
   after_pop_back => ['z', 'a', 'b', 'c'],
   after_pop_front => ['a', 'b', 'c'],
   count => 4,
  },
  'push/pop end methods return saved updates and continuations consume the current array',
 );
 ok(!exists($ctx->{last_error}), 'array-end result fixture leaves structured runtime error clear');
};

subtest 'set returns the post-assignment typed value for receiver chaining' => sub {
 my $spec = <<'SPEC';
Top::
 /x/ -> Done {
   first = set(items, ["b", "a"]).sorted().first()
   return([first, items])
 }
Done::
 /x/
SPEC
 my ($result, $ctx) = run_spec($spec, 'xx', 'set chaining fixture');
 is_deeply($result, ['a', ['b', 'a']], 'set chains from the assigned typed value and preserves the binding');
 ok(!exists($ctx->{last_error}), 'set chaining fixture leaves structured runtime error clear');
};

subtest 'pure helpers read the same scalar-held typed binding that mutations update' => sub {
 my $spec = <<'SPEC';
Top::
 /x/ -> Done {
   items = []
   empty_before = is_empty(items)
   push(items, "b")
   push(items, "a")
   joined = join_values(",", items)
   item_count = count(items)
   first_item = first(items)
   ordered = sorted(items)
   meta = {}
   empty_meta_before = is_empty(meta)
   meta["stage"] = "ok"
   key_count = count_keys(meta)
   return({
     "empty_before" : empty_before,
     "joined" : joined,
     "item_count" : item_count,
     "first_item" : first_item,
     "ordered" : ordered,
     "empty_meta_before" : empty_meta_before,
     "key_count" : key_count
   })
 }
Done::
 /x/
SPEC
 my ($result, $ctx) = run_spec($spec, 'xx', 'pure uniform-binding helper fixture');
 is_deeply(
  $result,
  {
   empty_before => 1,
   joined => 'b,a',
   item_count => 2,
   first_item => 'b',
   ordered => ['a', 'b'],
   empty_meta_before => 1,
   key_count => 1,
  },
  'pure array/hash helpers observe mutation updates through the one bare typed binding',
 );
 ok(!exists($ctx->{last_error}), 'pure uniform-binding helper fixture leaves structured runtime error clear');

 my $print_each_spec = <<'SPEC';
Top::
 I { items = []; push(items, "x") }
 /x/ -> Done { print_each(items, "<", ">") }
Done::
 /x/
SPEC
 my $print_each_source = LinkedSpec::emit_generated_source(\$print_each_spec);
 like(
  $print_each_source,
  qr/foreach \(\@\{\$items \/\/ \[\]\}\)/,
  'print_each iterates the scalar-held bare array binding',
 );
};

subtest 'static rule push keeps precedence over a same-named binding' => sub {
 my $lowered = LinkedSpec::call_spec_handler_subst('Top', 'push(items, outputs)');
 like($lowered, qr/\$\$descr\{spec\}\{items\}/, 'ambiguous push resolves the potential static-rule entry');
 like($lowered, qr/__ls_push_handler/, 'ambiguous push retains a representation-neutral static-rule branch');
 like($lowered, qr/\$items/, 'ambiguous push also contains the bare array-binding branch');

 my $spec = <<'SPEC';
Top::
 I { items = ["unchanged"]; outputs = [] }
 /x/ -> Done { push(items, outputs); return([items, outputs]) }
items::
 /x/ I { return("child-result") }
Done::
 /x/
SPEC
 my ($result, $ctx) = run_spec($spec, 'xx', 'static push precedence fixture');
 is_deeply($result, [['unchanged'], ['child-result']], 'registered rule wins and the same-named binding is unchanged');
 ok(!exists($ctx->{last_error}), 'static push precedence leaves structured runtime error clear');
};

subtest 'wrong-kind mutation reports the neutral code and fields' => sub {
 my $spec = <<'SPEC';
Top::
 /x/ -> Done { items = "text"; push(items, "x"); return(items) }
Done::
 /x/
SPEC
 my ($result, $ctx) = run_spec($spec, 'xx', 'wrong-kind mutation fixture');
 ok(!defined($result), 'wrong-kind push returns no parser result');
 my $detail = $ctx->{last_error}{detail} // '';
 like($detail, qr/binding_kind_mismatch/, 'wrong-kind push reports the neutral diagnostic code');
 like($detail, qr/identifier=items/, 'wrong-kind push reports the binding identifier');
 like($detail, qr/expected_kind=array/, 'wrong-kind push reports the required kind');
 like($detail, qr/actual_kind=scalar/, 'wrong-kind push reports the actual kind');
};

subtest 'exact aggregate selectors hard-reject at Perl compile and generated-source boundaries' => sub {
 foreach my $case (@{$contract->{invalid_selector_cases}}) {
  my $source = $case->{source};
  my $surface = $case->{surface};
  my $identifier = $case->{identifier};
  my $replacement = $case->{replacement};
  my $expected = qr/aggregate_selector_removed surface=\Q$surface\E identifier=\Q$identifier\E replacement=\Q$replacement\E/;

  my $lowered = eval { LinkedSpec::call_spec_handler_subst('Top', $source) };
  my $lower_error = $@;
  ok(!defined($lowered), "$case->{id} has no compatibility lowering result");
  like($lower_error, $expected, "$case->{id} direct lowering reports the neutral diagnostic fields");

  my $spec = "Top::\n /x/ -> Done { $source }\n\nDone::\n /x/\n";
  my %runtime_ctx;
  my $parser;
  my $compile_noise = '';
  {
   open my $sink, '>', \$compile_noise or die "Could not open compile-noise sink: $!";
   local *STDERR = $sink;
   local *STDOUT = $sink;
   $parser = LinkedSpec::Get(\$spec, runtime_ctx_ref => \%runtime_ctx);
  }
  ok(ref($parser) ne 'CODE', "$case->{id} is rejected while compiling a live parser");
  is($runtime_ctx{last_error}{type}, 'compiler_pipeline', "$case->{id} live rejection is compiler-owned");
  like($runtime_ctx{last_error}{detail} // '', $expected, "$case->{id} live diagnostic preserves neutral fields");

  my ($generated, $generated_error);
  my $generated_noise = '';
  {
   open my $sink, '>', \$generated_noise or die "Could not open generated-noise sink: $!";
   local *STDERR = $sink;
   local *STDOUT = $sink;
   $generated = eval {
    LinkedSpec::emit_generated_source(\$spec, source_identity => "removed-$case->{id}.spec")
   };
   $generated_error = $@;
  }
  ok(!defined($generated), "$case->{id} cannot emit standalone generated source");
  is(ref($generated_error), 'HASH', "$case->{id} generated-source rejection is structured");
  is($generated_error->{code}, 'generated_source_emit_failed', "$case->{id} generated-source rejection has the stable outer code");
  like($generated_error->{detail} // '', $expected, "$case->{id} generated-source detail preserves neutral fields");
 }

 my $unused_function_spec = <<'SPEC';
fn retired_inside_unused() { return(array(items)) }

Top::
 /x/ -> Done { return("ok") }
Done::
 /x/
SPEC
 my %function_ctx;
 my $function_parser;
 my $function_noise = '';
 {
  open my $sink, '>', \$function_noise or die "Could not open function-noise sink: $!";
  local *STDERR = $sink;
  local *STDOUT = $sink;
  $function_parser = LinkedSpec::Get(\$unused_function_spec, runtime_ctx_ref => \%function_ctx);
 }
 ok(ref($function_parser) ne 'CODE', 'unused user-function body cannot hide a removed selector');
 is($function_ctx{last_error}{type}, 'compiler_pipeline', 'unused function rejection is compiler-owned');
 is($function_ctx{last_error}{stage}, 'function_registry', 'unused function rejects while building the staged function registry');
 like(
  $function_ctx{last_error}{detail} // '',
  qr/aggregate_selector_removed surface=array identifier=items replacement=items/,
  'unused function rejection preserves the neutral selector fields',
 );
};

subtest 'retained aggregate constructors and literals remain distinct from removed selectors' => sub {
 foreach my $case (@{$contract->{valid_constructor_cases}}) {
  my $lowered = eval { LinkedSpec::call_spec_handler_subst('Top', $case->{source}) };
  my $error = $@;
  ok(defined($lowered) && length($lowered), "$case->{id} still lowers");
  is($error, '', "$case->{id} does not enter removed-selector rejection");
 }

 my $spec = <<'SPEC';
Top::
 /x/ -> Done {
   items = ["x"]
   left = "l"
   right = "r"
   return([
     array(),
     array("items"),
     array(copy(items)),
     array(left, right),
     hash(),
     hash("key", right),
     [items],
     { "key" : left }
   ])
 }
Done::
 /x/
SPEC
 my ($result, $ctx) = run_spec($spec, 'xx', 'retained aggregate constructor fixture');
 is_deeply(
  $result,
  [[], ['items'], [['x']], ['l', 'r'], {}, {key => 'r'}, [['x']], {key => 'l'}],
  'empty, quoted/computed/multi constructors and literals retain their distinct values',
 );
 ok(!exists($ctx->{last_error}), 'retained aggregate constructors leave structured runtime error clear');
};

subtest 'selector-free source remains behavior-compatible after migration' => sub {
 my $spec = <<'SPEC';
Top::
 /x/ -> Done {
   set(legacy, ["a"])
   push(legacy, "b")
   set(oldmeta, { "stage" : "ok" })
   return([copy(legacy), copy(oldmeta)])
 }
Done::
 /x/
SPEC
 my ($result, $ctx) = run_spec($spec, 'xx', 'temporary selector compatibility fixture');
 is_deeply($result, [['a', 'b'], {stage => 'ok'}], 'bare typed bindings preserve the former compatibility result');
 ok(!exists($ctx->{last_error}), 'selector-free compatibility result leaves structured runtime error clear');
};

done_testing();
