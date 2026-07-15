use strict;
use warnings;
use Test::More;
use JSON::PP ();
use File::Basename qw(dirname);
use File::Spec ();

use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();

my $repo_root = dirname(dirname(File::Spec->rel2abs(__FILE__)));
my $contract_path = File::Spec->catfile(
    $repo_root,
    'capability_conformance',
    'callable_codeblock_contract.json',
);
open my $contract_fh, '<:encoding(UTF-8)', $contract_path
    or die "Could not read $contract_path: $!";
my $contract_text = do {
    local $/;
    <$contract_fh>;
};
my $contract = JSON::PP->new->decode($contract_text);
close $contract_fh or die "Could not close $contract_path: $!";

my $descriptor_contract_path = File::Spec->catfile(
    $repo_root,
    'capability_conformance',
    'outward_descriptor_contract.json',
);
open my $descriptor_contract_fh, '<:encoding(UTF-8)', $descriptor_contract_path
    or die "Could not read $descriptor_contract_path: $!";
my $descriptor_contract = JSON::PP->new->decode(do {
    local $/;
    <$descriptor_contract_fh>;
});
close $descriptor_contract_fh or die "Could not close $descriptor_contract_path: $!";

my @ast_fields = sort @{$contract->{ast_schema}{fields}};

sub parse_expr {
    my ($source) = @_;
    return LinkedSpec::ActionIR::AST::parse_action_expr($source);
}

sub signature_source {
    my ($signature) = @_;
    my @parts = @{$signature->{positional_params}};
    push @parts, '...' . $signature->{rest_param}
        if defined $signature->{rest_param};
    return join(', ', @parts);
}

sub run_spec {
    my ($source, $input) = @_;
    my $parser = LinkedSpec::Get(\$source);
    ok($parser && ref($parser) eq 'CODE', 'focused callable-codeblock spec compiles');
    return undef unless $parser && ref($parser) eq 'CODE';
    my $runtime_input = $input;
    return $parser->(\$runtime_input);
}

sub run_spec_with_context {
    my ($source, $input) = @_;
    my %runtime_ctx;
    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%runtime_ctx);
    ok($parser && ref($parser) eq 'CODE', 'focused callable-codeblock failure spec compiles');
    return (undef, \%runtime_ctx) unless $parser && ref($parser) eq 'CODE';
    my $runtime_input = $input;
    my $result = $parser->(\$runtime_input);
    return ($result, \%runtime_ctx);
}

subtest 'neutral brace classification and valid literal AST records' => sub {
    my %perl_kind = (
        harray_literal => 'hash_literal',
        block_value => 'block_value',
        codeblock_literal => 'codeblock_literal',
    );
    foreach my $case (@{$contract->{brace_classification}}) {
        my $node = parse_expr($case->{source});
        is(
            $node->{kind},
            $perl_kind{$case->{expected_kind}},
            "$case->{id} has the neutral brace classification",
        );
    }

    foreach my $literal (@{$contract->{literals}}) {
        my $node = parse_expr($literal->{source});
        is_deeply(
            [sort keys %$node],
            \@ast_fields,
            "$literal->{id} exposes exactly the version-1 codeblock AST fields",
        );
        is($node->{version}, 1, "$literal->{id} has codeblock AST version 1");
        is($node->{source_text}, $literal->{source}, "$literal->{id} preserves exact literal source");
        is($node->{body_source}, $literal->{body_source}, "$literal->{id} preserves exact body source");
        is_deeply(
            $node->{source_span},
            {start => 0, end => length($literal->{source})},
            "$literal->{id} preserves its exact source span",
        );
        my $body_start = index($literal->{source}, '|', 2) + 1;
        is_deeply(
            $node->{body_span},
            {start => $body_start, end => length($literal->{source}) - 1},
            "$literal->{id} preserves its exact body span",
        );
        is($node->{body_ast}{kind}, 'action_block', "$literal->{id} owns a typed ActionIR body");
        is($node->{body_ast}{source}, $literal->{body_source}, "$literal->{id} body AST preserves source bytes");
        is(
            signature_source($node->{signature}),
            $literal->{signature_source},
            "$literal->{id} preserves the canonical callable signature",
        );
        is($node->{signature}{min_arity}, scalar(@{$node->{signature}{positional_params}}),
            "$literal->{id} signature minimum matches its fixed prefix");
        my $expected_max = defined($node->{signature}{rest_param})
            ? undef
            : scalar(@{$node->{signature}{positional_params}});
        is($node->{signature}{max_arity}, $expected_max, "$literal->{id} signature maximum is exact or open");
        ok(!exists($node->{captured_environment}), "$literal->{id} captures no environment field");
    }

    my $assignment = parse_expr('cb = {|x| return(x) }');
    is($assignment->{kind}, 'assign_scalar', 'a callable literal composes as an assignment RHS');
    is_deeply($assignment->{value}{source_span}, {start => 5, end => 21},
        'nested literal source span remains exact in its containing expression');
    is_deeply($assignment->{value}{body_span}, {start => 9, end => 20},
        'nested literal body span remains exact in its containing expression');
    is_deeply($assignment->{value}{body_ast}{statements}[0]{source_span}, {start => 10, end => 19},
        'typed body statement spans use the containing expression coordinate space');
};

