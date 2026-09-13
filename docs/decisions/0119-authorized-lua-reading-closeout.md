# ADR 0119: Close verified Lua reading and continue authorized read-only startup work

- Date: 2026-09-13
- Status: accepted under `LUA-STARTUP-READING.3.2`; explicit director disposition
- Tags: lua, reading, verification, continuity, dependency-reuse

## Context and authorization

The Lua reading-only proposal is committed at
`21210a8bcfa70f605897a13ddafa8c2fe65078ba`. The director asked what its waiver meant
and why unchanged RGX/PGEN submodules would be rebuilt. The explanation identified
one full repository CI run for Lua reading closeout, retained known failures and
excluded cases, and the pending dependency build-reuse implementation.

The director then authorized the read-only work to proceed and be unblocked:
"do what you need to do rearding read-only" and "I didn't block anything about
reading", while retaining "please do not rebuild something that does not need
to be rebuilt". This new direction authorizes the pending reading-only disposition;
it is not inferred from earlier Julia or capacity approvals.

The director subsequently confirms explicitly: "I grant your request" to waive
"one full repository CI run solely to mark the Lua source-reading task complete".
The same message again rejects repeated RGX/PGEN rebuilds when their code has
not changed. This confirms the single closeout scope recorded below.

The phrase "dependency no-build directive" used in the preceding audit and
conversation was overly broad. The requirement is to reuse compatible RGX/PGEN
products and avoid unnecessary rebuilds of unchanged dependencies. It does not
prohibit source reading or necessary builds justified by actual changed inputs.
Read-only startup work must not be blocked by that shorthand or require repeated
approval of the same authorized continuation. The exact build-on-update lifecycle
and its implementation/proof remain owned by startup .80.1-.4.

## Decision

Use focused verification to close only Lua reading `.1`, audit/closeout `.3/.3.2`
and `SESSION-STARTUP-READING.3.6`. Waive the full canonical CI run and receipt for
this documentation-only reading closeout. Explicitly retain the absence of a
passing fresh full Lua component gate and declared PUC 5.4 proof. Reexecute both
committed .3.1 recipes, verify exact source/reading/repair/history preservation,
run normal doctrine hooks, Knowledge and memory checks, both bounded-history
checks, and render/check the public book. No gate is bypassed or modified.

The audit covers all 51 source-reading commits, 149 ranges, 99 baseline-identical
files, 71,269 fragments and 2,732,450 bytes, plus 51 unchanged comprehension cards.
All 35 repair roots and 145 pending nodes remain exact. Native PUC observation
120/121 and generated observation 79/80 remain failed. Four native regex-error
package groups remain excluded; startup .28.7 retains the public-selector baseline
failure. Earlier passing focused tests stay dated; no new component pass is claimed.

After the clean per-leaf commit and zero-byte message file, continue read-only
startup .3.7: inventory and bound the 158 baseline supporting entries before reading
unread ranges. Remaining supporting lanes .3.8-.3.10, final delta audit .3.11,
formal book .4 and policy .5 remain required. The director's authorization permits
this continuation; no further permission is needed merely to read or record it.

## Consequences

- Reading completion is durable and separate from runtime or zero-defect signoff.
  All repairs and their implementation prerequisites remain open.
- No RGX/PGEN compilation, toolchain installation, cache mutation, dependency
  update, runtime repair, capacity increase or push occurs in this closeout.
- Standing executable, infrastructure, admission and final push verification
  requirements remain. Full CI should reuse compatible dependency products;
  the existing rebuild behavior is not accepted as the desired lifecycle.
- Named arguments and other parked features remain parked. Current pointers
  advance to supporting reading without rewriting historical audit evidence.

## Links

- Owner: `docs/tasks/LUA-STARTUP-READING.md`, .3.2
- Startup: `docs/tasks/SESSION-STARTUP-READING.md`, .3.6/.3.7/.80
- Committed proposal and audit: `docs/knowledge/lua-reading-commit-closeout-audit.md`
- Build-reuse evidence: `docs/knowledge/rust-ci-pgen-missing-input-rebuilds.md`
- Standing cadence: `COMMIT.md`; `docs/decisions/0073-tiered-verification-cadence.md`
