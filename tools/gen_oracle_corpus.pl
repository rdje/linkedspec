#!/usr/bin/env perl
# RUST-PARITY.7.1 — Perl↔Rust output-oracle fixture generator.
#
# Purpose
#   Generate a *language-neutral* test corpus (ADR 0006 §Phase 8.6) under
#   `rust/linkedspec-runtime/tests/corpus/`. The Perl reference is the behavioral
#   oracle: for each (spec, input) case this tool runs the reference parser and
#   records its result as canonical JSON. A backend's fixture-runner then asserts
#   it reproduces the same value (modulo each backend's documented output-shape
#   rule — see "Output-shape rule" below).
#
# Corpus entry layout (one directory per case; matches the book's
# `appendix/backend-handoff.md` corpus contract):
#   rust/linkedspec-runtime/tests/corpus/<case>/
#     input.spec    — the .spec source (copied verbatim from specs/<spec>.spec)
#     input.txt     — the exact input bytes fed to the parser
#     expected.json — canonical JSON of the reference (Perl) top-rule value
#
# Output-shape rule (Perl↔Rust reconciliation)
#   The Perl reference returns the top rule's value DIRECTLY, e.g. tclite on "[]"
#   returns ["?tcl_script:",[["?command_subst:",[]]]]. The Rust engine wraps the
#   accumulator one level (engine.rs `execute()` returns Array(accumulator)), so
#   its output is [ <perl_value> ]. `expected.json` stores the *reference value*
#   (the canonical, backend-neutral form); each backend's runner applies its own
#   known mapping. The Rust runner (`tests/corpus_oracle.rs`) compares
#   engine.execute(input) == [ expected ].
#
# Safety
#   Every oracle parse runs under a hard `alarm(...)` timeout (default 15s,
#   override with ORACLE_TIMEOUT) so a pathological grammar — e.g. the known
#   RTLUtils catastrophic-backtrack hang — cannot wedge corpus generation.
#
# Usage
#   perl tools/gen_oracle_corpus.pl            # regenerate all cases
#   ORACLE_TIMEOUT=30 perl tools/gen_oracle_corpus.pl
#
# Determinism
#   JSON::PP->canonical(1) sorts object keys, so regenerating an unchanged case
#   yields byte-identical `expected.json` (no spurious git churn).

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec;
use File::Path qw(make_path);
use JSON::PP ();
use LinkedSpec;

my $REPO    = File::Spec->rel2abs( File::Spec->catdir( $Bin, File::Spec->updir ) );
my $SPECDIR = File::Spec->catdir( $REPO, 'specs' );
my $CORPUS  = File::Spec->catdir( $REPO, qw(rust linkedspec-runtime tests corpus) );
my $TIMEOUT = $ENV{ORACLE_TIMEOUT} // 15;

