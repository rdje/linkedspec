# Publication recovery checkpoint — November 5 local date

Owner: `TYPE-REFERENCE-BOOK.1.2.23.4.10.1`; operation/outcome owner: `.10.2`.
The director explicitly resumed full PNT from clean `4df2a8cfe468c46fe269e957193765a53603a16f`.

`capture.sh` is the actual one-shot, read-only acquisition. Its retained UTC timestamp
is in `acquired-at.txt`; raw official host, SSH main, authenticated API main and
workflow responses remain alongside it. Fresh SSH/API main both name
`d3a26a94f5c2efba736806ac13911155e3739995`; Git Operations is operational at acquisition.
The script refuses replacement of any prior response. Do not replay it to refresh history.
The independent SSH/API comparison and the named component were directly inspected.
These are dated external events, not a durable guarantee about future remote state.

Initial restricted-harness reads reported DNS/network failures. Repeating through
approved host execution succeeded without any key, agent, remote or Git configuration
change. The preceding `commit_refs` rejection and separate SSH `publickey` denial in
`docs/checkpoints/pause-handoff-2026-11-04/` remain historical observations. Recovery
does not establish either previous root cause or an upload-size rejection.

The three director-supplied read-only policy files have the same SHA256 values recorded
in `SESSION-STARTUP-READING.04-49.md` and ADR `0126`. No source update is required.
The last artifact review remains within 24 hours at startup; no cleanup was performed.

Commit this focused resume/access checkpoint, then run exact clean HEAD canonical CI
in approved host execution and use normal fast-forward push hooks. `.10.2` retains
the actual push/read-back/hosted result. A subsequent outcome-record commit does not
inherit the pushed commit's receipt. No runtime feature is admitted by these events.

External access is the authorized repository/public service read with existing credentials;
all project-owned outputs stay in this repository. Other repositories and dependencies
remain read-only. Hosted push CI remains disabled under ADR `0004`.

## Successful publication outcome

Owner: `TYPE-REFERENCE-BOOK.1.2.23.4.10.2`. The default canonical gate completed
successfully in approved host execution for clean
`4683555ec51f04b8977812ce4e984c5cc6e6f42c`. The final exact committed receipt is
`canonical-4683555e.receipt`; byte-exact complete gate output is compressed in
`canonical-4683555e.log.gz`. Default optional expanded matrices stayed disabled;
this is exact default canonical proof, not independent full reference admission.

The actual command was:

```bash
git -c push.followTags=false push --porcelain --recurse-submodules=no origin HEAD:refs/heads/main
```

It exited successfully. `push-4683555e.log.gz` retains normal pre-push receipt reuse,
the verified canonical boundary and the accepted `d3a26a94f..4683555ec` main update.
No force, authentication/configuration change, tag publication or submodule recursion
was used. The earlier host rejection and separate publickey error remain unattributed.

`capture-outcome.sh` is the actual one-shot read-back and log/receipt acquisition;
`published-at.txt` preserves its UTC timestamp. `local-origin-refs.txt`,
`published-ssh-main.txt` and `published-main-ref.json` independently agree on
`4683555ec51f04b8977812ce4e984c5cc6e6f42c`. The fresh official Git Operations component
is operational. `published-head-runs.json` reports no hosted runs for that head,
consistent with ADR `0004`. These are dated observations, not future ref guarantees.
The retained compressed logs were decompressed and compared byte-for-byte with the
actual project-local execution logs before this record.

An early receipt check ran while the gate was still finalizing and rejected the
old receipt. The gate then exited successfully, wrote the exact committed receipt,
and a fresh check passed before publication. That intermediate query is not a gate
failure or authority to publish. The driver invokes Phase0 through `prove` directly;
its quiet output was checked against the active process and the retained prior run,
without restarting or weakening verification.

This later focused outcome-record commit has no inherited exact-HEAD receipt.
Its own publication occurs at the next normal canonical boundary. Recovery of the
prior committed work is complete; Rust Count73.2 is next, followed by peers/P1
copy/source73.6 and advisory growth8. No runtime or portable admission is inferred.
