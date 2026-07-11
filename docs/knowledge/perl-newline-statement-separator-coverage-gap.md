---
id: perl-newline-statement-separator-coverage-gap
title: "Perl newline statement separation is not yet universal across assignment, cursor/capture, and marker-helper sequences"
answers:
  - "do all newline separated ActionIR statements currently lower in Perl"
  - "why do newline separated capture helper assignments fail in Perl"
  - "why do newline separated cursor controls fail in Perl"
  - "why do newline separated if elseif marker chains fail in Perl"
  - "what does FUTURE-PARITY-BACKLOG.1.6.1.1 own"
date: 2026-07-10
status: confirmed-gap
tags: [actionir, statement-split, newline, semicolon, perl-reference, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.0 toolbox audit, 2026-07-10. `call_spec_handler_subst` on `slice = capture_slice()\nslice_len = capture_slice_len()` emitted the first assignment as `$slice = do { ... }` without a generated separator and left `slice_len = do { ... }` as a raw target. Cursor-control sequences showed the same missing boundary/raw-target pattern. Newline-separated `if`/`elseif` marker sequences left inner assignments or `elseif(...)` raw, while the same marker sequence on one physical line with explicit semicolon separators lowered and executed. The established contract remains that physical newlines separate statements and semicolons only separate multiple statements on one line; this is an implementation coverage gap, not a contract change. FUTURE-PARITY-BACKLOG.1.6.1.1 owns root cause, repair, focused locks, and unchanged cross-backend proof."
reverify: "perl tools/check_language_capability_coverage.pl --report && rg -n 'FUTURE-PARITY-BACKLOG\\.1\\.6\\.1\\.[012]' docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

# Perl Newline Statement-Separator Coverage Gap

The public statement-separator contract is unchanged:

- a physical newline separates adjacent top-level statements;
- a semicolon separates adjacent statements only when they share one physical line; and
- the final statement on a line does not require a trailing semicolon.

The earlier focused lock proved a narrow `set(...)` then `return(...)` path. The exhaustive current-call audit
shows that this did not establish universal Perl reference coverage. Consecutive capture assignments, cursor
controls, and marker-style control statements can still cross lowerer seams where the previous generated Perl
statement receives no terminator or the next assignment target remains raw.

The audit fixture sources live under `capability_conformance/fixtures/`. They remain outside the generated neutral
corpus until `.1.6.1.1` repairs the common boundary and `.1.6.1.2` proves them unchanged on every backend.

## Links

- Contract: [[terse-statement-separator-contract]].
- Historical narrow repair: [[terse-literals-calls-separators-access-ground-truth]].
- Attached-control seam: [[terse-perl-attached-if-statement-split-seam]].
- Owner: [[FUTURE-PARITY-BACKLOG]] `.1.6.1.1`.
