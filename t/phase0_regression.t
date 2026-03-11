#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
no warnings 'once';

use Test::More;
use FindBin qw($Bin);
use File::Basename qw(basename);
use File::Spec;
use Cwd qw(getcwd);
use IPC::Open3;
use Symbol qw(gensym);

use lib "$Bin/../perl";
use LinkedSpec;

my $spec_dir = File::Spec->catdir($Bin, '..', 'specs');
my @all_specs = discover_specs($spec_dir);

my %excluded_specs = (
    'tclite.spec' => 'Deferred by current scope decision',
);

my @target_specs = grep { !exists $excluded_specs{$_} } @all_specs;
ok(@target_specs > 0, 'Discovered target specs for regression pass');
diag('Excluded specs: ' . join(', ', sort keys %excluded_specs));

subtest 'compile_all_target_specs' => sub {
    plan tests => scalar @target_specs;

    for my $spec (@target_specs) {
        my $path = File::Spec->catfile($spec_dir, $spec);
        my $content = slurp($path);

        my $parser = eval { LinkedSpec::Get(\$content) };
        my $err = $@ // '';
        ok(defined($parser) && ref($parser) eq 'CODE', "$spec builds parser coderef")
            or diag(normalize_error($err || "LinkedSpec::Get returned non-CODE for $spec"));
    }
};

