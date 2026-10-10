---
id: verification-output-chunk-boundary
title: Final tool output chunks do not measure whole verification streams
answers:
  - "does original_token_count measure the complete verification run"
  - "can final tool poll counts compare Phase0 output volume"
  - "why should full verification output be retained before filtering"
date: 2026-10-10
status: current for the exec_command/write_stdin interface observed in this session
tags: [verification, tools, diagnostics, evidence]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2 output diagnostic retains a bounded two-block producer and both actual tool responses. Each result contains only its own recent stdout block; concatenation recovers the complete expected stream. The tool contract describes recent output and before-truncation token metadata."
reverify: "Read docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2-output-diagnostic/stream_probe.py and chunk-results.json. Reproduce through exec_command with an early yield followed by write_stdin; inspect each actual response and concatenate its output. Other harnesses must check their own output contract."
---

`write_stdin` returns recent output. Its `original_token_count` describes output before that response's
truncation; it is not a cumulative counter for the entire job. The retained controlled producer writes one
block, yields, then writes a different block. Actual responses contain their respective blocks only, and their
concatenation is the complete expected stream. Comparing the final responses of different long jobs cannot
establish a change in their whole output volumes.

The array-end public Phase0 run completed successfully, but its full original stream was not retained in the
repository. An initial comparison with the earlier canonical run's final response therefore used different
unestablished populations. The transport probe resolves that comparison error; it does not reconstruct the
lost stream or certify a warning count. No new runtime defect is inferred from those final-response counts.

Retain complete verification stdout/stderr in repository-derived diagnostics before filtering when output
content or volume matters. Preserve the actual command, completion result and relevant input boundary. Existing
bounded runtime producers already retain their full channels; this observation does not alter their measurements
or the array-end claim. This is qualitative tool-contract evidence, not a project performance measurement.
