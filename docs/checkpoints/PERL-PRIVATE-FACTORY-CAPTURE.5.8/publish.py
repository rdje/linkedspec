"""Readonly complete finite-continuity publication; --capture creates its claim once."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/'
LEAF='PERL-PRIVATE-FACTORY-CAPTURE.5.8'
TARGET=ROOT/('docs/claims/'+LEAF+'.json')
sha=lambda v:hashlib.sha256(v).hexdigest()
decode=lambda v:base64.b64decode(v,validate=True)
raw=lambda p:(ROOT/p).read_bytes()
assert sys.argv[1:] in ([],['--capture'])
repair=json.loads(raw(PREFIX+'review-repair.json'))
assert repair['result']=='PASS' and repair['producer_sha256']==sha(raw(PREFIX+'review-repair.py'))
source=raw(PREFIX+'review.py')
assert repair['original_producer_sha256']==sha(source) and repair['returncode']!=0
assert b'unchanged actual helper/config source' in decode(repair['stderr_base64'])
assert repair['changed_support']==['doctrine/readme_stability/routes.jsonl']
old,new=decode(repair['old_base64']),decode(repair['new_base64'])
assert source.count(old)==1
corrected=source.replace(old,new,1).replace(b"PREFIX+'review.py'",b"PREFIX+'review-final.py'")
corrected=corrected.replace(b"'book-review.json','review.py'):raw(PREFIX+name)",
    b"'book-review.json','review.py','review-final.py','review-repair.py','review-repair.json'):raw(PREFIX+name)",1)
assert raw(PREFIX+'review-final.py')==corrected and repair['corrected_producer_sha256']==sha(corrected)
for name in ('review-final.py','evidence.py'):
    run=subprocess.run(['python3',PREFIX+name],cwd=ROOT,capture_output=True)
    assert run.returncode==0 and not run.stderr,('actual readonly proof',name,run.stderr)
review=json.loads(raw(PREFIX+'review.json'));evidence=json.loads(raw(PREFIX+'evidence.json'))
assert review['result']==evidence['result']=='PASS' and len(evidence['controls'])==7
population=review['population']
assert population['unchanged_prior_files']==230 and population['original_claim_inputs']==565
assert population['original_claim_bytes']==129686 and population['archive_lines']==257
assert population['numeric_observations']==60 and population['authority_red']==31
assert population['knowledge_bytes']==8388337 and population['book_inputs']==89
paths=set(review['inputs'])|{PREFIX+n for n in ('review.json','evidence.py','evidence.json',
    'evidence-originals.json.gz','evidence-reached.json.gz','publish.py')}
bindings=[]
for p in sorted(paths):
    source=ROOT/p;assert source.is_file() and not source.is_symlink()
    bindings.append(dict(path=p,sha256=sha(source.read_bytes()),
        role='producer' if source.suffix in ('.py','.pl','.pm','.sh','.t') else 'input'))
statement=('One exact change-history rollover and a finite512-line engineering-note envelope preserve '
    'all230 prior files and the whole565-input/129686-byte accepted compiler publication with actual '
    'baseline. Six registry scalars change under sole ADR0136. Actual old-cap RED, independent '
    'reconstruction,60 numeric/31 authority controls, seven semantic artifact denials, complete '
    'Knowledge8388337 and book89/four controls pass. Exact staged canonical receipt governs admission.')
claim=dict(name='finite-continuity-capacity-0136',statement=statement,
    scope='Change-history segment4962 is the exact257-line/26898-byte clean-source suffix109–365; '
        'current root111/32530. Actual369/59429 triggers rollover; old limits reject files51/50, '
        'manifest50/49 lines and28559/27983 bytes, notes29516/29512 lines. ADR0136 admits only '
        'that member/manifest, notes29512→30024 and decisions136→137 files/13285→13326 lines: '
        'sole40-line ADR plus one index row. Other root/byte/per-file/engineering membership '
        'and unrelated fields stay exact; no future archive reserve. Declared continuation '
        'covers maintenance, due metadata-only artifact review, fixture .7, pipeline .6 and '
        'metadata with bounded splits. Full original-project1980/1981 snapshots retain routed '
        'data, helper/config/directory/namespace and historical Git fixture inputs, without '
        'copied-root portability or immutable host-toolchain claims. Prior compiler observations '
        'remain historical at54bb5eb65178a57ac6e61e53324c9291863e716d; only mode/revision changes. '
        'No new full historical runtime replay or broader private/parent admission is inferred. '
        'First passing control output has two wrong actual census manifests and is independently '
        'rejected; exact two-line correction has full census equality and byte-exact actual '
        'recurrence. Original reader wrongly classifies the intentionally changed registry '
        'as unchanged support; actual failure/source and precise correction remain retained. '
        'Thirteen card routes/one body preserve all originals, twelve bodies stay exact, '
        'and the existing fact/card budgets remain unchanged. Native teaching stays exact. '
        'Runtime/test/checker/dependency implementations stay unchanged; startup.7 owns '
        'wrapper/kernel gaps and recovery/purge restrictions. Canonical logs/receipt are '
        'separately governed and excluded from the fixed evidence census.',
    rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+PREFIX+
        'publish.py (readonly default). review-final.py, evidence.py, control-census.py and '
        'book-review.py defaults are readonly. Original capture/measurement/admission/repair '
        'writers remain retired one-shot instruments.',
        granularity='Every230 prior file,565 original claim binding and whole129686 bytes; '
            'all complete source records/suffix/root/manifest coordinates and six changed '
            'registry scalars; actual1980/1981 observation inputs/four historical fixtures; '
            'each60 boundary observations/31 authority denials; seven full artifact '
            'counterfactuals/restorations; full1486 original/1487 current Markdown and89 book inputs.',
        result=statement),
    falsify=dict(status='checked',hypothesis='Rollover generation could be mistaken for authority, '
        'an old finite grant could imply reserve, census paths could hide actual pressure, '
        'or coherent immediate hashes could conceal changed historical custody, source '
        'coordinates, numeric reserve, proposed/displaced authority or rendered allowances.',
        oracle='Accepted Git source and fixed claim namespace; independent complete record '
            'selection and full prior bytes; unchanged actual production threshold and '
            'accepted/indexed/exact-object functions; separate actual census and rendered-table '
            'derivation before final identity checks.',
        red_control='Actual rollover-required255 and old-cap1 precede authority writes. '
            'Sixty inclusive old/new-boundary observations and31 actual authority REDs pass. '
            'Original two-population census fails independently before exact correction. '
            'Seven semantic artifact forgeries reject missing immutable membership, changed '
            'whole accepted claim, extra reserve, proposed authority, displaced index, '
            'forged source coordinate and rendered allowance; all complete changed '
            'bytes/modes/channels are retained and exact restoration passes. Four actual '
            'book source/include controls remain independently scoped.'),
    durability=dict(status='checked',mode='live',inputs=bindings))
record=dict(version=1,owner=LEAF,claims=[claim])
value=(json.dumps(record,indent=2)+'\n').encode()
assert len(value)<=131072,(len(value),len(bindings))
if sys.argv[1:]:
    with TARGET.open('xb') as output:output.write(value)
else:assert TARGET.read_bytes()==value
print('Finite continuity publication PASS:',len(bindings),'live inputs;',len(value),'bytes')
