#!/usr/bin/env bash
# Enforce ADR 0052: tracked repository-owned paths must survive checkout relocation.
# The scan is limited to tracked parent-repository text. The rgx gitlink, ignored
# build/package caches, binaries, and generated local artifacts are outside its scope.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/project_data_env.sh"
cd "$ROOT"

mapfile -d '' tracked_files < <(git ls-files -z -- . ':(exclude)rgx')

PORTABILITY_ROOT="$ROOT" perl - "${tracked_files[@]}" <<'PERL'
use strict;
use warnings;

my $root = $ENV{PORTABILITY_ROOT} // die "repo-root-path-portability: repository root is unavailable\n";

sub classify_violation {
    my ($path, $line) = @_;

    return 'current checkout identity' if index($line, $root) >= 0;

    my $lead = qr{(?:^|[\s'"`=(:,])};
    return 'Unix developer home'
        if $line =~ m{$lead/(?:Users|home)/[A-Za-z0-9._-]+(?:/|$)};
    return 'macOS private volume'
        if $line =~ m{$lead/(?:Volumes)/[A-Za-z0-9._-]+(?:/|$)};
    return 'macOS private session root'
        if $line =~ m{$lead/(?:private/)?var/(?:folders)/[A-Za-z0-9._-]+(?:/|$)};
    return 'legacy private workspace root'
        if $line =~ m{$lead/(?:vobs|dsync)/[A-Za-z0-9._-]+(?:/|$)};
    return 'Windows developer home or checkout'
        if $line =~ m{$lead[A-Za-z]:[\\/](?:Users|home)[\\/][A-Za-z0-9._-]+(?:[\\/]|$)};

    if ($path eq 'rust/linkedspec-runtime/src/primary_cli.rs' &&
            $line =~ /env!\s*\(\s*"CARGO_MANIFEST_DIR"\s*\)/) {
        return 'compile-time Rust primary-CLI root discovery';
    }

    return;
}

sub expect_rejected {
    my ($name, $path, $line) = @_;
    return if defined classify_violation($path, $line);
    die "repo-root-path-portability: self-test failed to reject $name\n";
}

sub expect_accepted {
    my ($name, $path, $line) = @_;
    my $reason = classify_violation($path, $line);
    return unless defined $reason;
    die "repo-root-path-portability: self-test rejected legal $name as $reason\n";
}

my $slash = '/';
expect_rejected('current-root mutation', 'README.md', "$root/specs/demo.spec");
expect_rejected('Unix-home mutation', 'conf/example.conf', $slash . 'home/alice/work/linkedspec');
expect_rejected('macOS-home mutation', 'conf/example.conf', $slash . 'Users/alice/work/linkedspec');
expect_rejected('macOS-volume mutation', 'conf/example.conf', $slash . 'Volumes/Work/linkedspec');
expect_rejected('private-session mutation', 'docs/example.md',
    $slash . 'private/var/folders/aa/session/T/linkedspec');
expect_rejected('Windows-home/checkout mutation', 'conf/example.conf',
    'C:' . '\\Users\\alice\\Documents\\github\\linkedspec\\specs');
expect_rejected('compile-time-root mutation', 'rust/linkedspec-runtime/src/primary_cli.rs',
    'let root = env!("CARGO_MANIFEST_DIR");');

expect_accepted('repo-relative path', 'README.md', 'specs/Lispish.spec');
expect_accepted('repository URL', 'README.md', 'https://github.com/example/linkedspec');
expect_accepted('/usr tool', 'conf/example.conf', '/usr/bin/env perl');
expect_accepted('/opt tool', 'docs/example.md', '/opt/homebrew/bin/julia');
expect_accepted('caller /tmp path', 'docs/example.md', '/tmp/linkedspec-caller-work');
expect_accepted('neutral Windows fixture', 't/example.t', 'C:/Demo/input.spec');
expect_accepted('path-denial needle', 't/example.t', '/Users/');

my @violations;
for my $path (@ARGV) {
    next if -l $path;
    next unless -f $path;
    open my $fh, '<:raw', $path
        or die "repo-root-path-portability: cannot read tracked file $path: $!\n";
    local $/;
    my $content = <$fh>;
    close $fh or die "repo-root-path-portability: cannot close tracked file $path: $!\n";
    next if !defined($content) || index($content, "\0") >= 0;

    my $line_number = 0;
    for my $line (split /\n/, $content, -1) {
        ++$line_number;
        my $reason = classify_violation($path, $line);
        push @violations, "$path:$line_number: $reason: $line" if defined $reason;
    }
}

if (@violations) {
    print STDERR "repo-root-path-portability: tracked parent-repository text is not relocation-safe\n";
    print STDERR "repo-root-path-portability: use repo-relative operands or derive the current root at runtime\n";
    print STDERR "$_\n" for @violations;
    exit 1;
}
PERL

fail=0
note() {
  printf 'repo-root-path-portability: missing primary-command runtime anchor: %s\n' "$1" >&2
  fail=1
}

require_literal() {
  local file="$1"
  local literal="$2"
  local label="$3"
  grep -Fq -- "$literal" "$file" || note "$label ($file)"
}

require_literal bin/linkedspec 'use FindBin;' 'Perl FindBin module anchor'
require_literal bin/linkedspec 'use lib "$FindBin::Bin/../perl";' 'Perl script-relative library anchor'

require_literal rust/linkedspec-runtime/src/primary_cli.rs 'std::env::current_exe().ok()' \
  'Rust current-executable anchor'
require_literal rust/linkedspec-runtime/src/primary_cli.rs '.and_then(find_repository_root)' \
  'Rust executable-ancestry discovery'
require_literal rust/linkedspec-runtime/src/primary_cli.rs '.or_else(|| find_repository_root(cwd))' \
  'Rust cwd-ancestry fallback'
require_literal rust/linkedspec-runtime/src/primary_cli.rs \
  'const REPOSITORY_MARKER: &str = "specs/user_function_definition.spec";' \
  'Rust checked-in marker anchor'

require_literal dart/lib/src/cli/primary_cli.dart 'Directory.current.absolute' \
  'Dart cwd anchor'
require_literal dart/lib/src/cli/primary_cli.dart "Platform.script.scheme == 'file'" \
  'Dart script-location anchor'
require_literal dart/lib/src/cli/primary_cli.dart '_findRepositoryRoot()' \
  'Dart repository-root ascent'

require_literal julia/src/cli/LinkedSpecJuliaCli.jl \
  '_primary_cli_repo_root() = normpath(joinpath(@__DIR__, "..", "..", ".."))' \
  'Julia module-location anchor'

require_literal lua/bin/linkedspec-lua 'debug.getinfo(1, "S").source' \
  'Lua script-location anchor'
require_literal lua/bin/linkedspec-lua 'local repo_root = lua_root:match("^(.*)[/\\]lua$")' \
  'Lua repository-root derivation'

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

printf 'repo-root-path-portability: OK (tracked parent text; 14 classifier cases; 5 primary anchors)\n'
