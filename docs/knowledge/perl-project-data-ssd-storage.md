---
id: perl-project-data-ssd-storage
title: Perl temporary data, traces, and CLI workspaces are SSD-local
answers:
  - where do Perl File Temp allocations live
  - are Perl test temporary directories on the repository filesystem
  - where do LinkedSpec Perl trace logs live during tests
  - does the CLI conformance runner use SSD workspaces
  - is the standalone primary CLI matrix project data routed
  - how many tracked Perl temporary allocation owners exist
  - what happened to the 65 old linkedspec cli workspaces
  - were old Perl temporary directories deleted after SSD migration
  - where is the verified migrated Perl CLI data retained
  - what hash verified the Perl CLI workspace migration
  - which Perl path values remain inert fixtures
date: 2026-07-26
status: current
tags: [perl, storage, ssd, temporary-data, trace, cli, migration, PROJECT-DATA-SSD-ROOTING]
evidence: "PROJECT-DATA-SSD-ROOTING.2.1 routes the standalone primary matrix and adds tools/test_perl_project_data_storage.sh. The oracle passes from another filesystem across 24 tracked Perl allocators, default/named File::Temp, explicit trace output, and a real CLI child workspace. Sixty-five exact old CLI directories were copied to root-relative retained cache, matched at 17 files/1,590 bytes and canonical SHA-256 2a24e96043cf42b0c5e31d6b77064c64b07e36d6506ff9724d2c361f53ce8f49, exercised, then deleted; old residue is zero."
reverify: |
  bash tools/test_perl_project_data_storage.sh &&
  bash tools/project_data_run.sh --list &&
  perl -MFile::Spec -e '$root = File::Spec->tmpdir; @paths = glob("$root/linkedspec-cli-*"); exit(@paths ? 1 : 0)'
---

All supported Perl project work inherits a repository-derived `TMPDIR` from `tools/project_data_env.sh` and runs
inside `tools/project_data_run.sh`. `tools/run_ci_local.sh` already owns the reference gate; `.2.1` adds the same
boundary to `tools/run_primary_cli_matrix.sh`. Direct low-level Perl commands must source the initializer or use the
foreground wrapper documented in `README.md`.

The recurring oracle `tools/test_perl_project_data_storage.sh` is the precise family proof. It discovers its root
from its own location, enters a managed run, and verifies the run and private `tmp/` child share the repository
device. It exercises default and named `tempdir`/`tempfile` forms, both implicit and explicit `TMPDIR` selection,
routes an actual `LinkedSpec::Trace` event to a file, and launches a real neutral CLI manifest child. That child
requires its cwd to be the active run's `tmp/linkedspec-cli-*` directory and writes an exact expected artifact;
normal completion must remove the workspace.

The oracle also freezes the complete 24-file Perl allocation inventory, including the CLI runner and the oracle
generator's two stdout/stderr capture files. It deliberately retains `/tmp`-shaped semantic privacy and redaction
values because those are inert fixture data, not filesystem writers.

Migration used copy/verify/use/delete. The 65 exact old directories matched manifest case ids and the CLI runner's
six-character workspace suffix; no symlink entered the set. Their root-relative SSD destination is
`/.linkedspec-data/cache/migrated/perl-cli-workspaces/`. Source and destination each measured 65 directories,
17 files, and 1,590 bytes and matched canonical inventory SHA-256
`2a24e96043cf42b0c5e31d6b77064c64b07e36d6506ff9724d2c361f53ce8f49`. A copied nested spec/input pair produced
the exact expected JSON through the Perl primary command. Only then were the exact old sources deleted. The old
CLI census is zero; the verified SSD copy remains recoverable.

Related facts: [[project-data-ssd-storage-locality]], [[project-data-run-lifecycle]],
[[neutral-cli-fixture-runner]], [[trace-cli-control]].
