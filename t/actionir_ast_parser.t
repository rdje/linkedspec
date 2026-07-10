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
    is($block->{statements}[0]{expr}{name}, 'set', 'set helper name is preserved by MethodExpr');
    is($block->{statements}[0]{expr}{args}[0]{kind}, 'variable', 'bare call argument parses as a variable');
    is($block->{statements}[0]{expr}{args}[1]{kind}, 'string', 'quoted call argument parses as a string');
    is($block->{statements}[0]{expr}{args}[1]{value}, 'a', 'string payload is captured without delimiters');
    my $single_quoted = parse_expr(q{'"|\s'});
    is($single_quoted->{kind}, 'string', 'single-quoted action argument parses as a string');
    is($single_quoted->{value}, q{"|\s}, 'single-quoted action argument preserves regex escapes');
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

    my $nested = parse_expr('foo["a"][0][z]');
    is($nested->{kind}, 'nested_access', 'mixed direct access parses as nested_access');
    is($nested->{base}, 'foo', 'nested_access base is captured');
    is_deeply([map { $_->{kind} } @{$nested->{segments}}], ['key', 'index', 'index'], 'segment kinds preserve key/index roles');
    is($nested->{segments}[0]{value}, 'a', 'quoted segment becomes a key');
    is($nested->{segments}[2]{expr}{kind}, 'variable', 'bare segment payload parses as a variable expression');
    is($nested->{segments}[2]{expr}{name}, 'z', 'bare segment variable name is captured');
};

subtest 'shape literals and expression-valued blocks' => sub {
    my $array = parse_expr('[value, true, []]');
    is($array->{kind}, 'array_literal', 'array shape literal parses');
    is_deeply([map { $_->{kind} } @{$array->{items}}], ['variable', 'boolean', 'array_literal'], 'array literal items are typed expressions');

    my $hash = parse_expr('{ key : value, "fixed" : [value] }');
    is($hash->{kind}, 'hash_literal', 'hash shape literal parses');
    is(scalar(@{$hash->{entries}}), 2, 'hash literal entries are captured');
    is($hash->{entries}[0]{key}{kind}, 'variable', 'bare hash key is an expression');
    is($hash->{entries}[1]{key}{kind}, 'string', 'quoted hash key is a string expression');
    is($hash->{entries}[1]{value}{kind}, 'array_literal', 'hash value can be a nested shape literal');

    my $colon_hash = parse_expr('{ key : value, "fixed" : [value], outer : { "nested" : value } }');
    is($colon_hash->{kind}, 'hash_literal', 'colon hash shape literal parses');
    is(scalar(@{$colon_hash->{entries}}), 3, 'colon hash literal entries are captured');
    is($colon_hash->{entries}[1]{value}{kind}, 'array_literal', 'colon hash value can be a nested array shape literal');
    is($colon_hash->{entries}[2]{value}{kind}, 'hash_literal', 'colon hash value can be a nested hash shape literal');

    my $retired_hash = parse_expr('{ old => value, current : value }');
    is($retired_hash->{kind}, 'hash_literal_fat_arrow_removed', 'old hash-literal fat-arrow separator is retired');
    is($retired_hash->{reason}, 'hash_literal_use_colon', 'retired hash-literal diagnostic points to colon association');

    my $double_colon_block = parse_expr('{ JSON::PP }');
    is($double_colon_block->{kind}, 'block_value', 'double-colon payload does not trigger colon hash parsing');

    my $block = parse_expr('{ set(x,"a"); x }');
    is($block->{kind}, 'block_value', 'non-empty non-hash-pair braces parse as a block value');
    is(scalar(@{$block->{block}{statements}}), 2, 'block value owns nested statements');
    is($block->{block}{statements}[0]{expr}{name}, 'set', 'block statement calls use the same method parser seam');
    is($block->{block}{statements}[1]{expr}{kind}, 'variable', 'block final expression parses as a variable');
};

subtest 'trailing block call arguments' => sub {
    my $with = parse_expr('with("x") { return(cat(value,"!")) }');
    is($with->{kind}, 'call', 'with(...) trailing block parses as a call');
    is($with->{name}, 'with', 'trailing block call keeps the source callee');
    ok($with->{trailing_block_arg}, 'trailing block call is explicitly flagged');
    is(scalar(@{$with->{args}}), 2, 'explicit value plus trailing block become two call arguments');
    is($with->{args}[0]{kind}, 'string', 'explicit with value parses as the first argument');
    is($with->{args}[1]{kind}, 'block_value', 'trailing body parses as the final block_value argument');
    is($with->{args}[1]{source}, '{ return(cat(value,"!")) }', 'block argument preserves its brace source');
    is($with->{args}[1]{block}{statements}[0]{expr}{name}, 'return', 'block argument owns parsed block statements');

    my $zero = parse_expr('with() { return(is_undefined(value)) }');
    ok($zero->{trailing_block_arg}, 'zero-argument with() trailing block is flagged');
    is(scalar(@{$zero->{args}}), 1, 'zero-argument with() carries only the final block argument');
    is($zero->{args}[0]{kind}, 'block_value', 'zero-argument with() block is the final argument');

    my $receiver = parse_expr('"x".with() { return(cat(value,"!")) }.trim()');
    is($receiver->{kind}, 'fluent_chain', 'receiver .with() trailing block parses as a fluent chain');
    is_deeply([map { $_->{method} } @{$receiver->{calls}}], ['with', 'trim'], 'receiver .with() preserves later fluent calls');
    ok($receiver->{calls}[0]{receiver_trailing_block_arg}, 'receiver .with() segment is explicitly flagged');
    is(scalar(@{$receiver->{calls}[0]{args}}), 1, 'receiver .with() carries only the trailing block argument');
    is($receiver->{calls}[0]{args}[0]{kind}, 'block_value', 'receiver .with() block is the final argument');

    my $hash_tree = parse_expr('meta.map_leaves() { return(cat(path.join_values("."), "=", value)) }.count_keys()');
    is($hash_tree->{kind}, 'fluent_chain', 'hash-tree receiver trailing block parses as a fluent chain');
    is_deeply([map { $_->{method} } @{$hash_tree->{calls}}], ['map_leaves', 'count_keys'],
        'hash-tree receiver trailing block preserves later fluent calls');
    ok($hash_tree->{calls}[0]{receiver_trailing_block_arg},
        'hash-tree receiver trailing block segment is explicitly flagged');
    is(scalar(@{$hash_tree->{calls}[0]{args}}), 1,
        'map_leaves() carries only the trailing block argument');
    is($hash_tree->{calls}[0]{args}[0]{kind}, 'block_value',
        'map_leaves() block is the final argument');

    my $array_tree = parse_expr('items.map_leaves() { return(cat(index, "=", value)) }.count()');
    is($array_tree->{kind}, 'fluent_chain', 'array-tree receiver trailing block parses as the same fluent chain shape');
    is_deeply([map { $_->{method} } @{$array_tree->{calls}}], ['map_leaves', 'count'],
        'array-tree receiver trailing block preserves later array-family fluent calls');
    ok($array_tree->{calls}[0]{receiver_trailing_block_arg},
        'array-tree receiver trailing block segment is explicitly flagged');
    is(scalar(@{$array_tree->{calls}[0]{args}}), 1,
        'array-tree map_leaves() carries only the trailing block argument');
    is($array_tree->{calls}[0]{args}[0]{kind}, 'block_value',
        'array-tree map_leaves() block is the final argument');

    my $reducer = parse_expr('meta.reduce_leaves("") { return(cat(acc,value)) }');
    ok($reducer->{calls}[0]{receiver_trailing_block_arg}, 'reduce_leaves(...) trailing block is flagged');
    is(scalar(@{$reducer->{calls}[0]{args}}), 2,
        'reduce_leaves(initial) carries initial value plus block argument');
    is($reducer->{calls}[0]{args}[1]{kind}, 'block_value',
        'reduce_leaves block is the final argument');

    my $unknown = parse_expr('unknown("x") { return(value) }');
    ok($unknown->{trailing_block_arg}, 'unknown trailing-block callees still parse for lowering diagnostics');
};

subtest 'assignment and mutation statement nodes' => sub {
    my $scalar = parse_expr('name = [value]');
    is($scalar->{kind}, 'assign_scalar', 'bare assignment parses as assign_scalar');
    is($scalar->{value}{kind}, 'array_literal', 'assign_scalar RHS is a parsed expression');

    my $append = parse_expr('items += value');
    is($append->{kind}, 'assign_array_append', 'array append operator parses as assign_array_append');
    is($append->{name}, 'items', 'array append target name is captured');
    is($append->{value}{kind}, 'variable', 'array append RHS is parsed');

    my $hash = parse_expr('meta[key] = { key : value }');
    is($hash->{kind}, 'assign_hash_index', 'hash-index assignment parses as assign_hash_index');
    is($hash->{key}{kind}, 'variable', 'hash assignment key is parsed as expression');
    is($hash->{value}{kind}, 'hash_literal', 'hash assignment RHS is parsed as hash literal');

    my $colon_hash = parse_expr('meta[key] = { key : value }');
    is($colon_hash->{kind}, 'assign_hash_index', 'colon hash-index assignment parses as assign_hash_index');
    is($colon_hash->{value}{kind}, 'hash_literal', 'colon hash assignment RHS is parsed as hash literal');

    my $operator_call = parse_expr('=(target, value)');
    is($operator_call->{kind}, 'call', 'single-equals operator spelling parses as a call');
    is($operator_call->{name}, '=', 'single-equals operator call keeps the symbol callee');
    is($operator_call->{args}[0]{kind}, 'variable', 'single-equals operator target is parsed');
    is($operator_call->{args}[1]{kind}, 'variable', 'single-equals operator value is parsed');
};

subtest 'structured control forms parse as typed AST nodes' => sub {
    my $if = parse_expr('if(flag) { set(x,"a") }');
    is($if->{kind}, 'control_if', 'attached if parses as control_if');
    is($if->{keyword}, 'if', 'control_if preserves the source keyword');
    is($if->{canonical_keyword}, 'if', 'control_if carries the canonical keyword');
    is($if->{condition}{kind}, 'variable', 'control_if condition is parsed as an expression');
    is($if->{body}{kind}, 'action_block', 'control_if owns its attached body block');
    is($if->{body}{statements}[0]{expr}{name}, 'set', 'control_if body statements are parsed');

    my $when = parse_expr('when(is_nonempty(array(items)))');
    is($when->{kind}, 'control_if', 'marker when parses through the if-family control node');
    is($when->{keyword}, 'when', 'when preserves its alias keyword');
    is($when->{canonical_keyword}, 'if', 'when canonicalizes to if');
    is($when->{condition}{name}, 'is_nonempty', 'when condition is parsed as a call');

    my $elseif = parse_expr('elseif(has_key(hash(meta),"tag")) { return("tagged") }');
    is($elseif->{kind}, 'control_if', 'attached elseif parses through the if-family control node');
    is($elseif->{branch_role}, 'elseif', 'elseif branch role is explicit');
    is($elseif->{canonical_keyword}, 'elseif', 'elseif keeps its canonical keyword');
    is($elseif->{condition}{name}, 'has_key', 'elseif condition is parsed as a call');
    is($elseif->{body_source}, '{ return("tagged") }', 'elseif preserves its attached body source');

    my $elif = parse_expr('elif(flag)');
    is($elif->{kind}, 'control_if', 'marker elif parses through the if-family control node');
    is($elif->{branch_role}, 'elseif', 'elif branch role is explicit');
    is($elif->{canonical_keyword}, 'elseif', 'elif canonicalizes to elseif');

    my $else = parse_expr('else');
    is($else->{kind}, 'control_else', 'bare else marker parses as control_else');
    is($else->{canonical_keyword}, 'else', 'else carries its canonical keyword');

    my $else_call = parse_expr('else()');
    is($else_call->{kind}, 'control_else', 'parenthesized else marker parses as control_else');

    my $otherwise = parse_expr('otherwise { return("miss") }');
    is($otherwise->{kind}, 'control_else', 'attached otherwise parses as control_else');
    is($otherwise->{keyword}, 'otherwise', 'otherwise preserves its alias keyword');
    is($otherwise->{canonical_keyword}, 'else', 'otherwise canonicalizes to else');
    is($otherwise->{body}{statements}[0]{expr}{name}, 'return', 'otherwise body statements are parsed');

    my $endif = parse_expr('endif');
    is($endif->{kind}, 'control_endif', 'bare endif marker parses as control_endif');
    is($endif->{canonical_keyword}, 'endif', 'endif carries its canonical keyword');

    my $endif_call = parse_expr('endif()');
    is($endif_call->{kind}, 'control_endif', 'parenthesized endif marker parses as control_endif');

    my $switch_marker = parse_expr('switch(kind)');
    is($switch_marker->{kind}, 'control_switch', 'marker switch parses as control_switch');
    is($switch_marker->{source_expr}{kind}, 'variable', 'marker switch source expression is parsed');

    my $switch = parse_expr('switch(kind) { case("a") { return("hit") } default { return("miss") } }');
    is($switch->{kind}, 'control_switch', 'attached switch parses as control_switch');
    is($switch->{source_expr}{kind}, 'variable', 'switch source expression is parsed');
    is(scalar(@{$switch->{cases}}), 1, 'attached switch owns parsed case branches');
    is($switch->{cases}[0]{kind}, 'control_case', 'switch case branch is typed');
    is($switch->{cases}[0]{match}{value}, 'a', 'case match expression is parsed');
    is($switch->{cases}[0]{body}{statements}[0]{expr}{args}[0]{value}, 'hit', 'case body is parsed');
    is($switch->{default}{kind}, 'control_default', 'switch default branch is typed');
    is($switch->{default}{body}{statements}[0]{expr}{args}[0]{value}, 'miss', 'default body is parsed');

    my $case = parse_expr('case(/a/)');
    is($case->{kind}, 'control_case', 'marker case parses as control_case');
    is($case->{match}{kind}, 'regex', 'marker case match payload is parsed as an expression');

    my $default = parse_expr('default');
    is($default->{kind}, 'control_default', 'bare default marker parses as control_default');
    is($default->{canonical_keyword}, 'default', 'default carries its canonical keyword');

    my $default_call = parse_expr('default()');
    is($default_call->{kind}, 'control_default', 'parenthesized default marker parses as control_default');

    my $endcase = parse_expr('endcase');
    is($endcase->{kind}, 'control_endcase', 'bare endcase marker parses as control_endcase');

    my $endcase_call = parse_expr('endcase()');
    is($endcase_call->{kind}, 'control_endcase', 'parenthesized endcase marker parses as control_endcase');

    my $endswitch = parse_expr('endswitch');
    is($endswitch->{kind}, 'control_endswitch', 'bare endswitch marker parses as control_endswitch');

    my $endswitch_call = parse_expr('endswitch()');
    is($endswitch_call->{kind}, 'control_endswitch', 'parenthesized endswitch marker parses as control_endswitch');

    my $while_marker = parse_expr('while(num_lt(count,3))');
    is($while_marker->{kind}, 'control_while', 'marker while parses as control_while');
    is($while_marker->{condition}{name}, 'num_lt', 'marker while condition is parsed as a call');

    my $while = parse_expr('while(num_lt(count,3)) { set(count,num_add(count,1)) }');
    is($while->{kind}, 'control_while', 'attached while parses as control_while');
    is($while->{condition}{name}, 'num_lt', 'while condition is parsed as a call');
    is($while->{body}{statements}[0]{expr}{name}, 'set', 'while body statements are parsed');

    my $inline_if = parse_expr('if(flag, "yes", "no")');
    is($inline_if->{kind}, 'call', 'inline value if remains a generic call');
    is($inline_if->{name}, 'if', 'inline value if keeps its helper name');

    my $inline_switch = parse_expr('switch(kind, case("a","hit"), default("miss"))');
    is($inline_switch->{kind}, 'call', 'inline value switch remains a generic call');
    is($inline_switch->{name}, 'switch', 'inline value switch keeps its helper name');
};

subtest 'if-family control lowering consumes AST nodes' => sub {
    my $parse_calls = 0;
    my $orig_parse_action_expr = \&LinkedSpec::ActionIR::AST::parse_action_expr;
    my $var = sub {
        my ($name) = @_;
        return { kind => 'variable', name => $name, source => '__bad_var_'.$name.'__()' };
    };
    my $call = sub {
        my ($name, @args) = @_;
        return { kind => 'call', name => $name, source => '__bad_call_'.$name.'__()', args => \@args };
    };
    my $stmt = sub {
        my ($expr) = @_;
        return { kind => 'action_stmt', source => '__bad_stmt_source__()', expr => $expr };
    };
    my $block_return = sub {
        my ($name) = @_;
        return {
            kind => 'action_block',
            source => '__bad_block_source__()',
            statements => [$stmt->($call->('return', $var->($name)))],
        };
    };
    my $control_if = sub {
        my ($keyword, $condition, $return_name) = @_;
        my $branch_role = ($keyword eq 'elseif' || $keyword eq 'elif') ? 'elseif' : 'if';
        return {
            kind => 'control_if',
            source => '__bad_control_'.$keyword.'__()',
            keyword => $keyword,
            canonical_keyword => $branch_role eq 'elseif' ? 'elseif' : 'if',
            branch_role => $branch_role,
            condition => $var->($condition),
            body => defined($return_name) ? $block_return->($return_name) : undef,
        };
    };
    my $control_else = sub {
        my ($keyword, $return_name) = @_;
        return {
            kind => 'control_else',
            source => '__bad_control_'.$keyword.'__()',
            keyword => $keyword,
            canonical_keyword => 'else',
            branch_role => 'else',
            body => defined($return_name) ? $block_return->($return_name) : undef,
        };
    };

    {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::AST::parse_action_expr = sub {
            my ($expr, @rest) = @_;
            ++$parse_calls;
            return $control_if->('if', 'safe_if_flag', 'safe_then')
                if $expr eq 'if(poison_if) { poison_then() }';
            return $control_if->('elseif', 'safe_alt_flag', 'safe_alt')
                if $expr eq 'elseif(poison_alt) { poison_alt_body() }';
            return $control_else->('else', 'safe_else')
                if $expr eq 'else { poison_else_body() }';
            return $control_if->('when', 'safe_when_flag', 'safe_when')
                if $expr eq 'when(poison_when) { poison_when_body() }';
            return $control_else->('otherwise', 'safe_otherwise')
                if $expr eq 'otherwise { poison_otherwise_body() }';
            return $control_if->('if', 'safe_marker_flag', undef)
                if $expr eq 'if(poison_marker)';
            return $control_if->('elseif', 'safe_marker_alt_flag', undef)
                if $expr eq 'elseif(poison_marker_alt)';
            return $control_else->('else', undef)
                if $expr eq 'else()';
            return { kind => 'control_endif', source => '__bad_endif__()', keyword => 'endif', canonical_keyword => 'endif', args => [] }
                if $expr eq 'endif()';
            return $call->('return', $var->('safe_marker_then'))
                if $expr eq 'return(poison_marker_then)';
            return $call->('return', $var->('safe_marker_alt'))
                if $expr eq 'return(poison_marker_alt)';
            return $call->('return', $var->('safe_marker_else'))
                if $expr eq 'return(poison_marker_else)';
            return $orig_parse_action_expr->($expr, @rest);
        };

        my $attached = LinkedSpec::call_spec_handler_subst(
            'Top',
            q{if(poison_if) { poison_then() } elseif(poison_alt) { poison_alt_body() } else { poison_else_body() }},
        );
        like($attached, qr/if \(\$safe_if_flag\) \{ return \$safe_then \} elsif \(\$safe_alt_flag\) \{ return \$safe_alt \} else \{ return \$safe_else \}/, 'attached if/elseif/else lowers from AST condition and body fields');

        my $aliases = LinkedSpec::call_spec_handler_subst(
            'Top',
            q{when(poison_when) { poison_when_body() } otherwise { poison_otherwise_body() }},
        );
        like($aliases, qr/if \(\$safe_when_flag\) \{ return \$safe_when \} else \{ return \$safe_otherwise \}/, 'when/otherwise aliases lower from AST condition and body fields');

        my $markers = LinkedSpec::call_spec_handler_subst(
            'Top',
            q{if(poison_marker); return(poison_marker_then); elseif(poison_marker_alt); return(poison_marker_alt); else(); return(poison_marker_else); endif()},
        );
        like($markers, qr/if \(\$safe_marker_flag\) \{; return \$safe_marker_then; \} elsif \(\$safe_marker_alt_flag\) \{; return \$safe_marker_alt; \} else \{; return \$safe_marker_else; \}/, 'marker if/elseif/else/endif lowers from AST condition fields');

        my $all = join("\n", $attached, $aliases, $markers);
        unlike($all, qr/poison|__bad_/, 'if-family control lowering does not reuse original text or AST source fields');
    }

    ok($parse_calls >= 9, 'if-family control lowering entered through the AST parser');
};

subtest 'switch control lowering consumes AST nodes' => sub {
    my $parse_calls = 0;
    my $orig_parse_action_expr = \&LinkedSpec::ActionIR::AST::parse_action_expr;
    my $var = sub {
        my ($name) = @_;
        return { kind => 'variable', name => $name, source => '__bad_var_'.$name.'__()' };
    };
    my $string = sub {
        my ($value) = @_;
        return { kind => 'string', value => $value, quote => '"', source => '__bad_string_'.$value.'__()' };
    };
    my $call = sub {
        my ($name, @args) = @_;
        return { kind => 'call', name => $name, source => '__bad_call_'.$name.'__()', args => \@args };
    };
    my $stmt = sub {
        my ($expr) = @_;
        return { kind => 'action_stmt', source => '__bad_stmt_source__()', expr => $expr };
    };
    my $block_return = sub {
        my ($name) = @_;
        return {
            kind => 'action_block',
            source => '__bad_block_source__()',
            statements => [$stmt->($call->('return', $var->($name)))],
        };
    };
    my $control_case = sub {
        my ($match, $return_name) = @_;
        my %node = (
            kind => 'control_case',
            source => '__bad_control_case__()',
            keyword => 'case',
            canonical_keyword => 'case',
            args => [$match],
            match => $match,
        );
        $node{body} = $block_return->($return_name) if defined $return_name;
        return \%node;
    };
    my $control_default = sub {
        my ($return_name) = @_;
        my %node = (
            kind => 'control_default',
            source => '__bad_control_default__()',
            keyword => 'default',
            canonical_keyword => 'default',
            args => [],
        );
        $node{body} = $block_return->($return_name) if defined $return_name;
        return \%node;
    };
    my $control_switch = sub {
        my (%fields) = @_;
        my %node = (
            kind => 'control_switch',
            source => '__bad_control_switch__()',
            keyword => 'switch',
            canonical_keyword => 'switch',
            args => [$fields{source_expr}],
            source_expr => $fields{source_expr},
        );
        $node{cases} = $fields{cases} if exists $fields{cases};
        $node{default} = $fields{default} if exists $fields{default};
        $node{body} = $fields{body} if exists $fields{body};
        return \%node;
    };

    {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::AST::parse_action_expr = sub {
            my ($expr, @rest) = @_;
            ++$parse_calls;
            return $control_switch->(
                source_expr => $var->('safe_kind'),
                cases => [$control_case->($string->('a'), 'safe_hit')],
                default => $control_default->('safe_miss'),
                body => $block_return->('poison_body_fallback'),
            ) if $expr eq 'switch(poison_kind) { case(poison_a) { poison_hit() } default { poison_miss() } }';
            return $control_switch->(source_expr => $var->('safe_marker_kind'))
                if $expr eq 'switch(poison_marker_kind)';
            return $control_case->($string->('marker-a'), undef)
                if $expr eq 'case(poison_marker_a)';
            return $control_default->(undef)
                if $expr eq 'default()';
            return { kind => 'control_endcase', source => '__bad_endcase__()', keyword => 'endcase', canonical_keyword => 'endcase', args => [] }
                if $expr eq 'endcase()';
            return { kind => 'control_endswitch', source => '__bad_endswitch__()', keyword => 'endswitch', canonical_keyword => 'endswitch', args => [] }
                if $expr eq 'endswitch()';
            return $call->('return', $var->('safe_marker_hit'))
                if $expr eq 'return(poison_marker_hit)';
            return $call->('return', $var->('safe_marker_miss'))
                if $expr eq 'return(poison_marker_miss)';
            return $orig_parse_action_expr->($expr, @rest);
        };

        my $attached = LinkedSpec::call_spec_handler_subst(
            'Top',
            q{switch(poison_kind) { case(poison_a) { poison_hit() } default { poison_miss() } }},
        );
        like($attached, qr/my \$__ls_switch_value_\d+ = \$safe_kind/, 'attached switch source lowers from AST source_expr');
        like($attached, qr/\$__ls_switch_value_\d+ eq "a".*return \$safe_hit/s, 'attached case lowers from AST match and body fields');
        like($attached, qr/if \(!\$__ls_switch_hit_\d+\).*return \$safe_miss/s, 'attached default lowers from AST default body');

        my $markers = LinkedSpec::call_spec_handler_subst(
            'Top',
            q{switch(poison_marker_kind); case(poison_marker_a); return(poison_marker_hit); endcase(); default(); return(poison_marker_miss); endswitch()},
        );
        like($markers, qr/my \$__ls_switch_value_\d+ = \$safe_marker_kind/, 'marker switch source lowers from AST source_expr');
        like($markers, qr/\$__ls_switch_value_\d+ eq "marker-a".*return \$safe_marker_hit/s, 'marker case lowers from AST match field while preserving switch stack');
        like($markers, qr/if \(!\$__ls_switch_hit_\d+\).*return \$safe_marker_miss/s, 'marker default and endswitch lower from AST markers');

        my $all = join("\n", $attached, $markers);
        unlike($all, qr/poison|__bad_/, 'switch control lowering does not reuse original text, fake fallback body, or AST source fields');
    }

    ok($parse_calls >= 8, 'switch control lowering entered through the AST parser');
};

subtest 'while control lowering consumes AST nodes' => sub {
    my $parse_calls = 0;
    my $orig_parse_action_expr = \&LinkedSpec::ActionIR::AST::parse_action_expr;
    my $var = sub {
        my ($name) = @_;
        return { kind => 'variable', name => $name, source => '__bad_var_'.$name.'__()' };
    };
    my $call = sub {
        my ($name, @args) = @_;
        return { kind => 'call', name => $name, source => '__bad_call_'.$name.'__()', args => \@args };
    };
    my $stmt = sub {
        my ($expr) = @_;
        return { kind => 'action_stmt', source => '__bad_stmt_source__()', expr => $expr };
    };
    my $block_return = sub {
        my ($name) = @_;
        return {
            kind => 'action_block',
            source => '__bad_block_source__()',
            statements => [$stmt->($call->('return', $var->($name)))],
        };
    };

    {
        no warnings 'redefine';
        local *LinkedSpec::ActionIR::AST::parse_action_expr = sub {
            my ($expr, @rest) = @_;
            ++$parse_calls;
            return {
                kind => 'control_while',
                source => '__bad_control_while__()',
                keyword => 'while',
                canonical_keyword => 'while',
                args => [$var->('safe_condition')],
                condition => $var->('safe_condition'),
                body => $block_return->('safe_loop_value'),
            } if $expr eq 'while(poison_condition) { poison_body() }';
            return $orig_parse_action_expr->($expr, @rest);
        };

        my $loop = LinkedSpec::call_spec_handler_subst(
            'Top',
            q{while(poison_condition) { poison_body() }},
        );
        like($loop, qr/do \{ my \$__ls_while_guard_\d+ = 0; for \(; \$safe_condition; \)/, 'attached while condition lowers from AST condition field');
        like($loop, qr/LinkedSpec while iteration safety limit exceeded after 10000 iterations/, 'attached while keeps the existing iteration-safety guard');
        like($loop, qr/return \$safe_loop_value/, 'attached while body lowers from AST body statements');
        unlike($loop, qr/poison|__bad_/, 'while control lowering does not reuse original text or AST source fields');
    }

    ok($parse_calls >= 1, 'while control lowering entered through the AST parser');
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
            if ($expr eq 'meta[poison_key] = { poison_key : poison_value }') {
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
        is($scalar, '$name = [$value]', 'scalar assignment operator lowers RHS from AST fields');

        my $append = LinkedSpec::call_spec_handler_subst('Top', q{items += poison});
        is($append, 'push @items, $value', 'array append operator lowers RHS from AST fields');

        my $hash_assign = LinkedSpec::call_spec_handler_subst('Top', q{meta[poison_key] = { poison_key : poison_value }});
        is($hash_assign, '$meta{$key} = {$key => $value}', 'hash-index assignment lowers key/RHS from AST fields');

        my $all = join("\n", $scalar, $append, $hash_assign);
        unlike($all, qr/poison|__bad_/, 'assignment/mutation statement lowering does not reuse fake AST source or original poison text');
    }

    ok($parse_calls >= 3, 'assignment/mutation statements entered through the AST parser');
};

subtest 'assignment expression lowering consumes AST nodes' => sub {
    is(
        LinkedSpec::call_spec_handler_subst('Top', q{return(name = "ok")}),
        q{return do { $name = "ok"; $name }},
        'scalar assignment expression returns the stored scalar value'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', q{return(=(other, name = "ok"))}),
        q{return do { $other = do { $name = "ok"; $name }; $other }},
        'single-equals operator call composes with a nested scalar assignment value'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', q{return(set(out, name = "ok"))}),
        q{return do { $out = do { $name = "ok"; $name }; $out }},
        'set compatibility spelling returns the stored scalar value in value position'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', q{return(set(items, [value]))}),
        q{return do { $items = [$value]; $items }},
        'direct array shape RHS assignment returns the stored scalar-held array value'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', q{return(=(meta, { key : value }))}),
        q{return do { $meta = {$key => $value}; $meta }},
        'single-equals operator call returns the stored scalar-held hash value'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', q{return(set(:payload, [value]))}),
        q{return do { my $__ls_actionir_unsupported_helper = "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read"; undef }},
        'retired colon scalar target reports the bare-read migration diagnostic'
    );
    my $retired_hash_literal = LinkedSpec::call_spec_handler_subst('Top', q{return({ old => value })});
    like(
        $retired_hash_literal,
        qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon/,
        'old hash-literal fat arrow reports the colon-association diagnostic'
    );
    unlike(
        $retired_hash_literal,
        qr/\$old => \$value/,
        'old hash-literal fat arrow does not lower as a Perl hash pair'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', q{return(items += value)}),
        q{return do { push @items, $value; [@items] }},
        'array append expression returns the updated array snapshot'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', q{return(meta[key] = value)}),
        q{return do { $meta{$key} = $value; +{%meta} }},
        'hash-index assignment expression returns the updated hash snapshot'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', q{return((items += value).count())}),
        q{return do { my $__ls_count = do { push @items, $value; [@items] }; defined($__ls_count) ? scalar(@{$__ls_count}) : 0 }},
        'array append expression can feed an aggregate receiver chain'
    );
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
                return $call->('set', $var->('name'), $array->($var->('value')));
            }
            if ($expr eq 'set_key(hash(meta), poison_key, poison_value)') {
                return $call->('set_key', $call->('hash', $var->('meta')), $var->('key'), $var->('value'));
            }
            if ($expr eq 'push(array(items), poison)') {
                return $call->('push', $call->('array', $var->('items')), $var->('value'));
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
        is($assign, '$name = [$value]', 'set statement lowers from AST call args');

        my $set_key = LinkedSpec::call_spec_handler_subst('Top', q{set_key(hash(meta), poison_key, poison_value)});
        is($set_key, '$meta{$key} = $value', 'set_key statement lowers target/key/value from AST call args');

        my $push = LinkedSpec::call_spec_handler_subst('Top', q{push(array(items), poison)});
        is($push, 'push @items, $value', 'push statement lowers explicit append from AST call args');

        my $return = LinkedSpec::call_spec_handler_subst('Top', q{return([poison])});
        is($return, 'return [$value]', 'return statement lowers payload from AST call args');

        my $return_undef = LinkedSpec::call_spec_handler_subst('Top', q{return_undef(poison)});
        is($return_undef, 'return undef', 'return_undef statement lowers from AST call arity');

        my $push_back = LinkedSpec::call_spec_handler_subst('Top', q{items.push_back(poison)});
        is($push_back, 'push @items, $value', 'array end-mutation statement lowers from AST receiver/call fields');

        my $all = join("\n", $assign, $set_key, $push, $return, $return_undef, $push_back);
        unlike($all, qr/poison|__bad_/, 'statement helper-call lowering does not reuse fake AST source or original poison text');
    }

    ok($parse_calls >= 6, 'statement helper calls entered through the AST parser');
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
            q{return([value, true, foo["a"][i], { key : value }])},
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
            if ($expr eq 'num_add(n,num_mul(2,3))') {
                return {
                    kind => 'call',
                    name => 'num_add',
                    source => '__bad_num_outer_host_call__()',
                    args => [
                        { kind => 'variable', name => 'n', source => 'n' },
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

        my $numeric_call = LinkedSpec::call_spec_handler_subst('Top', q{return(num_add(n,num_mul(2,3)))});
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
            if ($expr eq 'copy(array(items))') {
                return $call->(
                    'copy',
                    '__bad_array_snapshot_host_call__()',
                    $call->('array', '__bad_array_wrapper_host_call__()', $var->('items')),
                );
            }
            if ($expr eq 'copy(hash(meta))') {
                return $call->(
                    'copy',
                    '__bad_hash_snapshot_host_call__()',
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
            if ($expr eq 'merge_hash(hash(base),set_key(hash(overlay),"stage",cat("a","b")))') {
                return $call->(
                    'merge_hash',
                    '__bad_merge_hash_host_call__()',
                    $call->('hash', '__bad_base_hash_wrapper_host_call__()', $var->('base')),
                    $call->(
                        'set_key',
                        '__bad_set_key_host_call__()',
                        $call->('hash', '__bad_overlay_hash_wrapper_host_call__()', $var->('overlay')),
                        $str->('stage'),
                        $call->('cat', '__bad_cat_host_call__()', $str->('a'), $str->('b')),
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

        my $array_snapshot = LinkedSpec::call_spec_handler_subst('Top', q{return(copy(array(items)))});
        is($array_snapshot, q{return [@items]}, 'AST aggregate lowering preserves copy(array(items)) output');

        my $hash_snapshot = LinkedSpec::call_spec_handler_subst('Top', q{return(copy(hash(meta)))});
        is($hash_snapshot, q{return {%meta}}, 'AST aggregate lowering preserves copy(hash(meta)) output');

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

        my $merge = LinkedSpec::call_spec_handler_subst('Top', q{return(merge_hash(hash(base),set_key(hash(overlay),"stage",cat("a","b"))))});
        like($merge, qr/%base/, 'AST aggregate lowering preserves merge_hash hash source slots');
        like($merge, qr/\\%overlay/, 'AST aggregate lowering preserves nested set_key hash source slots');
        like($merge, qr/\@__ls_cat_parts/, 'AST aggregate lowering composes nested value-only helper slots');

        my $has_key = LinkedSpec::call_spec_handler_subst('Top', q{return(has_key(pick_keys(hash(meta),"a"),"a"))});
        like($has_key, qr/\$__ls_pick_source/, 'AST aggregate lowering preserves nested pick_keys hash helper output');
        like($has_key, qr/\$__ls_has_key/, 'AST aggregate lowering preserves has_key terminal output');

        my $all = join("\n", $array_snapshot, $hash_snapshot, $copy_hash, $quoted_count, $sum, $take, $merge, $has_key);
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

    my $nested_bad = LinkedSpec::call_spec_handler_subst('Top', q{return(cat(substr("abc"),"x"))});
    unlike($nested_bad, qr/\@__ls_cat_parts = \(substr\s*\(/, 'nested unsupported covered helper no longer becomes a host-call cat operand');
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

subtest 'standalone AST value statements drop covered values without raw fallback' => sub {
    my $trim = LinkedSpec::call_spec_handler_subst('Top', q{trim(" x ")});
    like($trim, qr/^do \{ do \{ my \$__ls_trim = " x ";.*undef \}$/s,
        'standalone trim lowers as a discarded value expression');
    unlike($trim, qr/^trim\s*\(/, 'standalone trim no longer remains as raw host-call text');

    my $cat = LinkedSpec::call_spec_handler_subst('Top', q{cat("a", "b")});
    like($cat, qr/^do \{ do \{ my \@__ls_cat_parts = \("a", "b"\);.*undef \}$/s,
        'standalone cat lowers as a discarded value expression');
    unlike($cat, qr/^cat\s*\(/, 'standalone cat no longer remains as raw host-call text');

    my $bad_count = LinkedSpec::call_spec_handler_subst('Top', q{count(1,2)});
    like($bad_count, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:count/,
        'malformed covered standalone helper lowers to the unresolved-helper sentinel');
    unlike($bad_count, qr/^count\s*\(/, 'malformed covered standalone helper no longer remains as raw host-call text');

    my $string_chain = LinkedSpec::call_spec_handler_subst('Top', q{" x ".trim()});
    like($string_chain, qr/^do \{ do \{ my \$__ls_trim = " x ";.*undef \}$/s,
        'standalone string receiver chain lowers as a discarded value expression');
    unlike($string_chain, qr/^" x "\.trim\(\)/, 'standalone string receiver chain no longer remains as raw source text');

    my $ready_spec = qq{Top::\n /x/ -> Done { trim(" x "); cat("a","b"); " y ".trim() }\nDone::\n /y/\n};
    my $ready_descriptor = eval { LinkedSpec::Get(\$ready_spec, return_descriptor => 1) };
    ok(ref($ready_descriptor) eq 'HASH', 'descriptor builds for supported standalone value statements');
    my $ready_meta = ref($ready_descriptor) eq 'HASH' ? ($ready_descriptor->{spec}{Top}{meta}{action_rewriter} || {}) : {};
    is($ready_meta->{raw_perl_dependency_count} || 0, 0, 'supported standalone value statements have no raw Perl dependency');
    is($ready_meta->{unresolved_helper_count} || 0, 0, 'supported standalone value statements have no unresolved helper');
    ok($ready_meta->{language_agnostic_action_ir_ready}, 'supported standalone value statements remain language-agnostic ready');
    ok(grep { $_ eq 'VALUE_DROP' } @{$ready_meta->{canonical_action_ir_nodes} || []},
        'supported standalone value statements report VALUE_DROP canonical nodes');

    my $unsupported_spec = qq{Top::\n /x/ -> Done { count(1,2) }\nDone::\n /y/\n};
    my $unsupported_descriptor = eval { LinkedSpec::Get(\$unsupported_spec, return_descriptor => 1) };
    ok(ref($unsupported_descriptor) eq 'HASH', 'descriptor builds for unsupported covered standalone value statement');
    my $unsupported_meta = ref($unsupported_descriptor) eq 'HASH' ? ($unsupported_descriptor->{spec}{Top}{meta}{action_rewriter} || {}) : {};
    is($unsupported_meta->{raw_perl_dependency_count} || 0, 0, 'unsupported covered standalone helper is not reported as raw Perl fallback');
    is($unsupported_meta->{unresolved_helper_count} || 0, 1, 'unsupported covered standalone helper is reported as unresolved');
    is_deeply($unsupported_meta->{unresolved_helpers} || [], ['count'], 'unsupported covered standalone helper names the helper');
    ok(!$unsupported_meta->{language_agnostic_action_ir_ready}, 'unsupported covered standalone helper blocks readiness through diagnostics');

    my $unknown = LinkedSpec::call_spec_handler_subst('Top', q{user_fn("x")});
    is($unknown, q{user_fn("x")},
        'standalone unknown user function remains raw until the function registry owns discard semantics');

    my $unknown_chain = LinkedSpec::call_spec_handler_subst('Top', q{user_fn("x").trim()});
    is($unknown_chain, q{user_fn("x").trim()},
        'standalone unknown function-call receiver chain remains raw until function calls resolve');

    my $unknown_spec = qq{Top::\n /x/ -> Done { user_fn("x"); user_fn("x").trim() }\nDone::\n /y/\n};
    my $unknown_descriptor = eval { LinkedSpec::Get(\$unknown_spec, return_descriptor => 1) };
    ok(ref($unknown_descriptor) eq 'HASH', 'descriptor still builds for unknown standalone user-function statements');
    my $unknown_meta = ref($unknown_descriptor) eq 'HASH' ? ($unknown_descriptor->{spec}{Top}{meta}{action_rewriter} || {}) : {};
    is($unknown_meta->{raw_perl_dependency_count} || 0, 2, 'unknown standalone user-function statements remain raw Perl dependencies');
    is($unknown_meta->{unresolved_helper_count} || 0, 0, 'unknown standalone user-function statements are not claimed as covered helper diagnostics yet');
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
            if ($expr eq '[value, true, cat("a","b"), foo["a"][i], { key : value }]') {
                return {
                    kind => 'array_literal',
                    source => '__bad_return_payload_array__()',
                    items => [
                        $var->('value'),
                        { kind => 'boolean', value => 1, source => '__bad_true__()' },
                        $call->('cat', $str->('a'), $str->('b')),
                        {
                            kind => 'nested_access',
                            base => 'foo',
                            source => '__bad_nested_access__()',
                            segments => [
                                { kind => 'key', value => 'a', source => '["a"]' },
                                { kind => 'index', expr => $var->('i') },
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
            q{return([value, true, cat("a","b"), foo["a"][i], { key : value }])},
        );
        like($payload, qr/\$value/, 'AST return payload lowers bare scalar reads from typed nodes');
        like($payload, qr/JSON::PP::true/, 'AST return payload lowers booleans from typed nodes');
        like($payload, qr/__ls_cat_parts/, 'AST return payload lowers nested helper calls from typed nodes');
        like($payload, qr/\$foo->\{"a"\}->\[\$i\]/, 'AST return payload lowers nested access from typed nodes');
        like($payload, qr/\{\$key => \$value\}/, 'AST return payload lowers hash literals from typed nodes');

        my $bad_chain = LinkedSpec::call_spec_handler_subst('Top', q{return(["x", "abc".substr()])});
        unlike($bad_chain, qr/\bsubstr\s*\(/, 'unsupported covered return-payload chain helper does not leak as a host call');
        like($bad_chain, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:substr/, 'unsupported covered return-payload chain helper keeps diagnostic sentinel');

        my $unknown_call = LinkedSpec::call_spec_handler_subst('Top', q{return(user_fn("x"))});
        unlike($unknown_call, qr/\breturn\s+user_fn\s*\(/, 'unknown return-payload call does not leak as a host call');
        like($unknown_call, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:user_fn/, 'unknown return-payload call keeps diagnostic sentinel');

        my $unknown_receiver = LinkedSpec::call_spec_handler_subst('Top', q{return(user_fn("x").trim())});
        unlike($unknown_receiver, qr/user_fn\s*\("x"\)/, 'unknown function-call receiver does not leak into receiver-chain lowering');
        like($unknown_receiver, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:user_fn/, 'unknown function-call receiver keeps diagnostic sentinel');

        my $bare_scalar = LinkedSpec::call_spec_handler_subst('Top', q{return(count)});
        like($bare_scalar, qr/return \$count\b/, 'AST variable return payloads still lower through scalar source-slot reads');
        unlike($bare_scalar, qr/return count\b/, 'AST variable return payloads do not leak raw identifiers');

        my $all = join("\n", $payload, $bad_chain, $unknown_call, $unknown_receiver, $bare_scalar);
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
                    $stmt->('set_x', $call->('set', $var->('x'), $str->('a'))),
                    $stmt->('return_value', $call->('return', $var->('value'))),
                    $stmt->('set_y', $call->('set', $var->('y'), $str->('b'))),
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