subtest 'get_parser_local_resolution_without_pathsearch' => sub {
    plan tests => 4;

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before local-resolution check');

    require File::Temp;
    my $orig_cwd = getcwd();
    my $tmp_cwd = File::Temp::tempdir(CLEANUP => 1);

    my ($ok_run, $parser, $ast, $err) = (0, undef, undef, '');
    $ok_run = eval {
        chdir($tmp_cwd) or die "Unable to chdir '$tmp_cwd': $!";
        $parser = LinkedSpec::get_parser('Lispish');
        my $input = '(x y)';
        $ast = $parser ? $parser->(\$input) : undef;
        1;
    };
    $err = $@ // '';
    chdir($orig_cwd) or die "Unable to restore cwd to '$orig_cwd': $!";

    ok($ok_run, 'get_parser executes from non-project cwd') or diag(normalize_error($err));
    ok(defined($parser) && ref($parser) eq 'CODE', 'module-relative Lispish parser resolves without cwd assumptions');
    ok(defined($ast) && ref($ast) eq 'ARRAY' && !exists $INC{'PathSearch.pm'},
        'module-relative parser executes and keeps PathSearch unloaded');
};
subtest 'linkedspec_require_avoids_resolver_load_until_get_parser' => sub {
    plan tests => 5;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(
        'require LinkedSpec;'
      . 'print exists($INC{"LinkedSpec/Resolver.pm"}) ? "__RESOLVER_EAGER__\n" : "__RESOLVER_STILL_LAZY__\n";'
      . 'my $parser = LinkedSpec::get_parser("Lispish");'
      . 'print defined($parser) ? "__PARSER_DEFINED__\n" : "__PARSER_UNDEF__\n";'
      . 'print exists($INC{"LinkedSpec/Resolver.pm"}) ? "__RESOLVER_AFTER_GET_PARSER__\n" : "__RESOLVER_STILL_UNLOADED__\n";'
    );

    is($exit_code, 0, 'LinkedSpec require/get_parser subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__RESOLVER_STILL_LAZY__/, 'require LinkedSpec keeps Resolver unloaded');
    like($out, qr/__PARSER_DEFINED__/, 'get_parser still returns a parser coderef after lazy Resolver loading');
    like($out, qr/__RESOLVER_AFTER_GET_PARSER__/, 'get_parser lazy-loads Resolver when the parser-factory default deps are resolved');
    is($err, '', 'LinkedSpec require/get_parser subprocess does not emit stderr');
};
subtest 'linkedspec_require_avoids_compile_pipeline_load_until_get' => sub {
    plan tests => 8;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
my $spec_content = "Top::\n /a/ -> Top { return_a(Top) }\n";
require LinkedSpec;
print exists($INC{"LinkedSpec/Runtime.pm"}) ? "__RUNTIME_EAGER__\n" : "__RUNTIME_STILL_LAZY__\n";
print exists($INC{"LinkedSpec/Compiler.pm"}) ? "__COMPILER_EAGER__\n" : "__COMPILER_STILL_LAZY__\n";
print exists($INC{"LinkedSpec/ActionRewriter.pm"}) ? "__ACTION_REWRITER_EAGER__\n" : "__ACTION_REWRITER_STILL_LAZY__\n";
my $parser = LinkedSpec::Get(\$spec_content);
print defined($parser) ? "__PARSER_DEFINED__\n" : "__PARSER_UNDEF__\n";
print exists($INC{"LinkedSpec/Runtime.pm"}) ? "__RUNTIME_AFTER_GET__\n" : "__RUNTIME_STILL_UNLOADED__\n";
print exists($INC{"LinkedSpec/Compiler.pm"}) ? "__COMPILER_AFTER_GET__\n" : "__COMPILER_STILL_UNLOADED__\n";
print exists($INC{"LinkedSpec/ActionRewriter.pm"}) ? "__ACTION_REWRITER_AFTER_GET__\n" : "__ACTION_REWRITER_STILL_UNLOADED__\n";
PERL

    is($exit_code, 0, 'LinkedSpec require/Get subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__RUNTIME_STILL_LAZY__/, 'require LinkedSpec keeps Runtime unloaded');
    like($out, qr/__COMPILER_STILL_LAZY__/, 'require LinkedSpec keeps Compiler unloaded');
    like($out, qr/__ACTION_REWRITER_STILL_LAZY__/, 'require LinkedSpec keeps ActionRewriter unloaded');
    like($out, qr/__PARSER_DEFINED__/, 'Get still returns a parser coderef after lazy compile-pipeline loading');
    like($out, qr/__RUNTIME_AFTER_GET__/, 'Get lazy-loads Runtime');
    like($out, qr/__COMPILER_AFTER_GET__\n__ACTION_REWRITER_AFTER_GET__/, 'Get lazy-loads Compiler and ActionRewriter through the compile pipeline');
    is($err, '', 'LinkedSpec require/Get subprocess does not emit stderr');
};
subtest 'runtime_require_avoids_compiler_load_until_run_get' => sub {
    plan tests => 4;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
my $spec_content = "Top::\n /a/ -> Top { return_a(Top) }\n";
require LinkedSpec::Runtime;
print exists($INC{"LinkedSpec/Compiler.pm"}) ? "__COMPILER_EAGER__\n" : "__COMPILER_STILL_LAZY__\n";
my $parser = LinkedSpec::Runtime::run_get(\$spec_content, {});
print defined($parser) ? "__PARSER_DEFINED__\n" : "__PARSER_UNDEF__\n";
print exists($INC{"LinkedSpec/Compiler.pm"}) ? "__COMPILER_AFTER_RUN_GET__\n" : "__COMPILER_STILL_UNLOADED__\n";
PERL

    is($exit_code, 0, 'LinkedSpec::Runtime require/run_get subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__COMPILER_STILL_LAZY__/, 'require LinkedSpec::Runtime keeps Compiler unloaded');
    like($out, qr/__PARSER_DEFINED__\n__COMPILER_AFTER_RUN_GET__/, 'run_get still returns a parser coderef and lazy-loads Compiler on demand');
    is($err, '', 'LinkedSpec::Runtime require/run_get subprocess does not emit stderr');
};
subtest 'compiler_require_avoids_owner_load_until_run_get_pipeline' => sub {
    plan tests => 8;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
my $spec_content = "Top::\n /a/ -> Top { return_a(Top) }\n";
require LinkedSpec::Compiler;
print exists($INC{"LinkedSpec/BootstrapSpec.pm"}) ? "__BOOTSTRAP_EAGER__\n" : "__BOOTSTRAP_STILL_LAZY__\n";
print exists($INC{"LinkedSpec/SpecEntry.pm"}) ? "__SPEC_ENTRY_EAGER__\n" : "__SPEC_ENTRY_STILL_LAZY__\n";
print exists($INC{"LinkedSpec/Validation.pm"}) ? "__VALIDATION_EAGER__\n" : "__VALIDATION_STILL_LAZY__\n";
my $runtime_ctx = { top_rule => undef, parser_source_chunks_ref => [] };
my $descr = LinkedSpec::Compiler::run_get_pipeline(\$spec_content, { return_descr => 1 }, { runtime_ctx => $runtime_ctx });
print defined($descr) ? "__DESCR_DEFINED__\n" : "__DESCR_UNDEF__\n";
print exists($INC{"LinkedSpec/BootstrapSpec.pm"}) ? "__BOOTSTRAP_AFTER_PIPELINE__\n" : "__BOOTSTRAP_STILL_UNLOADED__\n";
print exists($INC{"LinkedSpec/SpecEntry.pm"}) ? "__SPEC_ENTRY_AFTER_PIPELINE__\n" : "__SPEC_ENTRY_STILL_UNLOADED__\n";
print exists($INC{"LinkedSpec/Validation.pm"}) ? "__VALIDATION_AFTER_PIPELINE__\n" : "__VALIDATION_STILL_UNLOADED__\n";
PERL

    is($exit_code, 0, 'LinkedSpec::Compiler require/run_get_pipeline subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__BOOTSTRAP_STILL_LAZY__/, 'require LinkedSpec::Compiler keeps BootstrapSpec unloaded');
    like($out, qr/__SPEC_ENTRY_STILL_LAZY__/, 'require LinkedSpec::Compiler keeps SpecEntry unloaded');
    like($out, qr/__VALIDATION_STILL_LAZY__/, 'require LinkedSpec::Compiler keeps Validation unloaded');
    like($out, qr/__DESCR_DEFINED__/, 'run_get_pipeline still returns a descriptor hash after owner lazy loading');
    like($out, qr/__BOOTSTRAP_AFTER_PIPELINE__/, 'run_get_pipeline lazy-loads BootstrapSpec on demand');
    like($out, qr/__SPEC_ENTRY_AFTER_PIPELINE__\n__VALIDATION_AFTER_PIPELINE__/, 'run_get_pipeline lazy-loads SpecEntry and Validation on demand');
    is($err, '', 'LinkedSpec::Compiler require/run_get_pipeline subprocess does not emit stderr');
};
subtest 'spec_entry_require_avoids_ruleir_load_until_compile_spec_entry' => sub {
    plan tests => 6;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
my $spec_content = "Top::\n /a/ -> Top { return_a(Top) }\n";
require LinkedSpec::SpecEntry;
print exists($INC{"LinkedSpec/RuleIR.pm"}) ? "__RULEIR_EAGER__\n" : "__RULEIR_STILL_LAZY__\n";
require LinkedSpec::BootstrapSpec;
my ($parse_success, $retv, $parse_error) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$spec_content);
print $parse_success ? "__BOOTSTRAP_PARSED__\n" : "__BOOTSTRAP_FAILED__\n";
my $runtime_ctx = { top_rule => undef, parser_source_chunks_ref => [] };
my ($label, $info) = $parse_success ? LinkedSpec::SpecEntry::compile_spec_entry($retv->[0], { runtime_ctx => $runtime_ctx }) : ();
print defined($label) && ref($info) eq "HASH" ? "__COMPILED_ENTRY_DEFINED__\n" : "__COMPILED_ENTRY_UNDEF__\n";
print exists($INC{"LinkedSpec/RuleIR.pm"}) ? "__RULEIR_AFTER_COMPILE_SPEC_ENTRY__\n" : "__RULEIR_STILL_UNLOADED__\n";
PERL

    is($exit_code, 0, 'LinkedSpec::SpecEntry require/compile_spec_entry subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__RULEIR_STILL_LAZY__/, 'require LinkedSpec::SpecEntry keeps RuleIR unloaded');
    like($out, qr/__BOOTSTRAP_PARSED__/, 'bootstrap parse still succeeds before compile_spec_entry lazy-loads RuleIR');
    like($out, qr/__COMPILED_ENTRY_DEFINED__/, 'compile_spec_entry still returns compiled rule info after lazy RuleIR loading');
    like($out, qr/__RULEIR_AFTER_COMPILE_SPEC_ENTRY__/, 'compile_spec_entry lazy-loads RuleIR on demand');
    is($err, '', 'LinkedSpec::SpecEntry require/compile_spec_entry subprocess does not emit stderr');
};
subtest 'ruleir_require_avoids_emit_context_load_until_emit_context_build' => sub {
    plan tests => 5;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
require LinkedSpec::RuleIR;
print exists($INC{"LinkedSpec/RuleIR/EmitContext.pm"}) ? "__EMIT_CONTEXT_EAGER__\n" : "__EMIT_CONTEXT_STILL_LAZY__\n";
my $rule_ir = {
    label => 'Top',
    node_type => 'default',
    REs => [qr/a/],
    code_blocks => {
        ICODE  => [],
        ECODE  => [],
        EXCODE => [],
        ITCODE => [],
        LXCODE => [],
        LSCODE => [],
        LECODE => [],
    },
    acode_entries => [
        { relabel => 'Top', reidx => 0, code => 'return_a(Top)' },
    ],
    bcode_entries => [],
};
my $emit_ctx = LinkedSpec::RuleIR::_build_rule_ir_emit_context($rule_ir);
print defined($emit_ctx) ? "__EMIT_CTX_DEFINED__\n" : "__EMIT_CTX_UNDEF__\n";
print exists($INC{"LinkedSpec/RuleIR/EmitContext.pm"}) ? "__EMIT_CONTEXT_AFTER_BUILD__\n" : "__EMIT_CONTEXT_STILL_UNLOADED__\n";
PERL

    is($exit_code, 0, 'LinkedSpec::RuleIR require/build subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__EMIT_CONTEXT_STILL_LAZY__/, 'require LinkedSpec::RuleIR keeps EmitContext unloaded');
    like($out, qr/__EMIT_CTX_DEFINED__/, 'RuleIR emit-context build still succeeds after lazy EmitContext loading');
    like($out, qr/__EMIT_CONTEXT_AFTER_BUILD__/, 'RuleIR emit-context build lazy-loads EmitContext on demand');
    is($err, '', 'LinkedSpec::RuleIR require/build subprocess does not emit stderr');
};
subtest 'bootstrap_spec_require_avoids_core_load_until_bootstrap_state_build' => sub {
    plan tests => 5;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
my $spec_content = "Top::\n /a/ -> Top { return_a(Top) }\n";
require LinkedSpec::BootstrapSpec;
print exists($INC{"LinkedSpec/BootstrapSpec/Core.pm"}) ? "__BOOTSTRAP_CORE_EAGER__\n" : "__BOOTSTRAP_CORE_STILL_LAZY__\n";
my ($parse_success, $retv, $parse_error) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$spec_content);
print $parse_success ? "__BOOTSTRAP_PARSE_DEFINED__\n" : "__BOOTSTRAP_PARSE_FAILED__\n";
print exists($INC{"LinkedSpec/BootstrapSpec/Core.pm"}) ? "__BOOTSTRAP_CORE_AFTER_PARSE__\n" : "__BOOTSTRAP_CORE_STILL_UNLOADED__\n";
PERL

    is($exit_code, 0, 'LinkedSpec::BootstrapSpec require/run_bootstrap_parse subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__BOOTSTRAP_CORE_STILL_LAZY__/, 'require LinkedSpec::BootstrapSpec keeps BootstrapSpec::Core unloaded');
    like($out, qr/__BOOTSTRAP_PARSE_DEFINED__/, 'run_bootstrap_parse still succeeds after lazy BootstrapSpec::Core loading');
    like($out, qr/__BOOTSTRAP_CORE_AFTER_PARSE__/, 'run_bootstrap_parse lazy-loads BootstrapSpec::Core on demand');
    is($err, '', 'LinkedSpec::BootstrapSpec require/run_bootstrap_parse subprocess does not emit stderr');
};
subtest 'actionir_scanner_require_avoids_scannercore_load_until_scan' => sub {
    plan tests => 6;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
require LinkedSpec::ActionIR::Scanner;
print exists($INC{"LinkedSpec/ActionIR/ScannerCore.pm"}) ? "__SCANNERCORE_EAGER__\n" : "__SCANNERCORE_STILL_LAZY__\n";
my $events = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
    { id => 'return_bare' },
    "return foo;",
    {
        split_action_ir_statements => sub { return ['return foo'] },
        trim_action_ir_value => sub {
            my ($value) = @_;
            return undef unless defined $value;
            $value =~ s/^\s+//;
            $value =~ s/\s+$//;
            return $value;
        },
        parse_method_function_expr => sub { die "__UNEXPECTED_PARSE_METHOD_FUNCTION_EXPR__\n" },
        normalize_method_args_with_optional_scope => sub { die "__UNEXPECTED_NORMALIZE_METHOD_ARGS__\n" },
        build_array_pipeline_plan_from_expr => sub { die "__UNEXPECTED_BUILD_ARRAY_PIPELINE_PLAN__\n" },
        extract_declare_statement_from_method_expr => sub { die "__UNEXPECTED_EXTRACT_DECLARE_STATEMENT__\n" },
        parse_declare_binding_entry => sub { die "__UNEXPECTED_PARSE_DECLARE_BINDING_ENTRY__\n" },
    },
);
print ref($events) eq "ARRAY" ? "__EVENTS_ARRAY__\n" : "__EVENTS_OTHER__\n";
print exists($INC{"LinkedSpec/ActionIR/ScannerCore.pm"}) ? "__SCANNERCORE_AFTER_SCAN__\n" : "__SCANNERCORE_STILL_UNLOADED__\n";
print scalar(@{$events || []}) == 1 && $events->[0]{raw} eq "return foo" ? "__EVENT_PAYLOAD_OK__\n" : "__EVENT_PAYLOAD_BAD__\n";
PERL

    is($exit_code, 0, 'ActionIR::Scanner require/scan subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__SCANNERCORE_STILL_LAZY__/, 'require ActionIR::Scanner keeps ScannerCore unloaded');
    like($out, qr/__EVENTS_ARRAY__/, 'scanner scan still returns an event array after lazy ScannerCore loading');
    like($out, qr/__SCANNERCORE_AFTER_SCAN__/, 'scanner scan lazy-loads ScannerCore on demand');
    like($out, qr/__EVENT_PAYLOAD_OK__/, 'scanner scan preserves return-bare payload after lazy ScannerCore loading');
    is($err, '', 'ActionIR::Scanner require/scan subprocess does not emit stderr');
};
subtest 'actionir_scannercore_require_avoids_scanner_rule_load_until_scan' => sub {
    plan tests => 6;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
require LinkedSpec::ActionIR::ScannerCore;
my @rule_paths = (
    "LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm",
    "LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm",
    "LinkedSpec/ActionIR/Scanner/FlowRules.pm",
    "LinkedSpec/ActionIR/Scanner/LegacyRules.pm",
);
my $loaded_before = scalar grep { exists $INC{$_} } @rule_paths;
print $loaded_before == 0 ? "__SCANNER_RULES_STILL_LAZY__\n" : "__SCANNER_RULES_EAGER__\n";
my $events = LinkedSpec::ActionIR::ScannerCore::scan_contract_ir_events(
    { id => 'return_bare' },
    "return foo;",
    {
        split_action_ir_statements => sub { return ['return foo'] },
        trim_action_ir_value => sub {
            my ($value) = @_;
            return undef unless defined $value;
            $value =~ s/^\s+//;
            $value =~ s/\s+$//;
            return $value;
        },
        parse_method_function_expr => sub { die "__UNEXPECTED_PARSE_METHOD_FUNCTION_EXPR__\n" },
        normalize_method_args_with_optional_scope => sub { die "__UNEXPECTED_NORMALIZE_METHOD_ARGS__\n" },
        build_array_pipeline_plan_from_expr => sub { die "__UNEXPECTED_BUILD_ARRAY_PIPELINE_PLAN__\n" },
        extract_declare_statement_from_method_expr => sub { die "__UNEXPECTED_EXTRACT_DECLARE_STATEMENT__\n" },
        parse_declare_binding_entry => sub { die "__UNEXPECTED_PARSE_DECLARE_BINDING_ENTRY__\n" },
    },
);
print ref($events) eq "ARRAY" ? "__SCANNER_RULE_EVENTS_ARRAY__\n" : "__SCANNER_RULE_EVENTS_OTHER__\n";
my $loaded_after = scalar grep { exists $INC{$_} } @rule_paths;
print $loaded_after == scalar(@rule_paths) ? "__SCANNER_RULES_AFTER_SCAN__\n" : "__SCANNER_RULES_PARTIAL__\n";
print scalar(@{$events || []}) == 1 && $events->[0]{raw} eq "return foo" ? "__SCANNER_RULE_PAYLOAD_OK__\n" : "__SCANNER_RULE_PAYLOAD_BAD__\n";
PERL

    is($exit_code, 0, 'ActionIR::ScannerCore require/scan subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__SCANNER_RULES_STILL_LAZY__/, 'require ActionIR::ScannerCore keeps scanner rule modules unloaded');
    like($out, qr/__SCANNER_RULE_EVENTS_ARRAY__/, 'scanner-core scan still returns an event array after lazy scanner rule loading');
    like($out, qr/__SCANNER_RULES_AFTER_SCAN__/, 'scanner-core scan lazy-loads scanner rule modules on demand');
    like($out, qr/__SCANNER_RULE_PAYLOAD_OK__/, 'scanner-core scan preserves return-bare payload after lazy scanner rule loading');
    is($err, '', 'ActionIR::ScannerCore require/scan subprocess does not emit stderr');
};
subtest 'actionir_statement_split_require_avoids_core_load_until_split' => sub {
    plan tests => 6;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
require LinkedSpec::ActionIR::StatementSplit;
print exists($INC{"LinkedSpec/ActionIR/StatementSplit/Core.pm"}) ? "__STATEMENT_SPLIT_CORE_EAGER__\n" : "__STATEMENT_SPLIT_CORE_STILL_LAZY__\n";
my $parts = LinkedSpec::ActionIR::StatementSplit::_split_action_ir_statements(
    "return foo; exit",
    {
        trim_action_ir_value => sub {
            my ($value) = @_;
            return undef unless defined $value;
            $value =~ s/^\s+//;
            $value =~ s/\s+$//;
            return $value;
        },
    },
);
print ref($parts) eq "ARRAY" ? "__STATEMENT_PARTS_ARRAY__\n" : "__STATEMENT_PARTS_OTHER__\n";
print exists($INC{"LinkedSpec/ActionIR/StatementSplit/Core.pm"}) ? "__STATEMENT_SPLIT_CORE_AFTER_SPLIT__\n" : "__STATEMENT_SPLIT_CORE_STILL_UNLOADED__\n";
print scalar(@{$parts || []}) == 2 && $parts->[0] eq "return foo" && $parts->[1] eq "exit" ? "__STATEMENT_PARTS_OK__\n" : "__STATEMENT_PARTS_BAD__\n";
PERL

    is($exit_code, 0, 'ActionIR::StatementSplit require/split subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__STATEMENT_SPLIT_CORE_STILL_LAZY__/, 'require ActionIR::StatementSplit keeps StatementSplit::Core unloaded');
    like($out, qr/__STATEMENT_PARTS_ARRAY__/, 'statement split still returns an array after lazy StatementSplit::Core loading');
    like($out, qr/__STATEMENT_SPLIT_CORE_AFTER_SPLIT__/, 'statement split lazy-loads StatementSplit::Core on demand');
    like($out, qr/__STATEMENT_PARTS_OK__/, 'statement split preserves split output after lazy StatementSplit::Core loading');
    is($err, '', 'ActionIR::StatementSplit require/split subprocess does not emit stderr');
};
subtest 'actionir_statement_split_core_require_avoids_mode_load_until_split' => sub {
    plan tests => 6;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
require LinkedSpec::ActionIR::StatementSplit::Core;
print exists($INC{"LinkedSpec/ActionIR/StatementSplit/Mode.pm"}) ? "__STATEMENT_SPLIT_MODE_EAGER__\n" : "__STATEMENT_SPLIT_MODE_STILL_LAZY__\n";
my $parts = LinkedSpec::ActionIR::StatementSplit::Core::split_action_ir_statements(
    "return foo; exit",
    sub {
        my ($value) = @_;
        return undef unless defined $value;
        $value =~ s/^\s+//;
        $value =~ s/\s+$//;
        return $value;
    },
);
print ref($parts) eq "ARRAY" ? "__STATEMENT_CORE_PARTS_ARRAY__\n" : "__STATEMENT_CORE_PARTS_OTHER__\n";
print exists($INC{"LinkedSpec/ActionIR/StatementSplit/Mode.pm"}) ? "__STATEMENT_SPLIT_MODE_AFTER_SPLIT__\n" : "__STATEMENT_SPLIT_MODE_STILL_UNLOADED__\n";
print scalar(@{$parts || []}) == 2 && $parts->[0] eq "return foo" && $parts->[1] eq "exit" ? "__STATEMENT_CORE_PARTS_OK__\n" : "__STATEMENT_CORE_PARTS_BAD__\n";
PERL

    is($exit_code, 0, 'ActionIR::StatementSplit::Core require/split subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__STATEMENT_SPLIT_MODE_STILL_LAZY__/, 'require ActionIR::StatementSplit::Core keeps StatementSplit::Mode unloaded');
    like($out, qr/__STATEMENT_CORE_PARTS_ARRAY__/, 'statement-split core still returns an array after lazy StatementSplit::Mode loading');
    like($out, qr/__STATEMENT_SPLIT_MODE_AFTER_SPLIT__/, 'statement-split core lazy-loads StatementSplit::Mode on demand');
    like($out, qr/__STATEMENT_CORE_PARTS_OK__/, 'statement-split core preserves split output after lazy StatementSplit::Mode loading');
    is($err, '', 'ActionIR::StatementSplit::Core require/split subprocess does not emit stderr');
};
subtest 'actionir_canonical_events_require_avoids_core_load_until_build' => sub {
    plan tests => 6;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
require LinkedSpec::ActionIR::CanonicalEvents;
print exists($INC{"LinkedSpec/ActionIR/CanonicalEvents/Core.pm"}) ? "__CANONICAL_EVENTS_CORE_EAGER__\n" : "__CANONICAL_EVENTS_CORE_STILL_LAZY__\n";
my $diag = LinkedSpec::ActionIR::CanonicalEvents::_build_canonical_action_ir_events(
    'Top',
    'return_a(Top)',
    [{ raw => 'return_a(Top)', args => { label => 'Top' }, contract_id => 'return_a', ir_node => 'RETURN' }],
    {
        trim_action_ir_value => sub {
            my ($value) = @_;
            return undef unless defined $value;
            $value =~ s/^\s+//;
            $value =~ s/\s+$//;
            return $value;
        },
        split_action_ir_statements => sub { return ['return_a(Top)'] },
    },
);
print ref($diag) eq "HASH" ? "__CANONICAL_EVENTS_DIAG_HASH__\n" : "__CANONICAL_EVENTS_DIAG_OTHER__\n";
print exists($INC{"LinkedSpec/ActionIR/CanonicalEvents/Core.pm"}) ? "__CANONICAL_EVENTS_CORE_AFTER_BUILD__\n" : "__CANONICAL_EVENTS_CORE_STILL_UNLOADED__\n";
print ref($diag->{canonical_action_ir_nodes}) eq "ARRAY" && @{$diag->{canonical_action_ir_nodes}} == 1 && $diag->{canonical_action_ir_nodes}[0] eq "RETURN_A" ? "__CANONICAL_EVENTS_NODES_OK__\n" : "__CANONICAL_EVENTS_NODES_BAD__\n";
PERL

    is($exit_code, 0, 'ActionIR::CanonicalEvents require/build subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__CANONICAL_EVENTS_CORE_STILL_LAZY__/, 'require ActionIR::CanonicalEvents keeps CanonicalEvents::Core unloaded');
    like($out, qr/__CANONICAL_EVENTS_DIAG_HASH__/, 'canonical-event build still returns a hash after lazy CanonicalEvents::Core loading');
    like($out, qr/__CANONICAL_EVENTS_CORE_AFTER_BUILD__/, 'canonical-event build lazy-loads CanonicalEvents::Core on demand');
    like($out, qr/__CANONICAL_EVENTS_NODES_OK__/, 'canonical-event build preserves classification output after lazy CanonicalEvents::Core loading');
    is($err, '', 'ActionIR::CanonicalEvents require/build subprocess does not emit stderr');
};
subtest 'linkedspec_require_avoids_compiler_load_until_spec_descr' => sub {
    plan tests => 6;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
my $spec_content = "Top::\n /a/ -> Top { return_a(Top) }\n";
require LinkedSpec;
require LinkedSpec::BootstrapSpec;
print exists($INC{"LinkedSpec/Compiler.pm"}) ? "__COMPILER_EAGER__\n" : "__COMPILER_STILL_LAZY__\n";
my ($parse_success, $retv, $parse_error) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$spec_content);
print $parse_success ? "__BOOTSTRAP_PARSED__\n" : "__BOOTSTRAP_FAILED__\n";
my $compiled = $parse_success ? LinkedSpec::spec_descr($retv) : undef;
print defined($compiled) ? "__SPEC_DESCR_DEFINED__\n" : "__SPEC_DESCR_UNDEF__\n";
print exists($INC{"LinkedSpec/Compiler.pm"}) ? "__COMPILER_AFTER_SPEC_DESCR__\n" : "__COMPILER_STILL_UNLOADED__\n";
PERL

    is($exit_code, 0, 'LinkedSpec require/spec_descr subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__COMPILER_STILL_LAZY__/, 'require LinkedSpec keeps Compiler unloaded before spec_descr');
    like($out, qr/__BOOTSTRAP_PARSED__/, 'bootstrap parse still succeeds before spec_descr lazy-loads Compiler');
    like($out, qr/__SPEC_DESCR_DEFINED__/, 'spec_descr still returns compiled rule data after lazy Compiler loading');
    like($out, qr/__COMPILER_AFTER_SPEC_DESCR__/, 'spec_descr lazy-loads Compiler on demand');
    is($err, '', 'LinkedSpec require/spec_descr subprocess does not emit stderr');
};
subtest 'linkedspec_require_avoids_action_rewriter_load_until_compat_helper' => sub {
    plan tests => 5;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(
        'require LinkedSpec;'
      . 'print exists($INC{"LinkedSpec/ActionRewriter.pm"}) ? "__ACTION_REWRITER_EAGER__\n" : "__ACTION_REWRITER_STILL_LAZY__\n";'
      . 'my $rewritten = LinkedSpec::call_spec_handler_subst("Top", "return_a(Top)");'
      . 'print defined($rewritten) ? "__REWRITE_DEFINED__\n" : "__REWRITE_UNDEF__\n";'
      . 'print exists($INC{"LinkedSpec/ActionRewriter.pm"}) ? "__ACTION_REWRITER_AFTER_HELPER__\n" : "__ACTION_REWRITER_STILL_UNLOADED__\n";'
    );

    is($exit_code, 0, 'LinkedSpec require/helper subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__ACTION_REWRITER_STILL_LAZY__/, 'require LinkedSpec keeps ActionRewriter unloaded before the compatibility helper is used');
    like($out, qr/__REWRITE_DEFINED__/, 'call_spec_handler_subst still returns rewritten helper code after lazy ActionRewriter loading');
    like($out, qr/__ACTION_REWRITER_AFTER_HELPER__/, 'call_spec_handler_subst lazy-loads ActionRewriter on demand');
    is($err, '', 'LinkedSpec require/helper subprocess does not emit stderr');
};
subtest 'linkedspec_require_avoids_parser_factory_load_until_get_parser' => sub {
    plan tests => 5;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(
        'require LinkedSpec;'
      . 'print exists($INC{"LinkedSpec/ParserFactory.pm"}) ? "__PARSER_FACTORY_EAGER__\n" : "__PARSER_FACTORY_STILL_LAZY__\n";'
      . 'my $parser = LinkedSpec::get_parser("Lispish");'
      . 'print defined($parser) ? "__PARSER_DEFINED__\n" : "__PARSER_UNDEF__\n";'
      . 'print exists($INC{"LinkedSpec/ParserFactory.pm"}) ? "__PARSER_FACTORY_AFTER_GET_PARSER__\n" : "__PARSER_FACTORY_STILL_UNLOADED__\n";'
    );

    is($exit_code, 0, 'LinkedSpec require/get_parser subprocess exits cleanly with lazy ParserFactory') or diag($err || $out);
    like($out, qr/__PARSER_FACTORY_STILL_LAZY__/, 'require LinkedSpec keeps ParserFactory unloaded');
    like($out, qr/__PARSER_DEFINED__/, 'get_parser still returns a parser coderef after lazy ParserFactory loading');
    like($out, qr/__PARSER_FACTORY_AFTER_GET_PARSER__/, 'get_parser lazy-loads ParserFactory on demand');
    is($err, '', 'LinkedSpec require/get_parser subprocess with lazy ParserFactory does not emit stderr');
};
subtest 'linkedspec_require_avoids_plugin_bridge_load_until_autoload' => sub {
    plan tests => 6;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
require LinkedSpec;
require PPlugin;
no warnings 'redefine';
local *PPlugin::exec_plugin_name = sub {
    my ($class_or_self, $plugin_name, @args) = @_;
    print "__PLUGIN_NAME__=$plugin_name\n";
    print "__ARGS__=" . join(',', @args) . "\n";
    return 'plugin_ok';
};
print exists($INC{"LinkedSpec/PluginBridge.pm"}) ? "__PLUGIN_BRIDGE_EAGER__\n" : "__PLUGIN_BRIDGE_STILL_LAZY__\n";
my $ret = LinkedSpec::synthetic_plugin('alpha', 'beta');
print "__RET__=$ret\n";
print exists($INC{"LinkedSpec/PluginBridge.pm"}) ? "__PLUGIN_BRIDGE_AFTER_AUTOLOAD__\n" : "__PLUGIN_BRIDGE_STILL_UNLOADED__\n";
PERL

    is($exit_code, 0, 'LinkedSpec require/AUTOLOAD subprocess exits cleanly with lazy PluginBridge') or diag($err || $out);
    like($out, qr/__PLUGIN_BRIDGE_STILL_LAZY__/, 'require LinkedSpec keeps PluginBridge unloaded');
    like($out, qr/__PLUGIN_NAME__=synthetic_plugin/, 'AUTOLOAD still normalizes through PluginBridge after lazy load');
    like($out, qr/__ARGS__=alpha,beta/, 'AUTOLOAD still forwards plugin arguments after lazy PluginBridge loading');
    like($out, qr/__RET__=plugin_ok\n__PLUGIN_BRIDGE_AFTER_AUTOLOAD__/, 'AUTOLOAD lazy-loads PluginBridge on demand and preserves return payload');
    is($err, '', 'LinkedSpec require/AUTOLOAD subprocess with lazy PluginBridge does not emit stderr');
};
subtest 'autoload_avoids_plugin_bridge_wrapper' => sub {
    plan tests => 5;

    my ($ok_run, $ret, $err) = (0, undef, '');
    my ($captured_name, @captured_args);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::PluginBridge::_dispatch_autoload = sub {
            my ($autoload_name, $args) = @_;
            ($captured_name, @captured_args) = ($autoload_name, @{$args // []});
            return {
                autoload_name => $captured_name,
                args => [@captured_args],
            };
        };
        $ret = LinkedSpec::synthetic_plugin('alpha', 'beta');
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'AUTOLOAD succeeds while the PluginBridge owner path is trapped') or diag(normalize_error($err));
    is($captured_name, 'LinkedSpec::synthetic_plugin', 'AUTOLOAD forwards the fully-qualified method name into PluginBridge');
    is_deeply(\@captured_args, [qw(alpha beta)], 'AUTOLOAD forwards plugin arguments into PluginBridge unchanged');
    ok(ref($ret) eq 'HASH', 'AUTOLOAD returns the PluginBridge owner-path result');
    is_deeply($ret->{args}, [qw(alpha beta)], 'AUTOLOAD preserves the PluginBridge return payload');
};
subtest 'get_parser_avoids_linkedspec_parser_factory_facade' => sub {
    plan tests => 8;

    require File::Temp;
    my $orig_cwd = getcwd();
    my $tmp_cwd = File::Temp::tempdir(CLEANUP => 1);
    my $tmp_log = File::Spec->catfile($tmp_cwd, 'parser_factory_trace.log');

    my ($ok_run, $parser, $ast, $err) = (0, undef, undef, '');
    $ok_run = eval {
        no warnings 'redefine';
        local $LinkedSpec::Trace::DUMP_VERBOSITY = LinkedSpec::Trace::DUMP_NONE();
        local $LinkedSpec::Trace::TRACE_LOG_FILE;
        local $LinkedSpec::Trace::TRACE_LOG_MODE = 'stdout';
        local $LinkedSpec::Trace::TRACE_EMOJI = 0;
        local $LinkedSpec::Trace::TRACE_INDENT_LEVEL = 0;
        local $LinkedSpec::Trace::TRACE_INITIALIZED = 1;
        local *LinkedSpec::_trace_level_name = sub { die "__UNEXPECTED_LINKEDSPEC_TRACE_LEVEL_NAME__\n" };
        local *LinkedSpec::_apply_trace_options = sub { die "__UNEXPECTED_LINKEDSPEC_APPLY_TRACE_OPTIONS__\n" };
        local *LinkedSpec::trace_enter = sub { die "__UNEXPECTED_LINKEDSPEC_TRACE_ENTER__\n" };
        local *LinkedSpec::trace_exit = sub { die "__UNEXPECTED_LINKEDSPEC_TRACE_EXIT__\n" };
        local *LinkedSpec::trace_decision = sub { die "__UNEXPECTED_LINKEDSPEC_TRACE_DECISION__\n" };
        local *LinkedSpec::Get = sub { die "__UNEXPECTED_LINKEDSPEC_GET__\n" };
        local *LinkedSpec::DUMP_LOW = sub { die "__UNEXPECTED_LINKEDSPEC_DUMP_LOW__\n" };
        local *LinkedSpec::DUMP_MEDIUM = sub { die "__UNEXPECTED_LINKEDSPEC_DUMP_MEDIUM__\n" };
        local *LinkedSpec::Runtime::run_get_from_args = sub { die "__UNEXPECTED_RUNTIME_RUN_GET_FROM_ARGS__\n" };

        chdir($tmp_cwd) or die "Unable to chdir '$tmp_cwd': $!";
        $parser = LinkedSpec::get_parser(
            'Lispish',
            trace_level => 'high',
            trace_log_file => $tmp_log,
            trace_log_mode => 'route',
            trace_reset_log => 1,
        );
        my $input = '(facade test)';
        $ast = $parser ? $parser->(\$input) : undef;
        1;
    };
    $err = $@ // '' unless $ok_run;
    chdir($orig_cwd) or die "Unable to restore cwd to '$orig_cwd': $!";

    ok($ok_run, 'get_parser succeeds without LinkedSpec parser-factory facade helpers')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_(?:LINKEDSPEC|RUNTIME)_/, 'get_parser does not call the trapped LinkedSpec parser-factory facade helpers or Runtime raw-arg wrapper');
    ok(defined($parser) && ref($parser) eq 'CODE', 'get_parser still returns parser coderef through extracted parser-factory dependencies');
    ok(defined($ast) && ref($ast) eq 'ARRAY', 'parser created through extracted parser-factory dependencies still executes');
    ok(!exists $INC{'PathSearch.pm'}, 'module-relative parser-factory path still keeps PathSearch unloaded');
    ok(-f $tmp_log, 'trace log file created through extracted Trace dependency path');

    my $trace_log = slurp($tmp_log);
    like($trace_log, qr/ENTER LinkedSpec::get_parser/, 'trace log records get_parser entry through extracted Trace dependency path');
    like($trace_log, qr/parser coderef generated/, 'trace log records parser compilation result through extracted Runtime dependency path');
};
subtest 'plugin_bridge_supports_injected_plugin_runtime_deps' => sub {
    plan tests => 6;
    require LinkedSpec::PluginBridge;

    my $load_calls = 0;
    my ($exec_plugin_name, @exec_args);
    my $ret = LinkedSpec::PluginBridge::_dispatch_autoload(
        'LinkedSpec::synthetic_plugin',
        ['alpha', 'beta'],
        {
            load_plugin_runtime => sub {
                ++$load_calls;
                return 1;
            },
            exec_plugin => sub {
                ($exec_plugin_name, @exec_args) = @_;
                return {
                    plugin_name => $exec_plugin_name,
                    args => [@exec_args],
                };
            },
        },
    );

    is($load_calls, 1, 'PluginBridge injected runtime deps invoke the load callback exactly once');
    is($exec_plugin_name, 'synthetic_plugin', 'PluginBridge injected runtime deps normalize the autoload name into a plugin name before exec callback dispatch');
    is_deeply(\@exec_args, [qw(alpha beta)], 'PluginBridge injected runtime deps forward plugin arguments into exec callback');
    ok(ref($ret) eq 'HASH', 'PluginBridge injected runtime deps return exec callback payload');
    is($ret->{plugin_name}, 'synthetic_plugin', 'PluginBridge injected runtime deps preserve returned normalized plugin name payload');
    is_deeply($ret->{args}, [qw(alpha beta)], 'PluginBridge injected runtime deps preserve returned argument payload');
};
subtest 'plugin_bridge_dispatch_plugin_name_supports_injected_runtime_deps' => sub {
    plan tests => 6;
    require LinkedSpec::PluginBridge;

    my $load_calls = 0;
    my ($exec_plugin_name, @exec_args);
    my $ret = LinkedSpec::PluginBridge::_dispatch_plugin_name(
        'synthetic_plugin',
        ['alpha', 'beta'],
        {
            load_plugin_runtime => sub {
                ++$load_calls;
                return 1;
            },
            exec_plugin => sub {
                ($exec_plugin_name, @exec_args) = @_;
                return {
                    plugin_name => $exec_plugin_name,
                    args => [@exec_args],
                };
            },
        },
    );

    is($load_calls, 1, 'PluginBridge explicit-name dispatch invokes the load callback exactly once');
    is($exec_plugin_name, 'synthetic_plugin', 'PluginBridge explicit-name dispatch forwards the explicit plugin name unchanged');
    is_deeply(\@exec_args, [qw(alpha beta)], 'PluginBridge explicit-name dispatch forwards plugin arguments unchanged');
    ok(ref($ret) eq 'HASH', 'PluginBridge explicit-name dispatch returns exec callback payload');
    is($ret->{plugin_name}, 'synthetic_plugin', 'PluginBridge explicit-name dispatch preserves returned plugin name payload');
    is_deeply($ret->{args}, [qw(alpha beta)], 'PluginBridge explicit-name dispatch preserves returned argument payload');
};
subtest 'plugin_bridge_dispatch_plugin_name_rejects_invalid_name_before_runtime_load' => sub {
    plan tests => 4;
    require LinkedSpec::PluginBridge;

    my ($load_calls, $exec_calls) = (0, 0);
    my ($ok_run, $err) = (0, '');
    $ok_run = eval {
        LinkedSpec::PluginBridge::_dispatch_plugin_name(
            'LinkedSpec::synthetic_plugin',
            ['alpha'],
            {
                load_plugin_runtime => sub {
                    ++$load_calls;
                    return 1;
                },
                exec_plugin => sub {
                    ++$exec_calls;
                    return 'unexpected';
                },
            },
        );
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok(!$ok_run, 'PluginBridge explicit-name dispatch dies on invalid explicit plugin names before runtime dispatch');
    like($err, qr/invalid plugin name/i, 'PluginBridge explicit-name dispatch reports invalid explicit plugin names clearly');
    is($load_calls, 0, 'PluginBridge explicit-name dispatch does not load plugin runtime for invalid explicit plugin names');
    is($exec_calls, 0, 'PluginBridge explicit-name dispatch does not call exec callback for invalid explicit plugin names');
};
subtest 'plugin_bridge_default_load_dep_uses_legacy_runtime_owner' => sub {
    plan tests => 4;
    require LinkedSpec::PluginBridge;

    my ($ok_run, $ret, $err) = (0, undef, '');
    my $load_calls = 0;
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::PluginBridge::_load_legacy_plugin_runtime = sub {
            ++$load_calls;
            return 'legacy_runtime_loaded';
        };
        my $deps = LinkedSpec::PluginBridge::_default_deps();
        $ret = $deps->{load_plugin_runtime}->();
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'PluginBridge default load dep succeeds while the legacy runtime owner is trapped')
        or diag(normalize_error($err));
    is($load_calls, 1, 'PluginBridge default load dep calls the legacy runtime owner exactly once');
    is($ret, 'legacy_runtime_loaded', 'PluginBridge default load dep preserves the legacy runtime owner return payload');
    like(ref(LinkedSpec::PluginBridge::_default_deps()->{load_plugin_runtime}), qr/CODE/, 'PluginBridge default load dep remains callable after the owner trap test');
};
subtest 'plugin_bridge_default_exec_dep_uses_legacy_exec_owner' => sub {
    plan tests => 6;
    require LinkedSpec::PluginBridge;

    my ($ok_run, $ret, $err) = (0, undef, '');
    my ($exec_calls, $captured_plugin_name, @captured_args) = (0, undef);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::PluginBridge::_exec_legacy_plugin = sub {
            my ($plugin_name, @args) = @_;
            ++$exec_calls;
            ($captured_plugin_name, @captured_args) = ($plugin_name, @args);
            return {
                plugin_name => $plugin_name,
                args => [@args],
            };
        };
        my $deps = LinkedSpec::PluginBridge::_default_deps();
        $ret = $deps->{exec_plugin}->('synthetic_plugin', 'alpha', 'beta');
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'PluginBridge default exec dep succeeds while the legacy exec owner is trapped')
        or diag(normalize_error($err));
    is($exec_calls, 1, 'PluginBridge default exec dep calls the legacy exec owner exactly once');
    is($captured_plugin_name, 'synthetic_plugin', 'PluginBridge default exec dep forwards the explicit plugin name unchanged into the legacy exec owner');
    is_deeply(\@captured_args, [qw(alpha beta)], 'PluginBridge default exec dep forwards plugin arguments unchanged into the legacy exec owner');
    ok(ref($ret) eq 'HASH', 'PluginBridge default exec dep preserves the legacy exec owner payload type');
    is_deeply($ret, { plugin_name => 'synthetic_plugin', args => [qw(alpha beta)] }, 'PluginBridge default exec dep preserves the legacy exec owner return payload');
};
subtest 'plugin_bridge_autoload_uses_dispatch_plugin_name_owner' => sub {
    plan tests => 5;
    require LinkedSpec::PluginBridge;

    my ($ok_run, $ret, $err) = (0, undef, '');
    my ($captured_plugin_name, @captured_args);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::PluginBridge::_dispatch_plugin_name = sub {
            my ($plugin_name, $args) = @_;
            ($captured_plugin_name, @captured_args) = ($plugin_name, @{$args // []});
            return {
                plugin_name => $plugin_name,
                args => [@captured_args],
            };
        };
        $ret = LinkedSpec::PluginBridge::_dispatch_autoload('LinkedSpec::synthetic_plugin', ['alpha', 'beta']);
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'PluginBridge autoload dispatch succeeds while the explicit-name owner path is trapped')
        or diag(normalize_error($err));
    is($captured_plugin_name, 'synthetic_plugin', 'PluginBridge autoload dispatch normalizes the autoload name before delegating');
    is_deeply(\@captured_args, [qw(alpha beta)], 'PluginBridge autoload dispatch forwards plugin arguments unchanged into the explicit-name owner');
    ok(ref($ret) eq 'HASH', 'PluginBridge autoload dispatch returns the explicit-name owner payload');
    is_deeply($ret->{args}, [qw(alpha beta)], 'PluginBridge autoload dispatch preserves the explicit-name owner return payload');
};
subtest 'plugin_bridge_rejects_invalid_autoload_name_before_runtime_load' => sub {
    plan tests => 4;
    require LinkedSpec::PluginBridge;

    my ($load_calls, $exec_calls) = (0, 0);
    my ($ok_run, $err) = (0, '');
    $ok_run = eval {
        LinkedSpec::PluginBridge::_dispatch_autoload(
            'LinkedSpec::',
            ['alpha'],
            {
                load_plugin_runtime => sub {
                    ++$load_calls;
                    return 1;
                },
                exec_plugin => sub {
                    ++$exec_calls;
                    return 'unexpected';
                },
            },
        );
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok(!$ok_run, 'PluginBridge dies on invalid autoload names before attempting runtime dispatch');
    like($err, qr/invalid autoload name/i, 'PluginBridge reports invalid autoload names clearly');
    is($load_calls, 0, 'PluginBridge does not load plugin runtime for invalid autoload names');
    is($exec_calls, 0, 'PluginBridge does not call exec callback for invalid autoload names');
};
subtest 'plugin_bridge_default_exec_dep_uses_pplugin_explicit_name_owner' => sub {
    plan tests => 6;

    require LinkedSpec::PluginBridge;
    require PPlugin;

    my $deps = LinkedSpec::PluginBridge::_default_deps();
    my ($ok_run, $ret, $err) = (0, undef, '');
    my ($exec_calls, $captured_plugin_name, @captured_args) = (0, undef);

    $ok_run = eval {
        no warnings 'redefine';
        local *PPlugin::exec = sub { die "__UNEXPECTED_PPLUGIN_EXEC__\n" };
        local *PPlugin::exec_plugin_name = sub {
            my ($class_or_self, $plugin_name, @args) = @_;
            ++$exec_calls;
            ($captured_plugin_name, @captured_args) = ($plugin_name, @args);
            return {
                plugin_name => $plugin_name,
                args => [@args],
            };
        };
        $ret = $deps->{exec_plugin}->('synthetic_plugin', 'alpha', 'beta');
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'PluginBridge default exec dep succeeds while PPlugin exec wrapper is trapped')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_PPLUGIN_EXEC__/, 'PluginBridge default exec dep avoids the legacy mixed-name PPlugin exec wrapper');
    is($exec_calls, 1, 'PluginBridge default exec dep calls the explicit PPlugin plugin-name owner exactly once');
    is($captured_plugin_name, 'synthetic_plugin', 'PluginBridge default exec dep forwards the normalized plugin name unchanged');
    is_deeply(\@captured_args, [qw(alpha beta)], 'PluginBridge default exec dep forwards plugin arguments unchanged');
    is_deeply($ret, { plugin_name => 'synthetic_plugin', args => [qw(alpha beta)] }, 'PluginBridge default exec dep preserves the explicit-owner return payload');
};
subtest 'pplugin_legacy_plugin_search_roots_are_cwd_first_and_deduped' => sub {
    plan tests => 2;

    require File::Temp;
    require PPlugin;

    my $tmp_root = File::Temp::tempdir(CLEANUP => 1);
    my $cwd_root = File::Spec->catdir($tmp_root, 'cwd');
    my $project_root = File::Spec->catdir($tmp_root, 'project');
    mkdir $cwd_root or die "Unable to create cwd-root '$cwd_root': $!";
    mkdir $project_root or die "Unable to create project-root '$project_root': $!";
    mkdir File::Spec->catdir($project_root, 'plugin') or die "Unable to create project plugin dir: $!";

    my @roots = PPlugin::_legacy_plugin_search_roots($cwd_root, $project_root);
    is_deeply(
        \@roots,
        [$cwd_root, File::Spec->catdir($project_root, 'plugin')],
        'PPlugin legacy plugin search roots keep cwd first and project plugin dir second'
    );

    my $dedup_project_root = $tmp_root;
    mkdir File::Spec->catdir($dedup_project_root, 'plugin') unless -d File::Spec->catdir($dedup_project_root, 'plugin');
    my @deduped_roots = PPlugin::_legacy_plugin_search_roots(File::Spec->catdir($tmp_root, 'plugin'), $dedup_project_root);
    is_deeply(
        \@deduped_roots,
        [File::Spec->catdir($tmp_root, 'plugin')],
        'PPlugin legacy plugin search roots dedupe identical cwd/project plugin directories'
    );
};
subtest 'pplugin_legacy_plugin_files_are_sorted_and_deduped' => sub {
    plan tests => 3;

    require File::Temp;
    require PPlugin;

    my $tmp_root = File::Temp::tempdir(CLEANUP => 1);
    my $root_a = File::Spec->catdir($tmp_root, 'root_a');
    my $root_b = File::Spec->catdir($tmp_root, 'root_b');
    mkdir $root_a or die "Unable to create root_a '$root_a': $!";
    mkdir $root_b or die "Unable to create root_b '$root_b': $!";

    write_text(File::Spec->catfile($root_a, 'z_last.plg'), "plugin z\n");
    write_text(File::Spec->catfile($root_a, 'a_first.plg'), "plugin a\n");
    write_text(File::Spec->catfile($root_a, 'ignore.txt'), "skip\n");
    write_text(File::Spec->catfile($root_b, 'b_only.plg'), "plugin b\n");

    my @files = PPlugin::_legacy_plugin_files($root_a, $root_a, $root_b, File::Spec->catdir($tmp_root, 'missing'));
    is_deeply(
        \@files,
        [
            File::Spec->catfile($root_a, 'a_first.plg'),
            File::Spec->catfile($root_a, 'z_last.plg'),
            File::Spec->catfile($root_b, 'b_only.plg'),
        ],
        'PPlugin legacy plugin file enumeration is sorted per root, cwd-first, and deduped'
    );
    is(scalar @files, 3, 'PPlugin legacy plugin file enumeration excludes duplicate roots and non-plugin files');
    ok((scalar grep { /\.txt\z/ } @files) == 0, 'PPlugin legacy plugin file enumeration only returns .plg files');
};
subtest 'pplugin_build_plugin_registry_preserves_file_order_and_skips_parse_failures' => sub {
    plan tests => 6;

    require File::Temp;
    require PPlugin;

    my $tmp_root = File::Temp::tempdir(CLEANUP => 1);
    my $first_file = File::Spec->catfile($tmp_root, '001_first.plg');
    my $second_file = File::Spec->catfile($tmp_root, '002_second.plg');
    my $bad_file = File::Spec->catfile($tmp_root, '003_bad.plg');
    write_text($first_file, "first\n");
    write_text($second_file, "second\n");
    write_text($bad_file, "bad\n");

    my ($registry, $stdout, $ok_run, $err) = (undef, '', 0, '');
    $ok_run = eval {
        local *STDOUT;
        open(STDOUT, '>', \$stdout) or die "Unable to capture STDOUT: $!";
        $registry = PPlugin::_build_plugin_registry(
            sub {
                my ($content_ref) = @_;
                return { foo => sub { 1 } } if $$content_ref eq "first\n";
                return { foo => sub { 2 }, bar => sub { 3 } } if $$content_ref eq "second\n";
                return undef;
            },
            $first_file,
            $second_file,
            $bad_file,
        );
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'PPlugin explicit registry builder executes without die') or diag(normalize_error($err));
    ok(ref($registry) eq 'HASH', 'PPlugin explicit registry builder returns a hashref registry');
    is($registry->{foo}->(), 2, 'PPlugin explicit registry builder preserves later file override precedence for duplicate plugin names');
    is($registry->{bar}->(), 3, 'PPlugin explicit registry builder preserves non-duplicate plugin entries');
    ok(!exists $registry->{bad}, 'PPlugin explicit registry builder skips malformed plugin files');
    like($stdout, qr/\Q$bad_file\E/, 'PPlugin explicit registry builder reports skipped malformed plugin files');
};
subtest 'pplugin_load_legacy_registry_uses_explicit_dependency_callbacks' => sub {
    plan tests => 8;

    require PPlugin;

    my ($load_calls, $discover_calls, $build_calls) = (0, 0, 0);
    my ($captured_get, @captured_files);
    my ($ok_run, $registry, $err) = (0, undef, '');

    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::get_parser = sub { die "__UNEXPECTED_LINKEDSPEC_GET_PARSER__\n" };
        local *PPlugin::_legacy_plugin_files = sub { die "__UNEXPECTED_PPLUGIN_LEGACY_PLUGIN_FILES__\n" };
        local *PPlugin::_build_plugin_registry = sub { die "__UNEXPECTED_PPLUGIN_BUILD_PLUGIN_REGISTRY__\n" };
        $registry = PPlugin::_load_legacy_registry(
            {
                load_plugin_parser => sub {
                    ++$load_calls;
                    return sub { 'synthetic_parser' };
                },
                discover_plugin_files => sub {
                    ++$discover_calls;
                    return ['001_first.plg', '002_second.plg'];
                },
                build_plugin_registry => sub {
                    ++$build_calls;
                    ($captured_get, @captured_files) = @_;
                    return {
                        synthetic => sub { 1 },
                    };
                },
            }
        );
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'PPlugin legacy registry loader succeeds while direct owner helpers are trapped')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_(?:LINKEDSPEC_GET_PARSER|PPLUGIN_(?:LEGACY_PLUGIN_FILES|BUILD_PLUGIN_REGISTRY))__/, 'PPlugin legacy registry loader avoids direct parser/discovery/registry helper calls when deps are injected');
    is($load_calls, 1, 'PPlugin legacy registry loader invokes the injected parser-loader callback once');
    is($discover_calls, 1, 'PPlugin legacy registry loader invokes the injected plugin-file discovery callback once');
    is($build_calls, 1, 'PPlugin legacy registry loader invokes the injected registry-builder callback once');
    ok(ref($captured_get) eq 'CODE', 'PPlugin legacy registry loader forwards the injected parser callback into the registry builder');
    is_deeply(\@captured_files, ['001_first.plg', '002_second.plg'], 'PPlugin legacy registry loader forwards the discovered plugin files into the registry builder in order');
    ok(ref($registry) eq 'HASH' && ref($registry->{synthetic}) eq 'CODE', 'PPlugin legacy registry loader preserves the injected registry payload');
};
subtest 'pplugin_default_registry_deps_load_through_explicit_owner_paths' => sub {
    plan tests => 6;

    require PPlugin;

    my $deps = PPlugin::_default_deps();
    my ($ok_run, $parser, $plugin_files, $registry, $err) = (0, undef, undef, undef, '');

    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::get_parser = sub {
            my ($spec_name) = @_;
            return sub { return "parser:$spec_name" };
        };
        local *PPlugin::_legacy_plugin_files = sub { return ('001_first.plg', '002_second.plg') };
        local *PPlugin::_build_plugin_registry = sub {
            my ($get, @plugin_list) = @_;
            return {
                parser_result => $get->(),
                files => [@plugin_list],
            };
        };

        $parser = $deps->{load_plugin_parser}->();
        $plugin_files = $deps->{discover_plugin_files}->();
        $registry = $deps->{build_plugin_registry}->($parser, @$plugin_files);
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'PPlugin default registry deps execute without die') or diag(normalize_error($err));
    ok(ref($parser) eq 'CODE', 'PPlugin default registry deps load a parser callback through LinkedSpec');
    is_deeply($plugin_files, ['001_first.plg', '002_second.plg'], 'PPlugin default registry deps discover plugin files through the explicit owner helper');
    ok(ref($registry) eq 'HASH', 'PPlugin default registry deps preserve the registry-builder payload');
    is($registry->{parser_result}, 'parser:pplugin', 'PPlugin default parser-loader dep targets the pplugin spec explicitly');
    is_deeply($registry->{files}, ['001_first.plg', '002_second.plg'], 'PPlugin default registry-builder dep forwards discovered plugin files unchanged');
};
subtest 'pplugin_require_does_not_eagerly_load_linkedspec' => sub {
    plan tests => 4;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(
        'require PPlugin;'
      . 'print exists($INC{"LinkedSpec.pm"}) ? "__LINKEDSPEC_LOADED__\n" : "__LINKEDSPEC_NOT_LOADED__\n";'
      . 'print defined(&Cwd::abs_path) ? "__CWD_READY__\n" : "__CWD_MISSING__\n";'
      . 'print eval { File::Spec->catdir("a", "b"); 1 } ? "__FILESPEC_READY__\n" : "__FILESPEC_MISSING__\n";'
      . 'print defined(&File::Basename::fileparse) ? "__BASENAME_READY__\n" : "__BASENAME_MISSING__\n";'
    );

    is($exit_code, 0, 'PPlugin require-only subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__LINKEDSPEC_NOT_LOADED__/, 'PPlugin require-only subprocess keeps LinkedSpec unloaded');
    like($out, qr/__CWD_READY__\n__FILESPEC_READY__\n__BASENAME_READY__/, 'PPlugin require-only subprocess loads its direct core path modules explicitly');
    is($err, '', 'PPlugin require-only subprocess does not emit stderr');
};
subtest 'pplugin_default_parser_dep_lazy_loads_linkedspec' => sub {
    plan tests => 5;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(
        'require PPlugin;'
      . 'my $deps = PPlugin::_default_deps();'
      . 'print exists($INC{"LinkedSpec.pm"}) ? "__LINKEDSPEC_EAGER__\n" : "__LINKEDSPEC_STILL_LAZY__\n";'
      . 'my $parser = $deps->{load_plugin_parser}->();'
      . 'print defined($parser) ? "__PARSER_DEFINED__\n" : "__PARSER_UNDEF__\n";'
      . 'print exists($INC{"LinkedSpec.pm"}) ? "__LINKEDSPEC_AFTER_CALLBACK__\n" : "__LINKEDSPEC_STILL_UNLOADED__\n";'
    );

    is($exit_code, 0, 'PPlugin default parser-dep subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__LINKEDSPEC_STILL_LAZY__/, 'PPlugin default deps do not eager-load LinkedSpec when built');
    like($out, qr/__PARSER_DEFINED__/, 'PPlugin default parser dep returns a parser callback when invoked');
    like($out, qr/__LINKEDSPEC_AFTER_CALLBACK__/, 'PPlugin default parser dep lazy-loads LinkedSpec only on callback execution');
    is($err, '', 'PPlugin default parser-dep subprocess does not emit stderr');
};
subtest 'tablescript_http_exec_uses_pplugin_explicit_name_owner' => sub {
    plan tests => 5;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
BEGIN {
    package Global;
    sub search_path { return [] }
}
require PPlugin;
require TableScript;
no warnings 'redefine';
local *TableScript::node_exec = sub { return $_[1] };
local *PPlugin::exec = sub { die "__UNEXPECTED_PPLUGIN_EXEC__\n" };
local *PPlugin::exec_plugin_name = sub {
    my ($class_or_self, $plugin_name, @args) = @_;
    print "__PLUGIN_NAME__=$plugin_name\n";
    print "__ARGS__=" . join(',', @args) . "\n";
    return 'http://example.test/file';
};
my $ret = TableScript::http_exec({}, ['report.txt', 'Report']);
print "__RET__=$ret\n";
PERL

    is($exit_code, 0, 'TableScript http_exec subprocess exits cleanly') or diag($err || $out);
    unlike($err, qr/__UNEXPECTED_PPLUGIN_EXEC__/, 'TableScript http_exec avoids the legacy mixed-name PPlugin exec wrapper');
    like($out, qr/__PLUGIN_NAME__=httplink/, 'TableScript http_exec dispatches through the explicit plugin name owner');
    like($out, qr/__ARGS__=report\.txt/, 'TableScript http_exec forwards the resolved filename into the explicit plugin owner');
    like($out, qr/__RET__=http:\/\/example\.test\/file\@Report/, 'TableScript http_exec preserves the explicit-owner return payload');
};
subtest 'hutils_generic_filter_uses_pplugin_explicit_name_owner' => sub {
    plan tests => 5;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
require PPlugin;
require HUtils;
no warnings 'redefine';
local *HUtils::Recurse = sub {
    my ($data, $cb) = @_;
    return $cb->(['leaf'], ['contains', 'needle']);
};
local *HUtils::avv_set = sub {
    my ($href, $info, $value) = @_;
    $href->{$info->[-1]} = $value;
    return $href;
};
local *PPlugin::exec = sub { die "__UNEXPECTED_PPLUGIN_EXEC__\n" };
local *PPlugin::exec_plugin_name = sub {
    my ($class_or_self, $plugin_name, @args) = @_;
    print "__PLUGIN_NAME__=$plugin_name\n";
    print "__MAPTABLE__=$args[3]\n";
    return 'filtered_payload';
};
my $ret = HUtils::GenericFilter(
    {
        maptable => { DEFAULT => 'default_map' },
        filters => {},
    },
    [],
    ['filters'],
);
print "__LEAF__=$ret->{leaf}\n";
PERL

    is($exit_code, 0, 'HUtils GenericFilter subprocess exits cleanly') or diag($err || $out);
    unlike($err, qr/__UNEXPECTED_PPLUGIN_EXEC__/, 'HUtils GenericFilter avoids the legacy mixed-name PPlugin exec wrapper');
    like($out, qr/__PLUGIN_NAME__=genericfilter_contains/, 'HUtils GenericFilter dispatches through the explicit plugin name owner');
    like($out, qr/__MAPTABLE__=default_map/, 'HUtils GenericFilter forwards the selected maptable into the explicit plugin owner');
    like($out, qr/__LEAF__=filtered_payload/, 'HUtils GenericFilter preserves the explicit-owner filtered payload');
};
subtest 'pplugin_exec_wrapper_normalizes_to_explicit_name_owner' => sub {
    plan tests => 5;

    require PPlugin;

    my ($ok_run, $ret, $err) = (0, undef, '');
    my ($captured_self, $captured_plugin_name, @captured_args);

    $ok_run = eval {
        no warnings 'redefine';
        local *PPlugin::new = sub { bless {}, 'PPlugin' };
        local *PPlugin::exec_plugin_name = sub {
            my ($self, $plugin_name, @args) = @_;
            ($captured_self, $captured_plugin_name, @captured_args) = ($self, $plugin_name, @args);
            return {
                plugin_name => $plugin_name,
                args => [@args],
            };
        };
        $ret = PPlugin->exec('LinkedSpec::synthetic_plugin', 'alpha', 'beta');
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'PPlugin compatibility exec wrapper succeeds while explicit owner path is trapped')
        or diag(normalize_error($err));
    ok(ref($captured_self) eq 'PPlugin', 'PPlugin compatibility exec wrapper resolves an object before delegating');
    is($captured_plugin_name, 'synthetic_plugin', 'PPlugin compatibility exec wrapper normalizes mixed plugin names before delegating');
    is_deeply(\@captured_args, [qw(alpha beta)], 'PPlugin compatibility exec wrapper forwards plugin arguments unchanged');
    is_deeply($ret, { plugin_name => 'synthetic_plugin', args => [qw(alpha beta)] }, 'PPlugin compatibility exec wrapper preserves the explicit-owner return payload');
};
subtest 'get_parser_normalizes_option_pairs_before_parser_factory' => sub {
    plan tests => 5;

    require File::Temp;
    my $orig_cwd = getcwd();
    my $tmp_cwd = File::Temp::tempdir(CLEANUP => 1);
    my $tmp_log = File::Spec->catfile($tmp_cwd, 'parser_factory_hashref_trace.log');
    my $orig_run_get_parser = \&LinkedSpec::ParserFactory::run_get_parser;

    my ($ok_run, $parser, $ast, $err) = (0, undef, undef, '');
    my ($saw_hashref, $captured_option);
    $ok_run = eval {
        no warnings 'redefine';
        local $LinkedSpec::Trace::DUMP_VERBOSITY = LinkedSpec::Trace::DUMP_NONE();
        local $LinkedSpec::Trace::TRACE_LOG_FILE;
        local $LinkedSpec::Trace::TRACE_LOG_MODE = 'stdout';
        local $LinkedSpec::Trace::TRACE_EMOJI = 0;
        local $LinkedSpec::Trace::TRACE_INDENT_LEVEL = 0;
        local $LinkedSpec::Trace::TRACE_INITIALIZED = 1;
        local *LinkedSpec::ParserFactory::run_get_parser = sub {
            my ($spec_name, $option, $deps) = @_;
            $saw_hashref = ref($option) eq 'HASH';
            $captured_option = $saw_hashref ? { %{$option} } : undef;
            return $orig_run_get_parser->($spec_name, $option, $deps);
        };

        chdir($tmp_cwd) or die "Unable to chdir '$tmp_cwd': $!";
        $parser = LinkedSpec::get_parser(
            'Lispish',
            trace_level => 'high',
            trace_log_file => $tmp_log,
            trace_log_mode => 'route',
            trace_reset_log => 1,
        );
        my $input = '(hashref contract)';
        $ast = $parser ? $parser->(\$input) : undef;
        1;
    };
    $err = $@ // '' unless $ok_run;
    chdir($orig_cwd) or die "Unable to restore cwd to '$orig_cwd': $!";

    ok($ok_run, 'get_parser succeeds while ParserFactory contract is trapped') or diag(normalize_error($err));
    ok($saw_hashref, 'get_parser passes a normalized option hashref into ParserFactory');
    is_deeply(
        [sort keys %{ $captured_option || {} }],
        [qw(trace_level trace_log_file trace_log_mode trace_reset_log)],
        'get_parser forwards the expected normalized option keys into ParserFactory'
    );
    is($captured_option->{trace_log_file}, $tmp_log, 'get_parser preserves normalized option values when delegating into ParserFactory');
    ok(defined($parser) && ref($parser) eq 'CODE' && defined($ast) && ref($ast) eq 'ARRAY', 'parser created through normalized ParserFactory options still executes');
};
subtest 'get_parser_avoids_linkedspec_parser_factory_dep_builder' => sub {
    plan tests => 4;

    require File::Temp;
    my $orig_cwd = getcwd();
    my $tmp_cwd = File::Temp::tempdir(CLEANUP => 1);

    my ($ok_run, $parser, $ast, $err) = (0, undef, undef, '');
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::_parser_factory_deps = sub { die "__UNEXPECTED_LINKEDSPEC_PARSER_FACTORY_DEPS__\n" };

        chdir($tmp_cwd) or die "Unable to chdir '$tmp_cwd': $!";
        $parser = LinkedSpec::get_parser('Lispish');
        my $input = '(deps owner)';
        $ast = $parser ? $parser->(\$input) : undef;
        1;
    };
    $err = $@ // '' unless $ok_run;
    chdir($orig_cwd) or die "Unable to restore cwd to '$orig_cwd': $!";

    ok($ok_run, 'get_parser succeeds without the LinkedSpec parser-factory dep builder') or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_LINKEDSPEC_PARSER_FACTORY_DEPS__/, 'get_parser does not call the trapped LinkedSpec parser-factory dep builder');
    ok(defined($parser) && ref($parser) eq 'CODE', 'get_parser still returns parser coderef when ParserFactory owns its default deps');
    ok(defined($ast) && ref($ast) eq 'ARRAY', 'parser created through ParserFactory-owned default deps still executes');
};
subtest 'get_parser_avoids_removed_deps_parser_factory_dep_builder' => sub {
    plan tests => 4;

    require File::Temp;
    my $orig_cwd = getcwd();
    my $tmp_cwd = File::Temp::tempdir(CLEANUP => 1);

    my ($ok_run, $parser, $ast, $err) = (0, undef, undef, '');
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Deps::parser_factory_deps_for_package = sub { die "__UNEXPECTED_DEPS_PARSER_FACTORY_DEPS__\n" };

        chdir($tmp_cwd) or die "Unable to chdir '$tmp_cwd': $!";
        $parser = LinkedSpec::get_parser('Lispish');
        my $input = '(deps removed)';
        $ast = $parser ? $parser->(\$input) : undef;
        1;
    };
    $err = $@ // '' unless $ok_run;
    chdir($orig_cwd) or die "Unable to restore cwd to '$orig_cwd': $!";

    ok($ok_run, 'get_parser succeeds without the removed Deps parser-factory dep builder') or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_DEPS_PARSER_FACTORY_DEPS__/, 'get_parser does not call the trapped removed Deps parser-factory dep builder');
    ok(defined($parser) && ref($parser) eq 'CODE', 'get_parser still returns parser coderef after removing the Deps parser-factory dep builder');
    ok(defined($ast) && ref($ast) eq 'ARRAY', 'parser created after removing the Deps parser-factory dep builder still executes');
};
subtest 'parser_factory_require_avoids_linkedspec_deps_load' => sub {
    plan tests => 4;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(
        'require LinkedSpec::ParserFactory;'
      . 'print exists($INC{"LinkedSpec/Deps.pm"}) ? "__DEPS_LOADED__\n" : "__DEPS_NOT_LOADED__\n";'
      . 'print exists($INC{"LinkedSpec/Trace.pm"}) ? "__TRACE_LOADED__\n" : "__TRACE_NOT_LOADED__\n";'
    );

    is($exit_code, 0, 'ParserFactory require-only subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__DEPS_NOT_LOADED__/, 'ParserFactory require-only subprocess keeps LinkedSpec::Deps unloaded');
    like($out, qr/__TRACE_NOT_LOADED__/, 'ParserFactory require-only subprocess does not eager-load owner dependencies before default dep resolution');
    is($err, '', 'ParserFactory require-only subprocess does not emit stderr');
};
subtest 'get_parser_avoids_linkedspec_local_spec_path_facade' => sub {
    plan tests => 5;

    require File::Temp;
    my $orig_cwd = getcwd();
    my $tmp_cwd = File::Temp::tempdir(CLEANUP => 1);

    my ($ok_run, $parser, $ast, $err) = (0, undef, undef, '');
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::_resolve_local_spec_path = sub { die "__UNEXPECTED_LINKEDSPEC_RESOLVE_LOCAL_SPEC_PATH__\n" };

        chdir($tmp_cwd) or die "Unable to chdir '$tmp_cwd': $!";
        $parser = LinkedSpec::get_parser('Lispish');
        my $input = '(resolver owner)';
        $ast = $parser ? $parser->(\$input) : undef;
        1;
    };
    $err = $@ // '' unless $ok_run;
    chdir($orig_cwd) or die "Unable to restore cwd to '$orig_cwd': $!";

    ok($ok_run, 'get_parser succeeds without the LinkedSpec local spec-path facade') or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_LINKEDSPEC_RESOLVE_LOCAL_SPEC_PATH__/, 'get_parser does not call the trapped LinkedSpec local spec-path facade');
    ok(defined($parser) && ref($parser) eq 'CODE', 'get_parser still returns parser coderef through Resolver-owned local lookup');
    ok(defined($ast) && ref($ast) eq 'ARRAY', 'parser created through Resolver-owned local lookup still executes');
    ok(!exists $INC{'PathSearch.pm'}, 'Resolver-owned local lookup still keeps PathSearch unloaded');
};
subtest 'get_parser_explicit_path_resolution_without_pathsearch' => sub {
    plan tests => 4;

    require File::Temp;
    my $tmp_dir = File::Temp::tempdir(CLEANUP => 1);
    my $tmp_spec = File::Spec->catfile($tmp_dir, 'phase1_explicit_path_resolution.spec');
    my $source_spec = File::Spec->catfile($spec_dir, 'Lispish.spec');
    my $source_content = slurp($source_spec);

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before explicit-path check');

    open(my $fh, '>', $tmp_spec) or die "Cannot create explicit-path spec '$tmp_spec': $!";
    print {$fh} $source_content;
    close($fh);
    ok(-f $tmp_spec, 'temporary explicit-path spec created');

    my $parser = LinkedSpec::get_parser($tmp_spec);
    my $input = '(ep path)';
    my $ast = eval { $parser ? $parser->(\$input) : undef };

    ok(!$@ && defined($parser) && ref($parser) eq 'CODE', 'explicit-path parser created and executed without die')
        or diag(normalize_error($@));
    ok(defined($ast) && ref($ast) eq 'ARRAY' && !exists $INC{'PathSearch.pm'},
        'explicit-path resolution keeps PathSearch unloaded');
};

subtest 'get_parser_cwd_name_spec_resolution_without_pathsearch' => sub {
    plan tests => 4;

    require File::Temp;
    my $tmp_dir = File::Temp::tempdir(CLEANUP => 1);
    my $tmp_name = 'phase1_cwd_name_resolution_' . $$;
    my $tmp_spec = File::Spec->catfile($tmp_dir, "$tmp_name.spec");
    my $source_spec = File::Spec->catfile($spec_dir, 'Lispish.spec');
    my $source_content = slurp($source_spec);

    open(my $fh, '>', $tmp_spec) or die "Cannot create cwd-resolution spec '$tmp_spec': $!";
    print {$fh} $source_content;
    close($fh);

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before cwd name.spec check');

    my $orig_cwd = getcwd();
    my ($ok_run, $parser, $ast, $err) = (0, undef, undef, '');
    $ok_run = eval {
        chdir($tmp_dir) or die "Unable to chdir '$tmp_dir': $!";
        $parser = LinkedSpec::get_parser($tmp_name);
        my $input = '(cw d)';
        $ast = $parser ? $parser->(\$input) : undef;
        1;
    };
    $err = $@ // '';
    chdir($orig_cwd) or die "Unable to restore cwd to '$orig_cwd': $!";

    ok($ok_run, 'get_parser executes from cwd containing name.spec') or diag(normalize_error($err));
    ok(defined($parser) && ref($parser) eq 'CODE', 'cwd name.spec parser resolves by direct local file');
    ok(defined($ast) && ref($ast) eq 'ARRAY' && !exists $INC{'PathSearch.pm'},
        'cwd name.spec resolution keeps PathSearch unloaded');
};
subtest 'get_parser_empty_spec_name_reports_error_without_pathsearch' => sub {
    plan tests => 8;

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before empty-spec-name checks');

    my ($ok_undef, $parser_undef, $err_undef, $out_undef, $warn_undef) = run_get_parser_with_captured_io(undef);
    ok($ok_undef, 'undef-spec get_parser call returns without die') or diag(normalize_error($err_undef));
    ok(!defined($parser_undef), 'undef-spec get_parser returns undef');
    like($out_undef, qr/Invalid spec name/, 'undef-spec diagnostics report invalid spec name');

    my ($ok_empty, $parser_empty, $err_empty, $out_empty, $warn_empty) = run_get_parser_with_captured_io('');
    ok($ok_empty, 'empty-spec get_parser call returns without die') or diag(normalize_error($err_empty));
    ok(!defined($parser_empty), 'empty-spec get_parser returns undef');
    like($out_empty, qr/Invalid spec name/, 'empty-spec diagnostics report invalid spec name');

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after empty-spec-name checks');
};
subtest 'get_parser_whitespace_spec_name_reports_error_without_pathsearch' => sub {
    plan tests => 8;

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before whitespace-spec-name checks');

    my ($ok_space, $parser_space, $err_space, $out_space, $warn_space) = run_get_parser_with_captured_io('   ');
    ok($ok_space, 'space-only-spec get_parser call returns without die') or diag(normalize_error($err_space));
    ok(!defined($parser_space), 'space-only-spec get_parser returns undef');
    like($out_space, qr/Invalid spec name/, 'space-only-spec diagnostics report invalid spec name');

    my ($ok_mixed, $parser_mixed, $err_mixed, $out_mixed, $warn_mixed) = run_get_parser_with_captured_io(" \t\n");
    ok($ok_mixed, 'whitespace-mixed-spec get_parser call returns without die') or diag(normalize_error($err_mixed));
    ok(!defined($parser_mixed), 'whitespace-mixed-spec get_parser returns undef');
    like($out_mixed, qr/Invalid spec name/, 'whitespace-mixed-spec diagnostics report invalid spec name');

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after whitespace-spec-name checks');
};
subtest 'get_parser_padded_spec_name_reports_error_without_pathsearch' => sub {
    plan tests => 8;

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before padded-spec-name checks');

    my ($ok_lead, $parser_lead, $err_lead, $out_lead, $warn_lead) = run_get_parser_with_captured_io(' Lispish');
    ok($ok_lead, 'leading-space-spec get_parser call returns without die') or diag(normalize_error($err_lead));
    ok(!defined($parser_lead), 'leading-space-spec get_parser returns undef');
    like($out_lead, qr/Invalid spec name/, 'leading-space-spec diagnostics report invalid spec name');

    my ($ok_trail, $parser_trail, $err_trail, $out_trail, $warn_trail) = run_get_parser_with_captured_io('Lispish ');
    ok($ok_trail, 'trailing-space-spec get_parser call returns without die') or diag(normalize_error($err_trail));
    ok(!defined($parser_trail), 'trailing-space-spec get_parser returns undef');
    like($out_trail, qr/Invalid spec name/, 'trailing-space-spec diagnostics report invalid spec name');

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after padded-spec-name checks');
};
subtest 'get_parser_control_char_spec_name_reports_error_without_pathsearch' => sub {
    plan tests => 8;

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before control-char-spec-name checks');

    my ($ok_tab, $parser_tab, $err_tab, $out_tab, $warn_tab) = run_get_parser_with_captured_io("Lis\tpish");
    ok($ok_tab, 'tab-char-spec get_parser call returns without die') or diag(normalize_error($err_tab));
    ok(!defined($parser_tab), 'tab-char-spec get_parser returns undef');
    like($out_tab, qr/Invalid spec name/, 'tab-char-spec diagnostics report invalid spec name');

    my ($ok_newline, $parser_newline, $err_newline, $out_newline, $warn_newline) = run_get_parser_with_captured_io("Lis\npish");
    ok($ok_newline, 'newline-char-spec get_parser call returns without die') or diag(normalize_error($err_newline));
    ok(!defined($parser_newline), 'newline-char-spec get_parser returns undef');
    like($out_newline, qr/Invalid spec name/, 'newline-char-spec diagnostics report invalid spec name');

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after control-char-spec-name checks');
};
subtest 'get_parser_additional_control_byte_spec_name_reports_error_without_pathsearch' => sub {
    plan tests => 8;

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before additional-control-byte-spec-name checks');

    my ($ok_bel, $parser_bel, $err_bel, $out_bel, $warn_bel) = run_get_parser_with_captured_io("Lis\apish");
    ok($ok_bel, 'BEL-char-spec get_parser call returns without die') or diag(normalize_error($err_bel));
    ok(!defined($parser_bel), 'BEL-char-spec get_parser returns undef');
    like($out_bel, qr/Invalid spec name/, 'BEL-char-spec diagnostics report invalid spec name');

    my ($ok_us, $parser_us, $err_us, $out_us, $warn_us) = run_get_parser_with_captured_io("Lis\x1Fpish");
    ok($ok_us, 'US-char-spec get_parser call returns without die') or diag(normalize_error($err_us));
    ok(!defined($parser_us), 'US-char-spec get_parser returns undef');
    like($out_us, qr/Invalid spec name/, 'US-char-spec diagnostics report invalid spec name');

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after additional-control-byte-spec-name checks');
};
subtest 'get_parser_non_scalar_spec_name_reports_error_without_pathsearch' => sub {
    plan tests => 8;

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before non-scalar-spec-name checks');

    my ($ok_arrayref, $parser_arrayref, $err_arrayref, $out_arrayref, $warn_arrayref) =
        run_get_parser_with_captured_io([]);
    ok($ok_arrayref, 'arrayref-spec get_parser call returns without die') or diag(normalize_error($err_arrayref));
    ok(!defined($parser_arrayref), 'arrayref-spec get_parser returns undef');
    like($out_arrayref, qr/Invalid spec name/, 'arrayref-spec diagnostics report invalid spec name');

    my ($ok_hashref, $parser_hashref, $err_hashref, $out_hashref, $warn_hashref) =
        run_get_parser_with_captured_io({});
    ok($ok_hashref, 'hashref-spec get_parser call returns without die') or diag(normalize_error($err_hashref));
    ok(!defined($parser_hashref), 'hashref-spec get_parser returns undef');
    like($out_hashref, qr/Invalid spec name/, 'hashref-spec diagnostics report invalid spec name');

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after non-scalar-spec-name checks');
};
subtest 'get_parser_non_scalar_reference_variants_reports_error_without_pathsearch' => sub {
    plan tests => 11;

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before non-scalar-reference-variant checks');

    my $scalar_ref = do { my $v = 'Lispish'; \$v };
    my ($ok_scalar_ref, $parser_scalar_ref, $err_scalar_ref, $out_scalar_ref, $warn_scalar_ref) =
        run_get_parser_with_captured_io($scalar_ref);
    ok($ok_scalar_ref, 'scalarref-spec get_parser call returns without die') or diag(normalize_error($err_scalar_ref));
    ok(!defined($parser_scalar_ref), 'scalarref-spec get_parser returns undef');
    like($out_scalar_ref, qr/Invalid spec name/, 'scalarref-spec diagnostics report invalid spec name');

    my ($ok_coderef, $parser_coderef, $err_coderef, $out_coderef, $warn_coderef) =
        run_get_parser_with_captured_io(sub { return 'noop' });
    ok($ok_coderef, 'coderef-spec get_parser call returns without die') or diag(normalize_error($err_coderef));
    ok(!defined($parser_coderef), 'coderef-spec get_parser returns undef');
    like($out_coderef, qr/Invalid spec name/, 'coderef-spec diagnostics report invalid spec name');

    my ($ok_regexref, $parser_regexref, $err_regexref, $out_regexref, $warn_regexref) =
        run_get_parser_with_captured_io(qr/Lispish/o);
    ok($ok_regexref, 'regexref-spec get_parser call returns without die') or diag(normalize_error($err_regexref));
    ok(!defined($parser_regexref), 'regexref-spec get_parser returns undef');
    like($out_regexref, qr/Invalid spec name/, 'regexref-spec diagnostics report invalid spec name');

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after non-scalar-reference-variant checks');
};
subtest 'get_parser_nul_byte_spec_name_reports_error_without_pathsearch' => sub {
    plan tests => 8;

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before NUL-byte-spec-name checks');

    my ($ok_nul_only, $parser_nul_only, $err_nul_only, $out_nul_only, $warn_nul_only) =
        run_get_parser_with_captured_io("\0");
    ok($ok_nul_only, 'NUL-only-spec get_parser call returns without die') or diag(normalize_error($err_nul_only));
    ok(!defined($parser_nul_only), 'NUL-only-spec get_parser returns undef');
    like($out_nul_only, qr/Invalid spec name/, 'NUL-only-spec diagnostics report invalid spec name');

    my ($ok_nul_mixed, $parser_nul_mixed, $err_nul_mixed, $out_nul_mixed, $warn_nul_mixed) =
        run_get_parser_with_captured_io("Lispish\0.spec");
    ok($ok_nul_mixed, 'NUL-mixed-spec get_parser call returns without die') or diag(normalize_error($err_nul_mixed));
    ok(!defined($parser_nul_mixed), 'NUL-mixed-spec get_parser returns undef');
    like($out_nul_mixed, qr/Invalid spec name/, 'NUL-mixed-spec diagnostics report invalid spec name');

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after NUL-byte-spec-name checks');
};
subtest 'get_parser_missing_explicit_path_skips_pathsearch' => sub {
    plan tests => 6;

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before missing-explicit-path check');

    my $missing_path = File::Spec->catfile($Bin, 'tmp_phase1_missing', 'does_not_exist.spec');
    my ($ok_call, $parser, $err_call, $out, $warn) = run_get_parser_with_captured_io($missing_path);

    ok($ok_call, 'missing-explicit-path get_parser call returns without die') or diag(normalize_error($err_call));
    ok(!defined($parser), 'missing-explicit-path get_parser returns undef');
    like($out, qr/Spec path not found/, 'missing-explicit-path reports "Spec path not found"');
    like($out . $warn, qr/\Q$missing_path\E/, 'missing-explicit-path diagnostics include requested path');
    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after missing-explicit-path check');
};
subtest 'get_parser_missing_windows_style_path_skips_pathsearch' => sub {
    plan tests => 6;

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before missing-windows-style-path check');

    my $missing_windows_path = 'tmp_phase1_missing\\does_not_exist.spec';
    my ($ok_call, $parser, $err_call, $out, $warn) = run_get_parser_with_captured_io($missing_windows_path);

    ok($ok_call, 'missing-windows-style-path get_parser call returns without die') or diag(normalize_error($err_call));
    ok(!defined($parser), 'missing-windows-style-path get_parser returns undef');
    like($out, qr/Spec path not found/, 'missing-windows-style-path reports "Spec path not found"');
    like($out . $warn, qr/\Q$missing_windows_path\E/, 'missing-windows-style-path diagnostics include requested path');
    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after missing-windows-style-path check');
};
subtest 'get_parser_explicit_directory_path_reports_error_without_pathsearch' => sub {
    plan tests => 7;

    require File::Temp;
    my $tmp_dir = File::Temp::tempdir(CLEANUP => 1);
    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before explicit-directory-path check');
    ok(-d $tmp_dir, 'temporary directory path exists for explicit-directory-path check');

    my ($ok_call, $parser, $err_call, $out, $warn) = run_get_parser_with_captured_io($tmp_dir);

    ok($ok_call, 'explicit-directory-path get_parser call returns without die') or diag(normalize_error($err_call));
    ok(!defined($parser), 'explicit-directory-path get_parser returns undef');
    like($out, qr/Spec path is not a file/, 'explicit-directory-path reports "Spec path is not a file"');
    like($out . $warn, qr/\Q$tmp_dir\E/, 'explicit-directory-path diagnostics include resolved directory path');
    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after explicit-directory-path check');
};
subtest 'get_parser_explicit_non_regular_path_reports_error_without_pathsearch' => sub {
    plan tests => 8;

    my $devnull = File::Spec->devnull();
    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before explicit-non-regular-path check');
    ok(-e $devnull, 'non-regular explicit path exists for check');

    my ($ok_call, $parser, $err_call, $out, $warn) = run_get_parser_with_captured_io($devnull);

    ok($ok_call, 'explicit-non-regular-path get_parser call returns without die') or diag(normalize_error($err_call));
    ok(!defined($parser), 'explicit-non-regular-path get_parser returns undef');
    like($out, qr/Spec path is not a file/, 'explicit-non-regular-path reports "Spec path is not a file"');
    like($out . $warn, qr/\Q$devnull\E/, 'explicit-non-regular-path diagnostics include resolved path');
    like($out . $warn, qr/type='non-regular'/, 'explicit-non-regular-path diagnostics include non-regular type marker');
    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after explicit-non-regular-path check');
};
subtest 'get_parser_missing_dot_spec_name_skips_pathsearch' => sub {
    plan tests => 6;

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before missing-dot-spec-name check');

    my $missing_spec_name = 'phase1_missing_dot_spec_name_' . $$ . '.spec';
    my ($ok_call, $parser, $err_call, $out, $warn) = run_get_parser_with_captured_io($missing_spec_name);

    ok($ok_call, 'missing-dot-spec-name get_parser call returns without die') or diag(normalize_error($err_call));
    ok(!defined($parser), 'missing-dot-spec-name get_parser returns undef');
    like($out, qr/Spec path not found/, 'missing-dot-spec-name reports "Spec path not found"');
    like($out . $warn, qr/\Q$missing_spec_name\E/, 'missing-dot-spec-name diagnostics include requested name');
    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after missing-dot-spec-name check');
};
subtest 'get_parser_pathsearch_load_failure_reports_error' => sub {
    plan tests => 6;

    require File::Temp;
    my $tmp_inc = File::Temp::tempdir(CLEANUP => 1);
    my $missing_name = 'phase1_force_pathsearch_load_failure_' . $$;
    my ($ok_call, $parser, $err_call, $out, $warn) = (0, undef, '', '', '');

    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch not loaded before forced-load-failure check');

    $ok_call = eval {
        local @INC = ($tmp_inc);
        local *STDOUT;
        local *STDERR;
        open(STDOUT, '>', \$out) or die "Unable to capture STDOUT: $!";
        open(STDERR, '>', \$warn) or die "Unable to capture STDERR: $!";
        $parser = LinkedSpec::get_parser($missing_name);
        1;
    };
    $err_call = $@ // '' unless $ok_call;

    ok($ok_call, 'PathSearch-load-failure get_parser call returns without die') or diag(normalize_error($err_call));
    ok(!defined($parser), 'PathSearch-load-failure get_parser returns undef');
    like($out, qr/Unable to resolve spec/, 'PathSearch-load-failure diagnostics report unresolved spec');
    like($out, qr/PathSearch load failed:/, 'PathSearch-load-failure diagnostics report require failure');
    ok(!exists $INC{'PathSearch.pm'}, 'PathSearch remains unloaded after forced-load-failure check');
};
subtest 'get_parser_pathsearch_runtime_failure_reports_error' => sub {
    plan tests => 6;

    my $missing_name = 'phase1_force_pathsearch_runtime_failure_' . $$;
    my ($ok_call, $parser, $err_call, $out, $warn) = (0, undef, '', '', '');

    require PathSearch;
    ok(exists $INC{'PathSearch.pm'}, 'PathSearch loaded for runtime-failure check');

    $ok_call = eval {
        no warnings 'redefine';
        local *PathSearch::go = sub { die "__PHASE1_PATHSEARCH_GO_DIE__\n" };
        local *STDOUT;
        local *STDERR;
        open(STDOUT, '>', \$out) or die "Unable to capture STDOUT: $!";
        open(STDERR, '>', \$warn) or die "Unable to capture STDERR: $!";
        $parser = LinkedSpec::get_parser($missing_name);
        1;
    };
    $err_call = $@ // '' unless $ok_call;

    ok($ok_call, 'PathSearch-runtime-failure get_parser call returns without die') or diag(normalize_error($err_call));
    ok(!defined($parser), 'PathSearch-runtime-failure get_parser returns undef');
    like($out, qr/Unable to resolve spec/, 'PathSearch-runtime-failure diagnostics report unresolved spec');
    like($out, qr/PathSearch runtime failure:/, 'PathSearch-runtime-failure diagnostics report runtime failure');
    like($out . $warn, qr/__PHASE1_PATHSEARCH_GO_DIE__/, 'PathSearch-runtime-failure diagnostics include underlying die marker');
};
subtest 'get_parser_explicit_miss_bypasses_pathsearch_when_loaded' => sub {
    plan tests => 10;

    require PathSearch;
    ok(exists $INC{'PathSearch.pm'}, 'PathSearch loaded before explicit-miss bypass check');

    my $missing_path = File::Spec->catfile($Bin, 'tmp_phase1_missing', 'does_not_exist_loaded.spec');
    my $missing_spec_name = 'phase1_missing_dot_spec_loaded_' . $$ . '.spec';
    my $go_calls = 0;
    my ($ok_call, $err_call, $out, $warn, $parser_path, $parser_spec) = (0, '', '', '', undef, undef);

    $ok_call = eval {
        no warnings 'redefine';
        local *PathSearch::go = sub { ++$go_calls; die "__UNEXPECTED_PATHSEARCH_GO__\n" };
        local *STDOUT;
        local *STDERR;
        open(STDOUT, '>', \$out) or die "Unable to capture STDOUT: $!";
        open(STDERR, '>', \$warn) or die "Unable to capture STDERR: $!";
        $parser_path = LinkedSpec::get_parser($missing_path);
        $parser_spec = LinkedSpec::get_parser($missing_spec_name);
        1;
    };
    $err_call = $@ // '' unless $ok_call;

    ok($ok_call, 'explicit-miss bypass check returns without die') or diag(normalize_error($err_call));
    is($go_calls, 0, 'explicit-miss bypass check does not call PathSearch::go');
    ok(!defined($parser_path), 'missing-explicit-path with PathSearch loaded returns undef');
    ok(!defined($parser_spec), 'missing-dot-spec-name with PathSearch loaded returns undef');
    like($out, qr/Spec path not found/, 'explicit-miss bypass diagnostics report not-found');
    like($out . $warn, qr/\Q$missing_path\E/, 'explicit-miss bypass diagnostics include requested explicit path');
    like($out . $warn, qr/\Q$missing_spec_name\E/, 'explicit-miss bypass diagnostics include requested dot-spec name');
    unlike($out . $warn, qr/__UNEXPECTED_PATHSEARCH_GO__/, 'explicit-miss bypass diagnostics do not include PathSearch::go sentinel');
    ok(exists $INC{'PathSearch.pm'}, 'PathSearch remains loaded after explicit-miss bypass check');
};
subtest 'get_parser_pathsearch_returns_missing_file_reports_error' => sub {
    plan tests => 6;

    my $missing_name = 'phase1_force_pathsearch_missing_file_' . $$;
    my $fake_resolved = File::Spec->catfile($Bin, 'tmp_phase1_missing', "pathsearch_missing_" . $$ . '.spec');
    my ($ok_call, $parser, $err_call, $out, $warn) = (0, undef, '', '', '');

    require PathSearch;
    ok(exists $INC{'PathSearch.pm'}, 'PathSearch loaded for fallback-resolved-missing-file check');

    $ok_call = eval {
        no warnings 'redefine';
        local *PathSearch::go = sub { return $fake_resolved };
        local *STDOUT;
        local *STDERR;
        open(STDOUT, '>', \$out) or die "Unable to capture STDOUT: $!";
        open(STDERR, '>', \$warn) or die "Unable to capture STDERR: $!";
        $parser = LinkedSpec::get_parser($missing_name);
        1;
    };
    $err_call = $@ // '' unless $ok_call;

    ok($ok_call, 'PathSearch-resolved-missing-file get_parser call returns without die') or diag(normalize_error($err_call));
    ok(!defined($parser), 'PathSearch-resolved-missing-file get_parser returns undef');
    like($out, qr/Spec path not found/, 'PathSearch-resolved-missing-file diagnostics report not-found');
    like($out . $warn, qr/\Q$missing_name\E/, 'PathSearch-resolved-missing-file diagnostics include requested spec');
    like($out . $warn, qr/\Q$fake_resolved\E/, 'PathSearch-resolved-missing-file diagnostics include resolved missing path');
};
subtest 'get_parser_pathsearch_returns_directory_reports_error' => sub {
    plan tests => 8;

    require File::Temp;
    require PathSearch;
    my $tmp_dir = File::Temp::tempdir(CLEANUP => 1);
    my $missing_name = 'phase1_force_pathsearch_directory_' . $$;
    my $go_calls = 0;
    my ($ok_call, $parser, $err_call, $out, $warn) = (0, undef, '', '', '');

    ok(exists $INC{'PathSearch.pm'}, 'PathSearch loaded for fallback-resolved-directory check');

    $ok_call = eval {
        no warnings 'redefine';
        local *PathSearch::go = sub { ++$go_calls; return $tmp_dir };
        local *STDOUT;
        local *STDERR;
        open(STDOUT, '>', \$out) or die "Unable to capture STDOUT: $!";
        open(STDERR, '>', \$warn) or die "Unable to capture STDERR: $!";
        $parser = LinkedSpec::get_parser($missing_name);
        1;
    };
    $err_call = $@ // '' unless $ok_call;

    ok($ok_call, 'PathSearch-resolved-directory get_parser call returns without die') or diag(normalize_error($err_call));
    is($go_calls, 1, 'PathSearch-resolved-directory calls PathSearch::go exactly once');
    ok(!defined($parser), 'PathSearch-resolved-directory get_parser returns undef');
    like($out, qr/Spec path is not a file/, 'PathSearch-resolved-directory reports "Spec path is not a file"');
    like($out . $warn, qr/\Q$missing_name\E/, 'PathSearch-resolved-directory diagnostics include requested spec');
    like($out . $warn, qr/\Q$tmp_dir\E/, 'PathSearch-resolved-directory diagnostics include resolved directory path');
    ok(-d $tmp_dir, 'temporary directory path remains available during check');
};
subtest 'get_parser_pathsearch_returns_non_regular_path_reports_error' => sub {
    plan tests => 9;

    require PathSearch;
    my $devnull = File::Spec->devnull();
    my $missing_name = 'phase1_force_pathsearch_non_regular_' . $$;
    my $go_calls = 0;
    my ($ok_call, $parser, $err_call, $out, $warn) = (0, undef, '', '', '');

    ok(exists $INC{'PathSearch.pm'}, 'PathSearch loaded for fallback-resolved-non-regular check');
    ok(-e $devnull, 'non-regular fallback-resolved path exists for check');

    $ok_call = eval {
        no warnings 'redefine';
        local *PathSearch::go = sub { ++$go_calls; return $devnull };
        local *STDOUT;
        local *STDERR;
        open(STDOUT, '>', \$out) or die "Unable to capture STDOUT: $!";
        open(STDERR, '>', \$warn) or die "Unable to capture STDERR: $!";
        $parser = LinkedSpec::get_parser($missing_name);
        1;
    };
    $err_call = $@ // '' unless $ok_call;

    ok($ok_call, 'PathSearch-resolved-non-regular get_parser call returns without die') or diag(normalize_error($err_call));
    is($go_calls, 1, 'PathSearch-resolved-non-regular calls PathSearch::go exactly once');
    ok(!defined($parser), 'PathSearch-resolved-non-regular get_parser returns undef');
    like($out, qr/Spec path is not a file/, 'PathSearch-resolved-non-regular reports "Spec path is not a file"');
    like($out . $warn, qr/\Q$missing_name\E/, 'PathSearch-resolved-non-regular diagnostics include requested spec');
    like($out . $warn, qr/\Q$devnull\E/, 'PathSearch-resolved-non-regular diagnostics include resolved non-regular path');
    like($out . $warn, qr/type='non-regular'/, 'PathSearch-resolved-non-regular diagnostics include non-regular type marker');
};
subtest 'get_parser_pathsearch_fallback_calls_go_once' => sub {
    plan tests => 7;

    require File::Temp;
    require PathSearch;
    my $tmp_dir = File::Temp::tempdir(CLEANUP => 1);
    my $tmp_spec = File::Spec->catfile($tmp_dir, 'phase1_pathsearch_go_once.spec');
    my $source_spec = File::Spec->catfile($spec_dir, 'Lispish.spec');
    my $source_content = slurp($source_spec);
    my $missing_name = 'phase1_pathsearch_go_once_' . $$;
    my $go_calls = 0;

    open(my $fh, '>', $tmp_spec) or die "Cannot create go-once fallback spec '$tmp_spec': $!";
    print {$fh} $source_content;
    close($fh);
    ok(-f $tmp_spec, 'temporary go-once fallback spec created');
    ok(exists $INC{'PathSearch.pm'}, 'PathSearch loaded for go-once fallback check');

    my ($ok_call, $parser, $err_call) = (0, undef, '');
    $ok_call = eval {
        no warnings 'redefine';
        local *PathSearch::go = sub {
            ++$go_calls;
            return $tmp_spec;
        };
        $parser = LinkedSpec::get_parser($missing_name);
        1;
    };
    $err_call = $@ // '' unless $ok_call;

    ok($ok_call, 'go-once fallback get_parser call returns without die') or diag(normalize_error($err_call));
    is($go_calls, 1, 'go-once fallback calls PathSearch::go exactly once');
    ok(defined($parser) && ref($parser) eq 'CODE', 'go-once fallback get_parser returns parser coderef');

    my $input = '(go once)';
    my $ast = eval { $parser ? $parser->(\$input) : undef };
    ok(!$@, 'go-once fallback parser invocation returns without die') or diag(normalize_error($@));
    ok(defined($ast) && ref($ast) eq 'ARRAY', 'go-once fallback parser invocation returns AST');
};

subtest 'get_parser_pathsearch_fallback' => sub {
    plan tests => 5;

    my $tmp_name = 'phase1_pathsearch_fallback_' . $$;
    my $tmp_dir = File::Spec->catdir($Bin, 'tmp_phase1_pathsearch');
    my $tmp_spec = File::Spec->catfile($tmp_dir, "$tmp_name.spec");
    my $module_relative_candidate = File::Spec->catfile($spec_dir, "$tmp_name.spec");
    my $source_spec = File::Spec->catfile($spec_dir, 'Lispish.spec');
    my $source_content = slurp($source_spec);

    mkdir($tmp_dir) or die "Cannot create directory '$tmp_dir': $!" unless -d $tmp_dir;
    open(my $fh, '>', $tmp_spec) or die "Cannot create fallback spec '$tmp_spec': $!";
    print {$fh} $source_content;
    close($fh);

    ok(-f $tmp_spec, 'temporary fallback spec created');
    ok(!-f $module_relative_candidate, 'module-relative candidate does not exist for fallback case');

    my $parser = LinkedSpec::get_parser($tmp_name);
    ok(defined($parser) && ref($parser) eq 'CODE', 'fallback parser created through get_parser');
    ok(exists $INC{'PathSearch.pm'}, 'PathSearch loaded when fallback resolution is needed');

    my $input = '(u v)';
    my $ast = eval { $parser->(\$input) };
    ok(!$@ && defined($ast) && ref($ast) eq 'ARRAY', 'fallback parser executes and returns AST')
        or diag(normalize_error($@));

    unlink($tmp_spec) or die "Cannot remove temporary fallback spec '$tmp_spec': $!";
};
subtest 'get_parser_unresolved_spec_reports_error' => sub {
    plan tests => 8;

    my $missing_name = 'phase1_missing_spec_' . $$;
    my ($ok_name, $parser_name, $err_name, $out_name, $warn_name) = run_get_parser_with_captured_io($missing_name);

    ok($ok_name, 'missing-name get_parser call returns without die') or diag(normalize_error($err_name));
    ok(!defined($parser_name), 'missing-name get_parser returns undef');
    like($out_name, qr/Spec path not found/, 'missing-name path reports \"Spec path not found\"');
    like($out_name . $warn_name, qr/\Q$missing_name\E/, 'missing-name diagnostics include requested spec');

    my $missing_path = File::Spec->catfile($Bin, 'tmp_phase1_missing', 'does_not_exist.spec');
    my ($ok_path, $parser_path, $err_path, $out_path, $warn_path) = run_get_parser_with_captured_io($missing_path);

    ok($ok_path, 'missing-explicit-path get_parser call returns without die') or diag(normalize_error($err_path));
    ok(!defined($parser_path), 'missing-explicit-path get_parser returns undef');
    like($out_path, qr/Spec path not found/, 'missing-explicit-path reports \"Spec path not found\"');
    like($out_path . $warn_path, qr/\Q$missing_path\E/, 'missing-explicit-path diagnostics include requested path');
};
subtest 'get_parser_open_failure_reports_error' => sub {
    plan tests => 6;

    require File::Temp;
    my $tmp_dir = File::Temp::tempdir(CLEANUP => 1);
    my $tmp_spec = File::Spec->catfile($tmp_dir, 'phase1_unreadable_open_failure.spec');
    my $source_spec = File::Spec->catfile($spec_dir, 'Lispish.spec');
    my $source_content = slurp($source_spec);

    open(my $fh, '>', $tmp_spec) or die "Cannot create unreadable-open-failure spec '$tmp_spec': $!";
    print {$fh} $source_content;
    close($fh);
    ok(-f $tmp_spec, 'temporary unreadable spec created');

    my $perm_ok = chmod 0000, $tmp_spec;
    ok($perm_ok, 'temporary spec permissions changed to unreadable') or diag("chmod 0000 failed for '$tmp_spec': $!");

    my ($ok_call, $parser, $err_call, $out, $warn) = run_get_parser_with_captured_io($tmp_spec);

    ok($ok_call, 'unreadable-spec get_parser call returns without die') or diag(normalize_error($err_call));
    ok(!defined($parser), 'unreadable-spec get_parser returns undef');
    like($out, qr/Unable to open spec file/, 'unreadable-spec reports open failure');
    like($out . $warn, qr/\Q$tmp_spec\E.*OS Error:/s, 'unreadable-spec diagnostics include path and OS error');

    chmod 0600, $tmp_spec;
    unlink($tmp_spec);
};
subtest 'get_parser_malformed_spec_reports_validation_error' => sub {
    plan tests => 7;

    require File::Temp;
    my $tmp_dir = File::Temp::tempdir(CLEANUP => 1);
    my $tmp_spec = File::Spec->catfile($tmp_dir, 'phase1_malformed_spec_validation.spec');
    my $malformed_spec = "this is not a valid LinkedSpec rule line\n";

    open(my $fh, '>', $tmp_spec) or die "Cannot create malformed spec '$tmp_spec': $!";
    print {$fh} $malformed_spec;
    close($fh);
    ok(-f $tmp_spec, 'temporary malformed spec created');

    my ($ok_call, $parser, $err_call, $out, $warn) = (0, undef, '', '', '');
    ($ok_call, $parser, $err_call, $out, $warn) = eval {
        no warnings 'redefine';
        local *LinkedSpec::get_dsl_context = sub { die "__UNEXPECTED_LINKEDSPEC_GET_DSL_CONTEXT__\n" };
        local *LinkedSpec::report_dsl_error = sub { die "__UNEXPECTED_LINKEDSPEC_REPORT_DSL_ERROR__\n" };
        local *LinkedSpec::validate_spec_content = sub { die "__UNEXPECTED_LINKEDSPEC_VALIDATE_SPEC_CONTENT__\n" };
        local *LinkedSpec::validate_rule_definition = sub { die "__UNEXPECTED_LINKEDSPEC_VALIDATE_RULE_DEFINITION__\n" };
        local *LinkedSpec::validate_gdata_references = sub { die "__UNEXPECTED_LINKEDSPEC_VALIDATE_GDATA_REFERENCES__\n" };
        local *LinkedSpec::validate_dsl_syntax = sub { die "__UNEXPECTED_LINKEDSPEC_VALIDATE_DSL_SYNTAX__\n" };
        local *LinkedSpec::extract_regex_literals_from_rule_rhs = sub { die "__UNEXPECTED_LINKEDSPEC_EXTRACT_REGEX_LITERALS_FROM_RULE_RHS__\n" };
        run_get_parser_with_captured_io($tmp_spec);
    };

    ok($ok_call, 'malformed-spec get_parser call returns without die') or diag(normalize_error($err_call));
    unlike($err_call, qr/__UNEXPECTED_LINKEDSPEC_/, 'malformed-spec validation error path does not call the trapped removed LinkedSpec validation facade helpers');
    ok(!defined($parser), 'malformed-spec get_parser returns undef');
    like($out, qr/DSL Error at line 1:/, 'malformed-spec still reports DSL line context through Validation owner path');
    like($out, qr/Spec file must start with a rule definition/, 'malformed-spec reports missing rule-definition validation failure');
    like($out, qr/CRITICAL ERROR/, 'malformed-spec reports critical validation failure');

    unlink($tmp_spec);
};
subtest 'get_parser_malformed_handler_runtime_error' => sub {
    plan tests => 7;

    require File::Temp;
    my $tmp_dir = File::Temp::tempdir(CLEANUP => 1);
    my $tmp_spec = File::Spec->catfile($tmp_dir, 'phase1_malformed_handler_runtime_error.spec');
    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { my $broken = ; return_a(Top) }
SPEC

    open(my $fh, '>', $tmp_spec) or die "Cannot create malformed-handler spec '$tmp_spec': $!";
    print {$fh} $spec_content;
    close($fh);
    ok(-f $tmp_spec, 'temporary malformed-handler spec created');

    my ($ok_get, $parser, $err_get, $out_get, $warn_get) = run_get_parser_with_captured_io($tmp_spec);
    ok($ok_get, 'malformed-handler get_parser call returns without die') or diag(normalize_error($err_get));
    ok(defined($parser) && ref($parser) eq 'CODE', 'malformed-handler get_parser returns parser coderef');

    my $input = 'a';
    my ($ok_run, $ast, $err_run, $out_run, $warn_run, $inner_eval_err) =
        run_parser_with_captured_io($parser, \$input);

    ok($ok_run, 'malformed-handler parser invocation returns without outer die') or diag(normalize_error($err_run));
    ok(!defined($ast), 'malformed-handler parser invocation returns undef AST');
    ok(length($inner_eval_err) > 0, 'malformed-handler parser invocation exposes inner eval error');
    like($inner_eval_err, qr/syntax error/i, 'malformed-handler inner eval error reports syntax issue');

    unlink($tmp_spec);
};
subtest 'get_parser_mixed_action_blind_call_returns_undef_without_exit' => sub {
    plan tests => 7;

    require File::Temp;
    my $tmp_dir = File::Temp::tempdir(CLEANUP => 1);
    my $tmp_spec = File::Spec->catfile($tmp_dir, 'phase1_mixed_action_blind_call.spec');
    my $spec_content = <<'SPEC';
Top::
 /a/
 -> Top { return_a(Top) }
 => helper

helper:
 /a/
 -> helper { return_a(helper) }
SPEC

    open(my $fh, '>', $tmp_spec) or die "Cannot create mixed-action/blind-call spec '$tmp_spec': $!";
    print {$fh} $spec_content;
    close($fh);
    ok(-f $tmp_spec, 'temporary mixed-action/blind-call spec created');

    my ($exit_code, $out, $err) = run_get_parser_in_subprocess($tmp_spec);
    my $combined = ($out // '') . ($err // '');
    is(defined($exit_code) ? $exit_code : '<undef>', '0', 'mixed-action/blind-call subprocess exit code is 0');
    like($combined, qr/Cannot mix ACTION \(\->\) and BLIND CALL \(\=\>\) code blocks/,
        'mixed-action/blind-call diagnostics report incompatible action types');
    like($combined, qr/Rule 'Top'/, 'mixed-action/blind-call diagnostics include rule label');
    like($combined, qr/Solution: Use either ACTION blocks OR BLIND CALL blocks, not both/,
        'mixed-action/blind-call diagnostics include remediation guidance');
    unlike($combined, qr/__PARSER_DEFINED__/, 'mixed-action/blind-call subprocess does not return parser-defined marker');
    like($combined, qr/__PARSER_UNDEF__/, 'mixed-action/blind-call subprocess returns parser-undef marker');

    unlink($tmp_spec);
};
subtest 'parser_invalid_input_returns_undef_without_exit' => sub {
    plan tests => 5;

    my ($exit_code, $out, $err) = run_parser_invocation_in_subprocess('Lispish', '__INPUT_ARRAYREF__');
    my $combined = ($out // '') . ($err // '');

    is(defined($exit_code) ? $exit_code : '<undef>', '0', 'invalid-input parser subprocess exit code is 0');
    like($combined, qr/__AST_UNDEF__/, 'invalid-input parser subprocess reports undef AST marker');
    unlike($combined, qr/__AST_DEFINED__/, 'invalid-input parser subprocess does not report AST-defined marker');
    unlike($combined, qr/Error during handler code generation/, 'invalid-input parser subprocess does not emit handler-generation error banner');
    unlike($combined, qr/__NO_PARSER__/, 'invalid-input parser subprocess confirms parser was created');
};
subtest 'bootstrap_registry_curly_brace_recursion_smoke' => sub {
    plan tests => 3;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { my $tmp = "{literal}"; if ($tmp) { return_a(Top) } }
SPEC

    my $parser = LinkedSpec::Get(\$spec_content);
    ok(defined($parser) && ref($parser) eq 'CODE', 'bootstrap-registry smoke builds parser coderef');

    my $input = 'a';
    my $ast = eval { $parser->(\$input) };
    ok(!$@, 'bootstrap-registry smoke parser executes without die') or diag(normalize_error($@));
    ok(defined($ast) && ref($ast) eq 'ARRAY', 'bootstrap-registry smoke parser returns AST array');
};
subtest 'get_return_descr_rule_meta_single_vs_multi_strategy' => sub {
    plan tests => 13;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { return_a(Top) }

AndMulti:&
 /b/ -> AndMulti { return_a(AndMulti) }
 /c/ -> AndMulti { return_a(AndMulti) }

Choice:|
 /d/ -> Choice { return_a(Choice) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'return_descr mode returns descriptor hash');
    ok(exists $descr->{spec} && ref($descr->{spec}) eq 'HASH', 'return_descr descriptor includes spec hash');
    ok(exists $descr->{gdata} && ref($descr->{gdata}) eq 'HASH', 'return_descr descriptor includes gdata hash');

    ok(exists $descr->{spec}{Top}{meta}, 'Top rule includes execution metadata');
    is($descr->{spec}{Top}{meta}{handler_variant}, 'AND_SINGLE_ACODE', 'Top single-regex AND maps to AND_SINGLE_ACODE');
    is($descr->{spec}{Top}{meta}{regex_count}, 1, 'Top metadata captures single regex count');
    ok(!$descr->{spec}{Top}{meta}{uses_loop}, 'Top single-regex AND metadata reports non-loop strategy');

    ok(exists $descr->{spec}{AndMulti}{meta}, 'AndMulti rule includes execution metadata');
    is($descr->{spec}{AndMulti}{meta}{handler_variant}, 'AND_ACODE', 'AndMulti multi-regex AND maps to AND_ACODE');
    is($descr->{spec}{AndMulti}{meta}{regex_count}, 2, 'AndMulti metadata captures multi-regex count');
    ok($descr->{spec}{AndMulti}{meta}{uses_loop}, 'AndMulti multi-regex AND metadata reports loop strategy');

    is($descr->{spec}{Choice}{meta}{handler_variant}, 'OR_ACODE', 'Choice OR rule maps to OR_ACODE');
    ok(!$descr->{spec}{Choice}{meta}{uses_loop}, 'Choice OR metadata reports non-loop dispatch');
};
subtest 'ruleir_pipeline_preserves_acode_gdata_mapping_order' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Alpha[0] { return_a(Top) }
 /b/ -> Beta[0] { return_a(Top) }

Alpha:
 /a/ -> Alpha { return_a(Alpha) }

Beta:
 /b/ -> Beta { return_a(Beta) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'RuleIR pipeline descriptor build returns hash');
    ok(ref($descr->{spec}{Top}{gdata}) eq 'ARRAY', 'Top rule gdata mapping array exists');
    is(scalar @{$descr->{spec}{Top}{gdata}}, 2, 'Top rule gdata mapping count preserved');
    is_deeply($descr->{spec}{Top}{gdata}[0], {label => 'Alpha', idx => 0}, 'Top gdata first mapping preserved');
    is_deeply($descr->{spec}{Top}{gdata}[1], {label => 'Beta', idx => 0}, 'Top gdata second mapping preserved');
    is($descr->{spec}{Top}{meta}{acode_count}, 2, 'Top metadata acode_count preserved');
    is($descr->{spec}{Top}{meta}{handler_variant}, 'AND_ACODE', 'Top handler variant remains AND_ACODE for multi-acode AND');
};
subtest 'compiler_spec_descr_uses_injected_compile_spec_entry_callback' => sub {
    plan tests => 5;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my ($parse_success, $retv, $parse_error) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$spec_content);
    ok($parse_success, 'bootstrap parse succeeds for injected spec_descr callback test') or diag(normalize_error($parse_error));
    ok(ref($retv) eq 'ARRAY', 'bootstrap parse returns parsed entry array');

    my $compile_spec_entry_count = 0;
    my $compiled = LinkedSpec::Compiler::spec_descr(
        $retv,
        sub {
            ++$compile_spec_entry_count;
            return LinkedSpec::SpecEntry::compile_spec_entry($_[0], { emit_parser_source_line => sub {} });
        }
    );

    ok(defined($compiled) && ref($compiled) eq 'HASH', 'spec_descr succeeds with injected compile_spec_entry callback');
    is($compile_spec_entry_count, 1, 'spec_descr invokes injected compile_spec_entry callback once for the single parsed rule');
    ok(ref($compiled->{Top}{handler}) eq 'CODE', 'compiled spec entry still exposes runtime handler coderef');
};
subtest 'spec_descr_defers_default_compile_callback_to_compiler_owner' => sub {
    plan tests => 6;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my ($parse_success, $retv, $parse_error) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$spec_content);
    ok($parse_success, 'bootstrap parse succeeds for spec_descr owner-default test') or diag(normalize_error($parse_error));
    ok(ref($retv) eq 'ARRAY' && @$retv == 1, 'bootstrap parse returns one parsed entry for spec_descr owner-default test');

    my $orig_compiler_spec_descr = \&LinkedSpec::Compiler::spec_descr;
    my ($ok_run, $compiled, $err) = (0, undef, '');
    my ($saw_undef_callback, $forwarded_entry_count);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Compiler::spec_descr = sub {
            my ($entries, $compile_spec_entry) = @_;
            $saw_undef_callback = !defined($compile_spec_entry);
            $forwarded_entry_count = ref($entries) eq 'ARRAY' ? scalar(@$entries) : undef;
            return $orig_compiler_spec_descr->(@_);
        };
        $compiled = LinkedSpec::spec_descr($retv);
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'LinkedSpec::spec_descr succeeds while Compiler::spec_descr delegation is trapped') or diag(normalize_error($err));
    ok($saw_undef_callback, 'LinkedSpec::spec_descr now delegates without injecting the default compile callback');
    is($forwarded_entry_count, 1, 'LinkedSpec::spec_descr forwards the parsed entry array unchanged');
    ok(defined($compiled) && ref($compiled) eq 'HASH' && ref($compiled->{Top}{handler}) eq 'CODE', 'Compiler-owned default compile callback still builds a compiled handler');
};
subtest 'get_avoids_runtime_run_get_from_args_wrapper' => sub {
    plan tests => 4;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my ($ok_run, $parser, $ast, $err) = (0, undef, undef, '');
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Runtime::run_get_from_args = sub { die "__UNEXPECTED_RUNTIME_RUN_GET_FROM_ARGS__\n" };
        $parser = LinkedSpec::Get(\$spec_content);
        my $input = 'a';
        $ast = $parser ? $parser->(\$input) : undef;
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'Get succeeds without Runtime raw-arg wrapper') or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_RUNTIME_RUN_GET_FROM_ARGS__/, 'Get does not call the trapped Runtime raw-arg wrapper');
    ok(defined($parser) && ref($parser) eq 'CODE', 'Get still returns parser coderef through direct Runtime::run_get delegation');
    ok(defined($ast) && ref($ast) eq 'ARRAY', 'parser created through direct Runtime::run_get delegation still executes');
};
subtest 'runtime_run_get_avoids_legacy_raw_arg_wrapper' => sub {
    plan tests => 4;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my ($ok_run, $descr, $err) = (0, undef, '');
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Runtime::run_get_from_args = sub { die "__UNEXPECTED_RUNTIME_RUN_GET_FROM_ARGS__\n" };
        $descr = LinkedSpec::Runtime::run_get(\$spec_content, { return_descr => 1 });
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'Runtime::run_get succeeds without the legacy raw-arg wrapper') or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_RUNTIME_RUN_GET_FROM_ARGS__/, 'Runtime::run_get does not call the trapped legacy raw-arg wrapper');
    ok(defined($descr) && ref($descr) eq 'HASH', 'Runtime::run_get still returns descriptor hash directly');
    ok(ref($descr->{spec}{Top}{handler}) eq 'CODE', 'Runtime::run_get still preserves compiled handler coderef');
};
subtest 'spec_entry_compile_spec_entry_uses_injected_runtime_context' => sub {
    plan tests => 9;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my ($parse_success, $retv, $parse_error) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$spec_content);
    ok($parse_success, 'bootstrap parse succeeds for injected runtime context test') or diag(normalize_error($parse_error));
    ok(ref($retv) eq 'ARRAY' && @$retv == 1, 'bootstrap parse returns one parsed entry for runtime context test');

    my @parser_source_chunks;
    my $runtime_ctx = {
        top_rule => undef,
        emit_parser_source_line => sub {
            my ($chunk) = @_;
            push @parser_source_chunks, $chunk;
        },
    };

    my ($label, $info, $ok_run, $err) = (undef, undef, 0, '');
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::_emit_parser_source_line = sub { die "__UNEXPECTED_LINKEDSPEC_EMIT_PARSER_SOURCE_LINE__\n" };
        ($label, $info) = LinkedSpec::SpecEntry::compile_spec_entry($retv->[0], { runtime_ctx => $runtime_ctx });
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'SpecEntry compile_spec_entry succeeds without the removed LinkedSpec emit-parser-source wrapper')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_LINKEDSPEC_EMIT_PARSER_SOURCE_LINE__/, 'SpecEntry compile_spec_entry does not call the trapped removed LinkedSpec emit-parser-source wrapper');
    is($label, 'Top', 'SpecEntry compile_spec_entry still returns rule label through injected runtime context');
    ok(defined($info) && ref($info) eq 'HASH', 'SpecEntry compile_spec_entry still returns rule info through injected runtime context');
    ok(ref($info->{handler}) eq 'CODE', 'SpecEntry compile_spec_entry still exposes runtime handler coderef');
    is($runtime_ctx->{top_rule}, 'Top', 'SpecEntry compile_spec_entry writes discovered top rule into injected runtime context');
    like(join('', @parser_source_chunks), qr/\n Top => sub \{/s, 'SpecEntry compile_spec_entry emits parser source through injected runtime context');
};
subtest 'spec_entry_paths_avoid_runtime_compile_spec_entry_wrapper' => sub {
    plan tests => 9;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my ($parse_success, $retv, $parse_error) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$spec_content);
    ok($parse_success, 'bootstrap parse succeeds for spec-entry wrapper bypass test') or diag(normalize_error($parse_error));
    ok(ref($retv) eq 'ARRAY' && @$retv == 1, 'bootstrap parse returns one parsed entry for spec-entry wrapper bypass test');

    my ($compiled, $descr, $ok_run, $err) = (undef, undef, 0, '');
    my $spec_content_for_get = $spec_content;
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Runtime::compile_spec_entry = sub { die "__UNEXPECTED_RUNTIME_COMPILE_SPEC_ENTRY__\n" };
        $compiled = LinkedSpec::spec_descr($retv);
        $descr = LinkedSpec::Get(\$spec_content_for_get, return_descr => 1);
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'default spec-entry paths succeed without Runtime compile_spec_entry wrapper')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_RUNTIME_COMPILE_SPEC_ENTRY__/, 'default spec-entry paths do not call the trapped Runtime compile_spec_entry wrapper');
    ok(defined($compiled) && ref($compiled) eq 'HASH', 'LinkedSpec::spec_descr default callback still builds compiled rule hash');
    ok(ref($compiled->{Top}{handler}) eq 'CODE', 'LinkedSpec::spec_descr default callback still exposes runtime handler coderef');
    ok(defined($descr) && ref($descr) eq 'HASH', 'LinkedSpec::Get return_descr path still builds descriptor without Runtime compile_spec_entry wrapper');
    ok(ref($descr->{spec}{Top}{handler}) eq 'CODE', 'descriptor build through Get still exposes runtime handler coderef');
    is($descr->{spec}{Top}{meta}{selected_handler_variant}, '_default', 'descriptor build through Get preserves selected handler metadata');
};
subtest 'spec_descr_paths_avoid_linkedspec_spec_entry_facade' => sub {
    plan tests => 9;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my ($parse_success, $retv, $parse_error) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$spec_content);
    ok($parse_success, 'bootstrap parse succeeds for LinkedSpec spec_entry facade bypass test') or diag(normalize_error($parse_error));
    ok(ref($retv) eq 'ARRAY' && @$retv == 1, 'bootstrap parse returns one parsed entry for LinkedSpec spec_entry facade bypass test');

    my ($compiled, $descr, $ok_run, $err) = (undef, undef, 0, '');
    my $spec_content_for_get = $spec_content;
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::spec_entry = sub { die "__UNEXPECTED_LINKEDSPEC_SPEC_ENTRY__\n" };
        $compiled = LinkedSpec::spec_descr($retv);
        $descr = LinkedSpec::Get(\$spec_content_for_get, return_descr => 1);
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'default spec-entry owner paths succeed without the LinkedSpec spec_entry facade')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_LINKEDSPEC_SPEC_ENTRY__/, 'default spec-entry owner paths do not call the trapped LinkedSpec spec_entry facade');
    ok(defined($compiled) && ref($compiled) eq 'HASH', 'LinkedSpec::spec_descr default callback still builds compiled rule hash without the facade');
    ok(ref($compiled->{Top}{handler}) eq 'CODE', 'LinkedSpec::spec_descr still exposes runtime handler coderef without the facade');
    ok(defined($descr) && ref($descr) eq 'HASH', 'LinkedSpec::Get return_descr path still builds descriptor without the LinkedSpec spec_entry facade');
    ok(ref($descr->{spec}{Top}{handler}) eq 'CODE', 'descriptor build through Get still exposes runtime handler coderef without the facade');
    is($descr->{spec}{Top}{meta}{selected_handler_variant}, '_default', 'descriptor build through Get still preserves selected handler metadata without the facade');
};
subtest 'spec_descr_and_get_avoid_removed_linkedspec_ruleir_internal_facade' => sub {
    plan tests => 10;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my ($parse_success, $retv, $parse_error) = LinkedSpec::BootstrapSpec::run_bootstrap_parse(\$spec_content);
    ok($parse_success, 'bootstrap parse succeeds for removed LinkedSpec RuleIR/internal facade bypass test') or diag(normalize_error($parse_error));
    ok(ref($retv) eq 'ARRAY' && @$retv == 1, 'bootstrap parse returns one parsed entry for removed LinkedSpec RuleIR/internal facade bypass test');

    my ($compiled, $descr, $ok_run, $err) = (undef, undef, 0, '');
    my $spec_content_for_get = $spec_content;
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::_build_action_rewriter_migration_summary = sub { die "__UNEXPECTED_LINKEDSPEC_BUILD_ACTION_REWRITER_MIGRATION_SUMMARY__\n" };
        local *LinkedSpec::_action_contract_deps = sub { die "__UNEXPECTED_LINKEDSPEC_ACTION_CONTRACT_DEPS__\n" };
        local *LinkedSpec::_build_action_lowering_contracts = sub { die "__UNEXPECTED_LINKEDSPEC_BUILD_ACTION_LOWERING_CONTRACTS__\n" };
        local *LinkedSpec::_select_rule_handler_variant = sub { die "__UNEXPECTED_LINKEDSPEC_SELECT_RULE_HANDLER_VARIANT__\n" };
        local *LinkedSpec::_build_rule_execution_meta = sub { die "__UNEXPECTED_LINKEDSPEC_BUILD_RULE_EXECUTION_META__\n" };
        local *LinkedSpec::_collect_rule_ir = sub { die "__UNEXPECTED_LINKEDSPEC_COLLECT_RULE_IR__\n" };
        local *LinkedSpec::_plan_rule_ir_meta = sub { die "__UNEXPECTED_LINKEDSPEC_PLAN_RULE_IR_META__\n" };
        local *LinkedSpec::_validate_rule_ir_or_exit = sub { die "__UNEXPECTED_LINKEDSPEC_VALIDATE_RULE_IR_OR_EXIT__\n" };
        local *LinkedSpec::_normalize_rule_code_chunks = sub { die "__UNEXPECTED_LINKEDSPEC_NORMALIZE_RULE_CODE_CHUNKS__\n" };
        local *LinkedSpec::_build_rule_ir_emit_context = sub { die "__UNEXPECTED_LINKEDSPEC_BUILD_RULE_IR_EMIT_CONTEXT__\n" };
        $compiled = LinkedSpec::spec_descr($retv);
        $descr = LinkedSpec::Get(\$spec_content_for_get, return_descr => 1);
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'spec_descr and Get succeed without the removed LinkedSpec RuleIR/internal facade helpers')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_LINKEDSPEC_/, 'spec_descr and Get do not call the trapped removed LinkedSpec RuleIR/internal facade helpers');
    ok(defined($compiled) && ref($compiled) eq 'HASH', 'LinkedSpec::spec_descr still builds compiled rule hash without the removed internal facade');
    ok(ref($compiled->{Top}{handler}) eq 'CODE', 'LinkedSpec::spec_descr still exposes runtime handler coderef without the removed internal facade');
    ok(defined($descr) && ref($descr) eq 'HASH', 'LinkedSpec::Get return_descr path still builds descriptor without the removed internal facade');
    ok(ref($descr->{spec}{Top}{handler}) eq 'CODE', 'descriptor build through Get still exposes runtime handler coderef without the removed internal facade');
    is($descr->{spec}{Top}{meta}{selected_handler_variant}, '_default', 'descriptor build through Get still preserves selected handler metadata without the removed internal facade');
    ok(ref($descr->{meta}{action_rewriter_migration}) eq 'HASH', 'descriptor build through Get still exposes action-rewriter migration summary without the removed internal facade');
};
subtest 'get_return_descr_avoids_removed_linkedspec_validation_facade' => sub {
    plan tests => 8;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my ($descr, $ok_run, $err) = (undef, 0, '');
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::get_dsl_context = sub { die "__UNEXPECTED_LINKEDSPEC_GET_DSL_CONTEXT__\n" };
        local *LinkedSpec::report_dsl_error = sub { die "__UNEXPECTED_LINKEDSPEC_REPORT_DSL_ERROR__\n" };
        local *LinkedSpec::validate_spec_content = sub { die "__UNEXPECTED_LINKEDSPEC_VALIDATE_SPEC_CONTENT__\n" };
        local *LinkedSpec::validate_rule_definition = sub { die "__UNEXPECTED_LINKEDSPEC_VALIDATE_RULE_DEFINITION__\n" };
        local *LinkedSpec::validate_gdata_references = sub { die "__UNEXPECTED_LINKEDSPEC_VALIDATE_GDATA_REFERENCES__\n" };
        local *LinkedSpec::validate_dsl_syntax = sub { die "__UNEXPECTED_LINKEDSPEC_VALIDATE_DSL_SYNTAX__\n" };
        local *LinkedSpec::extract_regex_literals_from_rule_rhs = sub { die "__UNEXPECTED_LINKEDSPEC_EXTRACT_REGEX_LITERALS_FROM_RULE_RHS__\n" };
        $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'Get return_descr succeeds without the removed LinkedSpec validation facade helpers')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_LINKEDSPEC_/, 'Get return_descr does not call the trapped removed LinkedSpec validation facade helpers');
    ok(defined($descr) && ref($descr) eq 'HASH', 'Get return_descr still returns descriptor hash without the removed validation facade');
    ok(ref($descr->{spec}) eq 'HASH', 'descriptor build still exposes spec hash without the removed validation facade');
    ok(ref($descr->{spec}{Top}{handler}) eq 'CODE', 'descriptor build still exposes runtime handler coderef without the removed validation facade');
    ok(ref($descr->{gdata}) eq 'HASH', 'descriptor build still exposes gdata hash without the removed validation facade');
    is($descr->{spec}{Top}{meta}{selected_handler_variant}, '_default', 'descriptor build still preserves selected handler metadata without the removed validation facade');
    ok(ref($descr->{meta}{action_rewriter_migration}) eq 'HASH', 'descriptor build still exposes migration metadata without the removed validation facade');
};
subtest 'compiler_run_get_pipeline_uses_injected_bootstrap_parse_and_runtime_context' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my @parser_source_chunks;
    my $parser_source = '';
    my $bootstrap_parse_count = 0;
    my $runtime_ctx = {
        top_rule => undef,
        parser_source_chunks_ref => \@parser_source_chunks,
        emit_parser_source_line => sub {
            my ($chunk) = @_;
            push @parser_source_chunks, $chunk;
        },
    };

    my $descr = LinkedSpec::Compiler::run_get_pipeline(
        \$spec_content,
        {
            return_descr => 1,
            dump_parser_source => 1,
            parser_source_ref => \$parser_source,
        },
        {
            bootstrap_parse => sub {
                ++$bootstrap_parse_count;
                return LinkedSpec::BootstrapSpec::run_bootstrap_parse($_[0]);
            },
            compile_spec_entry => sub {
                return LinkedSpec::SpecEntry::compile_spec_entry($_[0], { runtime_ctx => $runtime_ctx });
            },
            runtime_ctx => $runtime_ctx,
        },
    );

    ok(defined($descr) && ref($descr) eq 'HASH', 'compiler pipeline returns descriptor through injected runtime context');
    ok(ref($descr->{spec}{Top}{handler}) eq 'CODE', 'compiler pipeline still builds runtime handler through injected runtime context');
    is($bootstrap_parse_count, 1, 'compiler pipeline invokes injected bootstrap_parse callback exactly once');
    is($runtime_ctx->{top_rule}, 'Top', 'compiler pipeline records top rule in injected runtime context');
    ok(@parser_source_chunks > 0, 'compiler pipeline records parser-source chunks in injected runtime context');
    like(join('', @parser_source_chunks), qr/sub Get \{&\{\$descr->\{spec\}\{Top\}\}\(\$descr, \$_\[0\]\)\}/s, 'compiler pipeline emits final Get wrapper through injected runtime context');
    like($parser_source, qr/sub Get \{&\{\$descr->\{spec\}\{Top\}\}\(\$descr, \$_\[0\]\)\}/s, 'compiler pipeline writes parser source through injected runtime context-backed capture');
};
subtest 'runtime_run_get_defers_default_pipeline_callbacks_to_compiler_owner' => sub {
    plan tests => 6;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my $orig_run_get_pipeline = \&LinkedSpec::Compiler::run_get_pipeline;
    my ($ok_run, $descr, $err) = (0, undef, '');
    my ($saw_runtime_ctx, $saw_bootstrap_parse_key, $saw_compile_spec_entry_key);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Compiler::run_get_pipeline = sub {
            my ($spec_content_ref, $option, $deps) = @_;
            $saw_runtime_ctx = ref($deps->{runtime_ctx}) eq 'HASH';
            $saw_bootstrap_parse_key = exists $deps->{bootstrap_parse};
            $saw_compile_spec_entry_key = exists $deps->{compile_spec_entry};
            return $orig_run_get_pipeline->(@_);
        };

        $descr = LinkedSpec::Runtime::run_get(\$spec_content, { return_descr => 1 });
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'Runtime::run_get succeeds while Compiler::run_get_pipeline delegation is trapped') or diag(normalize_error($err));
    ok($saw_runtime_ctx, 'Runtime::run_get still injects runtime_ctx into the compiler pipeline');
    ok(!$saw_bootstrap_parse_key, 'Runtime::run_get no longer injects bootstrap_parse into the compiler pipeline');
    ok(!$saw_compile_spec_entry_key, 'Runtime::run_get no longer injects compile_spec_entry into the compiler pipeline');
    ok(defined($descr) && ref($descr) eq 'HASH', 'compiler-owned default pipeline callbacks still return descriptor hash through Runtime::run_get');
    ok(ref($descr->{spec}{Top}{handler}) eq 'CODE', 'descriptor returned through Runtime::run_get still preserves compiled handler coderef');
};
subtest 'compiler_pipeline_avoids_legacy_run_bootstrap_parse_helper' => sub {
    plan tests => 4;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my ($ok_run, $descr, $err) = (0, undef, '');
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Compiler::_run_bootstrap_parse = sub { die "__UNEXPECTED_COMPILER_RUN_BOOTSTRAP_PARSE__\n" };
        $descr = LinkedSpec::Runtime::run_get(\$spec_content, { return_descr => 1 });
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'compiler pipeline succeeds without the legacy compiler bootstrap helper') or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_COMPILER_RUN_BOOTSTRAP_PARSE__/, 'compiler pipeline does not call the trapped legacy compiler bootstrap helper');
    ok(defined($descr) && ref($descr) eq 'HASH', 'compiler pipeline still returns descriptor hash without the legacy compiler bootstrap helper');
    ok(ref($descr->{spec}{Top}{handler}) eq 'CODE', 'descriptor returned without the legacy compiler bootstrap helper still preserves compiled handler coderef');
};
subtest 'run_get_pipeline_defers_default_spec_gdata_callback_to_final_descr_owner' => sub {
    plan tests => 5;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my $runtime_ctx = {
        top_rule => undef,
        parser_source_chunks_ref => [],
    };

    my $orig_build_final_descr = \&LinkedSpec::Compiler::_build_final_descr;
    my ($ok_run, $descr, $err) = (0, undef, '');
    my ($saw_undef_spec_gdata_cb, $saw_top_rule_spec);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Compiler::_build_final_descr = sub {
            my ($auto_descr_spec, $spec_gdata_cb) = @_;
            $saw_undef_spec_gdata_cb = !defined($spec_gdata_cb);
            $saw_top_rule_spec = ref($auto_descr_spec) eq 'HASH' && exists $auto_descr_spec->{Top};
            return $orig_build_final_descr->(@_);
        };

        $descr = LinkedSpec::Compiler::run_get_pipeline(
            \$spec_content,
            { return_descr => 1 },
            {
                bootstrap_parse => sub {
                    return LinkedSpec::BootstrapSpec::run_bootstrap_parse($_[0]);
                },
                compile_spec_entry => sub {
                    return LinkedSpec::SpecEntry::compile_spec_entry($_[0], { runtime_ctx => $runtime_ctx });
                },
                runtime_ctx => $runtime_ctx,
            },
        );
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'compiler pipeline succeeds while final descriptor assembly is trapped') or diag(normalize_error($err));
    ok($saw_undef_spec_gdata_cb, 'compiler pipeline now lets final descriptor assembly own the default spec_gdata callback');
    ok($saw_top_rule_spec, 'compiler pipeline still forwards compiled rule descriptors into final descriptor assembly');
    ok(defined($descr) && ref($descr) eq 'HASH', 'compiler pipeline still returns descriptor hash when final descriptor owner supplies spec_gdata');
    ok(ref($descr->{spec}{Top}{handler}) eq 'CODE', 'final descriptor assembly still preserves compiled handler coderef');
};
subtest 'compiler_pipeline_avoids_linkedspec_spec_gdata_facade' => sub {
    plan tests => 4;

    my $spec_content = <<'SPEC';
Top::
 /a/ -> Top { return_a(Top) }
SPEC

    my ($ok_run, $descr, $err) = (0, undef, '');
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::spec_gdata = sub { die "__UNEXPECTED_LINKEDSPEC_SPEC_GDATA__\n" };
        $descr = LinkedSpec::Runtime::run_get(\$spec_content, { return_descr => 1 });
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'compiler pipeline succeeds without the LinkedSpec spec_gdata facade') or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_LINKEDSPEC_SPEC_GDATA__/, 'compiler pipeline does not call the trapped LinkedSpec spec_gdata facade');
    ok(defined($descr) && ref($descr) eq 'HASH', 'compiler pipeline still returns descriptor hash without the LinkedSpec spec_gdata facade');
    ok(ref($descr->{gdata}) eq 'HASH', 'final descriptor assembly still produces compiled gdata through Compiler ownership');
};
subtest 'ruleir_emit_context_avoids_removed_linkedspec_action_rewriter_facade' => sub {
    plan tests => 7;

    my $rule_ir = {
        label => 'Top',
        node_type => 'default',
        REs => [qr/a/],
        code_blocks => {
            ICODE  => [],
            ECODE  => [],
            EXCODE => [],
            ITCODE => [],
            LXCODE => [],
            LSCODE => [],
            LECODE => [],
        },
        acode_entries => [
            { relabel => 'Top', reidx => 0, code => 'return_a(Top)' },
        ],
        bcode_entries => [],
    };

    my ($emit_ctx, $ok_run, $err) = (undef, 0, '');
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::_find_unresolved_action_helpers = sub { die "__UNEXPECTED_LINKEDSPEC_FIND_UNRESOLVED_ACTION_HELPERS__\n" };
        local *LinkedSpec::_scan_contract_ir_events = sub { die "__UNEXPECTED_LINKEDSPEC_SCAN_CONTRACT_IR_EVENTS__\n" };
        local *LinkedSpec::_collect_action_helper_ir_nodes = sub { die "__UNEXPECTED_LINKEDSPEC_COLLECT_ACTION_HELPER_IR_NODES__\n" };
        local *LinkedSpec::_build_action_rewrite_rules = sub { die "__UNEXPECTED_LINKEDSPEC_BUILD_ACTION_REWRITE_RULES__\n" };
        local *LinkedSpec::_rewrite_action_code_with_diagnostics = sub { die "__UNEXPECTED_LINKEDSPEC_REWRITE_ACTION_CODE_WITH_DIAGNOSTICS__\n" };
        local *LinkedSpec::_accumulate_action_rewrite_diagnostics = sub { die "__UNEXPECTED_LINKEDSPEC_ACCUMULATE_ACTION_REWRITE_DIAGNOSTICS__\n" };
        local *LinkedSpec::_trim_action_ir_value = sub { die "__UNEXPECTED_LINKEDSPEC_TRIM_ACTION_IR_VALUE__\n" };
        local *LinkedSpec::_canonicalize_helper_action_ir_event = sub { die "__UNEXPECTED_LINKEDSPEC_CANONICALIZE_HELPER_ACTION_IR_EVENT__\n" };
        local *LinkedSpec::_split_action_ir_statements = sub { die "__UNEXPECTED_LINKEDSPEC_SPLIT_ACTION_IR_STATEMENTS__\n" };
        local *LinkedSpec::_build_canonical_action_ir_events = sub { die "__UNEXPECTED_LINKEDSPEC_BUILD_CANONICAL_ACTION_IR_EVENTS__\n" };
        local *LinkedSpec::_lower_action_code_from_canonical_ir = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_ACTION_CODE_FROM_CANONICAL_IR__\n" };
        $emit_ctx = LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context($rule_ir);
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'RuleIR emit-context build succeeds without the removed LinkedSpec action-rewriter facade helpers')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_LINKEDSPEC_/, 'RuleIR emit-context does not call the trapped removed LinkedSpec facade helpers');
    ok(defined($emit_ctx) && ref($emit_ctx) eq 'HASH', 'RuleIR emit-context returns hashref');
    ok(ref($emit_ctx->{ACODEs}) eq 'ARRAY' && @{$emit_ctx->{ACODEs}} == 1, 'RuleIR emit-context returns rewritten ACODE list');
    is_deeply($emit_ctx->{GDATA}, [{ label => 'Top', idx => 0 }], 'RuleIR emit-context preserves ACODE gdata mapping');
    ok(ref($emit_ctx->{action_rewriter_meta}) eq 'HASH', 'RuleIR emit-context exposes action-rewriter metadata');
    ok(($emit_ctx->{action_rewriter_meta}{rewrite_contract_ids} && @{$emit_ctx->{action_rewriter_meta}{rewrite_contract_ids}} > 0),
        'RuleIR emit-context still builds rewrite contracts through extracted action-rewriter module');
};
subtest 'action_rewriter_avoids_removed_linkedspec_lowering_facade' => sub {
    plan tests => 15;

    my %rewritten;
    my ($ok_run, $err) = (0, '');
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::_flow_expr_deps = sub { die "__UNEXPECTED_LINKEDSPEC_FLOW_EXPR_DEPS__\n" };
        local *LinkedSpec::_method_lowering_deps = sub { die "__UNEXPECTED_LINKEDSPEC_METHOD_LOWERING_DEPS__\n" };
        local *LinkedSpec::_declare_method_deps = sub { die "__UNEXPECTED_LINKEDSPEC_DECLARE_METHOD_DEPS__\n" };
        local *LinkedSpec::_array_pipeline_deps = sub { die "__UNEXPECTED_LINKEDSPEC_ARRAY_PIPELINE_DEPS__\n" };
        local *LinkedSpec::_control_flow_deps = sub { die "__UNEXPECTED_LINKEDSPEC_CONTROL_FLOW_DEPS__\n" };
        local *LinkedSpec::_lower_is_empty_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_IS_EMPTY_EXPR__\n" };
        local *LinkedSpec::_lower_flow_composite_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_FLOW_COMPOSITE_EXPR__\n" };
        local *LinkedSpec::_split_declare_symbol_names = sub { die "__UNEXPECTED_LINKEDSPEC_SPLIT_DECLARE_SYMBOL_NAMES__\n" };
        local *LinkedSpec::_parse_declare_binding_entry = sub { die "__UNEXPECTED_LINKEDSPEC_PARSE_DECLARE_BINDING_ENTRY__\n" };
        local *LinkedSpec::_lower_declare_value_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_DECLARE_VALUE_EXPR__\n" };
        local *LinkedSpec::_lower_declare_initializer_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_DECLARE_INITIALIZER_EXPR__\n" };
        local *LinkedSpec::_declare_sigil_for_type = sub { die "__UNEXPECTED_LINKEDSPEC_DECLARE_SIGIL_FOR_TYPE__\n" };
        local *LinkedSpec::_lower_method_value_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_METHOD_VALUE_EXPR__\n" };
        local *LinkedSpec::_declare_alias_to_type = sub { die "__UNEXPECTED_LINKEDSPEC_DECLARE_ALIAS_TO_TYPE__\n" };
        local *LinkedSpec::_lower_typed_declare_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_TYPED_DECLARE_STATEMENT__\n" };
        local *LinkedSpec::_normalize_method_tag_expr = sub { die "__UNEXPECTED_LINKEDSPEC_NORMALIZE_METHOD_TAG_EXPR__\n" };
        local *LinkedSpec::_value_expr_deps = sub { die "__UNEXPECTED_LINKEDSPEC_VALUE_EXPR_DEPS__\n" };
        local *LinkedSpec::_extract_scalar_symbol_name = sub { die "__UNEXPECTED_LINKEDSPEC_EXTRACT_SCALAR_SYMBOL_NAME__\n" };
        local *LinkedSpec::_extract_array_symbol_name = sub { die "__UNEXPECTED_LINKEDSPEC_EXTRACT_ARRAY_SYMBOL_NAME__\n" };
        local *LinkedSpec::_extract_hash_symbol_name = sub { die "__UNEXPECTED_LINKEDSPEC_EXTRACT_HASH_SYMBOL_NAME__\n" };
        local *LinkedSpec::_lower_scalar_access_key_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_SCALAR_ACCESS_KEY_EXPR__\n" };
        local *LinkedSpec::_split_scalaref_path_segments = sub { die "__UNEXPECTED_LINKEDSPEC_SPLIT_SCALAREF_PATH_SEGMENTS__\n" };
        local *LinkedSpec::_lower_scalaref_segment_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_SCALAREF_SEGMENT_EXPR__\n" };
        local *LinkedSpec::_lower_scalaref_value_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_SCALAREF_VALUE_EXPR__\n" };
        local *LinkedSpec::_infer_scalar_container_kind = sub { die "__UNEXPECTED_LINKEDSPEC_INFER_SCALAR_CONTAINER_KIND__\n" };
        local *LinkedSpec::_lower_assignment_source_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_ASSIGNMENT_SOURCE_EXPR__\n" };
        local *LinkedSpec::_strip_literal_delimiters = sub { die "__UNEXPECTED_LINKEDSPEC_STRIP_LITERAL_DELIMITERS__\n" };
        local *LinkedSpec::_split_top_level_csv = sub { die "__UNEXPECTED_LINKEDSPEC_SPLIT_TOP_LEVEL_CSV__\n" };
        local *LinkedSpec::_lower_assign_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_ASSIGN_STATEMENT__\n" };
        local *LinkedSpec::_lower_return_payload_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_RETURN_PAYLOAD_EXPR__\n" };
        local *LinkedSpec::_build_array_pipeline_plan_from_expr = sub { die "__UNEXPECTED_LINKEDSPEC_BUILD_ARRAY_PIPELINE_PLAN_FROM_EXPR__\n" };
        local *LinkedSpec::_lower_return_general_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_RETURN_GENERAL_STATEMENT__\n" };
        local *LinkedSpec::_lower_return_imatch_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_RETURN_IMATCH_STATEMENT__\n" };
        local *LinkedSpec::_lower_push_value_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_PUSH_VALUE_STATEMENT__\n" };
        local *LinkedSpec::_lower_assign_method_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_ASSIGN_METHOD_STATEMENT__\n" };
        local *LinkedSpec::_extract_declare_statement_from_method_expr = sub { die "__UNEXPECTED_LINKEDSPEC_EXTRACT_DECLARE_STATEMENT_FROM_METHOD_EXPR__\n" };
        local *LinkedSpec::_lower_declare_method_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_DECLARE_METHOD_STATEMENT__\n" };
        local *LinkedSpec::_lower_regex_subst_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_REGEX_SUBST_STATEMENT__\n" };
        local *LinkedSpec::_normalize_split_delimiter_expr = sub { die "__UNEXPECTED_LINKEDSPEC_NORMALIZE_SPLIT_DELIMITER_EXPR__\n" };
        local *LinkedSpec::_parse_method_function_expr = sub { die "__UNEXPECTED_LINKEDSPEC_PARSE_METHOD_FUNCTION_EXPR__\n" };
        local *LinkedSpec::_is_bare_method_scope_token = sub { die "__UNEXPECTED_LINKEDSPEC_IS_BARE_METHOD_SCOPE_TOKEN__\n" };
        local *LinkedSpec::_normalize_method_args_with_optional_scope = sub { die "__UNEXPECTED_LINKEDSPEC_NORMALIZE_METHOD_ARGS_WITH_OPTIONAL_SCOPE__\n" };
        local *LinkedSpec::_lower_control_flow_value_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_CONTROL_FLOW_VALUE_EXPR__\n" };
        local *LinkedSpec::_lower_switch_case_value_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_SWITCH_CASE_VALUE_EXPR__\n" };
        local *LinkedSpec::_lower_array_pipeline_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_ARRAY_PIPELINE_EXPR__\n" };
        local *LinkedSpec::_lower_if_flow_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_IF_FLOW_STATEMENT__\n" };
        local *LinkedSpec::_lower_elseif_flow_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_ELSEIF_FLOW_STATEMENT__\n" };
        local *LinkedSpec::_lower_else_flow_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_ELSE_FLOW_STATEMENT__\n" };
        local *LinkedSpec::_lower_endif_flow_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_ENDIF_FLOW_STATEMENT__\n" };
        local *LinkedSpec::_lower_flow_branch_action_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_FLOW_BRANCH_ACTION_EXPR__\n" };
        local *LinkedSpec::_lower_inline_switch_branch_expr = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_INLINE_SWITCH_BRANCH_EXPR__\n" };
        local *LinkedSpec::_lower_switch_flow_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_SWITCH_FLOW_STATEMENT__\n" };
        local *LinkedSpec::_lower_case_flow_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_CASE_FLOW_STATEMENT__\n" };
        local *LinkedSpec::_lower_default_flow_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_DEFAULT_FLOW_STATEMENT__\n" };
        local *LinkedSpec::_lower_endcase_flow_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_ENDCASE_FLOW_STATEMENT__\n" };
        local *LinkedSpec::_lower_endswitch_flow_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_ENDSWITCH_FLOW_STATEMENT__\n" };
        local *LinkedSpec::_lower_say_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_SAY_STATEMENT__\n" };
        local *LinkedSpec::_lower_print_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_PRINT_STATEMENT__\n" };
        local *LinkedSpec::_lower_return_undef_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_RETURN_UNDEF_STATEMENT__\n" };
        local *LinkedSpec::_lower_split_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_SPLIT_STATEMENT__\n" };
        local *LinkedSpec::_lower_trim_each_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_TRIM_EACH_STATEMENT__\n" };
        local *LinkedSpec::_lower_filter_nonempty_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_FILTER_NONEMPTY_STATEMENT__\n" };
        local *LinkedSpec::_lower_lowercase_each_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_LOWERCASE_EACH_STATEMENT__\n" };
        local *LinkedSpec::_lower_uppercase_each_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_UPPERCASE_EACH_STATEMENT__\n" };
        local *LinkedSpec::_lower_uniq_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_UNIQ_STATEMENT__\n" };
        local *LinkedSpec::_lower_filter_match_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_FILTER_MATCH_STATEMENT__\n" };
        local *LinkedSpec::_lower_return_array_statement = sub { die "__UNEXPECTED_LINKEDSPEC_LOWER_RETURN_ARRAY_STATEMENT__\n" };

        $rewritten{declare} = LinkedSpec::ActionRewriter::call_spec_handler_subst(
            'Top',
            'declare_s(Top, flag=or(scalar(on), scalar(off)))',
        );
        $rewritten{assign} = LinkedSpec::ActionRewriter::call_spec_handler_subst(
            'Top',
            'assign(Top, scalar(flag), or(scalar(on), scalar(off)))',
        );
        $rewritten{push} = LinkedSpec::ActionRewriter::call_spec_handler_subst(
            'Top',
            'push_value(array(items), scalar(retv))',
        );
        $rewritten{regex} = LinkedSpec::ActionRewriter::call_spec_handler_subst(
            'Top',
            'substr(Top, scalar(c), /^"|"$/, //, go)',
        );
        $rewritten{pipeline} = LinkedSpec::ActionRewriter::call_spec_handler_subst(
            'Top',
            'split(array(parts), scalar(args), /\s*,\s*/); trim_each(array(parts)); filter_nonempty(array(parts))',
        );
        $rewritten{flow} = LinkedSpec::ActionRewriter::call_spec_handler_subst(
            'Top',
            'if(scalar(on)); print("warn"); else(); return_undef(); endif()',
        );
        $rewritten{flow_empty} = LinkedSpec::ActionRewriter::call_spec_handler_subst(
            'Top',
            'if(is_empty(array(items))); return_undef(); endif()',
        );
        $rewritten{switch} = LinkedSpec::ActionRewriter::call_spec_handler_subst(
            'Top',
            'switch(scalar(kind)); case(foo); print("hit"); default(); say("miss"); endswitch()',
        );
        $rewritten{return_imatch} = LinkedSpec::ActionRewriter::call_spec_handler_subst(
            'Top',
            'return_imatch(Top, semantic_annotation)',
        );
        $rewritten{return_array} = LinkedSpec::ActionRewriter::call_spec_handler_subst(
            'Top',
            'return_array(Top, semantic_annotation, array(scalar(IMATCH_LIST, 0), scalar(c)))',
        );
        $rewritten{return_general} = LinkedSpec::ActionRewriter::call_spec_handler_subst(
            'Top',
            'return(array_copy(array(items)))',
        );
        $rewritten{pipeline_match} = LinkedSpec::ActionRewriter::call_spec_handler_subst(
            'Top',
            'lowercase_each(array(parts)); filter_match(uniq(uppercase_each(array(parts))), /^[A-Z_]+$/)',
        );
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionRewriter lowering succeeds without the removed LinkedSpec lowering facade helpers')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_LINKEDSPEC_/, 'ActionRewriter lowering does not call the trapped removed LinkedSpec facade helpers');
    is($rewritten{declare}, 'my $flag = (($on) || ($off))', 'declare alias lowering stays inside ActionRewriter-owned lowering path');
    is($rewritten{assign}, '$flag = (($on) || ($off))', 'assign lowering stays inside ActionRewriter-owned lowering path');
    is($rewritten{push}, 'push @items, $retv', 'push_value lowering stays inside ActionRewriter-owned lowering path');
    is($rewritten{regex}, '$c =~ s{^"|"$}{}go', 'regex substitution lowering stays inside ActionRewriter-owned lowering path');
    is($rewritten{pipeline}, '@parts = split /\s*,\s*/, $args; @parts = map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } @parts; @parts = grep { length($_) } @parts',
        'array pipeline lowering stays inside ActionRewriter-owned lowering path');
    is($rewritten{flow}, 'if ($on) {; print "warn"; } else {; return undef; }',
        'if/else flow lowering stays inside ActionRewriter-owned lowering path');
    like($rewritten{flow_empty}, qr/!\@items.*return undef/s, 'is_empty flow lowering stays inside ActionRewriter-owned lowering path');
    like($rewritten{switch}, qr/^do \{ my \$__ls_switch_value_\d+ = \$kind; my \$__ls_switch_hit_\d+ = 0; if \(!\$__ls_switch_hit_\d+ && \$__ls_switch_value_\d+ eq "foo"\) \{ \$__ls_switch_hit_\d+ = 1; print "hit"; \} if \(!\$__ls_switch_hit_\d+\) \{ \$__ls_switch_hit_\d+ = 1; say "miss"; \} \}$/s,
        'switch/case/default lowering stays inside ActionRewriter-owned lowering path');
    is($rewritten{return_imatch}, 'return ["semantic_annotation", $IMATCH]', 'return_imatch lowering stays inside ActionRewriter-owned lowering path');
    is($rewritten{return_array}, 'return ["semantic_annotation", [$IMATCH_LIST[0], $c]]', 'return_array lowering stays inside ActionRewriter-owned lowering path');
    is($rewritten{return_general}, 'return [@items]', 'general return(payload) lowering stays inside ActionRewriter-owned lowering path');
    like($rewritten{pipeline_match}, qr/lc\(\$_\)/, 'lowercase_each lowering stays inside ActionRewriter-owned lowering path');
    like($rewritten{pipeline_match}, qr/A-Z_/, 'filter_match/uppercase/uniq lowering stays inside ActionRewriter-owned lowering path');
};
subtest 'actionir_scannercore_uses_scanner_dep_binding_owner' => sub {
    plan tests => 7;

    my ($ok_run, $err, $events) = (0, '', undef);
    my ($binding_calls, $captured_symbols) = (0, undef);
    $ok_run = eval {
        no warnings 'redefine';
        my $orig_with_scanner_rule_deps = \&LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_deps;
        local *LinkedSpec::ActionIR::ScannerCore::_with_scanner_rule_deps = sub {
            my ($bindings, $body) = @_;
            ++$binding_calls;
            $captured_symbols = [sort keys %{$bindings || {}}];
            return $orig_with_scanner_rule_deps->($bindings, $body);
        };
        $events = LinkedSpec::ActionIR::ScannerCore::scan_contract_ir_events(
            { id => 'return_bare' },
            "return foo;",
            {
                split_action_ir_statements => sub { return ['return foo'] },
                trim_action_ir_value => sub {
                    my ($value) = @_;
                    return undef unless defined $value;
                    $value =~ s/^\s+//;
                    $value =~ s/\s+$//;
                    return $value;
                },
                parse_method_function_expr => sub { die "__UNEXPECTED_PARSE_METHOD_FUNCTION_EXPR__\n" },
                normalize_method_args_with_optional_scope => sub { die "__UNEXPECTED_NORMALIZE_METHOD_ARGS__\n" },
                build_array_pipeline_plan_from_expr => sub { die "__UNEXPECTED_BUILD_ARRAY_PIPELINE_PLAN__\n" },
                extract_declare_statement_from_method_expr => sub { die "__UNEXPECTED_EXTRACT_DECLARE_STATEMENT__\n" },
                parse_declare_binding_entry => sub { die "__UNEXPECTED_PARSE_DECLARE_BINDING_ENTRY__\n" },
            },
        );
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionIR ScannerCore scan succeeds while the scanner dep-binding owner is trapped')
        or diag(normalize_error($err));
    is($binding_calls, 1, 'ActionIR ScannerCore routes dependency rebinding through the owner helper exactly once');
    is_deeply(
        $captured_symbols,
        [
            '_build_array_pipeline_plan_from_expr',
            '_extract_declare_statement_from_method_expr',
            '_normalize_method_args_with_optional_scope',
            '_parse_declare_binding_entry',
            '_parse_method_function_expr',
            '_split_action_ir_statements',
            '_trim_action_ir_value',
        ],
        'ActionIR ScannerCore owner helper receives the expected scanner rule dependency bindings'
    );
    ok(ref($events) eq 'ARRAY', 'ActionIR ScannerCore still returns an event list');
    is(scalar(@{$events || []}), 1, 'ActionIR ScannerCore still finds one return-bare event through the owner helper path');
    is($events->[0]{raw}, 'return foo', 'ActionIR ScannerCore preserves the scanned raw statement');
    is_deeply($events->[0]{args}, { payload => 'foo' }, 'ActionIR ScannerCore preserves the scanned return payload');
};
subtest 'action_rewriter_avoids_deps_scanner_dep_builder' => sub {
    plan tests => 4;

    my ($ok_run, $err, $rewritten) = (0, '', undef);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Deps::action_rewriter_scanner_deps_for_package = sub { die "__UNEXPECTED_DEPS_ACTION_REWRITER_SCANNER_DEPS__\n" };
        $rewritten = LinkedSpec::ActionRewriter::call_spec_handler_subst('Top', 'return_a(Top)');
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionRewriter rewrite succeeds without the removed Deps scanner dep builder')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_DEPS_ACTION_REWRITER_SCANNER_DEPS__/, 'ActionRewriter does not call the trapped Deps scanner dep builder');
    ok(defined($rewritten), 'ActionRewriter still returns rewritten code through the Scanner-owned default deps');
    is($rewritten, q{return ['?Top:', \@Top]}, 'ActionRewriter preserves helper rewrite output after moving scanner default deps into Scanner');
};
subtest 'action_rewriter_avoids_deps_statement_split_dep_builder' => sub {
    plan tests => 4;

    my ($ok_run, $err, $parts) = (0, '', undef);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Deps::action_rewriter_statement_split_deps_for_package = sub { die "__UNEXPECTED_DEPS_ACTION_REWRITER_STATEMENT_SPLIT_DEPS__\n" };
        $parts = LinkedSpec::ActionRewriter::_split_action_ir_statements("return foo; exit");
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionRewriter statement split succeeds without the removed Deps statement-split dep builder')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_DEPS_ACTION_REWRITER_STATEMENT_SPLIT_DEPS__/, 'ActionRewriter does not call the trapped Deps statement-split dep builder');
    ok(ref($parts) eq 'ARRAY', 'ActionRewriter still returns a split statement list through the StatementSplit-owned default deps');
    is_deeply($parts, ['return foo', 'exit'], 'ActionRewriter preserves statement splitting output after moving default deps into StatementSplit');
};
subtest 'action_rewriter_avoids_deps_canonical_event_dep_builder' => sub {
    plan tests => 4;

    my ($ok_run, $err, $diag) = (0, '', undef);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Deps::action_rewriter_canonical_event_deps_for_package = sub { die "__UNEXPECTED_DEPS_ACTION_REWRITER_CANONICAL_EVENT_DEPS__\n" };
        $diag = LinkedSpec::ActionRewriter::_build_canonical_action_ir_events(
            'Top',
            'return_a(Top)',
            [{ raw => 'return_a(Top)', args => { label => 'Top' }, contract_id => 'return_a', ir_node => 'RETURN' }],
        );
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionRewriter canonical-event build succeeds without the removed Deps canonical-event dep builder')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_DEPS_ACTION_REWRITER_CANONICAL_EVENT_DEPS__/, 'ActionRewriter does not call the trapped Deps canonical-event dep builder');
    ok(ref($diag) eq 'HASH', 'ActionRewriter still returns canonical-event diagnostics through the CanonicalEvents-owned default deps');
    is_deeply($diag->{canonical_action_ir_nodes}, ['RETURN_A'], 'ActionRewriter preserves canonical-event classification after moving default deps into CanonicalEvents');
};
subtest 'action_rewriter_avoids_deps_diagnostics_dep_builder' => sub {
    plan tests => 4;

    my ($ok_run, $err, $diag) = (0, '', undef);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Deps::action_rewriter_diagnostics_deps_for_package = sub { die "__UNEXPECTED_DEPS_ACTION_REWRITER_DIAGNOSTICS_DEPS__\n" };
        $diag = LinkedSpec::ActionRewriter::_find_unresolved_action_helpers(
            'return_a(Top); return_a(Top)',
            [{ id => 'return_a', diag_name => 'return_a', unresolved_pattern => qr/\breturn_a\s*\(/ }],
        );
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionRewriter diagnostics scan succeeds without the removed Deps diagnostics dep builder')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_DEPS_ACTION_REWRITER_DIAGNOSTICS_DEPS__/, 'ActionRewriter does not call the trapped Deps diagnostics dep builder');
    ok(ref($diag) eq 'HASH', 'ActionRewriter still returns diagnostics through the Diagnostics-owned default deps');
    is($diag->{unresolved_helper_count}, 2, 'ActionRewriter preserves unresolved-helper counting after moving default deps into Diagnostics');
};
subtest 'action_rewriter_avoids_deps_rewrite_pipeline_dep_builder' => sub {
    plan tests => 5;

    my ($ok_run, $err, $rewritten, $diag) = (0, '', undef, undef);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Deps::action_rewriter_rewrite_pipeline_deps_for_package = sub { die "__UNEXPECTED_DEPS_ACTION_REWRITER_REWRITE_PIPELINE_DEPS__\n" };
        ($rewritten, $diag) = LinkedSpec::ActionRewriter::_rewrite_action_code_with_diagnostics('Top', 'return_a(Top)');
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionRewriter rewrite pipeline succeeds without the removed Deps rewrite-pipeline dep builder')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_DEPS_ACTION_REWRITER_REWRITE_PIPELINE_DEPS__/, 'ActionRewriter does not call the trapped Deps rewrite-pipeline dep builder');
    is($rewritten, q{return ['?Top:', \@Top]}, 'ActionRewriter preserves rewrite output after moving default deps into RewritePipeline');
    ok(ref($diag) eq 'HASH', 'ActionRewriter still returns diagnostics through the RewritePipeline-owned default deps');
    is_deeply($diag->{canonical_action_ir_nodes}, ['RETURN_A'], 'ActionRewriter preserves canonical-event diagnostics through the RewritePipeline-owned default deps');
};
subtest 'action_rewriter_avoids_deps_declare_method_dep_builder' => sub {
    plan tests => 6;

    my ($ok_run, $err, $declare_stmt, $assign_stmt) = (0, '', undef, undef);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Deps::action_rewriter_declare_method_deps_for_package = sub { die "__UNEXPECTED_DEPS_ACTION_REWRITER_DECLARE_METHOD_DEPS__\n" };
        $declare_stmt = LinkedSpec::ActionRewriter::_lower_declare_method_statement('declare(array, items)');
        $assign_stmt = LinkedSpec::ActionRewriter::_lower_assign_method_statement('assign(retv, scalar(foo))');
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionRewriter declare-method lowering succeeds without the removed Deps declare-method dep builder')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_DEPS_ACTION_REWRITER_DECLARE_METHOD_DEPS__/, 'ActionRewriter does not call the trapped Deps declare-method dep builder');
    ok(defined($declare_stmt), 'ActionRewriter still returns lowered declare output through the DeclareMethod-owned default deps');
    is($declare_stmt, 'my @items', 'ActionRewriter preserves declare-method lowering output after moving default deps into DeclareMethod');
    ok(defined($assign_stmt), 'ActionRewriter still returns lowered assign output through the DeclareMethod-owned default deps');
    is($assign_stmt, '$retv = $foo', 'ActionRewriter preserves assign-method lowering output after moving default deps into DeclareMethod');
};
subtest 'action_rewriter_avoids_deps_action_contract_dep_builder' => sub {
    plan tests => 5;

    my ($ok_run, $err, $contracts, $declare_contract, $declare_output) = (0, '', undef, undef, undef);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Deps::action_rewriter_contract_deps_for_package = sub { die "__UNEXPECTED_DEPS_ACTION_REWRITER_CONTRACT_DEPS__\n" };
        $contracts = LinkedSpec::ActionRewriter::_build_action_lowering_contracts('Top');
        ($declare_contract) = grep { $_->{id} eq 'declare_typed' } @{$contracts || []};
        $declare_output = $declare_contract ? $declare_contract->{lower}->('declare(array, items)') : undef;
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionRewriter contract build succeeds without the removed Deps action-contract dep builder')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_DEPS_ACTION_REWRITER_CONTRACT_DEPS__/, 'ActionRewriter does not call the trapped Deps action-contract dep builder');
    ok(ref($contracts) eq 'ARRAY' && @{$contracts} > 0, 'ActionRewriter still returns lowering contracts through the Contracts-owned default deps');
    ok($declare_contract && ref($declare_contract->{lower}) eq 'CODE', 'ActionRewriter still exposes the declare_typed lowering contract through the Contracts owner');
    is($declare_output, 'my @items', 'ActionRewriter preserves declare_typed contract lowering after moving default deps into Contracts');
};
subtest 'action_rewriter_avoids_deps_value_expr_dep_builder' => sub {
    plan tests => 6;

    my ($ok_run, $err, $key_expr, $scalaref_expr) = (0, '', undef, undef);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Deps::value_expr_deps_for_package = sub { die "__UNEXPECTED_DEPS_VALUE_EXPR_DEPS__\n" };
        $key_expr = LinkedSpec::ActionRewriter::_lower_scalar_access_key_expr('scalar(foo)');
        $scalaref_expr = LinkedSpec::ActionRewriter::_lower_scalaref_value_expr('retv', '[scalar(foo)]');
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionRewriter value-expression lowering succeeds without the removed Deps value-expression dep builder')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_DEPS_VALUE_EXPR_DEPS__/, 'ActionRewriter does not call the trapped Deps value-expression dep builder');
    ok(defined($key_expr), 'ActionRewriter still returns lowered scalar access output through the ValueExpr-owned default deps');
    is($key_expr, '$foo', 'ActionRewriter preserves scalar access key lowering after moving default deps into ValueExpr');
    ok(defined($scalaref_expr), 'ActionRewriter still returns lowered scalaref output through the ValueExpr-owned default deps');
    is($scalaref_expr, '$retv->[$foo]', 'ActionRewriter preserves scalaref lowering after moving default deps into ValueExpr');
};
subtest 'action_rewriter_avoids_deps_flow_expr_dep_builder' => sub {
    plan tests => 6;

    my ($ok_run, $err, $empty_expr, $compound_expr) = (0, '', undef, undef);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Deps::flow_expr_deps_for_package = sub { die "__UNEXPECTED_DEPS_FLOW_EXPR_DEPS__\n" };
        $empty_expr = LinkedSpec::ActionRewriter::_lower_flow_composite_expr('is_empty(array(items))');
        $compound_expr = LinkedSpec::ActionRewriter::_lower_flow_composite_expr('or(eq(scalar(foo), "x"), not(is_empty(array(items))))');
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionRewriter flow-expression lowering succeeds without the removed Deps flow-expression dep builder')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_DEPS_FLOW_EXPR_DEPS__/, 'ActionRewriter does not call the trapped Deps flow-expression dep builder');
    ok(defined($empty_expr), 'ActionRewriter still returns lowered empty-check output through the FlowExpr-owned default deps');
    is($empty_expr, '(!@items)', 'ActionRewriter preserves empty-check flow lowering after moving default deps into FlowExpr');
    ok(defined($compound_expr), 'ActionRewriter still returns lowered composite flow output through the FlowExpr-owned default deps');
    is($compound_expr, '((($foo eq "x")) || ((!((!@items)))))', 'ActionRewriter preserves composite flow lowering after moving default deps into FlowExpr');
};
subtest 'action_rewriter_avoids_deps_array_pipeline_dep_builder' => sub {
    plan tests => 6;

    my ($ok_run, $err, $plan, $lowered) = (0, '', undef, undef);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Deps::array_pipeline_deps_for_package = sub { die "__UNEXPECTED_DEPS_ARRAY_PIPELINE_DEPS__\n" };
        $plan = LinkedSpec::ActionRewriter::_build_array_pipeline_plan_from_expr('filter_nonempty(array(items))');
        $lowered = LinkedSpec::ActionRewriter::_lower_array_pipeline_expr('filter_nonempty(array(items))');
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionRewriter array-pipeline lowering succeeds without the removed Deps array-pipeline dep builder')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_DEPS_ARRAY_PIPELINE_DEPS__/, 'ActionRewriter does not call the trapped Deps array-pipeline dep builder');
    ok(ref($plan) eq 'HASH', 'ActionRewriter still returns array-pipeline plans through the ArrayPipeline-owned default deps');
    is_deeply($plan, { target_symbol => 'items', ops => [{ op => 'filter_nonempty' }] }, 'ActionRewriter preserves array-pipeline planning after moving default deps into ArrayPipeline');
    ok(defined($lowered), 'ActionRewriter still returns lowered array-pipeline output through the ArrayPipeline-owned default deps');
    is($lowered, '@items = grep { length($_) } @items', 'ActionRewriter preserves array-pipeline lowering after moving default deps into ArrayPipeline');
};
subtest 'action_rewriter_avoids_deps_control_flow_dep_builder' => sub {
    plan tests => 7;

    my ($ok_run, $err, $if_stmt, $print_stmt, $ctx) = (0, '', undef, undef, undef);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Deps::control_flow_deps_for_package = sub { die "__UNEXPECTED_DEPS_CONTROL_FLOW_DEPS__\n" };
        $ctx = { if_stack => [], switch_stack => [], switch_counter => 0, rewrite_rules => [] };
        $if_stmt = LinkedSpec::ActionRewriter::_lower_if_flow_statement('if(is_empty(array(items)))', $ctx);
        $print_stmt = LinkedSpec::ActionRewriter::_lower_print_statement('print(scalar(foo))');
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionRewriter control-flow lowering succeeds without the removed Deps control-flow dep builder')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_DEPS_CONTROL_FLOW_DEPS__/, 'ActionRewriter does not call the trapped Deps control-flow dep builder');
    ok(defined($if_stmt), 'ActionRewriter still returns lowered if output through the ControlFlow-owned default deps');
    is($if_stmt, 'if ((!@items)) {', 'ActionRewriter preserves if-flow lowering after moving default deps into ControlFlow');
    is(scalar(@{$ctx->{if_stack} || []}), 1, 'ActionRewriter preserves if-stack mutation after moving default deps into ControlFlow');
    ok(defined($print_stmt), 'ActionRewriter still returns lowered print output through the ControlFlow-owned default deps');
    is($print_stmt, 'print $foo', 'ActionRewriter preserves print lowering after moving default deps into ControlFlow');
};
subtest 'action_rewriter_avoids_deps_method_lowering_dep_builder' => sub {
    plan tests => 8;

    my ($ok_run, $err, $alias, $assign_stmt, $return_array_stmt) = (0, '', undef, undef, undef);
    $ok_run = eval {
        no warnings 'redefine';
        local *LinkedSpec::Deps::method_lowering_deps_for_package = sub { die "__UNEXPECTED_DEPS_METHOD_LOWERING_DEPS__\n" };
        $alias = LinkedSpec::ActionRewriter::_declare_alias_to_type('array');
        $assign_stmt = LinkedSpec::ActionRewriter::_lower_assign_statement('scalar(foo)', 'scalar(bar)');
        $return_array_stmt = LinkedSpec::ActionRewriter::_lower_return_array_statement('Tag', 'array(items)');
        1;
    };
    $err = $@ // '' unless $ok_run;

    ok($ok_run, 'ActionRewriter method-lowering succeeds without the removed Deps method-lowering dep builder')
        or diag(normalize_error($err));
    unlike($err, qr/__UNEXPECTED_DEPS_METHOD_LOWERING_DEPS__/, 'ActionRewriter does not call the trapped Deps method-lowering dep builder');
    ok(defined($alias), 'ActionRewriter still returns declaration alias output through the MethodLowering-owned default deps');
    is($alias, 'array', 'ActionRewriter preserves declaration alias lowering after moving default deps into MethodLowering');
    ok(defined($assign_stmt), 'ActionRewriter still returns assign output through the MethodLowering-owned default deps');
    is($assign_stmt, '$foo = $bar', 'ActionRewriter preserves assign lowering after moving default deps into MethodLowering');
    ok(defined($return_array_stmt), 'ActionRewriter still returns return-array output through the MethodLowering-owned default deps');
    is($return_array_stmt, 'return ["Tag", [items]]', 'ActionRewriter preserves return-array lowering after moving default deps into MethodLowering');
};
subtest 'action_rewriter_require_avoids_linkedspec_deps_load' => sub {
    plan tests => 4;

    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(
        'require LinkedSpec::ActionRewriter;'
      . 'print exists($INC{"LinkedSpec/Deps.pm"}) ? "__DEPS_LOADED__\n" : "__DEPS_NOT_LOADED__\n";'
      . 'print exists($INC{"LinkedSpec/ActionIR/MethodExpr.pm"}) ? "__METHODEXPR_LOADED__\n" : "__METHODEXPR_NOT_LOADED__\n";'
    );

    is($exit_code, 0, 'ActionRewriter require-only subprocess exits cleanly') or diag($err || $out);
    like($out, qr/__DEPS_NOT_LOADED__/, 'ActionRewriter require-only subprocess keeps LinkedSpec::Deps unloaded');
    like($out, qr/__METHODEXPR_LOADED__/, 'ActionRewriter require-only subprocess still loads its direct ActionIR owner modules');
    is($err, '', 'ActionRewriter require-only subprocess does not emit stderr');
};
subtest 'action_rewriter_pipeline_helper_substitutions' => sub {
    plan tests => 10;

    my $label = 'Top';

    is(
        LinkedSpec::call_spec_handler_subst($label, 'call ( Foo )'),
        '&{$$descr{spec}{Foo}{handler}}($descr, $STRING, $minfo)',
        'call() helper rewrite preserves optional whitespace forms'
    );
    is(
        LinkedSpec::call_spec_handler_subst($label, 'push(Foo)'),
        'push @Top, &{$$descr{spec}{Foo}{handler}}($descr, $STRING, $minfo)',
        'push(rule) helper rewrite preserved'
    );
    is(
        LinkedSpec::call_spec_handler_subst($label, 'push(Foo,Bar)'),
        'push @Bar, &{$$descr{spec}{Foo}{handler}}($descr, $STRING, $minfo)',
        'push(rule,target) helper rewrite preserved'
    );
    is(
        LinkedSpec::call_spec_handler_subst($label, '$CAPTURE'),
        'substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH)',
        '$CAPTURE helper rewrite preserved'
    );
    is(
        LinkedSpec::call_spec_handler_subst($label, 'IBACKTRACK()'),
        'pos($$STRING) = $IPOS  - length $IMATCH',
        'IBACKTRACK() helper rewrite preserved'
    );
    is(
        LinkedSpec::call_spec_handler_subst($label, 'BACKTRACK()'),
        'pos($$STRING)  = $LSPOS - length $LMATCH',
        'BACKTRACK() helper rewrite preserved'
    );

    is(
        LinkedSpec::call_spec_handler_subst($label, 'return_a(Top, $x)'),
        q{return ['?Top:', ( $x), \@Top]},
        'return_a(label,arg) helper rewrite preserved'
    );
    is(
        LinkedSpec::call_spec_handler_subst($label, 'return_ma(Top)'),
        q{return ['?Top:', @IMATCH_LIST, \@Top]},
        'return_ma(label) helper rewrite preserved'
    );
    like(
        LinkedSpec::call_spec_handler_subst($label, 'capture_if(Top)'),
        qr/my \$capt = substr\(\$\$STRING, \$IPOS, \$LSPOS - \$IPOS - length \$LMATCH\);/,
        'capture_if(label) helper rewrite preserved'
    );
    like(
        LinkedSpec::call_spec_handler_subst($label, 'CAPTURE_IF ( )'),
        qr/push \@Top, \$capt if \$capt/,
        'CAPTURE_IF() helper rewrite preserves optional whitespace forms'
    );
};
subtest 'action_rewriter_lowers_typed_declare_methods_and_aliases' => sub {
    plan tests => 13;

    is(
        LinkedSpec::call_spec_handler_subst('Top', 'declare(array, items, captures); declare(scalar, flag); declare(hash, by_name)'),
        'my @items; my @captures; my $flag; my %by_name',
        'typed declare(type, ...) lowering emits canonical Perl declarations'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'declare_a(Top, items, captures); declare_s(Top, flag); declare_h(Top, by_name)'),
        'my @items; my @captures; my $flag; my %by_name',
        'declare_* aliases lower to same declaration semantics'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'declare_array(Top, items); declare_scalar(Top, flag); declare_hash(Top, by_name)'),
        'my @items; my $flag; my %by_name',
        'long declare_* aliases lower to same declaration semantics'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'declare(scalar, flag=or(scalar(on), scalar(off)), token=scalaref(myref, {kind}))'),
        'my $flag = (($on) || ($off)); my $token = $myref->{kind}',
        'declare(scalar, name=expr, ...) supports flow/value expression initializers'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'declare_array(Top, parts=array(scalar(a), scalar(b)))'),
        'my @parts = ($a, $b)',
        'declare_array alias supports array(...) initializer lowering'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'declare_hash(Top, by_name=hash("k1", scalar(v1), "k2", scalar(v2)))'),
        'my %by_name = ("k1" => $v1, "k2" => $v2)',
        'declare_hash alias supports hash(...) initializer lowering'
    );

    my $spec_content = <<'SPEC';
