---
id: conformance-write-cli-reading
title: Complete neutral write contracts and CLI guide with exact fixture reading
answers:
  - "what exact write and CLI source does conformance reading group 31 complete"
  - "why do the admitted write JSON contracts still say future-neutral"
  - "who owns the CLI guide command missing project-data setup"
date: 2026-09-13
status: scoped reading and focused checks complete; CLI guide setup repair pending
tags: [conformance, reading, mutation, cli, fixtures, storage, evidence]
evidence: "CONFORMANCE-SOURCE-READING.1.31 reads 32 complete windows over 25 paths: 1226 fragments/65536 bytes. It completes uniform binding, both write contracts, CLI README and selected output fixtures; CLI manifest1-33 remains partial. CONFORMANCE-SOURCE-READING.2.2 owns the standalone command's missing managed-storage setup."
reverify: "bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py && bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py; run the managed selected CLI command below and the reading-window recipe in conformance-source-reading-coverage."
---

Nested writes evaluate ordered segment expressions and then the RHS before
validating selector kinds and structure. The structural operation snapshots that
post-evaluation binding, builds separately and commits once. Completed expression
effects survive structural failure. Strings select harray keys; nonnegative
integers select array indexes. Arrays remain dense, and bound null is not absence.

The shared write/`map_leaves!` contract distinguishes callback-local values,
unrelated bindings, active receiver identity, shadow locals and continuation.
Unrelated completed writes survive a later callback failure. The active receiver
guard rejects a write before its segment/RHS evaluation. A returned replacement
subtree is not revisited, and a later continuation failure preserves the completed
receiver update. These are the existing neutral semantics, not new behavior.

Both JSON files deliberately retain their historical future-neutral strings.
The dated implementation, admission, recurrence and public-closeout records in
[[write-vivification-neutral-contract]] and [[write-map-leaves-neutral-composition]]
explain why those frozen strings do not describe today's implementation status.
Their current bytes and all native evidence are preserved.

Fresh neutral write validation passes five valid/seven invalid syntax cases,
11 successes, 16 structural failures, three evaluation failures, three read
exclusions, eight composed writes and 105 rejected mutations. The map checker
passes four valid/14 invalid syntax cases, five exclusions, ten successes, eight
pre-commit failures, six callback compositions, one continuation composition and
167 base plus 592 composition mutations. Uniform-binding proof remains unchanged
from `.1.30` at `74ecae96e`.

The CLI guide fixes strict schema, placeholders, raw channel bytes, workspace
files and exit status. Read fixtures cover exact help/error text, phase ordering,
trace routing and append behavior, percent-escaped fields, emoji and UTF-8 byte
counts. Manifest lines 1-33 contain both help cases and open the next case; later
manifest reading remains `.1.32`-owned. This managed command passes 2/2 on Perl:

```bash
bash tools/project_data_run.sh env PERL5LIB= perl tools/run_cli_conformance.pl \
  --case help --case help_short --display-command 'perl bin/linkedspec' \
  -- perl -I'{{REPO_ROOT}}/perl' '{{REPO_ROOT}}/bin/linkedspec'
```

`cli_conformance/README.md` lines 7-13 instead give a standalone direct command
without the initializer or managed wrapper required by [[perl-project-data-ssd-storage]].
[[neutral-cli-fixture-runner]] already includes the initializer. Targeted inspection
of the runner's entry and `File::Temp` call confirms its reliance on ambient
temporary-directory setup. This adds no full tools-source reading credit and no
unmanaged allocation was executed. Pending `.2.2.1` corrects the guide and verifies
actual workspace locality; `.2.2.2` independently checks the correction. This
slice adds no full CLI matrix, dependency build or cross-backend native admission.
