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

subtest 'compatibility selectors remain temporary until scheduled source migration' => sub {
 my $spec = <<'SPEC';
Top::
 /x/ -> Done {
   set(array(legacy), ["a"])
   push(array(legacy), "b")
   set(hash(oldmeta), { "stage" : "ok" })
   return([copy(array(legacy)), copy(hash(oldmeta))])
 }
Done::
 /x/
SPEC
 my ($result, $ctx) = run_spec($spec, 'xx', 'temporary selector compatibility fixture');
 is_deeply($result, [['a', 'b'], {stage => 'ok'}], 'existing selectors remain behavior-compatible before migration');
 ok(!exists($ctx->{last_error}), 'temporary selector compatibility leaves structured runtime error clear');
};

done_testing();
