# Publication prerequisites observed during Lua80.5

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.80.5; repair owner:
TYPE-REFERENCE-BOOK.1.2.23.4.14 (P1 before memory-guarded full verification).

At activationfb613736f, the existing local canonical runner1323-1345 duplicates
the denied-sysctl16GiB fallback already owned in ram_guard. A4.14 fix must cover
both producers and their current/older threshold instructions before full CI is
relied on. No canonical job was started here. Source card:
docs/knowledge/canonical-ci-ram-fallback-prerequisite.md. This source observation
is recoverable from the activation Git object; it is not original OS-call custody
or a new actual-memory measurement. Focused Lua jobs used their own retained
memory_pressure preflight and serial workers.

A managed pgrep query during gate observation returned exit3 and exactly:

```text
sysmon request failed with error: sysmond service not found
pgrep: Cannot get process list
```

No process was signalled and no native PID/PGID fact was obtained. Existing
SESSION-STARTUP-READING7 owns liveness restrictions; harness job status remains
the source for in-flight commands. Do not retry native process probing to infer
a completed historical job's liveness.
