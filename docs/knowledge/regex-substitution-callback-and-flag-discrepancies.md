---
id: regex-substitution-callback-and-flag-discrepancies
title: "Statement regex substitution diverges by Perl lowering context and bypasses Rust receiver protection"
answers:
  - "does regex_subst work inside a map_leaves callback"
  - "does substr regex substitution guard an active receiver"
  - "why does Perl ignore callback regex substitution"
  - "do quoted regex substitution flags work on Perl and Rust"
  - "where are callback substitution and flag-form repairs tracked"
  - "does an unsupported helper descriptor stop Perl execution"
date: 2026-09-07
status: confirmed bounded discrepancies; repair SESSION-STARTUP-READING.59.1-.59.4 pending
tags: [rust, perl, actionir, regex, substitution, callbacks, receiver-mutation, diagnostics]
evidence: "SESSION-STARTUP-READING.3.3.20 at 14a66b821d3ebb64eb91781ebd44e0b80e1f2030 reads engine.rs 7879-9278 and records ten paired primary Rust/Perl Get controls, ten lowering/generated-source captures, and six exact callback descriptor controls. Ordinary bare-g substitutions agree. Quoted flags and callback contexts diverge; Rust accepts four active-receiver substitutions, while Perl emits unsupported-helper markers for those calls and for two unrelated scalar controls. Independent assertions pass after matching the actual Perl error type/stage fields."
reverify: "bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py && rg -n 'receiver_write_attempt|regex_subst_call_parts|lower_regex_subst_statement|lower_ast_block_side_effect_statement' rust/linkedspec-runtime/src/engine.rs perl/LinkedSpec/ActionIR/MethodLowering.pm"
---

# Exact substitution boundaries

The current book's helper catalog describes a named scalar mutation, a scalar flags
argument, and bare-token examples such as `g`/`go`. Pure character slicing has a
different signature. The existing neutral receiver contract rejects helper-mediated
writes through the active binding identity. These two authorities motivate the
controls; Perl's observed callback result is not treated as the intended semantics.

Every fixture uses this exact scaffold and input `xhello`:

```text
Top::
 I { BODY }
 /x/ -> Done
Done:
 /[a-z]+/
```

For each helper `H` in `regex_subst` and `substr`:

- Ordinary body: `text = "A"; H(text, /A/, "X", FLAGS); return(text)`.
- Receiver body: `tree = { "a" : "A" }; result = tree.map_leaves!() { H(tree, /A/, "X", FLAGS); return(tree) }; return([tree, result])`.
- Unrelated body: `text = "A"; tree = { "a" : "A" }; result = tree.map_leaves!() { H(text, /A/, "X", g); return(text) }; return([text, tree, result])`.

Ordinary/receiver bodies each run with `FLAGS` equal to `"g"` and `g`. The unrelated
body runs only with bare `g`, giving ten paired cases.

| Case name | Rust JSON value | Perl result / error |
| --- | --- | --- |
| regex_scalar | `"X"` | null; undefined host subroutine |
| substr_scalar | `"X"` | `"A"`; no error |
| regex_scalar_bare | `"X"` | `"X"`; no error |
| substr_scalar_bare | `"X"` | `"X"`; no error |
| regex_receiver | `[{"a":""},{"a":""}]` | `[{"a":{"a":"A"}},{"a":{"a":"A"}}]` |
| substr_receiver | `[{"a":""},{"a":""}]` | `[{"a":{"a":"A"}},{"a":{"a":"A"}}]` |
| regex_receiver_bare | `[{"a":""},{"a":""}]` | `[{"a":{"a":"A"}},{"a":{"a":"A"}}]` |
| substr_receiver_bare | `[{"a":""},{"a":""}]` | `[{"a":{"a":"A"}},{"a":{"a":"A"}}]` |
| regex_unrelated | `["X",{"a":"X"},{"a":"X"}]` | `["A",{"a":"A"},{"a":"A"}]` |
| substr_unrelated | `["X",{"a":"X"},{"a":"X"}]` | `["A",{"a":"A"},{"a":"A"}]` |

All Rust processes exit 0 with empty stderr. All Perl parsers are created, build/call
exception strings are empty, and captured warnings are empty. Only `regex_scalar`
has `last_error`: `type=runtime_handler`, `stage=rule_handler_eval`,
`owner_stage=runtime_handler:rule_handler_eval`. Its exact detail is
`Undefined subroutine &LinkedSpec::SpecEntry::regex_subst called at LinkedSpec::generated_handler:Top:_default line 22.\n`.
The collector's plain projection serializes parser-created truth as `"1"`, not a
native JSON boolean. The initial four-case Perl stdout contains 367 trace bytes
despite trace level NONE; its stderr and later bare/unrelated execution logs are
empty. Successful callback cases have null `last_error`.

