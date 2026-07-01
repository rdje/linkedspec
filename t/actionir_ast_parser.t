use strict;
use warnings;
use Test::More;

use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();

sub parse_expr {
    my ($expr) = @_;
    return LinkedSpec::ActionIR::AST::parse_action_expr($expr);
}

sub parse_block {
    my ($code) = @_;
    return LinkedSpec::ActionIR::AST::parse_action_block($code);
}

subtest 'calls literals variables and value-drop statements' => sub {
    my $block = parse_block(qq{set(name,"a")\nuser_fn().trim().split("-")});

    is($block->{kind}, 'action_block', 'parse_action_block returns an action block');
    is(scalar(@{$block->{statements}}), 2, 'AST parser refines newline-separated chain statements');
    is($block->{statements}[0]{expr}{kind}, 'call', 'method statement parses as a call');
    is($block->{statements}[0]{expr}{name}, 'assign', 'set alias normalizes through MethodExpr');
    is($block->{statements}[0]{expr}{args}[0]{kind}, 'variable', 'bare call argument parses as a variable');
    is($block->{statements}[0]{expr}{args}[1]{kind}, 'string', 'quoted call argument parses as a string');
    is($block->{statements}[0]{expr}{args}[1]{value}, 'a', 'string payload is captured without delimiters');
    ok($block->{statements}[1]{drops_value}, 'standalone expression statements silently drop their value');

    my $chain = $block->{statements}[1]{expr};
    is($chain->{kind}, 'fluent_chain', 'standalone function-call receiver chain parses as fluent_chain');
    is($chain->{receiver}{kind}, 'call', 'function call can be a receiver expression');
    is($chain->{receiver}{name}, 'user_fn', 'receiver call name is preserved');
    is_deeply([map { $_->{method} } @{$chain->{calls}}], ['trim', 'split'], 'receiver-chain calls are ordered');
    is($chain->{calls}[1]{args}[0]{value}, '-', 'receiver-chain call arguments are parsed as expressions');
};

subtest 'primitive literals' => sub {
    is(parse_expr('42')->{kind}, 'number', 'integer literal parses');
    is(parse_expr('-3.5')->{value}, -3.5, 'negative decimal literal parses');
    is(parse_expr('true')->{kind}, 'boolean', 'true parses as boolean');
    is(parse_expr('false')->{value}, 0, 'false carries boolean false');
    is(parse_expr('undef')->{kind}, 'undef', 'undef parses as undef');
    is(parse_expr('/a\\sb/i')->{kind}, 'regex', 'regex literal parses');
    is(parse_expr('/a\\sb/i')->{flags}, 'i', 'regex flags are captured');
};

subtest 'direct access and indexed variables' => sub {
    my $indexed = parse_expr('items[0]');
    is($indexed->{kind}, 'indexed_var', 'single numeric segment parses as indexed_var');
    is($indexed->{name}, 'items', 'indexed_var base name is captured');
    is($indexed->{index}{kind}, 'number', 'indexed_var index is an expression');

    my $nested = parse_expr('foo["a"][0][scalar(z)]');
    is($nested->{kind}, 'nested_access', 'mixed direct access parses as nested_access');
    is($nested->{base}, 'foo', 'nested_access base is captured');
    is_deeply([map { $_->{kind} } @{$nested->{segments}}], ['key', 'index', 'index'], 'segment kinds preserve key/index roles');
    is($nested->{segments}[0]{value}, 'a', 'quoted segment becomes a key');
    is($nested->{segments}[2]{expr}{kind}, 'call', 'helper segment payload parses as a call expression');
    is($nested->{segments}[2]{expr}{name}, 'scalar', 'helper segment call name is captured');
};

subtest 'shape literals and expression-valued blocks' => sub {
    my $array = parse_expr('[value, true, []]');
    is($array->{kind}, 'array_literal', 'array shape literal parses');
    is_deeply([map { $_->{kind} } @{$array->{items}}], ['variable', 'boolean', 'array_literal'], 'array literal items are typed expressions');

    my $hash = parse_expr('{ key => value, "fixed" => [value] }');
    is($hash->{kind}, 'hash_literal', 'hash shape literal parses');
    is(scalar(@{$hash->{entries}}), 2, 'hash literal entries are captured');
    is($hash->{entries}[0]{key}{kind}, 'variable', 'bare hash key is an expression');
    is($hash->{entries}[1]{key}{kind}, 'string', 'quoted hash key is a string expression');
    is($hash->{entries}[1]{value}{kind}, 'array_literal', 'hash value can be a nested shape literal');

    my $block = parse_expr('{ set(x,"a"); x }');
    is($block->{kind}, 'block_value', 'non-empty non-fat-arrow braces parse as a block value');
    is(scalar(@{$block->{block}{statements}}), 2, 'block value owns nested statements');
    is($block->{block}{statements}[0]{expr}{name}, 'assign', 'block statement calls use the same method parser seam');
    is($block->{block}{statements}[1]{expr}{kind}, 'variable', 'block final expression parses as a variable');
};

