use strict;
use warnings;
use Test::More;
BEGIN {
    if ($ENV{LINKEDSPEC_QUOTE_BASELINE}) {
        my $prefix = './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0-before-';
        for my $name (qw(MethodExpr ScannerCore RewritePipeline)) {
            require $prefix.$name.'.pm';
            $INC{'LinkedSpec/ActionIR/'.$name.'.pm'} = $prefix.$name.'.pm';
        }
    }
}
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::ScannerCore ();

sub rewrite {
    return LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics('Top', $_[0], undef);
}

sub literal_scalar_value {
    my ($code) = @_;
    my $program = 'sub { my ($counter,$text); '.$code.' }';
    my $sub = eval $program;
    if (!$sub) { diag($@); return undef }
    my $value = eval { $sub->() };
    diag($@) if $@;
    return $value;
}

for my $fixture (
    [q{return("return(inner); if(true)")}, 'return(inner); if(true)'],
    [q{return('return(inner); if(true)')}, 'return(inner); if(true)'],
    [q{return("set(counter, 2)")}, 'set(counter, 2)'],
    [q{return('set(counter, 2)')}, 'set(counter, 2)'],
    [q{return("quote\"; if(true)")}, 'quote"; if(true)'],
) {
    subtest 'quoted literal ownership: '.$fixture->[0] => sub {
        my ($lowered, $diag) = rewrite($fixture->[0]);
        is(literal_scalar_value($lowered), $fixture->[1], 'literal result retains authored data');
        is($diag->{helper_action_ir_hits}{IF} || 0, 0, 'no quoted IF helper occurrence');
        ok(!grep({ ($_->{contract_id} // '') eq 'set_value' || ($_->{contract_id} // '') eq 'if_flow' }
            @{$diag->{helper_action_ir_events}}), 'no helper event sourced inside the literal');
        is($diag->{canonical_action_ir_hits}{IF} || 0, 0, 'no phantom canonical IF');
        is($diag->{canonical_action_ir_hits}{ASSIGN} || 0, 0, 'no phantom canonical assignment');
    };
}

for my $fixture (
    [q{text="set(counter,2)"; set(counter,2); return([text,counter])}, ['set(counter,2)',2], 1],
    [q{set(counter,2); text="set(counter,2)"; return([text,counter])}, ['set(counter,2)',2], 1],
    [q{set(counter,1); text="set(counter,1)"; set(counter,1); return([text,counter])}, ['set(counter,1)',1], 2],
) {
    subtest 'identical quoted/real occurrences: '.$fixture->[0] => sub {
        my ($lowered, $diag) = rewrite($fixture->[0]);
        is_deeply(literal_scalar_value($lowered), $fixture->[1], 'actual assignments preserve independent literal/value oracle');
        is(scalar(grep { ($_->{contract_id} // '') eq 'set_value' } @{$diag->{helper_action_ir_events}}),
            $fixture->[2], 'retain exactly the executable assignment occurrences');
        is(scalar(grep { ($_->{contract_id} // '') eq 'set_value' } @{$diag->{canonical_action_ir_events}}),
            $fixture->[2], 'canonical queue retains each real occurrence once');
    };
}

subtest 'Unicode and CRLF preserve original operands and scalar frame' => sub {
    my $snow = chr(0x96ea);
    my $action = "\r\n return(\"$snow set(counter, 2); if(true)\")";
    my ($lowered, $diag) = rewrite($action);
    is(literal_scalar_value($lowered), "$snow set(counter, 2); if(true)", 'Unicode quoted data survives lowering');
    like($lowered, qr/^\r\n/, 'CRLF prefix is retained');
    is(scalar(@{$diag->{helper_action_ir_events}}), 1, 'only the actual outer return is scanned');
    is($diag->{helper_action_ir_events}[0]{raw}, substr($action, 3), 'event retains complete original Unicode source');
};

subtest 'regex patterns are data while arithmetic slash calls remain helpers' => sub {
    my ($lowered, $diag) = rewrite(q{return(matches("iftrue", /if(true)/))});
    is(literal_scalar_value($lowered), 1, 'accepted regex grouping matches the literal subject');
    is($diag->{canonical_action_ir_hits}{IF} || 0, 0, 'regex call spelling contributes no IF');
    my ($division) = rewrite(q{return(/(14,2))});
    is(literal_scalar_value($division), 7, 'slash-call arithmetic is not hidden as regex data');
};

subtest 'generated and native nested values no longer escape as host calls' => sub {
    my @cases = (
        [q{return(cat("set(counter, 2)","; if(true); return(inner)"))}, 'set(counter, 2); if(true); return(inner)'],
        [q{return(matches("if(true)", /if\(true\)/))}, 1],
        [q{cb={|| return("set(counter, 2); if(true)") }; return(cb())}, 'set(counter, 2); if(true)'],
    );
    my $index = 0;
    for my $case (@cases) {
        my $source = 'Top:: I { '.$case->[0].' }';
        my (%context, $value);
        my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
        my $input = '';
        my $ok = eval { $value = $parser->(\$input); 1 };
        ok($ok && !$context{last_error}, 'native route has no host-call failure');
        is_deeply($value, $case->[1], 'native route independent literal/matches result');
        my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'quoted-source-test.spec');
        my $package = 'QuotedSourceTest::Generated'.++$index;
        my $loaded = eval "package $package; $emitted\n1;";
        ok($loaded, 'actual emitted source independently loads');
        no strict 'refs';
        $input = '';
        $value = undef;
        $ok = eval { $value = &{$package.'::Execute'}(\$input); 1 };
        ok($ok, 'independent emitted route has no host-call failure');
        is_deeply($value, $case->[1], 'independent emitted route exact result');
    }
};

subtest 'real unsupported helpers and raw operands remain blockers' => sub {
    for my $action (q{return(substr("abc"))}, q{return(count())}, q{return(cat(substr("abc"),"x"))}) {
        my ($lowered, $diag) = rewrite($action);
        is($diag->{unresolved_helper_count}, 1, 'real compiler-owned unsupported marker remains visible');
        like($lowered, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:/, 'real unsupported lowering still emits its guard');
    }
    my $source = 'Top:: I { return(add(0,i+1)) }';
    my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
    my $meta = $descriptor->{spec}{Top}{meta}{action_rewriter};
    is($meta->{raw_perl_dependency_count}, 1, 'real raw child remains counted');
    is_deeply($meta->{raw_perl_dependency_statements}, ['i+1'], 'real raw source remains original');
    ok(!$meta->{language_agnostic_action_ir_ready}, 'real raw child still blocks readiness');
};

subtest 'scanner opaque return and caller error state retain their contract' => sub {
    no warnings 'redefine';
    local *LinkedSpec::ActionIR::ScannerCore::_scanner_rule_dep_bindings = sub { return {} };
    local *LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_deps = sub { return $_[1]->() };
    local *LinkedSpec::ActionIR::ScannerCore::_scanner_dispatchers = sub { return sub { return 'opaque scanner value' } };
    local $@ = 'caller diagnostic';
    is(LinkedSpec::ActionIR::ScannerCore::scan_contract_ir_events({id => 'opaque'}, 'return("if(true)")', {}),
       'opaque scanner value', 'opaque dispatcher return stays unchanged');
    is($@, 'caller diagnostic', 'scanner source ownership retains caller error state');
};

done_testing;
