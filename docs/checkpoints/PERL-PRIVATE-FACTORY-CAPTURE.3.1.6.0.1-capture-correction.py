"""Supersede the empty-stderr assumption without altering any retained observation or producer."""
import base64
import hashlib
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-'
OLD=PREFIX+'complete-capture.py'
NEW=PREFIX+'final-capture.py'
TARGET=PREFIX+'capture-correction.json'
digest=lambda raw:hashlib.sha256(raw).hexdigest()
assert not (ROOT/NEW).exists() and not (ROOT/TARGET).exists(), 'one-shot producer correction already applied'
original=(ROOT/OLD).read_bytes()
first_raw=(ROOT/(PREFIX+'fixture.json')).read_bytes()
first=json.loads(first_raw)
assert first['producer_sha256']==digest(original) and first['returncode']==0 and first['unchanged']
stdout=base64.b64decode(first['stdout_base64'])
stderr=base64.b64decode(first['stderr_base64'])
assert re.findall(rb'^1\.\.(\d+)$',stdout,re.MULTILINE)==[b'487']
assert not re.search(rb'^not ok ',stdout,re.MULTILINE)
prefix=b'# RECEIVER_COPY_OBSERVATIONS '
assert stderr.startswith(prefix) and stderr.endswith(b'\n') and stderr.count(b'\n')==1
assert isinstance(json.loads(stderr[len(prefix):-1]),dict)
helper=r'''
def public_diagnostic(raw):
    prefix = b'# RECEIVER_COPY_OBSERVATIONS '
    assert raw.startswith(prefix) and raw.endswith(b'\n') and raw.count(b'\n') == 1, 'unexpected public-copy stderr'
    observed = json.loads(raw[len(prefix):-1])
    assert isinstance(observed, dict) and {'live', 'standalone', 'typed_value'} <= observed.keys(), 'invalid public-copy diagnostic'
    return observed


'''
text=original.decode()
changes=[
 ('"""Complete fixed-population fixture proof; original native and draft before remain immutable."""',
  '"""Final diagnostic-aware fixture/consumer/fault proof; all earlier producers and results stay immutable."""'),
 ('def retain(name, row):',helper+'def retain(name, row):'),
 ("retain('before-complete' if mode == 'before' else mode, row)",
  "retain('before-complete' if mode == 'before' else 'positive' if mode == 'fixture' else mode, row)"),
 ('assert result.returncode == 0 and not failures and not result.stderr',
  'assert result.returncode == 0 and not failures\n                public_diagnostic(result.stderr)'),
 ("PREFIX + 'fixture.json'","PREFIX + 'positive.json'"),
]
for old,new in changes:
    assert text.count(old)==(2 if old == "PREFIX + 'fixture.json'" else 1)
    text=text.replace(old,new)
(ROOT/NEW).write_text(text)
(ROOT/TARGET).write_text(json.dumps({
 'producer_sha256':digest(Path(__file__).read_bytes()),
 'original_producer':OLD,'original_producer_sha256':digest(original),
 'first_positive':PREFIX+'fixture.json','first_positive_sha256':digest(first_raw),
 'final_producer':NEW,'final_producer_sha256':digest(text.encode()),
 'observed_inner_exit':first['returncode'],'observed_assertions':487,'observed_failures':0,
 'reported_outer_exit':1,
 'preflight_draft':PREFIX+'capture-correction-draft.py',
 'preflight_draft_sha256':digest((ROOT/(PREFIX+'capture-correction-draft.py')).read_bytes()),
 'preflight_refusal':'Initial correction writer expected one fixture.json pointer; the instrument has two. It refused before writing either target. Exact draft retained; corrected guard requires both pointers.',
 'outer_boundary':'Terminal tool reported exit1 at the empty-stderr assertion. This is a transcription of that observed boundary, not a retained raw transport envelope.',
 'scope':'First actual positive remains verbatim: inner exit0,487 GREEN, one existing structured public-copy diagnostic. Retain the original complete producer unchanged. Its zero-stderr assumption is superseded by an exact single recognized JSON diagnostic and rejection of all other stderr. Final producer writes a separate positive artifact and selects it for faults; no prior result is refreshed.'
},indent=2)+'\n')
print('Capture correction PASS: original487 GREEN retained; active producer validates the existing single diagnostic')
