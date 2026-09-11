# ADR 0116: Approved finite Julia Knowledge and decision capacity

- Date: 2026-09-11
- Status: accepted under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.13`; explicit director approval
- Tags: documentation, knowledge, capacity, continuity, verification

## Context and authorization

The director answered **Granted** to the complete proposal committed at
`63523d44898f6831e7c450786d1ac5a3f0a64015`: both exact aggregate line limits
and the containment .13-only focused-verification exception, including this
bounded implementation before full codebase reading. The original proposal
remains intact in `docs/tasks/JULIA-STARTUP-READING.md`, Capacity proposal .5.1.

Julia reading has completed 37/52 groups; fifteen children and bounded audit,
closeout and capacity work remain. Knowledge uses exactly 72,000 lines after
68 new checkpoint lines were routed byte-exact to their task with three card
pointers. This preserves retrieval but leaves no further fact-card allowance.
Existing decisions use 11,997/12,000 lines, so the full proposal was retained
in its task owner until this approval. No sufficient removable duplication is
established. Splitting members cannot reduce aggregate lines; deleting unique
evidence or packing it into dense lines is not an acceptable remedy.

## Exact reviewed transitions

### Knowledge cards

- Routed surface: `knowledge_cards`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":1152,"max_lines_per_file":512,"max_total_bytes":6291456,"max_total_lines":72000}`
- New routed limits: `{"max_bytes_per_file":65536,"max_files":1152,"max_lines_per_file":512,"max_total_bytes":6291456,"max_total_lines":79000}`

### Decision records

- Routed surface: `decisions`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":128,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":12000}`
- New routed limits: `{"max_bytes_per_file":65536,"max_files":128,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13000}`

## Decision and finite reserve

Change only these two registry scalars. Stable responsibilities remain
`docs/knowledge/` and `docs/decisions/INDEX.md`. All member, file-count and byte
limits, routing contracts, guard code, task/map/history/README controls and
previous source, card, decision and immutable history bytes remain unchanged.
Containment .13 owns this atomic transition and its current continuity mirrors.

The fixed 36 unconstrained reading commits through .1.36 add 5,279 Knowledge
lines /315,921 bytes /25 files, with per-unit maxima of 316 lines /17,674 bytes
/one file. Twenty finite units reserve 6,320 lines; the alternative recent-mean
model reserves 4,472. At the proposal baseline, the larger model projects
78,320 lines, leaving 680 below 79,000. Three decision records plus index rows
reserve 486 lines /30,000 bytes /three files, projecting 12,483 lines.

The complete reserve also retains 1,440 task lines /197,500 bytes /two files,
320 map lines /72,120 bytes and 353,480 Knowledge bytes /twenty files. Recheck
the actual final candidate plus the entire reserve again, conservatively
counting this admission overhead twice. Preserve per-member checks. History
capacity remains governed by ADR0115 and each actual rollover.

This forecast covers fifteen remaining Julia reading children, proposal,
admission, independent audit, reading closeout and one contingency. It is
not a guarantee about unknown findings, a Lua/runtime-repair allowance or an
automatic later increase. Remeasure each leaf and retain readable evidence.

## One-time verification exception

The director explicitly grants focused proof for containment .13 without a
canonical CI receipt. Run exact two-scalar/source/card/question/task/history
preservation, the full current-plus-reserve census, actual production-validator
inclusive/overflow and unauthorized-change cases, all nine normal doctrines,
Knowledge synchronization, memory checks, both history pressure checks and
rendered-book verification. Normal hooks remain enabled.

This exception applies only to .13. No standing policy or gate changes, later
milestone exception or push waiver follows. No canonical CI or dependency
build is claimed or authorized here. The PGEN/RGX build-on-submodule-update
implementation remains separately owned by startup .80. All remaining reading
prerequisites and previously owned parser defects remain open.

## Consequences and handoff

Close Julia .5 after verified implementation, commit this capacity boundary,
clear the brief and prove clean before resuming Julia .1.38. Reverting the
limits later requires the resulting population to fit; never discard evidence
to force rollback. Proportionate governance follows ADR0115's operating principle.

## Links

- Owner: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`, leaf .13
- Proposal and intake: `docs/tasks/JULIA-STARTUP-READING.md`, .5 and .5.1
- Governing policy: `README_POLICY.md`; standing verification: ADR0073
- Implementation proof: `docs/knowledge/julia-evidence-capacity-admission.md`