subtest 'assignment and mutation statement nodes' => sub {
    my $scalar = parse_expr('name = [value]');
    is($scalar->{kind}, 'assign_scalar', 'bare assignment parses as assign_scalar');
    is($scalar->{value}{kind}, 'array_literal', 'assign_scalar RHS is a parsed expression');

    my $append = parse_expr('items += value');
    is($append->{kind}, 'assign_array_append', 'array append operator parses as assign_array_append');
    is($append->{name}, 'items', 'array append target name is captured');
    is($append->{value}{kind}, 'variable', 'array append RHS is parsed');

    my $hash = parse_expr('meta[key] = { key => value }');
    is($hash->{kind}, 'assign_hash_index', 'hash-index assignment parses as assign_hash_index');
    is($hash->{key}{kind}, 'variable', 'hash assignment key is parsed as expression');
    is($hash->{value}{kind}, 'hash_literal', 'hash assignment RHS is parsed as hash literal');
};

subtest 'assignment and mutation statement lowering consumes AST nodes' => sub {
    my $parse_calls = 0;
    my $orig_parse_action_expr = \&LinkedSpec::ActionIR::AST::parse_action_expr;
    my $var = sub {
        my ($name) = @_;
        return { kind => 'variable', name => $name, source => '__bad_var_'.$name.'__()' };
    };
    my $array = sub {
        my (@items) = @_;
        return { kind => 'array_literal', source => '__bad_array_source__()', items => \@items };
    };
    my $hash = sub {
        my (@entries) = @_;
        return { kind => 'hash_literal', source => '__bad_hash_source__()', entries => \@entries };
    };

    {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::AST::parse_action_expr = sub {
            my ($expr, @rest) = @_;
            ++$parse_calls;
            if ($expr eq 'name = [poison]') {
                return {
                    kind => 'assign_scalar',
                    source => '__bad_assign_scalar__()',
                    name => 'name',
                    value => $array->($var->('value')),
                };
            }
            if ($expr eq 'items += poison') {
                return {
                    kind => 'assign_array_append',
                    source => '__bad_assign_append__()',
                    name => 'items',
                    value => $var->('value'),
                };
            }
            if ($expr eq 'meta[poison_key] = { poison_key => poison_value }') {
                return {
                    kind => 'assign_hash_index',
                    source => '__bad_assign_hash__()',
                    name => 'meta',
                    key => $var->('key'),
                    value => $hash->({ key => $var->('key'), value => $var->('value') }),
                };
            }
            return $orig_parse_action_expr->($expr, @rest);
        };

        my $scalar = LinkedSpec::call_spec_handler_subst('Top', q{name = [poison]});
        is($scalar, '@name = ($value)', 'scalar assignment operator lowers RHS from AST fields');

        my $append = LinkedSpec::call_spec_handler_subst('Top', q{items += poison});
        is($append, 'push @items, $value', 'array append operator lowers RHS from AST fields');

        my $hash_assign = LinkedSpec::call_spec_handler_subst('Top', q{meta[poison_key] = { poison_key => poison_value }});
        is($hash_assign, '$meta{$key} = {$key => $value}', 'hash-index assignment lowers key/RHS from AST fields');

        my $all = join("\n", $scalar, $append, $hash_assign);
        unlike($all, qr/poison|__bad_/, 'assignment/mutation statement lowering does not reuse fake AST source or original poison text');
    }

    ok($parse_calls >= 3, 'assignment/mutation statements entered through the AST parser');
};

