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

