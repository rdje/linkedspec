"""Retain the actual two-image admission gap while the owned helper fault is live."""
import importlib.util
import json
import common as c

lease=json.loads(c.source('.linkedspec-data/verification/numeric55-source-fault-lease.json').read_text())
assert lease['stem']=='fault-first-json-clamp'
spec=importlib.util.spec_from_file_location('numeric_support_gap_audit',
    c.ROOT/'tests/language-readiness/verify_objectives.py')
audit=importlib.util.module_from_spec(spec);spec.loader.exec_module(audit)
assert not hasattr(audit,'RUST_NUMERIC_SUPPORT')
path=audit.RUST_SIGNED_SOURCE
row=audit.verify_rust_numeric_evolution(path,c.source(path).read_bytes(),audit.RUST_SIGNED_BEFORE)
helper=c.read(lease['path'])
assert helper['sha256']==lease['fault_sha256'] and helper['sha256']!=lease['before']['sha256']
c.save('support-admission-gap.json.gz',dict(producer=c.read(c.PREFIX+'support_gap.py'),
    auditor=c.read('tests/language-readiness/verify_objectives.py'),lease=lease,
    admitted=row,actual_helper=helper,
    primary_images={path:c.read(path),'rust/Cargo.toml':c.read('rust/Cargo.toml')},
    scope='Actual owned saturation fault changes the new numeric helper while both '
        'primary images stay exact. The initial two-image guard still admits them. '
        'This is not whole-producer integrity; bind the support set before landing.'))
print('Admission gap observed: unchanged primary pair admits a changed numeric helper.')
