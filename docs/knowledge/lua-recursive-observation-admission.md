---
id: lua-recursive-observation-admission
title: Shared Lua privately admits recursive source observation on PUC Lua and LuaJIT across all four carriers
answers:
  - "does Lua support observe_recognition"
  - "where is Lua recursive observation implemented"
  - "what Lua action node owns observe_recognition"
  - "how does Lua validate recursive observation targets and operands"
  - "how does Lua preserve false observation payloads"
  - "how does Lua convert recursive observation UTF-8 byte offsets"
  - "how does Lua reject direct and mutual recursive observation"
  - "does Lua recursive observation reuse recognition invocation identity"
  - "does Lua retain recursive observation history"
  - "does generated Lua source execute recursive observation"
  - "does reconstructed Lua execution preserve recursive observation"
  - "does recursive observation work on both PUC Lua and LuaJIT"
  - "is Lua recursive observation admitted in canonical CI"
  - "does Lua recursive observation change the public facade"
date: 2026-08-12
status: current private shared-Lua admission on both ABIs; recurrence and public closeout pending
tags: [lua, puc-lua, luajit, source-location, recursion, observation, generated-source, admission, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.4.6 adds one Lua-5.1-compatible dedicated observe_recognition action node, compiler-wide static and transaction-effect validation, direct-parent and rejected-attempt identity in the existing RecognitionTransaction authority, pending-entry observation scopes, ephemeral runtime completions, detached typed record construction, and action-edge single dispatch. lua/test/recursive_observation_contract_test.lua passes 43 assertions independently on PUC Lua and LuaJIT across native, reconstructed, generated-plan, and independently loaded emitted-source execution, including captured bind-before-error records for direct rejection, mutual rejection, and abort. A multibyte-input case proves zero-based UTF-8-byte registers become Unicode-scalar positions only through source_location projection. The typed-source checker records Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT on the still-pending recursive_observation row at 8 complete / 6 pending / 75 mutations. Recognition remains 129 current + four dedicated transaction nodes / 246 calls / 58 mutations because observation closes through the existing binding_write effect rather than widening its public inventory."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/recursive_observation_contract_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/recursive_observation_contract_test.lua && bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && perl tools/check_language_capability_coverage.pl"
---

Shared Lua recognizes exactly `value = observe_recognition(observation, call(Child))` as one dedicated private
`observe_recognition` action node. The parser rejects a non-bare target, a dynamic or malformed operand, and a
missing static rule before execution. Compiler-wide effect closure also forbids an observation binding write from
any rule reached by `recognize_once`, including transit through ordinary rule calls and user-function calls.

The shared interpreter invokes the ordinary child exactly once and preserves its payload independently from
observation truthiness. Direct invocation invents no entry match; action-edge invocation retains the parent-selected
entry match. The child continues to own its family-derived seek/consume policy and terminal local-match register.
Normal, failed, aborted, and rejected completions bind the detached nine-field observation before returning or
propagating the unchanged typed failure.

The private recognition transaction authority is the only parse-local invocation authority. Frame entry captures
the direct parent, and pre-entry progress rejection reserves the next attempted-child identity without a frame push.
A scope intercepts only its pending observed child and disarms after successful entry, so ordinary nested
self-recursion retains the existing cutoff. A completion exists only inside the active observation boundary and is
consumed immediately. No source text, path, parser, live frame, match object, authority, host reference, second
stack, or parse-wide history escapes.

Lua retains zero-based UTF-8-byte cursor, boundary, match, and mark registers. The existing private
`source_location` authority converts entry, selected match, and accepted exit to Unicode-scalar detached records
only at projection time. Native, compiled-spec reconstruction, generated-plan execution, and independently loaded
emitted-source execution converge on the same engine. One Lua-5.1-compatible consumer proves all 43 assertions
independently on PUC Lua and LuaJIT.

The surface remains grammar-owned and private: it adds no facade export, public helper or typed value, schema
field/version, semantic/MCP projection, CLI option, or README claim. The six-runtime recurring composition and
public closeout remain separately owned by `.14.4.7-.8`.

Definitive signoff passes all eight doctrines, repository containment/relocation, primary CLI 66/66 in both option
environments, RAM 61%, Phase 0 1,031/1,031 in 734 seconds, and the complete six-runtime typed-source opt-in. The
matrix independently repeats Lua typed source 240 plus recursive observation 43 on PUC Lua and LuaJIT before the
exact local-CI success marker and exit 0. A sandboxed attempt stopped only at the outer harness's nested macOS
`sandbox-exec` denial; the unchanged permission-authorized command supplies the authoritative result.

## Links

- Neutral/audit authority: [[recursive-source-observation-audit]].
- Julia predecessor: [[julia-recursive-observation-admission]].
- Typed-source rollout: [[typed-source-location-runtime-rollout-plan]].
- Recognition authority: [[lua-recognition-transaction-admission]].
- Decision: ADR `0056`, section 26.
- Task owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.4.6`.
