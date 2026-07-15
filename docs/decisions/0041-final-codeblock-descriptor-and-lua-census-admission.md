# 0041 - Final-codeblock functions use outward descriptor v3; Lua census admission waits for full parity

- Date: 2026-07-15
- Status: accepted
- Tags: architecture, functions, codeblock, descriptor, capability-census, lua, portability, cross-variant-parity

## Context

Lua preserves a final `name: codeblock` declaration through its typed function AST, staged payload/job, registry,
and compiled state, but deliberately refuses to emit an outward descriptor for that function. The neutral outward
union defines exact fixed-v1 and variadic-v2 records; neither record has a governed place for
`parameter_kinds`. Adding an optional Lua-only field to fixed-v1 would make an exact public record ambiguous.

The Lua parity tree also contains older wording that would expand the executable capability census during
descriptor/trace work. The later census policy admits complete backend variants, and the Lua root plus `.8.4`
already require an expanded all-pass manifest before Lua is called complete. Early expansion would create known
non-pass rows for generated source, corpus execution, and the primary CLI.

The director accepted the two recommendations from `LUA-BACKEND-PARITY.5.3.0`: define a neutral descriptor
variant now, and keep Lua outside the census until its complete parity handoff.

## Decision

1. The outward user-function descriptor is a permanent versioned union:
   - version 1: fixed parameters, with exact `params` and `arity` fields;
   - version 2: variadic parameters, with the exact `signature` field from ADR `0030`;
   - version 3: fixed parameters plus final-codeblock intent, with exact `params`, `arity`, and
     `parameter_kinds` fields.
2. A version-3 record uses this exact ordered field sequence:

   ```text
   index, kind, version, name, params, arity, parameter_kinds,
   source_text, source_span, body_span, body_source,
   body_payload, body_parse_job, body_ast
   ```

   `params` includes the final codeblock parameter, `arity` counts it, and `parameter_kinds` is an exact object
   whose sole entry maps that final parameter name to `"codeblock"`. Empty, extra, non-final, or non-codeblock
   entries are invalid. Version 3 does not carry a variadic `signature`.
3. The neutral executable contract and checker are updated before any backend descriptor emitter changes.
   `LUA-BACKEND-PARITY.5.3.1` owns that contract enforcement and Lua emission; it may align another backend only
   where an existing projection already exposes the same function, but it does not promote generic callable-
   codeblock capability or force unrelated Rust/Dart/Julia runtime work into the Lua leaf.
4. The capability census remains the current four-backend all-pass surface through Lua `.5.3`, `.6`, and `.7`.
   Descriptor/trace closeout `.5.3.3` must verify that this boundary remains intact.
5. Lua enters the executable census only at `LUA-BACKEND-PARITY.8.4`, after native runtime, corpus, primary CLI,
   generated source, and contract-sourced generated-subset proof are complete. The expansion lands all-pass in one
   slice; it does not use partial/gap rows as a progress tracker.

## Consequences

- Lua can remove `codeblock_user_function_descriptor_pending` only by consuming the exact version-3 contract.
- Fixed-v1 and variadic-v2 records remain byte/schema stable; version 3 preserves callable intent without an
  optional-field reinterpretation.
- Generic explicit codeblock literals and arbitrary dynamic calls remain owned by `FUTURE-PARITY-BACKLOG.11`.
- `.5.3.3` closes descriptor/full-pipeline trace no-drift without changing census membership; `.8.4` is the sole
  Lua census-expansion owner.
- No backend source, outward descriptor, capability manifest, public status, or test expectation changes in this
  decision slice.

## Links

- Task owner: `docs/tasks/LUA-BACKEND-PARITY.md` (`.5.3.0.1`)
- Descriptor implementation: `docs/tasks/LUA-BACKEND-PARITY.md` (`.5.3.1`)
- Census admission: `docs/tasks/LUA-BACKEND-PARITY.md` (`.8.4`)
- Fixed/variadic union: ADR `0030`
- Final-codeblock declaration: ADR `0032`
- Audit fact: `docs/knowledge/lua-descriptor-trace-admission-split.md`
