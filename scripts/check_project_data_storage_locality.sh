#!/usr/bin/env bash
# Enforce ADR 0053: project-owned storage defaults and documented output commands
# must remain on the filesystem containing the current repository.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$ROOT/scripts/check_project_data_storage_locality.sh" "$@"
cd "$ROOT"

mapfile -d '' tracked_files < <(git ls-files -z -- . ':(exclude)rgx')

PROJECT_DATA_POLICY_ROOT="$ROOT" perl - "${tracked_files[@]}" <<'PERL'
use strict;
use warnings;

my $current_root = $ENV{PROJECT_DATA_POLICY_ROOT}
    // die "project-data-storage-locality: repository root is unavailable\n";

sub governed_line {
    my ($path, $line) = @_;

    return 1 if $path eq 'README.md' || $path eq 'TOOLBOX.md';
    return 1 if $path =~ m{^docs/linkedspec-book/src/.*[.]md$};
    return $line =~ /^reverify:/ if $path =~ m{^docs/knowledge/.*[.]md$};
    return 1 if $path =~ m{^(?:[.]githooks|bin|cli_conformance|conf|dart|julia|knowledge-map|lua|perl|rust|scripts|specs|t|tools)/};
    return 0;
}

sub classify_violation {
    my ($path, $line) = @_;
    return unless governed_line($path, $line);

    # These declarations are the checker's mutation-sensitive fixture corpus;
    # expect_rejected/expect_accepted pass their reconstructed values back
    # through this function directly below.
    return if $path eq 'scripts/check_project_data_storage_locality.sh'
        && $line =~ /^expect_(?:rejected|accepted)\(/;

    if ($path !~ /[.]md$/ && $line =~ /^\s*(?:#|\/\/|--\s)/) {
        return;
    }

    my $slash = chr 47;
    my $unsafe_unix = qr{
        (?<![A-Za-z0-9_\x7d])\Q$slash\E(?:private\Q$slash\E)?tmp(?:\Q$slash\E|\b)
        |(?<![A-Za-z0-9_\x7d])\Q$slash\E(?:private\Q$slash\E)?var\Q$slash\Efolders(?:\Q$slash\E|\b)
        |(?<![A-Za-z0-9_\x7d])\Q$slash\E(?:Users|home)\Q$slash\E[A-Za-z0-9._-]+(?:\Q$slash\E|\b)
        |(?<![A-Za-z0-9_\x7d])\Q$slash\EVolumes\Q$slash\E[A-Za-z0-9._-]+(?:\Q$slash\E|\b)
    }x;
    my $unsafe_windows = qr{[A-Za-z]:[\\/](?:Users|home)[\\/][A-Za-z0-9._-]+(?:[\\/]|\b)};
    my $unsafe = qr{(?:$unsafe_unix|$unsafe_windows|\Q$current_root\E(?:\Q$slash\E|\b))};
    my $storage_variable = qr{
        (?:TMPDIR|TMP|TEMP|CARGO_HOME|CARGO_TARGET_DIR|PUB_CACHE|JULIA_DEPOT_PATH|
           LINKEDSPEC_JULIA_DEPOT_PATH|PYTHONPYCACHEPREFIX|KM_OUTPUT|MDBOOK_BUILD__BUILD_DIR)
    }x;
    my $storage_name = qr{
        (?:[A-Za-z][A-Za-z0-9]*_)*
        (?:tmp|temp|cache|depot|target|build|output|artifact|workspace|log|trace|tap|socket)
        (?:_[A-Za-z0-9]+)*
    }ix;

    return 'off-repository storage environment assignment'
        if $line =~ /\b$storage_variable\s*=\s*[^#\n]*$unsafe/;

    return 'operating-system temporary fallback'
        if $line =~ /\$\{(?:TMPDIR|TMP|TEMP):-[^}]*$unsafe[^}]*\}/;

    return 'developer-home package/cache default'
        if $line =~ /(?:\$\{?HOME\}?|~|home_dir|homedir|expanduser)/i
            && $line =~ /[.](?:cargo|julia|pub-cache|cache)(?:\b|\Q$slash\E)/i
            && $line =~ /(?:=|default|fallback|join|cat(?:dir|file)?)/i;

    return 'off-repository named storage assignment'
        if $line =~ /(?:\$|\b)$storage_name\s*(?:=|=>|:)\s*[^#\n]*$unsafe/;

    return 'off-repository documented output destination'
        if $line =~ /(?:(?<![-=])>{1,2}\s*|--(?:output|output-dir|dest|dest-dir|target-dir|cache|cache-dir|depot|build-dir|trace|trace-file|log|log-file)\s+)[^#\n]*$unsafe/;

    return 'off-repository Toolbox artifact path'
        if $path eq 'TOOLBOX.md' && $line =~ /$unsafe/;

    return 'off-repository documented artifact path'
        if $path =~ /[.]md$/
            && $line !~ /\binert\b/i
            && $line =~ /\b(?:write|output|capture|dump|extract|save|store|redirect)[A-Za-z]*\b[^#\n]*$unsafe/i;

    return 'off-repository temporary allocator template'
        if $line =~ /\bmktemp\b[^#\n]*$unsafe/;

    return 'off-repository active config destination'
        if $line =~ /^\s*(?!#)(?=[^#\n]*(?:cache[-_.]?dir|temp[-_.]?dir|socket|log[-_.]?file|trace[-_.]?file|output[-_.]?dir))[^#\n]*$unsafe/i;

    if ($line =~ /\$\{($storage_variable):-([^}]*)\}/) {
        my $fallback = $2;
        return if $fallback eq '';
        return 'unrooted storage fallback'
            unless $fallback =~ /\$(?:\{)?(?:LINKEDSPEC_[A-Z0-9_]+|REPO_ROOT|ROOT|TMPDIR|TMP|TEMP|$storage_variable)(?:\}|\b)/;
    }

    return;
}

sub expect_rejected {
    my ($name, $path, $line) = @_;
    return if defined classify_violation($path, $line);
    die "project-data-storage-locality: self-test failed to reject $name\n";
}

sub expect_accepted {
    my ($name, $path, $line) = @_;
    my $reason = classify_violation($path, $line);
    return unless defined $reason;
    die "project-data-storage-locality: self-test rejected legal $name as $reason\n";
}

my $slash = chr 47;
expect_rejected('internal-temp environment', 'tools/example.sh', 'TMPDIR=' . $slash . 'private/tmp/linkedspec');
expect_rejected('OS-temp fallback', 'tools/example.sh', '${TMPDIR:-' . $slash . 'tmp}/linkedspec');
expect_rejected('developer-home Cargo cache', 'tools/example.sh', 'CARGO_HOME="$HOME' . $slash . '.cargo"');
expect_rejected('unrooted package cache', 'tools/example.sh', 'PUB_CACHE="${PUB_CACHE:-dart-cache}"');
expect_rejected('documented TAP redirection', 'TOOLBOX.md', 'prove t/example.t > ' . $slash . 'tmp/result.tap');
expect_rejected('documented book destination', 'README.md', 'mdbook build --dest-dir ' . $slash . 'tmp/book');
expect_rejected('absolute trace destination', 'perl/example.pm', 'trace_log = "' . $slash . 'Users/alice/log"');
expect_rejected('absolute Windows build destination', 'tools/example.ps1', 'build_root = "C:\\Users\\alice\\build"');
expect_rejected('persisted current checkout', 'tools/example.sh', 'CARGO_HOME="' . $current_root . '/cache"');
expect_rejected('temporary allocator template', 'tools/example.sh', 'mktemp -d ' . $slash . 'tmp/example.XXXXXX');
expect_rejected('active cache config', 'conf/example.conf', 'cache-dir = "' . $slash . 'tmp/cache"');

expect_accepted('repository-derived temp', 'tools/example.sh', 'TMPDIR="$LINKEDSPEC_SCRATCH_ROOT/tmp"');
expect_accepted('repository-derived Cargo fallback', 'tools/example.sh', 'CARGO_TARGET_DIR="${CARGO_TARGET_DIR:-$REPO_ROOT/rust/target}"');
expect_accepted('root-relative operand', 'README.md', 'perl bin/linkedspec specs/Lispish.spec input.txt');
expect_accepted('explicit caller input', 'README.md', 'perl bin/linkedspec ' . $slash . 'tmp/input.spec');
expect_accepted('inert logical path', 't/example.t', 'logical_name = "' . $slash . 'tmp/private.spec"');
expect_accepted('external executable', 'TOOLBOX.md', $slash . 'opt/homebrew/bin/julia --version');
expect_accepted('system library', 'README.md', $slash . 'usr/lib/libpcre2.dylib');
expect_accepted('hostile-root read', 'tools/test_example.sh', 'for candidate in ' . $slash . 'private/tmp ' . $slash . 'tmp "$HOME"');
expect_accepted('commented legacy config', 'conf/example.conf', '# cache-dir = "' . $slash . 'tmp/cache"');
expect_accepted('historical fact evidence', 'docs/knowledge/example.md', 'evidence: "old cache was ' . $slash . 'tmp/cache"');
expect_accepted('caller Windows path', 'README.md', 'linkedspec C:/Demo/input.spec');

my @violations;
my %governed_files;
my $governed_lines = 0;
for my $path (@ARGV) {
    next if -l $path;
    next unless -f $path;
    open my $fh, '<:raw', $path
        or die "project-data-storage-locality: cannot read tracked file $path: $!\n";
    local $/;
    my $content = <$fh>;
    close $fh or die "project-data-storage-locality: cannot close tracked file $path: $!\n";
    next if !defined($content) || index($content, "\0") >= 0;

    my $line_number = 0;
    for my $line (split /\n/, $content, -1) {
        ++$line_number;
        next unless governed_line($path, $line);
        $governed_files{$path} = 1;
        ++$governed_lines;
        my $reason = classify_violation($path, $line);
        push @violations, "$path:$line_number: $reason: $line" if defined $reason;
    }
}

if (@violations) {
    print STDERR "project-data-storage-locality: project storage is not repository-filesystem rooted\n";
    print STDERR "project-data-storage-locality: derive outputs from the current repo or use an explicit caller input\n";
    print STDERR "$_\n" for @violations;
    exit 1;
}

printf "project-data-storage-locality: OK (%d governed files; %d lines; 22 classifier cases)\n",
    scalar(keys %governed_files), $governed_lines;
PERL
