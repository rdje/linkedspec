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
    plan tests => 10;

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
        LinkedSpec::call_spec_handler_subst('Top', 'return(array_values(array(items)))'),
        'return [@items]',
        'return(payload) lowers array_values(array(...)) to a snapshot array payload'
    );
    is(
        LinkedSpec::call_spec_handler_subst('Top', 'return({name=>scalar(block_namei), content=>array_values(array(assigns))})'),
        'return {name=>$block_namei, content=>[@assigns]}',
        'return(payload) lowers array_values(array(...)) inside structured hash payloads'
    );

    my $spec_content = <<'SPEC';
Top:: I.declare(array, items).declare(scalar, retv).assign(array(items), array(scalar(retv))).return(array_values(array(items)))
 /a/ -> Top { return_a(Top) }
SPEC

    my $descr = LinkedSpec::Get(\$spec_content, return_descr => 1);
    ok(defined($descr) && ref($descr) eq 'HASH', 'descriptor build succeeds for array snapshot/assign method contracts');

    my $meta = $descr->{spec}{Top}{meta}{action_rewriter};
    is($meta->{canonical_action_ir_fallback_count}, 0, 'array snapshot/assign method contracts avoid RAW_PERL fallback');
    is($meta->{unresolved_helper_count}, 0, 'array snapshot/assign method contracts avoid unresolved-helper hits');
    ok(
        scalar(grep { $_ eq 'DECLARE' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'ASSIGN' } @{$meta->{canonical_action_ir_nodes}}) &&
        scalar(grep { $_ eq 'RETURN' } @{$meta->{canonical_action_ir_nodes}}),
        'canonical action-IR nodes include DECLARE/ASSIGN/RETURN for array snapshot/assign contracts'
    );
    ok($meta->{language_agnostic_action_ir_ready}, 'array snapshot/assign method contracts remain language-agnostic action-IR ready');
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
    like($out, qr/\[[A-Z]+\]\[LinkedSpec\.pm\]\[[^\]]+:\d+\]/, 'trace includes level + file + function:line metadata');
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

