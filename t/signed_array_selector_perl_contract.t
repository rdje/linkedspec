use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use B ();
use File::Spec ();
use JSON::PP ();
use Scalar::Util qw(refaddr reftype);
use Test::More;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::BindingRuntime ();
use LinkedSpec::CodeblockRuntime ();

binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';
my $json = JSON::PP->new->utf8->canonical->allow_nonref;
my $root = File::Spec->catdir($Bin, '..');

sub load_json {
    my ($path) = @_;
    open my $fh, '<:raw', $path or die "Read $path: $!";
    local $/;
    return $json->decode(<$fh>);
}

sub clone_value { return $json->decode($json->encode($_[0])) }
sub parse_expr { return LinkedSpec::ActionIR::AST::parse_action_expr($_[0]) }
sub numeric_flags {
    my ($value) = @_;
    return undef unless defined($value) && !ref($value);
    my $flags = B::svref_2object(\$value)->FLAGS;
    return {integer_flag => ($flags & B::SVp_IOK()) ? 1 : 0,
        float_flag => ($flags & B::SVp_NOK()) ? 1 : 0,
        string_flag => ($flags & B::SVp_POK()) ? 1 : 0};
}

my $contract = load_json(File::Spec->catfile($root, 'capability_conformance', 'signed_array_selector_contract.json'));
is($contract->{contract_id}, 'linkedspec-signed-array-selector-v1', 'loads the separate signed target authority');

subtest 'authored signed sources retain independent Unicode-scalar segment spans' => sub {
    for my $case (@{$contract->{write_cases}}) {
        my $node = parse_expr($case->{source});
        is($node->{kind}, 'assign_nested_access', "$case->{id}: typed write node");
        my $cursor = length($case->{binding});
        for my $index (0 .. $#{$case->{segments}}) {
            my $source = $case->{segments}[$index]{source};
            my $start = index($case->{source}, $source, $cursor);
            die "Missing segment in $case->{id}" if $start < 0;
            is_deeply($node->{segments}[$index]{source_span},
                {start => $start, end => $start + length($source)},
                "$case->{id}: authored segment $index span");
            $cursor = $start + length($source);
        }
    }
};

subtest 'frozen read targets are noncreating through the shared path reader' => sub {
    for my $case (@{$contract->{read_cases}}) {
        my $initial = $case->{initial_binding};
        my $tree = $initial->{present} ? clone_value($initial->{value}) : undef;
        my $before = clone_value($tree);
        my $keys = [map { clone_value($_->{value}) } @{$case->{segments}}];
        my $value = LinkedSpec::CodeblockRuntime::read_path($tree, $keys);
        is_deeply($value, $case->{expected_result}, "$case->{id}: selected value");
        is_deeply($tree, $before, "$case->{id}: source remains unchanged");
    }
};

subtest 'arithmetic targets distinguish existing positions from dense positive append' => sub {
    for my $case (@{$contract->{arithmetic_cases}}) {
        my $length = $case->{length};
        my $tree = [map { 100 + $_ } 0 .. $length - 1];
        my $before = clone_value($tree);
        my $value = LinkedSpec::CodeblockRuntime::read_path($tree, [$case->{index}]);
        my $expected = $case->{expected}{readable}
            ? $before->[$case->{expected}{resolved_index}] : undef;
        is($value, $expected, "$case->{id}: length-plus-index read");
        my ($updated, $result, $error);
        eval {
            ($updated, $result) = LinkedSpec::BindingRuntime::nested_write($tree, 1, 'tree',
                [{value => $case->{index}, kind_hint => 'integer', source_span => {
                    source_id => 'arithmetic:' . $case->{id}, start => 0, end => 1,
                    unit => 'unicode_scalar', provenance => 'authored'}}], 999);
            1;
        } or $error = $@;
        if ($case->{expected}{writable}) {
            ok(!defined($error), "$case->{id}: legal write");
            my $target = clone_value($before);
            $target->[$case->{expected}{resolved_index}] = 999;
            is_deeply($updated, $target, "$case->{id}: exact committed position");
            is_deeply($result, $target, "$case->{id}: returned root");
        } else {
            ok(LinkedSpec::BindingRuntime::is_nested_write_error($error), "$case->{id}: typed boundary failure");
        }
        is_deeply($tree, $before, "$case->{id}: input never mutated");
    }
};

