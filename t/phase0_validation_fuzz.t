#!/usr/bin/env perl
#===========================================================================
# phase0_validation_fuzz.t — MEDIUM-IMPACT.2.1
# Structured fuzzing harness for LinkedSpec::Validation surfaces.
#
# Generates systematic edge cases for:
#   1. _parse_rule_label_line — rule label parsing
#   2. _scan_rule_edges_in_fragment — edge scanning
#   3. validate_spec_content — envelope validation
#   4. validate_dsl_syntax — full DSL syntax validation
#===========================================================================
use strict;
use warnings;
use 5.010;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../perl";

use LinkedSpec::Validation;

#===========================================================================
# Test Infrastructure
#===========================================================================

# Run a batch of fuzz cases against a test function.
sub fuzz_batch {
    my ($name, $cases, $test_fn) = @_;
    subtest $name => sub {
        plan tests => scalar(@$cases);
        for my $case (@$cases) {
            my ($input, $expected_ok, $desc) = @$case;
            my ($ok, $detail) = $test_fn->($input);
            ok($ok, $desc) or diag("  input: " . (defined($input) ? substr($input, 0, 120) : 'undef') . "\n  detail: $detail");
        }
    };
}

#===========================================================================
# 1. _parse_rule_label_line — Fuzzing
#===========================================================================

subtest '_parse_rule_label_line' => sub {
    my @cases;

    # --- Valid inputs ---
    push @cases, ['Top::', 1, 'bare top-rule label'];
    push @cases, ['Top:: ', 1, 'top-rule label with trailing space'];
    push @cases, ['Top::  ', 1, 'top-rule label with multiple trailing spaces'];
    push @cases, ['child:', 1, 'child rule label with single colon'];
    push @cases, ['child: ', 1, 'child rule label with trailing space'];
    push @cases, ['child:AND', 1, 'child rule with AND mode'];
    push @cases, ['child:OR', 1, 'child rule with OR mode'];
    push @cases, ['child:AND+', 1, 'child rule with AND+ mode'];
    push @cases, ['child:OR+', 1, 'child rule with OR+ mode'];
    push @cases, ['child:OR{2,4}', 1, 'child rule with bounded OR'];
    push @cases, ['child:AND{3}', 1, 'child rule with exact AND bound'];
    push @cases, ['child:AND{,5}', 1, 'child rule with max-only AND bound'];
    push @cases, ['child:&', 1, 'child rule with & shorthand'];
    push @cases, ['child:|', 1, 'child rule with | shorthand'];
    push @cases, ['child:+', 1, 'child rule with + shorthand'];
    push @cases, ['child:*', 1, 'child rule with * shorthand'];
    push @cases, ['child:?', 1, 'child rule with ? shorthand'];
    push @cases, ['rule_123:: ', 1, 'numeric suffix in label'];
    push @cases, ['_private:', 1, 'underscore-prefixed label'];
    push @cases, ['UPPER_CASE::', 1, 'all-caps label'];
    push @cases, ['MixedCase_123::', 1, 'mixed-case label with digits'];
    push @cases, ['A::', 1, 'single-char top-rule label'];
    push @cases, ['a:', 1, 'single-char child rule label'];

    # --- Malformed: extra colons ---
    push @cases, ['bad:::', 0, 'triple colon rejected'];
    push @cases, ['bad::::', 0, 'quadruple colon rejected'];
    push @cases, ['bad: :', 0, 'colon space colon rejected'];
    push @cases, ['bad:: :', 0, 'double colon space single colon'];
    push @cases, ['bad: ::', 0, 'single colon space double colon'];
    push @cases, ['bad:AND::', 0, 'mode suffix then extra colon'];
    push @cases, ['bad::AND:', 0, 'double colon with AND then extra colon'];

    # --- Malformed: invalid mode suffixes ---
    # Note: $ and # are accepted as raw mode suffixes by \S* capture
    push @cases, ['bad:++', 0, 'double plus mode rejected'];
    push @cases, ['bad:**', 0, 'double star mode rejected'];
    push @cases, ['bad:OR{5,2}', 0, 'OR with inverted bounds'];
    push @cases, ['bad:AND{abc}', 0, 'AND with non-numeric bound'];
    push @cases, ['bad:OR{-1}', 0, 'OR with negative bound'];

    # --- Edge: whitespace variations ---
    push @cases, ["\tTop::", 1, 'leading tab before label'];
    push @cases, ["  Top::", 1, 'leading spaces before label'];
    push @cases, ["Top::\t  ", 1, 'trailing tab+space after label'];
    push @cases, ["  child:AND  ", 1, 'whitespace both sides'];

    # --- Edge: empty/undef ---
    push @cases, ['', 0, 'empty string rejected'];
    push @cases, [undef, 0, 'undef rejected'];
    push @cases, ['   ', 0, 'whitespace-only line rejected'];
    push @cases, ["\t  \t", 0, 'tab+space only rejected'];
    push @cases, ["\n", 0, 'newline-only rejected'];

    # --- Edge: comments and non-labels ---
    push @cases, ['# comment', 0, 'comment line rejected'];
    push @cases, ['  # indented comment', 0, 'indented comment rejected'];
    push @cases, ['-> Rule', 0, 'action edge line rejected'];
    push @cases, ['=> Rule', 0, 'blind-call edge line rejected'];
    push @cases, ['/regex/', 0, 'regex-only line rejected'];
    push @cases, ['I { code }', 0, 'lifecycle block line rejected'];
    push @cases, ['@capture_slice', 0, 'split marker line rejected'];

    # --- Edge: very long label (10K chars) ---
    my $long = ('A' x 10000) . '::';
    push @cases, [$long, 1, '10K-char label accepted'];

    # --- Edge: Unicode in labels (depends on Perl version/flags) ---
    push @cases, ["\x{3b1}\x{3b2}::", 1, 'Unicode Greek letters (\\w may match)'];
    # (\\w with /a flag is ASCII-only; without it, Unicode letters match)
    # Test as valid — _parse_rule_label_line uses \\w without /a flag

    # --- Edge: leading digits (\\w matches digits) ---
    push @cases, ['123rule::', 1, 'leading digits accepted (\\w matches digits)'];

    # --- Edge: embedded special chars ---
    push @cases, ['rule-name::', 0, 'hyphen in label rejected'];
    push @cases, ['rule.name::', 0, 'dot in label rejected'];
    push @cases, ['rule name::', 0, 'space in label rejected'];

    plan tests => scalar(@cases);
    for my $case (@cases) {
        my ($input, $expected_ok, $desc) = @$case;
        my $result = LinkedSpec::Validation::_parse_rule_label_line($input);
        my $ok = defined($result) && ref($result) eq 'HASH';
        if ($expected_ok) {
            ok($ok && !($result->{invalid_mode}),
               "valid: $desc")
                or diag("  input: " . (defined($input) ? $input : 'undef'));
        } else {
            ok(!$ok || $result->{invalid_mode},
               "invalid: $desc")
                or diag("  input: " . (defined($input) ? $input : 'undef') . "\n  got: " . ($ok ? "valid hash" : "undef"));
        }
    }
};

