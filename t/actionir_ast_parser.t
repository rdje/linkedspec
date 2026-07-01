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

subtest 'parser seam is incremental' => sub {
    my $lowered = LinkedSpec::call_spec_handler_subst('Top', 'return(3.5.floor().add(1))');
    like($lowered, qr/__ls_num_floor.*__ls_num_add/s, 'receiver-chain lowering remains on the compatibility path until the fluent-chain leaf');
};

done_testing();
