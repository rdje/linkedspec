use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use JSON::PP ();
use Test::More;

use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::BindingRuntime ();

sub slurp {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "Could not read '$path': $!";
 local $/;
 return <$fh>
}

my $json = JSON::PP->new->canonical(1)->allow_nonref(1);
my $contract = $json->decode(slurp(File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'map_leaves_mutation_contract.json',
)));

is($contract->{contract_id}, 'linkedspec-map-leaves-mutation-v1', 'loads the frozen map_leaves! contract');

sub projected_like {
 my ($actual, $expected) = @_;
 if (ref($expected) eq 'HASH') {
  return {
   map { $_ => projected_like($actual->{$_}, $expected->{$_}) }
   sort keys %$expected
  }
 }
 if (ref($expected) eq 'ARRAY') {
  return [
   map { projected_like($actual->[$_], $expected->[$_]) }
   0 .. $#$expected
  ]
 }
 return $actual
}

sub clone_value {
 my ($value) = @_;
 return $json->decode($json->encode($value))
}

sub receiver_error_projection {
 my ($error) = @_;
 return undef unless ref($error);
 return {%$error}
}

subtest 'dedicated receiver-mutation AST and exclusions agree with the neutral contract' => sub {
 for my $case (@{$contract->{valid_syntax_cases}}) {
  my $ast = LinkedSpec::ActionIR::AST::parse_action_expr($case->{source});
  if (ref($case->{expected_ast}) eq 'HASH') {
   is_deeply(
    projected_like($ast, $case->{expected_ast}),
    $case->{expected_ast},
    "$case->{id} preserves every frozen AST field and span",
   );
  } else {
   is($ast->{kind}, 'receiver_mutation_chain', "$case->{id} uses the dedicated AST kind");
   is($ast->{receiver}{name}, $case->{expected_receiver}, "$case->{id} preserves the receiver");
   is_deeply(
    [map { $_->{method} } @{$ast->{continuation}}],
    $case->{expected_continuation},
    "$case->{id} preserves ordinary continuation methods",
   );
  }
 }

 for my $case (@{$contract->{invalid_syntax_cases}}) {
  my $ok = eval {
   LinkedSpec::ActionIR::AST::parse_action_expr($case->{source});
   1;
  };
  my $error = $@;
  ok(!$ok, "$case->{id} is rejected");
  is(ref($error), 'LinkedSpec::ActionIR::AST::Parser::Diagnostic', "$case->{id} is a typed parser diagnostic");
  is($error->{code}, $case->{diagnostic}{code}, "$case->{id} preserves diagnostic code");
  is($error->{stage}, 'action_parse', "$case->{id} preserves diagnostic stage");
  is($error->{message}, $case->{diagnostic}{message}, "$case->{id} preserves exact message");
  is_deeply(
   $error->{source_span},
   {
    start => $case->{diagnostic}{source_span}{start},
    end => $case->{diagnostic}{source_span}{end},
    unit => 'unicode_scalar',
    provenance => 'authored',
   },
   "$case->{id} preserves the authored half-open span",
  );
 }

 my %expected_kind = (
  nonbang_twin => 'fluent_chain',
  walk_nonbang => 'fluent_chain',
  reduce_nonbang => 'fluent_chain',
  bang_word_alias => 'fluent_chain',
  bang_variable => 'raw_perl',
 );
 for my $case (@{$contract->{excluded_syntax_cases}}) {
  my $ast = LinkedSpec::ActionIR::AST::parse_action_expr($case->{source});
  is($ast->{kind}, $expected_kind{$case->{id}}, "$case->{id} stays outside receiver-mutation syntax");
 }
};

