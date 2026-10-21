"""Retain the bounded-root rejection and shorten only activation narrative."""
import common as c

path=c.PREFIX+'activate.py'
before=c.read(path)
run=c.run(['bash','tools/run_python_project_data.sh',path])
assert run['returncode']!=0 and b'AssertionError: 65724' in c.decode(run['stderr_base64'])
text=c.decode(before['base64']).decode()
changes=[
('  Scope/custody: docs/checkpoints/type-aggregate-codeblocks/; whole drop10334/actual clean readonly0 preserved before writes. Existing aggregate semantics are separate from scalar ADR0029. Ordinary numeric-string kinds95, constructor94 and callback boolean literals35 remain owned.',
 '  Scope/custody: docs/checkpoints/type-aggregate-codeblocks/; whole drop10334/clean readonly0 preserved. Aggregates are separate from scalar ADR0029;95/94/35 retain ownership.'),
('  Focused checks: Source-bound public descriptor/Get/dump/fresh routes; complete six-family names/aliases/receiver shapes, arity/kind/empty/effect controls; scalar5/drop6/direct consumers; book/Knowledge and doctrines.',
 '  Focused checks: Public descriptor/Get/dump/fresh routes; six families/names/receivers, arity/kind/empty/effects; scalar5/drop6/direct tests; book/Knowledge/doctrines.'),
('  Canonical trigger: Escalate for public contract/infrastructure movement or cross-cutting uncertainty; no blanket backend admission.',
 '  Canonical trigger: Escalate for contract/infrastructure changes or cross-cutting uncertainty.'),
('  - [ ] **ADDRESSED (verified)** — Independent values, diagnostics/effects and actual producer faults/restoration.',
 '  - [ ] **ADDRESSED (verified)** — Values/diagnostics/effects and actual faults/restoration.'),
]
for old,new in changes:
 assert text.count(old)==1,old
 text=text.replace(old,new,1)
c.write_new('activation-size-preparation.json.gz',dict(before=before,after_base64=c.encode(text.encode()),run=run,
 producer=c.read(c.PREFIX+'refine_activation.py'),
 scope='Existing65536-byte root guard rejects65724 before bound writes. Retain actual source/run, '
       'then compact only narrative; no budget increase or completed6 formal declaration change.'))
(c.ROOT/path).write_text(text)
