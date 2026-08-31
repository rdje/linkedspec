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

sub clone_value {
 my ($value) = @_;
 return JSON::PP->new->allow_nonref(1)->decode(
  JSON::PP->new->canonical(1)->allow_nonref(1)->encode($value)
 )
}

sub segment_hint {
 my ($kind) = @_;
 return $kind if $kind =~ /\A(?:string|integer|number|boolean|null|array|harray|codeblock)\z/o;
 die "Unsupported neutral segment kind '$kind'"
}

sub runtime_segments {
 my ($case, $ast) = @_;
 my @segments;
 for (my $index = 0; $index < @{$case->{segments}}; ++$index) {
  my $observation = $case->{segments}[$index];
  push @segments, {
   value => clone_value($observation->{value}),
   kind_hint => segment_hint($observation->{kind}),
   source_span => {
    source_id => "contract:$case->{id}",
    %{$ast->{segments}[$index]{source_span}},
    unit => 'unicode_scalar',
    provenance => 'authored',
   },
  };
 }
 return \@segments
}

sub expected_runtime_error {
 my ($case, $ast) = @_;
 my $expected = $case->{expected_error};
 my $index = $expected->{segment_index};
 my %common = (
  operation => 'nested_write_vivification',
  binding => $case->{binding},
  segment_index => $index,
  path => clone_value($expected->{path}),
  source_span => {
   source_id => "contract:$case->{id}",
   %{$ast->{segments}[$index]{source_span}},
   unit => 'unicode_scalar',
   provenance => 'authored',
  },
 );
 if ($expected->{code} eq 'nested_write_segment_invalid') {
  return {
   code => $expected->{code},
   %common,
   actual_kind => $expected->{actual_kind},
   reason => $expected->{reason},
   message => "nested write segment $index for binding '$case->{binding}' must evaluate to a string or nonnegative integer; got $expected->{actual_kind} ($expected->{reason})",
  };
 }
 if ($expected->{code} eq 'nested_write_kind_conflict') {
  return {
   code => $expected->{code},
   %common,
   expected_kind => $expected->{expected_kind},
   actual_kind => $expected->{actual_kind},
   message => "nested write segment $index for binding '$case->{binding}' requires $expected->{expected_kind}; found $expected->{actual_kind}",
  };
 }
 return {
  code => $expected->{code},
  %common,
  index => $expected->{index},
  length => $expected->{length},
  message => "nested write segment $index for binding '$case->{binding}' cannot create array index $expected->{index} at length $expected->{length}",
 };
}

my $contract_path = File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'write_vivification_contract.json',
);
my $json = JSON::PP->new->canonical(1)->allow_nonref(1);
my $contract = $json->decode(slurp($contract_path));

is($contract->{contract_id}, 'linkedspec-write-vivification-v1', 'loads the frozen nested-write contract');

subtest 'valid authored assignments use one expression-bearing ActionIR node' => sub {
 my %kind_map = (
  string_literal => 'string',
  integer_literal => 'number',
  identifier => 'variable',
  call => 'call',
 );
 for my $case (@{$contract->{valid_syntax_cases}}) {
  my $ast = LinkedSpec::ActionIR::AST::parse_action_expr($case->{source});
  my $expected = $case->{expected_ast};
  is($ast->{kind}, 'assign_nested_access', "$case->{id} uses assign_nested_access");
  is($ast->{source}, $expected->{source}, "$case->{id} retains complete source");
  is_deeply($ast->{source_span}, $expected->{source_span}, "$case->{id} retains assignment span");
  is($ast->{base}, $expected->{base}, "$case->{id} retains bare binding base");
  is(scalar(@{$ast->{segments}}), scalar(@{$expected->{segments}}), "$case->{id} retains segment count");
  for (my $index = 0; $index < @{$expected->{segments}}; ++$index) {
   my $actual_segment = $ast->{segments}[$index];
   my $expected_segment = $expected->{segments}[$index];
   is($actual_segment->{kind}, 'path_segment', "$case->{id} segment $index has neutral node kind");
   is($actual_segment->{source}, $expected_segment->{source}, "$case->{id} segment $index excludes brackets");
   is_deeply($actual_segment->{source_span}, $expected_segment->{source_span}, "$case->{id} segment $index span excludes brackets");
   is(
    $actual_segment->{expression}{kind},
    $kind_map{$expected_segment->{expression}{kind}},
    "$case->{id} segment $index retains its typed Perl expression",
   );
   is($actual_segment->{expression}{source}, $expected_segment->{expression}{source}, "$case->{id} segment $index expression source agrees");
   is_deeply($actual_segment->{expression}{source_span}, $expected_segment->{expression}{source_span}, "$case->{id} segment $index expression span agrees");
  }
 }
};