subtest 'runtime traverses the frozen topology and commits only rebuilt leaves' => sub {
 for my $case (@{$contract->{success_cases}}[0 .. 7]) {
  my $binding = clone_value($case->{initial_bindings}{$case->{binding}});
  my @steps = map { clone_value($_) } @{$case->{callback_steps}};
  my @observed;
  my $result = LinkedSpec::BindingRuntime::map_leaves_mutation(
   \$binding,
   1,
   $case->{binding},
   {source_id => "contract:$case->{id}", start => 0, end => length($case->{binding}), unit => 'unicode_scalar', provenance => 'authored'},
   sub {
    my ($value, $selector, $path, $depth, $root_kind) = @_;
    my $step = shift @steps;
    my $selector_name = $root_kind eq 'harray' ? 'key' : 'index';
    my $frame = {
     value => clone_value($value),
     $selector_name => clone_value($selector),
     path => clone_value($path),
     depth => $depth,
    };
    is_deeply($frame, $step->{frame}, "$case->{id} callback frame follows frozen order and shape");
    if (ref($step->{mutate_frame}) eq 'HASH') {
     $path->[0] = $step->{mutate_frame}{path}[0];
     $value = clone_value($step->{mutate_frame}{value});
    }
    push @observed, clone_value($frame->{path});
    return clone_value($step->{result});
   },
  );
  is_deeply($binding, $case->{expected_bindings}{$case->{binding}}, "$case->{id} publishes only rebuilt leaves");
  is_deeply($result, $case->{expected_result}, "$case->{id} returns the detached rebuilt root");
  is(scalar(@steps), 0, "$case->{id} visits every and only frozen leaf");
 }
};

subtest 'receiver validation and guard failures are typed and atomic' => sub {
 my $missing;
 my $ok = eval {
  LinkedSpec::BindingRuntime::map_leaves_mutation(
   \$missing, 0, 'tree',
   {source_id => 'contract:receiver_absent', start => 0, end => 4, unit => 'unicode_scalar', provenance => 'authored'},
   sub { return $_[0] },
  );
  1;
 };
 my $error = $@;
 ok(!$ok, 'missing receiver is rejected');
 ok(LinkedSpec::BindingRuntime::is_receiver_mutation_error($error), 'missing receiver uses the typed receiver error');
 is($error->{code}, 'map_leaves_mutation_receiver_missing', 'missing receiver preserves its code');

 for my $value_case ([undef, 'null'], ['scalar', 'string']) {
  my ($value, $kind) = @$value_case;
  $ok = eval {
   LinkedSpec::BindingRuntime::map_leaves_mutation(
    \$value, 1, 'tree',
    {source_id => "contract:receiver_$kind", start => 0, end => 4, unit => 'unicode_scalar', provenance => 'authored'},
    sub { return $_[0] },
   );
   1;
  };
  $error = $@;
  ok(!$ok, "$kind receiver is rejected");
  ok(LinkedSpec::BindingRuntime::is_receiver_mutation_error($error), "$kind receiver uses the typed receiver error");
  is($error->{code}, 'map_leaves_mutation_receiver_kind_mismatch', "$kind receiver preserves its code");
  is($error->{actual_kind}, $kind, "$kind receiver preserves its runtime kind");
 }

 my @cases = (
  ['direct_assignment_reentrant', 'assign'],
  ['nested_bang_reentrant', 'map_leaves!'],
  ['nested_write_reentrant', 'nested_write'],
  ['helper_mediated_reentrant', 'helper:set'],
 );
 for my $entry (@cases) {
  my ($id, $attempt) = @$entry;
  my ($case) = grep { $_->{id} eq $id } @{$contract->{failure_cases}};
  my $tree = clone_value($case->{initial_bindings}{tree});
  my $audit = clone_value($case->{initial_bindings}{audit});
  my %__ls_binding_presence = (tree => 1, defined($audit) ? (audit => 1) : ());
  my $lowered = LinkedSpec::call_spec_handler_subst('Top', $case->{source});
  my $ignored = eval $lowered;
  $error = $@;
  ok(LinkedSpec::BindingRuntime::is_receiver_mutation_error($error), "$id throws the typed receiver guard");
  is($error->{code}, 'receiver_mutation_reentrant', "$id preserves the reentrant code");
  is($error->{attempt}, $attempt, "$id identifies the attempted write surface");
  is_deeply($tree, $case->{expected_bindings}{tree}, "$id leaves the receiver unchanged");
  is_deeply($audit, $case->{expected_bindings}{audit}, "$id preserves completed unrelated effects")
   if exists $case->{expected_bindings}{audit};
 }

 my @additional_writes = (
  ['tree.map_leaves!() { set_key(tree, "x", "X"); return(value) }', 'tree', 'helper:set_key'],
  ['items.map_leaves!() { push(items, "X"); return(value) }', 'items', 'helper:push'],
  ['items.map_leaves!() { items += "X"; return(value) }', 'items', 'append'],
  ['items.map_leaves!() { items.push_back("X"); return(value) }', 'items', 'push_back'],
  ['items.map_leaves!() { items.push_front("X"); return(value) }', 'items', 'push_front'],
  ['items.map_leaves!() { items.pop_back(); return(value) }', 'items', 'pop_back'],
  ['items.map_leaves!() { items.pop_front(); return(value) }', 'items', 'pop_front'],
  ['items.map_leaves!() { split(items, "a,b", ","); return(value) }', 'items', 'helper:split', 'split(items, "a,b", ",")'],
  ['items.map_leaves!() { split_each(items, ","); return(value) }', 'items', 'helper:split_each', 'split_each(items, ",")'],
  ['items.map_leaves!() { trim_each(items); return(value) }', 'items', 'helper:trim_each', 'trim_each(items)'],
  ['items.map_leaves!() { filter_nonempty(items); return(value) }', 'items', 'helper:filter_nonempty', 'filter_nonempty(items)'],
  ['items.map_leaves!() { filter_match(items, /A/); return(value) }', 'items', 'helper:filter_match', 'filter_match(items, /A/)'],
  ['items.map_leaves!() { lowercase_each(items); return(value) }', 'items', 'helper:lowercase_each', 'lowercase_each(items)'],
  ['items.map_leaves!() { uppercase_each(items); return(value) }', 'items', 'helper:uppercase_each', 'uppercase_each(items)'],
  ['items.map_leaves!() { uniq(items); return(value) }', 'items', 'helper:uniq', 'uniq(items)'],
  ['items.map_leaves!() { uniq(trim_each(items)); return(value) }', 'items', 'helper:trim_each', 'uniq(trim_each(items))'],
 );
 for my $write (@additional_writes) {
  my ($source, $target, $attempt, $write_source) = @$write;
  my $tree = {a => 'A'};
  my $items = ['A'];
  my %__ls_binding_presence = (tree => 1, items => 1);
  my $lowered = LinkedSpec::call_spec_handler_subst('Top', $source);
  my $ignored = eval $lowered;
  my $error = $@;
  ok(LinkedSpec::BindingRuntime::is_receiver_mutation_error($error), "$attempt is rejected for the active $target identity");
  is($error->{attempt}, $attempt, "$attempt reports its exact write surface");
  if (defined($write_source)) {
   my $start = index($source, $write_source);
   is_deeply(
    $error->{source_span},
    {
     source_id => 'action:Top',
     start => $start,
     end => $start + length($write_source),
     unit => 'unicode_scalar',
     provenance => 'authored',
    },
    "$attempt preserves the authored pipeline write span",
   );
  }
  is_deeply($tree, {a => 'A'}, "$attempt leaves the hash receiver unchanged");
  is_deeply($items, ['A'], "$attempt leaves the array receiver unchanged");
 }
};