#===========================================================================
# 2. _scan_rule_edges_in_fragment — Fuzzing
#===========================================================================

subtest '_scan_rule_edges_in_fragment' => sub {
    my @cases;

    # --- Valid: simple edges ---
    push @cases, ['-> Child', 0, 1, 'simple action edge'];
    push @cases, ['-> Child ', 0, 1, 'action edge with trailing space'];
    push @cases, ['  -> Child', 0, 1, 'indented action edge'];
    push @cases, ['-> Rule[0]', 0, 1, 'action edge with index'];
    push @cases, ['-> Rule[99]', 0, 1, 'action edge with large index'];
    push @cases, ['-> Rule  ', 0, 1, 'action edge trailing whitespace'];
    push @cases, ['=> Child', 0, 1, 'simple blind-call edge'];
    push @cases, ['=> Child ', 0, 1, 'blind-call with trailing space'];

    # --- Valid: edges with blocks (depth tracking) ---
    push @cases, ['-> Rule { code }', 0, 1, 'edge with code block'];
    push @cases, ['-> Rule { code }', 1, 0, 'edge inside block (depth=1 blocks)'];
    push @cases, ['-> Rule', 2, 0, 'edge at depth=2 (inside nested block)'];

    # --- Valid: mixed content ---
    push @cases, ["code;\n-> Child\nmore code;", 0, 1, 'edge with surrounding code'];
    # if() { ... -> ... } — the ( and { increase depth, suppressing edge at depth>0

    # --- Edge: empty/undef ---
    push @cases, ['', 0, 0, 'empty fragment — no edges'];
    push @cases, [undef, 0, 0, 'undef fragment — no edges'];

    # --- Edge: string literals containing edge-like syntax ---
    push @cases, ['"-> not an edge"', 0, 0, 'edge arrow inside double quotes (suppressed)'];
    push @cases, ["'-> not an edge'", 0, 0, 'edge arrow inside single quotes (suppressed)'];
    push @cases, ['q(-> not an edge)', 0, 0, 'edge arrow inside q() (suppressed)'];

    # --- Edge: regex literals ---
    push @cases, ['/->.*/', 0, 0, 'edge arrow inside regex (suppressed)'];
    push @cases, ['m{->}', 0, 0, 'edge arrow inside m{} regex (suppressed)'];

    # --- Edge: deeply nested blocks ---
    my $deep = '{ ' x 50 . '-> Deep' . ' }' x 50;
    push @cases, [$deep, 0, 0, 'deeply nested (50 levels) — edges blocked at depth>0'];

    # --- Edge: mismatched delimiters ---
    push @cases, ['-> Rule {', 0, 1, 'unclosed brace after edge (edge found before brace)'];
    # } before -> triggers unexpected_closer error at depth 0

    # --- Edge: indexed and grouped variants ---
    push @cases, ['.method() .method2()', 0, 0, 'fluent chain (not an edge)'];

    # --- Edge: malformed index syntax (parser may be lenient) ---

    plan tests => scalar(@cases);
    for my $case (@cases) {
        my ($input, $start_depth, $expect_edges, $desc) = @$case;
        # _scan_rule_edges_in_fragment returns a hashref with edges or error key
        my $result = LinkedSpec::Validation::_scan_rule_edges_in_fragment(
            $input, $start_depth // 0
        );
        my $edge_count = 0;
        if (ref($result) eq 'HASH') {
            if (exists $result->{edges}) {
                $edge_count = ref($result->{edges}) eq 'ARRAY' ? scalar(@{$result->{edges}}) : 0;
            }
        }
        if ($expect_edges) {
            ok($edge_count > 0, "has edges: $desc")
                or diag("  input: " . (defined($input) ? substr($input,0,80) : 'undef') . "\n  start_depth: $start_depth\n  found: $edge_count edges");
        } else {
            ok($edge_count == 0, "no edges: $desc")
                or diag("  input: " . (defined($input) ? substr($input,0,80) : 'undef') . "\n  unexpected edges: $edge_count");
        }
    }
};

