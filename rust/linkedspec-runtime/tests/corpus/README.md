# Output-oracle test corpus (`RUST-PARITY.7`)

A **language-neutral** parity corpus (ADR 0006 §Phase 8.6). The Perl reference is
the behavioral oracle; this corpus is its frozen output. Every LinkedSpec backend
validates against the same fixtures, so a backend is "compliant" when it
reproduces the reference value for every entry.

## Entry layout

One directory per case:

```
manifest.json
<case>/
  input.spec    — the .spec source (copied verbatim from specs/<spec>.spec)
  input.txt     — the exact input bytes fed to the parser
  expected.json — canonical JSON of the reference (Perl) top-rule value
```

`expected.json` is canonicalized with `JSON::PP->canonical(1)` (object keys
sorted), so regenerating an unchanged case is byte-stable — no spurious diffs.
The root `manifest.json` records the intended fixture set (`case_count` plus
ordered `cases`). The Rust oracle runner reads the manifest first, rejects
duplicate or invalid case names, fails if any manifest entry is missing, and
fails if a stale extra fixture directory remains after a case is removed.

## Output-shape rule (Perl ↔ Rust)

`expected.json` holds the **backend-neutral reference value**: the Perl reference
returns the top rule's value *directly* (e.g. tclite on `[]` →
`["?tcl_script:",[["?command_subst:",[]]]]`). Each backend applies its own known
output-shape mapping when comparing:

- **Perl reference:** identity — output equals `expected.json`.
- **Rust engine:** `Engine::execute` wraps the accumulator one level (it returns
  `Array(accumulator)`), so its output is `[ <expected> ]`. The Rust fixture
  runner (`../corpus_oracle.rs`) compares `engine.execute(input) == [expected]`.

## Regenerating

```sh
perl tools/gen_oracle_corpus.pl            # default 15s hard per-case build+parse timeout
ORACLE_TIMEOUT=30 perl tools/gen_oracle_corpus.pl
```

The generator runs every oracle parser build and parse in a child process. If
either phase exceeds `ORACLE_TIMEOUT`, the parent kills that child with
`SIGKILL`, so catastrophic regex backtracking or parser-construction hangs
cannot wedge corpus generation. The historical `RTLUtils` hang is retired with
the legacy VHDL/RTL/FSM subsystem; the process-level guard remains as generic
protection for future pathological specs. The case list lives at the top of
`tools/gen_oracle_corpus.pl`; regeneration writes both the fixture directories
and `manifest.json`. `RUST-PARITY.7.4` finalized the enumerate-all-fixtures
drift guard.

`SPEC-FORMAT-TERSE.2.3.3.3.3.1` restored the minimal shipped `tclite` fixtures after the
Rust default-mode recursive repetition and child-preamble-return gap was fixed. The
committed corpus includes `tclite_command_subst` (`[]`) and `tclite_double_quote` (`""`),
and both now pass with the tagged Perl-reference `tcl_script` values.

`SCALAREF-RETIREMENT.3` keeps the minimal shipped `Lispish.spec` fixture active after
migrating its child-return field reads to direct `retv["content"]` access. The committed
corpus includes `lispish_x_y` (`(x y)`), whose Perl reference value is `["x",["y"]]`; the
corpus then had 63 fixtures.

`RUST-PARITY.7.2` added the first post-retirement shipped-spec expansion: two
`hlink_substitution` raw-string cases (`hlink_raw_string` and
`hlink_raw_escaped_brackets`). `RUST-PARITY.7.3.3.2` then added the JSON-safe
curly-brace delimiter fixture (`hlink_curly_brace`, input `{abc}`). The corpus
then had 66 fixtures.

`SPEC-SOURCE-TERSE-CLOSEOUT.1` later migrated the shipped `hlink_substitution`
bracket payload away from the historical Perl scalar-reference shape to a neutral
`capture_slice()` string. The corpus now includes `hlink_bracket_body` (`[abc]`)
and `hlink_mixed_bracket_brace` (`foo[bar]{baz}`), both represented directly in
JSON and green against the Rust backend.

`RUST-PARITY.7.3.4.4` added `lib_reader_sattribute` and `lib_reader_cattribute`.
`RUST-PARITY.7.3.4.2` then added `portmap_bare`, `portmap_bit`,
`portmap_slice`, and `portmap_constant`, proving the shipped `portmap.spec`
scalar classifications against the Perl reference. `RUST-PARITY.7.3.4.3` added
`portmap_concatenation`, `ebnf_expression_rules`, and `ebnf_logging_annotation`
after Rust action-edge child aggregation parity landed.

`RUST-PARITY.7.3.5` added four `spec.spec` smoke fixtures:
`spec_spec_minimal_rule`, `spec_spec_action_edge`,
`spec_spec_user_function_definition`, and `spec_spec_comment_skip`. The same
triage deliberately did **not** add `BNF`, `DT`, `ifelse`, or `operators_try`
semantic fixtures for the probed inputs, because the Perl reference returns
`null` for those diagnostic/debug-print cases. The corpus then had 81 fixtures.

`RUST-PARITY.7.3.6` added seven RTL/plugin/legacy shipped-spec safety smokes:
`regdef_nested_register_fields`, `tablegrep_simple_term`,
`simenv_multiline_value`, `vhdl_library_use`, `ds_vhistory_version_entry`,
`pplugin_empty`, and `tkgui_empty`. Those are deliberately narrow, JSON-safe,
Rust-green fixtures. Richer `pplugin`, `tkgui`, `sdce`, recursive `tablegrep`,
single-line `simenv`, VHDL port-clause, `ds_vhistory` branch, and placeholder
`verilog` candidates remain follow-up parity blockers rather than unsafe corpus
promotions. The corpus then had 88 fixtures.

`TOP-RULE-AS-NORMAL.3.2` added three recursive top-rule/body value parity
fixtures after the broader recursive-grammar blocker closed:
`top_rule_body_recursion_sexpr`, `top_rule_lx_recursion_nested`, and
`top_rule_lx_recursion_sequence`. These lock the Perl reference values for the
wrapper-body recursive `sexpr` idiom, a recursive top rule with `LX`, and a
top-rule `LX` sequence parse.

Later terse-language leaves added helper/receiver trailing-block, hash-tree traversal,
array-tree traversal, and typed-wrapper quoted-name fixtures. `FUTURE-PARITY-BACKLOG.1.6.1.2.2.5`
then admitted six governed exhaustive capability sources after all four backends matched their exact Perl values.
The checked-in corpus now has 105 fixtures, ending with the anonymous/named capture families.

`FUTURE-PARITY-BACKLOG.10.5.0.1.2` refreshes all four `spec_spec_*` inputs to exact canonical
`specs/spec.spec` bytes and adds a checker-enforced freshness lock. The current canonical SHA-256 is
`ce409f572887d102543d995e197666df668e47963f572a3a376622249e57fa7c`; the four expected JSON values remain
unchanged, and all four backend corpus runners still pass 105/105.