subtest 'callback failure is atomic and the identity guard always releases' => sub {
 my $tree = {a => 'A', b => 'B'};
 my @audit;
 my $ok = eval {
  LinkedSpec::BindingRuntime::map_leaves_mutation(
   \$tree, 1, 'tree',
   {source_id => 'test:callback', start => 0, end => 4, unit => 'unicode_scalar', provenance => 'authored'},
   sub {
    my ($value, undef, $path) = @_;
    push @audit, clone_value($path);
    die "callback requested failure\n" if $path->[0] eq 'b';
    return "$value!";
   },
  );
  1;
 };
 ok(!$ok, 'callback failure propagates');
 like($@, qr/^callback requested failure/, 'callback failure is not wrapped');
 is_deeply($tree, {a => 'A', b => 'B'}, 'callback failure publishes no partial leaf updates');
 is_deeply(\@audit, [['a'], ['b']], 'unrelated callback effects retain ordinary semantics');

 my $result = LinkedSpec::BindingRuntime::map_leaves_mutation(
  \$tree, 1, 'tree',
  {source_id => 'test:retry', start => 0, end => 4, unit => 'unicode_scalar', provenance => 'authored'},
  sub { return "$_[0]!" },
 );
 is_deeply($tree, {a => 'A!', b => 'B!'}, 'a later invocation succeeds after callback failure');
 is_deeply($result, $tree, 'the successful retry returns the rebuilt root');
};