subtest 'invalid authored nested writes fail with exact typed action-parse diagnostics' => sub {
 for my $case (@{$contract->{invalid_syntax_cases}}) {
  my $ok = eval {
   LinkedSpec::ActionIR::AST::parse_action_expr($case->{source});
   1;
  };
  my $error = $@;
  ok(!$ok, "$case->{id} is rejected");
  is(ref($error), 'LinkedSpec::ActionIR::AST::Parser::Diagnostic', "$case->{id} throws the typed parser diagnostic");
  is($error->{code}, $case->{diagnostic}{code}, "$case->{id} preserves diagnostic code");
  is($error->{stage}, 'action_parse', "$case->{id} preserves action_parse stage");
  is($error->{message}, $case->{diagnostic}{message}, "$case->{id} preserves exact message");
  is_deeply(
   $error->{source_span},
   {
    start => $case->{diagnostic}{source_span}{start},
    end => $case->{diagnostic}{source_span}{end},
    unit => 'unicode_scalar',
    provenance => 'authored',
   },
   "$case->{id} preserves authored Unicode-scalar span",
  );
 }
};

subtest 'neutral success cases create and replace isolated typed value trees' => sub {
 for my $case (@{$contract->{success_cases}}) {
  my $ast = LinkedSpec::ActionIR::AST::parse_action_expr($case->{source});
  my $initial = $case->{initial_binding};
  my $present = $initial->{present} ? 1 : 0;
  my $binding = $present ? clone_value($initial->{value}) : undef;
  for my $observation (@{$case->{segments}}) {
   if (exists $observation->{same_binding_after}) {
    $present = 1;
    $binding = clone_value($observation->{same_binding_after});
   }
  }
  if (exists $case->{rhs}{same_binding_after}) {
   $present = 1;
   $binding = clone_value($case->{rhs}{same_binding_after});
  }
  my ($updated, $result) = LinkedSpec::BindingRuntime::nested_write(
   $binding,
   $present,
   $case->{binding},
   runtime_segments($case, $ast),
   clone_value($case->{rhs}{value}),
  );
  is_deeply($updated, $case->{expected_binding}, "$case->{id} commits the expected binding");
  is_deeply($result, $case->{expected_result}, "$case->{id} returns the expected detached root");
 }
};

subtest 'neutral structural failures are typed and leave the post-evaluation state unchanged' => sub {
 for my $case (@{$contract->{failure_cases}}) {
  my $ast = LinkedSpec::ActionIR::AST::parse_action_expr($case->{source});
  my $initial = $case->{initial_binding};
  my $present = $initial->{present} ? 1 : 0;
  my $binding = $present ? clone_value($initial->{value}) : undef;
  for my $observation (@{$case->{segments}}) {
   if (exists $observation->{same_binding_after}) {
    $present = 1;
    $binding = clone_value($observation->{same_binding_after});
   }
  }
  if (exists $case->{rhs}{same_binding_after}) {
   $present = 1;
   $binding = clone_value($case->{rhs}{same_binding_after});
  }
  my $before = clone_value($binding);
  my $ok = eval {
   LinkedSpec::BindingRuntime::nested_write(
    $binding,
    $present,
    $case->{binding},
    runtime_segments($case, $ast),
    clone_value($case->{rhs}{value}),
   );
   1;
  };
  my $error = $@;
  ok(!$ok, "$case->{id} fails structurally");
  ok(LinkedSpec::BindingRuntime::is_nested_write_error($error), "$case->{id} throws a nested-write error object");
  is_deeply({%$error}, expected_runtime_error($case, $ast), "$case->{id} preserves every typed diagnostic field");
  is_deeply($binding, $before, "$case->{id} commits no partial structural path");
 }
};

subtest 'dynamic Perl scalar kinds distinguish strings integers and integral-valued numbers' => sub {
 my $string_selector = '0';
 my ($string_root) = LinkedSpec::BindingRuntime::nested_write(
  undef,
  0,
  'string_root',
  [{value => $string_selector, kind_hint => 'dynamic', source_span => {start => 0, end => 1}}],
  'value',
 );
 is_deeply($string_root, {'0' => 'value'}, 'a dynamic numeric-looking string selects an harray');

 my $integer_selector = 0;
 my ($array_root) = LinkedSpec::BindingRuntime::nested_write(
  undef,
  0,
  'array_root',
  [{value => $integer_selector, kind_hint => 'dynamic', source_span => {start => 0, end => 1}}],
  'value',
 );
 is_deeply($array_root, ['value'], 'a dynamic integer selects an array');

 my $number_selector = 1.0;
 my $ok = eval {
  LinkedSpec::BindingRuntime::nested_write(
   undef,
   0,
   'number_root',
   [{value => $number_selector, kind_hint => 'dynamic', source_span => {start => 0, end => 3}}],
   'value',
  );
  1;
 };
 my $error = $@;
 ok(!$ok, 'an integral-valued dynamic number is not silently retyped as an integer');
 ok(LinkedSpec::BindingRuntime::is_nested_write_error($error), 'integral-valued number failure stays typed');
 is($error->{actual_kind}, 'number', 'integral-valued number preserves its runtime number kind');
 is($error->{reason}, 'fractional_number', 'integral-valued number uses the frozen number-selector reason');
};