Top:: I.declare(array, items, captures=array(scalar(seed))).declare(scalar, flag=or(scalar(on), scalar(off))).declare(hash, by_name=hash("k", scalar(v)))
 /a/ -> Top { return_a(Top) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for non-action chained declare methods');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'chained declare methods avoid RAW_PERL fallback');
    is($meta->{raw_perl_dependency_count}, 0, 'chained declare methods avoid raw-Perl dependency');
    is($meta->{unresolved_helper_count}, 0, 'chained declare methods avoid unresolved-helper hits');
    ok(grep { $_ eq 'DECLARE' } @{$meta->{helper_action_ir_nodes}}, 'helper action-IR nodes include DECLARE for declare methods');
    ok(grep { $_ eq 'DECLARE' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include DECLARE for declare methods');
    ok($meta->{language_agnostic_action_ir_ready}, 'chained declare method rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_lowers_method_contracts_for_capture_and_structured_return_values' => sub {
    plan tests => 12;

    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return_imatch(Top, group_open)'),
        'return ["group_open", $IMATCH]',
        'return_imatch helper lowers to tagged IMATCH return payload'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return_im(group_open)'),
        'return ["group_open", $IMATCH]',
        'return_im alias lowers to tagged IMATCH return payload'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'assign(Top, scalar(c), CAPTURE)'),
        '$c = substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH)',
        'assign helper lowers CAPTURE source into canonical capture-expression assignment'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'assign(Top, scalar(flag), or(scalar(on), scalar(off)))'),
        '$flag = (($on) || ($off))',
        'assign helper accepts flow/value expression sources used by if/elseif/switch'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', q{assign(Top, scalar(capt_joined), join_values('', array(capt)))}),
        q{$capt_joined = join('', @capt)},
        'assign helper accepts join_values(delimiter, array(...)) source lowering'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'assign(scalar(retv), call(Leaf))'),
        q{$retv = &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo)},
        'assign helper accepts call(rule) source lowering'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'substr(Top, scalar(c), "\\s*$", "", o)'),
        '$c =~ s{\\s*$}{}o',
        'substr helper lowers quoted-pattern regex substitution'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'substr(Top, scalar(c), /^"|"$/, //, go)'),
        '$c =~ s{^"|"$}{}go',
        'substr helper lowers slash-pattern regex substitution'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return_array(Top, semantic_annotation, array(scalar(IMATCH_LIST, 0), scalar(c)))'),
        'return ["semantic_annotation", [$IMATCH_LIST[0], $c]]',
        'return_array helper lowers scalar()/array() constructor payloads'
    );

    my $spec_content = <<'SPEC';
