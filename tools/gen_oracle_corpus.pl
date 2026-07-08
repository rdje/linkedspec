#!/usr/bin/env perl
# RUST-PARITY.7.1 — Perl↔Rust output-oracle fixture generator.
#
# Purpose
#   Generate a *language-neutral* test corpus (ADR 0006 §Phase 8.6) under
#   `rust/linkedspec-runtime/tests/corpus/`. The Perl reference is the behavioral
#   oracle: for each (spec, input) case this tool builds and runs the reference
#   parser, then records its result as canonical JSON. A backend's fixture-runner
#   asserts it reproduces the same value (modulo each backend's documented
#   output-shape rule — see "Output-shape rule" below).
#
# Corpus entry layout (one directory per case; matches the book's
# `appendix/backend-handoff.md` corpus contract):
#   rust/linkedspec-runtime/tests/corpus/<case>/
#     input.spec    — the .spec source (copied verbatim from specs/<spec>.spec)
#     input.txt     — the exact input bytes fed to the parser
#     expected.json — canonical JSON of the reference (Perl) top-rule value
#   rust/linkedspec-runtime/tests/corpus/manifest.json
#     format/case_count/cases — the intended fixture set consumed by the Rust
#     runner's drift guard
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
#   Every oracle case builds the reference parser and runs the parse in a child
#   process under a hard wall-clock timeout (default 15s, override with
#   ORACLE_TIMEOUT). The parent kills the child with SIGKILL on timeout; this
#   deliberately does not rely on `alarm()`, because a catastrophic regex can
#   stay inside one Perl opcode and defer safe signals.
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
use File::Temp qw(tempfile);
use JSON::PP ();
use LinkedSpec;
use POSIX ();
use Time::HiRes ();

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
# subset (`::` rules, entry_text, assignment, push/copy/return, with a few
# named compatibility twins that still exercise declare/old-helper aliases). They
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
#   Lispish: SCALAREF-RETIREMENT.3 keeps the shipped Lispish corpus active after
#   migrating child-return field reads to direct `retv["content"]` access.
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
    # through a typed wrapper -- NAME/array(NAME) -- be used without a
    # declaration helper. These cases prove the Rust backend reproduces that
    # behavior under the universal-contract obligation (ADR 0006): each grammar
    # uses a working variable with no declaration helper in the divergence-free edge-action
    # form (the .7.1 proof class -- non-recursive `Parent:: /re/ -> Child { ... }`,
    # value set by the edge's own `return(...)`, action-less child), so Perl and
    # Rust agree exactly (modulo the one-level accumulator wrap). The historical
    # `*_declare` case names now carry the current initializer/reset forms for
    # continuity; `undef_literal` guards that the
    # `undef` LITERAL inside array(undef) is not mistaken for a variable.
    # The recursive/REP auto-exist idiom the Perl phase0 locks use does NOT yet
    # reproduce on Rust -- that is the separately-owned RUST-PARITY recursive-grammar
    # gap, NOT auto-existence (see docs/knowledge/working-vars-no-strict-need-my-lexical.md).
    {   case   => 'autoexist_scalar_no_declare',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { v = "ok"; return(v) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'autoexist_scalar_declare',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { v = undef; v = "ok"; return(v) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'autoexist_array_no_declare',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { push(array(items), "a"); push(array(items), "b"); return(copy(array(items))) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'autoexist_array_declare',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(array(items), []); push(array(items), "a"); push(array(items), "b"); return(copy(array(items))) }

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
    # kind -- the assignment target is a scalar, the push(...) target is an array.
    # Same divergence-free proof class as the wrapped autoexist_* cases above (the bare
    # target is the only difference), so the Rust backend must produce the identical
    # reference value. The value is read back through a wrapper (v/array(items)) --
    # bare value-position reads are Channel 2, not this leaf.
    {   case   => 'autoexist_scalar_bare_arg',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { v = "ok"; return(v) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'autoexist_array_bare_arg',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { push(items, "a"); push(items, "b"); return(copy(array(items))) }

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
    #
    # The historical `*_array_copy_*` / `*_hash_copy_*` case names now carry the
    # current `copy(...)` forms for continuity after .8.4 hard retirement.
    {   case   => 'terse_1_2_3_2_array_copy_bare_read',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { push(items, "a"); push(items, "b"); return(copy(items)) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_2_3_2_hash_copy_bare_read',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set_key(meta, "stage", "v"); return(copy(hash(meta))) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_2_3_2_copy_bare_array_first',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { push(items, "a"); return(copy(items)) }

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
 /x/ -> Done { set(value, "ok"); set(out, value); name = value; return(array(out, name)) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_2_3_4_mutation_direct_bare_reads',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "payload"); set(key, "stage"); set(idx, 1); set(foo, hash("a", array("zero", "one"))); items += value; set_key(meta, key, value); meta[key] = value; return(array(copy(array(items)), copy(hash(meta)), foo["a"][idx])) }

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
 /x/ -> Done { set(value, "ok"); set(key, "stage"); return(array([value, cat("a", "b"), true, []], { key : value, "fixed" : [value] })) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_2_3_5_3_shape_literal_mutation_rhs',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "payload"); set(key, "stage"); items += [value]; meta[key] = { key : value }; return(array(copy(array(items)), copy(hash(meta)))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.11.3 — Rust duck-typed assignment parity ──
    #
    # These fixtures freeze the current Perl `.11.2` / Rust `.11.3`
    # duck-typed assignment contract: bare direct shape RHS values bind
    # scalar-held typed values, while explicit array/hash targets keep
    # aggregate-storage mutation semantics.
    {   case   => 'terse_11_3_shape_assignment_value_binding',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); items = [value]; meta = { key : value }; return(array(items, array(items), copy(items), items.count(), items.first(), meta, hash(meta), copy(meta), meta.count_keys(), meta.pick_keys(key).sorted_values().first())) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_11_3_assignment_replacement_and_explicit_targets',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); thing = "text"; first = thing; thing = [value]; second = array(thing); thing = { key : value }; third = hash(thing); thing = "done"; set(array(items_mut), [value]); items_mut += "tail"; set(hash(meta_mut), { key : value }); meta_mut["extra"] = "yes"; return(array(first, second, third, thing, array(items_mut), hash(meta_mut))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.11.4 — nested mixed value-path assignment ──
    #
    # Nested writes mutate scalar-held array/hash value trees only when each
    # intermediate container already exists with the needed shape. Final hash
    # keys may be created; final array indexes may replace an existing element
    # or append exactly at len; gaps and wrong/missing intermediate paths return
    # undef and leave the root unchanged.
    {   case   => 'terse_11_4_nested_mixed_value_path_assignment',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "new"); payload = { "items" : [{ "name" : "old" }] }; payload["items"][0]["name"] = value; payload["items"][1] = { "name" : "tail" }; missing_result = payload["missing"][0] = "bad"; wrong_result = payload["items"][0][0] = "bad"; root_array = [{ "name" : "old" }]; root_array[0]["name"] = value; root_array[1] = { "name" : "tail" }; return(array(payload, missing_result, wrong_result, root_array, (payload["items"][3] = "gap"))) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_15_4_bare_scalar_payload_readback',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "ok"); set(payload, [value]); set(snapshot, payload); return(array(value, payload, copy(array(payload)), snapshot)) }

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
 /x/ -> Done { label = cat("a", "b"); push(array(items), label); return(copy(array(items))) }

Done::
 /[a-z]+/
SPEC
    },
    {   case   => 'terse_1_4_2_copy_hash_symbol_empty',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { return(copy(hash(m))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.3.2 — explicit array append terse spelling ──
    #
    # `push(target, value)` remains available when the value shape is unambiguous.
    # All-bare `push(Rule,target)` keeps child-call precedence, so appending a
    # scalar read by bare name uses the `+=` operator spelling.
    {   case   => 'terse_1_3_2_push_alias_array',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(label, "b"); push(items, "a"); items += label; return(copy(array(items))) }

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
 /x/ -> Done { set_key(meta, "stage", cat("a", "b")); return(copy(hash(meta))) }

Done::
 /[a-z]+/
SPEC
    },

    # ── SPEC-FORMAT-TERSE.1.3.4.1 — scalar assignment operator spelling ──
    #
    # `name = value` is the statement-level scalar assignment operator. It is
    # equivalent to `set(name, value)` / `name = value` and does not imply
    # array append, hash-index assignment, or bare value-position reads.
    {   case   => 'terse_1_3_4_1_scalar_assignment_operator',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { name = cat("o", "k"); return(name) }

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
 /x/ -> Done { label = "b"; items += "a"; items += label; return(copy(array(items))) }

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
 /x/ -> Done { meta[cat("s", "tage")] = cat("a", "b"); return(copy(hash(meta))) }

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
 /x/ -> Done { flag = true; items += false; push(items, true); meta["enabled"] = true; if(false); return("bad"); else(); return(array(flag, copy(array(items)), copy(hash(meta)))); endif() }

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
 /x/ -> Done { set (name, cat ("a", "b")); items += cat ("c", "d"); meta[cat ("s", "tage")] = name; return (array(name, copy (array (items)), copy (hash (meta)))) }

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
 return(name) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.1.5.5.1 — direct nested access with explicit segments ──
    #
    # Direct mixed hash/array access is canonical when every segment is explicit.
    # Bare path atoms such as `[z]` remain Channel 2 work; this fixture uses
    # `z` for the final index.
    {   case   => 'terse_1_5_5_1_direct_nested_access',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(foo, hash("a", array(hash("b", array("zero","one")))))
 set(z,1)
 return(foo["a"][0]["b"][z]) }

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
 /x/ -> Done { set(value, "b"); items.push_back("a"); items.push_back(value); items.push_front("z"); items.pop_back(); items.pop_front(); return(copy(items)) }

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
 /x/ -> Done { return(array({ set(x, "a"); x }, { set(y, "b"); return(y) }, { set(key, "stage"); set(value, "ok"); { key : value } })) }

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
 /x/ -> Done { return(array({ return("a"); "b" }, { set(x, "c"); return({ "k" : x }); "bad" })) }

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
 /x/ -> Done { set(kind, "b"); switch(kind) { case("a") { return("bad") } case("b") { return("later") } default { return("default") } } }

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
 /x/ -> Done { set(count, 0); while(num_lt(count, 3)) { set(count, num_add(count, 1)) }; return(count) }

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
 /x/ -> Done { set_key(base, "b", 2); set_key(base, "a", 1); set_key(overlay, "c", 3); return(count(drop_front(sorted_keys(merge_hash(hash(base), hash(overlay)))))) }

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
 /x/ -> Done { set_key(base, "b", 2); set_key(base, "a", 1); set_key(overlay, "c", 3); return(count(drop_front(sorted_keys(merge_hash(copy(hash(base)), overlay))))) }

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
    # ── SPEC-FORMAT-TERSE.15.2.3 — Rust parity for bare value reads ──
    #
    # Bare identifiers in value positions read bound values, while a bare
    # switch-case label stays a literal tag. Dynamic case labels must be written
    # as value expressions rather than as bare labels.
    {   case   => 'terse_15_2_3_bare_value_reads_and_case_labels',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(kind, "foo"); set(foo, "bar"); set(n, 10); set(c, 0); switch(kind) { case(foo) { attached = "literal" } case(cat(foo, "")) { attached = "dynamic" } default { attached = "default" } }; return(array(attached, switch(kind, case(foo, "literal"), case(cat(foo, ""), "dynamic"), default("default")), if(num_lt(n, 5), "yes", else("no")), if(c, "T", else("F")))) }

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
    # Perl/Rust JSON parity. The `.copy()` receiver links below are current
    # documented hash receiver-method surface, not incidental function-form helper
    # residue.
    {   case   => 'terse_2_3_5_2_hash_receiver_value_chains',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set_key(meta, "b", 2); set_key(meta, "a", 1); set_key(extra, "a", 9); set_key(extra, "c", 3); set(hash(layered), merge_hash(hash(meta), hash(extra))); return(array(meta.set_key("c", 3).sorted_keys().join_values(","), hash(layered).pick_keys("a").sorted_values().first(), hash(meta).rename_key("a", "aa").drop_keys("b").set_key("z", 4).count_keys(), meta.pick_keys("missing").count_keys(), meta.sorted_values().drop_front(1).first(), meta.copy().flat_hash().count_keys(), missing.copy().count_keys())) }

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
    # ── SPEC-FORMAT-TERSE.2.3.5.4 — number receiver-dot value chains ──
    #
    # Receiver-dot number methods are pure helper composition over the existing
    # num_* helper family. Boolean comparison terminals are covered by focused
    # backend tests; this oracle fixture keeps numeric values for direct
    # Perl/Rust JSON parity.
    {   case   => 'terse_2_3_5_4_number_receiver_value_chains',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(score, -3.7); return(array(score.abs().ceil().add(2, 3).mul(2).sub(1).div(2).clamp(0, 20).max(5).min(12), 5.mod(2), 3.5.floor().add(1), 3.5.round())) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.7.3 — array numeric reducer receiver methods ──
    #
    # Numeric aggregate reducers are pure terminal methods on array receivers.
    # The fixture also locks the documented single-array min/max helper forms
    # that the receiver methods dispatch through.
    {   case   => 'terse_7_3_array_numeric_reducer_receiver_methods',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { scores += 1; scores += 5; scores += 3; scores += 5; return(array(scores.sum(), scores.avg(), scores.median(), scores.range(), scores.min(), scores.max(), scores.sorted().take(3).avg(), scores.uniq().sum(), num_min(array(scores)), num_max(array(scores)), min(scores), max(scores))) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.3.2.1 — numeric word aliases ──
    #
    # Function-form numeric word aliases map to the existing num_* family.
    # Comparison word aliases stay out of this fixture; .3.2.3 owns that
    # policy decision separately.
    {   case   => 'terse_3_2_1_numeric_word_aliases',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { return(array(add(2,3,4), sub(10,3), mul(2,3,4), div(9,2), mod(17,5), abs(-7), floor(3.7), ceil(3.2), round(3.5), min(8,3,5), max(8,3,5), clamp(add(2,5),0,6), sum(array(1,2,3)), avg(array(2,4,6)), median(array(1,5,3)), range(array(1,5,3)))) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.3.2.2 — arithmetic symbol callees ──
    #
    # Symbol callees are ordinary callee(args) forms and must lower to the same
    # num_* helpers before any backend can reinterpret them as host syntax.
    {   case   => 'terse_3_2_2_arithmetic_symbol_callees',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { return(array(+(2,3,4), -(10,3), *(2,3,4), /(9,2), %(17,5), +(2, *(3,4)))) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.3.2.3.2 — explicit string comparison helpers ──
    #
    # str_* helpers preserve the current lexical string comparison semantics
    # under explicit names before bare comparison words become future numeric
    # aliases. This fixture uses control flow to emit backend-stable strings
    # instead of relying on Perl/Rust boolean JSON shape equivalence.
    {   case   => 'terse_3_2_3_2_string_comparison_helpers',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(out, ""); if(str_eq("node", "node")) { set(out, cat(out, "E")) }; if(str_ne("node", "edge")) { set(out, cat(out, "N")) }; if(str_gt("2", "10")) { set(out, cat(out, "G")) }; if(str_ge("2", "2")) { set(out, cat(out, "H")) }; if(str_lt("10", "2")) { set(out, cat(out, "L")) }; if(str_le("10", "10")) { set(out, cat(out, "M")) }; if(str_gt("10", "2")) { set(out, cat(out, "X")) }; return(out) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.3.2.3.3 — numeric comparison word aliases ──
    #
    # Bare comparison words now dispatch through num_* semantics. Keep str_gt in
    # the same fixture to prove lexical comparison remains available explicitly.
    {   case   => 'terse_3_2_3_3_numeric_comparison_word_aliases',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(out, ""); if(eq("2", "2")) { set(out, cat(out, "E")) }; if(ne("2", "3")) { set(out, cat(out, "N")) }; if(gt("10", "2")) { set(out, cat(out, "G")) }; if(ge("2", "2")) { set(out, cat(out, "H")) }; if(lt("2", "10")) { set(out, cat(out, "L")) }; if(le("2", "2")) { set(out, cat(out, "M")) }; if(gt("2", "10")) { set(out, cat(out, "X")) }; if(str_gt("2", "10")) { set(out, cat(out, "S")) }; return(out) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.3.2.3.4 — numeric comparison symbol callees ──
    #
    # Comparison symbol callees dispatch through num_* semantics. Keep str_gt in
    # the same fixture to prove lexical comparison remains available explicitly.
    {   case   => 'terse_3_2_3_4_numeric_comparison_symbol_callees',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(out, ""); if(==("2", "2")) { set(out, cat(out, "E")) }; if(!=("2", "3")) { set(out, cat(out, "N")) }; if(>("10", "2")) { set(out, cat(out, "G")) }; if(>=("2", "2")) { set(out, cat(out, "H")) }; if(<("2", "10")) { set(out, cat(out, "L")) }; if(<=("2", "2")) { set(out, cat(out, "M")) }; if(>("2", "10")) { set(out, cat(out, "X")) }; if(str_gt("2", "10")) { set(out, cat(out, "S")) }; return(out) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.3.3.1 — scalar assignment expression values ──
    #
    # Scalar non-shape assignment forms now store and yield the assigned value
    # in value positions. This fixture covers infix `name = value`, operator
    # call `=(name, value)`, scalar set/assign compatibility via `set(...)`, a
    # function-local assignment return, an expression-valued block, and receiver
    # chaining on the assigned value. Direct RHS shapes, array append values, and
    # hash-index mutation values remain deferred to later `.3.3.x` leaves.
    {   case   => 'terse_3_3_1_scalar_assignment_expressions',
        input  => 'xhello',
        source => <<'SPEC',
fn store(value) { return(local = value) }
Top::
 /x/ -> Done { return(array(name = "ok", name, =(other, cat(name, "!")), other, set(third, store("fn")), third, { block = cat(third, "!"); block }, =(raw, " hi ").trim())) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.3.3.2 — aggregate assignment expression values ──
    #
    # Direct RHS shape assignment forms now store and yield scalar-held typed
    # values in value positions for bare targets. This fixture covers bare
    # infix assignment, set(...) compatibility, explicit scalar shape payloads,
    # and receiver chaining on the operator-call assigned value.
    {   case   => 'terse_3_3_2_aggregate_assignment_expressions',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); return(array(items = [value], copy(array(items)), set(meta, { key : value }), copy(hash(meta)), set(payload, [value]), payload, =(more, [value, "x"]).count())) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.3.3.3 — mutation assignment expression values ──
    #
    # Array append and hash-index assignment forms now mutate their working
    # targets and yield the updated aggregate snapshot in value positions. This
    # fixture covers helper arguments, snapshot reads after mutation, and
    # receiver chaining on the mutation expression result.
    {   case   => 'terse_3_3_3_mutation_assignment_expressions',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); return(array(items += value, copy(items), meta[key] = value, copy(hash(meta)), (items += "x").count(), (meta["last"] = value).count_keys())) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.3.3.4 — assignment expression closure ──
    #
    # The parent `.3.3` contract is closed once scalar, direct-shape
    # aggregate, append, and hash-index assignment expressions all compose in
    # one portable program. Public docs prefer `set(...)` or operator forms.
    {   case   => 'terse_3_3_4_assignment_expression_closure',
        input  => 'xhello',
        source => <<'SPEC',
fn keep(value) { return(fn_out = value) }
Top::
 /x/ -> Done { set(value, "ok"); set(key, "stage"); return(array(name = value, name, =(other, cat(name, "!")), other, set(third, keep("fn")), third, set(current, "surface"), current, items = [value], array(items), set(meta, { key : value }), hash(meta), set(array(items_mut), [value]), items_mut += "tail", copy(array(items_mut)), set(hash(meta_mut), { key : value }), meta_mut["extra"] = other, copy(hash(meta_mut)), (items_mut += "last").count(), (meta_mut["last"] = value).count_keys())) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.4.3.2 — user-function runtime parity ──
    #
    # Registered calls execute as values, standalone calls discard their result,
    # function-local variables stay local, and returned arrays feed compatible
    # receiver-dot chains.
    {   case   => 'terse_4_3_2_user_function_runtime',
        input  => 'xhello',
        source => <<'SPEC',
fn normalize(value) { return(trim(value)) }
fn words(value) { set(scratch, trim(value)); return([scratch, uppercase(scratch)]) }
Top::
 /x/ -> Done { normalize(" drop "); return(array(normalize(" x "), words(" go ").join_values("|"), words(" a ").count(), scratch)) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.2.3.5.5 — block-valued receiver-dot chains ──
    #
    # Expression-valued blocks can be receivers for the same compatible
    # array/string/hash/number receiver helper families. This fixture keeps
    # JSON-stable scalar/number outputs while proving that the yielded block
    # value, not a special block-only rule, feeds the receiver chain.
    {   case   => 'terse_2_3_5_5_block_valued_receiver_chains',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { return(array({ [3, 1, 2] }.sorted().join_values(","), { return(["x", "y"]); ["bad"] }.join_values("|"), { set(raw, " a-b "); raw }.trim().split("-").count(), { { "b" : 2, "a" : 1 } }.sorted_keys().join_values(","), { 3.5 }.floor().add(2))) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.14.3 — Rust helper-form trailing block parity ──
    #
    # The Perl reference is the oracle for immediate, non-closure helper-form
    # trailing block arguments. Rust must parse `with(value) { ... }` and
    # `with() { ... }`, bind/restore the scoped `value`, and preserve hash
    # literal payloads inside the block.
    {   case   => 'terse_14_3_with_helper_trailing_block',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "outer"); return(array(with("inner") { return(cat(value, "!")) }, value, with() { return(if(is_undefined(value), "undef", else("bad"))) }, with("ok") { return({ "stage" : value }) })) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.14.4 — receiver-form trailing block parity ──
    #
    # Receiver `.with() { ... }` binds the receiver value as scoped `value`.
    # The block result is either the terminal expression result or feeds later
    # compatible receiver-family links.
    {   case   => 'terse_14_4_receiver_with_trailing_block',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { set(value, "outer"); return(array("inner".with() { return(cat(value, "!")) }, value, " x ".with() { return(cat(value, "!")) }.trim(), " a-b ".trim().with() { return(value.split("-")) }.count(), "ok".with() { return({ "stage" : value }) }.count_keys())) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.12.3 — Rust hash-tree traversal parity ──
    #
    # Hash-tree receiver blocks traverse hash roots/interior nodes in sorted
    # depth-first order, bind scoped leaf callback variables, treat arrays as
    # leaves, and preserve hash-family continuation for walk/map.
    {   case   => 'terse_12_3_hash_tree_traversal_receiver_blocks',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { meta = { "b" : { "y" : "B" }, "a" : "A", "arr" : ["u", "v"] }; nonhash = "x".map_leaves() { seen += "bad" }; return(array(meta.map_leaves() { return(cat(join_values("/", array(path)), "=", if(count(array(value)), join_values("", array(value)), else(value)))) }, meta.reduce_leaves("") { return(cat(acc, key)) }, meta.walk_leaves() { seen += join_values("/", array(path)); return(value) }.count_keys(), array(seen), if(is_undefined(nonhash), "undef", else("bad")))) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.13.3 — Rust array-tree traversal parity ──
    #
    # Array-tree receiver blocks recurse through nested arrays in source order,
    # bind numeric index/path/depth callback variables at leaves, treat hashes
    # as leaf values, and return undef for scalar receivers without callbacks.
    {   case   => 'terse_13_3_array_tree_traversal_receiver_blocks',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { items = ["a", ["b", "c"], { "h" : "H" }]; scalar = "x"; nonarray = scalar.map_leaves() { seen += "bad" }; return(array(items.map_leaves() { return(cat(join_values("/", array(path)), "=", if(count(hash(value).sorted_keys()), cat("{", hash(value).sorted_keys().join_values(","), "}"), else(value)))) }, items.reduce_leaves("") { return(cat(acc, join_values("/", array(path)), ":", if(count(hash(value).sorted_keys()), cat("{", hash(value).sorted_keys().join_values(","), "}"), else(value)), ";")) }, items.walk_leaves() { seen += join_values("/", array(path)); return(value) }.count(), array(seen), if(is_undefined(nonarray), "undef", else("bad")))) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.2.3.5.6 — typed wrapper quoted-name boundaries ──
    #
    # Single-argument aggregate wrappers name a working variable only when the
    # token is bare. Quoted strings remain constructor payloads; direct shape
    # literals are the terse constructor form.
    {   case   => 'terse_2_3_5_6_typed_wrapper_quoted_names',
        input  => 'xhello',
        source => <<'SPEC',
Top::
 /x/ -> Done { items += "a"; items += "b"; set_key(meta, "a", 1); set_key(meta, "b", 2); return(array(count(array(items)), count(array("items")), count(array('items')), count(array(items)), count(array("items")), count(["items"]), count(array("literal", "value")), count_keys(hash(meta)), count_keys(hash("meta", 1)), count_keys(hash('meta', 1)), count_keys({ "meta" : 1 }), count_keys(hash(meta)), count_keys(hash("meta", 1)))) }

Done::
 /[a-z]+/
SPEC
    },
    # ── SPEC-FORMAT-TERSE.2.3.3.3.3.1 — shipped tclite parity ──
    { case => 'tclite_command_subst', spec => 'tclite', input => '[]' },
    { case => 'tclite_double_quote',  spec => 'tclite', input => '""' },
    # ── SCALAREF-RETIREMENT.3 — shipped Lispish direct-access migration ──
    { case => 'lispish_x_y', spec => 'Lispish', input => '(x y)' },
    # ── TOP-RULE-AS-NORMAL.3.2 — recursive top-rule value parity ──
    #
    # SPEC-FORMAT-TERSE.8.4 makes `set(array(items), [])` the current rule-local
    # recursive accumulator reset classified in the integration tests.
    {
        case   => 'top_rule_body_recursion_sexpr',
        input  => '(a(b)c)',
        source => <<'SPEC',
top::
 -> sexpr { return(call(sexpr)) }

sexpr: /\(/ /\)/  I { set(array(items), []) }
 -> sexpr     { push(array(items), call(sexpr)) }
 -> atom      { push(array(items), call(atom)) }
 -> sexpr[1]  { return(copy(array(items))) }

atom: /[A-Za-z0-9]+/   I.return(entry_text())
SPEC
    },
    {
        case   => 'top_rule_lx_recursion_nested',
        input  => '(a(b)c)',
        source => <<'SPEC',
sexpr:: /\(/ /\)/  I { set(array(items), []) }
 -> sexpr     { push(array(items), call(sexpr)) }
 -> atom      { push(array(items), call(atom)) }
 -> sexpr[1]  { return(copy(array(items))) }
LX { return(copy(array(items))) }

atom: /[A-Za-z0-9]+/   I.return(entry_text())
SPEC
    },
    {
        case   => 'top_rule_lx_recursion_sequence',
        input  => '(a) (b)',
        source => <<'SPEC',
sexpr:: /\(/ /\)/  I { set(array(items), []) }
 -> sexpr     { push(array(items), call(sexpr)) }
 -> atom      { push(array(items), call(atom)) }
 -> sexpr[1]  { return(copy(array(items))) }
LX { return(copy(array(items))) }

atom: /[A-Za-z0-9]+/   I.return(entry_text())
SPEC
    },
    # ── RUST-PARITY.7.2 — structurally simple shipped-spec corpus batch ──
    { case => 'hlink_raw_string',              spec => 'hlink_substitution', input => 'plain text' },
    { case => 'hlink_raw_escaped_brackets',    spec => 'hlink_substitution', input => 'plain \[text\]' },
    # ── RUST-PARITY.7.3.3.2 — JSON-safe hlink_substitution curly delimiter ──
    { case => 'hlink_curly_brace',             spec => 'hlink_substitution', input => '{abc}' },
    # ── SPEC-SOURCE-TERSE-CLOSEOUT.1 — hlink bracket outputs are now neutral strings ──
    { case => 'hlink_bracket_body',            spec => 'hlink_substitution', input => '[abc]' },
    { case => 'hlink_mixed_bracket_brace',     spec => 'hlink_substitution', input => 'foo[bar]{baz}' },

    # ── RUST-PARITY.7.3.4.2 — shipped portmap scalar classification parity ──
    { case => 'portmap_bare',     spec => 'portmap', input => 'foo' },
    { case => 'portmap_bit',      spec => 'portmap', input => 'bar[3]' },
    { case => 'portmap_slice',    spec => 'portmap', input => 'baz[7:0]' },
    { case => 'portmap_constant', spec => 'portmap', input => '0x1f' },

    # ── RUST-PARITY.7.3.4.3 — action-edge child/target aggregation parity ──
    { case => 'portmap_concatenation', spec => 'portmap', input => '{foo bar[2]}' },
    { case => 'ebnf_expression_rules', spec => 'ebnf',    input => "Expr := Term (\"+\" Term)*\nTerm := Factor\n" },
    { case => 'ebnf_logging_annotation', spec => 'ebnf', input => "Expr := Term \@log_rule(\"expr\", \"term\")\n" },
    { case => 'spec_spec_minimal_rule', spec => 'spec', input => "Top::\n /x/\n" },
    {
        case  => 'spec_spec_action_edge',
        spec  => 'spec',
        input => "Top::\n /x/ -> Done { return(\"x\") }\n\nDone::\n /x/\n",
    },
    {
        case  => 'spec_spec_user_function_definition',
        spec  => 'spec',
        input => "fn norm(value) { return(trim(value)) }\nTop::\n /x/ -> Done { return(norm(\" x \")) }\n\nDone::\n /x/\n",
    },
    { case => 'spec_spec_comment_skip', spec => 'spec', input => "# hello\nTop::\n /x/\n" },

    # RUST-PARITY.7.3.6 - RTL/plugin/legacy shipped-spec safety smokes.
    {
        case  => 'regdef_nested_register_fields',
        spec  => 'regdef',
        input => "reg_def CTRL {\n  reg_fld ENABLE : RW : anything;\n  reg_fld MODE : RO : other;\n}\n",
    },
    { case => 'tablegrep_simple_term', spec => 'tablegrep', input => 'field1 =~ /foo/' },
    { case => 'simenv_multiline_value', spec => 'simenv', input => "BEGIN top\nBAR={baz}\nEND top\n" },
    { case => 'vhdl_library_use', spec => 'vhdl', input => "library ieee;\nuse ieee.std_logic_1164.all;\n" },
    {
        case  => 'ds_vhistory_version_entry',
        spec  => 'ds_vhistory',
        input => "\nobject: /proj/foo\nversion: 1\ndate: today\n--------------------\n",
    },
    { case => 'pplugin_empty', spec => 'pplugin', input => '' },
    { case => 'tkgui_empty', spec => 'tkgui', input => '' },

    {
        case  => 'lib_reader_sattribute',
        spec  => 'lib_reader',
        input => 'cell("foo"){ attr : "bar"; }',
    },
    {
        case  => 'lib_reader_cattribute',
        spec  => 'lib_reader',
        input => 'cell("foo"){ attr("bar,baz"); }',
    },
);

my $json = JSON::PP->new->canonical(1)->pretty(1);

my $written = 0;
my @case_names;
my %seen_case;
for my $case (@CASES) {
    my $name  = $case->{case};
    my $input = $case->{input};
    die "duplicate oracle corpus case '$name'\n" if $seen_case{$name}++;
    push @case_names, $name;

    my $spec_src;
    if ( defined $case->{source} ) {
        $spec_src = $case->{source};
    }
    else {
        my $spec = $case->{spec};
        $spec_src = slurp( File::Spec->catfile( $SPECDIR, "$spec.spec" ) );
    }

    my $value = run_oracle( $case, $name, $input, $TIMEOUT );

    my $dir = File::Spec->catdir( $CORPUS, $name );
    make_path($dir);
    spew( File::Spec->catfile( $dir, 'input.spec' ),    $spec_src );
    spew( File::Spec->catfile( $dir, 'input.txt' ),     $input );
    spew( File::Spec->catfile( $dir, 'expected.json' ), $json->encode($value) );

    printf "  wrote corpus/%s/ (input=%s)\n", $name, _show($input);
    $written++;
}

spew(
    File::Spec->catfile( $CORPUS, 'manifest.json' ),
    $json->encode(
        {
            format       => 1,
            generated_by => 'tools/gen_oracle_corpus.pl',
            case_count   => scalar @case_names,
            cases        => \@case_names,
        }
    )
);

printf "Generated %d oracle fixture(s) plus manifest into %s\n", $written, $CORPUS;

# Build the reference parser and run one input under a hard wall-clock timeout;
# return the decoded result structure (arrayref/hashref/scalar).
sub run_oracle {
    my ( $case, $name, $input, $timeout ) = @_;

    my $safe_name = $name;
    $safe_name =~ s/[^A-Za-z0-9_.-]+/_/g;

    my ( $out_fh, $out_path ) = tempfile(
        "linkedspec-oracle-${safe_name}-out-XXXX",
        TMPDIR => 1,
        UNLINK => 1,
    );
    my ( $err_fh, $err_path ) = tempfile(
        "linkedspec-oracle-${safe_name}-err-XXXX",
        TMPDIR => 1,
        UNLINK => 1,
    );
    close $out_fh or die "cannot close oracle temp output $out_path: $!\n";
    close $err_fh or die "cannot close oracle temp error $err_path: $!\n";

    my $pid = fork();
    die "oracle fork failed for case='$name': $!\n" unless defined $pid;

    if ( $pid == 0 ) {
        my $stage = 'parser build';
        my $ok    = eval {
            my $parser;
            if ( defined $case->{source} ) {
                my $source = $case->{source};
                $parser = LinkedSpec::Get( \$source );
                die "Get(<inline $name>) did not return a CODE ref\n"
                    unless ref $parser eq 'CODE';
            }
            else {
                my $spec = $case->{spec};
                $parser = LinkedSpec::get_parser($spec);
                die "get_parser('$spec') did not return a CODE ref\n"
                    unless ref $parser eq 'CODE';
            }

            $stage = 'parser execute';
            my $result     = $parser->( \$input );
            my $child_json = JSON::PP->new->canonical(1)->pretty(1);
            spew( $out_path, $child_json->encode($result) );
            1;
        };
        if ( !$ok ) {
            my $err = $@ // 'unknown oracle child failure';
            spew( $err_path, "$stage: $err" );
            POSIX::_exit(1);
        }
        POSIX::_exit(0);
    }

    my $start  = Time::HiRes::time();
    my $status = undef;
    while ( Time::HiRes::time() - $start < $timeout ) {
        my $done = waitpid( $pid, POSIX::WNOHANG() );
        if ( $done == $pid ) {
            $status = $?;
            last;
        }
        die "oracle waitpid failed for case='$name': $!\n" if $done == -1;
        Time::HiRes::sleep(0.02);
    }

    if ( !defined $status ) {
        kill 'KILL', $pid;
        waitpid( $pid, 0 );
        die "ORACLE_TIMEOUT after ${timeout}s (hard kill during parser build/parse) for case='$name' input="
            . _show($input) . "\n";
    }

    if ( $status & 127 ) {
        die "oracle build/parse failed for case='$name' input=" . _show($input)
            . ": child died with signal " . ( $status & 127 ) . "\n";
    }

    my $exit = $status >> 8;
    if ( $exit != 0 ) {
        my $err = -s $err_path ? slurp($err_path) : "child exited with status $exit\n";
        die "oracle build/parse failed for case='$name' input=" . _show($input) . ": $err";
    }

    my $json_text = slurp($out_path);
    die "oracle build/parse failed for case='$name' input=" . _show($input)
        . ": child produced no JSON\n"
        unless length $json_text;

    return JSON::PP->new->decode($json_text);
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
