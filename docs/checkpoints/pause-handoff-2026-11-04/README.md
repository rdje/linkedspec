# Director pause and publication recovery — November 4

Owner: `TYPE-REFERENCE-BOOK.1.2.23.4.9`. Recovery owner:
`TYPE-REFERENCE-BOOK.1.2.23.4.10`, first **only on explicit director resume**.
This is operational event custody, not a new population, performance or feature admission.

The director requested the next handoff-ready checkpoint. The current infrastructure unit
completed at `5801970b4d311e97b5764d16a2573a4094144e49`: normal hooks passed all ten doctrines,
the post-commit pointer check passed, and the exact canonical receipt was promoted.
`commit.log` and `canonical-5801970b.receipt` are byte-for-byte copies from that execution.
The complete local gate log remains project-local at
`.linkedspec-data/logs/task-budget-canonical.log`; the tracked unit's source and focused
evidence are under `docs/checkpoints/task-budget-renewal-2026-11-04/`.

The next normal push ran:

```bash
git -c push.followTags=false push --porcelain --recurse-submodules=no origin HEAD:refs/heads/main
```

It exited 1. `push-rejected.log.gz` preserves the byte-exact actual output (including server trailing spaces, compressed to retain them without a whitespace edit), including successful exact
receipt reuse followed by `remote: fatal error in commit_refs` and a remote rejection.
No force push, ref rewrite, authentication change or submodule publication was attempted.
The earlier huge backlog was already published successfully at
`d3a26a94f5c2efba736806ac13911155e3739995` through bounded uploads; this later failure does
not undo that publication. The subsequent maintenance commits remain local.

`capture.sh` is the actual one-shot read-only acquisition of `github-status.json`,
`main-ref.json`, `repository.json` and `workflows.json`; it refuses output replacement.
The status response has page update `2026-11-04T10:21:30.929Z`, marks Git Operations
`degraded_performance`, and reports incident `smtdswd1h2w4` as investigating.
The independently authenticated API main ref still names `d3a26a94f5c2`.
These observations are consistent with a host incident; they do **not** establish the
repository-specific server root cause, an oversized pack, or a repository-size rejection.
The repository API's `size` field is retained as an unconverted server field, not a wire
or exact server disk measurement. No additional pack-size estimate was performed here.

A subsequent read-only SSH `git ls-remote --refs origin refs/heads/main` returned
`Permission denied (publickey)` while authenticated API reads succeeded. That is a separate
observed channel failure. No key, agent, remote URL or Git configuration was changed.
Recheck access and host state at recovery instead of assuming the two errors have one cause.
The tool response retained this SSH diagnostic in the session; the exact push failure is
retained as its original log here.

The additional actual read-only post-publication monitoring command was:

```bash
gh api 'repos/rdje/linkedspec/actions/runs?head_sha=d3a26a94f5c2efba736806ac13911155e3739995&per_page=20' --jq '{total_count,workflow_runs:[.workflow_runs[]|{id,status,conclusion,head_sha,html_url}]}'
```

Its output is `published-head-runs.json`. The workflow API's `active` state denotes the
registered manual workflow, not enabled push CI. The tracked workflow remains
`workflow_dispatch` only with `if: false`, as required by ADR `0004`. Local canonical CI
is the verification authority. The rejected local commit has no successful publication
to monitor.

The pause documentation commit is a later focused unit; the retained receipt above names
only `5801970b`. It cannot authorize a later HEAD. Recovery must obtain exact final clean
HEAD canonical proof, use normal push hooks, and verify fresh local/origin/API refs.
The pause itself does not wait for the incident or activate Rust Count73.2.

Primary references consulted:

- [GitHub incident](https://www.githubstatus.com/incidents/smtdswd1h2w4)
- [GitHub repository limits](https://docs.github.com/en/repositories/creating-and-managing-repositories/repository-limits)
- [GitHub 2 GiB push troubleshooting](https://docs.github.com/en/get-started/using-git/troubleshooting-the-2-gb-push-limit)

External access was read-only acquisition of the user-authorized GitHub repository and
public GitHub service status, including existing authentication/toolchain inputs. All
project-owned outputs are repository-relative on the repository volume. Other repositories,
dependency stores, source history and verification artifacts remain untouched.