Top:: I.assign(scalar(c), CAPTURE).substr(scalar(c), "\\s*$", "", o).return_array(semantic_annotation, array(scalar(IMATCH_LIST, 0), scalar(c)))
 /a/ -> Top { return_a(Top) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for non-action capture/return method contracts');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'capture/return method contracts avoid RAW_PERL fallback');
    ok(
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'REGEX_SUBST' } @{$meta->{canonical_action_ir_nodes}}),
        'canonical action-IR nodes include RETURN/ASSIGN/REGEX_SUBST for method contracts'
    );
};
subtest 'action_rewriter_lowers_push_value_method_contract' => sub {
    plan tests => 8;

    is(
        LinkedSpec::call_spec_handler_subst('Top', 'push_value(array(items), scalar(retv))'),
        'push @items, $retv',
        'push_value(array(target), scalar(value)) lowers to canonical Perl push statement'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'push_value(items, array(scalar(tag), scalar(name)))'),
        'push @items, [$tag, $name]',
        'push_value accepts bare target symbol and lowers nested array(...) value expression'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'push_value(Top, array(items), scalar(retv))'),
        'push @items, $retv',
        'push_value optional scope argument is ignored during lowering'
    );

    my $spec_content = <<'SPEC';
Top:: I.declare(array, items).declare(scalar, retv).assign(scalar(retv), CAPTURE).push_value(array(items), scalar(retv))
 /a/ -> Top { return_a(Top) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for push_value method contract');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'push_value method contract avoids RAW_PERL fallback');
    is($meta->{unresolved_helper_count}, 0, 'push_value method contract avoids unresolved-helper hits');
    ok(grep { $_ eq 'PUSH' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include PUSH for push_value contract');
    ok($meta->{language_agnostic_action_ir_ready}, 'push_value method contract remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_lowers_array_snapshot_and_array_assign_method_contracts' => sub {
    plan tests => 13;

    is(
        LinkedSpec::call_spec_handler_subst('Top', 'assign(array(items), array(scalar(retv)))'),
        '@items = ($retv)',
        'assign(array(target), array(...)) lowers to array assignment with lowered value payloads'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'assign(array(items), array())'),
        '@items = ()',
        'assign(array(target), array()) lowers to empty array assignment'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'push_value(array(assigns), array_values(array(keyval_pairs)))'),
        'push @assigns, [@keyval_pairs]',
        'push_value accepts array_values(array(...)) snapshot payloads'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'push_value(array(assigns), array_copy(array(keyval_pairs)))'),
        'push @assigns, [@keyval_pairs]',
        'push_value accepts array_copy(array(...)) snapshot payloads as the clearer alias'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return(array_values(array(items)))'),
        'return [@items]',
        'return(payload) lowers array_values(array(...)) to a snapshot array payload'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return(array_copy(array(items)))'),
        'return [@items]',
        'return(payload) lowers array_copy(array(...)) to the same snapshot array payload'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return({name=>scalar(block_namei), content=>array_values(array(assigns))})'),
        'return {name=>$block_namei, content=>[@assigns]}',
        'return(payload) lowers array_values(array(...)) inside structured hash payloads'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return({name=>scalar(block_namei), content=>array_copy(array(assigns))})'),
        'return {name=>$block_namei, content=>[@assigns]}',
        'return(payload) lowers array_copy(array(...)) inside structured hash payloads'
    );

    my $spec_content = <<'SPEC';
Top:: I.declare(array, items).declare(scalar, retv).assign(array(items), array(scalar(retv))).return(array_copy(array(items)))
 /a/ -> Top { return_a(Top) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for array snapshot alias/assign method contracts');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'array snapshot/assign method contracts avoid RAW_PERL fallback');
    is($meta->{unresolved_helper_count}, 0, 'array snapshot/assign method contracts avoid unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}),
        'canonical action-IR nodes include DECLARE/ASSIGN/RETURN for array snapshot/assign contracts'
    );
    ok($meta->{language_agnostic_action_ir_ready}, 'array snapshot alias/assign method contracts remain language-agnostic action-IR ready');
};
subtest 'action_rewriter_lowers_general_return_payloads_with_nested_structures' => sub {
    plan tests => 11;

    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return(["semantic", { key => scalar(name) }, [123, scalar(foo_arr, idx)]])'),
        'return ["semantic", { key => $name }, [123, $foo_arr[$idx]]]',
        'general return(payload) lowers nested array/hash payload with scalar helpers'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return({ item => scalar(foo_hash, key), list => [scalar(name), 123] })'),
        'return { item => $foo_hash{$key}, list => [$name, 123] }',
        'general return(payload) lowers scalar(container,key_or_index) forms inside nested hash/list payload'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return(scalaref(myref, [A][B]{C}[D]))'),
        'return $myref->[A]->[B]->{C}->[D]',
        'general return(payload) lowers scalaref(base,[...]{...}) with mixed index/key path segments'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return({ item => scalaref(myref, {A}[B]{C}[D]) })'),
        'return { item => $myref->{A}->[B]->{C}->[D] }',
        'general return(payload) lowers scalaref(base,{...}[...]) with hash-first path segments'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return(hash("kind", "node", "item", scalar(foo_hash, key), "list", array(scalar(name), 123)))'),
        'return {"kind" => "node", "item" => $foo_hash{$key}, "list" => [$name, 123]}',
        'general return(payload) lowers hash(...) constructor payloads with nested helper values'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return(Top, $x)'),
        q{return ['?Top:',  $x]},
        'legacy return(label,arg) helper behavior remains preserved for compatibility'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return_undef()'),
        'return undef',
        'return_undef() shorthand remains available'
    );

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top .return(["semantic", { key => scalar(name) }, [scalar(foo_arr, idx)]])
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for method-chain general return payload form');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'method-chain general return payload avoids RAW_PERL fallback');
    is($meta->{unresolved_helper_count}, 0, 'method-chain general return payload avoids unresolved-helper hits');
    ok(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}, 'method-chain general return payload contributes canonical RETURN action-IR node');
};
subtest 'action_rewriter_lowers_flat_list_value_helpers' => sub {
    plan tests => 10;

    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return(array("?subprogram_declaration:", flat_array(IMATCH_LIST)))'),
        'return ["?subprogram_declaration:", @IMATCH_LIST]',
        'flat_array(name) lowers array contents into surrounding array constructor list context'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return(array("semantic", flat(array(parts)), scalar(name)))'),
        'return ["semantic", @parts, $name]',
        'flat(array(name)) lowers explicit array wrapper into surrounding array constructor list context'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return(hash(flat_hash(extra), "kind", "node", "item", scalar(name)))'),
        'return {%extra, "kind" => "node", "item" => $name}',
        'flat_hash(name) lowers hash contents into surrounding hash constructor list context'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return(hash(flat(hash(extra)), "kind", "node"))'),
        'return {%extra, "kind" => "node"}',
        'flat(hash(name)) lowers explicit hash wrapper into surrounding hash constructor list context'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return(flat_array(items))'),
        'return @items',
        'return(payload) accepts flat_array(name) as a direct flat list payload'
    );

    my $spec_content = <<'SPEC';