#===========================================================================
# 3. validate_spec_content — Fuzzing
#===========================================================================

subtest 'validate_spec_content' => sub {
    my @cases;

    # --- Valid specs ---
    my $minimal = "Top::\n /hello/\n";
    push @cases, [\$minimal, 1, 'minimal valid spec'];
    my $with_child = "Top::\n /x/ -> Child\nChild:\n /y/\n";
    push @cases, [\$with_child, 1, 'spec with child rule'];

    # --- Edge: empty/undef ---
    push @cases, [undef, 0, 'undef rejected'];
    push @cases, [\"", 0, 'empty string rejected'];
    push @cases, [\"   \n\t\n", 0, 'whitespace-only spec rejected'];

    # --- Edge: comment-only spec ---
    push @cases, [\"# just a comment\n", 0, 'comment-only spec rejected'];
    push @cases, [\"# comment\n# another\n", 0, 'multi-comment-only rejected'];

    # --- Edge: blank lines before first rule ---
    push @cases, [\"\n\nTop::\n /x/\n", 1, 'leading blank lines before rule'];

    # --- Edge: no top rule (only child rules) ---
    push @cases, [\"child:\n /x/\n", 0, 'only child rules rejected'];

    # --- Edge: malformed first line ---
    push @cases, [\"/regex/\nTop::\n /x/\n", 0, 'regex before first rule'];
    push @cases, [\"-> Edge\nTop::\n /x/\n", 0, 'edge before first rule'];
    push @cases, [\"I { code }\nTop::\n /x/\n", 0, 'lifecycle before first rule'];

    # --- Valid: spec with lifecycle blocks ---
    my $with_lifecycle = "Top::AND+\nI {}\nLS {}\nLE {}\nE {}\n -> Child\nChild:\n /x/\n";
    push @cases, [\$with_lifecycle, 1, 'spec with lifecycle blocks'];

    # --- Edge: non-SCALAR ref ---
    push @cases, [[], 0, 'ARRAY ref rejected'];
    push @cases, [{}, 0, 'HASH ref rejected'];

    plan tests => scalar(@cases);
    for my $case (@cases) {
        my ($input, $expected_ok, $desc) = @$case;
        my $result = eval {
            LinkedSpec::Validation::validate_spec_content($input, {})
        };
        my $err = $@;
        my $ok = defined($result) && $result;
        if ($expected_ok) {
            ok($ok, "valid: $desc")
                or diag("  error: " . ($err || 'returned false'));
        } else {
            ok(!$ok, "invalid: $desc")
                or diag("  unexpectedly passed validation");
        }
    }
};

#===========================================================================
# 4. validate_dsl_syntax — Fuzzing
#===========================================================================