subtest 'binding result initial tree and aggregate RHS are mutually detached' => sub {
 my $case = $contract->{detachment_case};
 my $ast = LinkedSpec::ActionIR::AST::parse_action_expr($case->{source});
 my $initial = clone_value($case->{initial_binding}{value});
 my $rhs = clone_value($case->{rhs}{value});
 my ($binding, $result) = LinkedSpec::BindingRuntime::nested_write(
  $initial,
  1,
  $case->{binding},
  runtime_segments($case, $ast),
  $rhs,
 );
 $rhs->[0] = 'rhs-mutated';
 $result->{payload}[0] = 'result-mutated';
 $binding->{existing}[0] = 'binding-mutated';
 $initial->{existing}[0] = 'initial-mutated';
 is_deeply(
  {initial => $initial, rhs => $rhs, binding => $binding, result => $result},
  $case->{expected},
  'all four observable values detach in both directions',
 );
};

{
 package LinkedSpec::WriteVivificationOrderScalar;
 sub TIESCALAR { return bless {events => $_[1], label => $_[2], value => $_[3], fail => $_[4]}, $_[0] }
 sub FETCH {
  my ($self) = @_;
  push @{$self->{events}}, $self->{label};
  die "$self->{label} failed\n" if $self->{fail};
  return $self->{value};
 }
 sub STORE { $_[0]{value} = $_[1]; return }
}

subtest 'lowered Perl evaluates segments once left-to-right then RHS and propagates expression failure' => sub {
 my @events;
 my ($first, $second, $rhs);
 tie $first, 'LinkedSpec::WriteVivificationOrderScalar', \@events, 'segment:0', 'items', 0;
 tie $second, 'LinkedSpec::WriteVivificationOrderScalar', \@events, 'segment:1', 0, 0;
 tie $rhs, 'LinkedSpec::WriteVivificationOrderScalar', \@events, 'rhs', 'value', 0;
 my $document;
 my %__ls_binding_presence;
 my $lowered = LinkedSpec::call_spec_handler_subst('Top', q{document[first][second] = rhs});
 my $result = eval $lowered;
 is($@, '', 'ordered lowering completes');
 is_deeply(\@events, ['segment:0', 'segment:1', 'rhs'], 'each expression evaluates once in neutral order');
 is_deeply($document, {items => ['value']}, 'ordered lowering commits after all expression evaluation');
 is_deeply($result, {items => ['value']}, 'ordered lowering returns the updated detached root');

 @events = ();
 untie $first;
 untie $second;
 untie $rhs;
 tie $first, 'LinkedSpec::WriteVivificationOrderScalar', \@events, 'segment:0', 'items', 1;
 tie $second, 'LinkedSpec::WriteVivificationOrderScalar', \@events, 'segment:1', 0, 0;
 tie $rhs, 'LinkedSpec::WriteVivificationOrderScalar', \@events, 'rhs', 'value', 0;
 $document = {};
 %__ls_binding_presence = (document => 1);
 my $ok = eval $lowered;
 like($@, qr/^segment:0 failed/, 'the original segment evaluation failure propagates');
 is_deeply(\@events, ['segment:0'], 'a failed segment stops later segments and RHS');
 is_deeply($document, {}, 'expression failure does not enter structural mutation');
};

