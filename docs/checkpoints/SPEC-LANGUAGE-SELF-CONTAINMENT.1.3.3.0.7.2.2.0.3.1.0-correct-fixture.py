"""Retain the actual original fixture and correct one authored cardinality error."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('correct-fixture.py')
path=Path(PREFIX+'origin-fixture.t'); raw=path.read_bytes()
old=b"['copied', sub { [@{$split->($_[0])}] }, [0]],"
new=b"['copied', sub { [@{$split->($_[0])}] }, [0,0]],"
assert raw.count(old)==1
manifest=json.loads(Path(PREFIX+'before-inputs.json').read_bytes())
entry=next(e for e in manifest['entries'] if e['path']==str(path.relative_to(ROOT)))
assert entry['sha256']==hashlib.sha256(raw).hexdigest()
assert json.loads(Path(PREFIX+'before-tap.json').read_bytes())['exit']==1
Path(PREFIX+'origin-fixture-initial.t').write_bytes(raw)
fixed=raw.replace(old,new);path.write_bytes(fixed)
result={'complete':True,'producer_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'initial_sha256':hashlib.sha256(raw).hexdigest(),'corrected_sha256':hashlib.sha256(fixed).hexdigest(),'actual_mechanism':'The canonical splitter returns two statements for host_call(); other_call(); the copied array is also two entries. Original private lookup is absent, so actual authority flags are [0,0], not the incorrectly authored [0]. Both event count and denial remain existing correct behavior.','change':'Only the copied-array expectation changes [0] to [0,0]; original source/actual complete channels remain retained. Corrected original RED is required before production edits.'}
Path(PREFIX+'fixture-correction.json').write_text(json.dumps(result,indent=2)+'\n')
task=ROOT/'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md';text=task.read_text();mark='  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0.json`'
assert text.count(mark)==1
text=text.replace(mark,mark+'\n  Instrument issue: Original copied-array denial control incorrectly expects one flag although the actual source splits into two statements. Retain exact initial fixture/complete RED channels; correct only [0] to [0,0]. Existing event count and no-origin behavior are correct. A corrected complete original fixture RED must precede production changes; original public capture continues against its immutable supplied tree.')
task.write_text(text)
print(json.dumps(result))
