"""Retain the actual restoration inputs and already observed component channels."""
import argparse
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[3]
PREFIX=Path(__file__).parent
V=ROOT/'.linkedspec-data/normal-hook-restoration'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(),sha256=hashlib.sha256(raw).hexdigest())


def capture():
    destination=PREFIX/'component-evidence.json.gz'
    assert not destination.exists(),'capture is one-shot; retain previous epochs'
    names=('claim-before-result.json','claim-after-result.json','claim-before.log','claim-after.log',
           'claim-checker-before.py','claim-checker-after.py','observe_claim_before.py','observe_claim_after.py',
           'history-check.log','history-rollover.log','history-rollover.json','task-metadata.log',
           'map-final-preservation.json','projection-replay.log','atomic-compact.log','book-build.log')
    channels={name:packet((V/name).read_bytes()) for name in names}
    histories={}
    for family in ('change-history','engineering-notes'):
        before=(V/(family+'-before.md')).read_bytes();after=(V/(family+'-after.md')).read_bytes()
        assert before==after,'dated catalog migration changed ordered history'
        histories[family]=dict(before=packet(before),after=packet(after))
    inputs={}
    selected=('tools/task_narrative.py','tools/migrate_task_narrative.py','tools/read_task_narrative.py',
              'tools/read_task_tree.pl','tools/update_task_tree_index.pl','scripts/check_task_tree_metadata.sh',
              'tools/check_claim_verification.py','tools/check_reference_scope.py','tools/reference_scope.py',
              'tools/update_reference_scope.py','tools/lib/LinkedSpec/DocumentHistoryCatalog.pm',
              'tools/read_document_history.pl','tools/roll_document_history.pl','tools/pack_document_history.pl',
              'scripts/check_document_history.pl','scripts/check_readme_routing_pressure.pl',
              'knowledge-map/scripts/gen_knowledge_map.sh','tools/project_data_env.sh','tools/project_data_run.sh',
              'tools/run_python_project_data.sh','tools/run_ci_local.sh','README_POLICY.md',
              'docs/decisions/0139-approved-archive-reference-contracts.md','doctrine/readme_stability/routes.jsonl')
    paths=set(selected)
    for pattern in ('tools/test_*scope.py','tools/test_claim_verification_cache.py','tools/test_task_narrative.py',
                    'tools/test_knowledge_map_projection.py','t/document_history_catalog.t','docs/history/**/*.md',
                    'docs/history/**/*.jsonl'):
        paths.update(p.relative_to(ROOT).as_posix() for p in ROOT.glob(pattern))
    for name in sorted(paths):inputs[name]=packet((ROOT/name).read_bytes())
    index=subprocess.check_output(['git','ls-files','--stage','-z'],cwd=ROOT)
    old=json.loads((V/'claim-before-result.json').read_bytes());new=json.loads((V/'claim-after-result.json').read_bytes())
    assert old['passed'] and new['passed'] and old['index_unchanged'] and new['index_unchanged']
    assert old['index_sha256']==new['index_sha256']==hashlib.sha256(index).hexdigest()
    report=dict(base='0db5e9e87b7c1cfaf09936b9629974787038f5e3',index=packet(index),channels=channels,
                histories=histories,inputs=inputs,limits='Dated component epoch before final continuity edits. Complete original/repaired claim checks share the unchanged predecessor index; timing is not portable performance. Canonical receipt and normal hooks separately govern final acceptance.')
    destination.write_bytes(gzip.compress(json.dumps(report,sort_keys=True,separators=(',',':')).encode(),mtime=0))
    print('retained component evidence and complete producer/input epoch')

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--apply',action='store_true',required=True);parser.parse_args();capture()
