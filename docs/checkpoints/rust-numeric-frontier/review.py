"""Numeric55.1 frontier repair: one-shot capture, then readonly dated review."""
import gzip
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/rust-numeric-frontier/'
sys.path.insert(0,str(ROOT/'docs/checkpoints/rust-numeric-boundaries'))
import common as c

TREE='docs/tasks/SESSION-STARTUP-READING'
CARD='docs/knowledge/startup-task-partition-plan.md'
PART=TREE+'.50-99.md'
CLAIM='docs/claims/SESSION-STARTUP-READING.55.1.json'
COMMAND=['perl','scripts/check_startup_task_partitions.pl']


def save(name,value):
    with (ROOT/PREFIX/name).open('xb') as output:
        output.write(gzip.compress((json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0))


def load(name):
    return json.loads(gzip.decompress((ROOT/PREFIX/name).read_bytes()))


def capture():
    paths=[TREE+suffix for suffix in ['.md','.index.jsonl','.01-03.md',
        '.04-49.md','.50-99.md','.history.md']]
    paths+=['scripts/check_startup_task_partitions.pl','tools/read_task_tree.pl',
        'doctrine/readme_stability/routes.jsonl','docs/decisions/0125-startup-task-partitions.md']
    before={path:c.read(path) for path in paths}
    index=c.run(['git','ls-files','--stage','-z']);assert index['returncode']==0
    log=c.read('.linkedspec-data/verification/numeric55-canonical-host.log')
    assert b'root frontier lacks a stable child/status row' in c.decode(log['base64'])
    prior=c.read(CLAIM);claims={}
    for path in subprocess.check_output(['git','ls-files','docs/claims'],cwd=ROOT,text=True).splitlines():
        packet=c.read(path);claims[path]=packet
        for claim in json.loads(c.decode(packet['base64']))['claims']:
            durable=claim['durability']
            if durable.get('mode')=='live':
                assert CARD not in {item['path'] for item in durable.get('inputs',[])},path
    saved=dict(inputs=before,index=index,canonical_log=log,
        canonical_status=143,canonical_scope='Actual metadata failure observed; intentionally '
        'terminated verified own process group before remaining doctrines completed. No full-CI completion claim.',
        producer=c.read(PREFIX+'review.py'),prior_claim=prior,claims=claims,
        frozen_source=c.run(['git','show','58a5ff936e54f0699da2b33c35641a5e0155ed81:'+TREE+'.md']),
        scope='Actual startup validator inputs and original frozen Git source; Perl/OS '
            'and accepted Git object identities are read-only prerequisites. '
            'The full staged index is metadata only; unchanged original candidate files '
            'remain in this commit and sealed numeric publication. No whole-environment replay.')
    save('before.json.gz',saved)
    red=c.run(COMMAND)
    assert red['returncode']==1 and b'root frontier lacks a stable child/status row' in c.decode(red['stderr_base64'])
    root=ROOT/(TREE+'.md');text=root.read_text()
    old='| 1 | `TYPE-REFERENCE-BOOK.1.2.17.4` | `pending` | Resume Dart signed selectors after the clean Rust numeric repair; owner is the type-reference tree. |'
    new='| 1 | `SESSION-STARTUP-READING.55.2` | `pending` | Next startup numeric child remains queued; overall PNT returns to Dart17.4 before this separate spelling work. |'
    assert text.count(old)==1;root.write_text(text.replace(old,new,1))
    green=c.run(COMMAND)
    assert green['returncode']==0 and not c.decode(green['stderr_base64'])
    after={path:c.read(path) for path in paths}
    assert [path for path in paths if before[path]!=after[path]]==[TREE+'.md']
    save('runs.json.gz',dict(red=red,green=green,after=after))
    card_before=c.read(CARD);part_before=c.read(PART)
    text=c.decode(card_before['base64']).decode()
    marker='date: 2026-09-24'
    assert text.count(marker)==1
    text=text.replace(marker,'  - "why does the startup root frontier require its own stable child status row"\ndate: 2026-10-25',1)
    marker='## Applied migration\n'
    note=('Current frontier contract (numeric55.1, October25): the startup validator\n'
        'requires at least one table row naming a stable child of this same tree,\n'
        'with the exact status in its semantic part. A cross-tree next action belongs\n'
        'in the surrounding handoff prose and MEMORY.md. Naming Dart17.4 alone in\n'
        'the startup table fails `root frontier lacks a stable child/status row`;\n'
        'the queued startup55.2 row passes while Dart remains the overall next action.\n'
        'Readonly dated proof: `docs/checkpoints/rust-numeric-frontier/review.py`.\n\n')
    assert text.count(marker)==1;(ROOT/CARD).write_text(text.replace(marker,note+marker,1))
    text=c.decode(part_before['base64']).decode();marker='  Next boundary: Commit this leaf cleanly before Dart signed17.4.'
    note=('  Canonical1 document correction: The original numeric proof is sealed409 claim inputs. '
        'The staged gate finds a cross-tree-only startup frontier row; its metadata/routing '
        'failures and intentional143 termination are retained separately in rust-numeric-frontier/. '
        'Actual unchanged validator RED1 becomes GREEN0 after only that root row names queued55.2; '
        'overall Dart17.4 handoff stays explicit. The canonical Knowledge retrieval is extended; '
        'no numeric source, original claim item or sealed checkpoint is refreshed. Run a fresh '
        'exact-staged approved-host canonical gate before landing.\n')
    assert text.count(marker)==1;(ROOT/PART).write_text(text.replace(marker,note+marker,1))
    result=c.run(['perl','tools/update_task_tree_index.pl','--tree','SESSION-STARTUP-READING'])
    assert result['returncode']==0
    save('documentation.json.gz',dict(card_before=card_before,part_before=part_before,
        card_after=c.read(CARD),part_after=c.read(PART),index_refresh=result))
    result=check()
    record=json.loads(c.decode(prior['base64']))
    inputs=[dict(path=file.relative_to(ROOT).as_posix(),sha256=c.identity(file.relative_to(ROOT).as_posix())['sha256'],
        role='producer' if file.suffix=='.py' else 'input')
        for file in sorted((ROOT/PREFIX).iterdir()) if file.is_file()]
    record['claims'].append(dict(name='numeric-handoff-frontier',
        statement='The startup frontier retains its queued stable child while the overall clean handoff returns to Dart signed selectors.',
        scope='Only the numeric55.1 continuity correction. Original canonical attempt observed metadata/routing failure and was intentionally terminated143; no completed full gate is claimed. Current numeric proof and its409 inputs are unchanged. Whole dated startup checker inputs/producer, original frozen source and exact before/after root are retained; Perl/OS and accepted Git objects remain prerequisites.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+PREFIX+'review.py',
            granularity='Exact startup root row, semantic child status and unchanged validator invocation/input epoch.',result=json.dumps(result,sort_keys=True)),
        falsify=dict(status='checked',hypothesis='A startup frontier containing only a foreign tree child satisfies its registered topology.',
            oracle='Existing independent startup validator and unchanged semantic child definitions.',
            red_control='Actual cross-tree-only root rejects1; after only its table row names queued startup55.2, the identical validator passes0. Overall Dart handoff remains in prose.'),
        durability=dict(status='checked',mode='live',inputs=inputs)))
    (ROOT/CLAIM).write_text(json.dumps(record,sort_keys=True,separators=(',',':'))+'\n')
    assert (ROOT/CLAIM).stat().st_size<=131072
    print(json.dumps(result,sort_keys=True))