Top::&
 /(\w+)\s+(\w+)/ -> Top .return(flat_array(IMATCH_LIST))
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for method-chain flat list return payload form');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'method-chain flat list return payload avoids RAW_PERL fallback');
    is($meta->{unresolved_helper_count}, 0, 'method-chain flat list return payload avoids unresolved-helper hits');
    ok(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}, 'method-chain flat list return payload contributes canonical RETURN action-IR node');
    ok($meta->{language_agnostic_action_ir_ready}, 'method-chain flat list return payload remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_lowers_composable_array_string_method_contracts' => sub {
    plan tests => 11;

    is(
        LinkedSpec::call_spec_handler_subst('Top', 'split(array(parts), scalar(args), /\s*,\s*/)'),
        '@parts = split /\s*,\s*/, $args',
        'split helper lowers into array assignment with regex delimiter'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'trim_each(array(parts))'),
        '@parts = map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } @parts',
        'trim_each helper lowers into map-trim assignment'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'filter_nonempty(array(parts))'),
        '@parts = grep { length($_) } @parts',
        'filter_nonempty helper lowers into grep assignment'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'split(array(parts), scalar(args), /\s*,\s*/); trim_each(array(parts)); filter_nonempty(array(parts))'),
        '@parts = split /\s*,\s*/, $args; @parts = map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } @parts; @parts = grep { length($_) } @parts',
        'composed split/trim/filter helper chain lowers deterministically'
    );

    my $spec_content = <<'SPEC';
