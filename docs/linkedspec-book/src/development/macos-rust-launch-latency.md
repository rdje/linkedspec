# Diagnosing macOS Rust Launch Latency

A silent Rust test process is not necessarily executing a slow or looping test. On macOS, policy assessment can
delay an ad-hoc Cargo test binary before Rust `main`. Keep compilation, first process launch, and test execution as
three separate measurements.

Use LinkedSpec's repository-routed Cargo wrapper for the build:

```bash
bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml \
  -p linkedspec-runtime --test trace_controls --no-run
```

For a suspected launch delay, identify the exact test binary and time `BINARY --list` twice inside a managed run.
The `--list` operation excludes test-body work. Process census plus read-only extended-attribute and code-signature
inspection can then distinguish an OS policy wait from compilation or runtime behavior.

The controlled macOS 26.5.2 investigation measured two older binary hashes at `45.32s → 0.00s` and
`51.75s → 0.00s` for first versus warm inventory launches while `syspolicyd` owned CPU time. In contrast, two
unique fresh builds completed in `37.18s` and `23.17s`; the first hash's signed-copy/original comparison ran in
`0.44s/0.45s`, and the second wholly unmanipulated provenance-tagged linker-signed hash first-launched in `0.41s`.
The incident was therefore external per-artifact policy/cache state, not a persistent LinkedSpec defect.

Do not respond by disabling Gatekeeper, clearing shared or original provenance metadata, re-signing accepted test
artifacts, deleting a target owned by another process, moving caches off the repository volume, or reducing test
coverage. Preserve the evidence and rerun from controlled serial ownership instead.
