---
id: perl-unicode-artifact-filename-aliases
title: Unicode rule-label artifact names can alias on the repository filesystem
answers:
  - "why did Töp decomposed Top and lowercase top generated artifact files overwrite each other"
  - "how should Unicode label fixtures name generated files portably"
date: 2026-10-29
status: instrument defect repaired in48.2.6.1; ASCII artifact IDs required
evidence: "perl-unicode-operand-intake.json.gz retains actual device/inode/hash alias receipt, failed integrity check, per-row sources and numeric-name restoration producer."
reverify: "Restore retained alias receipt and producer under owning leaf; fresh runtime replay compares restored source bodies against per-row retained artifacts before loading."
---

The48.2.6.1 replay producer initially named intermediate modules after their
logical rule label. On this repository filesystem the paths containing `Töp`,
decomposed `Töp`, and `töp` resolve to one device/inode with identical bytes.
Later writes therefore overwrite a previous fixture module. The source-integrity
check refused replay; this is an instrument defect, not a language/runtime failure.

The per-row observations JSON preserves all distinct source bodies. Restore those
bytes into stable ASCII numeric artifact IDs, verify against the retained bodies,
and keep exact logical Unicode labels in metadata. Do not derive artifact paths
from identifiers when case or normalization distinguishes them. Restored source
replay proves reuse of retained source bodies, not original overwritten physical
files. No general filesystem or cross-volume measurement is inferred.
