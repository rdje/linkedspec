---
id: scalar-numeric-unicode-digit-oracle-drift
title: "Perl numeric coercion and the neutral oracle disagree on Unicode digits"
answers:
  - "why does Perl num_add truncate Arabic Indic or mixed digit strings"
  - "does the scalar numeric oracle accept Unicode decimal digits"
  - "which task resolves the numeric string digit language"
date: 2026-09-06
status: dated diagnostic evidence; repair state belongs to the owning task-tree
tags: ["startup-reading","perl","numeric","oracle"]
evidence: "SESSION-STARTUP-READING.31 preserves the recorded Toolbox/source controls at reading baseline baeb984e36a94a15951cd23d4c52def5064cdaca. The owning task is SESSION-STARTUP-READING.20. No implementation repair or whole-project signoff is claimed."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- perl/LinkedSpec/Numeric.pm tools/check_scalar_numeric_contract.py"
  - "sed -n '1,40p' perl/LinkedSpec/Numeric.pm"
  - "rg -n 'NUMERIC|numeric|float|fullmatch' tools/check_scalar_numeric_contract.py"
---

# Perl numeric coercion and the neutral oracle disagree on Unicode digits

This is the September 6 intake observation at the stated baseline. Current repair state and acceptance belong to
[SESSION-STARTUP-READING.20](docs/tasks/SESSION-STARTUP-READING.md), rather than a duplicated completion counter.

For a string containing U+0661, num_add(value, 1) produced 1 with a Perl host-conversion warning, while the neutral Python oracle produced 2. The mixed string ASCII 1 followed by U+0662 produced 2 with a warning versus the oracle's 13.

Numeric accepts the Unicode digit pattern and then uses host numeric coercion, which does not preserve those accepted digits. The current evidence establishes disagreement and truncation; it does not settle whether the intended contract accepts these digits or rejects them. The owning review must resolve that authority before implementation and preserve the 55-case / 18-helper contract with independent expectations.

Sources: `perl/LinkedSpec/Numeric.pm`, `tools/check_scalar_numeric_contract.py`.
