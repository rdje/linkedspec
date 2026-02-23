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
    plan tests => 5;

    require File::Temp;
    my $tmp_dir = File::Temp::tempdir(CLEANUP => 1);
    my $tmp_spec = File::Spec->catfile($tmp_dir, 'phase1_malformed_spec_validation.spec');
    my $malformed_spec = "this is not a valid LinkedSpec rule line\n";

    open(my $fh, '>', $tmp_spec) or die "Cannot create malformed spec '$tmp_spec': $!";
    print {$fh} $malformed_spec;
    close($fh);
    ok(-f $tmp_spec, 'temporary malformed spec created');

    my ($ok_call, $parser, $err_call, $out, $warn) = run_get_parser_with_captured_io($tmp_spec);

    ok($ok_call, 'malformed-spec get_parser call returns without die') or diag(normalize_error($err_call));
    ok(!defined($parser), 'malformed-spec get_parser returns undef');
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
subtest 'get_parser_mixed_action_blind_call_trapped_exit' => sub {
    plan tests => 6;

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

    is(defined($exit_code) ? $exit_code : '<undef>', '1', 'mixed-action/blind-call subprocess exit code is 1');
    like($combined, qr/Cannot mix ACTION \(\->\) and BLIND CALL \(\=\>\) code blocks/,
        'mixed-action/blind-call diagnostics report incompatible action types');
    like($combined, qr/Rule 'Top'/, 'mixed-action/blind-call diagnostics include rule label');
    like($combined, qr/Solution: Use either ACTION blocks OR BLIND CALL blocks, not both/,
        'mixed-action/blind-call diagnostics include remediation guidance');
    unlike($combined, qr/__PARSER_DEFINED__/, 'mixed-action/blind-call subprocess does not return parser-defined marker');

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
    my ($spec_name) = @_;
    my ($ret, $err, $stdout, $stderr);
    $err = '';
    $stdout = '';
    $stderr = '';

    my $ok = eval {
        local *STDOUT;
        local *STDERR;
        open(STDOUT, '>', \$stdout) or die "Unable to capture STDOUT: $!";
        open(STDERR, '>', \$stderr) or die "Unable to capture STDERR: $!";
        $ret = LinkedSpec::get_parser($spec_name);
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

