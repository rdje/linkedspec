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
#   override with ORACLE_TIMEOUT) so a pathological grammar with catastrophic
#   regex backtracking cannot wedge corpus generation.
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
# tclite: the oracle proved additional independent blockers beyond header-line regexes.
#
#   tclite: SPEC-FORMAT-TERSE.2.3.3.3.3.1 closed the Rust gap exposed by the
#   shipped `[]` and `""` probes: bare default rules now repeat as zero-min
#   choice loops, and a child rule whose I-block returns exits before re-matching
#   the entry regex. The two minimal tclite fixtures below are active shipped-spec
#   coverage for that parity.
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
    # ── SPEC-FORMAT-TERSE.1.1.2 — auto-existing working variables (cross-variant) ──
    #
    # The Perl reference (.1.1.1, ADR 0007) lets a working variable referenced
    # through a typed wrapper -- scalar(NAME)/array(NAME) -- be used WITHOUT a
    # prior declare(...). These cases prove the Rust backend reproduces that
    # behavior under the universal-contract obligation (ADR 0006): each grammar
    # uses a working variable with NO declare in the divergence-free edge-action
    # form (the .7.1 proof class -- non-recursive `Parent:: /re/ -> Child { ... }`,
    # value set by the edge's own `return(...)`, action-less child), so Perl and
    # Rust agree exactly (modulo the one-level accumulator wrap). The `*_declare`
    # twins show declare-form output is unchanged; `undef_literal` guards that the
    # `undef` LITERAL inside array(undef) is not mistaken for a variable.
    # The recursive/REP auto-exist idiom the Perl phase0 locks use does NOT yet
    # reproduce on Rust -- that is the separately-owned RUST-PARITY recursive-grammar
    # gap, NOT auto-existence (see docs/knowledge/working-vars-no-strict-need-my-lexical.md).
    {   case   => 'autoexist_scalar_no_declare',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { assign(scalar(v), "ok"); return(scalar(v)) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'autoexist_scalar_declare',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { declare(scalar, v); assign(scalar(v), "ok"); return(scalar(v)) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'autoexist_array_no_declare',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { push_value(array(items), "a"); push_value(array(items), "b"); return(array_copy(array(items))) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'autoexist_array_declare',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { declare(array, items); push_value(array(items), "a"); push_value(array(items), "b"); return(array_copy(array(items))) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'autoexist_undef_literal',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { return(array(undef)) }

Done::
 /[a-z]+/
SPEC
    },
    # SPEC-FORMAT-TERSE.1.2.1 Channel 1 (Rust parity = .1.2.2): a BARE (un-wrapped)
    # working var in a type-implying arg position auto-exists with the position-implied
    # kind -- the assign(...) target is a scalar, the push_value(...) target is an array.
    # Same divergence-free proof class as the wrapped autoexist_* cases above (the bare
    # target is the only difference), so the Rust backend must produce the identical
    # reference value. The value is read back through a wrapper (scalar(v)/array(items)) --
    # bare value-position reads are Channel 2, not this leaf.
    {   case   => 'autoexist_scalar_bare_arg',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { assign(v, "ok"); return(scalar(v)) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'autoexist_array_bare_arg',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { push_value(items, "a"); push_value(items, "b"); return(array_copy(array(items))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.2.3.2 — Rust parity for aggregate bare value reads ──
    #
    # These fixtures freeze the Perl reference values after .1.2.3.1 made aggregate
    # bare value reads safe on the reference backend. Rust must resolve these bare
    # snapshot forms to the same named aggregate variables without broadening scalar
    # bare value reads or bare direct-access path atoms.
    {   case   => 'terse_1_2_3_2_array_copy_bare_read',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { push_value(items, "a"); push_value(items, "b"); return(array_copy(items)) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_2_3_2_hash_copy_bare_read',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set_key(meta, "stage", "v"); return(hash_copy(meta)) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_2_3_2_copy_bare_array_first',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { push_value(items, "a"); return(copy(items)) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_2_3_2_copy_wrapped_hash',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set_key(meta, "stage", "v"); return(copy(hash(meta))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.2.3.4 — Rust parity for scalar bare value reads ──
    #
    # These fixtures freeze the Perl reference values after `.1.2.3.3` closed the
    # accepted scalar bare-read seams: return/assignment source slots, mutation
    # key/RHS slots, and direct-access bare path atoms. They intentionally do not
    # claim RHS-shape inference or all-bare `push(...)` changes.
    {   case   => 'terse_1_2_3_4_return_bare_scalar',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "ok"); return(value) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_2_3_4_assignment_source_bare_reads',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "ok"); set(out, value); name = value; return(array(scalar(out), scalar(name))) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_2_3_4_mutation_direct_bare_reads',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "payload"); set(key, "stage"); set(idx, 1); set(foo, hash("a", array("zero", "one"))); items += value; set_key(meta, key, value); meta[key] = value; return(array(array_copy(array(items)), hash_copy(hash(meta)), foo["a"][idx])) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.2.3.5.3 — Rust shape-literal value parity ──
    #
    # These fixtures freeze the Perl `.1.2.3.5.1` value-expression contract for
    # direct `[]` / `{}` shapes. They deliberately avoid `.1.2.3.5.2` bare-target
    # inference, which Rust owns separately under `.1.2.3.5.4`.
    {   case   => 'terse_1_2_3_5_3_shape_literal_return_values',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); return(array([value, cat("a", "b"), true, []], { key => value, "fixed" => [value] })) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_2_3_5_3_shape_literal_mutation_rhs',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "payload"); set(key, "stage"); items += [value]; meta[key] = { key => value }; return(array(array_copy(array(items)), hash_copy(hash(meta)))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.2.3.5.4 — Rust RHS shape target-kind parity ──
    #
    # These fixtures freeze the Perl `.1.2.3.5.2` target-kind inference
    # contract: direct shape RHS values infer aggregate bare targets, while
    # explicit scalar targets keep scalar-held shape payloads.
    {   case   => 'terse_1_2_3_5_4_shape_rhs_infers_bare_targets',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); items = [value]; items += "tail"; meta = { key => value }; meta["fixed"] = "yes"; return(array(array_copy(array(items)), hash_copy(hash(meta)), scalar(items), scalar(meta))) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_2_3_5_4_shape_rhs_scalar_boundary',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); set(items, [value]); assign(meta, { key => value }); set(scalar(payload), [value]); return(array(array_copy(array(items)), hash_copy(hash(meta)), scalar(payload), array_copy(array(payload)))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.4.2 — Rust lockstep parity for .1.4.1 helper renames ──
    #
    # These fixtures freeze the Perl reference values for the new canonical terse
    # spellings that .1.4.1 taught the book: set (assign), cat (concat), and copy
    # (array/hash copy). They stay in the same divergence-free proof class as the
    # earlier authored cases: non-recursive parent edge, action-less child, no retv.
    {   case   => 'terse_1_4_2_set_cat_copy_array',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(scalar(label), cat("a", "b")); push_value(array(items), scalar(label)); return(copy(array(items))) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_4_2_copy_hash_symbol_empty',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { return(copy(h(m))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.3.2 — explicit array append terse spelling ──
    #
    # `push(target, value)` is the terse explicit-value append spelling when the
    # value shape is unambiguous; all-bare child-call forms keep `push(Rule,target)`
    # precedence on the Perl reference.
    {   case   => 'terse_1_3_2_push_alias_array',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(label, "b"); push(items, "a"); push(items, scalar(label)); return(array_copy(array(items))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.3.3 — hash mutation statement spelling ──
    #
    # `set_key(target, key, value)` is a top-level mutation statement when the
    # first argument names a hash target. The pure hash-valued
    # `set_key(hash_expr, key, value)` helper remains a value expression.
    {   case   => 'terse_1_3_3_set_key_statement_hash',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set_key(meta, "stage", cat("a", "b")); return(hash_copy(hash(meta))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.3.4.1 — scalar assignment operator spelling ──
    #
    # `name = value` is the statement-level scalar assignment operator. It is
    # equivalent to `set(name, value)` / `assign(name, value)` and does not imply
    # array append, hash-index assignment, or bare value-position reads.
    {   case   => 'terse_1_3_4_1_scalar_assignment_operator',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { name = cat("o", "k"); return(scalar(name)) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.3.4.2 — array append operator spelling ──
    #
    # `items += value` was introduced as the statement-level array append operator
    # for explicit RHS shapes. Bare RHS variable reads landed later under
    # SPEC-FORMAT-TERSE.1.2.3.4.
    {   case   => 'terse_1_3_4_2_array_append_operator',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { label = "b"; items += "a"; items += scalar(label); return(array_copy(array(items))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.3.4.3 — hash-index assignment operator spelling ──
    #
    # `name[key] = value` was introduced as the statement-level hash-index
    # assignment operator for explicit key/RHS shapes. Bare key and RHS variable
    # reads landed later under SPEC-FORMAT-TERSE.1.2.3.4.
    {   case   => 'terse_1_3_4_3_hash_index_assignment_operator',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { meta[cat("s", "tage")] = cat("a", "b"); return(hash_copy(hash(meta))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.5.2 — primitive literal parity ──
    #
    # Primitive literals are explicit typed value expressions across return
    # payloads, mutation RHS positions, and flow conditions. In particular,
    # true/false must be JSON booleans, not the strings "true"/"false".
    {   case   => 'terse_1_5_2_primitive_literals',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { return(array(true, false, "s", 42, 3.14, undef)) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_5_2_boolean_mutation_flow',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { flag = true; items += false; push(items, true); meta["enabled"] = true; if(false); return("bad"); else(); return(array(scalar(flag), array_copy(array(items)), hash_copy(hash(meta)))); endif() }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.5.3 — call-spacing locks ──
    #
    # Whitespace before the opening parenthesis is accepted at supported call
    # sites, but the call still keeps its mandatory `callee(args)` shape.
    {   case   => 'terse_1_5_3_call_spacing',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set (name, cat ("a", "b")); items += cat ("c", "d"); meta[cat ("s", "tage")] = scalar (name); return (array(scalar (name), array_copy (array (items)), hash_copy (hash (meta)))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.5.4 — statement separator contract ──
    #
    # Newline-separated top-level DSL statements are canonical and lower to
    # valid generated Perl/Rust execution. Same-line adjacency keeps requiring
    # semicolons; this fixture locks the implicit-newline form.
    {   case   => 'terse_1_5_4_newline_statements',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(name,"a")
 return(scalar(name)) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.1.5.5.1 — direct nested access with explicit segments ──
    #
    # Direct mixed hash/array access is canonical when every segment is explicit.
    # Bare path atoms such as `[z]` remain Channel 2 work; this fixture uses
    # `scalar(z)` for the final index.
    {   case   => 'terse_1_5_5_1_direct_nested_access',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(foo, hash("a", array(hash("b", array("zero","one")))))
 set(z,1)
 return(foo["a"][0]["b"][scalar(z)]) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.6 — array end-mutation methods ──
    #
    # Receiver-dot array methods are statement-level ActionIR mutations over
    # named working arrays. Push methods consume one value argument; pop methods
    # mutate and discard the removed value in statement position.
    {   case   => 'terse_1_6_array_end_mutation_methods',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "b"); items.push_back("a"); items.push_back(value); items.push_front("z"); items.pop_back(); items.pop_front(); return(array_copy(items)) }

Done::
/[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.2.1.3 — Rust expression-valued block parity ──
    #
    # Non-empty non-hash braces are value blocks whose value is the final
    # expression, while a final return(expr) is block-local for the core subset.
    {   case   => 'terse_2_1_3_expression_valued_blocks',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { return(array({ set(x, "a"); x }, { set(y, "b"); return(y) }, { set(key, "stage"); set(value, "ok"); { key => value } })) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.2.1.4 — expression-valued block early return ──
    #
    # A return(expr) inside a value block exits only that block and skips later
    # block statements; the surrounding rule-level return remains explicit.
    {   case   => 'terse_2_1_4_expression_valued_block_early_return',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { return(array({ return("a"); "b" }, { set(x, "c"); return({ "k" => x }); "bad" })) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.2.2.3 — Rust attached-block if parity ──
    #
    # Attached if/elseif/else branch blocks are a terse statement spelling for
    # the same control markers the Rust runtime already executes.
    {   case   => 'terse_2_2_3_attached_if_blocks',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { if(false) { return("bad") } elseif(true) { return("yes") } else { return("no") } }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.2.2.4 — when/otherwise conditional aliases ──
    #
    # Attached when/otherwise branch blocks are aliases for the same canonical
    # if/else/endif marker flow as attached if/else.
    {   case   => 'terse_2_2_4_when_otherwise_aliases',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { when(false) { return("bad") } otherwise { return("yes") } }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.2.2.5.2 — Rust attached-block switch parity ──
    #
    # Attached switch/case/default branch blocks are a terse statement spelling
    # for first-match/default control flow. This fixture freezes the Perl
    # reference value for a later-case match. The switch subject uses the
    # explicit scalar wrapper so this case locks branch selection, not the
    # separate bare-read boundary.
    {   case   => 'terse_2_2_5_2_attached_switch_blocks',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(kind, "b"); switch(scalar(kind)) { case("a") { return("bad") } case("b") { return("later") } default { return("default") } } }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.2.2.6.2 — Rust attached-block while parity ──
    #
    # Attached while blocks execute their body while the condition is true,
    # re-evaluating the condition after body mutation. The deterministic
    # non-termination safety guard is locked by focused integration tests rather
    # than this finite oracle fixture.
    {   case   => 'terse_2_2_6_2_attached_while_blocks',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(count, 0); while(num_lt(scalar(count), 3)) { set(count, num_add(scalar(count), 1)) }; return(count) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.2.3.4 — deep pure-helper composition audit ──
    #
    # The supported "function in any argument position at any depth" subset is
    # pure value-helper composition. Hash working variables are initialized with
    # mutation statements, then the return expression composes value-helper
    # layers without a raw host-language fallback. This fixture preserves the
    # explicit `hash(...)` wrapper from the audit lock; SPEC-FORMAT-TERSE.2.3.4.1
    # below locks the now-supported bare aggregate helper argument forms separately.
    {   case   => 'terse_2_3_4_deep_pure_helper_composition',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set_key(base, "b", 2); set_key(base, "a", 1); set_key(overlay, "c", 3); return(count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay)))))) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.2.3.4.1 — Rust helper-context aggregate bare reads ──
    #
    # Hash-consuming and array-consuming helper argument slots may use a bare
    # working variable name where the callee contract implies that aggregate
    # value. This is deliberately narrower than global bare-variable evaluation:
    # ordinary `Expr::Variable` still reads scalar state, while helper-specific
    # aggregate slots snapshot hashes or arrays only where their contract says so.
    {   case   => 'terse_2_3_4_1_bare_hash_helper_arg_composition',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set_key(base, "b", 2); set_key(base, "a", 1); set_key(overlay, "c", 3); return(count(drop_front(sorted_keys(merge_hash(hash_copy(base), overlay))))) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_2_3_4_1_bare_array_helper_arg_composition',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { items += "b"; items += "a"; return(count(drop_front(sorted(items)))) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.2.3.4.2 — inline value-control parity ──
    #
    # Inline-composite if(...) and switch(...) are value expressions in supported
    # value-consuming slots. These fixtures freeze the returned payload values
    # only; tag strings from fluent/action-edge compatibility output are not part
    # of the asserted contract.
    {   case   => 'terse_2_3_4_2_inline_if_value_control',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(flag, "go"); return(array(if(is_nonempty(flag), cat("y", "es"), else("no")), if(false, "bad", "fallback"), if(true, { set(block, "branch"); return(block) }, else("bad")))) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_2_3_4_2_inline_switch_value_control',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(kind, "b"); set(out, switch(kind, case("a", "bad"), case("b", cat("y", "es")), default("no"))); return(out) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.2.3.5.1 — array receiver-dot value chains ──
    #
    # Receiver-dot array value methods are pure helper composition: each call
    # returns the documented value and feeds that value into the next compatible
    # array helper. Boolean terminals are covered by focused backend tests; this
    # oracle fixture uses array/scalar/number terminals whose JSON shape is
    # already identical across the Perl reference and Rust runtime.
    {   case   => 'terse_2_3_5_1_array_receiver_value_chains',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { items += "b"; items += "a"; items += "c"; items += "a"; phrases += "aa-b"; phrases += "c-aa"; return(array(items.sorted().drop_front(2).first(), array(items).reversed().take(2).last(), items.sorted().index_of("c"), items.drop_back().join_values("|"), items.uniq().join_values(","), items.filter_match(/^a$/).count(), phrases.split_each("-").filter_match(/^aa$/).count())) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.2.3.5.2 — hash receiver-dot value chains ──
    #
    # Receiver-dot hash value methods are pure helper composition over the
    # existing hash helper family. Hash-returning links feed later hash helpers;
    # sorted key/value terminals can continue through the already-landed array
    # receiver helper family. Boolean terminals are covered by focused backend
    # tests; this oracle fixture keeps scalar/number/string values for direct
    # Perl/Rust JSON parity.
    {   case   => 'terse_2_3_5_2_hash_receiver_value_chains',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set_key(meta, "b", 2); set_key(meta, "a", 1); set_key(extra, "a", 9); set_key(extra, "c", 3); return(array(meta.set_key("c", 3).sorted_keys().join_values(","), meta.merge_hash(hash(extra)).scalaref("a"), hash(meta).rename_key("a", "aa").drop_keys("b").set_key("z", 4).count_keys(), meta.pick_keys("missing").count_keys(), meta.sorted_values().drop_front(1).first(), meta.hash_copy().flat_hash().count_keys(), missing.hash_copy().count_keys())) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.2.3.5.3 — string receiver-dot value chains ──
    #
    # Receiver-dot string value methods are pure helper composition over the
    # existing string/scalar helper family. split(...) is the explicit bridge
    # into the already-landed array receiver family. Boolean terminals are
    # covered by focused backend tests; this oracle fixture keeps string/number
    # values for direct Perl/Rust JSON parity.
    {   case   => 'terse_2_3_5_3_string_receiver_value_chains',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(raw, " Node-Name_end "); return(array(raw.trim().lowercase().replace_substr("-", "_").rm_prefix("node_").rm_suffix("_end").cat("!"), raw.trim().length(), raw.trim().split("-").trim_each().lowercase_each().join_values("|"), " a-b ".trim().split("-").count(), "abcdef".substr(1, 3).uppercase(), raw.coalesce_nonempty("fallback").trim())) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.2.3.3.3.3.1 — shipped tclite parity ──
    { case => 'tclite_command_subst', spec => 'tclite', input => '[]' },
    { case => 'tclite_double_quote',  spec => 'tclite', input => '""' },
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
