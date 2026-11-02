"""Retain the complete reached Phase0 failure and its pre-edit source population."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def capture():
    destination = HERE / 'phase0-intake.json.gz'
    assert not destination.exists(), 'preserve completed intake epochs'
    names = set(subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 't/lib'], cwd=ROOT).decode().rstrip('\0').split('\0'))
    names.update(['t/phase0_regression.t', 'tools/run_ci_local.sh', 'tools/project_data_env.sh',
                  'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
                  'tests/language-readiness/verify_objectives.py', 'tools/historical_objective_images.py',
                  'tests/language-readiness/current-source-images.json.gz',
                  'docs/checkpoints/document-pressure-restoration/objective-recovery-execution-preflight.json.gz',
                  'docs/knowledge/terse-number-receiver-value-chains.md',
                  'docs/knowledge/terse-block-valued-receiver-chains.md',
                  'docs/knowledge/terse-mutation-assignment-expression-values.md',
                  'docs/linkedspec-book/src/development/documentation-workflow.md',
                  str(Path(__file__).relative_to(ROOT))])
    saved = dict(owner='TYPE-REFERENCE-BOOK.1.2.20.1.21',
                 inputs={n: packet((ROOT / n).read_bytes()) for n in sorted(names)},
                 failure=packet((ROOT / '.linkedspec-data/normal-hook-restoration/canonical-ci.log').read_bytes()),
                 limits='Complete failed69786 log, Phase0, all tracked project Perl/test-library sources and named current authorities before component21 changes. No passing repair or classification of its six generated-source mismatches is implied.')
    destination.write_bytes(gzip.compress(json.dumps(saved, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    print('retained Phase0 intake:', len(names), 'inputs')


if __name__ == '__main__':
    capture()
