use strict;
use warnings;
use Test::More;
use JSON::PP ();
use File::Basename qw(dirname);
use File::Spec ();
use Scalar::Util ();
use B ();
use Storable ();

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

subtest 'tracked scalar assignments preserve values and remain quiet in every context' => sub {
    require LinkedSpec::ActionIR::MethodLowering;
    my $expression = LinkedSpec::ActionIR::MethodLowering::_tracked_scalar_assignment_expr(
        'value', 'do { ++$effects; $input }', {nested_write_target => sub { 1 }}, 0);
    for my $context (qw(void value list)) {
        my $operation = $context eq 'void' ? $expression . '; my $result;'
            : $context eq 'value' ? 'my $result = ' . $expression . ';'
            : 'my $result = [' . $expression . '];';
        my $source = 'sub { my ($input) = @_; my $value; my $effects = 0;'
            . ' my %__ls_binding_presence; ' . $operation
            . ' return [$value, $result, $__ls_binding_presence{value}, $effects] }';
        my (@warnings, $code, $error);
        {
            local $SIG{__WARN__} = sub { push @warnings, @_ };
            $code = eval $source;
            $error = $@;
        }
        is($error, '', "$context fragment compiles");
        is_deeply(\@warnings, [], "$context fragment emits no warning");
        next unless $code;
        for my $input (0, '0', 'text', undef, [], {}) {
            my $expected = $context eq 'void' ? undef
                : $context eq 'value' ? $input : [$input];
            my $actual = $code->($input);
            is_deeply($actual, [$input, $expected, 1, 1],
                "$context preserves value, presence, and single evaluation");
            my $result = $context eq 'list' ? $actual->[1][0] : $actual->[1];
            is(Scalar::Util::refaddr($result), Scalar::Util::refaddr($input),
                "$context preserves assignment reference identity")
                if ref($input) && $context ne 'void';
        }
    }
};

subtest 'allocating a deferred slot retains its supplied caller presence flag' => sub {
    require LinkedSpec::CodeblockRuntime;
    my (%bindings, $present);
    $present = 0;
    my $setter = parse_expr('{|| document = undef }');
    LinkedSpec::CodeblockRuntime::invoke($setter, [], \%bindings, 'setter', undef, {},
        {document => \$present});
    is($present, 1, 'the caller flag observes the new null binding');
    ok(exists($bindings{document}), 'the function frame retains the new slot');
    my $writer = parse_expr('{|| document["x"] = 2 }');
    my $ok = eval {
        LinkedSpec::CodeblockRuntime::invoke($writer, [], \%bindings, 'writer', undef, {},
            {document => \$present});
        1;
    };
    my $failure = $@;
    ok(!$ok, 'a separately supplied flag map retains bound null');
    is(ref($failure), 'LinkedSpec::BindingRuntime::NestedWriteError', 'the error remains typed');
    is(ref($failure) ? $failure->{code} : undef, 'nested_write_kind_conflict', 'null cannot vivify');
    is($present, 1, 'the structural failure preserves caller presence');
    ok(!defined(${$bindings{document}}), 'the structural failure preserves null');
};

subtest 'ordinary standalone lowering does not require a caller presence frame' => sub {
    my $lowered = LinkedSpec::call_spec_handler_subst('Top', 'item = 1');
    my ($item, @warnings);
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    my $ok = eval "$lowered; 1";
    is($@, '', 'ordinary fragment compiles with only its authored binding');
    ok($ok, 'ordinary fragment completes');
    is($item, 1, 'ordinary fragment preserves the assigned value');
    is_deeply(\@warnings, [], 'ordinary fragment emits no host warnings');
};

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

subtest 'operator-named signature parameters preserve native and generated calls' => sub {
    my $index = 0;
    for my $name (qw(y tr s q qq qx qr m)) {
        for my $params ("x,$name", "x,...$name") {
            my $source = 'Top:: I { cb={|' . $params
                . '| return(x) }; return(cb("ok","unused")) }';
            my %ctx;
            my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx);
            my $input = 'x';
            is($parser->(\$input), 'ok', "$params native invocation returns its first parameter");
            is($ctx{last_error}, undef, "$params has no native handler compilation error");
            my $generated = LinkedSpec::emit_generated_source(\$source,
                source_identity => "signature-pipe-$index.spec");
            my $package = 'LinkedSpec::SignaturePipeGenerated' . $index++;
            my $loaded = eval "package $package; $generated; 1";
            ok($loaded, "$params generated source loads") or diag($@);
            if ($loaded) {
                no strict 'refs';
                my $fresh_input = 'x';
                is(&{"${package}::Execute"}(\$fresh_input), 'ok',
                    "$params generated invocation returns its first parameter");
            }
        }
    }
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

