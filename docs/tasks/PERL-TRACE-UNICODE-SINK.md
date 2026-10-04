# PERL-TRACE-UNICODE-SINK: preserve Unicode trace payloads without host warnings

## Metadata

- Tree ID: `PERL-TRACE-UNICODE-SINK`
- Status: `pending`
- Created: `2026-10-04`
- Last updated: `2026-10-04`
- Owner: repo-local workflow
- Priority: P2 — developer diagnostics warn on accepted Unicode source.

## Goal and schedule

Repair the Perl trace sink's character/byte boundary through its published trace controls.
This defect is owned here during quoted-source diagnosis; the active compiler leaf continues
without a dirty-tree pivot. Activate this repair after the current compiler readiness prerequisites
and their clean committed handoff. Existing TRACE-OBSERVABILITY completion remains historical;
this newly reproduced Unicode sink scope is separate.

- ID: `PERL-TRACE-UNICODE-SINK.1`
  Status: `pending`
  Goal: Make routed/mirrored Unicode trace output warning-free without altering payloads or stdout routing.
  Reproduce: Run bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py trace. The complete unicode_crlf process has exit0, six Wide character in print warnings at perl/LinkedSpec/Trace.pm line199; the preserving capture command returns1. Other21 trace processes have no stderr. The exact authored source/action, full trace bytes and raw process stderr remain in .7.2.1-trace.json; this is a tool warning, not a failed literal parse or quote repair.
  Root cause: Public configure_trace routes the Unicode action trace into _trace_write_raw. Its append filehandle at Trace.pm:198 is opened without an encoding layer and prints the character payload at199. No implementation changes are made during diagnosis.
  Impact: Accepted non-ASCII text produces host warnings during diagnostics and contaminates stderr; it prevents quiet trace acceptance. Trace contents still need exact byte verification before any fix claims preservation.
  Acceptance: Declare exact paths/tier/evidence before implementation; reproduce routed and mirrored Unicode, ASCII, emoji, append/reset and quiet controls through the public trace facade, preserve raw channels and trace bytes, prove a bounded encoding repair with actual RED/GREEN and direct consumer checks. Update Toolbox/book/Knowledge/live docs and commit with the normal workflow. No blanket warning suppression or loss of payload data.
  Verification: `pending`
  Commit: `pending`
