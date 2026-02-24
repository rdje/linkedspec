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
subtest 'action_rewriter_pipeline_helper_substitutions' => sub {
    plan tests => 10;

    my $label = 'Top';

    is(
        LinkedSpec::call_spec_handler_subst($label, 'call(Foo)'),
        '&{$$descr{spec}{Foo}{handler}}($descr, $STRING, $minfo)',
        'call() helper rewrite preserved'
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
        LinkedSpec::call_spec_handler_subst($label, 'CAPTURE_IF()'),
        qr/push \@Top, \$capt if \$capt/,
        'CAPTURE_IF() helper rewrite preserved'
    );
};
subtest 'action_rewriter_reports_unresolved_helpers_in_rule_meta' => sub {
    plan tests => 8;

    my $spec_content = <<'SPEC';
Top::&
 /a/ -> Top { call (Leaf); CAPTURE_IF (); return_a(Top) }

Leaf:
 /a/ -> Leaf { return_a(Leaf) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for unresolved-helper diagnostics check');
    ok(exists $descr->{spec}{Top}{meta}{action_rewriter}, 'Top rule exposes action_rewriter metadata');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{unresolved_helper_count}, 2, 'Top unresolved helper count captures unrewritten helper forms');
    ok(grep { $_ eq 'call' } @{$meta->{unresolved_helpers}}, 'Top unresolved helpers include call');
    ok(grep { $_ eq 'CAPTURE_IF' } @{$meta->{unresolved_helpers}}, 'Top unresolved helpers include CAPTURE_IF');
    is($meta->{unresolved_helper_hits}{call}, 1, 'Top call unresolved helper hit count is tracked');
    is($meta->{unresolved_helper_hits}{CAPTURE_IF}, 1, 'Top CAPTURE_IF unresolved helper hit count is tracked');
    is($descr->{spec}{Leaf}{meta}{action_rewriter}{unresolved_helper_count}, 0, 'Leaf rule has no unresolved helpers');
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

