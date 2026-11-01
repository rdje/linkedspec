---
id: doctrine-tracked-path-argv-limit
title: Two doctrine checkers exceed the process-launch argv limit
answers:
  - "why do path portability and project storage checks fail Argument list too long"
  - "which task owns E2BIG in the pre-commit doctrine checks"
  - "does an Argument list too long failure mean the path policy scan ran"
date: 2026-11-01
status: reproduced; P1 repair pending before admission and push
tags: [doctrine, hooks, paths, storage, argv, e2big]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.5; gate-argv-limit-intake.json.gz retains actual filename vector and checker bytes with distinguishing launch controls."
reverify: "Use the retained NUL vector as argv to perl -e 'print qq{started\n};'; the original launch fails E2BIG while a README.md-only argument succeeds. Current checkout growth may alter the vector; no exact portable threshold is claimed."
---

Both `scripts/check_repo_root_path_portability.sh` and
`scripts/check_project_data_storage_locality.sh` read `git ls-files -z` into a
Bash array and pass every filename as an argument to a single Perl launch.
Normal pre-commit during73.1 reports `Argument list too long` at these launches.
A minimal Perl launch with the same retained vector fails errno7 (`E2BIG`);
a single-path launch succeeds. The policy code does not execute on this failure.

The repair owner is P1 `TYPE-REFERENCE-BOOK.1.2.23.4.5`, scheduled in the
infrastructure prerequisite window after feature coverage/document pressure and
before full admission or any push. Stream exact NUL-delimited paths through
stdin or a repository-local manifest, retain existing policy semantics and add
a distinguishing large-list control. No fix or completed policy scan is claimed.
