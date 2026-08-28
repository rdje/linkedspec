---
id: structural-progressive-staged-authoring-doctrine
title: LinkedSpec authoring uses simple boundary regexes, linked-rule recursion, and progressive/staged parser composition
answers:
  - "how should LinkedSpec spec files use regexes"
  - "should spec regexes be recursive"
  - "where should recursion live in a spec file"
  - "what are zero one and two regex rules for"
  - "what is a leaf rule"
  - "what is a node or dispatch rule"
  - "what is progressive parsing"
  - "what is the difference between progressive and staged parsing"
  - "why are there many cursor relative capture helpers"
  - "can a spec invoke other specs during parsing"
  - "can returned AST fields be parsed again"
  - "what owns the structural progressive staged authoring clarification"
date: 2026-08-01
status: current
tags: [architecture, authoring, rules, regex, recursion, progressive-parsing, staged-parsing, parser-composition]
evidence: "Director clarification on 2026-07-12 establishes the authoring doctrine and extends ADR 0012 without replacing it. Typical .spec rules use zero, one, or two small readable regexes: one-regex leaf rules recognize unstructured parts; two-regex node/dispatch rules use a first entry/start boundary and an optional second exit/end boundary around linked child structure; zero-regex rules coordinate structure, including blind-call paths. Deep recursion belongs in the rule graph through action-edge OR dispatch and blind-call AND composition, not recursive regexes. Progressive parsing means an active parser captures text relative to reliable cursor anchors and invokes any required loaded spec parser over that extracted text. Staged parsing means an AST level may return bounded raw fields that later spec parsers refine into richer AST levels. Existing ADRs specify neutral parse jobs and deterministic dispatch, and the current function-body prototype proves one narrow family; general public parse_job authoring, multiple payload parser families, arbitrary in-parse composition, and recursive queues remain future work under parent FUTURE-PARITY-BACKLOG.14, specifically progressive .14.6 and staged .14.7. FUTURE-PARITY-BACKLOG.14.1.2 aligns the sole-facing mdBook on 2026-08-01: the rule/regex guides teach the current executable shapes, and the unchanged portmap/EBNF complex-regex implementations are framed as compatibility facts rather than the preferred general idiom."
evidence_update_2026_08_28_progressive_and_staged_delivery: "FUTURE-PARITY-BACKLOG.14.6 delivers exact progressive dispatch_span authoring and recurrence. FUTURE-PARITY-BACKLOG.14.7.2-.9 deliver the separate general staged-v2 contract, all five backend sources/six runtime routes, recurrence, and exact scalar assignment-form public parse_job authoring. Dynamic loaders/providers/callbacks remain intentionally denied rather than pending."
reverify: "rg -n 'FUTURE-PARITY-BACKLOG\\.14|recursive regex|complex regex|linked opener/closer|target = parse_job|dispatch_span' docs/tasks/FUTURE-PARITY-BACKLOG.md docs/tasks/STAGED-LINKED-PARSING.md docs/decisions/0012-staged-linked-parsing-architecture.md docs/linkedspec-book/src"
---

The target authoring model separates three responsibilities.

1. **Rule structure:** regexes mark small, readable lexical or boundary facts. A typical
   leaf rule needs one regex. A typical structured node/dispatch rule has an entry/start
   regex and, when needed, an exit/end regex. A zero-regex rule can coordinate linked
   parsing without selecting an entry regex. These are authoring roles, not a new hard
   syntactic maximum.
2. **Progressive parsing:** while parsing, a spec uses clear anchors and cursor-relative
   capture/extraction to isolate text that is difficult to parse in situ, then invokes
   the appropriate loaded spec parser over that extracted text. The intended architecture
   permits composition with any number of spec parsers; actual public/runtime breadth
   must be audited and proven before documentation claims it is already complete.
3. **Staged parsing:** an AST level may deliberately return exact extracted text fields
   with provenance. Later stages select those fields, run other loaded spec parsers, and
   stitch richer AST results into the next AST level.

Deep/nested recursion belongs primarily in connected rules: action-edge OR dispatch
selects child rules by recognizable boundaries, while blind-call AND composition orders
structural work. Recursive or elaborate regexes obscure that graph and are not the target
general `.spec` idiom.

This clarification extends the accepted staged-linked-parsing architecture in ADR 0012. The current project has
both the unchanged narrow function-body `body_parse_job` path and exact public general-v2
`target = parse_job(source_bound_text, hash(literal options))` authoring with breadth-first recursive scheduling.
Authored callbacks, dynamic composition, filesystem/URI loading, provider queries, compilation, and registry
mutation remain denied by the authority model.

## Public teaching status

`FUTURE-PARITY-BACKLOG.14.1.2` aligns the sole-facing rule-paragraph, regex, walkthrough,
shipped-corpus, and project-status pages with this doctrine. The current engine facts are
unchanged: zero/one/two-regex shapes and regex-bearing entries execute, while elaborate
host regexes remain supported.

The portmap five-capture classifier and EBNF recursive payload regexes still exist and
remain documented accurately. They are compatibility descriptions, not recommendations
for new structural parsers. Exact progressive `dispatch_span` and staged assignment-form `parse_job` dispatch are
current; broader dynamic host authority is not part of the authored surface.