Top:: I.declare(array, parts).declare(scalar, args).assign(scalar(args), CAPTURE).split(array(parts), scalar(args), /\s*,\s*/).trim_each(array(parts)).filter_nonempty(array(parts))
 /a/ -> Top { return_a(Top) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for composable array-string method contracts');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'composed array-string method contracts avoid RAW_PERL fallback');
    is($meta->{unresolved_helper_count}, 0, 'composed array-string method contracts avoid unresolved-helper hits');
    ok(grep { $_ eq 'SPLIT' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include SPLIT');
    ok(grep { $_ eq 'TRIM_EACH' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include TRIM_EACH');
    ok(grep { $_ eq 'FILTER_NONEMPTY' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include FILTER_NONEMPTY');
    ok($meta->{language_agnostic_action_ir_ready}, 'composed array-string method contract rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_lowers_additional_composable_array_string_routines' => sub {
    plan tests => 14;

    is(
        LinkedSpec::call_spec_handler_subst('Top', 'lowercase_each(array(parts))'),
        '@parts = map { lc($_) } @parts',
        'lowercase_each helper lowers into map lc assignment'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'uppercase_each(array(parts))'),
        '@parts = map { uc($_) } @parts',
        'uppercase_each helper lowers into map uc assignment'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'uniq(array(parts))'),
        '@parts = do { my %seen; grep { !$seen{$_}++ } @parts }',
        'uniq helper lowers into stable de-dup assignment'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'filter_match(array(parts), /^[A-Z_]+$/)'),
        '@parts = grep { $_ =~ /^[A-Z_]+$/ } @parts',
        'filter_match helper lowers into regex grep assignment'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'filter_match(uniq(uppercase_each(array(parts))), /^[A-Z_]+$/)'),
        '@parts = grep { $_ =~ /^[A-Z_]+$/ } do { my %seen; grep { !$seen{$_}++ } map { uc($_) } @parts }',
        'nested functional composition lowers inner-to-outer over stable target array'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'lowercase_each(Top, array(parts)); filter_match(Top, uniq(uppercase_each(array(parts))), /^[A-Z_]+$/)'),
        '@parts = map { lc($_) } @parts; @parts = grep { $_ =~ /^[A-Z_]+$/ } do { my %seen; grep { !$seen{$_}++ } map { uc($_) } @parts }',
        'mixed style (dot-chain scope form + nested functional composition) lowers deterministically'
    );

    my $spec_content = <<'SPEC';
Top:: I.declare(array, parts).lowercase_each(array(parts)).filter_match(uniq(uppercase_each(array(parts))), /^[A-Z_]+$/)
 /a/ -> Top { return_a(Top) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for mixed dot-chained and nested functional-composition routines');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'dot-chained lowercase/uppercase/uniq/filter_match routines avoid RAW_PERL fallback');
    is($meta->{unresolved_helper_count}, 0, 'dot-chained lowercase/uppercase/uniq/filter_match routines avoid unresolved-helper hits');
    ok(grep { $_ eq 'MAP_LOWERCASE' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include MAP_LOWERCASE');
    ok(grep { $_ eq 'MAP_UPPERCASE' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include MAP_UPPERCASE');
    ok(grep { $_ eq 'UNIQ' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include UNIQ');
    ok(grep { $_ eq 'FILTER_MATCH' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include FILTER_MATCH');
    ok($meta->{language_agnostic_action_ir_ready}, 'dot-chained lowercase/uppercase/uniq/filter_match rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_lowers_fluent_if_else_and_branch_statements' => sub {
    plan tests => 12;

    is(
        LinkedSpec::call_spec_handler_subst('Top', 'if(scalar(on)); push(pipe_operator, rule); elseif(scalar(alt_on)); print("warn"); else(); say("Error: no context"); return_undef(); endif()'),
        'if ($on) {; push @rule, &{$$descr{spec}{pipe_operator}{handler}}($descr, $STRING, $minfo); } elsif ($alt_on) {; print "warn"; } else {; say "Error: no context"; return undef; }',
        'if/elseif/else/endif fluent chain lowers to structured Perl control-flow with branch statements'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'i(scalar(on)); push(pipe_operator, rule); elif(scalar(alt_on)); say("warn"); endif()'),
        'if ($on) {; push @rule, &{$$descr{spec}{pipe_operator}{handler}}($descr, $STRING, $minfo); } elsif ($alt_on) {; say "warn"; }',
        'i/elif aliases lower to canonical if/elsif flow'
    );
    my $lisp_if = LinkedSpec::call_spec_handler_subst(
        'Top',
        'if(or(scalar(on), and(not(scalar(off)), is_empty(scalar(name))))); say("ok"); endif()'
    );
    like(
        $lisp_if,
        qr/\$on.*\|\|.*\$off.*&&.*!defined\(\$name\).*say \"ok\"/s,
        'if(...) condition supports nested Lisp-style boolean expressions (or/and/not/is_empty)'
    );
    like(
        $lisp_if,
        qr/\$name eq ''/s,
        'is_empty(scalar(...)) lowers to scalar emptiness check in fluent conditions'
    );
    my $indexed_scalar_if = LinkedSpec::call_spec_handler_subst(
        'Top',
        'if(eq(scalar(foo_arr, idx), scalar(foo_hash, key))); say("shape"); endif()'
    );
    like(
        $indexed_scalar_if,
        qr/\$foo_arr\[\$idx\]\s+eq\s+\$foo_hash\{\$key\}/s,
        'scalar(array_symbol, index_symbol) and scalar(hash_symbol, key_symbol) lower into array/hash entry access'
    );
    like(
        $indexed_scalar_if,
        qr/say \"shape\"/s,
        'array/hash entry accessor expressions compose inside fluent if() branch conditions'
    );

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top .if(scalar(on)).push(pipe_operator, rule).elseif(scalar(alt_on)).print("warn").else().say("Error: no context").return_undef().endif()

pipe_operator:
 /a/ -> pipe_operator { return_a(pipe_operator) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for fluent if/elseif/else/endif chain');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'fluent if/elseif/else/endif chain avoids RAW_PERL fallback');
    is($meta->{unresolved_helper_count}, 0, 'fluent if/elseif/else/endif chain avoids unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'IF' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ELIF' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ELSE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ENDIF' } @{$meta->{canonical_action_ir_nodes}}),
        'canonical action-IR nodes include IF/ELIF/ELSE/ENDIF control-flow markers'
    );
    ok(
        scalar(grep { $_ eq 'PUSH' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PRINT' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'SAY' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}),
        'canonical action-IR nodes include PUSH/PRINT/SAY/RETURN branch statements'
    );
    ok($meta->{language_agnostic_action_ir_ready}, 'fluent if/elseif/else/endif rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_lowers_fluent_switch_case_default_with_optional_endcase' => sub {
    plan tests => 18;

    my $rewritten = LinkedSpec::call_spec_handler_subst(
        'Top',
        'switch(scalar(op)); case("|"); push(pipe_operator, rule); case("&"); push(pipe_operator, rule2); default(); say("Error"); return_undef(); endswitch()'
    );
    like(
        $rewritten,
        qr/do \{ my \$__ls_switch_value_1 = \$op; my \$__ls_switch_hit_1 = 0/s,
        'switch(...) lowers into scoped switch-state prologue'
    );
    like(
        $rewritten,
        qr/if \(!\$__ls_switch_hit_1 && \$__ls_switch_value_1 eq \"\\|\"\) \{ \$__ls_switch_hit_1 = 1/s,
        'first case(...) lowers with guarded equality match'
    );
    like(
        $rewritten,
        qr/\}\s*if \(!\$__ls_switch_hit_1 && \$__ls_switch_value_1 eq \"&\"\) \{ \$__ls_switch_hit_1 = 1/s,
        'next case(...) implicitly closes previous case body when endcase() is omitted'
    );
    like(
        $rewritten,
        qr/\}\s*if \(!\$__ls_switch_hit_1\) \{ \$__ls_switch_hit_1 = 1/s,
        'default() implicitly closes prior case body when endcase() is omitted'
    );
    like(
        $rewritten,
        qr/return undef;\s*\}\s*\}/s,
        'endswitch() closes final case and switch scope'
    );
    my $lisp_switch = LinkedSpec::call_spec_handler_subst(
        'Top',
        'switch(or(scalar(op_ready), and(not(scalar(op_blocked)), is_empty(scalar(op_alt))))); case("|"); say("hit"); endswitch()'
    );
    like(
        $lisp_switch,
        qr/my \$__ls_switch_value_1 = .*\$op_ready.*\|\|.*\$op_blocked.*&&.*!defined\(\$op_alt\)/s,
        'switch(...) condition supports nested Lisp-style boolean expressions through unified lowering'
    );
    my $composite_switch = LinkedSpec::call_spec_handler_subst(
        'Top',
        'switch(scalar(op), case("|", push(pipe_operator, rule)), case("&", say("amp")), default(say("Error"), return_undef()))'
    );
    like(
        $composite_switch,
        qr/if \(!\$__ls_switch_hit_1 && \$__ls_switch_value_1 eq \"\|\"\) \{ \$__ls_switch_hit_1 = 1; push \@rule, &\{\$\$descr\{spec\}\{pipe_operator\}\{handler\}\}\(\$descr, \$STRING, \$minfo\) \}/s,
        'inline switch(..., case(...), ...) composite form lowers case branch actions without separate case()/endswitch() markers'
    );
    like(
        $composite_switch,
        qr/if \(!\$__ls_switch_hit_1\) \{ \$__ls_switch_hit_1 = 1; say \"Error\"; return undef \}/s,
        'inline switch(..., default(...)) composite form lowers default branch actions directly inside switch arguments'
    );

    my $composite_spec_content = <<'SPEC';
Top::&
 /a/ -> Top .switch(scalar(op), case("|", push(pipe_operator, rule)), default(return_undef()))

pipe_operator:
 /a/ -> pipe_operator { return_a(pipe_operator) }
SPEC
    my $composite_descr = LinkedSpec::Get(\$composite_spec_content, return_descr => 1);
    ok(defined($composite_descr) && ref($composite_descr) eq 'HASH', 'descriptor build succeeds for inline composite switch(case/default) method form');

    my $composite_meta = $composite_descr->{spec}{Top}{meta}{action_rewriter};
    is($composite_meta->{canonical_action_ir_fallback_count}, 0, 'inline composite switch(case/default) form avoids RAW_PERL fallback');
    is($composite_meta->{unresolved_helper_count}, 0, 'inline composite switch(case/default) form avoids unresolved-helper hits');
    ok($composite_meta->{language_agnostic_action_ir_ready}, 'inline composite switch(case/default) rule remains language-agnostic action-IR ready');

    my $explicit = LinkedSpec::call_spec_handler_subst(
        'Top',
        'switch(scalar(op)); case("|"); say("x"); endcase(); default(); say("d"); endcase(); endswitch()'
    );
    like(
        $explicit,
        qr/say \"x\";\s*\}\s*;\s*if \(!\$__ls_switch_hit_1\) \{ \$__ls_switch_hit_1 = 1/s,
        'explicit endcase() is accepted while remaining optional'
    );

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top .switch(scalar(op)).case("|").push(pipe_operator, rule).case("&").push(pipe_operator, rule2).default().say("Error").return_undef().endswitch()

pipe_operator:
 /a/ -> pipe_operator { return_a(pipe_operator) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for fluent switch/case/default/endswitch chain');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'fluent switch/case/default/endswitch chain avoids RAW_PERL fallback');
    is($meta->{unresolved_helper_count}, 0, 'fluent switch/case/default/endswitch chain avoids unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'SWITCH' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'CASE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'DEFAULT' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ENDSWITCH' } @{$meta->{canonical_action_ir_nodes}}),
        'canonical action-IR nodes include SWITCH/CASE/DEFAULT/ENDSWITCH control-flow markers'
    );
    ok($meta->{language_agnostic_action_ir_ready}, 'fluent switch/case/default/endswitch rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_showcase_pipe_operator_if_else_method_chain' => sub {
    plan tests => 7;

    is(
        LinkedSpec::call_spec_handler_subst(
            'Top',
            q{if(scalar(on)); push(pipe_operator, rule); else(); say("Error: '|' operator occurrence with no container rule context"); return_undef(); endif()}
        ),
        q{if ($on) {; push @rule, &{$$descr{spec}{pipe_operator}{handler}}($descr, $STRING, $minfo); } else {; say "Error: '|' operator occurrence with no container rule context"; return undef; }},
        'pipe_operator fluent if/else chain lowers to expected branch semantics without raw block code'
    );

    my $spec_content = <<'SPEC';
Top::&
 /\|/ -> Top .if(scalar(on)).push(pipe_operator, rule).else().say("Error: '|' operator occurrence with no container rule context").return_undef().endif()

pipe_operator:
 /\|/ -> pipe_operator { return_a(pipe_operator) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for pipe_operator fluent if/else chain');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'pipe_operator fluent if/else chain avoids RAW_PERL fallback');
    is($meta->{raw_perl_dependency_count}, 0, 'pipe_operator fluent if/else chain avoids raw-Perl dependency');
    is($meta->{unresolved_helper_count}, 0, 'pipe_operator fluent if/else chain avoids unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'IF' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ELSE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ENDIF' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PUSH' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'SAY' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}),
        'canonical action-IR nodes include IF/ELSE/ENDIF and PUSH/SAY/RETURN for pipe_operator showcase'
    );
    ok($meta->{language_agnostic_action_ir_ready}, 'pipe_operator fluent if/else showcase remains language-agnostic action-IR ready');
};
subtest 'method_like_action_chain_parses_into_multiple_helper_events' => sub {
    plan tests => 6;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top .return_a().return_m()
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for chained method-like action block');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'chained method-like action block avoids RAW_PERL fallback');
    is($meta->{unresolved_helper_count}, 0, 'chained method-like action block avoids unresolved-helper hits');
    ok(grep { $_ eq 'RETURN_A' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include RETURN_A from chained action methods');
    ok(grep { $_ eq 'RETURN_M' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include RETURN_M from chained action methods');
    ok($meta->{language_agnostic_action_ir_ready}, 'chained method-like action block remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_ir_lowering_preserves_helper_and_raw_behavior' => sub {
    plan tests => 3;

    my $label = 'Top';
    like(
        LinkedSpec::call_spec_handler_subst($label, 'call(Leaf); my $tmp = 1; CAPTURE_IF()'),
        qr/^&\{\$\$descr\{spec\}\{Leaf\}\{handler\}\}\(\$descr, \$STRING, \$minfo\); my \$tmp = 1; .*push \@Top, \$capt if \$capt$/s,
        'canonical-IR lowering rewrites helpers while preserving RAW_PERL statements'
    );
    is(
        LinkedSpec::call_spec_handler_subst($label, 'call (Leaf); my $tmp = 1'),
        '&{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo); my $tmp = 1',
        'canonical-IR lowering accepts optional helper whitespace and preserves RAW_PERL statement'
    );
    is(
        LinkedSpec::call_spec_handler_subst($label, 'push(Leaf,Top); return_a(Top, $x)'),
        q{push @Top, &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo); return ['?Top:', ( $x), \@Top]},
        'canonical-IR lowering preserves push/return helper output semantics'
    );
};
subtest 'action_rewriter_reports_unresolved_helpers_in_rule_meta' => sub {
    plan tests => 8;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call (Leaf); CAPTURE_IF (); return_a(Leaf); return(Leaf, $x) }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for unresolved-helper diagnostics check');
    ok(exists $descr->{spec}{Top}{meta}{action_rewriter}, 'Top rule exposes action_rewriter metadata');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{unresolved_helper_count}, 2, 'Top unresolved helper count captures unrewritten helper forms');
    ok(grep { $_ eq 'return_a' } @{$meta->{unresolved_helpers}}, 'Top unresolved helpers include return_a label-mismatch form');
    ok(grep { $_ eq 'return' } @{$meta->{unresolved_helpers}}, 'Top unresolved helpers include return label-mismatch form');
    is($meta->{unresolved_helper_hits}{return_a}, 1, 'Top return_a unresolved helper hit count is tracked');
    is($meta->{unresolved_helper_hits}{return}, 1, 'Top return unresolved helper hit count is tracked');
    is($descr->{spec}{Leaf}{meta}{action_rewriter}{unresolved_helper_count}, 0, 'Leaf rule has no unresolved helpers');
};
subtest 'action_rewriter_meta_exposes_lowering_contract_ids' => sub {
    plan tests => 6;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { return_a(Top) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for contract-id metadata check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    ok(ref($meta->{rewrite_contract_ids}) eq 'ARRAY', 'action rewriter metadata exposes rewrite_contract_ids array');
    ok(@{$meta->{rewrite_contract_ids}} > 0, 'rewrite_contract_ids is non-empty');
    is($meta->{rewrite_contract_ids}[0], 'call', 'rewrite_contract_ids preserves stable ordering (first: call)');
    ok(grep { $_ eq 'return_a' } @{$meta->{rewrite_contract_ids}}, 'rewrite_contract_ids includes return_a contract');
    ok(grep { $_ eq 'capture_if_macro' } @{$meta->{rewrite_contract_ids}}, 'rewrite_contract_ids includes CAPTURE_IF macro contract');
};
subtest 'action_rewriter_meta_exposes_helper_action_ir_nodes' => sub {
    plan tests => 8;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call(Leaf); capture_if(Top); return_a(Top) }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for helper action-IR metadata check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{helper_action_ir_count}, 3, 'helper action-IR count captures helper invocations before lowering');
    ok(grep { $_ eq 'CALL' } @{$meta->{helper_action_ir_nodes}}, 'helper action-IR nodes include CALL');
    ok(grep { $_ eq 'CAPTURE_IF' } @{$meta->{helper_action_ir_nodes}}, 'helper action-IR nodes include CAPTURE_IF');
    ok(grep { $_ eq 'RETURN_A' } @{$meta->{helper_action_ir_nodes}}, 'helper action-IR nodes include RETURN_A');
    is($meta->{helper_action_ir_hits}{CALL}, 1, 'helper action-IR CALL hit count is tracked');
    is($meta->{helper_action_ir_hits}{CAPTURE_IF}, 1, 'helper action-IR CAPTURE_IF hit count is tracked');
    is($meta->{helper_action_ir_hits}{RETURN_A}, 1, 'helper action-IR RETURN_A hit count is tracked');
};
subtest 'action_rewriter_meta_exposes_helper_action_ir_payload_events' => sub {
    plan tests => 8;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call(Leaf); push(Leaf,Top); return_a(Top, $x + 1) }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for helper action-IR payload event metadata check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    ok(ref($meta->{helper_action_ir_events}) eq 'ARRAY', 'helper action-IR metadata exposes payload events array');
    is(scalar @{$meta->{helper_action_ir_events}}, 3, 'helper action-IR payload event count matches helper invocations');

    my ($call_evt)   = grep { $_->{contract_id} eq 'call' } @{$meta->{helper_action_ir_events}};
    my ($push_evt)   = grep { $_->{contract_id} eq 'push_target_arg' } @{$meta->{helper_action_ir_events}};
    my ($return_evt) = grep { $_->{contract_id} eq 'return_a' } @{$meta->{helper_action_ir_events}};

    is($call_evt->{args}{callee}, 'Leaf', 'CALL payload event captures callee argument');
    is($push_evt->{args}{source}, 'Leaf', 'PUSH payload event captures source rule argument');
    is($push_evt->{args}{target}, 'Top', 'PUSH payload event captures target list argument');
    like($return_evt->{args}{arg}, qr/\$x \+ 1/, 'RETURN_A payload event captures expression argument payload');
    is($return_evt->{args}{label}, 'Top', 'RETURN_A payload event captures label argument');
};
subtest 'action_rewriter_meta_exposes_canonical_action_ir_with_raw_fallback' => sub {
    plan tests => 11;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call(Leaf); my $tmp = 1; push(Leaf,Top); return_a(Top, $x + 1) }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for canonical action-IR metadata check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_count}, 4, 'canonical action-IR count includes helper and fallback statements');
    is($meta->{canonical_action_ir_fallback_count}, 1, 'canonical action-IR fallback count captures non-helper statement');
    ok(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include CALL');
    ok(grep { $_ eq 'PUSH' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include PUSH');
    ok(grep { $_ eq 'RETURN_A' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include RETURN_A');
    ok(grep { $_ eq 'RAW_PERL' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include RAW_PERL fallback marker');

    my ($call_evt) = grep { $_->{kind} eq 'CALL' } @{$meta->{canonical_action_ir_events}};
    my ($push_evt) = grep { $_->{kind} eq 'PUSH' } @{$meta->{canonical_action_ir_events}};
    my ($raw_evt)  = grep { $_->{kind} eq 'RAW_PERL' } @{$meta->{canonical_action_ir_events}};
    my ($ret_evt)  = grep { $_->{kind} eq 'RETURN_A' } @{$meta->{canonical_action_ir_events}};

    is($call_evt->{args}{callee}, 'Leaf', 'canonical CALL event captures callee');
    is($push_evt->{args}{target}, 'Top', 'canonical PUSH event captures explicit target');
    is($raw_evt->{args}{code}, 'my $tmp = 1', 'canonical RAW_PERL fallback event captures non-helper statement');
    like($ret_evt->{args}{arg}, qr/\$x \+ 1/, 'canonical RETURN_A event captures expression payload');
};
subtest 'action_rewriter_meta_exposes_language_agnostic_readiness' => sub {
    plan tests => 10;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call(Leaf); return_a(Top) }

Mixed::&
 /b/ -> Mixed { call(Leaf); my $tmp = 1 }

Unresolved::&
 /c/ -> Unresolved { return_a(Leaf) }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
 /b/ -> Leaf { return_a(Leaf) }
 /c/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for language-agnostic readiness metadata check');

    my $top_meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($top_meta->{raw_perl_dependency_count}, 0, 'helper-only rule reports zero raw-Perl dependency count');
    is_deeply($top_meta->{raw_perl_dependency_statements}, [], 'helper-only rule reports empty raw-Perl dependency statement list');
    ok($top_meta->{language_agnostic_action_ir_ready}, 'helper-only rule reports language-agnostic action-IR readiness');

    my $mixed_meta = $descr->{spec}{Mixed}{meta}{action_rewriter};
    is($mixed_meta->{raw_perl_dependency_count}, 1, 'mixed rule reports raw-Perl fallback dependency count');
    is_deeply($mixed_meta->{raw_perl_dependency_statements}, ['my $tmp = 1'], 'mixed rule reports canonical raw-Perl dependency statement payload');
    ok(!$mixed_meta->{language_agnostic_action_ir_ready}, 'mixed rule with raw-Perl fallback is not language-agnostic action-IR ready');

    my $unresolved_meta = $descr->{spec}{Unresolved}{meta}{action_rewriter};
    is($unresolved_meta->{unresolved_helper_count}, 1, 'unresolved helper rule reports unresolved helper count');
    is($unresolved_meta->{raw_perl_dependency_count}, 0, 'unresolved helper rule can still report zero raw-Perl fallback dependency count');
    ok(!$unresolved_meta->{language_agnostic_action_ir_ready}, 'unresolved helper rule is not language-agnostic action-IR ready');
};
subtest 'action_rewriter_meta_exposes_language_agnostic_blocker_statements' => sub {
    plan tests => 9;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call(Leaf); return_a(Top) }

Combo::&
 /b/ -> Combo { return_a(Leaf); my $tmp = 1 }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
 /b/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for language-agnostic blocker statement metadata check');

    my $top_meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is_deeply($top_meta->{language_agnostic_action_ir_blocker_statements}, [], 'helper-only rule exposes no language-agnostic blocker statements');
    is($top_meta->{language_agnostic_action_ir_blocker_statement_count}, 0, 'helper-only rule exposes zero language-agnostic blocker statements');

    my $combo_meta = $descr->{spec}{Combo}{meta}{action_rewriter};
    is($combo_meta->{unresolved_helper_count}, 1, 'combo rule tracks unresolved helper count');
    is_deeply($combo_meta->{unresolved_helper_statements}, ['return_a(Leaf)'], 'combo rule exposes unresolved helper statement payloads');
    is_deeply($combo_meta->{raw_perl_dependency_statements}, ['my $tmp = 1'], 'combo rule exposes raw-Perl fallback dependency statements');
    is_deeply($combo_meta->{language_agnostic_action_ir_blocker_statements}, ['my $tmp = 1', 'return_a(Leaf)'], 'combo rule exposes combined language-agnostic blocker statements');
    is($combo_meta->{language_agnostic_action_ir_blocker_statement_count}, 2, 'combo rule exposes combined blocker statement count');
    ok(!$combo_meta->{language_agnostic_action_ir_ready}, 'combo rule with unresolved helper and raw fallback is not language-agnostic action-IR ready');
};
subtest 'return_descr_exposes_action_rewriter_migration_summary' => sub {
    plan tests => 15;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call(Leaf); return_a(Top) }

Mixed::&
 /b/ -> Mixed { call(Leaf); my $tmp = 1 }

Unresolved::&
 /c/ -> Unresolved { return_a(Leaf) }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
 /b/ -> Leaf { return_a(Leaf) }
 /c/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for action_rewriter migration summary check');
    ok(ref($descr->{meta}) eq 'HASH', 'descriptor exposes top-level meta hash');
    ok(ref($descr->{meta}{action_rewriter_migration}) eq 'HASH', 'descriptor exposes action_rewriter migration summary');

    my $summary = $descr->{meta}{action_rewriter_migration};
    is($summary->{total_rules}, 4, 'migration summary tracks total rule count');
    is($summary->{rules_with_action_rewriter_meta}, 4, 'migration summary tracks rules with action_rewriter metadata');
    is($summary->{language_agnostic_ready_rule_count}, 2, 'migration summary tracks ready rule count');
    is($summary->{language_agnostic_blocked_rule_count}, 2, 'migration summary tracks blocked rule count');
    is($summary->{language_agnostic_blocker_statement_total_count}, 2, 'migration summary tracks total blocker statement count across blocked rules');
    is_deeply($summary->{language_agnostic_ready_rules}, ['Leaf', 'Top'], 'migration summary exposes deterministic ready-rule list');

    my ($mixed_row) = grep { $_->{rule} eq 'Mixed' } @{$summary->{language_agnostic_blocked_rules}};
    my ($unresolved_row) = grep { $_->{rule} eq 'Unresolved' } @{$summary->{language_agnostic_blocked_rules}};
    is_deeply($mixed_row->{blocker_statements}, ['my $tmp = 1'], 'migration summary blocked entry preserves RAW_PERL blocker payload');
    is_deeply($unresolved_row->{blocker_statements}, ['return_a(Leaf)'], 'migration summary blocked entry preserves unresolved-helper blocker payload');
    is(scalar(@{$summary->{language_agnostic_blocked_rules_by_priority}}), 2, 'migration summary exposes prioritized blocked-rule list');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, ['Unresolved', 'Mixed'], 'migration summary sorts blocked rules by deterministic blocker priority');
    is($summary->{language_agnostic_top_blocked_rule}, 'Unresolved', 'migration summary exposes top blocked rule');
    is($summary->{language_agnostic_ready_ratio}, '0.5000', 'migration summary exposes language-agnostic ready ratio');
};
subtest 'return_descr_exposes_action_rewriter_migration_blocker_type_breakdown' => sub {
    plan tests => 13;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call(Leaf); return_a(Top) }

RawOnly::&
 /b/ -> RawOnly { call(Leaf); my $tmp = 1 }

UnresolvedOnly::&
 /c/ -> UnresolvedOnly { return_a(Leaf) }

Mixed::&
 /d/ -> Mixed { return_a(Leaf); my $tmp = 2 }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
 /b/ -> Leaf { return_a(Leaf) }
 /c/ -> Leaf { return_a(Leaf) }
 /d/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for migration blocker-type breakdown check');
    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'descriptor exposes migration summary for blocker-type breakdown check');

    is($summary->{language_agnostic_blocked_rule_count}, 3, 'migration summary tracks blocked-rule count for blocker-type breakdown corpus');
    is($summary->{language_agnostic_blocked_raw_perl_only_rule_count}, 1, 'migration summary tracks raw-Perl-only blocked-rule count');
    is($summary->{language_agnostic_blocked_unresolved_helper_only_rule_count}, 1, 'migration summary tracks unresolved-helper-only blocked-rule count');
    is($summary->{language_agnostic_blocked_mixed_rule_count}, 1, 'migration summary tracks mixed blocked-rule count');
    is($summary->{language_agnostic_blocked_raw_perl_only_ratio}, '0.3333', 'migration summary tracks raw-Perl-only blocked-rule ratio');
    is($summary->{language_agnostic_blocked_unresolved_helper_only_ratio}, '0.3333', 'migration summary tracks unresolved-helper-only blocked-rule ratio');
    is($summary->{language_agnostic_blocked_mixed_ratio}, '0.3333', 'migration summary tracks mixed blocked-rule ratio');
    is_deeply($summary->{language_agnostic_blocked_raw_perl_only_rules}, ['RawOnly'], 'migration summary exposes deterministic raw-Perl-only blocked-rule list');
    is_deeply($summary->{language_agnostic_blocked_unresolved_helper_only_rules}, ['UnresolvedOnly'], 'migration summary exposes deterministic unresolved-helper-only blocked-rule list');
    is_deeply($summary->{language_agnostic_blocked_mixed_rules}, ['Mixed'], 'migration summary exposes deterministic mixed blocked-rule list');
    is($summary->{language_agnostic_top_blocked_rule}, 'Mixed', 'migration summary priority still surfaces mixed rule with highest blocker load');
};
subtest 'action_rewriter_canonical_action_ir_lowers_call_wrappers_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { my $retv = call(Leaf); $retv = call(Leaf); push @Top, call(Leaf) }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for call-wrapper canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes supported call-wrapper statements');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes supported call-wrapper statements');
    is($meta->{unresolved_helper_count}, 0, 'call-wrapper lowering keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include CALL for call-wrapper coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'my $retv = call(Leaf); $retv = call(Leaf); push @Top, call(Leaf)');
    is($rewritten, 'my $retv = &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo); $retv = &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo); push @Top, &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo)', 'call-wrapper lowering rewrites assignment and builtin push call wrappers to handler calls');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'call-wrapper-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_lowers_push_call_indexed_wrapper_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { push @Top, call(Leaf)->[1] }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for indexed push-call wrapper canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes indexed push-call wrapper statements');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes indexed push-call wrapper statements');
    is($meta->{unresolved_helper_count}, 0, 'indexed push-call wrapper lowering keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include CALL for indexed push-call wrapper coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'push @Top, call(Leaf)->[1]');
    is($rewritten, 'push @Top, &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo)->[1]', 'indexed push-call wrapper lowering rewrites to handler call with preserved index access');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'indexed push-call-wrapper-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_lowers_return_call_wrapper_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { return call(Leaf) }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for return-call wrapper canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes return-call wrapper statements');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes return-call wrapper statements');
    is($meta->{unresolved_helper_count}, 0, 'return-call wrapper lowering keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include CALL for return-call wrapper coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'return call(Leaf)');
    is($rewritten, 'return &{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo)', 'return-call wrapper lowering rewrites to direct handler return call');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'return-call-wrapper-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_classifies_bare_return_statements_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { return 1; return }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for bare-return canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes bare return statements');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes bare return statements');
    is($meta->{unresolved_helper_count}, 0, 'bare-return classification keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include RETURN for bare return statement coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'return 1; return');
    is($rewritten, 'return 1; return', 'bare return statements are preserved while avoiding RAW_PERL fallback');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'bare-return-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_classifies_bare_exit_statements_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { exit; exit 1; exit(2) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for bare-exit canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes bare exit statements');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes bare exit statements');
    is($meta->{unresolved_helper_count}, 0, 'bare-exit classification keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'EXIT' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include EXIT for bare exit statement coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'exit; exit 1; exit(2)');
    is($rewritten, 'exit; exit 1; exit(2)', 'bare exit statements are preserved while avoiding RAW_PERL fallback');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'bare-exit-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_classifies_prefix_newline_linecount_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { my @startline = substr($$STRING, 0, $IPOS) =~ /\n/g }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for prefix-newline line-count canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes prefix-newline line-count statement');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes prefix-newline line-count statement');
    is($meta->{unresolved_helper_count}, 0, 'prefix-newline line-count classification keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'LINE_COUNT' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include LINE_COUNT for prefix-newline line-count coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'my @startline = substr($$STRING, 0, $IPOS) =~ /\n/g');
    is($rewritten, 'my @startline = substr($$STRING, 0, $IPOS) =~ /\n/g', 'prefix-newline line-count statement is preserved while avoiding RAW_PERL fallback');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'prefix-newline-linecount-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_classifies_capture_substr_print_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { print "<".substr($$STRING, $IPOS, $LSPOS - $IPOS -1).">\n" }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for capture-substr-print canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes capture-substr print statement');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes capture-substr print statement');
    is($meta->{unresolved_helper_count}, 0, 'capture-substr print classification keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'PRINT' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include PRINT for capture-substr print coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'print "<".substr($$STRING, $IPOS, $LSPOS - $IPOS -1).">\n"');
    is($rewritten, 'print "<".substr($$STRING, $IPOS, $LSPOS - $IPOS -1).">\n"', 'capture-substr print statement is preserved while avoiding RAW_PERL fallback');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'capture-substr-print-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_classifies_bare_my_declarations_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { my $retv; my @matches }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for bare-my-declaration canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes bare lexical my declarations');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes bare lexical my declarations');
    is($meta->{unresolved_helper_count}, 0, 'bare lexical my declaration classification keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'DECLARE' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include DECLARE for bare lexical my declaration coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'my $retv; my @matches');
    is($rewritten, 'my $retv; my @matches', 'bare lexical my declarations are preserved while avoiding RAW_PERL fallback');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'bare-my-declaration-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_classifies_position_tracking_cluster_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { my @matches; my $last_pos=$IPOS; $last_pos = pos($$STRING); $IPOS = pos $$STRING; my $shift = $LSPOS - $last_pos - length($LMATCH); push @matches, substr($$STRING, $last_pos, $shift) if $shift }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for position-tracking cluster canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes supported position-tracking cluster statements');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes supported position-tracking cluster statements');
    is($meta->{unresolved_helper_count}, 0, 'position-tracking cluster classification keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'POSITION_TRACK' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include POSITION_TRACK for cluster coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'my @matches; my $last_pos=$IPOS; $last_pos = pos($$STRING); $IPOS = pos $$STRING; my $shift = $LSPOS - $last_pos - length($LMATCH); push @matches, substr($$STRING, $last_pos, $shift) if $shift');
    is($rewritten, 'my @matches; my $last_pos=$IPOS; $last_pos = pos($$STRING); $IPOS = pos $$STRING; my $shift = $LSPOS - $last_pos - length($LMATCH); push @matches, substr($$STRING, $last_pos, $shift) if $shift', 'position-tracking cluster statements are preserved while avoiding RAW_PERL fallback');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'position-tracking-cluster-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_classifies_inline_regex_subst_assignment_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { $args =~ s/\s*\)\s*$// }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for inline-regex-subst assignment canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes inline regex-subst assignment statement');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes inline regex-subst assignment statement');
    is($meta->{unresolved_helper_count}, 0, 'inline regex-subst assignment classification keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'REGEX_SUBST' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include REGEX_SUBST for inline assignment coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', '$args =~ s/\s*\)\s*$//');
    is($rewritten, '$args =~ s/\s*\)\s*$//', 'inline regex-subst assignment statement is preserved while avoiding RAW_PERL fallback');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'inline-regex-subst-assignment-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_classifies_lexical_match_assignment_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { my $args = $IMATCH }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for lexical match-assignment canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes lexical match-assignment statement');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes lexical match-assignment statement');
    is($meta->{unresolved_helper_count}, 0, 'lexical match-assignment classification keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include ASSIGN for lexical match-assignment coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'my $args = $IMATCH');
    is($rewritten, 'my $args = $IMATCH', 'lexical match-assignment statement is preserved while avoiding RAW_PERL fallback');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'lexical-match-assignment-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_classifies_imatch_list_destructure_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { my ($attribute_name, $value) = @IMATCH_LIST }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for IMATCH_LIST destructure canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes IMATCH_LIST destructure statement');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes IMATCH_LIST destructure statement');
    is($meta->{unresolved_helper_count}, 0, 'IMATCH_LIST destructure classification keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include ASSIGN for IMATCH_LIST destructure coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'my ($attribute_name, $value) = @IMATCH_LIST');
    is($rewritten, 'my ($attribute_name, $value) = @IMATCH_LIST', 'IMATCH_LIST destructure statement is preserved while avoiding RAW_PERL fallback');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'IMATCH_LIST-destructure-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_classifies_print_foreach_iterable_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { print "perl_dquotes:<<$_>>\n" foreach (@matches) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for print-foreach canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes print-foreach statement');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes print-foreach statement');
    is($meta->{unresolved_helper_count}, 0, 'print-foreach classification keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'PRINT' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include PRINT for print-foreach coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'print "perl_dquotes:<<$_>>\n" foreach (@matches)');
    is($rewritten, 'print "perl_dquotes:<<$_>>\n" foreach (@matches)', 'print-foreach statement is preserved while avoiding RAW_PERL fallback');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'print-foreach-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_classifies_split_trim_filter_assignment_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { my @parts = grep { length($_) } map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } split /\s*,\s*/, $args }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for split-trim-filter assignment canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes split-trim-filter assignment statement');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes split-trim-filter assignment statement');
    is($meta->{unresolved_helper_count}, 0, 'split-trim-filter assignment classification keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include ASSIGN for split-trim-filter assignment coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'my @parts = grep { length($_) } map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } split /\s*,\s*/, $args');
    is($rewritten, 'my @parts = grep { length($_) } map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } split /\s*,\s*/, $args', 'split-trim-filter assignment statement is preserved while avoiding RAW_PERL fallback');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'split-trim-filter-assignment-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_classifies_next_statement_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { next }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for next-statement canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes next statement');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes next statement');
    is($meta->{unresolved_helper_count}, 0, 'next-statement classification keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'NEXT' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include NEXT for next-statement coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'next');
    is($rewritten, 'next', 'next statement is preserved while avoiding RAW_PERL fallback');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'next-statement-only rule remains language-agnostic action-IR ready');
};
subtest 'action_rewriter_canonical_action_ir_classifies_ref_field_assignment_without_raw_fallback' => sub {
    plan tests => 7;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { $prev_node_type = $retv->{type} }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for ref-field-assignment canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes ref-field assignment statement');
    is($meta->{raw_perl_dependency_count}, 0, 'raw-perl dependency count excludes ref-field assignment statement');
    is($meta->{unresolved_helper_count}, 0, 'ref-field assignment classification keeps unresolved-helper count at zero');
    ok(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include ASSIGN for ref-field assignment coverage');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', '$prev_node_type = $retv->{type}');
    is($rewritten, '$prev_node_type = $retv->{type}', 'ref-field assignment statement is preserved while avoiding RAW_PERL fallback');
    is($meta->{language_agnostic_action_ir_ready}, 1, 'ref-field-assignment-only rule remains language-agnostic action-IR ready');
};
subtest 'method_empty_action_return_with_leading_space_args_stays_balanced' => sub {
    plan tests => 6;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top .return ((map {lc} @IMATCH_LIST), \@Top, call(Leaf))

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for method-style return with leading-space args');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'method-style return with leading-space args avoids RAW_PERL fallback');
    is($meta->{unresolved_helper_count}, 0, 'method-style return with leading-space args avoids unresolved helper hits');
    is($meta->{raw_perl_dependency_count}, 0, 'method-style return with leading-space args reports zero raw-perl dependency');
    ok($meta->{language_agnostic_action_ir_ready}, 'method-style return with leading-space args remains language-agnostic action-IR ready');
    ok(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}, 'method-style return contributes canonical RETURN action-IR node');
};
subtest 'action_rewriter_canonical_action_ir_handles_nested_semicolon_payloads' => sub {
    plan tests => 9;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { return_a(Top, do { my $x = 1; $x }); call(Leaf) }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for nested-semicolon canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical action-IR fallback count excludes semicolons inside helper payloads');
    is($meta->{canonical_action_ir_count}, 2, 'canonical action-IR count remains aligned to helper statement count');
    ok(grep { $_ eq 'RETURN_A' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include RETURN_A for nested payload helper');
    ok(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include CALL for trailing helper');
    is(scalar(grep { $_ eq 'RAW_PERL' } @{$meta->{canonical_action_ir_nodes}}), 0, 'canonical action-IR nodes do not inject RAW_PERL for nested helper payload semicolons');

    my ($ret_evt) = grep { $_->{kind} eq 'RETURN_A' } @{$meta->{canonical_action_ir_events}};
    like($ret_evt->{args}{arg}, qr/do \{ my \$x = 1; \$x \}/, 'canonical RETURN_A payload keeps nested semicolon expression intact');

    my $rewritten = LinkedSpec::call_spec_handler_subst('Top', 'return_a(Top, do { my $x = 1; $x }); call(Leaf)');
    like($rewritten, qr/^return \['\?Top:', \( do \{ my \$x = 1; \$x \}\), /, 'canonical-IR lowering preserves RETURN_A rewrite payload with nested semicolon expression');
    like($rewritten, qr/&\{\$\$descr\{spec\}\{Leaf\}\{handler\}\}\(\$descr, \$STRING, \$minfo\)$/, 'canonical-IR lowering preserves CALL rewrite after nested semicolon payload helper');
};
subtest 'action_rewriter_canonical_action_ir_ignores_line_comment_semicolon_fragmentation' => sub {
    plan tests => 8;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call(Leaf); # keep; comment }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for line-comment semicolon canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 1, 'canonical action-IR fallback count treats semicolon inside line comment as a single fallback statement');
    is($meta->{canonical_action_ir_count}, 2, 'canonical action-IR count remains helper plus one comment fallback statement');
    ok(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include CALL');
    is(scalar(grep { $_ eq 'RAW_PERL' } @{$meta->{canonical_action_ir_nodes}}), 1, 'canonical action-IR nodes include a single RAW_PERL fallback marker');

    my ($raw_evt) = grep { $_->{kind} eq 'RAW_PERL' } @{$meta->{canonical_action_ir_events}};
    is($raw_evt->{args}{code}, '# keep; comment', 'canonical RAW_PERL fallback payload preserves line comment text with semicolon');
    is($meta->{unresolved_helper_count}, 0, 'line-comment semicolon handling keeps helper lowering resolved');
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'call(Leaf); # keep; comment'),
        '&{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo); # keep; comment',
        'canonical-IR lowering output preserves comment while lowering helper call'
    );
};
subtest 'action_rewriter_canonical_action_ir_ignores_backtick_semicolon_fragmentation' => sub {
    plan tests => 8;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call(Leaf); my $cmd = `echo a;b`; }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for backtick-semicolon canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 1, 'canonical action-IR fallback count treats semicolon inside backtick string as one fallback statement');
    is($meta->{canonical_action_ir_count}, 2, 'canonical action-IR count remains helper plus one backtick fallback statement');
    ok(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include CALL');
    is(scalar(grep { $_ eq 'RAW_PERL' } @{$meta->{canonical_action_ir_nodes}}), 1, 'canonical action-IR nodes include a single RAW_PERL fallback marker');

    my ($raw_evt) = grep { $_->{kind} eq 'RAW_PERL' } @{$meta->{canonical_action_ir_events}};
    is($raw_evt->{args}{code}, 'my $cmd = `echo a;b`', 'canonical RAW_PERL fallback payload preserves backtick string with semicolon');
    is($meta->{unresolved_helper_count}, 0, 'backtick semicolon handling keeps helper lowering resolved');
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'call(Leaf); my $cmd = `echo a;b`'),
        '&{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo); my $cmd = `echo a;b`',
        'canonical-IR lowering output preserves backtick string while lowering helper call'
    );
};
subtest 'action_rewriter_canonical_action_ir_ignores_slash_quote_semicolon_fragmentation' => sub {
    plan tests => 8;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call(Leaf); my $re = qr/a;b/; }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for slash-quote semicolon canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 1, 'canonical action-IR fallback count treats semicolon inside slash-quote payload as one fallback statement');
    is($meta->{canonical_action_ir_count}, 2, 'canonical action-IR count remains helper plus one slash-quote fallback statement');
    ok(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include CALL');
    is(scalar(grep { $_ eq 'RAW_PERL' } @{$meta->{canonical_action_ir_nodes}}), 1, 'canonical action-IR nodes include a single RAW_PERL fallback marker');

    my ($raw_evt) = grep { $_->{kind} eq 'RAW_PERL' } @{$meta->{canonical_action_ir_events}};
    is($raw_evt->{args}{code}, 'my $re = qr/a;b/', 'canonical RAW_PERL fallback payload preserves slash-quote semicolon text');
    is($meta->{unresolved_helper_count}, 0, 'slash-quote semicolon handling keeps helper lowering resolved');
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'call(Leaf); my $re = qr/a;b/'),
        '&{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo); my $re = qr/a;b/',
        'canonical-IR lowering output preserves slash-quote payload while lowering helper call'
    );
};
subtest 'action_rewriter_canonical_action_ir_ignores_angle_quote_semicolon_fragmentation' => sub {
    plan tests => 8;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call(Leaf); my $re = qr<a;b>; }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for angle-quote semicolon canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 1, 'canonical action-IR fallback count treats semicolon inside angle-quote payload as one fallback statement');
    is($meta->{canonical_action_ir_count}, 2, 'canonical action-IR count remains helper plus one angle-quote fallback statement');
    ok(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include CALL');
    is(scalar(grep { $_ eq 'RAW_PERL' } @{$meta->{canonical_action_ir_nodes}}), 1, 'canonical action-IR nodes include a single RAW_PERL fallback marker');

    my ($raw_evt) = grep { $_->{kind} eq 'RAW_PERL' } @{$meta->{canonical_action_ir_events}};
    is($raw_evt->{args}{code}, 'my $re = qr<a;b>', 'canonical RAW_PERL fallback payload preserves angle-quote semicolon text');
    is($meta->{unresolved_helper_count}, 0, 'angle-quote semicolon handling keeps helper lowering resolved');
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'call(Leaf); my $re = qr<a;b>'),
        '&{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo); my $re = qr<a;b>',
        'canonical-IR lowering output preserves angle-quote payload while lowering helper call'
    );
};
subtest 'action_rewriter_canonical_action_ir_ignores_pipe_quote_semicolon_fragmentation' => sub {
    plan tests => 8;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call(Leaf); my $re = qr|a;b|; }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for pipe-quote semicolon canonical action-IR check');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 1, 'canonical action-IR fallback count treats semicolon inside pipe-quote payload as one fallback statement');
    is($meta->{canonical_action_ir_count}, 2, 'canonical action-IR count remains helper plus one pipe-quote fallback statement');
    ok(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}, 'canonical action-IR nodes include CALL');
    is(scalar(grep { $_ eq 'RAW_PERL' } @{$meta->{canonical_action_ir_nodes}}), 1, 'canonical action-IR nodes include a single RAW_PERL fallback marker');

    my ($raw_evt) = grep { $_->{kind} eq 'RAW_PERL' } @{$meta->{canonical_action_ir_events}};
    is($raw_evt->{args}{code}, 'my $re = qr|a;b|', 'canonical RAW_PERL fallback payload preserves pipe-quote semicolon text');
    is($meta->{unresolved_helper_count}, 0, 'pipe-quote semicolon handling keeps helper lowering resolved');
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'call(Leaf); my $re = qr|a;b|'),
        '&{$$descr{spec}{Leaf}{handler}}($descr, $STRING, $minfo); my $re = qr|a;b|',
        'canonical-IR lowering output preserves pipe-quote payload while lowering helper call'
    );
};
subtest 'ebnf_grammar_file_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 13;

    my $descr = LinkedSpec::get_parser('ebnf', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for ebnf grammar_file migration check');

    my $meta = $descr->{spec}{grammar_file}{meta}{action_rewriter};
    ok(ref($meta) eq 'HASH', 'ebnf grammar_file exposes action_rewriter metadata');
    is($meta->{raw_perl_dependency_count}, 0, 'ebnf grammar_file no longer reports raw-Perl fallback dependency');
    is_deeply($meta->{raw_perl_dependency_statements}, [], 'ebnf grammar_file exposes no raw-Perl fallback statements');
    is($meta->{unresolved_helper_count}, 0, 'ebnf grammar_file avoids unresolved-helper hits');
    is_deeply($meta->{language_agnostic_action_ir_blocker_statements}, [], 'ebnf grammar_file exposes no language-agnostic blocker statements');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'IF' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PUSH' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}),
        'ebnf grammar_file canonical action-IR nodes include DECLARE/ASSIGN/IF/PUSH/RETURN after helper migration'
    );
    ok(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}, 'ebnf grammar_file canonical action-IR nodes include CALL after grammar_rule binding');
    ok($meta->{language_agnostic_action_ir_ready}, 'ebnf grammar_file is language-agnostic action-IR ready');

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'ebnf descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'ebnf no longer reports blocked rules after grammar_file migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'ebnf exposes no prioritized blocked-rule list after grammar_file migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'ebnf exposes no top blocked rule after grammar_file migration');
};
subtest 'ds_vhistory_vhistory_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 13;

    my $descr = LinkedSpec::get_parser('ds_vhistory', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for ds_vhistory vhistory migration check');

    my $meta = $descr->{spec}{vhistory}{meta}{action_rewriter};
    ok(ref($meta) eq 'HASH', 'ds_vhistory vhistory exposes action_rewriter metadata');
    is($meta->{raw_perl_dependency_count}, 0, 'ds_vhistory vhistory no longer reports raw-Perl fallback dependency');
    is_deeply($meta->{raw_perl_dependency_statements}, [], 'ds_vhistory vhistory exposes no raw-Perl fallback statements');
    is($meta->{unresolved_helper_count}, 0, 'ds_vhistory vhistory avoids unresolved-helper hits');
    is_deeply($meta->{language_agnostic_action_ir_blocker_statements}, [], 'ds_vhistory vhistory exposes no language-agnostic blocker statements');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'IF' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ELSE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ENDIF' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PUSH' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}),
        'ds_vhistory vhistory canonical action-IR nodes include DECLARE/ASSIGN/IF/ELSE/ENDIF/PUSH/RETURN after helper migration'
    );
    ok(
        scalar(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PRINT' } @{$meta->{canonical_action_ir_nodes}}),
        'ds_vhistory vhistory canonical action-IR nodes include CALL and PRINT after helper migration'
    );
    ok($meta->{language_agnostic_action_ir_ready}, 'ds_vhistory vhistory is language-agnostic action-IR ready');

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'ds_vhistory descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'ds_vhistory no longer reports blocked rules after vhistory migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'ds_vhistory exposes no prioritized blocked-rule list after vhistory migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'ds_vhistory exposes no top blocked rule after vhistory migration');
};
subtest 'tablegrep_operator_guard_method_flow_avoids_prev_node_type_if_raw_fallback' => sub {
    plan tests => 9;

    my $descr = LinkedSpec::get_parser('tablegrep', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for tablegrep operator guard migration check');

    for my $rule (qw(grep group)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "tablegrep $rule exposes action_rewriter metadata");

        my @if_prev_node_raw = grep { defined($_) && $_ =~ /^if\s*\(.*prev_node_type/s } @{$meta->{raw_perl_dependency_statements} || []};
        is(scalar @if_prev_node_raw, 0, "tablegrep $rule no longer reports prev_node_type if-guard as raw-perl fallback");
        ok(grep { $_ eq 'IF' } @{$meta->{canonical_action_ir_nodes}}, "tablegrep $rule canonical action-IR nodes include IF");
        ok(grep { $_ eq 'EXIT' } @{$meta->{canonical_action_ir_nodes}}, "tablegrep $rule canonical action-IR nodes include EXIT");
    }
};
subtest 'tablegrep_accumulator_method_flow_avoids_push_internal_raw_fallback' => sub {
    plan tests => 11;

    my $descr = LinkedSpec::get_parser('tablegrep', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for tablegrep accumulator migration check');

    for my $rule (qw(grep group)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "tablegrep $rule exposes action_rewriter metadata for accumulator migration check");

        my @push_internal_raw = grep { defined($_) && $_ =~ /^push\s+\@internal\s*,\s*\$retv\b/ } @{$meta->{raw_perl_dependency_statements} || []};
        is(scalar @push_internal_raw, 0, "tablegrep $rule no longer reports push \@internal, \$retv as raw-perl fallback");
        ok(grep { $_ eq 'PUSH' } @{$meta->{canonical_action_ir_nodes}}, "tablegrep $rule canonical action-IR nodes include PUSH after accumulator migration");
        ok(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}, "tablegrep $rule canonical action-IR nodes include ASSIGN after accumulator migration");
        ok(grep { $_ eq 'DECLARE' } @{$meta->{canonical_action_ir_nodes}}, "tablegrep $rule canonical action-IR nodes include DECLARE after accumulator migration");
    }
};
subtest 'tablegrep_terminal_token_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 21;

    my $descr = LinkedSpec::get_parser('tablegrep', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for tablegrep terminal/token migration check');

    for my $rule (qw(and_op or_op)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "tablegrep $rule exposes action_rewriter metadata");
        is($meta->{raw_perl_dependency_count}, 0, "tablegrep $rule no longer reports raw-Perl fallback dependency");
        is_deeply($meta->{raw_perl_dependency_statements}, [], "tablegrep $rule exposes no raw-Perl fallback statements");
        ok(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}, "tablegrep $rule canonical action-IR nodes include RETURN after helper migration");
        ok($meta->{language_agnostic_action_ir_ready}, "tablegrep $rule is language-agnostic action-IR ready");
    }

    my $re_term_meta = $descr->{spec}{re_term}{meta}{action_rewriter};
    ok(ref($re_term_meta) eq 'HASH', 'tablegrep re_term exposes action_rewriter metadata');
    is($re_term_meta->{raw_perl_dependency_count}, 0, 'tablegrep re_term no longer reports raw-Perl fallback dependency');
    is_deeply($re_term_meta->{raw_perl_dependency_statements}, [], 'tablegrep re_term exposes no raw-Perl fallback statements');
    is($re_term_meta->{unresolved_helper_count}, 0, 'tablegrep re_term avoids unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$re_term_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'IF' } @{$re_term_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'REGEX_SUBST' } @{$re_term_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$re_term_meta->{canonical_action_ir_nodes}}),
        'tablegrep re_term canonical action-IR nodes include DECLARE/IF/REGEX_SUBST/RETURN after helper migration'
    );
    ok($re_term_meta->{language_agnostic_action_ir_ready}, 'tablegrep re_term is language-agnostic action-IR ready');

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'tablegrep descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'tablegrep no longer reports blocked rules after terminal/token migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'tablegrep exposes no prioritized blocked-rule list after terminal/token migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'tablegrep exposes no top blocked rule after terminal/token migration');
};
subtest 'vhdl_signal_decl_range_method_flow_reduces_raw_push_capture_fallback' => sub {
    plan tests => 11;

    my $descr = LinkedSpec::get_parser('vhdl', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for vhdl signal_decl_range migration check');

    my $meta = $descr->{spec}{signal_decl_range}{meta}{action_rewriter};
    ok(ref($meta) eq 'HASH', 'vhdl signal_decl_range exposes action_rewriter metadata');
    ok(ref($meta->{raw_perl_dependency_statements}) eq 'ARRAY', 'vhdl signal_decl_range exposes raw_perl_dependency_statements array');

    my @targeted_raw = grep {
        defined($_) && (
            $_ =~ /^my \(\@capt, \@msi_lsi\)$/ ||
            $_ =~ /^push \@capt, substr\b/ ||
            $_ =~ /^push \@msi_lsi, \$msi_lsi\b/ ||
            $_ =~ /^if \(\@capt\)\b/ ||
            $_ =~ /^\@capt = \(\)$/
        )
    } @{$meta->{raw_perl_dependency_statements} || []};
    is(scalar @targeted_raw, 0, 'vhdl signal_decl_range no longer reports targeted capture/push guard statements as raw-perl fallback');
    is($meta->{raw_perl_dependency_count}, 0, 'vhdl signal_decl_range no longer reports raw-Perl fallback dependency');
    is_deeply($meta->{raw_perl_dependency_statements}, [], 'vhdl signal_decl_range exposes no raw-Perl fallback statements');
    cmp_ok($meta->{raw_perl_dependency_count}, '<', 9, 'vhdl signal_decl_range raw-perl dependency count is reduced from previous baseline');
    ok(grep { $_ eq 'DECLARE' } @{$meta->{canonical_action_ir_nodes}}, 'vhdl signal_decl_range canonical action-IR nodes include DECLARE');
    ok(grep { $_ eq 'PUSH' } @{$meta->{canonical_action_ir_nodes}}, 'vhdl signal_decl_range canonical action-IR nodes include PUSH');
    ok(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}, 'vhdl signal_decl_range canonical action-IR nodes include ASSIGN');
    ok($meta->{language_agnostic_action_ir_ready}, 'vhdl signal_decl_range is now language-agnostic action-IR ready');
};
subtest 'vhdl_package_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 15;

    my $descr = LinkedSpec::get_parser('vhdl', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for vhdl package migration check');

    my $package_decl_meta = $descr->{spec}{package_declaration}{meta}{action_rewriter};
    ok(ref($package_decl_meta) eq 'HASH', 'vhdl package_declaration exposes action_rewriter metadata');
    is($package_decl_meta->{raw_perl_dependency_count}, 0, 'vhdl package_declaration no longer reports raw-Perl fallback dependency');
    is_deeply($package_decl_meta->{raw_perl_dependency_statements}, [], 'vhdl package_declaration exposes no raw-Perl fallback statements');
    is($package_decl_meta->{unresolved_helper_count}, 0, 'vhdl package_declaration avoids unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$package_decl_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$package_decl_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'MAP_LOWERCASE' } @{$package_decl_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$package_decl_meta->{canonical_action_ir_nodes}}),
        'vhdl package_declaration canonical action-IR nodes include DECLARE/ASSIGN/MAP_LOWERCASE/RETURN after helper migration'
    );
    ok($package_decl_meta->{language_agnostic_action_ir_ready}, 'vhdl package_declaration is language-agnostic action-IR ready');

    my $package_body_meta = $descr->{spec}{package_body}{meta}{action_rewriter};
    ok(ref($package_body_meta) eq 'HASH', 'vhdl package_body exposes action_rewriter metadata');
    is($package_body_meta->{raw_perl_dependency_count}, 0, 'vhdl package_body no longer reports raw-Perl fallback dependency');
    is_deeply($package_body_meta->{raw_perl_dependency_statements}, [], 'vhdl package_body exposes no raw-Perl fallback statements');
    is($package_body_meta->{unresolved_helper_count}, 0, 'vhdl package_body avoids unresolved-helper hits');
    ok(grep { $_ eq 'RETURN' } @{$package_body_meta->{canonical_action_ir_nodes}}, 'vhdl package_body canonical action-IR nodes include RETURN after helper migration');
    ok($package_body_meta->{language_agnostic_action_ir_ready}, 'vhdl package_body is language-agnostic action-IR ready');

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'vhdl descriptor exposes action_rewriter migration summary');
    ok(
        !grep { $_ eq 'package_declaration' || $_ eq 'package_body' } @{$summary->{language_agnostic_blocked_rules_by_priority} || []},
        'vhdl migration summary no longer lists package rules as blocked'
    );
};
subtest 'vhdl_declaration_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 17;

    my $descr = LinkedSpec::get_parser('vhdl', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for vhdl declaration migration check');

    my $subprogram_meta = $descr->{spec}{subprogram_declaration}{meta}{action_rewriter};
    ok(ref($subprogram_meta) eq 'HASH', 'vhdl subprogram_declaration exposes action_rewriter metadata');
    is($subprogram_meta->{raw_perl_dependency_count}, 0, 'vhdl subprogram_declaration no longer reports raw-Perl fallback dependency');
    is_deeply($subprogram_meta->{raw_perl_dependency_statements}, [], 'vhdl subprogram_declaration exposes no raw-Perl fallback statements');
    is($subprogram_meta->{unresolved_helper_count}, 0, 'vhdl subprogram_declaration avoids unresolved-helper hits');
    ok(grep { $_ eq 'RETURN' } @{$subprogram_meta->{canonical_action_ir_nodes}}, 'vhdl subprogram_declaration canonical action-IR nodes include RETURN after helper migration');
    ok($subprogram_meta->{language_agnostic_action_ir_ready}, 'vhdl subprogram_declaration is language-agnostic action-IR ready');

    my $type_meta = $descr->{spec}{type_declaration}{meta}{action_rewriter};
    ok(ref($type_meta) eq 'HASH', 'vhdl type_declaration exposes action_rewriter metadata');
    is($type_meta->{raw_perl_dependency_count}, 0, 'vhdl type_declaration no longer reports raw-Perl fallback dependency');
    is_deeply($type_meta->{raw_perl_dependency_statements}, [], 'vhdl type_declaration exposes no raw-Perl fallback statements');
    is($type_meta->{unresolved_helper_count}, 0, 'vhdl type_declaration avoids unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$type_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$type_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$type_meta->{canonical_action_ir_nodes}}),
        'vhdl type_declaration canonical action-IR nodes include DECLARE/ASSIGN/RETURN after helper migration'
    );
    ok($type_meta->{language_agnostic_action_ir_ready}, 'vhdl type_declaration is language-agnostic action-IR ready');

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'vhdl descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'vhdl blocked-rule count reaches zero after the later subprogram_body cleanup');
    ok(
        !grep { $_ eq 'subprogram_declaration' || $_ eq 'type_declaration' } @{$summary->{language_agnostic_blocked_rules_by_priority} || []},
        'vhdl migration summary no longer lists declaration rules as blocked'
    );
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'vhdl exposes no top blocked rule after the later subprogram_body cleanup');
};
subtest 'vhdl_small_blocker_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 20;

    my $descr = LinkedSpec::get_parser('vhdl', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for small vhdl blocker migration check');

    for my $rule (qw(signal_declaration configuration_specification vhdl_file)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "vhdl $rule exposes action_rewriter metadata");
        is($meta->{raw_perl_dependency_count}, 0, "vhdl $rule no longer reports raw-Perl fallback dependency");
        is_deeply($meta->{raw_perl_dependency_statements}, [], "vhdl $rule exposes no raw-Perl fallback statements");
        is($meta->{unresolved_helper_count}, 0, "vhdl $rule avoids unresolved-helper hits");
        ok($meta->{language_agnostic_action_ir_ready}, "vhdl $rule is language-agnostic action-IR ready");
    }

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'vhdl descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'vhdl blocked-rule count reaches zero after the later subprogram_body migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'vhdl blocked-rule priority list is empty after the later subprogram_body migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'vhdl exposes no top blocked rule after the later subprogram_body migration');
};
subtest 'vhdl_process_statement_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 11;

    my $descr = LinkedSpec::get_parser('vhdl', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for vhdl process_statement migration check');

    my $meta = $descr->{spec}{process_statement}{meta}{action_rewriter};
    ok(ref($meta) eq 'HASH', 'vhdl process_statement exposes action_rewriter metadata');
    is($meta->{raw_perl_dependency_count}, 0, 'vhdl process_statement no longer reports raw-Perl fallback dependency');
    is_deeply($meta->{raw_perl_dependency_statements}, [], 'vhdl process_statement exposes no raw-Perl fallback statements');
    is($meta->{unresolved_helper_count}, 0, 'vhdl process_statement avoids unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}),
        'vhdl process_statement canonical action-IR nodes include DECLARE/ASSIGN/RETURN after helper migration'
    );
    ok($meta->{language_agnostic_action_ir_ready}, 'vhdl process_statement is language-agnostic action-IR ready');

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'vhdl descriptor exposes action_rewriter migration summary after process_statement migration');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'vhdl blocked-rule count reaches zero after the later subprogram_body migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'vhdl blocked-rule priority list is empty after the later subprogram_body migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'vhdl exposes no top blocked rule after the later subprogram_body migration');
};
subtest 'vhdl_subprogram_body_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 12;

    my $descr = LinkedSpec::get_parser('vhdl', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for vhdl subprogram_body migration check');

    my $meta = $descr->{spec}{subprogram_body}{meta}{action_rewriter};
    ok(ref($meta) eq 'HASH', 'vhdl subprogram_body exposes action_rewriter metadata');
    is($meta->{raw_perl_dependency_count}, 0, 'vhdl subprogram_body no longer reports raw-Perl fallback dependency');
    is_deeply($meta->{raw_perl_dependency_statements}, [], 'vhdl subprogram_body exposes no raw-Perl fallback statements');
    is($meta->{unresolved_helper_count}, 0, 'vhdl subprogram_body avoids unresolved-helper hits');
    is_deeply($meta->{language_agnostic_action_ir_blocker_statements}, [], 'vhdl subprogram_body exposes no language-agnostic blocker statements');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'SPLIT' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'SPLIT_EACH' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'FILTER_NONEMPTY' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}),
        'vhdl subprogram_body canonical action-IR nodes include DECLARE/ASSIGN/SPLIT/SPLIT_EACH/FILTER_NONEMPTY/RETURN after helper migration'
    );
    ok($meta->{language_agnostic_action_ir_ready}, 'vhdl subprogram_body is language-agnostic action-IR ready');

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'vhdl descriptor exposes action_rewriter migration summary after subprogram_body migration');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'vhdl no longer reports blocked rules after subprogram_body migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'vhdl blocked-rule priority list is empty after subprogram_body migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'vhdl exposes no top blocked rule after subprogram_body migration');
};
subtest 'simenv_begin_end_blocks_method_flow_is_language_agnostic_ready' => sub {
    plan tests => 10;

    my $descr = LinkedSpec::get_parser('simenv', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for simenv begin_end_blocks migration check');

    my $meta = $descr->{spec}{begin_end_blocks}{meta}{action_rewriter};
    ok(ref($meta) eq 'HASH', 'simenv begin_end_blocks exposes action_rewriter metadata');
    is($meta->{raw_perl_dependency_count}, 0, 'simenv begin_end_blocks no longer reports raw-Perl fallback dependency');
    is_deeply($meta->{raw_perl_dependency_statements}, [], 'simenv begin_end_blocks exposes no raw-Perl fallback statements');
    is($meta->{unresolved_helper_count}, 0, 'simenv begin_end_blocks avoids unresolved-helper hits');
    is_deeply($meta->{language_agnostic_action_ir_blocker_statements}, [], 'simenv begin_end_blocks exposes no language-agnostic blocker statements');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PUSH' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}),
        'simenv begin_end_blocks canonical action-IR nodes include DECLARE/ASSIGN/PUSH/RETURN'
    );
    ok(
        scalar(grep { $_ eq 'IF' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ELSE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ENDIF' } @{$meta->{canonical_action_ir_nodes}}),
        'simenv begin_end_blocks canonical action-IR nodes include IF/ELSE/ENDIF control flow'
    );
    ok(
        scalar(grep { $_ eq 'PRINT' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'EXIT' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'REGEX_SUBST' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'LINE_COUNT' } @{$meta->{canonical_action_ir_nodes}}),
        'simenv begin_end_blocks canonical action-IR nodes include PRINT/EXIT/REGEX_SUBST/LINE_COUNT'
    );
    ok($meta->{language_agnostic_action_ir_ready}, 'simenv begin_end_blocks is now language-agnostic action-IR ready');
};
subtest 'ifelse_debug_print_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 36;

    my $descr = LinkedSpec::get_parser('ifelse', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for ifelse debug-print migration check');

    for my $rule (qw(program if then elsif else while while_then)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "ifelse $rule exposes action_rewriter metadata");
        is($meta->{raw_perl_dependency_count}, 0, "ifelse $rule no longer reports raw-Perl fallback dependency");
        is_deeply($meta->{raw_perl_dependency_statements}, [], "ifelse $rule exposes no raw-Perl fallback statements");
        ok(grep { $_ eq 'PRINT' } @{$meta->{canonical_action_ir_nodes}}, "ifelse $rule canonical action-IR nodes include PRINT after debug-print migration");
        ok($meta->{language_agnostic_action_ir_ready}, "ifelse $rule is language-agnostic action-IR ready");
    }
};
subtest 'bnf_debug_print_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 61;

    my $descr = LinkedSpec::get_parser('BNF', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for BNF debug-print migration check');

    for my $rule (qw(description construction_start node dquote_str squote_str regex group g_repetition q_mark plus star pipe)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "BNF $rule exposes action_rewriter metadata");
        is($meta->{raw_perl_dependency_count}, 0, "BNF $rule no longer reports raw-Perl fallback dependency");
        is_deeply($meta->{raw_perl_dependency_statements}, [], "BNF $rule exposes no raw-Perl fallback statements");
        ok(grep { $_ eq 'PRINT' } @{$meta->{canonical_action_ir_nodes}}, "BNF $rule canonical action-IR nodes include PRINT after debug-print migration");
        ok($meta->{language_agnostic_action_ir_ready}, "BNF $rule is language-agnostic action-IR ready");
    }
};
subtest 'operators_try_debug_print_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 70;

    my $descr = LinkedSpec::get_parser('operators_try', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for operators_try debug-print migration check');

    for my $rule (qw(top_expression group function_call string auto_inc_op auto_dec_op div_op mul_op add_op sub_op string_concat variable integer)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "operators_try $rule exposes action_rewriter metadata");
        is($meta->{raw_perl_dependency_count}, 0, "operators_try $rule no longer reports raw-Perl fallback dependency");
        is_deeply($meta->{raw_perl_dependency_statements}, [], "operators_try $rule exposes no raw-Perl fallback statements");
        ok(grep { $_ eq 'PRINT' } @{$meta->{canonical_action_ir_nodes}}, "operators_try $rule canonical action-IR nodes include PRINT after debug-print migration");
        ok($meta->{language_agnostic_action_ir_ready}, "operators_try $rule is language-agnostic action-IR ready");
    }

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'operators_try descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'operators_try blocked-rule count drops to zero after debug-print migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'operators_try exposes no prioritized blocked-rule list after debug-print migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'operators_try exposes no top blocked rule after debug-print migration');
};
subtest 'dt_debug_print_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 60;

    my $descr = LinkedSpec::get_parser('DT', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for DT debug-print migration check');

    for my $rule (qw(dtree testcontrol group identifier if_binary if_vector reg_assignment_lhs state_transition dtree_call logical_operator inline_dt_definition)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "DT $rule exposes action_rewriter metadata");
        is($meta->{raw_perl_dependency_count}, 0, "DT $rule no longer reports raw-Perl fallback dependency");
        is_deeply($meta->{raw_perl_dependency_statements}, [], "DT $rule exposes no raw-Perl fallback statements");
        ok(grep { $_ eq 'PRINT' } @{$meta->{canonical_action_ir_nodes}}, "DT $rule canonical action-IR nodes include PRINT after debug-print migration");
        ok($meta->{language_agnostic_action_ir_ready}, "DT $rule is language-agnostic action-IR ready");
    }

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'DT descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'DT blocked-rule count drops to zero after debug-print migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'DT exposes no prioritized blocked-rule list after debug-print migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'DT exposes no top blocked rule after debug-print migration');
};
subtest 'hlink_substitution_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 23;

    my $descr = LinkedSpec::get_parser('hlink_substitution', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for hlink_substitution helper-flow migration check');

    for my $rule (qw(substitute_top substitute_statement2 curlyb)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "hlink_substitution $rule exposes action_rewriter metadata");
        is($meta->{raw_perl_dependency_count}, 0, "hlink_substitution $rule no longer reports raw-Perl fallback dependency");
        is_deeply($meta->{raw_perl_dependency_statements}, [], "hlink_substitution $rule exposes no raw-Perl fallback statements");
        is($meta->{unresolved_helper_count}, 0, "hlink_substitution $rule avoids unresolved-helper hits");
        ok($meta->{language_agnostic_action_ir_ready}, "hlink_substitution $rule is language-agnostic action-IR ready");
    }

    my $top_meta = $descr->{spec}{substitute_top}{meta}{action_rewriter};
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$top_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$top_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PUSH' } @{$top_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'IF' } @{$top_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PRINT' } @{$top_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'EXIT' } @{$top_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$top_meta->{canonical_action_ir_nodes}}),
        'hlink_substitution substitute_top canonical action-IR nodes include DECLARE/ASSIGN/PUSH/IF/PRINT/EXIT/RETURN after helper migration'
    );

    my $curlyb_meta = $descr->{spec}{curlyb}{meta}{action_rewriter};
    ok(
        scalar(grep { $_ eq 'PRINT' } @{$curlyb_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'EXIT' } @{$curlyb_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$curlyb_meta->{canonical_action_ir_nodes}}),
        'hlink_substitution curlyb canonical action-IR nodes include PRINT/EXIT/RETURN after helper migration'
    );

    my $sub2_meta = $descr->{spec}{substitute_statement2}{meta}{action_rewriter};
    ok(
        scalar(grep { $_ eq 'PRINT' } @{$sub2_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'EXIT' } @{$sub2_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$sub2_meta->{canonical_action_ir_nodes}}),
        'hlink_substitution substitute_statement2 canonical action-IR nodes include PRINT/EXIT/RETURN after helper migration'
    );

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'hlink_substitution descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'hlink_substitution blocked-rule count drops to zero after helper migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'hlink_substitution exposes no prioritized blocked-rule list after helper migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'hlink_substitution exposes no top blocked rule after helper migration');
};
subtest 'lib_reader_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 23;

    my $descr = LinkedSpec::get_parser('lib_reader', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for lib_reader helper-flow migration check');

    for my $rule (qw(group cattribute sattribute)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "lib_reader $rule exposes action_rewriter metadata");
        is($meta->{raw_perl_dependency_count}, 0, "lib_reader $rule no longer reports raw-Perl fallback dependency");
        is_deeply($meta->{raw_perl_dependency_statements}, [], "lib_reader $rule exposes no raw-Perl fallback statements");
        is($meta->{unresolved_helper_count}, 0, "lib_reader $rule avoids unresolved-helper hits");
        ok($meta->{language_agnostic_action_ir_ready}, "lib_reader $rule is language-agnostic action-IR ready");
    }

    my $group_meta = $descr->{spec}{group}{meta}{action_rewriter};
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$group_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'REGEX_SUBST' } @{$group_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PUSH' } @{$group_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$group_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'SAY' } @{$group_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'EXIT' } @{$group_meta->{canonical_action_ir_nodes}}),
        'lib_reader group canonical action-IR nodes include DECLARE/REGEX_SUBST/PUSH/RETURN/SAY/EXIT after helper migration'
    );

    my $cattribute_meta = $descr->{spec}{cattribute}{meta}{action_rewriter};
    ok(
        scalar(grep { $_ eq 'RETURN' } @{$cattribute_meta->{canonical_action_ir_nodes}}),
        'lib_reader cattribute canonical action-IR nodes include RETURN after helper migration'
    );

    my $sattribute_meta = $descr->{spec}{sattribute}{meta}{action_rewriter};
    ok(
        scalar(grep { $_ eq 'RETURN' } @{$sattribute_meta->{canonical_action_ir_nodes}}),
        'lib_reader sattribute canonical action-IR nodes include RETURN after helper migration'
    );

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'lib_reader descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'lib_reader blocked-rule count drops to zero after helper migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'lib_reader exposes no prioritized blocked-rule list after helper migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'lib_reader exposes no top blocked rule after helper migration');
};
subtest 'sdce_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 17;

    my $descr = LinkedSpec::get_parser('sdce', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for sdce helper-flow migration check');

    for my $rule (qw(sdc_esplit get_pinport)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "sdce $rule exposes action_rewriter metadata");
        is($meta->{raw_perl_dependency_count}, 0, "sdce $rule no longer reports raw-Perl fallback dependency");
        is_deeply($meta->{raw_perl_dependency_statements}, [], "sdce $rule exposes no raw-Perl fallback statements");
        is($meta->{unresolved_helper_count}, 0, "sdce $rule avoids unresolved-helper hits");
        ok($meta->{language_agnostic_action_ir_ready}, "sdce $rule is language-agnostic action-IR ready");
    }

    my $top_meta = $descr->{spec}{sdc_esplit}{meta}{action_rewriter};
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$top_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$top_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PUSH' } @{$top_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$top_meta->{canonical_action_ir_nodes}}),
        'sdce sdc_esplit canonical action-IR nodes include DECLARE/ASSIGN/PUSH/RETURN after helper migration'
    );

    my $get_meta = $descr->{spec}{get_pinport}{meta}{action_rewriter};
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$get_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$get_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'CALL' } @{$get_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'SPLIT' } @{$get_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'FILTER_NONEMPTY' } @{$get_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$get_meta->{canonical_action_ir_nodes}}),
        'sdce get_pinport canonical action-IR nodes include DECLARE/ASSIGN/CALL/SPLIT/FILTER_NONEMPTY/RETURN after helper migration'
    );

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'sdce descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'sdce blocked-rule count drops to zero after helper migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'sdce exposes no prioritized blocked-rule list after helper migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'sdce exposes no top blocked rule after helper migration');
};
subtest 'portmap_bare_bit_slice_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 13;

    my $descr = LinkedSpec::get_parser('portmap', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for portmap bare_bit_slice migration check');

    my $meta = $descr->{spec}{bare_bit_slice}{meta}{action_rewriter};
    ok(ref($meta) eq 'HASH', 'portmap bare_bit_slice exposes action_rewriter metadata');
    is($meta->{raw_perl_dependency_count}, 0, 'portmap bare_bit_slice no longer reports raw-Perl fallback dependency');
    is_deeply($meta->{raw_perl_dependency_statements}, [], 'portmap bare_bit_slice exposes no raw-Perl fallback statements');
    is($meta->{unresolved_helper_count}, 0, 'portmap bare_bit_slice avoids unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'IF' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ELIF' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ELSE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}),
        'portmap bare_bit_slice canonical action-IR nodes include IF/ELIF/ELSE/RETURN after helper migration'
    );
    ok($meta->{language_agnostic_action_ir_ready}, 'portmap bare_bit_slice is language-agnostic action-IR ready');

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'portmap descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'portmap blocked-rule count drops to zero after helper migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'portmap exposes no prioritized blocked-rule list after helper migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'portmap exposes no top blocked rule after helper migration');
    is($descr->{spec}{portmap}{meta}{action_rewriter}{raw_perl_dependency_count}, 0, 'portmap top rule remains free of raw fallback after bare_bit_slice migration');
    is($descr->{spec}{concatenation}{meta}{action_rewriter}{raw_perl_dependency_count}, 0, 'portmap concatenation rule remains free of raw fallback after bare_bit_slice migration');
};
subtest 'portmap_bare_bit_slice_classification_smoke' => sub {
    plan tests => 15;

    my $parser = LinkedSpec::get_parser('portmap');
    ok(defined($parser) && ref($parser) eq 'CODE', 'portmap parser created');

    my @cases = (
        [q{foo}, ['?bare:', ['foo']]],
        [q{bar[3]}, ['?bit:', ['bar', '3']]],
        [q{bar[0]}, ['?bit:', ['bar', '0']]],
        [q{baz[7:0]}, ['?slice:', ['baz', '7', '0']]],
        [q{0x1f}, ['?constant:', ['0x1f']]],
        [q{foo[?bar]}, ['?bit:', ['foo', '?bar']]],
        [q{{foo bar[2]}}, ['?concat:', [['?bare:', ['foo']], ['?bit:', ['bar', '2']]]]],
    );

    for my $case (@cases) {
        my ($input, $expected) = @$case;
        my $copy = $input;
        my $ast = eval { $parser->(\$copy) };
        ok(!$@, "portmap parse completed for `$input`") or diag(normalize_error($@));
        is_deeply($ast, $expected, "portmap classification matches expected AST for `$input`");
    }
};
subtest 'pplugin_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 11;

    my $descr = LinkedSpec::get_parser('pplugin', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for pplugin helper-flow migration check');

    my $meta = $descr->{spec}{pplugin_top}{meta}{action_rewriter};
    ok(ref($meta) eq 'HASH', 'pplugin_top exposes action_rewriter metadata');
    is($meta->{raw_perl_dependency_count}, 0, 'pplugin_top no longer reports raw-Perl fallback dependency');
    is_deeply($meta->{raw_perl_dependency_statements}, [], 'pplugin_top exposes no raw-Perl fallback statements');
    is($meta->{unresolved_helper_count}, 0, 'pplugin_top avoids unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'NEXT' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}),
        'pplugin_top canonical action-IR nodes include DECLARE/ASSIGN/NEXT/CALL/RETURN after helper migration'
    );
    ok($meta->{language_agnostic_action_ir_ready}, 'pplugin_top is language-agnostic action-IR ready');

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'pplugin descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'pplugin blocked-rule count drops to zero after helper migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'pplugin exposes no prioritized blocked-rule list after helper migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'pplugin exposes no top blocked rule after helper migration');
};
subtest 'pplugin_parser_smoke' => sub {
    plan tests => 8;

    my $parser = LinkedSpec::get_parser('pplugin');
    ok(defined($parser) && ref($parser) eq 'CODE', 'pplugin parser created');

    my $input = <<'PPLUGIN';
foo { 1 + 2 }
# comment
bar { qq(ok) }
PPLUGIN

    my $ast = eval { $parser->(\$input) };
    ok(!$@, 'pplugin parser executed without die') or diag(normalize_error($@));
    ok(defined($ast) && ref($ast) eq 'HASH', 'pplugin parser returned a hash AST');
    is_deeply([sort keys %$ast], [qw(bar foo)], 'pplugin AST preserves expected subdef names');
    is(ref($ast->{foo}), 'CODE', 'pplugin foo entry is a coderef');
    is(ref($ast->{bar}), 'CODE', 'pplugin bar entry is a coderef');
    is($ast->{foo}->(), 3, 'pplugin foo coderef preserves evaluated body behavior');
    is($ast->{bar}->(), 'ok', 'pplugin bar coderef preserves evaluated body behavior');
};
subtest 'tkgui_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 11;

    my $descr = LinkedSpec::get_parser('tkgui', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for tkgui helper-flow migration check');

    my $meta = $descr->{spec}{sub_gui}{meta}{action_rewriter};
    ok(ref($meta) eq 'HASH', 'tkgui sub_gui exposes action_rewriter metadata');
    is($meta->{raw_perl_dependency_count}, 0, 'tkgui sub_gui no longer reports raw-Perl fallback dependency');
    is_deeply($meta->{raw_perl_dependency_statements}, [], 'tkgui sub_gui exposes no raw-Perl fallback statements');
    is($meta->{unresolved_helper_count}, 0, 'tkgui sub_gui avoids unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PRINT' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}),
        'tkgui sub_gui canonical action-IR nodes include ASSIGN/CALL/PRINT/RETURN after helper migration'
    );
    ok($meta->{language_agnostic_action_ir_ready}, 'tkgui sub_gui is language-agnostic action-IR ready');

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'tkgui descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'tkgui blocked-rule count drops to zero after helper migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'tkgui exposes no prioritized blocked-rule list after helper migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'tkgui exposes no top blocked rule after helper migration');
};
subtest 'tkgui_parser_smoke' => sub {
    plan tests => 7;

    my $parser = LinkedSpec::get_parser('tkgui');
    ok(defined($parser) && ref($parser) eq 'CODE', 'tkgui parser created');

    my $input = "start {(frame foo)}\n# comment\n";
    my ($ok, $ast, $err, $stdout, $stderr, $inner_eval_err) = run_parser_with_captured_io($parser, \$input);
    ok($ok, 'tkgui parser executed without die') or diag(normalize_error($err));
    ok(defined($ast) && ref($ast) eq 'HASH', 'tkgui parser returned a hash AST');
    is($inner_eval_err, '', 'tkgui parser execution leaves no inner eval error');
    is($stdout, "Found a SUB GUI entry point <start>\n", 'tkgui parser preserves the sub_gui entry-point debug print');
    is($stderr, '', 'tkgui parser emits no stderr for the smoke input');
    is_deeply($ast, {'((frame foo))' => undef}, 'tkgui parser preserves the current one-entry hash shape');
};
subtest 'simenv_delimiter_helper_print_flow_eliminates_raw_fallback' => sub {
    plan tests => 36;

    my $descr = LinkedSpec::get_parser('simenv', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for simenv delimiter-helper migration check');

    for my $rule (qw(bs_nl squotes perl_squotes multiline_value bvariable_substitution curlybrace parenthesis)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "simenv $rule exposes action_rewriter metadata");
        is($meta->{raw_perl_dependency_count}, 0, "simenv $rule no longer reports raw-Perl fallback dependency");
        is_deeply($meta->{raw_perl_dependency_statements}, [], "simenv $rule exposes no raw-Perl fallback statements");
        ok(grep { $_ eq 'PRINT' } @{$meta->{canonical_action_ir_nodes}}, "simenv $rule canonical action-IR nodes include PRINT after delimiter-helper migration");
        ok($meta->{language_agnostic_action_ir_ready}, "simenv $rule is language-agnostic action-IR ready");
    }
};
subtest 'simenv_quote_substitution_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 36;

    my $descr = LinkedSpec::get_parser('simenv', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for simenv quote-substitution migration check');

    for my $rule (qw(singleline_value dquotes perl_dquotes command_substitution perl_command_substitution variable_substitution comments)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "simenv $rule exposes action_rewriter metadata");
        is($meta->{raw_perl_dependency_count}, 0, "simenv $rule no longer reports raw-Perl fallback dependency");
        is_deeply($meta->{raw_perl_dependency_statements}, [], "simenv $rule exposes no raw-Perl fallback statements");
        ok(grep { $_ eq 'PRINT' } @{$meta->{canonical_action_ir_nodes}}, "simenv $rule canonical action-IR nodes include PRINT after quote-substitution migration");
        ok($meta->{language_agnostic_action_ir_ready}, "simenv $rule is language-agnostic action-IR ready");
    }
};
subtest 'simenv_top_and_anyvariable_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 17;

    my $descr = LinkedSpec::get_parser('simenv', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for simenv top/anyvariable migration check');

    my $top_meta = $descr->{spec}{top}{meta}{action_rewriter};
    ok(ref($top_meta) eq 'HASH', 'simenv top exposes action_rewriter metadata');
    is($top_meta->{raw_perl_dependency_count}, 0, 'simenv top no longer reports raw-Perl fallback dependency');
    is_deeply($top_meta->{raw_perl_dependency_statements}, [], 'simenv top exposes no raw-Perl fallback statements');
    is($top_meta->{unresolved_helper_count}, 0, 'simenv top avoids unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$top_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'IF' } @{$top_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PUSH' } @{$top_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$top_meta->{canonical_action_ir_nodes}}),
        'simenv top canonical action-IR nodes include DECLARE/IF/PUSH/RETURN after helper migration'
    );
    ok($top_meta->{language_agnostic_action_ir_ready}, 'simenv top is language-agnostic action-IR ready');

    my $any_meta = $descr->{spec}{anyvariable}{meta}{action_rewriter};
    ok(ref($any_meta) eq 'HASH', 'simenv anyvariable exposes action_rewriter metadata');
    is($any_meta->{raw_perl_dependency_count}, 0, 'simenv anyvariable no longer reports raw-Perl fallback dependency');
    is_deeply($any_meta->{raw_perl_dependency_statements}, [], 'simenv anyvariable exposes no raw-Perl fallback statements');
    is($any_meta->{unresolved_helper_count}, 0, 'simenv anyvariable avoids unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$any_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'REGEX_SUBST' } @{$any_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PRINT' } @{$any_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$any_meta->{canonical_action_ir_nodes}}),
        'simenv anyvariable canonical action-IR nodes include DECLARE/REGEX_SUBST/PRINT/RETURN after helper migration'
    );
    ok($any_meta->{language_agnostic_action_ir_ready}, 'simenv anyvariable is language-agnostic action-IR ready');

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'simenv descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'simenv no longer reports blocked rules after top/anyvariable migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'simenv exposes no prioritized blocked-rule list after top/anyvariable migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'simenv exposes no top blocked rule after top/anyvariable migration');
};
subtest 'lispish_small_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 47;

    my $descr = LinkedSpec::get_parser('Lispish', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for small Lispish migration check');

    for my $rule (qw(Lispish comments curlyb dquotes others sbrackets spaces squotes)) {
        my $meta = $descr->{spec}{$rule}{meta}{action_rewriter};
        ok(ref($meta) eq 'HASH', "Lispish $rule exposes action_rewriter metadata");
        is($meta->{raw_perl_dependency_count}, 0, "Lispish $rule no longer reports raw-Perl fallback dependency");
        is_deeply($meta->{raw_perl_dependency_statements}, [], "Lispish $rule exposes no raw-Perl fallback statements");
        is($meta->{unresolved_helper_count}, 0, "Lispish $rule avoids unresolved-helper hits");
        ok($meta->{language_agnostic_action_ir_ready}, "Lispish $rule is language-agnostic action-IR ready");
    }

    my $curlyb_meta = $descr->{spec}{curlyb}{meta}{action_rewriter};
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$curlyb_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$curlyb_meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$curlyb_meta->{canonical_action_ir_nodes}}),
        'Lispish curlyb canonical action-IR nodes include DECLARE/ASSIGN/RETURN after helper migration'
    );

    my $top_meta = $descr->{spec}{Lispish}{meta}{action_rewriter};
    ok(grep { $_ eq 'SAY' } @{$top_meta->{canonical_action_ir_nodes}}, 'Lispish top canonical action-IR nodes include SAY after helper migration');

    my $summary = $descr->{meta}{action_rewriter_migration};
    ok(ref($summary) eq 'HASH', 'Lispish descriptor exposes action_rewriter migration summary');
    is($summary->{language_agnostic_blocked_rule_count}, 0, 'Lispish blocked-rule count drops to zero after the final parenthesis migration');
    is_deeply($summary->{language_agnostic_blocked_rules_by_priority}, [], 'Lispish exposes no prioritized blocked-rule list after the final parenthesis migration');
    ok(!defined($summary->{language_agnostic_top_blocked_rule}), 'Lispish exposes no top blocked rule after the final parenthesis migration');
};
subtest 'lispish_parenthesis_helper_flow_eliminates_raw_fallback' => sub {
    plan tests => 7;

    my $descr = LinkedSpec::get_parser('Lispish', return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for Lispish parenthesis migration check');

    my $meta = $descr->{spec}{parenthesis}{meta}{action_rewriter};
    ok(ref($meta) eq 'HASH', 'Lispish parenthesis exposes action_rewriter metadata');
    is($meta->{raw_perl_dependency_count}, 0, 'Lispish parenthesis no longer reports raw-Perl fallback dependency');
    is_deeply($meta->{raw_perl_dependency_statements}, [], 'Lispish parenthesis exposes no raw-Perl fallback statements');
    is($meta->{unresolved_helper_count}, 0, 'Lispish parenthesis avoids unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'PUSH' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'IF' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'CALL' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}),
        'Lispish parenthesis canonical action-IR nodes include DECLARE/ASSIGN/PUSH/IF/CALL/RETURN after helper migration'
    );
    ok($meta->{language_agnostic_action_ir_ready}, 'Lispish parenthesis is language-agnostic action-IR ready');
};
subtest 'lispish_ast_smoke' => sub {
    my $parser = LinkedSpec::get_parser('Lispish');
    ok(defined($parser) && ref($parser) eq 'CODE', 'Lispish parser created');

    my $input = "(a (b c) d)";
    my $ast = eval { $parser->(\$input) };
    ok(!$@, 'Lispish parser executed without die') or diag(normalize_error($@));

    my $expected = [
        'a',
        [
            [
                'b',
                ['c'],
            ],
            'd',
        ],
    ];

    is_deeply($ast, $expected, 'Lispish nested AST matches expected baseline shape');
};

subtest 'vhdl_invariants_smoke' => sub {
    my $parser = LinkedSpec::get_parser('vhdl');
    ok(defined($parser) && ref($parser) eq 'CODE', 'vhdl parser created');

    my $input = <<'VHDL';
library ieee;
use ieee.std_logic_1164.all;
entity demo is
  port (
    clk : in std_logic
  );
end entity demo;
architecture rtl of demo is
begin
end architecture rtl;
VHDL

    my $ast = eval { $parser->(\$input) };
    ok(!$@, 'vhdl parser executed without die') or diag(normalize_error($@));
    ok(defined $ast, 'vhdl parser returned a defined AST');

    my %tags;
    collect_tags($ast, \%tags);

    ok($tags{'?library_clause:'}, 'AST contains ?library_clause:');
    ok($tags{'?use_clause:'}, 'AST contains ?use_clause:');
    ok($tags{'?entity_declaration:'}, 'AST contains ?entity_declaration:');
};
subtest 'ebnf_invariants_smoke' => sub {
    my $parser = LinkedSpec::get_parser('ebnf');
    ok(defined($parser) && ref($parser) eq 'CODE', 'ebnf parser created');

    my $input = <<'EBNF';
Expr := Term ("+" Term)*
Term := Factor
EBNF

    my $ast = eval { $parser->(\$input) };
    ok(!$@, 'ebnf parser executed without die') or diag(normalize_error($@));
    ok(defined $ast && ref($ast) eq 'ARRAY', 'ebnf parser returned an array AST');

    my @rule_names;
    for my $entry (@$ast) {
        next unless ref($entry) eq 'ARRAY' && @$entry;
        next unless ref($entry->[0]) eq 'ARRAY';
        next unless $entry->[0][0] && $entry->[0][0] eq 'rule';
        push @rule_names, $entry->[0][1];
    }

    is_deeply(\@rule_names, ['Expr', 'Term'], 'ebnf AST preserves expected top rule names');
};

subtest 'corpus_regression' => sub {
    my @datasets = (
        {
            name   => 'plugin_plg_via_pplugin_spec',
            dir    => File::Spec->catdir($Bin, '..', 'plugin'),
            suffix => '.plg',
            probe  => sub {
                my ($file) = @_;
                return parse_with_linkedspec('pplugin', $file, 'HASH');
            },
        },
        {
            name   => 'conf_via_lispish_spec',
            dir    => File::Spec->catdir($Bin, '..', 'conf'),
            suffix => '.conf',
            probe  => sub {
                my ($file) = @_;
                return parse_with_lispish_multi($file, 1);
            },
        },
        {
            name   => 'tablescript_via_lispish_runtime',
            dir    => File::Spec->catdir($Bin, '..', 'tablescript'),
            suffix => '.ts',
            probe  => sub {
                my ($file) = @_;
                return parse_with_lispish_multi($file, 1);
            },
        },
        {
            name   => 'ebnf_corpus_via_ebnf_spec',
            dir    => File::Spec->catdir($Bin, '..', 'ebnf'),
            suffix => '.ebnf',
            probe  => sub {
                my ($file) = @_;
                return parse_with_linkedspec('ebnf', $file, 'ARRAY');
            },
        },
    );

    plan tests => scalar(@datasets) * 2;

    for my $dataset (@datasets) {
        my @files = discover_dir_files_by_suffix($dataset->{dir}, $dataset->{suffix});
        ok(@files > 0, "$dataset->{name}: discovered files");

        my @failures;
        for my $file (@files) {
            my ($ok, $reason) = $dataset->{probe}->($file);
            next if $ok;
            push @failures, basename($file) . ($reason ? " => $reason" : "");
        }

        ok(!@failures, "$dataset->{name}: parsed all files (" . scalar(@files) . ")")
            or do {
                my @show = @failures > 10 ? @failures[0 .. 9] : @failures;
                diag(join("\n", @show));
                diag("... and " . (@failures - 10) . " more failures") if @failures > 10;
            };
    }
};

subtest 'trace_output_includes_metadata_and_decisions' => sub {
    plan tests => 5;

    my ($ok, $parser, $err, $out, $warn) = run_get_parser_with_captured_io(
        'Lispish',
        trace_level => 'debug',
        trace_log_mode => 'stdout',
        trace_topic_spacing => 0,
    );

    ok($ok, 'get_parser with debug tracing returns without die') or diag(normalize_error($err));
    ok(defined($parser) && ref($parser) eq 'CODE', 'get_parser with debug tracing returns parser coderef');
    like($out, qr/\[[A-Z]+\]\[(?:LinkedSpec\.pm|ParserFactory\.pm|Resolver\.pm|Compiler\.pm|Validation\.pm)\]\[[^\]]+:\d+\]/,
        'trace includes level + owning file + function:line metadata');
    like($out, qr/ENTER LinkedSpec::get_parser|ENTER LinkedSpec::Get/, 'trace includes function entry events');
    like($out, qr/DECISION [^\n]+ => (?:TAKEN|SKIPPED)/, 'trace includes decision/branch events');
};