subtest 'constructed values and callable arguments retain evaluated values' => sub {
    my $fixture_path = File::Spec->catfile(
        $repo_root, 'tests', 'evaluated-values', 'cases.json',
    );
    open my $fixture_fh, '<:raw', $fixture_path
        or die "Could not read $fixture_path: $!";
    my $fixture = JSON::PP->new->utf8->decode(do { local $/; <$fixture_fh> });
    close $fixture_fh or die "Could not close $fixture_path: $!";
    my $json = JSON::PP->new->canonical->allow_nonref;
    my $index = 0;
    foreach my $case (@{$fixture->{cases}}) {
        my $package = 'EvaluatedValueOrder' . $index++;
        subtest $case->{id} => sub {
            my $source = ($case->{functions} // '')
                . "Top: /x/\n I { $case->{body} }\n";
            my ($actual, $context) = run_spec_with_context($source, 'x');
            is($json->encode($actual), $json->encode($case->{expected}),
                'native values and primitive kinds match the independent expectation');
            ok(!defined($context->{last_error}), 'native execution has no runtime error');

            my $emitted = eval {
                LinkedSpec::emit_generated_source(
                    \$source, source_identity => 'evaluated-value-order.spec',
                );
            };
            ok(defined($emitted) && length($emitted), 'independent parser source emits');
            diag($@) if $@;
            my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
            ok($loaded, 'independently emitted parser source loads');
            diag($@) if $@;
            return unless $loaded;
            my $input = 'x';
            my $generated;
            my $ok = eval {
                no strict 'refs';
                my $function = $package . '::Execute';
                $generated = &{$function}(\$input);
                1;
            };
            ok($ok, 'independently emitted parser executes without an error');
            diag($@) unless $ok;
            is($json->encode($generated), $json->encode($case->{expected}),
                'generated values and primitive kinds match the independent expectation');
        };
    }
};

subtest 'with exposes the current scoped value to callable dispatch' => sub {
    my $path = File::Spec->catfile($repo_root, 'tests', 'scoped-with', 'cases.json');
    open my $fh, '<:raw', $path or die "Could not read $path: $!";
    my $fixture = JSON::PP->new->utf8->decode(do { local $/; <$fh> });
    close $fh or die "Could not close $path: $!";
    my $json = JSON::PP->new->canonical->allow_nonref;
    my $index = 0;
    foreach my $case (@{$fixture->{cases}}) {
        my $package = 'ScopedWithContract' . $index++;
        subtest $case->{id} => sub {
            my $source = ($case->{functions} // '') . "Top: /x/\n I { $case->{body} }\n";
            my (%context, @warnings, $actual, $native_ok, $native_error, $output);
            {
                open my $capture, '>', \$output or die "Capture diagnostic output: $!";
                local *STDOUT = $capture;
                local $SIG{__WARN__} = sub { push @warnings, @_ };
                $native_ok = eval {
                    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
                    die "Native parser did not build\n" unless ref($parser) eq 'CODE';
                    my $input = 'x';
                    $actual = $parser->(\$input);
                    1;
                };
                $native_error = $@ unless $native_ok;
            }
            ok($native_ok, 'native parser builds and completes its public invocation');
            diag($native_error) unless $native_ok;
            my ($emitted, $generated, $generated_error, $generated_ok);
            {
                local $SIG{__WARN__} = sub { push @warnings, @_ };
                $generated_ok = eval {
                    $emitted = LinkedSpec::emit_generated_source(
                        \$source, source_identity => 'scoped-with.spec',
                    );
                    eval "package $package; $emitted; 1" or die $@;
                    my $input = 'x';
                    no strict 'refs';
                    $generated = &{$package . '::Execute'}(\$input);
                    1;
                };
                $generated_error = $@ unless $generated_ok;
            }
            ok(defined($emitted) && length($emitted), 'fresh standalone parser source emits');
            is_deeply(\@warnings, [], 'native and standalone routes preserve warning discipline');
            if (exists $case->{expected}) {
                ok(!defined($context{last_error}), 'native execution has no runtime error');
                is($json->encode($actual), $json->encode($case->{expected}), 'native contract value');
                ok($generated_ok, 'fresh standalone parser loads and executes');
                diag($generated_error) unless $generated_ok;
                is($json->encode($generated), $json->encode($case->{expected}), 'standalone contract value');
                is($output // '', '', 'healthy native invocation emits no diagnostic output');
            } else {
                is($actual, undef, 'native invocation reports no successful value');
                my $detail = $context{last_error}{detail};
                isa_ok($detail, 'LinkedSpec::CodeblockRuntime::Error', 'native typed cause');
                ok(!$generated_ok, 'standalone invocation rejects the invalid call');
                is(ref($generated_error), 'HASH', 'standalone public error envelope');
                is($generated_error->{code}, 'generated_execution_failed', 'standalone execution stage');
                my $cause = $generated_error->{detail};
                isa_ok($cause, 'LinkedSpec::CodeblockRuntime::Error', 'standalone typed cause');
                foreach my $key (sort keys %{$case->{error}}) {
                    is_deeply($detail->{$key}, $case->{error}{$key}, "native diagnostic $key");
                    is_deeply($cause->{$key}, $case->{error}{$key}, "standalone diagnostic $key");
                }
            }
        };
    }
};

subtest 'with restores a function binding frame after a callable error' => sub {
    require LinkedSpec::CodeblockRuntime;
    my $invoke = \&LinkedSpec::CodeblockRuntime::invoke;
    my $source = "fn apply(value) { return(with() { return(value()) }) }\n"
        . "Top: /x/\n I { cb = {|| return(\"outer\") }; return(apply(cb)) }\n";
    foreach my $route (qw(native generated)) {
        my ($frame, $during, $error, $output);
        {
            open my $capture, '>', \$output or die "Capture diagnostic output: $!";
            local *STDOUT = $capture;
            no warnings 'redefine';
            local *LinkedSpec::CodeblockRuntime::invoke = sub {
                if (defined($_[3]) && $_[3] eq 'value') {
                    $frame = $_[2];
                    my $binding = $frame->{value};
                    $during = $$binding;
                }
                return $invoke->(@_);
            };
            my $input = 'x';
            if ($route eq 'native') {
                my %context;
                my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
                $parser->(\$input);
                $error = $context{last_error}{detail};
            } else {
                my $emitted = LinkedSpec::emit_generated_source(\$source);
                eval "package ScopedWithErrorRestoration; $emitted; 1" or die $@;
                eval { ScopedWithErrorRestoration::Execute(\$input); 1 };
                my $envelope = $@;
                $error = ref($envelope) eq 'HASH' ? $envelope->{detail} : $envelope;
            }
        }
        isa_ok($error, 'LinkedSpec::CodeblockRuntime::Error', "$route typed failure");
        is($error->{code}, 'value_not_callable', "$route scoped null fails as a bound value");
        ok(ref($frame) eq 'HASH', "$route observes the real invocation binding frame");
        is($during, undef, "$route frame exposes the inner null during invocation");
        my $restored = $frame->{value};
        is($invoke->($$restored, [], {}, 'restored', undef, {}), 'outer',
            "$route frame restores its outer callable after error unwinding");
    }
};

subtest 'malformed fluent members preserve typed invocation errors and records' => sub {
    require LinkedSpec::CodeblockRuntime;
    my $json = JSON::PP->new->canonical;
    foreach my $bad (undef, 'not-a-call', []) {
        my $record = parse_expr('{|| return(items.sum()) }');
        $record->{body_ast}{statements}[0]{expr}{args}[0]{calls}[0] = $bad;
        my $original = $json->encode($record);
        my $items = [3,1,8];
        my $error;
        eval { LinkedSpec::CodeblockRuntime::invoke($record, [], {items => \$items}, 'malformed'); 1 }
            or $error = $@;
        my $typed = ref($error) eq 'LinkedSpec::CodeblockRuntime::Error';
        ok($typed, 'malformed serialized member reports the public typed error');
        is($typed ? $error->{code} : undef, 'invalid_codeblock_body', 'body error code stays exact');
        is($typed ? $error->{detail} : undef, 'invalid fluent call', 'fluent member detail stays exact');
        is_deeply($items, [3,1,8], 'failed invocation preserves caller values');
        is($json->encode($record), $original, 'validation does not vivify or mutate the record');
    }
};

subtest 'serialized fluent argument fields preserve typed errors and values' => sub {
    require LinkedSpec::CodeblockRuntime;
    my $json = JSON::PP->new->canonical;
    foreach my $method (qw(sorted take sum)) {
        foreach my $kind (qw(null number string hash missing)) {
            my $record = parse_expr('{|| return(items.' . $method . '()) }');
            my $call = $record->{body_ast}{statements}[0]{expr}{args}[0]{calls}[0];
            if ($kind eq 'missing') { delete $call->{args} }
            else { $call->{args} = $kind eq 'null' ? undef : $kind eq 'number' ? 1 : $kind eq 'string' ? 'bad' : {} }
            my $before = $json->encode($record);
            my $items = [3,1,8];
            my $error;
            eval { LinkedSpec::CodeblockRuntime::invoke($record, [], {items => \$items}, 'malformed-args'); 1 }
                or $error = $@;
            my $typed = ref($error) eq 'LinkedSpec::CodeblockRuntime::Error';
            ok($typed, "$method/$kind reports a typed invocation error");
            is($typed ? $error->{code} : undef, 'invalid_codeblock_body', 'body error code');
            is($typed ? $error->{detail} : undef, 'fluent arguments must be an array', 'argument error detail');
            is_deeply($items, [3,1,8], 'caller values remain unchanged');
            is($json->encode($record), $before, 'record remains unchanged');
        }
    }
};

subtest 'indexed writes execute through native and independently emitted public parsers' => sub {
    my $path = File::Spec->catfile($repo_root, 'tests', 'numeric-codeblocks', 'indexed-writes.json');
    open my $fh, '<:raw', $path or die "Could not read $path: $!";
    my $plan = JSON::PP->new->utf8->decode(do { local $/; <$fh> });
    close $fh or die "Could not close $path: $!";
    my $json = JSON::PP->new->canonical->allow_nonref;
    my $index = 0;
    for my $case (@{$plan->{cases}}) {
        subtest $case->{id} => sub {
            my $source = $case->{source} // ($case->{functions} // '') . "Top: /x/\n I { $case->{body} }\n";
            my (%context, $native, $output, $failure);
            {
                open my $capture, '>', \$output or die "Capture diagnostic output: $!";
                local *STDOUT = $capture;
                eval {
                    my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
                    die "No parser" unless ref($parser) eq 'CODE';
                    my $input = 'x';
                    $native = $parser->(\$input);
                    1;
                } or $failure = $@;
            }
            ok(!defined($failure), 'native parser builds and completes its runtime boundary');
            my $generated = eval { LinkedSpec::emit_generated_source(\$source, source_identity => 'indexed-writes.spec') };
            ok(defined($generated) && length($generated), 'independent source emits');
            my $package = 'IndexedWrites' . $index++;
            my $loaded = defined($generated) && eval "package $package; $generated; 1";
            ok($loaded, 'independent source loads');
            return unless $loaded;
            my ($value, $error);
            eval {
                no strict 'refs';
                my $input = 'x';
                $value = &{$package . '::Execute'}(\$input);
                1;
            } or $error = $@;
            if ($case->{error}) {
                my $detail = $context{last_error}{detail};
                is($detail->{code}, $case->{error}, 'native typed code');
                is(ref($detail), $case->{error} eq 'receiver_mutation_reentrant'
                    ? 'LinkedSpec::BindingRuntime::ReceiverMutationError'
                    : 'LinkedSpec::BindingRuntime::NestedWriteError', 'native error class');
                is(ref($error), 'HASH', 'generated execution reports its contract error');
                is(ref($error) eq 'HASH' ? $error->{detail}{code} : undef,
                    $case->{error}, 'generated nested typed code');
            } else {
                ok(!defined($context{last_error}), 'native execution has no runtime error');
                is($json->encode($native), $json->encode($case->{expected}), 'native values and kinds');
                ok(!defined($error), 'generated execution has no runtime error');
                is($json->encode($value), $json->encode($case->{expected}), 'generated values and kinds');
            }
        };
    }
};

subtest 'deferred indexed writes obey the frozen vivification cases' => sub {
    require LinkedSpec::BindingRuntime;
    my $path = File::Spec->catfile($repo_root, 'capability_conformance', 'write_vivification_contract.json');
    open my $fh, '<:raw', $path or die "Could not read $path: $!";
    my $fixture = JSON::PP->new->utf8->decode(do { local $/; <$fh> });
    close $fh or die "Could not close $path: $!";
    my $json = JSON::PP->new->canonical->allow_nonref;
    my $clone = sub { $json->decode($json->encode($_[0])) };
    for my $case (@{$fixture->{success_cases}}, @{$fixture->{failure_cases}}) {
        subtest $case->{id} => sub {
            my $initial = $case->{initial_binding};
            my $document = $initial->{present} ? $clone->($initial->{value}) : undef;
            my $present = $initial->{present} ? 1 : 0;
            my ($rhs, $key_name, $position) = ('value', 'key', 0);
            my ($segment) = map { $_->{value} } grep { $_->{source} eq 'segment' } @{$case->{segments}};
            $segment = parse_expr('{|| return(1) }')
                if grep { ($_->{kind} // '') eq 'codeblock' } @{$case->{segments}};
            my $mutate_value = parse_expr($case->{id} eq 'rhs_side_effect_survives_outer_gap'
                ? '{|| document[0] = "rhs"; return("done") }'
                : '{|| document["audit"][0] = "rhs"; return("done") }');
            my $mutate_key = parse_expr('{|| document = {"seed":1}; return("value") }');
            my $record = parse_expr('{|| ' . $case->{source} . ' }');
            my $before = $json->encode($record);
            my ($result, $error);
            eval {
                $result = LinkedSpec::CodeblockRuntime::invoke($record, [], {
                    document => \$document, rhs => \$rhs, key_name => \$key_name,
                    position => \$position, segment => \$segment,
                    mutate_document_then_value => \$mutate_value,
                    mutate_document_then_key => \$mutate_key,
                }, $case->{id}, undef, {action_source_id => 'contract:' . $case->{id}},
                    {document => \$present});
                1;
            } or $error = $@;
            if (my $expected = $case->{expected_error}) {
                ok(LinkedSpec::BindingRuntime::is_nested_write_error($error), 'structural error retains its class');
                for my $field (qw(code segment_index path actual_kind expected_kind reason index length)) {
                    next unless exists $expected->{$field};
                    is_deeply($error->{$field}, $expected->{$field}, "frozen $field");
                }
                my $index = $expected->{segment_index};
                my $ast = parse_expr($case->{source});
                my $span = $ast->{segments}[$index]{source_span};
                is_deeply($error->{source_span}, {
                    source_id => 'contract:' . $case->{id}, start => $span->{start} + 4,
                    end => $span->{end} + 4, unit => 'unicode_scalar', provenance => 'authored',
                }, 'exact authored span survives deferred dispatch');
                my $state = $case->{expected_binding};
                is_deeply($document, $state->{present} ? $state->{value} : undef,
                    'failure preserves the post-expression root');
                is($present ? 1 : 0, $state->{present} ? 1 : 0, 'failure preserves presence');
            } else {
                ok(!defined($error), 'deferred write succeeds');
                diag($error) if defined $error;
                is_deeply($document, $case->{expected_binding}, 'frozen committed binding');
                is_deeply($result, $case->{expected_result}, 'frozen returned root');
                ok($present, 'success marks the binding present');
                isnt(Scalar::Util::refaddr($result), Scalar::Util::refaddr($document),
                    'returned and committed roots are detached');
            }
            is($json->encode($record), $before, 'execution preserves the callable record');
        };
    }
    for my $case (@{$fixture->{evaluation_failure_cases}}) {
        subtest $case->{id} => sub {
            my $document = {};
            my (@effects, $failure);
            my %functions;
            my @operands = (@{$case->{segments}}, $case->{rhs});
            for my $index (0 .. $#operands) {
                my $operand = $operands[$index];
                my ($name) = $operand->{source} =~ /\A(\w+)\(\)\z/;
                my $label = $index == $#operands ? 'rhs' : "segment:$index";
                my $error = $operand->{evaluation_error};
                my $exception = $error ? bless({%$error}, 'DeferredWriteFixtureError') : undef;
                $failure = $exception if $error;
                $functions{$name} = {
                    signature => { positional_params => [], min_arity => 0, max_arity => 0 },
                    call => sub {
                        push @effects, $label;
                        die $exception if $error;
                        return $operand->{value};
                    },
                };
            }
            my $record = parse_expr('{|| ' . $case->{source} . ' }');
            my $error;
            eval { LinkedSpec::CodeblockRuntime::invoke($record, [], {document => \$document},
                $case->{id}, undef, {registered_functions => \%functions}); 1 } or $error = $@;
            is(Scalar::Util::refaddr($error), Scalar::Util::refaddr($failure), 'expression failure keeps identity');
            is_deeply(\@effects, $case->{expected_effects}, 'later operands never execute after failure');
            is_deeply($document, {}, 'expression failure publishes no path');
        };
    }
};

subtest 'deferred writes guard the resolved receiver before operand effects' => sub {
    my $tree = {a => 'A'};
    my $seen = '';
    my $key = parse_expr('{|| seen = cat(seen,"k"); return("z") }');
    my $rhs = parse_expr('{|| seen = cat(seen,"r"); return(2) }');
    my $record = parse_expr('{|| tree[key()] = rhs() }');
    my $error;
    eval {
        LinkedSpec::BindingRuntime::map_leaves_mutation(\$tree, 1, 'tree',
            {source_id => 'guard', start => 0, end => 4, unit => 'unicode_scalar', provenance => 'authored'},
            sub { LinkedSpec::CodeblockRuntime::invoke($record, [], {
                tree => \$tree, seen => \$seen, key => \$key, rhs => \$rhs,
            }, 'guarded-write') });
        1;
    } or $error = $@;
    ok(LinkedSpec::BindingRuntime::is_receiver_mutation_error($error), 'resolved receiver guard retains its class');
    is($error->{code}, 'receiver_mutation_reentrant', 'receiver guard wins before path validation');
    is($seen, '', 'neither the segment nor RHS executes');
    is_deeply($tree, {a => 'A'}, 'the original receiver remains unchanged');
};

subtest 'deferred write validation and parameter presence restore without effects' => sub {
    my @corruptions = (
        sub { delete $_[0]{base} },
        sub { $_[0]{base} = [] },
        sub { $_[0]{segments} = undef },
        sub { $_[0]{segments} = [] },
        sub { $_[0]{segments}[0] = 'bad' },
        sub { $_[0]{segments}[0]{kind} = 'index' },
        sub { delete $_[0]{segments}[0]{expression} },
        sub { $_[0]{segments}[0]{expression} = [] },
        sub { $_[0]{segments}[1]{expression} = {} },
        sub { $_[0]{segments}[0]{expression}{kind} = [] },
        sub { delete $_[0]{segments}[0]{source_span} },
        sub { $_[0]{segments}[0]{source_span}{start} = -1 },
        sub { $_[0]{segments}[0]{source_span}{end} = 0 },
        sub { delete $_[0]{value} },
        sub { $_[0]{value} = 'bad' },
        sub { $_[0]{value} = {} },
    );
    my $json = JSON::PP->new->canonical;
    for my $corrupt (@corruptions) {
        my $record = parse_expr('{|| document[key()][key()] = rhs() }');
        $corrupt->($record->{body_ast}{statements}[0]{expr});
        my $before = $json->encode($record);
        my ($document, $seen) = ({a => 'A'}, '');
        my $key = parse_expr('{|| seen = "key"; return("x") }');
        my $rhs = parse_expr('{|| seen = "rhs"; return(2) }');
        my $error;
        eval { LinkedSpec::CodeblockRuntime::invoke($record, [], {
            document => \$document, seen => \$seen, key => \$key, rhs => \$rhs,
        }, 'malformed-write'); 1 } or $error = $@;
        isa_ok($error, 'LinkedSpec::CodeblockRuntime::Error');
        is($error->{code}, 'invalid_codeblock_body', 'malformed carrier has a typed error');
        is($seen, '', 'validation precedes segment and RHS effects');
        is_deeply($document, {a => 'A'}, 'validation preserves caller data');
        is($json->encode($record), $before, 'validation preserves serialized data');
    }
    for my $parameter (undef, {}) {
        my $record = parse_expr('{|document| document["x"] = 1; return(document) }');
        my $document;
        my $flag = 0;
        my $slot = \$document;
        my $flag_slot = \$flag;
        my $bindings = {document => $slot};
        my $presence = {document => $flag_slot};
        my ($result, $error);
        eval { $result = LinkedSpec::CodeblockRuntime::invoke($record, [$parameter], $bindings,
            'parameter-presence', undef, {}, $presence); 1 } or $error = $@;
        if (defined $parameter) {
            ok(!defined($error), 'independent parameter write succeeds');
            is_deeply($result, {x => 1}, 'parameter receives its own written value');
            is_deeply($parameter, {}, 'argument stays detached');
        } else {
            ok(LinkedSpec::BindingRuntime::is_nested_write_error($error), 'null parameter remains bound');
            is($error->{actual_kind}, 'null', 'null parameter is never vivified');
        }
        is(Scalar::Util::refaddr($bindings->{document}), Scalar::Util::refaddr($slot), 'caller slot restores');
        is(Scalar::Util::refaddr($presence->{document}), Scalar::Util::refaddr($flag_slot), 'presence slot restores');
        is($flag, 0, 'caller absence survives success or failure');
        ok(!defined($document), 'caller value survives success or failure');
    }
};

sub deferred_literal_flags {
    my ($value) = @_;
    return {kind => 'null'} unless defined $value;
    return {kind => 'boolean'} if JSON::PP::is_bool($value);
    return {kind => 'array', items => [map { deferred_literal_flags($_) } @$value]}
        if ref($value) eq 'ARRAY';
    return {kind => 'harray', entries => {map { $_ => deferred_literal_flags($value->{$_}) } keys %$value}}
        if ref($value) eq 'HASH';
    return {kind => ref($value)} if ref($value);
    my $bits = B::svref_2object(\$value)->FLAGS;
    # Compare public value kinds, allowing harmless additional conversion caches.
    my @valid = map { ($bits & $_) ? 1 : 0 } (B::SVf_IOK(), B::SVf_NOK(), B::SVf_POK());
    my @flags = $valid[2] ? (0,0,1) : $valid[0] ? (1,0,0) : $valid[1] ? (0,1,0) : (0,0,0);
    # Compare numeric zero by value; hexadecimal payloads distinguish nonzero precision.
    return {kind => 'scalar', flags => \@flags,
        ($flags[0] || $flags[1]) && !$flags[2]
            ? (numeric_payload => $value == 0 ? 'zero' : sprintf('%a', $value)) : ()};
}

sub deferred_literal_storage {
    my ($value) = @_;
    return {kind => 'null'} unless defined $value;
    return {kind => 'boolean'} if JSON::PP::is_bool($value);
    return {kind => 'array', items => [map { deferred_literal_storage($_) } @$value]}
        if ref($value) eq 'ARRAY';
    return {kind => 'harray', entries => {map { $_ => deferred_literal_storage($value->{$_}) } keys %$value}}
        if ref($value) eq 'HASH';
    return {kind => ref($value)} if ref($value);
    my $bits = B::svref_2object(\$value)->FLAGS;
    return {public => [map { ($bits & $_) ? 1 : 0 } (B::SVf_IOK(), B::SVf_NOK(), B::SVf_POK())],
        private => [map { ($bits & $_) ? 1 : 0 } (B::SVp_IOK(), B::SVp_NOK(), B::SVp_POK())]};
}

subtest 'deferred primitive literals retain kinds and numeric payloads on public routes' => sub {
    my @cases = (
        ['negative_whole_float', 'cb={|| return(-1.0) }; return(cb())', -1.0],
        ['positive_whole_float', 'cb={|| return(1.0) }; return(cb())', 1.0],
        ['positive_float_zero', 'cb={|| return(0.0) }; return(cb())', 0.0],
        ['negative_float_zero', 'cb={|| return(-0.0) }; return(cb())', -0.0],
        ['fractional_float', 'cb={|| return(-1.25) }; return(cb())', -1.25],
        ['large_whole_float', 'cb={|| return(9007199254740992.0) }; return(cb())', 9007199254740992.0],
        ['rounded_whole_float', 'cb={|| return(9007199254740993.0) }; return(cb())', 9007199254740993.0],
        ['large_fractional_value', 'cb={|| return(1000000000000000.5) }; return(cb())', 1000000000000000.5],
        ['visible_fractional_difference', 'cb={|| return(num_sub(1000000000000000.5,1000000000000000)) }; return(cb())', 0.5],
        ['negative_fractional_difference', 'cb={|| return(num_sub(-1000000000000000.5,-1000000000000000)) }; return(cb())', -0.5],
        ['integer_control', 'cb={|| return(-1) }; return(cb())', -1],
        ['large_integer_control', 'cb={|| return(9007199254740993) }; return(cb())', 9007199254740993],
        ['literal_true', 'cb={|| return(true) }; return(cb())', JSON::PP::true],
        ['literal_false', 'cb={|| return(false) }; return(cb())', JSON::PP::false],
        ['assigned_literals', 'cb={|| flag=false; index=-1.0; return([flag,index]) }; return(cb())',
            [JSON::PP::false, -1.0]],
        ['nested_literals', 'cb={|| return({"values":[false,true,-1.0,0.0,1.25,-1,0,undef,"false","0"]}) }; return(cb())',
            {values => [JSON::PP::false, JSON::PP::true, -1.0, 0.0, 1.25, -1, 0, undef, 'false', '0']}],
        ['fixed_forwarding', 'relay={|value| return(value) }; cb={|| return(relay(false)) }; return(cb())', JSON::PP::false],
        ['rest_forwarding', 'relay={|...values| return(values) }; cb={|| return(relay(false,-1.0,true,0.0)) }; return(cb())',
            [JSON::PP::false, -1.0, JSON::PP::true, 0.0]],
        ['copied_argument', 'edit={|value| value[0]=true; return(value) }; cb={|| original=[false,-1.0]; edited=edit(original); return([original,edited]) }; return(cb())',
            [[JSON::PP::false, -1.0], [JSON::PP::true, -1.0]]],
        ['registered_forwarding', 'cb={|| return(reflect(false)) }; return(cb())', JSON::PP::false,
            'fn reflect(value) { return(value) }'],
        ['registered_rest', 'cb={|| return(collect(false,-1.0)) }; return(cb())', [JSON::PP::false, -1.0],
            'fn collect(...values) { return(values) }'],
        ['contextual_attached', 'return(apply(7) { return(false) })', JSON::PP::false,
            'fn apply(value, callback: codeblock) { return(callback()) }'],
        ['contextual_parenthesized', 'return(apply(7,{ return(true) }))', JSON::PP::true,
            'fn apply(value, callback: codeblock) { return(callback()) }'],
        ['numeric_boolean_rejection', 'cb={|| return([num_add(true,1),num_add(false,1),num_eq(1,1)]) }; return(cb())',
            [undef, undef, 1]],
        ['logical_boolean_results', 'cb={|| return([and(true,false),or(false,true),not(false),not("0")]) }; return(cb())',
            [JSON::PP::false, JSON::PP::true, JSON::PP::true, JSON::PP::false]],
        ['false_text', 'cb={|| return(cat(false,"q")) }; return(cb())', '0q'],
        ['string_and_null_controls', 'cb={|| return(["-1","1.0","false","0",undef]) }; return(cb())',
            ['-1', '1.0', 'false', '0', undef]],
        ['negative_float_selector', 'items=[10,20,30]; cb={|| index=-1.0; return([items[index],index]) }; return(cb())',
            [undef, -1.0]],
        ['compiled_float_argument', 'items=[10,20,30]; cb={|index| return([items[index],index]) }; return(cb(-1.0))',
            [undef, -1.0]],
        ['literal_float_selector_control', 'items=[10,20,30]; cb={|| return(items[-1.0]) }; return(cb())', undef],
        ['negative_integer_selector_control', 'items=[10,20,30]; cb={|| index=-1; return([items[index],index]) }; return(cb())',
            [30, -1]],
        ['positive_float_read_compatibility', 'items=[10,20,30]; cb={|| index=1.0; return([items[index],index]) }; return(cb())',
            [20, 1.0]],
        ['compiled_boolean_argument', 'cb={|value| return(value) }; return(cb(false))', JSON::PP::false],
        ['direct_precision_control', 'return(1000000000000000.5)', 1000000000000000.5],
        ['direct_boolean_control', 'return(false)', JSON::PP::false],
        ['computed_fractional_selector', 'items=[10,20,30]; cb={|| index=num_sub(-1.5,-1); return([index,items[index]]) }; return(cb())',
            [-0.5, undef]],
        ['compiled_fractional_argument', 'items=[10,20,30]; cb={|index| return([index,items[index]]) }; return(cb(num_sub(-1.5,-1)))',
            [-0.5, undef]],
    );
    my $serial = 0;
    my $json = JSON::PP->new->canonical->allow_nonref;
    for my $case (@cases) {
        my ($id, $body, $expected, $definitions) = @$case;
        subtest $id => sub {
            my $source = ($definitions // '') . "\nTop: /x/\n I { $body }\n";
            my $expected_flags = deferred_literal_flags($expected);
            for my $route (qw(native generated)) {
                my (%context, @warnings, $value, $dump, $emitted, $output, $exception);
                my $completed;
                {
                    open my $capture, '>', \$output or die "Capture literal output: $!";
                    local *STDOUT = $capture;
                    local $SIG{__WARN__} = sub { push @warnings, @_ };
                    $completed = eval {
                        if ($route eq 'native') {
                            my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context,
                                dump_parser_source => 1, parser_source_ref => \$dump);
                            die 'Native literal parser did not build' unless ref($parser) eq 'CODE';
                            my $input = 'x';
                            $value = $parser->(\$input);
                        } else {
                            $emitted = LinkedSpec::emit_generated_source(\$source,
                                source_identity => 'deferred-literal-kinds.spec');
                            my $package = 'DeferredLiteralKindsGenerated' . $serial++;
                            eval "package $package; $emitted; 1" or die $@;
                            my $input = 'x';
                            no strict 'refs';
                            $value = &{"${package}::Execute"}(\$input);
                        }
                        1;
                    };
                    $exception = $@ unless $completed;
                }
                my $raw_storage = deferred_literal_storage($value);
                my $actual_flags = deferred_literal_flags($value);
                ok($completed, "$route execution completes");
                diag("$exception") if defined $exception;
                ok(!defined($context{last_error}), "$route has no runtime error");
                is_deeply(\@warnings, [], "$route is warning-free");
                is($output // '', '', "$route is quiet");
                is_deeply($actual_flags, $expected_flags, "$route retains pre-serialization kinds and exact numeric payloads");
                is_deeply($value, $expected, "$route retains values");
                if ($ENV{LINKEDSPEC_LITERAL_KIND_OBSERVE}) {
                    note('LITERAL_KIND_OBSERVATION ' . $json->encode({id => $id, route => $route,
                        instrument => 'public-validity-v2', raw_storage => $raw_storage,
                        source => $source, completed => $completed ? JSON::PP::true : JSON::PP::false,
                        flags => $actual_flags, expected_flags => $expected_flags, value => $value,
                        expected => $expected, warnings => \@warnings, stdout => $output // '',
                        exception => defined($exception) ? "$exception" : undef,
                        runtime_error => defined($context{last_error}) ? "$context{last_error}" : undef,
                        codeblock_runtime => $INC{'LinkedSpec/CodeblockRuntime.pm'},
                        defined($dump) ? (dump => $dump) : (), defined($emitted) ? (emitted => $emitted) : ()}));
                }
            }
        };
    }
};

subtest 'assigned literal kinds reject writes after RHS effects without changing the receiver' => sub {
    for my $case (
        ['false', JSON::PP::false, 'boolean', 'kind_not_path_selector'],
        ['true', JSON::PP::true, 'boolean', 'kind_not_path_selector'],
        ['1.0', 1.0, 'number', 'fractional_number'],
        ['-1.0', -1.0, 'number', 'fractional_number'],
        ['0.0', 0.0, 'number', 'fractional_number'],
    ) {
        my ($literal, $expected, $kind, $reason) = @$case;
        my ($items, $chosen, $seen) = ([10,20,30], undef, '');
        my $initial_identity = Scalar::Util::refaddr($items);
        my $rhs = parse_expr('{|| seen=cat(seen,"r"); return(99) }');
        my $record = parse_expr('{|| chosen=' . $literal . '; items[chosen]=rhs() }');
        my $expected_flags = deferred_literal_flags($expected);
        my $error;
        eval { LinkedSpec::CodeblockRuntime::invoke($record, [], {
            items => \$items, chosen => \$chosen, seen => \$seen, rhs => \$rhs,
        }, 'literal-write'); 1 } or $error = $@;
        my $actual_flags = deferred_literal_flags($chosen);
        ok(LinkedSpec::BindingRuntime::is_nested_write_error($error), "$literal reports a typed selector failure");
        my $fields = (Scalar::Util::reftype($error) // '') eq 'HASH' ? {%$error} : {};
        is($fields->{code}, 'nested_write_segment_invalid', "$literal has the invalid-segment diagnostic");
        is($fields->{actual_kind}, $kind, "$literal retains its selector kind");
        is($fields->{reason}, $reason, "$literal retains its invalid-kind reason");
        is_deeply($actual_flags, $expected_flags, "$literal assignment retains its scalar kind");
        is($seen, 'r', "$literal RHS runs exactly once before kind validation");
        is_deeply($items, [10,20,30], "$literal preserves receiver values on failure");
        is(Scalar::Util::refaddr($items), $initial_identity, "$literal preserves receiver identity on failure");
    }
};

subtest 'source-less and nonliteral numeric records retain their payload fallback' => sub {
    for my $source (undef, '', '.5', '1e3', '+1', '0x10', '1_0', '1.0; die "bad"', {}) {
        my $record = parse_expr('{|| return(7) }');
        my $number = $record->{body_ast}{statements}[0]{expr}{args}[0];
        $number->{value} = 7;
        if (defined $source) {
            $number->{source} = $source;
        } else {
            delete $number->{source};
        }
        my (@warnings, $value, $error);
        {
            local $SIG{__WARN__} = sub { push @warnings, @_ };
            eval { $value = LinkedSpec::CodeblockRuntime::invoke($record, [], {}, 'number-fallback'); 1 }
                or $error = $@;
        }
        ok(!defined($error), 'legacy numeric record still executes');
        is_deeply(\@warnings, [], 'source fallback is warning-free');
        is($value, 7, 'unsupported or absent source keeps its prior numeric payload');
    }
};

subtest 'typed container copying preserves scalar kinds, aliases and cycles' => sub {
    my $leaf = [-1.0];
    my $input = [$leaf, $leaf];
    push @$input, $input;
    my $before = deferred_literal_flags($leaf->[0]);
    my $copy = LinkedSpec::CodeblockRuntime::_copy_value($input);
    isnt(Scalar::Util::refaddr($copy), Scalar::Util::refaddr($input), 'copied root is independent');
    isnt(Scalar::Util::refaddr($copy->[0]), Scalar::Util::refaddr($leaf), 'copied child is independent');
    is(Scalar::Util::refaddr($copy->[0]), Scalar::Util::refaddr($copy->[1]), 'internal alias is preserved');
    is(Scalar::Util::refaddr($copy->[2]), Scalar::Util::refaddr($copy), 'internal cycle is preserved');
    is_deeply(deferred_literal_flags($leaf->[0]), $before, 'copying preserves the source scalar kind');
    is_deeply(deferred_literal_flags($copy->[0][0]), $before, 'copying preserves the destination scalar kind');
    $copy->[0][0] = 5;
    is($copy->[1][0], 5, 'copied aliases share their independent child');
    is($leaf->[0], -1.0, 'copied mutation preserves the original');
    pop @$input;
    pop @$copy;
    my $scalar = 7;
    my $opaque = bless \$scalar, 'LinkedSpec::LiteralOpaqueControl';
    my $opaque_copy = LinkedSpec::CodeblockRuntime::_copy_value($opaque);
    isa_ok($opaque_copy, 'LinkedSpec::LiteralOpaqueControl');
    isnt(Scalar::Util::refaddr($opaque_copy), Scalar::Util::refaddr($opaque), 'opaque fallback remains detached');
    $$opaque_copy = 8;
    is($$opaque, 7, 'opaque fallback preserves its source');
};

subtest 'lossy integer caches cannot promote fractional selectors' => sub {
    my $carrier = [-0.5];
    my $unused = Storable::dclone($carrier);
    my $index = $carrier->[0];
    is(LinkedSpec::BindingRuntime::_runtime_kind($index), 'number', 'fraction retains numeric kind after caching');
    ok(!defined(LinkedSpec::CodeblockRuntime::_read_array_entry([10,20,30], $index)),
        'fractional negative read stays outside the integer extension');
    my $error;
    eval { LinkedSpec::BindingRuntime::nested_write([10,20,30], 1, 'items', [
        {value => $index, kind_hint => 'dynamic', source_span => {source_id => 'cache-control',
            start => 0, end => 1, unit => 'unicode_scalar', provenance => 'authored'}},
    ], 99); 1 } or $error = $@;
    ok(LinkedSpec::BindingRuntime::is_nested_write_error($error), 'fractional write has a typed error');
    my $fields = (Scalar::Util::reftype($error) // '') eq 'HASH' ? {%$error} : {};
    is($fields->{actual_kind}, 'number', 'fractional write reports its valid numeric kind');
    is($fields->{reason}, 'fractional_number', 'fractional write reports the numeric exclusion');
};

subtest 'deferred last focused contract' => sub {
    do File::Spec->catfile($repo_root, 't', 'deferred_last_contract.t') or die $@ || $!;
};

subtest 'deferred with focused contract' => sub {
    do File::Spec->catfile($repo_root, 't', 'deferred_with_contract.t') or die $@ || $!;
};

subtest 'ordinary grouped assignment focused contract' => sub {
    do File::Spec->catfile($repo_root, 't', 'grouped_assignment_value_contract.t') or die $@ || $!;
};

subtest 'ordinary filter_match value contract' => sub {
    do File::Spec->catfile($repo_root, 't', 'filter_match_value_contract.t') or die $@ || $!;
};

done_testing();
