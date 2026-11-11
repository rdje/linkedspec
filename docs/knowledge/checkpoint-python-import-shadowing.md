---
id: checkpoint-python-import-shadowing
title: Checkpoint inspect.py can execute during Python exception formatting
answers:
  - "why did a Python traceback print checkpoint inspection rows"
  - "can inspect.py shadow Python standard-library exception imports"
  - "how should standalone intake readers avoid checkpoint import side effects"
  - "why did the safe Python module origin oracle reject Homebrew aliases"
date: 2026-11-11
status: current intake recovery isolated; broader launcher qualification owned by23.4.22
tags: [python, recovery, imports, diagnostics, provenance]
evidence: "Perl callable intake qualified-recovery/failure-unsafe import audit traces traceback -> _colorize -> dataclasses -> local inspect and137 inspection rows; safe -P/cleared PYTHONPATH avoids local module. qualified-recovery2 passes resolved physical-path import oracle and actual unchanged reader0/empty stderr/twelve controls."
reverify:
  - "Read docs/checkpoints/array-pipeline-callable-perl-2026-11-11/INTAKE.md and qualified-recovery2 retained commands/channels. Historical qualification writers are one-shot; do not replay over packets."
---

A script directory containing inspect.py can shadow Python's inspect module.
On this actual Python, failure formatting imports traceback/_colorize/dataclasses,
which imports inspect. The local diagnostic executes its137 output rows during
that import. It is not another SDK run. Explicit import/failure controls retain
actual audit stacks and complete physical channels.

Current standalone recovery clears PYTHONPATH and uses Python -P before loading
its script. Standard-library imports remain available and project cache settings
remain in force. This finite reader imports no sibling project modules; do not
blindly impose this invocation on historical producers that require them. Broader
safe-launcher coverage and compatibility are P1 owner TYPE23.4.22 after feature
coverage; immutable historical producers/identities must not be silently rewritten.

Compare module origins using resolved physical paths, not Homebrew opt/Cellar
lexical strings. The first qualified safe-path oracle was a false rejection:
safe_path/signature were true and physical paths/samefile agreed. Its complete
failed packet remains; separate recovery2 uses resolved paths and passes. Original
misnamed runner64 also remains. Both occur before actual reader execution and
receive no recovery PASS credit. This establishes the named import/control
mechanism, not complete Python/toolchain custody;4.2/SESSION5 retains that owner.
