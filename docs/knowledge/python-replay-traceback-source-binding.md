---
id: python-replay-traceback-source-binding
title: A Python compile filename does not bind displayed traceback source
answers:
  - "why does replaying retained Python source show newer traceback lines"
  - "how should a failed Python reviewer replay bind diagnostic source text"
  - "can a logical compile filename authorize diagnostic source identity"
date: 2026-10-05
status: reproduced and repaired within statement-family acceptance .1.1.1.3
tags: [python, diagnostics, evidence, source-identity, input-closure]
evidence: "Two actual uncached failed-review channels show source lines from the newer logical file instead of the executed retained bytes. Fresh bound replays reproduce the original heading AssertionError and contract KeyError with all six logical frames matching the original source. Both old contexts and four producer/channel/completeness corruptions observe RED."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.3-review-retention.py --review"
---

Python compile(source, filename, 'exec') binds bytecode coordinates to filename.
Traceback formatting can separately fetch displayed source through linecache using
that logical filename. Executing an immutable source copy under its original filename
can therefore display newer disk lines, including a corrected comprehension beside an
original KeyError. The filename does not establish executed source identity.

The retained replay-review.py supplies the original UTF-8 text in a virtual linecache
entry before execution. Its mtime=None prevents file-cache revalidation from replacing
that text with a newer disk file. review-retention.py independently extracts every
logical traceback frame and compares the displayed line with the executed original
source at the reported line number. It binds the actual source, logical-file bytes,
replay and capture producers, shared oracle/input artifacts, commands, exits and full
channels with before/after input guards. Host Python and its standard library are
necessary read-only execution prerequisites; this is a dated same-host proof.

The original uncached diagnostics and producers remain exact, explicitly limited
initial evidence: their formatter input was not bound and is not retroactively claimed
recovered. The runtime recurrence is unaffected. Its complete immutable Git inputs,
80 fixture groups, 66 compiler inspections, 177 frames and 111 event origins remain at
the original ab2c activation boundary. An interrupted canonical attempt retains its
original staged diff and actual combined output with observed exit143; no canonical
pass or receipt is claimed for that attempt. The corrected candidate must rerun CI.