def check():
    before=load('before.json.gz');saved=load('runs.json.gz')
    for packets in [before['inputs'],saved['after']]:
        for item in packets.values():assert c.sha(c.decode(item['base64']))==item['sha256']
    changed=[path for path in before['inputs'] if before['inputs'][path]!=saved['after'][path]]
    assert changed==[TREE+'.md']
    assert saved['red']['command']==saved['green']['command']==COMMAND
    assert saved['red']['returncode']==1 and saved['green']['returncode']==0
    assert b'root frontier lacks a stable child/status row' in c.decode(saved['red']['stderr_base64'])
    text=c.decode(saved['after'][TREE+'.md']['base64']).decode()
    assert '| `SESSION-STARTUP-READING.55.2` | `pending` |' in text
    assert 'Return to `TYPE-REFERENCE-BOOK.1.2.17.4` only' in text
    owner=c.decode(before['inputs'][PART]['base64']).decode()
    assert re.search(r'^- ID: `SESSION-STARTUP-READING.55.2`\n  Status: `pending`',owner,re.M)
    assert c.read(TREE+'.md')==saved['after'][TREE+'.md']
    assert before['canonical_status']==143
    return dict(original_validator_status=1,corrected_validator_status=0,
        changed_validator_inputs=changed,overall_next='TYPE-REFERENCE-BOOK.1.2.17.4',
        canonical1='metadata failure; intentionally terminated143; full rerun required')


if __name__=='__main__':
    assert sys.argv[1:] in ([],['capture'])
    capture() if sys.argv[1:] else print(json.dumps(check(),sort_keys=True))