subtest 'trace_log_file_route_redirects_stdout_to_trace_log' => sub {
    plan tests => 6;

    require File::Temp;
    my $tmp_dir = File::Temp::tempdir(CLEANUP => 1);
    my $trace_log = File::Spec->catfile($tmp_dir, 'trace.log');

    my ($ok, $parser, $err, $out, $warn) = run_get_parser_with_captured_io(
        'Lispish',
        trace_level => 'high',
        trace_log_file => $trace_log,
        trace_log_mode => 'route',
        trace_reset_log => 1,
        trace_topic_spacing => 0,
    );

    ok($ok, 'get_parser with routed trace log returns without die') or diag(normalize_error($err));
    ok(defined($parser) && ref($parser) eq 'CODE', 'get_parser with routed trace log returns parser coderef');
    ok(-f $trace_log, 'trace.log file created');
    my $trace_content = slurp($trace_log);
    ok(length($trace_content) > 0, 'trace.log captures routed trace output');
    unlike($out, qr/ENTER LinkedSpec::get_parser|DECISION [^\n]+ => (?:TAKEN|SKIPPED)/, 'stdout does not include routed trace events');
    like($trace_content, qr/ENTER LinkedSpec::get_parser/, 'trace.log includes get_parser trace events');
};

done_testing();

