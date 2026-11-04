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
