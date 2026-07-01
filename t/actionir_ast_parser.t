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

subtest 'parser seam is incremental' => sub {
    my $lowered = LinkedSpec::call_spec_handler_subst('Top', 'return(3.5.floor().add(1))');
    like($lowered, qr/__ls_num_floor.*__ls_num_add/s, 'receiver-chain lowering remains on the compatibility path until the fluent-chain leaf');
};

done_testing();
