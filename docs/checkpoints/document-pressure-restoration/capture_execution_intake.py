"""Freeze the restricted canonical failure and its documented host prerequisite."""
import base64
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def capture():
    destination = HERE / 'execution-intake.json.gz'
    assert not destination.exists(), 'preserve intake epochs'
    names = ['tools/run_ci_local.sh', 'tools/test_project_data_process_locality.sh',
             'tools/project_data_run.sh', 'tools/project_data_env.sh',
             'tools/verification_receipt.sh', 'tests/language-readiness/verify_objectives.py',
             'docs/knowledge/project-data-process-locality-proof.md', 'TOOLBOX.md',
             'docs/linkedspec-book/src/development/documentation-workflow.md',
             str(Path(__file__).relative_to(ROOT))]
    record = dict(owner='TYPE-REFERENCE-BOOK.1.2.20.1.20',
                  inputs={name: packet((ROOT / name).read_bytes()) for name in names},
                  failure=packet((ROOT / '.linkedspec-data/normal-hook-restoration/canonical-ci.log').read_bytes()),
                  limits='Failed canonical86500, complete actual log and pre-edit execution authorities. Existing September guidance already requires host execution. All completed prefix suites retain their scoped results; no canonical receipt, relocation or Phase0 pass.')
    destination.write_bytes(gzip.compress(json.dumps(record, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    print('retained restricted canonical execution intake')


if __name__ == '__main__':
    capture()