sub discover_specs {
    my ($dir) = @_;
    opendir(my $dh, $dir) or die "Cannot open specs directory '$dir': $!";
    my @specs = sort grep { /\.spec\z/ } readdir($dh);
    closedir($dh);
    return @specs;
}

sub slurp {
    my ($path) = @_;
    open(my $fh, '<', $path) or die "Cannot read '$path': $!";
    local $/;
    return <$fh>;
}

sub write_text {
    my ($path, $content) = @_;
    open(my $fh, '>', $path) or die "Cannot write '$path': $!";
    print {$fh} $content;
    close($fh);
    return 1;
}

sub collect_tags {
    my ($node, $tags) = @_;
    return unless defined $node;

    if (ref($node) eq 'ARRAY') {
        if (@$node && !ref($node->[0]) && defined $node->[0] && $node->[0] =~ /^\?\w+:/) {
            $tags->{$node->[0]}++;
        }
        collect_tags($_, $tags) foreach @$node;
    } elsif (ref($node) eq 'HASH') {
        collect_tags($_, $tags) foreach values %$node;
    }
}

sub normalize_error {
    my ($e) = @_;
    $e //= '';
    $e =~ s/\s+/ /g;
    $e =~ s/^\s+|\s+$//g;
    return $e || 'Unknown error';
}

sub discover_dir_files_by_suffix {
    my ($dir, $suffix) = @_;
    opendir(my $dh, $dir) or die "Cannot open directory '$dir': $!";
    my @files = sort grep { /\Q$suffix\E\z/ } readdir($dh);
    closedir($dh);
    return map { File::Spec->catfile($dir, $_) } @files;
}

sub parse_with_linkedspec {
    my ($spec_name, $file, $expected_ref) = @_;
    state %parser_cache;

    my $parser = $parser_cache{$spec_name} //= LinkedSpec::get_parser($spec_name);
    return (0, "unable to build parser for spec '$spec_name'") unless $parser && ref($parser) eq 'CODE';
    my $data = slurp($file);

    my ($ok, $ast, $err) = run_with_exit_trapped(sub { $parser->(\$data) });
    return (0, normalize_error($err)) unless $ok;
    return (0, 'undefined AST') unless defined $ast;
    return (0, 'unexpected AST ref type: ' . ref($ast))
        if $expected_ref && ref($ast) ne $expected_ref;

    return (1, '');
}

sub parse_with_lispish_multi {
    my ($file, $require_nonempty) = @_;
    state $lispish_parser = LinkedSpec::get_parser('Lispish');
    return (0, "unable to build parser for spec 'Lispish'") unless $lispish_parser && ref($lispish_parser) eq 'CODE';
    my $data = slurp($file);
    my @ast_list;
    my $iteration_count = 0;

    while (1) {
        my ($ok, $ast, $err) = run_with_exit_trapped(sub { $lispish_parser->(\$data) });
        return (0, normalize_error($err)) unless $ok;
        last unless defined $ast;

        push @ast_list, $ast;
        ++$iteration_count;
        if ($iteration_count > 100000) {
            return (0, 'iteration guard reached while parsing Lispish stream');
        }
    }

    return (0, 'empty AST list') if $require_nonempty && !@ast_list;

    return (1, '');
}

sub run_with_exit_trapped {
    my ($code) = @_;
    my ($ret, $err);

    my $ok = eval {
        local *CORE::GLOBAL::exit = sub { die "__EXIT__(" . (@_ ? $_[0] : 0) . ")" };
        $ret = $code->();
        1;
    };

    $err = $@ unless $ok;
    return ($ok ? 1 : 0, $ret, $err);
}

sub run_get_parser_with_captured_io {
    my ($spec_name, @opts) = @_;
    my ($ret, $err, $stdout, $stderr);
    $err = '';
    $stdout = '';
    $stderr = '';

    my $ok = eval {
        local *STDOUT;
        local *STDERR;
        open(STDOUT, '>', \$stdout) or die "Unable to capture STDOUT: $!";
        open(STDERR, '>', \$stderr) or die "Unable to capture STDERR: $!";
        $ret = LinkedSpec::get_parser($spec_name, @opts);
        1;
    };

    $err = $@ // '' unless $ok;
    return ($ok ? 1 : 0, $ret, $err, $stdout, $stderr);
}

sub run_get_parser_in_subprocess {
    my ($spec_name) = @_;
    my ($out, $err) = ('', '');
    my $err_fh = gensym();
    my $parser_marker = '__PARSER_DEFINED__';

    my $pid = open3(
        undef,
        my $out_fh,
        $err_fh,
        $^X,
        "-I$Bin/../perl",
        '-MLinkedSpec',
        '-e',
        "my \$s = shift; my \$p = LinkedSpec::get_parser(\$s); print defined(\$p) ? \"$parser_marker\\n\" : \"__PARSER_UNDEF__\\n\";",
        $spec_name,
    );

    $out .= $_ while <$out_fh>;
    $err .= $_ while <$err_fh>;
    waitpid($pid, 0);
    my $exit_code = $? >> 8;

    return ($exit_code, $out, $err);
}

sub run_parser_invocation_in_subprocess {
    my ($spec_name, $input_text) = @_;
    my ($out, $err) = ('', '');
    my $err_fh = gensym();

    my $pid = open3(
        undef,
        my $out_fh,
        $err_fh,
        $^X,
        "-I$Bin/../perl",
        '-MLinkedSpec',
        '-e',
        'my ($spec, $input) = @ARGV; my $p = LinkedSpec::get_parser($spec); die "__NO_PARSER__\n" unless $p; my $arg = ($input eq "__INPUT_ARRAYREF__") ? [] : $input; my $ast = $p->($arg); print defined($ast) ? "__AST_DEFINED__\n" : "__AST_UNDEF__\n";',
        $spec_name,
        $input_text,
    );

    $out .= $_ while <$out_fh>;
    $err .= $_ while <$err_fh>;
    waitpid($pid, 0);
    my $exit_code = $? >> 8;

    return ($exit_code, $out, $err);
}

sub run_perl_snippet_in_subprocess {
    my ($snippet, @args) = @_;
    my ($out, $err) = ('', '');
    my $err_fh = gensym();

    my $pid = open3(
        undef,
        my $out_fh,
        $err_fh,
        $^X,
        "-I$Bin/../perl",
        '-e',
        $snippet,
        @args,
    );

    $out .= $_ while <$out_fh>;
    $err .= $_ while <$err_fh>;
    waitpid($pid, 0);
    my $exit_code = $? >> 8;

    return ($exit_code, $out, $err);
}

sub run_parser_with_captured_io {
    my ($parser, $input_ref) = @_;
    my ($ret, $err, $stdout, $stderr, $inner_eval_err);
    $err = '';
    $stdout = '';
    $stderr = '';
    $inner_eval_err = '';

    my $ok = eval {
        local *STDOUT;
        local *STDERR;
        local *CORE::GLOBAL::exit = sub { die "__EXIT__(" . (@_ ? $_[0] : 0) . ")" };
        open(STDOUT, '>', \$stdout) or die "Unable to capture STDOUT: $!";
        open(STDERR, '>', \$stderr) or die "Unable to capture STDERR: $!";
        $ret = $parser->($input_ref);
        $inner_eval_err = $@ // '';
        1;
    };

    $err = $@ // '' unless $ok;
    return ($ok ? 1 : 0, $ret, $err, $stdout, $stderr, $inner_eval_err);
}
