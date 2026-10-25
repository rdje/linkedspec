"""Observe the repaired support guard on the same actual helper fault."""
import importlib.util
import json
import common as c

lease=json.loads(c.source('.linkedspec-data/verification/numeric55-source-fault-lease.json').read_text())
assert lease['stem']=='fault-first-json-clamp'
spec=importlib.util.spec_from_file_location('numeric_support_repaired_audit',
    c.ROOT/'tests/language-readiness/verify_objectives.py')
audit=importlib.util.module_from_spec(spec);spec.loader.exec_module(audit)
path=audit.RUST_SIGNED_SOURCE
try:audit.verify_rust_numeric_evolution(path,c.source(path).read_bytes(),audit.RUST_SIGNED_BEFORE)
except ValueError as error:reason=str(error)
else:raise AssertionError('actual changed support admitted')
assert reason=='unreviewed Rust numeric support drift: '+lease['path']
c.save('support-admission-denial.json.gz',dict(producer=c.read(c.PREFIX+'support_denial.py'),
    auditor=c.read('tests/language-readiness/verify_objectives.py'),lease=lease,
    actual_helper=c.read(lease['path']),reason=reason,
    scope='The same actual helper saturation fault now rejects through the guarded '
        'source reader. Fresh restored admission/final recovery remain required.'))
print('Same actual helper fault now rejects through the numeric support binding.')