subtest 'invalid literal forms retain neutral diagnostic codes' => sub {
    foreach my $case (@{$contract->{invalid_literal_cases}}) {
        my $node = parse_expr($case->{source});
        is($node->{kind}, 'codeblock_literal_error', "$case->{id} remains a typed literal error");
        is($node->{code}, $case->{expected_code}, "$case->{id} keeps the neutral diagnostic code");
    }
};

subtest 'lowering serializes inert typed data without host callable objects' => sub {
    my ($literal) = grep { $_->{id} eq 'mutate_dynamic' } @{$contract->{literals}};
    my $lowered = LinkedSpec::call_spec_handler_subst('Top', 'cb = ' . $literal->{source});
    like($lowered, qr/JSON::PP->new->utf8\(1\)->decode\(pack\("H\*", "[0-9a-f]+"\)\)/,
        'generated Perl reconstructs the codeblock from canonical hex-serialized data');
    unlike($lowered, qr/\bsub\s*\{|CODE\s*\(/, 'generated construction contains no host closure or coderef');
    unlike($lowered, qr/\{\|value\|/, 'literal syntax is inert serialized data rather than executable Perl');

    my $spec = join "\n",
        'Top::',
        ' /x/ -> Done {',
        '   state = "before";',
        '   cb = ' . $literal->{source} . ';',
        '   alias = cb;',
        '   return({ "state" : state, "cb" : alias })',
        ' }',
        '',
        'Done::',
        ' /x/',
        '';
    my $result = run_spec($spec, 'xx');
    is($result->{state}, 'before', 'constructing and copying a codeblock does not execute its body');
    is_deeply([sort keys %{$result->{cb}}], \@ast_fields, 'runtime codeblock keeps the exact typed record fields');
    is($result->{cb}{source_text}, $literal->{source}, 'generated execution preserves exact literal source');
    is($result->{cb}{body_source}, $literal->{body_source}, 'generated execution preserves exact body source');
    is($result->{cb}{body_ast}{source}, $literal->{body_source}, 'generated execution preserves typed body source');
    is_deeply($result->{cb}{signature}, parse_expr($literal->{source})->{signature},
        'generated execution preserves the parsed callable signature');
};

subtest 'user-function arguments and results preserve codeblock records' => sub {
    my $argument_source = '{|x| return(x) }';
    my $result_source = '{|| return("ok") }';
    my $spec = join "\n",
        'fn identity(value) { return(value) }',
        'fn make() { return(' . $result_source . ') }',
        'Top::',
        ' /x/ -> Done {',
        '   from_arg = identity(' . $argument_source . ');',
        '   from_result = make();',
        '   return({ "from_arg" : from_arg, "from_result" : from_result })',
        ' }',
        '',
        'Done::',
        ' /x/',
        '';
    my $result = run_spec($spec, 'xx');
    is_deeply($result->{from_arg}, parse_expr($argument_source),
        'a codeblock passed through a user-function parameter remains exact typed data');
    is_deeply($result->{from_result}, parse_expr($result_source),
        'a codeblock constructed and returned by a user function remains exact typed data');
};

subtest 'neutral fixture executes with dynamic caller context' => sub {
    my $fixture = $contract->{fixture};
    my $result = run_spec($fixture->{spec_source}, $fixture->{input});
    is_deeply($result, $fixture->{expected},
        'the contract-sourced Perl fixture matches every neutral invocation result');

    my $generated_source = LinkedSpec::emit_generated_source(
        \$fixture->{spec_source},
        source_identity => 'callable-codeblock-fixture.spec',
    );
    my $package = 'LinkedSpec::CallableCodeblockFixtureGenerated';
    my $loaded = eval "package $package; $generated_source; 1";
    ok($loaded, 'standalone generated source containing codeblock calls loads');
    diag($@) unless $loaded;
    if ($loaded) {
        no strict 'refs';
        my $input = $fixture->{input};
        my $generated_result = &{"${package}::Execute"}(\$input);
        is_deeply($generated_result, $fixture->{expected},
            'standalone generated execution matches the neutral fixture');
    }
};

subtest 'standalone discard and static callable precedence remain exact' => sub {
    my $discard_spec = join "\n",
        'Top::',
        ' /x/ -> Done {',
        '   state = "";',
        '   cb = {|value| state = cat(state, value); return(state) };',
        '   cb("x");',
        '   return(state)',
        ' }',
        '',
        'Done::',
        ' /x/',
        '';
    is(run_spec($discard_spec, 'xx'), 'x',
        'a standalone codeblock call executes its side effects and discards its result');
    my $discard_descriptor = LinkedSpec::Get(\$discard_spec, return_descriptor => 1);
    my $discard_meta = $discard_descriptor->{spec}{Top}{meta}{action_rewriter};
    is($discard_meta->{raw_perl_dependency_count}, 0,
        'a standalone codeblock call introduces no raw Perl dependency');
    ok(grep({ $_ eq 'VALUE_DROP' } @{$discard_meta->{canonical_action_ir_nodes}}),
        'a standalone codeblock call is canonical VALUE_DROP ActionIR');

    my $helper_precedence_spec = join "\n",
        'Top::',
        ' /x/ -> Done {',
        '   cat = {|left, right| return("shadow") };',
        '   return(cat("a", "b"))',
        ' }',
        '',
        'Done::',
        ' /x/',
        '';
    is(run_spec($helper_precedence_spec, 'xx'), 'ab',
        'a governed helper retains precedence over a same-named codeblock binding');

    my $function_precedence_spec = join "\n",
        'fn choose() { return("static") }',
        'Top::',
        ' /x/ -> Done {',
        '   choose = {|| return("shadow") };',
        '   return(choose())',
        ' }',
        '',
        'Done::',
        ' /x/',
        '';
    is(run_spec($function_precedence_spec, 'xx'), 'static',
        'a registered user function retains precedence over a same-named codeblock binding');
};

subtest 'typed invocation failures preserve neutral diagnostic payloads' => sub {
    my @cases = (
        {
            name => 'fixed arity mismatch',
            body => 'cb = {|value| return(value) }; return(cb())',
            expected => {
                code => 'codeblock_arity_mismatch',
                expected => 'exactly 1',
                got => 0,
            },
        },
        {
            name => 'keyword argument rejection',
            body => 'cb = {|value| return(value) }; return(cb(value: "x"))',
            expected => {
                code => 'codeblock_keyword_arguments_unsupported',
                expected => 'positional arguments',
                got => 1,
            },
        },
        {
            name => 'bound scalar is not callable',
            body => 'text = "not callable"; return(text())',
            expected => {
                code => 'value_not_callable',
                value_kind => 'scalar',
            },
        },
        {
            name => 'direct recursion rejection',
            body => 'reader = {|| return(reader()) }; return(reader())',
            expected => {
                code => 'codeblock_recursion_unsupported',
                cycle => ['reader', 'reader'],
            },
        },
    );

    foreach my $case (@cases) {
        my $spec = join "\n",
            'Top::',
            ' /x/ -> Done { ' . $case->{body} . ' }',
            '',
            'Done::',
            ' /x/',
            '';
        my ($result, $runtime_ctx) = run_spec_with_context($spec, 'xx');
        is($result, undef, "$case->{name} returns no parser result");
        my $detail = $runtime_ctx->{last_error}{detail};
        isa_ok($detail, 'LinkedSpec::CodeblockRuntime::Error', "$case->{name} has a typed runtime detail");
        foreach my $field (sort keys %{$case->{expected}}) {
            is_deeply($detail->{$field}, $case->{expected}{$field},
                "$case->{name} preserves neutral $field");
        }
    }

    my $record = parse_expr('{|value| value = cat(value, "!"); missing() }');
    my $value = 'outer';
    my $error;
    eval {
        require LinkedSpec::CodeblockRuntime;
        LinkedSpec::CodeblockRuntime::invoke(
            $record,
            ['inner'],
            {value => \$value},
            'failing',
        );
        1;
    } or $error = $@;
    isa_ok($error, 'LinkedSpec::CodeblockRuntime::Error',
        'a failing body reports a typed runtime error directly');
    is($error->{code}, 'unknown_helper', 'a failing body preserves its typed cause');
    is($error->{name}, 'missing', 'a failing body identifies the unknown call');
    is($value, 'outer', 'temporary parameter binding restores after body failure');
};

subtest 'final codeblock declarations and contextual AST normalization are metadata-owned' => sub {
    my $source = join "\n",
        'Top::',
        ' /x/ -> Done { return("x") }',
        '',
        'Done::',
        ' /x/',
        '',
        'fn apply(value, callback: codeblock) { return(callback()) }',
        '';
    my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
    ok(ref($descriptor) eq 'HASH', 'typed-codeblock user-function descriptor builds');
    my $record = $descriptor->{functions}{apply};
    my $variant = $descriptor_contract->{function_record_variants}{final_codeblock_v3};
    is_deeply([sort keys %$record], [sort @{$variant->{record_fields}}],
        'typed-codeblock function uses the exact neutral version-3 record');
    is($record->{version}, $variant->{function_version},
        'typed-codeblock function is outward descriptor version 3');
    is_deeply($descriptor->{functions}{apply}{params}, ['value', 'callback'],
        'typed-codeblock function preserves ordered parameter names');
    is_deeply($descriptor->{functions}{apply}{parameter_kinds}, {callback => 'codeblock'},
        'typed-codeblock function declares only the final parameter kind');
    is_deeply($descriptor->{functions}{apply}{body_payload}{parameter_kinds}, {callback => 'codeblock'},
        'staged body payload preserves the final parameter kind');
    is_deeply($descriptor->{functions}{apply}{body_parse_job}{parameter_kinds}, {callback => 'codeblock'},
        'staged body parse job preserves the final parameter kind');

    require LinkedSpec::CallableContract;
    require LinkedSpec::ActionIR::MethodLowering;
    my $attached = parse_expr('with("x") { return(value) }');
    my $parenthesized = parse_expr('with("x", { return(value) })');
    my $attached_normalized = LinkedSpec::ActionIR::MethodLowering::_normalize_contextual_codeblock_call_node(
        {}, 'helper', $attached, 'with');
    my $parenthesized_normalized = LinkedSpec::ActionIR::MethodLowering::_normalize_contextual_codeblock_call_node(
        {}, 'helper', $parenthesized, 'with');
    is($attached_normalized->{node}{args}[-1]{kind}, 'codeblock_argument',
        'attached helper block normalizes to typed codeblock_argument');
    is($parenthesized_normalized->{node}{args}[-1]{kind}, 'codeblock_argument',
        'parenthesized helper block normalizes to typed codeblock_argument');
    is_deeply(
        {map { $_ => $attached_normalized->{node}{args}[-1]{$_} }
            qw(kind version signature body_source body_ast)},
        {map { $_ => $parenthesized_normalized->{node}{args}[-1]{$_} }
            qw(kind version signature body_source body_ast)},
        'attached and parenthesized helper forms have one canonical semantic AST payload');

    my $generic_receiver = parse_expr('"x".custom() { return(value) }');
    is($generic_receiver->{kind}, 'fluent_chain', 'receiver parser recognizes attached syntax generically');
    ok($generic_receiver->{calls}[0]{receiver_trailing_block_arg},
        'generic receiver syntax is marked for later callable-contract validation');
};

subtest 'helper user-function and receiver contextual forms execute equivalently' => sub {
    my @helper_bodies = (
        'return(with("x") { return(cat(value, "!")) })',
        'return(with("x", { return(cat(value, "!")) }))',
        'return(with("x", {|item| return(cat(item, "!")) }))',
        'return("x".with() { return(cat(value, "!")) })',
        'return("x".with({ return(cat(value, "!")) }))',
        'return("x".with({|item| return(cat(item, "!")) }))',
    );
    foreach my $body (@helper_bodies) {
        my $spec = join "\n",
            'Top::',
            " /x/ -> Done { $body }",
            '',
            'Done::',
            ' /x/',
            '';
        is(run_spec($spec, 'xx'), 'x!', "$body executes through declared codeblock metadata");
    }

    my $user_spec = join "\n",
        'Top::',
        ' /x/ -> Done {',
        '   return([',
        '     apply("a") { return(cat(value, "!")) },',
        '     apply("b", { return(cat(value, "?")) }),',
        '     invoke("c", {|item| return(cat(item, ".")) })',
        '   ])',
        ' }',
        '',
        'Done::',
        ' /x/',
        '',
        'fn apply(value, callback: codeblock) { return(callback()) }',
        'fn invoke(value, callback: codeblock) { return(callback(value)) }',
        '';
    my $expected = ['a!', 'b?', 'c.'];
    is_deeply(run_spec($user_spec, 'xx'), $expected,
        'typed user functions accept attached, parenthesized, and explicit-literal codeblocks');

    my $generated_source = LinkedSpec::emit_generated_source(
        \$user_spec,
        source_identity => 'final-codeblock-user-function.spec',
    );
    my $package = 'LinkedSpec::FinalCodeblockUserFunctionGenerated';
    my $loaded = eval "package $package; $generated_source; 1";
    ok($loaded, 'standalone generated typed-callback source loads');
    diag($@) unless $loaded;
    if ($loaded) {
        no strict 'refs';
        my $input = 'xx';
        is_deeply(&{"${package}::Execute"}(\$input), $expected,
            'standalone generated typed-callback execution preserves all three forms');
    }

    my @tree_forms = (
        '{ "b" : 2, "a" : 1 }.map_leaves() { return(cat(value, "!")) }',
        '{ "b" : 2, "a" : 1 }.map_leaves({ return(cat(value, "!")) })',
    );
    foreach my $expr (@tree_forms) {
        my $spec = join "\n",
            'Top::',
            " /x/ -> Done { return($expr) }",
            '',
            'Done::',
            ' /x/',
            '';
        is_deeply(run_spec($spec, 'xx'), {a => '1!', b => '2!'},
            "$expr uses the receiver callable contract");
    }
};

subtest 'typed final-codeblock declaration and value failures stay explicit' => sub {
    my @invalid_declarations = (
        ['callback: codeblock(item)', 'codeblock_declaration_has_no_argument_list'],
        ['callback: codeblock, tail', 'codeblock_parameter_must_be_final'],
        [': codeblock', 'invalid_codeblock_parameter_name'],
        ['callback: closure', 'unknown_parameter_type'],
    );
    foreach my $case (@invalid_declarations) {
        my ($declaration, $code) = @$case;
        my $spec = join "\n",
            'Top::',
            ' /x/ -> Done { return("x") }',
            '',
            'Done::',
            ' /x/',
            '',
            "fn invalid($declaration) { return(undef) }",
            '';
        my %runtime_ctx;
        my $parser = LinkedSpec::Get(\$spec, runtime_ctx_ref => \%runtime_ctx);
        ok(!defined($parser), "$declaration is rejected before parser construction");
        like($runtime_ctx{last_error}{detail} // '', qr/\Q$code\E/,
            "$declaration reports $code");
    }

    my $malformed_with_harray_body = join "\n",
        'Top::',
        ' /x/ -> Done { return("x") }',
        '',
        'Done::',
        ' /x/',
        '',
        'fn invalid(value,, tail) { return({ "kind" : value }) }',
        '';
    my %malformed_ctx;
    my $malformed_parser = LinkedSpec::Get(\$malformed_with_harray_body, runtime_ctx_ref => \%malformed_ctx);
    ok(!defined($malformed_parser), 'an independently malformed function header is rejected');
    like($malformed_ctx{last_error}{detail} // '', qr/invalid user function definition/,
        'generic malformed-header detail remains stable');
    unlike($malformed_ctx{last_error}{detail} // '', qr/unknown_parameter_type/,
        'a colon in the function body cannot reclassify the header diagnostic');

    my $non_codeblock_spec = join "\n",
        'Top::',
        ' /x/ -> Done { return(apply("x", { "value" : value })) }',
        '',
        'Done::',
        ' /x/',
        '',
        'fn apply(value, callback: codeblock) { return(callback()) }',
        '';
    my ($result, $runtime_ctx) = run_spec_with_context($non_codeblock_spec, 'xx');
    is($result, undef, 'harray in a codeblock slot returns no parser result');
    my $detail = $runtime_ctx->{last_error}{detail};
    isa_ok($detail, 'LinkedSpec::CodeblockRuntime::Error',
        'harray in a codeblock slot has typed runtime detail');
    is($detail->{code}, 'final_argument_not_codeblock',
        'harray in a codeblock slot is not contextually promoted');
    is($detail->{value_kind}, 'harray', 'typed rejection preserves the actual harray kind');

    my $helper_non_codeblock_spec = join "\n",
        'Top::',
        ' /x/ -> Done { return(with("x", { "value" : value })) }',
        '',
        'Done::',
        ' /x/',
        '';
    my ($helper_result, $helper_runtime_ctx) = run_spec_with_context($helper_non_codeblock_spec, 'xx');
    is($helper_result, undef, 'helper harray in a codeblock slot returns no parser result');
    my $helper_detail = $helper_runtime_ctx->{last_error}{detail};
    isa_ok($helper_detail, 'LinkedSpec::CodeblockRuntime::Error',
        'helper harray in a codeblock slot has typed runtime detail');
    is($helper_detail->{code}, 'final_argument_not_codeblock',
        'helper harray uses the declared final-codeblock boundary');
    is($helper_detail->{value_kind}, 'harray',
        'helper typed rejection preserves the actual harray kind');

    my $receiver_non_codeblock_spec = join "\n",
        'Top::',
        ' /x/ -> Done { return("x".with({ "value" : value })) }',
        '',
        'Done::',
        ' /x/',
        '';
    my ($receiver_result, $receiver_runtime_ctx) = run_spec_with_context($receiver_non_codeblock_spec, 'xx');
    is($receiver_result, undef, 'receiver harray in a codeblock slot returns no parser result');
    my $receiver_detail = $receiver_runtime_ctx->{last_error}{detail};
    isa_ok($receiver_detail, 'LinkedSpec::CodeblockRuntime::Error',
        'receiver harray in a codeblock slot has typed runtime detail');
    is($receiver_detail->{code}, 'final_argument_not_codeblock',
        'receiver harray uses the declared final-codeblock boundary');
    is($receiver_detail->{value_kind}, 'harray',
        'receiver typed rejection preserves the actual harray kind');
};

done_testing();
