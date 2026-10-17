"""Readonly current retention/custody publication; --capture writes its claim once."""
import base64
import gzip
import hashlib
import io
import json
import re
import subprocess
import sys
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'e2ec1e96bc47633599f0935ed6828c1a0b99e40a'
PREFIX = 'docs/checkpoints/REPO-HYGIENE.18-'
CHAPTER = 'docs/linkedspec-book/src/development/documentation-workflow.md'
TARGET = ROOT / 'docs/claims/REPO-HYGIENE.18.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
raw = lambda p: (ROOT/p).read_bytes()
load = lambda name: json.loads(raw(PREFIX+name))
decode = lambda value: base64.b64decode(value,validate=True)
assert sys.argv[1:] in ([], ['--capture'])

# The failed reader and both complete observed refusals remain immutable.
failure=load('review-failure.json')
first=raw(PREFIX+'review-actual.py')
assert failure['exit_code']==1 and failure['tool_chunk']=='d5c447'
assert failure['producer_sha256']==sha(first)
channel=decode(failure['combined_output_base64'])
assert sha(channel)==failure['combined_output_sha256'] and channel.endswith(b"KeyError: 'inputs'\n")
old,new=decode(failure['old_base64']),decode(failure['new_base64'])
assert first.count(old)==1
expected=first.replace(old,new,1).replace(b"PREFIX + 'actual-verification.json'",b"PREFIX + 'actual-final-verification.json'")
assert raw(PREFIX+'review-actual-final.py')==expected, 'only non-live guard and distinct output correction'
assert not (ROOT/(PREFIX+'actual-verification.json')).exists(), 'original failed reader wrote no verification'
premature=load('review-premature.json')
assert premature['exit_code']==1 and premature['tool_chunk']=='67d322' and premature['producer_sha256']==sha(first)
channel=decode(premature['combined_output_base64'])
assert sha(channel)==premature['combined_output_sha256'] and b'FileNotFoundError:' in channel and b'REPO-HYGIENE.18-actual.json' in channel

for source in ('review-actual-final.py','book-review.py'):
    command=['bash','tools/run_python_project_data.sh',PREFIX+source]
    result=subprocess.run(command,cwd=ROOT,capture_output=True)
    assert result.returncode==0 and not result.stderr, ('actual readonly review',source,result.returncode,result.stdout,result.stderr)
actual=load('actual-final-verification.json')
assert actual['result']=='PASS' and len(actual['controls'])==4 and len(actual['preservation_controls'])==3
assert actual['producer_sha256']==sha(raw(PREFIX+'review-actual-final.py'))
assert actual['historical_publication_inputs']==507 and actual['historical_publication_bytes']==117862

