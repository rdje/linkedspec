"""Freeze the second unpublished pipeline publication before a prose-reference repair."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

root = Path(subprocess.check_output(['git', 'rev-parse', '--show-toplevel']).decode().strip())
sys.path.insert(0, str(root / 'docs/checkpoints/type-array-pipelines'))
import common as c
import context
import publish


def main():
    paths = publish.input_paths()
    inputs = {path: c.identity(path) for path in paths}
    assert inputs == c.load('publication2-inputs.json.gz')['inputs']
    status = c.run(['git', 'status', '--porcelain'])
    baseline = c.run(['bash', 'tools/run_python_project_data.sh', c.PREFIX + 'publish.py'])
    assert baseline['returncode'] == 0 and not c.decode(baseline['stderr_base64'])
    assert b'7 restored faults' in c.decode(baseline['stdout_base64'])
    assert inputs == {path: c.identity(path) for path in publish.input_paths()}
    assert c.run(['git', 'status', '--porcelain']) == status
    images = paths + [publish.MANIFEST, publish.PUBLICATION, publish.CLAIM]
    saved = context.snapshot(images)
    publication = c.load('publication2.json')
    assert publication['record_base64'] == c.read(publish.CLAIM)['base64']
    value = dict(context=saved, claim=c.read(publish.CLAIM),
        publication=c.read(publish.PUBLICATION), manifest=c.read(publish.MANIFEST),
        publisher=c.read(c.PREFIX + 'publish.py'), baseline=baseline, status=status,
        producer=c.read(Path(__file__).resolve().relative_to(root).as_posix()),
        canonical_status=c.read('.linkedspec-data/verification/type-pipeline-canonical.status'),
        canonical_log=c.read('.linkedspec-data/verification/type-pipeline-canonical.log'),
        scope='Whole second unpublished publication/claim/full-mode source context and actual source-readonly0 precede a task-tree artifact2-to-final-control reference correction. Canonical verification was deliberately stopped143 before this change; it is not a test failure or successful admission. No runtime/test/book observation changes. Changed plain sources recover whole; immutable gzip/chunks stay at exact identities and unchanged base files recover from real49ce.')
    target = root / '.linkedspec-data/verification/type-pipeline-reference-first.json.gz'
    with target.open('xb') as output:
        output.write(gzip.compress((json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n').encode(), mtime=0))
    print('Second unpublished publication preserved:', len(inputs), 'inputs;', len(saved['inputs']), 'full-mode images; actual readonly0; stopped canonical143 retained')


if __name__ == '__main__':
    main()