subtest 'same-binding expression effects compose and survive a later structural failure' => sub {
 my $document = {old => 1};
 my %__ls_binding_presence = (document => 1);
 my $rhs_composition = LinkedSpec::call_spec_handler_subst(
  'Top',
  q{document["value"] = set(document, { "audit" : [] }).count_keys()},
 );
 my $rhs_result = eval $rhs_composition;
 is($@, '', 'same-binding RHS composition completes');
 is_deeply($document, {audit => [], value => 1}, 'outer write snapshots the RHS post-assignment binding');
 is_deeply($rhs_result, {audit => [], value => 1}, 'same-binding RHS composition returns the detached updated root');

 $document = undef;
 %__ls_binding_presence = ();
 my $segment_composition = LinkedSpec::call_spec_handler_subst(
  'Top',
  q{document[cat(set(document, { "seed" : 1 }).count_keys(), "value")] = "done"},
 );
 my $segment_result = eval $segment_composition;
 is($@, '', 'same-binding segment composition completes');
 is_deeply($document, {seed => 1, '1value' => 'done'}, 'outer write snapshots the segment post-assignment binding');
 is_deeply($segment_result, $document, 'same-binding segment composition returns the detached updated root');

 $document = [];
 %__ls_binding_presence = (document => 1);
 my $gap_after_rhs = LinkedSpec::call_spec_handler_subst(
  'Top',
  q{document[2] = set(document, ["rhs"]).count()},
 );
 my $gap_ok = eval {
  eval $gap_after_rhs;
  die $@ if $@;
  1;
 };
 my $gap_error = $@;
 ok(!$gap_ok, 'outer array gap still fails after the completed RHS side effect');
 ok(LinkedSpec::BindingRuntime::is_nested_write_error($gap_error), 'post-RHS gap retains the typed structural diagnostic');
 is($gap_error->{code}, 'nested_write_array_gap', 'post-RHS failure uses the array-gap code');
 is_deeply($document, ['rhs'], 'completed RHS binding effect survives the failed outer structural write');
};

subtest 'live Perl keeps an explicit null binding present through the rule-owned presence seam' => sub {
 for my $assignment ('document = undef', 'set(document, undef)') {
  my $spec = <<"SPEC";
Top::
 /x/ -> Done {
   $assignment
   document["key"] = "bad"
   return(document)
 }

Done::
 /[a-z]+/
SPEC
  my %ctx;
  my $parser = LinkedSpec::Get(\$spec, runtime_ctx_ref => \%ctx);
  ok(ref($parser) eq 'CODE', "$assignment bound-null live fixture compiles");
  if (ref($parser) eq 'CODE') {
   my $null_input = 'xhello';
   my $null_result = $parser->(\$null_input);
   ok(!defined($null_result), "$assignment bound-null nested write fails the live rule");
   my $error = $ctx{last_error}{detail};
   ok(LinkedSpec::BindingRuntime::is_nested_write_error($error), "$assignment retains the typed runtime diagnostic");
   is($error->{code}, 'nested_write_kind_conflict', "$assignment bound-null failure has the neutral code");
   is($error->{actual_kind}, 'null', "$assignment remains present null rather than absent");
   is_deeply(
    $error->{source_span},
    {
     source_id => 'action:Top',
     start => 9,
     end => 14,
     unit => 'unicode_scalar',
     provenance => 'authored',
    },
    "$assignment carries the exact authored segment span through live lowering",
   );
  }
 }
};

subtest 'user-function presence state is invocation-local and parameters are already bound' => sub {
 my $build_spec = <<'SPEC';
fn build() {
 local_document["x"] = "y"
 return(local_document)
}
Top::
 /x/ -> Done { return(array(build(), build())) }

Done::
 /[a-z]+/
SPEC
 my $build_parser = LinkedSpec::Get(\$build_spec);
 ok(ref($build_parser) eq 'CODE', 'repeated local-root function fixture compiles');
 if (ref($build_parser) eq 'CODE') {
  my $build_input = 'xhello';
  is_deeply(
   $build_parser->(\$build_input),
   [{x => 'y'}, {x => 'y'}],
   'each zero-argument function call receives a fresh absent root and returns its own vivified tree',
  );
 }

 my $null_spec = <<'SPEC';
fn reject_bound_null(seed) {
 seed["x"] = "bad"
 return(seed)
}
Top::
 /x/ -> Done {
   return(reject_bound_null(undef))
 }

Done::
 /[a-z]+/
SPEC
 my %ctx;
 my $parser = LinkedSpec::Get(\$null_spec, runtime_ctx_ref => \%ctx);
 ok(ref($parser) eq 'CODE', 'bound-null parameter fixture compiles');
 if (ref($parser) eq 'CODE') {
  my $input = 'xhello';
  my $result = $parser->(\$input);
  ok(!defined($result), 'bound-null function parameter rejects the nested write');
  my $error = $ctx{last_error}{detail};
  ok(LinkedSpec::BindingRuntime::is_nested_write_error($error), 'function failure retains the typed diagnostic');
  is($error->{binding}, 'seed', 'function failure retains the parameter binding identity');
  is($error->{actual_kind}, 'null', 'an undef argument is a present null parameter');
 }
};

done_testing;