# Independently reconstruct the full original Knowledge population from accepted Git.
route=load('route.json')
assert route['base']==BASE and route['producer_sha256']==sha(raw(PREFIX+'route.py'))
capsule_raw=raw(PREFIX+'knowledge-inputs.json.gz')
assert sha(capsule_raw)==route['capsule_sha256']
capsule=json.loads(gzip.decompress(capsule_raw))
archive=subprocess.check_output(['git','archive',BASE,'--','docs/knowledge','docs/decisions'],cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as source:
    original={item.name:{'bytes_base64':base64.b64encode(source.extractfile(item).read()).decode(),'mode':item.mode}
              for item in source if item.isfile() and item.name.endswith('.md')}
assert capsule['original']==original, 'whole accepted Knowledge population'
paths={p.relative_to(ROOT).as_posix() for d in ('docs/knowledge','docs/decisions') for p in (ROOT/d).rglob('*.md') if p.is_file()}
assert paths==set(original) and len(paths)==route['markdown']==1486
freeze=load('preservation.json')
cards=sorted(p for p in freeze['selected'][0]['intersections'][0]['paths'] if p.startswith('docs/knowledge/'))
assert route['cards']==cards and len(cards)==11
expected_route=('Readonly current custody/retention review: bash tools/run_python_project_data.sh '
                'docs/checkpoints/REPO-HYGIENE.18-claim.py. Complete finite admission507/full117862 '
                'and earlier evidence remain at e2ec1e96b. Capture writers stay retired.')
assert route['route']==expected_route
for path,item in capsule['current'].items():
    p=ROOT/path
    assert p.is_file() and not p.is_symlink()
    value=p.read_bytes()
    assert sha(value)==item['sha256'] and value==decode(item['bytes_base64']), ('complete current Knowledge custody',path)
    assert p.stat().st_mode&0o7777==item['mode']
assert route['inputs']=={p:{'sha256':item['sha256'],'mode':item['mode']} for p,item in capsule['current'].items()}
for path,item in original.items():
    expected=decode(item['bytes_base64'])
    if path in cards:
        header,body=expected.split(b'\n---\n',1)
        lines=header.splitlines(keepends=True)
        matches=[i for i,line in enumerate(lines) if line.startswith(b'reverify: ')]
        assert len(matches)==1
        i=matches[0]
        ending=b'\n' if lines[i].endswith(b'\n') else b''
        lines[i]=('reverify: '+json.dumps(expected_route)).encode()+ending
        expected=b''.join(lines)+b'\n---\n'+body
    assert raw(path)==expected, ('only exact reverify header overlay',path)
    assert (ROOT/path).stat().st_mode&0o7777==item['mode']
command=['bash','knowledge-map/scripts/check_knowledge_map.sh']
process=subprocess.run(command,cwd=ROOT,capture_output=True)
assert process.returncode==0 and not process.stdout
assert process.stderr==b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert len(route['commands'])==2
assert route['commands'][0]['command']==['bash','knowledge-map/scripts/gen_knowledge_map.sh']
assert route['commands'][1]['command']==command
assert all(row['returncode']==0 for row in route['commands'])
assert decode(route['commands'][1]['stdout_base64'])==process.stdout and decode(route['commands'][1]['stderr_base64'])==process.stderr
old_chapter=subprocess.check_output(['git','show',BASE+':'+CHAPTER],cwd=ROOT)
old,new=decode(route['chapter_old_base64']),decode(route['chapter_new_base64'])
assert old_chapter.count(old)==1 and raw(CHAPTER)==old_chapter.replace(old,new,1)
assert b'REPO-HYGIENE.18-claim.py' in new and b'no future archive reserve follows' in new
book=load('book-review.json')
assert book['result']=='PASS' and book['source_count']==89 and book['actual_controls']==4
assert all(sha(raw(path))==digest for path,digest in book['source_inputs'].items())

census=load('artifact-review.json')
assert census['activation_commit']==BASE and census['owner']=='REPO-HYGIENE.18'
assert census['artifact_files']==len(census['rows'])
assert census['artifact_bytes']==sum(row['bytes'] for row in census['rows'])
assert census['removed_files']==census['removed_bytes']==0
cleanup=raw('docs/ARTIFACT_CLEANUP.md')
assert census['at_utc'].encode() in cleanup and b'REPO-HYGIENE.18' in cleanup and b'zero files removed' in cleanup
# This ordinary retained review adds one complete record and changes no engineering understanding.
old_changes=subprocess.check_output(['git','show',BASE+':CHANGES.md'],cwd=ROOT)
cut=old_changes.index(b'## ')
current_changes=raw('CHANGES.md')
assert current_changes.startswith(old_changes[:cut])
new_record=current_changes[cut:current_changes.index(old_changes[cut:])]
assert current_changes==old_changes[:cut]+new_record+old_changes[cut:]
assert new_record.startswith('## 2026-10-18 — REPO-HYGIENE.18 —'.encode()) and new_record.count(b'\n## ')==0
assert str(census['artifact_files']).encode() in new_record and str(census['artifact_bytes']).encode() in new_record
assert raw('DEVELOPMENT_NOTES.md')==subprocess.check_output(['git','show',BASE+':DEVELOPMENT_NOTES.md'],cwd=ROOT)

inputs={p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/checkpoints').glob('REPO-HYGIENE.18-*') if p.is_file()}
inputs.update(book['source_inputs'])
inputs.update(cards)
inputs.update(('.gitignore','.gitmodules','CHANGES.md','docs/ARTIFACT_CLEANUP.md','KNOWLEDGE_MAP.md',
               '.knowledge_map.conf','knowledge-map/scripts/knowledge_map.conf',
               'knowledge-map/scripts/gen_knowledge_map.sh','knowledge-map/scripts/check_knowledge_map.sh',
               'tools/run_python_project_data.sh','tools/project_data_run.sh','tools/project_data_env.sh',
               'tools/check_claim_verification.py','docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3.json'))
card_bytes=sum(len(raw(p)) for p in paths if p.startswith('docs/knowledge/'))
assert card_bytes<=8388608
statement=(f"At {census['at_utc']}, the scoped parent census retains{census['artifact_files']} candidate rows/"
           f"{census['artifact_bytes']} bytes; Rust release/incremental/deps are separate observations. "
           "Fresh census, independent per-file OS lstat, aggregate/balanced-size and traversal fixtures pass. "
           "Actual guarded commands/exits/full channels, four channel and three preservation RED controls pass. "
           "Zero files removed; all proof data/caches retained. Complete original507-input/117862-byte finite-history "
           "publication and its actual readonly baseline remain historical at e2ec1e96bc47633599f0935ed6828c1a0b99e40a "
           "with mode/revision-only projection; every original binding is verified against accepted Git. "
           f"Full1486 Knowledge Markdown inputs retain eleven header-only overlays, unchanged bodies and{card_bytes} "
           "card bytes under existing limits; derived map is synchronized. Complete book89/four controls verify "
           "the current entrypoint. Premature capture refusal and the first gap-leg reader failure/source remain "
           "retained; a distinct reader adds only the non-live guard and separate output path. No runtime, "
           "dependency, gate, storage or budget mechanism changes; if/while .5.2 follows the clean commit.")
claim=dict(name='dated-retained-artifact-review-and-current-custody',statement=statement,
 scope=('Dated per-file metadata only; no content ownership, disposal safety, reclaimed-space, liveness, '
        'recovery/purge, concurrent adversarial traversal or global audit claim. Other repositories/submodules, '
        'symlinks, other volumes, managed runs, reusable caches and every prior hygiene fixture are excluded '
        'before traversal; Rust locations are separate. Original507 inputs and complete prior publication '
        'remain recoverable at the recorded accepted Git revision and are independently hash-checked; current '
        'mutable documentation is not substituted for those historical inputs. Current Knowledge capsule '
        'retains every original/current byte and mode; only eleven reverify headers change. Complete book '
        'source/config/includes and actual rendered controls are retained. Source/channel/input identities '
        'of the original failed reader and sole guard/output correction are gated. Standard OS/Git/Python/'
        'mdBook are read-only environmental dependencies; no immutable toolchain or cross-version HTML claim. '
        'Capture/freezer/route/book writers and --capture publication are one-shot; this default and final '
        'actual/book readers are readonly. No new structural fact, callback/helper/private/parent/canonical '
        'admission or future capacity reserve. Runtime implementation and engineering notes stay unchanged.'),
 rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+PREFIX+'claim.py (readonly default). '
               'review-actual-final.py and book-review.py are readonly by default; original one-shot writers stay retired.',
               granularity='Every dated candidate/Rust row and retained command/channel; fixed accepted claim namespace, '
               'whole original507-input/117862-byte publication/baseline and every binding; full1486 original/current '
               'Knowledge bytes/modes and eleven exact header overlays; full89 book inputs/four rendered controls; '
               'exact original failed-reader source and guard-only correction.',result=statement),
 falsify=dict(status='checked',hypothesis='Aggregates conceal altered per-file sizes or unsafe traversal; source/channel '
              'metadata forges failed observations; shared documentation silently replaces accepted inputs; a gap leg '
              'is misread as a live durability input set; incomplete Knowledge/book populations conceal route drift.',
              oracle='Independent OS lstat/fresh census and traversal fixtures; accepted Git namespace/original bytes; '
              'reason-sensitive full-channel/preservation controls; unchanged gap-leg schema; independent complete '
              'Knowledge archive/header comparison and book source/include/rendered controls.',
              red_control='Aggregate inflation and balanced-size redistribution reject. Start/ancestor symlinks, '
              'nested repositories, mock submodules and outside-root starts reject. Four controls reject incomplete '
              'capture, forged producer, failed review and forged stdout; three reject altered whole publication, '
              'non-projection claim edit and forged baseline stdout. Four book controls reject missing SUMMARY, '
              'removed rendered markers/current entrypoint and missing recursive include. Actual initial reader '
              'KeyError on the permitted disclosed gap is retained; only filtering non-live legs before inputs '
              'and writing a distinct output yields verified PASS without refreshing the census.'),
 durability=dict(status='checked',mode='live',inputs=[dict(path=p,sha256=sha(raw(p)),
                 role='producer' if p.endswith(('.py','.sh','.pl','.pm','.t')) else 'input') for p in sorted(inputs)]))
value=(json.dumps(dict(version=1,owner='REPO-HYGIENE.18',claims=[claim]),indent=2)+'\n').encode()
assert len(value)<=131072
if sys.argv[1:]:
    with TARGET.open('xb') as f:f.write(value)
else:
    assert TARGET.read_bytes()==value, 'exact current retention publication'
print('Retention/custody publication PASS:',len(inputs),'live inputs;',len(value),'bytes')
print('Dated parent:',census['artifact_files'],census['artifact_bytes'],'removed0; Knowledge card bytes:',card_bytes)