subtest 'all aggregate boundaries and same-spelling local identities stay detached' => sub {
 my $tree = {leaf => ['A']};
 my $callback_value;
 my $callback_path;
 my $callback_result;
 my $returned = LinkedSpec::BindingRuntime::map_leaves_mutation(
  \$tree, 1, 'tree',
  {source_id => 'test:detach', start => 0, end => 4, unit => 'unicode_scalar', provenance => 'authored'},
  sub {
   ($callback_value, undef, $callback_path) = @_;
   $callback_result = ['A', {nested => ['B']}];
   return $callback_result;
  },
 );
 $callback_value->[0] = 'callback-value-mutated';
 $callback_path->[0] = 'callback-path-mutated';
 $callback_result->[1]{nested}[0] = 'callback-result-mutated';
 $returned->{leaf}[0] = 'returned-mutated';
 is_deeply($tree, {leaf => ['A', {nested => ['B']}]}, 'committed receiver is detached from every callback/result boundary');

 my $shadow = ['local'];
 my $guarded = {a => 'A'};
 my $shadow_result = LinkedSpec::BindingRuntime::map_leaves_mutation(
  \$guarded, 1, 'tree',
  {source_id => 'test:shadow', start => 0, end => 4, unit => 'unicode_scalar', provenance => 'authored'},
  sub {
   LinkedSpec::BindingRuntime::assert_receiver_writable(\$shadow, 'tree', 'assign', {start => 0, end => 4});
   $shadow = ['changed'];
   return 'A!';
  },
 );
 is_deeply($shadow, ['changed'], 'same spelling with a different scalar identity remains writable');
 is_deeply($shadow_result, {a => 'A!'}, 'shadow write does not interfere with leaf publication');
};

subtest 'continuations start after publication and guard release' => sub {
 my $tree = {a => 'A'};
 my %__ls_binding_presence = (tree => 1);
 my $source = 'tree.map_leaves!() { return(cat(value, "!")) }.with() { tree["extra"][2] = "X"; return(value) }';
 my $lowered = LinkedSpec::call_spec_handler_subst('Top', $source);
 my $ignored = eval $lowered;
 my $error = $@;
 ok(LinkedSpec::BindingRuntime::is_nested_write_error($error), 'post-commit write uses the ordinary nested-write diagnostic');
 is($error->{code}, 'nested_write_array_gap', 'post-commit write preserves the nested-write code');
 is_deeply($tree, {a => 'A!'}, 'post-commit failure preserves the already-published leaves');

 my $items = ['A', 'B'];
 %__ls_binding_presence = (items => 1);
 $lowered = LinkedSpec::call_spec_handler_subst(
  'Top',
  'result = items.map_leaves!() { return(cat(index, "=", value)) }.count()',
 );
 my $result;
 $ignored = eval $lowered;
 is($@, '', 'ordinary count continuation succeeds');
 is($result, 2, 'count continuation consumes the detached updated result');
 is_deeply($items, ['0=A', '1=B'], 'array leaves publish before the continuation');
};

subtest 'full Perl compilation has no fallback or syntax residue' => sub {
 my $spec = "Top::\n"
  . " /x/ -> Done { tree = { \"b\" : \"B\", \"a\" : \"A\" }; result = tree.map_leaves!() { return(cat(key, \"=\", value)) }; return(array(result, tree)) }\n"
  . "\nDone::\n /[a-z]+/\n";
 my $parser = eval { LinkedSpec::Get(\$spec) };
 ok(ref($parser) eq 'CODE', 'map_leaves! spec compiles') or diag($@);
 my $input = 'xhello';
 my $result = eval { $parser->(\$input) };
 is($@, '', 'compiled map_leaves! parser executes');
 is_deeply(
  $result,
  [{a => 'a=A', b => 'b=B'}, {a => 'a=A', b => 'b=B'}],
  'compiled parser returns and retains the published tree',
 );

 my $descriptor = LinkedSpec::Get(\$spec, return_descriptor => 1);
 my $meta = $descriptor->{spec}{Top}{meta}{action_rewriter};
 is($meta->{canonical_action_ir_fallback_count}, 0, 'compiled bang traversal has no canonical fallback');
 is($meta->{unresolved_helper_count}, 0, 'compiled bang traversal has no unresolved helper');
 ok($meta->{language_agnostic_action_ir_ready}, 'compiled bang traversal remains ActionIR ready');

 my $generated = '';
 LinkedSpec::Get(
  \$spec,
  generate_only => 1,
  dump_parser_source => 1,
  parser_source_ref => \$generated,
 );
 unlike($generated, qr/\.map_leaves!/, 'generated Perl contains no bang-method syntax residue');
 like($generated, qr/BindingRuntime::map_leaves_mutation/, 'generated Perl uses the owned receiver runtime');
};

done_testing;
