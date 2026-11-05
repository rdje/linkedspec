# Rust Count Array-only source fallback

Owner: `TYPE-REFERENCE-BOOK.1.2.23.3.73.6.2`.
Activation: `0d054e8ab800f7245cd329741d0a94e72b10b21c`.

`count_source_fallback.rs` consumes the authored20
`tests/fixtures/count_source_fallback_cases.json`. The source/copy controls retain
the existing reference Count and ADR0138 targets; the added length control
distinguishes Count's Array-only producer from general string/Array length.
The unchanged20-case normal moves17PASS3RED to20PASS. The three failing groups
are free, initial receiver and free-copied non-array source domains, not three
separately counted causal defects. Array counts, copied receiver rejection,
primitive kinds, zero/null, source errors/snapshots, missing reads, function scope
and rejection/copy effects remain healthy.

The recovered owned `observer.rs` uses only public SDK parsing, validation,
compilation, serialization, plan execution and source emission. `capture.py`
retains actual root Cargo test inputs, standalone observer inputs and generated
host source/manifests/resolved locks before their first respective executions.
All archives use repository-relative members. After execution, actual surviving
bytes must match the first archive before redundant owned acquisition directories
are removed. Global managed caches and other repositories are preserved. Root
normal and standalone native/restored/plan observations plus independently
compiled emitted modules all retain the same three baseline failing groups;
all final observations match. Bool/Number/String/null are compared strictly.
`compat.py` retains its own actual inputs before the current Count diagnostic1
and Count/length1 focused tests. Cargo is offline/locked with one worker/test
thread and86% RAM admission; host memory was actively monitored below86%.

Initial acquisition qualification: `before` completes the root normal but its
first producer derives an absolute BASE. Tar strips the leading slash and the
native archive membership assertion stops before standalone native or emitted
execution. This setup failure gets no additional product RED credit. The initial
producer, root first inputs/results and failed native archive are retained.
Verified relative packaging preserves the initial project bodies. The first
traceback appeared in the tool output but was not separately redirected; its
failure note is explicitly transcribed. `before-qualified` corrects the paths and
fully completes before production. Historical command instances inside raw
evidence are records, never relocation-dependent execution recipes.

`package-initial-inline.py.txt` preserves the actual inline packaging source as a
historical text artifact; never execute it again. Two unused imports in the new
normal were removed after the semantic acquisition. The separate `cleanup`
capture retains the exact final normal/Cargo inputs and final20-pass run without
owned test warnings; prior raw warning-bearing phases stay unchanged.

`review.py` reads frozen channels/targets and validates every retained input
archive without extracting or executing members. It distinguishes setup, expected
source errors, baseline mismatches and final passes. Default review is readonly:

```sh
bash tools/run_python_project_data.sh docs/checkpoints/count-source-rust-2026-11-05/review.py
```

Acquisition writers are one-shot; never replay them over retained directories.
Current behavior can be rechecked with:

```sh
bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline \
  -j 1 -p linkedspec-runtime --test count_source_fallback -- --test-threads=1
```

The original73.2 diagnostic fixture and assessment73.6.0 remain unchanged.
Current diagnostic assertions now use the reference zero target. These captures
retain direct actual Cargo inputs; remaining owned SDK source is recoverable from
activation Git plus the retained owner. Complete transitive/native/toolchain
closure, earlier input gaps, general isolation, recurring registration and full23.4
remain separately owned. No full suite, portable admission or publication follows.
