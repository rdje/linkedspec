---
id: lua-ordinary-loader-roles
title: Lua syntax loads do not execute the driver or bind package origin
answers:
  - "does assert loadfile run the Lua shared test driver"
  - "does a Lua test input root override select the linkedspec package"
  - "which ordinary Lua capture helpers read their output back"
date: 2026-11-16
status: bounded source and inert-header qualification; full origin and admission open
tags: [lua, loaders, fixtures, grammar, captures, source-origin]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.0; docs/checkpoints/lua-ordinary-loader-qualification-2026-11-16/REVIEW.md. Lua16/io43/bindings87/syntax30/support3/current165; fourteen controls and toy-only invocation inverse."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/lua-ordinary-loader-qualification-2026-11-16/review_qualified.py; bash tools/run_python_project_data.sh docs/checkpoints/lua-ordinary-loader-qualification-2026-11-16/probe.py --review"
---

Fifteen of the remaining16 Lua consumers use `assert(loadfile(...))` to compile
the interpreter and shared runner without calling the returned chunks. Six use
input-root prefixes for file reads; their literal package request stays
`require("linkedspec")`. Those checks supply neither shared-driver execution
nor actual package/cache/native origin proof. An isolated exact header with an
inert package distinguishes zero calls from a toy-only added invocation.

Three newer captures read back equal parsed/emitted bytes before restoration/
target compilation and emitted loading respectively; parsing already happened.
Eight older captures only write after compile/restore; Count-guard emits stdout.
Count-source accepts a present empty environment string. Preserve these roles,
timings and exact exclusions; do not infer earlier SDK custody from them.

The older root ledger corroborates29 source/input identities;30 selected current
targets are absent. Neither population supplies historical execution evidence.
Remaining semantic/transitive/local-selection review and registration4.1.2 stay
open; complete native/per-read/source-origin/physical custody remains4.2/SESSION5.