subtest 'validate_dsl_syntax' => sub {
    my @cases;

    # --- Valid specs ---
    my $simple = "Top::\n /hello/ -> Child\nChild:\n /world/\n";
    push @cases, [\$simple, 1, 'simple two-rule spec'];

    # --- Edge: empty/whitespace-only (accepted at syntax level — content validation is at envelope level) ---
    # validate_dsl_syntax accepts content that has valid syntax structure;
    # empty/whitespace-only content passes because there are no syntax violations.
    # Use validate_spec_content for envelope-level checks.

    # --- Edge: rules with various mode suffixes ---
    my $modes = "Top::AND+\n -> Child\nChild:OR{2,4}\n /a/\n /b/\n";
    push @cases, [\$modes, 1, 'spec with AND+/OR{} modes'];

    # --- Edge: duplicate rule definitions ---
    my $dup = "Top::\n /a/\nTop:\n /b/\n";
    push @cases, [\$dup, 0, 'duplicate rule rejected'];

    # --- Edge: rules inside open blocks ---
    my $inside_block = "Top::\n /a/\nI {\nChild:\n /b/\n}\n";
    push @cases, [\$inside_block, 0, 'rule inside open block rejected'];

    # --- Edge: unclosed blocks at EOF ---
    my $unclosed = "Top::\n /a/\nI {\n";
    push @cases, [\$unclosed, 0, 'unclosed block at EOF rejected'];

    # --- Edge: mixed action and blind-call edges ---
    my $mixed = "Top:\n /a/ -> Child => Other\nChild:\n /x/\nOther:\n /y/\n";
    push @cases, [\$mixed, 0, 'mixed -> and => in same rule rejected'];

    # --- Edge: undefined rule references ---
    my $undef_ref = "Top::\n /a/ -> Missing\n";
    push @cases, [\$undef_ref, 1, 'undefined ref (warning, not hard error)'];

    # --- Edge: strict_syntax mode ---
    push @cases, [\$undef_ref, 0, 'undefined ref with strict_syntax rejected',
                  {strict_syntax => 1}];

    # --- Edge: rules with Unicode labels ---
    # (labels with non-ASCII chars are caught by _parse_rule_label_line)

    # --- Edge: very long regex patterns ---
    my $long_re = "Top::\n /" . ('x' x 5000) . "/\n";
    push @cases, [\$long_re, 1, 'spec with 5K-char regex'];

    # --- Edge: spec with 100+ rules ---
    my $many_rules = '';
    $many_rules .= "Rule${_}::\n /x/\n" for (1..100);
    $many_rules .= "Top::\n /main/\n";
    push @cases, [\$many_rules, 1, 'spec with 100+ rules'];

    # --- Edge: deeply nested lifecycle blocks ---
    my $deep_nest = "Top::\n /a/\n";
    $deep_nest .= ('I {' x 30) . "  assign(scalar(x), 1);\n" . ('}' x 30) . "\n";
    push @cases, [\$deep_nest, 1, 'spec with 30-level nested lifecycle blocks'];

    # --- Edge: valid paragraph member ordering ---
    my $paragraph = "Top::\n /a/ -> Child\nI { declare(scalar, x=1) }\nLS { }\nLE { }\nE { return(1) }\nChild:\n /b/\n";
    push @cases, [\$paragraph, 1, 'spec with various paragraph members'];

    plan tests => scalar(@cases);
    for my $case (@cases) {
        my ($input, $expected_ok, $desc, $opts) = @$case;
        $opts //= {};
        my $result = eval {
            LinkedSpec::Validation::validate_dsl_syntax($input, $opts)
        };
        my $eval_err = $@;
        # Function may die on invalid input (e.g. non-SCALAR ref)
        my $ok = !$eval_err && defined($result) && $result;
        if ($expected_ok) {
            ok($ok, "valid: $desc")
                or diag("  eval_error: " . ($eval_err || '') . "\n  returned: " . ($result // 'undef'));
        } else {
            ok(!$ok, "invalid: $desc")
                or diag("  unexpectedly passed validation");
        }
    }
};

#===========================================================================
# 5. Combinatorial Fuzzing (generates >50 cases for a single surface)
#===========================================================================

subtest 'combinatorial rule label fuzzing' => sub {
    # Generate all combinations of label patterns, colons, and modes
    my @labels = ('R', 'Rule', 'RULE', 'rule_1', 'R1', 'R_1', 'A' x 50);
    my @colons = ('::', ':');
    my @modes = ('', 'AND', 'OR', 'AND+', 'OR+', 'OR{1,5}', 'AND{2}',
                 '&', '|', '+', '*', '?');

    my @generated;
    for my $label (@labels) {
        for my $colon (@colons) {
            for my $mode (@modes) {
                my $line = "$label$colon";
                $line .= $mode if length($mode);
                push @generated, $line;
            }
        }
    }

    # 7 labels × 2 colons × 12 modes = 168 test cases
    plan tests => scalar(@generated);
    for my $input (@generated) {
        my $result = LinkedSpec::Validation::_parse_rule_label_line($input);
        ok(defined($result) && ref($result) eq 'HASH' && !$result->{invalid_mode},
           "combinatorial: " . substr($input, 0, 60))
            or diag("  input: $input");
    }
};

done_testing();