# Mechanisms shown by LinkedSpec tools

The probes use `call_spec_handler_subst`, `Get(..., dump_parser_source=>1,
parser_source_ref=>...)`, and a separate `Get(..., return_descriptor=>1)` call.

- Ordinary bare flags produce `$text =~ s{A}{X}g` for both names.
  `Contracts.pm:2142–2149` matches bare-word flags; quoted flags do not enter it.
- Ordinary quoted `regex_subst` remains a host call in the generated handler and
  fails at execution. Ordinary quoted `substr` becomes an unsupported-helper
  sentinel yielding undef, leaving the scalar untouched.
- All six callback variants emit
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:regex_subst` or `:substr` followed by
  the callback's return payload. Their descriptors each report
  `unresolved_helper_count=1` and `language_agnostic_action_ir_ready=0`.
  `MethodLowering.pm:687–742` routes assignments, array pipelines and set/set_key/push
  statements, then falls back to value lowering; it has no substitution statement
  route. The ordinary substitution emitter lives at `8003–8030`. The sentinel's
  undef result is its existing diagnostics behavior, not a receiver rejection.
  See [[perl-actionir-ast-covered-call-diagnostics]].
- Rust `engine.rs:5314–5362` omits these names from `receiver_write_attempt`.
  The helper at `8360–8381` resolves a raw target, reads its private scalar slot,
  substitutes, and invokes unguarded `set_scalar`. Four receiver cases therefore
  continue with an empty scalar value and rebuild leaves from it. This is a
  different omission from final assignment dispatch in
  [[rust-final-value-assignment-receiver-guard-gap]].

These are primary Rust and live Perl observations. Generated source was captured
and inspected, not loaded/executed independently. No fresh direct native diagnostic,
other-backend, operand-effect, rollback, or generated-carrier result is inferred.

# Evidence and repair

All ten specs, Perl collectors, lowerings, descriptors, generated text and raw logs
are retained under `.linkedspec-data/scratch/startup79-substitution-guard/`.
Primary invocation is `rust/target/debug/linkedspec-rust --inline-spec <exact spec>
--input xhello` under `tools/project_data_run.sh`. Perl uses `LinkedSpec::Get` with
`runtime_ctx_ref` and a mutable input reference. Reconstruct fixtures from the
scaffold above if scratch is later retired. The reverify field checks the neutral
invariant and retrieves source owners; it does not rerun these ten pairs.

The existing Rust executable is 34,992,496 bytes, SHA-256
`ad45555750489b78f7835457a09ecfa174d56b7ebf6242a4db5850570797c81a`.
No compiler was launched for this checkpoint.

| Retained artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| rust-cli.jsonl | 334 | c263d811d06c4c9333399e12311080d798a9f915847daf4cf54473d719da7822 |
| rust-cli-bare.jsonl | 354 | a0392990c081d60c4153c9b71b5edff9131d8f92c560429d6f08b9f2103c4253 |
| rust-cli-unrelated.jsonl | 209 | bf0c2d078e25cfdcb207bf543dbe25325b361733d3f37d905104b041545aa32c |
| perl-results.jsonl | 996 | 04e02817ebf88f824aed3881c325c3da5314977ff872ad5f5eb939980c8db53d |
| perl-bare-results.jsonl | 578 | e9fcef3541e22b5be86003ef1de38bf8e957e7db6b914007149ecd9aa16fd433 |
| perl-unrelated-results.jsonl | 297 | 3c251763d5a136da04cac7e0096e0f64c6719ab6533ce87e94721797fbe6d89d |
| artifact-manifest.json | 12347 | 73014aadabf548dfcd9c676fd504acfc60b9cb170feb1c5b2408fe528f7c42a5 |

`SESSION-STARTUP-READING.59.1` owns Perl flags and callback statement routing;
`.59.2` owns Rust target protection with `.58.1`; `.59.3` owns permanent carrier and
remaining-backend proof; `.59.4` owns public examples and canonical closeout.
All repairs follow startup prerequisites. Four focused neutral checks (typed
source, gap, diagnostic output, uniform binding) pass; they do not cover these
substitution contexts or close the defects.