# Corpus cases. Each is a hashref:
#   { case => '<dir>', input => '<bytes>',
#     source => '<inline .spec>'   # authored grammar (embedded verbatim), OR
#     spec   => '<name>' }         # shipped spec, slurped from specs/<name>.spec
#
# .7.1 GREEN PROOF SET — controlled authored grammars in the Rust-supported
# subset (`::` rules, entry_text, declare/push_value/array_copy/return). They
# prove the full oracle loop end-to-end: Perl runs the grammar → canonical-JSON
# fixture → the Rust engine reproduces it under the one-level wrap rule.
#
# DEFERRED shipped specs (RUST-PARITY.7.5) — the oracle's findings. Kept OUT of
# the committed corpus until their engine gaps close, so `cargo test` stays green.
#
# RUST-PARITY.7.5.1 (header-line-regex fix, DONE) was a NECESSARY prerequisite —
# a regex on a rule's header line (`name : /re/`, or a `/open/ /close/` pair) was
# swallowed by the mode-suffix group and dropped, so the rule compiled as 0
# (pair: 1) regexes; now they register correctly. But it is NOT SUFFICIENT for
# tclite: the oracle proved a SECOND, independent blocker.
#
#   tclite (→ RUST-PARITY.7.5.3): accumulates via fluent continuations on ACTION
#   edges — `-> command_subst .push`, `-> command_subst[1] .return(...)`. The Rust
#   parser only attaches a `.method` fluent chain to a BLIND edge (`=>`); after a
#   `->` edge the `.push`/`.return(...)` becomes a standalone FluentChain element
#   the compiler discards, so the edges dispatch but never accumulate/return and
#   tclite still yields `[]`. Re-enable once .7.5.3 (action-edge fluent lowering)
#   lands.
#     { case => 'tclite_command_subst', spec => 'tclite', input => '[]' },
#     { case => 'tclite_double_quote',  spec => 'tclite', input => '""' },
#
#   Lispish (→ RUST-PARITY.7.5.2): uses `{ code }` blocks on its edges (not the
#   fluent form), so it only needs the `scalaref(retv, {content})` hashref-field
#   accessor parsed (expr.rs has no `{` case).
#     { case => 'lispish_x_y',          spec => 'Lispish', input => '(x y)' },
# See docs/knowledge/rust-perl-output-oracle.md.
# The proof grammars use the parent→child dispatch form (`Parent:: /re/ -> Child
# { ... }`) — a lone rule with top-level blocks returns 0 in the Perl reference
# (inline-spec lifecycle friction, noted in RUST-PARITY.5.2). The edge action
# returns a literal and the child rule is action-less, so every known
# divergence source is avoided: no retv (Perl-inline retv returns undef; Rust's
# works — they disagree), no capture-group indexing (Perl `group(0)`=first
# capture vs Rust `group(0)`=full match), no single-colon `name : /re/` rule
# (Rust compiles those as 0-regex), and no child `return` (Rust pushes a child
# return into the parent accumulator; Perl routes it to retv). On these, both
# backends agree exactly — the green proof of the oracle loop + the wrap rule.
my @CASES = (
    {   case   => 'proof_edge_array_literal',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { return(array("?proof:", "ok")) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'proof_edge_scalar_literal',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { return("scalar-ok") }

Done::
 /[a-z]+/
SPEC
    },
);

my $json = JSON::PP->new->canonical(1)->pretty(1);

my $written = 0;
for my $case (@CASES) {
    my $name  = $case->{case};
    my $input = $case->{input};

    my ( $spec_src, $parser );
    if ( defined $case->{source} ) {
        $spec_src = $case->{source};
        $parser   = LinkedSpec::Get( \$spec_src );
        die "Get(<inline $name>) did not return a CODE ref\n"
            unless ref $parser eq 'CODE';
    }
    else {
        my $spec = $case->{spec};
        $spec_src = slurp( File::Spec->catfile( $SPECDIR, "$spec.spec" ) );
        $parser   = LinkedSpec::get_parser($spec);
        die "get_parser('$spec') did not return a CODE ref\n"
            unless ref $parser eq 'CODE';
    }

    my $value = run_oracle( $parser, $name, $input, $TIMEOUT );

    my $dir = File::Spec->catdir( $CORPUS, $name );
    make_path($dir);
    spew( File::Spec->catfile( $dir, 'input.spec' ),    $spec_src );
    spew( File::Spec->catfile( $dir, 'input.txt' ),     $input );
    spew( File::Spec->catfile( $dir, 'expected.json' ), $json->encode($value) );

    printf "  wrote corpus/%s/ (input=%s)\n", $name, _show($input);
    $written++;
}
printf "Generated %d oracle fixture(s) into %s\n", $written, $CORPUS;

# Run a built reference parser coderef on one input under a hard timeout; return
# the decoded result structure (arrayref/hashref/scalar).
sub run_oracle {
    my ( $parser, $name, $input, $timeout ) = @_;

    my $result;
    my $ok = eval {
        local $SIG{ALRM} = sub { die "ORACLE_TIMEOUT after ${timeout}s\n" };
        alarm($timeout);
        $result = $parser->( \$input );
        alarm(0);
        1;
    };
    my $err = $@ // '';
    alarm(0);
    die "oracle parse failed for case='$name' input=" . _show($input) . ": $err"
        unless $ok;
    return $result;
}

sub slurp {
    my ($path) = @_;
    open my $fh, '<', $path or die "cannot read $path: $!\n";
    local $/;
    my $content = <$fh>;
    close $fh;
    return $content;
}

sub spew {
    my ( $path, $content ) = @_;
    open my $fh, '>', $path or die "cannot write $path: $!\n";
    print {$fh} $content;
    close $fh;
}

sub _show {
    my ($s) = @_;
    $s = '' unless defined $s;
    $s =~ s/\n/\\n/g;
    return qq{"$s"};
}