subtest 'statement helper-call lowering consumes AST call nodes' => sub {
    my $parse_calls = 0;
    my $orig_parse_action_expr = \&LinkedSpec::ActionIR::AST::parse_action_expr;
    my $var = sub {
        my ($name) = @_;
        return { kind => 'variable', name => $name, source => '__bad_var_'.$name.'__()' };
    };
    my $array = sub {
        my (@items) = @_;
        return { kind => 'array_literal', source => '__bad_array_source__()', items => \@items };
    };
    my $call = sub {
        my ($name, @args) = @_;
        return { kind => 'call', name => $name, source => '__bad_call_'.$name.'__()', args => \@args };
    };
    my $chain = sub {
        my ($receiver, @calls) = @_;
        return { kind => 'fluent_chain', source => '__bad_chain_source__()', receiver => $receiver, calls => \@calls };
    };
    my $fluent_call = sub {
        my ($method, @args) = @_;
        return { method => $method, source => '__bad_fluent_'.$method.'__()', args => \@args };
    };

    {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::AST::parse_action_expr = sub {
            my ($expr, @rest) = @_;
            ++$parse_calls;
            if ($expr eq 'set(name, [poison])') {
                return $call->('assign', $var->('name'), $array->($var->('value')));
            }
            if ($expr eq 'set_key(hash(meta), poison_key, poison_value)') {
                return $call->('set_key', $call->('hash', $var->('meta')), $var->('key'), $var->('value'));
            }
            if ($expr eq 'push_value(items, poison)') {
                return $call->('push_value', $var->('items'), $var->('value'));
            }
            if ($expr eq 'push(array(items), poison)') {
                return $call->('push', $call->('array', $var->('items')), $var->('value'));
            }
            if ($expr eq 'push_nonempty(array(items), poison)') {
                return $call->('push_nonempty', $call->('array', $var->('items')), $var->('value'));
            }
            if ($expr eq 'return([poison])') {
                return $call->('return', $array->($var->('value')));
            }
            if ($expr eq 'return_undef(poison)') {
                return $call->('return_undef');
            }
            if ($expr eq 'items.push_back(poison)') {
                return $chain->($var->('items'), $fluent_call->('push_back', $var->('value')));
            }
            return $orig_parse_action_expr->($expr, @rest);
        };

        my $assign = LinkedSpec::call_spec_handler_subst('Top', q{set(name, [poison])});
        is($assign, '@name = ($value)', 'set/assign statement lowers from AST call args');

        my $set_key = LinkedSpec::call_spec_handler_subst('Top', q{set_key(hash(meta), poison_key, poison_value)});
        is($set_key, '$meta{$key} = $value', 'set_key statement lowers target/key/value from AST call args');

        my $push_value = LinkedSpec::call_spec_handler_subst('Top', q{push_value(items, poison)});
        is($push_value, 'push @items, value', 'push_value statement lowers from AST call args');

        my $push = LinkedSpec::call_spec_handler_subst('Top', q{push(array(items), poison)});
        is($push, 'push @items, value', 'push statement lowers explicit append from AST call args');

        my $push_nonempty = LinkedSpec::call_spec_handler_subst('Top', q{push_nonempty(array(items), poison)});
        like($push_nonempty, qr/push \@items, \$__ls_push_nonempty/, 'push_nonempty statement keeps append guard');
        like($push_nonempty, qr/my \$__ls_push_nonempty = value\b/, 'push_nonempty value slot lowers from AST call args');

        my $return = LinkedSpec::call_spec_handler_subst('Top', q{return([poison])});
        is($return, 'return [$value]', 'return statement lowers payload from AST call args');

        my $return_undef = LinkedSpec::call_spec_handler_subst('Top', q{return_undef(poison)});
        is($return_undef, 'return undef', 'return_undef statement lowers from AST call arity');

        my $push_back = LinkedSpec::call_spec_handler_subst('Top', q{items.push_back(poison)});
        is($push_back, 'push @items, $value', 'array end-mutation statement lowers from AST receiver/call fields');

        my $all = join("\n", $assign, $set_key, $push_value, $push, $push_nonempty, $return, $return_undef, $push_back);
        unlike($all, qr/poison|__bad_/, 'statement helper-call lowering does not reuse fake AST source or original poison text');
    }

    my $bad_push_nonempty = LinkedSpec::call_spec_handler_subst('Top', q{push_nonempty(items)});
    unlike($bad_push_nonempty, qr/\bpush_nonempty\s*\(/, 'unsupported covered statement helper no longer leaks as a host call');
    like($bad_push_nonempty, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:push_nonempty/, 'unsupported covered statement helper leaves diagnostic sentinel');

    ok($parse_calls >= 8, 'statement helper calls entered through the AST parser');
};

subtest 'receiver chains accept all expression receivers' => sub {
    my $call_receiver = parse_expr('builder().trim().split("-").count()');
    is($call_receiver->{kind}, 'fluent_chain', 'function-call receiver chain parses');
    is($call_receiver->{receiver}{kind}, 'call', 'function call receiver is typed');
    is_deeply([map { $_->{method} } @{$call_receiver->{calls}}], ['trim', 'split', 'count'], 'call receiver chain methods are ordered');

    my $number_receiver = parse_expr('3.5.floor().add(1)');
    is($number_receiver->{receiver}{kind}, 'number', 'numeric literal receiver parses without splitting the decimal point');
    is_deeply([map { $_->{method} } @{$number_receiver->{calls}}], ['floor', 'add'], 'number receiver chain methods are ordered');

    my $block_receiver = parse_expr('{ [3, 1, 2] }.sorted().join_values(",")');
    is($block_receiver->{receiver}{kind}, 'block_value', 'block value can be a receiver expression');
    is_deeply([map { $_->{method} } @{$block_receiver->{calls}}], ['sorted', 'join_values'], 'block receiver chain methods are ordered');
};

subtest 'non-call value lowering consumes AST nodes' => sub {
    my $parse_calls = 0;
    my $orig_parse_action_expr = \&LinkedSpec::ActionIR::AST::parse_action_expr;
    {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::AST::parse_action_expr = sub {
            ++$parse_calls;
            return $orig_parse_action_expr->(@_);
        };

        my $shape = LinkedSpec::call_spec_handler_subst(
            'Top',
            q{return([value, true, foo["a"][scalar(i)], { key => value }])},
        );
        is(
            $shape,
            q!return [$value, do { require JSON::PP; JSON::PP::true }, $foo->{"a"}->[$i], {$key => $value}]!,
            'AST value lowering preserves shape, scalar-read, literal, and direct-access output',
        );

        my $block = LinkedSpec::call_spec_handler_subst('Top', q{return({ set(x,"a"); x })});
        is(
            $block,
            q!return do { $x = "a"; $x }!,
            'AST value lowering preserves block-value output',
        );
    }

    ok($parse_calls >= 2, 'value lowering invoked the AST parser for non-call value expressions');
};

subtest 'value-only helper-call lowering consumes AST call nodes' => sub {
    my $parse_calls = 0;
    my $orig_parse_action_expr = \&LinkedSpec::ActionIR::AST::parse_action_expr;
    {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::AST::parse_action_expr = sub {
            my ($expr, @rest) = @_;
            ++$parse_calls;
            if ($expr eq 'trim(lowercase(value))') {
                return {
                    kind => 'call',
                    name => 'trim',
                    source => '__bad_outer_host_call__()',
                    args => [
                        {
                            kind => 'call',
                            name => 'lowercase',
                            source => '__bad_inner_host_call__()',
                            args => [
                                { kind => 'variable', name => 'value', source => 'value' },
                            ],
                        },
                    ],
                };
            }
            if ($expr eq 'num_add(scalar(n),num_mul(2,3))') {
                return {
                    kind => 'call',
                    name => 'num_add',
                    source => '__bad_num_outer_host_call__()',
                    args => [
                        {
                            kind => 'call',
                            name => 'scalar',
                            source => 'scalar(n)',
                            args => [
                                { kind => 'variable', name => 'n', source => 'n' },
                            ],
                        },
                        {
                            kind => 'call',
                            name => 'num_mul',
                            source => '__bad_num_inner_host_call__()',
                            args => [
                                { kind => 'number', value => 2, source => '2' },
                                { kind => 'number', value => 3, source => '3' },
                            ],
                        },
                    ],
                };
            }
            return $orig_parse_action_expr->($expr, @rest);
        };

        my $string_call = LinkedSpec::call_spec_handler_subst('Top', q{return(trim(lowercase(value)))});
        like($string_call, qr/\$__ls_trim/, 'AST helper-call lowering preserves the outer string helper output');
        like($string_call, qr/\$__ls_lower/, 'AST helper-call lowering recursively lowers nested value-only calls');
        unlike($string_call, qr/__bad_(?:outer|inner)_host_call__/, 'AST helper-call lowering does not reuse fake source text for supported calls');

        my $numeric_call = LinkedSpec::call_spec_handler_subst('Top', q{return(num_add(scalar(n),num_mul(2,3)))});
        like($numeric_call, qr/\$__ls_num_add_sum/, 'AST helper-call lowering preserves the outer numeric helper output');
        like($numeric_call, qr/\$__ls_num_mul_product/, 'AST helper-call lowering recursively lowers nested numeric helper calls');
        unlike($numeric_call, qr/__bad_num_(?:outer|inner)_host_call__/, 'AST helper-call lowering preserves compatibility only for unsupported argument calls');
    }

    ok($parse_calls >= 2, 'value-only helper calls entered through the AST parser');
};

subtest 'aggregate helper-call lowering consumes AST call nodes' => sub {
    my $parse_calls = 0;
    my $orig_parse_action_expr = \&LinkedSpec::ActionIR::AST::parse_action_expr;
    my $var = sub {
        my ($name) = @_;
        return { kind => 'variable', name => $name, source => '__bad_var_'.$name.'__()' };
    };
    my $str = sub {
        my ($value) = @_;
        return { kind => 'string', value => $value, quote => '"', source => '__bad_string_'.$value.'__()' };
    };
    my $num = sub {
        my ($value) = @_;
        return { kind => 'number', value => $value, source => '__bad_number_'.$value.'__()' };
    };
    my $call = sub {
        my ($name, $source, @args) = @_;
        return { kind => 'call', name => $name, source => $source, args => \@args };
    };

    {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::AST::parse_action_expr = sub {
            my ($expr, @rest) = @_;
            ++$parse_calls;
            if ($expr eq 'array_copy(array(items))') {
                return $call->(
                    'array_copy',
                    '__bad_array_copy_host_call__()',
                    $call->('array', '__bad_array_wrapper_host_call__()', $var->('items')),
                );
            }
            if ($expr eq 'hash_copy(hash(meta))') {
                return $call->(
                    'hash_copy',
                    '__bad_hash_copy_host_call__()',
                    $call->('hash', '__bad_hash_wrapper_host_call__()', $var->('meta')),
                );
            }
            if ($expr eq 'copy(hash(meta))') {
                return $call->(
                    'copy',
                    '__bad_copy_host_call__()',
                    $call->('hash', '__bad_copy_hash_wrapper_host_call__()', $var->('meta')),
                );
            }
            if ($expr eq 'count(array("items"))') {
                return $call->(
                    'count',
                    '__bad_count_host_call__()',
                    $call->('array', '__bad_quoted_array_wrapper_host_call__()', $str->('items')),
                );
            }
            if ($expr eq 'num_sum(array(items))') {
                return $call->(
                    'num_sum',
                    '__bad_num_sum_host_call__()',
                    $call->('array', '__bad_num_sum_array_wrapper_host_call__()', $var->('items')),
                );
            }
            if ($expr eq 'merge_hash(hash(base),set_key(hash(overlay),"stage",concat("a","b")))') {
                return $call->(
                    'merge_hash',
                    '__bad_merge_hash_host_call__()',
                    $call->('hash', '__bad_base_hash_wrapper_host_call__()', $var->('base')),
                    $call->(
                        'set_key',
                        '__bad_set_key_host_call__()',
                        $call->('hash', '__bad_overlay_hash_wrapper_host_call__()', $var->('overlay')),
                        $str->('stage'),
                        $call->('concat', '__bad_concat_host_call__()', $str->('a'), $str->('b')),
                    ),
                );
            }
            if ($expr eq 'has_key(pick_keys(hash(meta),"a"),"a")') {
                return $call->(
                    'has_key',
                    '__bad_has_key_host_call__()',
                    $call->(
                        'pick_keys',
                        '__bad_pick_keys_host_call__()',
                        $call->('hash', '__bad_pick_hash_wrapper_host_call__()', $var->('meta')),
                        $str->('a'),
                    ),
                    $str->('a'),
                );
            }
            if ($expr eq 'take(array(items),1)') {
                return $call->(
                    'take',
                    '__bad_take_host_call__()',
                    $call->('array', '__bad_take_array_wrapper_host_call__()', $var->('items')),
                    $num->(1),
                );
            }
            return $orig_parse_action_expr->($expr, @rest);
        };

        my $array_copy = LinkedSpec::call_spec_handler_subst('Top', q{return(array_copy(array(items)))});
        is($array_copy, q{return [@items]}, 'AST aggregate lowering preserves array_copy(array(items)) output');

        my $hash_copy = LinkedSpec::call_spec_handler_subst('Top', q{return(hash_copy(hash(meta)))});
        is($hash_copy, q{return {%meta}}, 'AST aggregate lowering preserves hash_copy(hash(meta)) output');

        my $copy_hash = LinkedSpec::call_spec_handler_subst('Top', q{return(copy(hash(meta)))});
        is($copy_hash, q{return {%meta}}, 'AST aggregate lowering preserves copy(hash(meta)) array/hash resolution');

        my $quoted_count = LinkedSpec::call_spec_handler_subst('Top', q{return(count(array("items")))});
        like($quoted_count, qr/\["items"\]/, 'AST aggregate lowering preserves quoted array wrapper literal payloads');
        unlike($quoted_count, qr/\@items\b/, 'AST aggregate lowering does not turn quoted wrapper payloads into array symbols');

        my $sum = LinkedSpec::call_spec_handler_subst('Top', q{return(num_sum(array(items)))});
        like($sum, qr/\$__ls_num_sum_total/, 'AST aggregate lowering preserves numeric reducer output');
        like($sum, qr/\@items\b/, 'AST aggregate lowering preserves array symbol slots for numeric reducers');

        my $take = LinkedSpec::call_spec_handler_subst('Top', q{return(take(array(items),1))});
        like($take, qr/\@items\b/, 'AST aggregate lowering preserves array collection symbol slots');
        like($take, qr/\$__ls_take_count = 1\b/, 'AST aggregate lowering preserves collection count value slots');

        my $merge = LinkedSpec::call_spec_handler_subst('Top', q{return(merge_hash(hash(base),set_key(hash(overlay),"stage",concat("a","b"))))});
        like($merge, qr/%base/, 'AST aggregate lowering preserves merge_hash hash source slots');
        like($merge, qr/\\%overlay/, 'AST aggregate lowering preserves nested set_key hash source slots');
        like($merge, qr/\@__ls_concat_parts/, 'AST aggregate lowering composes nested value-only helper slots');

        my $has_key = LinkedSpec::call_spec_handler_subst('Top', q{return(has_key(pick_keys(hash(meta),"a"),"a"))});
        like($has_key, qr/\$__ls_pick_source/, 'AST aggregate lowering preserves nested pick_keys hash helper output');
        like($has_key, qr/\$__ls_has_key/, 'AST aggregate lowering preserves has_key terminal output');

        my $all = join("\n", $array_copy, $hash_copy, $copy_hash, $quoted_count, $sum, $take, $merge, $has_key);
        unlike($all, qr/__bad_/, 'AST aggregate lowering does not reuse fake source text for supported calls');
    }

    ok($parse_calls >= 8, 'aggregate helper calls entered through the AST parser');
};

subtest 'covered helper-call diagnostics retire AST host-call leakage' => sub {
    my $bad_substr = LinkedSpec::call_spec_handler_subst('Top', q{return(substr("abc"))});
    unlike($bad_substr, qr/\breturn\s+substr\s*\(/, 'unsupported covered value helper no longer lowers to a host substr call');
    like($bad_substr, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:substr/, 'unsupported covered value helper leaves diagnostic sentinel');

    my $bad_count = LinkedSpec::call_spec_handler_subst('Top', q{return(count())});
    unlike($bad_count, qr/\breturn\s+count\s*\(/, 'unsupported covered aggregate helper no longer lowers to a host count call');
    like($bad_count, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:count/, 'unsupported covered aggregate helper leaves diagnostic sentinel');

    my $nested_bad = LinkedSpec::call_spec_handler_subst('Top', q{return(concat(substr("abc"),"x"))});
    unlike($nested_bad, qr/\@__ls_concat_parts = \(substr\s*\(/, 'nested unsupported covered helper no longer becomes a host-call concat operand');
    like($nested_bad, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:substr/, 'nested unsupported covered helper remains visible to diagnostics');

    my $spec = qq{Top::\n /x/ -> Done { return(substr("abc")) }\nDone::\n /y/\n};
    my $descriptor = eval { LinkedSpec::Get(\$spec, return_descriptor => 1) };
    ok(ref($descriptor) eq 'HASH', 'descriptor still builds with unsupported covered helper sentinel');
    my $meta = ref($descriptor) eq 'HASH' ? ($descriptor->{spec}{Top}{meta}{action_rewriter} || {}) : {};
    is($meta->{raw_perl_dependency_count} || 0, 0, 'unsupported covered helper is not reported as raw Perl fallback');
    is($meta->{unresolved_helper_count} || 0, 1, 'unsupported covered helper is reported as one unresolved helper');
    is_deeply($meta->{unresolved_helpers} || [], ['substr'], 'unsupported covered helper diagnostic names the helper');
    ok(!$meta->{language_agnostic_action_ir_ready}, 'unsupported covered helper blocks language-agnostic readiness through diagnostics');
    like(join("\n", @{$meta->{unresolved_helper_statements} || []}), qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:substr/, 'unresolved-helper statements carry the sentinel');
};

subtest 'fluent_chain value lowering consumes AST nodes' => sub {
    my $parse_calls = 0;
    my $orig_parse_action_expr = \&LinkedSpec::ActionIR::AST::parse_action_expr;
    my $var = sub {
        my ($name) = @_;
        return { kind => 'variable', name => $name, source => '__bad_var_'.$name.'__()' };
    };
    my $str = sub {
        my ($value) = @_;
        return { kind => 'string', value => $value, quote => '"', source => '__bad_string_'.$value.'__()' };
    };
    my $num = sub {
        my ($value) = @_;
        return { kind => 'number', value => $value, source => '__bad_number_'.$value.'__()' };
    };
    my $chain = sub {
        my ($receiver, @calls) = @_;
        return {
            kind => 'fluent_chain',
            source => '__bad_chain_source__()',
            receiver => $receiver,
            calls => \@calls,
        };
    };
    my $fluent_call = sub {
        my ($method, @args) = @_;
        return { method => $method, source => '__bad_call_'.$method.'__()', args => \@args };
    };

    {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::AST::parse_action_expr = sub {
            my ($expr, @rest) = @_;
            ++$parse_calls;
            if ($expr eq '3.5.floor().add(1)') {
                return $chain->(
                    $num->('3.5'),
                    $fluent_call->('floor'),
                    $fluent_call->('add', $num->(1)),
                );
            }
            if ($expr eq '" a-b ".trim().split("-").count()') {
                return $chain->(
                    $str->(' a-b '),
                    $fluent_call->('trim'),
                    $fluent_call->('split', $str->('-')),
                    $fluent_call->('count'),
                );
            }
            if ($expr eq '{ [3,1,2] }.sorted().join_values(",")') {
                return $chain->(
                    { kind => 'block_value', source => '{ [3,1,2] }' },
                    $fluent_call->('sorted'),
                    $fluent_call->('join_values', $str->(',')),
                );
            }
            if ($expr eq 'meta.set_key("c",3).sorted_keys().join_values(",")') {
                return $chain->(
                    $var->('meta'),
                    $fluent_call->('set_key', $str->('c'), $num->(3)),
                    $fluent_call->('sorted_keys'),
                    $fluent_call->('join_values', $str->(',')),
                );
            }
            if ($expr eq 'score.floor().gt(2).add(1)') {
                return $chain->(
                    $var->('score'),
                    $fluent_call->('floor'),
                    $fluent_call->('gt', $num->(2)),
                    $fluent_call->('add', $num->(1)),
                );
            }
            if ($expr eq '"abc".substr()') {
                return $chain->(
                    $str->('abc'),
                    $fluent_call->('substr'),
                );
            }
            return $orig_parse_action_expr->($expr, @rest);
        };

        my $numeric = LinkedSpec::call_spec_handler_subst('Top', q{return(3.5.floor().add(1))});
        like($numeric, qr/__ls_num_floor.*__ls_num_add/s, 'AST fluent_chain lowering preserves number helper composition');

        my $string_array = LinkedSpec::call_spec_handler_subst('Top', q{return(" a-b ".trim().split("-").count())});
        like($string_array, qr/__ls_trim.*__ls_split.*__ls_count/s, 'AST fluent_chain lowering bridges string chains into array terminals');

        my $block_array = LinkedSpec::call_spec_handler_subst('Top', q{return({ [3,1,2] }.sorted().join_values(","))});
        like($block_array, qr/__ls_sorted.*__ls_join_values/s, 'AST fluent_chain lowering preserves block-valued array receivers');

        my $hash_array = LinkedSpec::call_spec_handler_subst('Top', q{return(meta.set_key("c",3).sorted_keys().join_values(","))});
        like($hash_array, qr/__ls_set_key_source.*__ls_sorted_keys.*__ls_join_values/s, 'AST fluent_chain lowering preserves hash-to-array receiver chains');

        my $invalid_number_continuation = LinkedSpec::call_spec_handler_subst('Top', q{return(score.floor().gt(2).add(1))});
        is($invalid_number_continuation, q{return undef}, 'AST fluent_chain lowering preserves terminal number-chain continuation behavior');

        my $bad_substr = LinkedSpec::call_spec_handler_subst('Top', q{return("abc".substr())});
        unlike($bad_substr, qr/\breturn\s+substr\s*\(/, 'unsupported covered chain helper no longer lowers to a host substr call');
        like($bad_substr, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:substr/, 'unsupported covered chain helper leaves diagnostic sentinel');

        my $all = join("\n", $numeric, $string_array, $block_array, $hash_array, $invalid_number_continuation, $bad_substr);
        unlike($all, qr/__bad_/, 'AST fluent_chain lowering does not reuse fake chain, call, receiver, or argument source text');
    }

    ok($parse_calls >= 6, 'receiver-dot chains entered through the AST parser');
};

subtest 'return-payload lowering consumes AST nodes before raw fallback' => sub {
    my $parse_calls = 0;
    my $orig_parse_action_expr = \&LinkedSpec::ActionIR::AST::parse_action_expr;
    my $var = sub {
        my ($name) = @_;
        return { kind => 'variable', name => $name, source => '__bad_var_'.$name.'__()' };
    };
    my $str = sub {
        my ($value) = @_;
        return { kind => 'string', value => $value, quote => '"', source => '__bad_string_'.$value.'__()' };
    };
    my $call = sub {
        my ($name, @args) = @_;
        return { kind => 'call', name => $name, source => '__bad_call_'.$name.'__()', args => \@args };
    };
    my $chain = sub {
        my ($receiver, @calls) = @_;
        return {
            kind => 'fluent_chain',
            source => '__bad_chain_source__()',
            receiver => $receiver,
            calls => \@calls,
        };
    };
    my $fluent_call = sub {
        my ($method, @args) = @_;
        return { method => $method, source => '__bad_fluent_'.$method.'__()', args => \@args };
    };

    {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::AST::parse_action_expr = sub {
            my ($expr, @rest) = @_;
            ++$parse_calls;
            if ($expr eq '[value, true, concat("a","b"), foo["a"][scalar(i)], { key => value }]') {
                return {
                    kind => 'array_literal',
                    source => '__bad_return_payload_array__()',
                    items => [
                        $var->('value'),
                        { kind => 'boolean', value => 1, source => '__bad_true__()' },
                        $call->('concat', $str->('a'), $str->('b')),
                        {
                            kind => 'nested_access',
                            base => 'foo',
                            source => '__bad_nested_access__()',
                            segments => [
                                { kind => 'key', value => 'a', source => '["a"]' },
                                { kind => 'index', expr => $call->('scalar', $var->('i')) },
                            ],
                        },
                        {
                            kind => 'hash_literal',
                            source => '__bad_hash_literal__()',
                            entries => [
                                { key => $var->('key'), value => $var->('value') },
                            ],
                        },
                    ],
                };
            }
            if ($expr eq '["x", "abc".substr()]') {
                return {
                    kind => 'array_literal',
                    source => '__bad_return_payload_chain_array__()',
                    items => [
                        $str->('x'),
                        $chain->($str->('abc'), $fluent_call->('substr')),
                    ],
                };
            }
            if ($expr eq 'count') {
                return $var->('count');
            }
            return $orig_parse_action_expr->($expr, @rest);
        };

        my $payload = LinkedSpec::call_spec_handler_subst(
            'Top',
            q{return([value, true, concat("a","b"), foo["a"][scalar(i)], { key => value }])},
        );
        like($payload, qr/\$value/, 'AST return payload lowers bare scalar reads from typed nodes');
        like($payload, qr/JSON::PP::true/, 'AST return payload lowers booleans from typed nodes');
        like($payload, qr/__ls_concat_parts/, 'AST return payload lowers nested helper calls from typed nodes');
        like($payload, qr/\$foo->\{"a"\}->\[\$i\]/, 'AST return payload lowers nested access from typed nodes');
        like($payload, qr/\{\$key => \$value\}/, 'AST return payload lowers hash literals from typed nodes');

        my $bad_chain = LinkedSpec::call_spec_handler_subst('Top', q{return(["x", "abc".substr()])});
        unlike($bad_chain, qr/\bsubstr\s*\(/, 'unsupported covered return-payload chain helper does not leak as a host call');
        like($bad_chain, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:substr/, 'unsupported covered return-payload chain helper keeps diagnostic sentinel');

        my $bare_scalar = LinkedSpec::call_spec_handler_subst('Top', q{return(count)});
        like($bare_scalar, qr/return \$count\b/, 'AST variable return payloads still lower through scalar source-slot reads');
        unlike($bare_scalar, qr/return count\b/, 'AST variable return payloads do not leak raw identifiers');

        my $all = join("\n", $payload, $bad_chain, $bare_scalar);
        unlike($all, qr/__bad_/, 'AST return-payload lowering does not reuse fake source text');
    }

    my $raw_fallback = LinkedSpec::call_spec_handler_subst('Top', q{return(\(my $capt = capture_slice()))});
    like(
        $raw_fallback,
        qr/return \\\(my \$capt = do \{ substr\(\$\$STRING, \$IPOS, \$LSPOS - \$IPOS - length \$LMATCH\) \}\)/,
        'raw compatibility return payloads keep the narrow helper fallback',
    );
    ok($parse_calls >= 2, 'return payloads entered through the AST parser');
};

subtest 'block-value lowering consumes AST action statements' => sub {
    my $parse_calls = 0;
    my $orig_parse_action_expr = \&LinkedSpec::ActionIR::AST::parse_action_expr;
    my $var = sub {
        my ($name) = @_;
        return { kind => 'variable', name => $name, source => '__bad_var_'.$name.'__()' };
    };
    my $str = sub {
        my ($value) = @_;
        return { kind => 'string', value => $value, quote => '"', source => '__bad_string_'.$value.'__()' };
    };
    my $call = sub {
        my ($name, @args) = @_;
        return { kind => 'call', name => $name, source => '__bad_call_'.$name.'__()', args => \@args };
    };
    my $stmt = sub {
        my ($label, $expr) = @_;
        return {
            kind => 'action_stmt',
            source => '__bad_stmt_'.$label.'__()',
            expr => $expr,
            drops_value => 1,
        };
    };
    my $block = sub {
        return {
            kind => 'block_value',
            source => '__bad_block_source__()',
            block => {
                kind => 'action_block',
                source => '__bad_action_block_source__()',
                statements => [
                    $stmt->('set_x', $call->('assign', $var->('x'), $str->('a'))),
                    $stmt->('return_value', $call->('return', $var->('value'))),
                    $stmt->('set_y', $call->('assign', $var->('y'), $str->('b'))),
                    $stmt->('final_y', $var->('y')),
                ],
            },
        };
    };

    {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::AST::parse_action_expr = sub {
            my ($expr, @rest) = @_;
            ++$parse_calls;
            if ($expr eq '{ set(x,"poison"); return(poison); set(y,"poison"); y }') {
                return $block->();
            }
            return $orig_parse_action_expr->($expr, @rest);
        };

        my $lowered = LinkedSpec::call_spec_handler_subst(
            'Top',
            q{return({ set(x,"poison"); return(poison); set(y,"poison"); y })},
        );
        like($lowered, qr/^return do \{ my \$__ls_block_done = 0; my \$__ls_block_value;/,
            'non-final block-local return still uses the guarded block-value wrapper');
        like($lowered, qr/\$x = "a"/, 'block side-effect assignment lowers from AST action statement fields');
        like($lowered, qr/\$__ls_block_value = \$value/, 'block-local return payload lowers from AST call argument');
        like($lowered, qr/\$y = "b"/, 'post-return guarded side effect also lowers from AST action statement fields');
        like($lowered, qr/\$__ls_block_value = \$y/, 'final block expression lowers from AST statement expression');
        unlike($lowered, qr/poison|__bad_/, 'block-value lowering does not reuse fake statement source or original poison text');
    }

    ok($parse_calls >= 1, 'block-value lowering entered through the AST parser');
};

done_testing();
