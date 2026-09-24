---
id: rust-single-index-read-bypasses-typed-binding
title: "Rust single-index reads use current typed array bindings after startup .88"
answers:
  - "why does Rust items[0] return null after items is assigned an array"
  - "why does an indexed Rust hash key become an empty string"
  - "why does Rust items.first work while items[0] fails"
  - "which task owns the Rust IndexedVar typed-binding repair"
  - "do Rust array index reads observe rebinding and saved array snapshots"
date: 2026-09-24
status: repaired and verified under SESSION-STARTUP-READING.88
tags: [rust, bindings, arrays, indexed-read, hash, SESSION-STARTUP-READING]
evidence: "Seven asserted public Rust CLI and Perl Toolbox controls are preserved in docs/checkpoints/SESSION-STARTUP-READING.88-indexed-read.json. Compact/spaced keys[0] and items[0] produce an empty hash key on Rust; a direct keys[0] read returns null. Perl returns the bound element. Plain binding and first() controls agree. Rust grouped access succeeds; its Perl grouped-postfix counterpart is an excluded unresolved grouping form, not portable success evidence. Pre-repair first-party source identified the distinct IndexedVar/get_array and get_bare_value paths."
reverify: "env PERL5LIB= bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test indexed_value_reads; replay the 17 source/input pairs in docs/checkpoints/SESSION-STARTUP-READING.88-indexed-read-repair.json."
---

## Measured baseline before the repair

The compact-key repair `.50` exposed this independent runtime failure. Adding
whitespace before the hash colon does not change it. Given `keys = ["a"]`, both
`{keys[0]:7}` and `{keys[0] : 7}` return `{"":7}` on the measured Rust CLI. Using
the binding name `items` has the same result. A direct `keys[0]` read returns
`null`, although `keys` returns `["a"]` and `keys.first()` returns `"a"`.
All six ordinary Perl controls return the correct binding or element value.

In `rust/linkedspec-core/src/expr.rs`, `parse_var_or_call` emits `IndexedVar`
for one non-key access segment. In `rust/linkedspec-runtime/src/engine.rs`, the
pre-repair `IndexedVar` evaluation branch called `ctx.get_array(name)`. The implementation in
`rust/linkedspec-runtime/src/runtime.rs` reads only the separate `arrays` map.
Ordinary assignment uses `set_scalar` for the typed array value. `Variable`,
`NestedAccess`, and grouped `ValueAccess` use the current typed binding instead.
The resulting undefined indexed value stringifies to an empty hash key.

The Rust-only `(keys)[0]` control returns the correct value through `ValueAccess`.
Perl leaves that grouped-postfix spelling unlowered and records a
`rule_handler_compile` error, so it is not a portable workaround. `.87.4` retains
grouped-expression contract reconciliation; `.88` repairs admitted indexed reads.
For the measured first-element case, `keys.first()` works on both engines.

The checkpoint retains source, input, expected values, actual stdout/stderr,
Perl lowering/runtime context, and the baseline Rust binary SHA-256. Its observed
failures are diagnostic evidence, never acceptance expectations. `.50` excludes
this read from its positive separator matrix and scheduled `.88` next.

```bash
bash tools/project_data_run.sh env PERL5LIB= PYTHONDONTWRITEBYTECODE=1 python3 - <<'INDEX_READ_REPLAY'
import json, subprocess
from pathlib import Path
checkpoint = json.loads(Path('docs/checkpoints/SESSION-STARTUP-READING.88-indexed-read.json').read_text())
for case in checkpoint['cases']:
    result = subprocess.run(
        ['rust/target/debug/linkedspec-rust', '--inline-spec', case['source'],
         '--input', checkpoint['input'], '--trace', 'low'],
        capture_output=True, text=True, timeout=120)
    print(json.dumps({'case': case['name'], 'expected': case['expected'],
                      'exit': result.returncode, 'stdout': result.stdout,
                      'stderr': result.stderr}, ensure_ascii=False))
INDEX_READ_REPLAY
```

Perl authority for each retained source is `LinkedSpec::Get` with
`runtime_ctx_ref`, paired with `LinkedSpec::call_spec_handler_subst('Top', action)`.
The checkpoint includes their complete structured results and any raw diagnostic
output; the grouped-postfix exclusion must not be counted as a Perl success.

## Typed-binding repair

Focused acceptance passes397 runtime tests, the separately compiled emitted book
example,26 Perl book assertions, rendering/exact HTML source-result checks and
the neutral binding contract. Exact commands, source/log identities and scope
are retained in `docs/checkpoints/SESSION-STARTUP-READING.88-verification.json`.

Fresh `.88` public proof is preserved in
`docs/checkpoints/SESSION-STARTUP-READING.88-indexed-read-repair.json`: all17 Perl
values agree before/after, and exactly12 wrong Rust values become correct while
five controls remain unchanged. Sources, expected values, public trace streams,
Perl lowering/context and both CLI binary identities are retained.

`.88` replaces the private-map lookup with `array_index_value(&ctx.get_bare_value(name), index)`.
The index expression still runs before the binding is read, and the existing numeric
conversion remains unchanged. The helper returns a cloned array element or `Undef`
for an absent element or a non-array value. Old private array entries cannot override
a later typed binding. No parser AST, serialized format, selector policy, or write
classification changes.

The permanent runtime matrix covers 17 public Perl/Rust controls plus one Rust-only
grouped receiver, both line endings, exact authored action source, parsed/compiled
serialization, native/reconstructed reuse, and generated-plan execution. Three engine
regression groups cover stale private storage, absence without creation, existing
Rust read-index coercion, and index-expression effects before binding resolution.
Their coercion controls preserve Rust behavior; they do not admit a new portable
negative, fractional, or nonnumeric index contract.

The book includes `examples/indexed-value-reads.spec` directly. Perl native/generated
and separately compiled Rust emitted-source tests consume that same source. Its
saved nested array remains detached after a later write; rebinding changes the
indexed value and computed hash key. Regenerate/rebuild emitted Rust parsers with
the repaired runtime. Perl grouped-postfix support remains separately owned by `.87.4`.

Related: [[uniform-binding-neutral-contract]], [[terse-rust-duck-typed-assignment-parity]],
[[rust-hash-separator-and-cat-arity-defects]].