subtest 'all signed write fixtures execute actual deferred callbacks and resolved guards' => sub {
    for my $case (@{$contract->{write_cases}}) {
        subtest $case->{id} => sub {
            my $initial = $case->{initial_binding};
            my $tree = $initial->{present} ? clone_value($initial->{value}) : undef;
            my $present = $initial->{present} ? 1 : 0;
            my (@effects, %functions, $failure);
            my @operands = (@{$case->{segments}}, $case->{rhs});
            my @segment_names = map { 'signed_segment_' . $_ } 0 .. $#{$case->{segments}};
            for my $index (0 .. $#operands) {
                my $operand = $operands[$index];
                my $last = $index == $#operands;
                my $name = $last ? 'signed_rhs' : $segment_names[$index];
                my $label = $last ? 'rhs' : "segment:$index";
                my $exception = exists($operand->{evaluation_error})
                    ? bless(clone_value($operand->{evaluation_error}), 'SignedArrayFixtureError') : undef;
                $failure = $exception if $exception;
                $functions{$name} = {
                    signature => {positional_params => [], min_arity => 0, max_arity => 0},
                    call => sub {
                        push @effects, $label;
                        die $exception if $exception;
                        if (exists $operand->{same_binding_after}) {
                            $tree = clone_value($operand->{same_binding_after});
                            $present = 1;
                        }
                        return clone_value($operand->{value});
                    },
                };
            }
            # Project observed operands to registered zero-argument calls. The
            # real evaluator owns their order, failure propagation and snapshot.
            # Original literal/variable syntax is exercised by the public grid.
            my $operation = $case->{binding}
                . join('', map { '[' . $_ . '()]' } @segment_names) . ' = signed_rhs()';
            my $record = parse_expr('{|| ' . $operation . ' }');
            my $record_before = $json->encode($record);
            my $invoke = sub {
                return LinkedSpec::CodeblockRuntime::invoke($record, [], {tree => \$tree},
                    $case->{id}, undef, {registered_functions => \%functions,
                        action_source_id => 'contract:' . $case->{id}}, {tree => \$present});
            };
            my ($result, $error, $outer);
            eval {
                if (my $guard = $case->{guard}) {
                    $outer = clone_value($tree);
                    my $slot = $guard->{active_identity} eq $guard->{target_identity} ? \$tree : \$outer;
                    LinkedSpec::BindingRuntime::map_leaves_mutation($slot, 1, 'tree',
                        {source_id => 'outer:' . $case->{id}, start => 0, end => 4,
                            unit => 'unicode_scalar', provenance => 'authored'},
                        sub { my ($leaf) = @_; $result = $invoke->(); return $leaf });
                } else {
                    $result = $invoke->();
                }
                1;
            } or $error = $@;
            my $expected_error = clone_value($case->{expected}{error});
            if ($expected_error) {
                if (my $span = $expected_error->{source_span}) {
                    my $start;
                    my $length;
                    if ($expected_error->{code} eq 'receiver_mutation_reentrant') {
                        ($start, $length) = (4, length($case->{binding}));
                    } else {
                        my $name = $segment_names[$expected_error->{segment_index}] . '()';
                        ($start, $length) = (4 + index($operation, $name), length($name));
                    }
                    $span->{start} = $start;
                    $span->{end} = $start + $length;
                }
                ok(defined($error), 'failure is observable');
                is_deeply((reftype($error) // '') eq 'HASH' ? {%$error} : $error,
                    $expected_error, 'complete projected diagnostic or original expression error');
                is(refaddr($error), refaddr($failure), 'expression error keeps identity')
                    if $failure && $expected_error->{code} eq 'fixture_evaluation_failed';
            } else {
                ok(!defined($error), 'write succeeds');
                diag($error) if defined $error;
                is_deeply($result, $case->{expected}{result}, 'detached result values');
                isnt(refaddr($result), refaddr($tree), 'result and binding are separate roots')
                    if ref($result) && ref($tree);
            }
            my $state = $case->{expected}{binding};
            is_deeply($tree, $state->{present} ? $state->{value} : undef, 'exact post-expression/commit state');
            is($present ? 1 : 0, $state->{present} ? 1 : 0, 'logical binding presence');
            is_deeply(\@effects, $case->{expected}{effects}, 'actual ordered operand effects');
            is($json->encode($record), $record_before, 'callable data remains unchanged');
            is_deeply($outer, $initial->{value}, 'same-spelling separate receiver stays unchanged')
                if $case->{guard} && $case->{guard}{active_identity} ne $case->{guard}{target_identity};
        };
    }
};

subtest 'direct write detaches initial input, aggregate RHS, binding and result' => sub {
    my $probe = $contract->{detachment_probe};
    my ($case) = grep { $_->{id} eq $probe->{case_id} } @{$contract->{write_cases}};
    my $initial = clone_value($case->{initial_binding}{value});
    my $rhs = clone_value($case->{rhs}{value});
    my $node = parse_expr($case->{source});
    my @segments;
    for my $index (0 .. $#{$case->{segments}}) {
        push @segments, {value => clone_value($case->{segments}[$index]{value}),
            kind_hint => $case->{segments}[$index]{kind},
            source_span => {source_id => 'contract:' . $case->{id},
                %{$node->{segments}[$index]{source_span}}, unit => 'unicode_scalar', provenance => 'authored'}};
    }
    my ($binding, $result, $error);
    eval { ($binding, $result) = LinkedSpec::BindingRuntime::nested_write($initial, 1, 'tree', \@segments, $rhs); 1 }
        or $error = $@;
    ok(!defined($error), 'detachment setup succeeds');
    return if defined $error;
    my %targets = (initial => $initial, rhs => $rhs, binding => $binding, result => $result);
    for my $mutation (@{$probe->{mutations}}) {
        my $cursor = $targets{$mutation->{target}};
        my @path = @{$mutation->{path}};
        my $last = pop @path;
        for my $key (@path) {
            $cursor = ref($cursor) eq 'ARRAY' ? $cursor->[$key] : $cursor->{$key};
        }
        if (ref($cursor) eq 'ARRAY') {
            $cursor->[$last] = clone_value($mutation->{value});
        } else {
            $cursor->{$last} = clone_value($mutation->{value});
        }
    }
    is_deeply(\%targets, $probe->{expected}, 'all four independent host mutations stay isolated');
};

subtest 'authored public programs agree through native and independently emitted execution' => sub {
    my $plan = load_json(File::Spec->catfile($root, 'tests', 'numeric-codeblocks', 'signed-array-selectors.json'));
    my $serial = 0;
    for my $case (@{$plan->{cases}}) {
        subtest $case->{id} => sub {
            my $source = $case->{source};
            my (%context, $native, $diagnostic, $native_exception);
            {
                open my $capture, '>', \$diagnostic or die "Capture native output: $!";
                local *STDOUT = $capture;
                eval {
                    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
                    die 'No native parser' unless ref($parser) eq 'CODE';
                    my $input = $case->{input} // 'x';
                    $native = $parser->(\$input);
                    1;
                } or $native_exception = $@;
            }
            ok(!defined($native_exception), 'native compilation/invocation boundary completes');
            my $emitted = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'signed-array-perl.spec') };
            ok(defined($emitted) && length($emitted), 'independent source emits');
            my $package = 'SignedArrayPublic' . $serial++;
            my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
            ok($loaded, 'independent source loads');
            return unless $loaded;
            my ($generated, $exception);
            eval { no strict 'refs'; my $input = $case->{input} // 'x';
                $generated = &{$package . '::Execute'}(\$input); 1 } or $exception = $@;
            if (my $flags = $case->{expected_scalar_flags}) {
                is_deeply(numeric_flags($native), $flags, 'native scalar flags before serialization');
                is_deeply(numeric_flags($generated), $flags, 'emitted scalar flags before serialization');
            }
            if (my $expected = $case->{error}) {
                my $native_error = $context{last_error}{detail};
                is((reftype($native_error) // ''), 'HASH', 'native typed runtime diagnostic');
                is(ref($exception), 'HASH', 'emitted execution uses its public error envelope');
                my $generated_error = ref($exception) eq 'HASH' ? $exception->{detail} : undef;
                for my $field (sort keys %$expected) {
                    is_deeply((reftype($native_error) // '') eq 'HASH' ? $native_error->{$field} : undef,
                        $expected->{$field}, "native $field");
                    is_deeply((reftype($generated_error) // '') eq 'HASH' ? $generated_error->{$field} : undef,
                        $expected->{$field}, "emitted $field");
                }
            } else {
                ok(!defined($context{last_error}), 'native execution has clear error state');
                ok(!defined($exception), 'emitted execution has clear error state');
                is($json->encode($native), $json->encode($case->{expected}), 'native values and JSON kinds');
                is($json->encode($generated), $json->encode($case->{expected}), 'emitted values and JSON kinds');
            }
        };
    }
};

done_testing;
