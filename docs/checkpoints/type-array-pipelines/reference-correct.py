"""Adopt the frozen second publication and correct its stale task-tree control reference."""
import json
from pathlib import Path
import shutil
import subprocess
import sys

root = Path(subprocess.check_output(['git', 'rev-parse', '--show-toplevel']).decode().strip())
sys.path.insert(0, str(root / 'docs/checkpoints/type-array-pipelines'))
import common as c


def main():
    prior_path = root / '.linkedspec-data/verification/type-pipeline-reference-first.json.gz'
    assert prior_path.is_file()
    names = [c.PREFIX + 'publish.py', c.PREFIX + 'review.py', c.PREFIX + 'custody.py',
        c.PREFIX + 'README.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'MEMORY.md', 'CHANGES.md']
    before = {path: c.read(path) for path in names}
    after = {path: c.decode(packet['base64']).decode() for path, packet in before.items()}
    path = c.PREFIX + 'publish.py'
    text = after[path].replace("MANIFEST_NAME='publication2-inputs.json.gz'", "MANIFEST_NAME='publication3-inputs.json.gz'", 1)
    text = text.replace("PUBLICATION_NAME='publication2.json'", "PUBLICATION_NAME='publication3.json'", 1)
    text = text.replace("['--controls','artifact3-inputs.json.gz']", "['--controls','artifact3-inputs.json.gz'],['--controls','artifact4-inputs.json.gz']", 1)
    assert text.count("c.load('report-first.json.gz')['claim']") == 2
    text = text.replace("c.load('report-first.json.gz')['claim']", "c.load('reference-first.json.gz')['claim']")
    after[path] = text
    path = c.PREFIX + 'review.py'
    text = after[path]
    for suffix in ('inputs', 'run', 'observed'):
        text = text.replace('artifact3-' + suffix + '.json.gz', 'artifact4-' + suffix + '.json.gz')
    after[path] = text
    path = c.PREFIX + 'custody.py'
    text = after[path]
    marker = "    contexts['refused-report-writer']=failed['context']\n"
    assert text.count(marker) == 1
    addition = """    second=c.load('reference-first.json.gz')
    assert second['producer']==c.read(c.PREFIX+'reference-preserve.py')
    assert second['baseline']['returncode']==0 and not c.decode(second['baseline']['stderr_base64'])
    assert b'7 restored faults' in c.decode(second['baseline']['stdout_base64'])
    assert c.decode(second['canonical_status']['base64'])==b'143\\n'
    manifest=json.loads(__import__('gzip').decompress(c.decode(second['manifest']['base64'])))
    assert len(second['context']['inputs'])==len(manifest['inputs'])+3
    assert all(second['context']['inputs'][path]==item for path,item in manifest['inputs'].items())
    publication=json.loads(c.decode(second['publication']['base64']))
    assert publication['record_base64']==second['claim']['base64'] and len(publication['result']['faults'])==7
    assert c.load('artifact3-inputs.json.gz')['producer']==second['publisher']
    contexts['reference-second']=second['context']
"""
    after[path] = text.replace(marker, marker + addition, 1)
    path = 'docs/tasks/TYPE-REFERENCE-BOOK.md'
    old = 'final artifact2 controls and publication2 bind the actual publisher.'
    new = 'final artifact4 controls and publication3 bind the actual publisher. Earlier artifact2/3 epochs and whole second publication remain frozen; a stale artifact2 task reference was corrected before canonical admission.'
    assert after[path].count(old) == 1
    after[path] = after[path].replace(old, new, 1)
    path = 'MEMORY.md'
    after[path] = after[path].replace('Current publication2/manifest2 and final artifact3 controls', 'Current publication3/manifest3 and final artifact4 controls', 1)
    path = 'CHANGES.md'
    marker = '## '
    assert after[path].startswith('# CHANGES')
    first = after[path].index(marker)
    end = after[path].index(marker, first + len(marker))
    after[path] = after[path][:end] + 'The stale task-tree artifact2 reference was corrected after preserving whole publication2 and its actual readonly0; canonical verification was deliberately superseded143. Publication3 and artifact4 bind the corrected candidate; prior outputs stay frozen.\n\n' + after[path][end:]
    path = c.PREFIX + 'README.md'
    after[path] = after[path].replace('`publication2-inputs.json.gz` closes the final physical population/full modes; `publication2.json` is current.', '`publication3-inputs.json.gz` closes the final physical population/full modes; `publication3.json` is current. Publication2 remains frozen.', 1)
    after[path] += '\nreference-first.json.gz preserves whole publication2, its claim/full-mode source context and actual source-readonly0 before a stale artifact2 task-tree reference was corrected. Its canonical run was deliberately superseded143 before admission. reference-preserve.py is the exact actor; reference-correct.py adopts that packet, fixes the reference and selects fresh publication3/artifact4 outputs. Runtime, tests and book remain unchanged. Earlier publication/artifact epochs stay frozen.\n'
    for path, text in after.items():
        if path.endswith('.py'):
            compile(text, path, 'exec')
    artifact = (root / (c.PREFIX + 'artifacts3.py')).read_text()
    for old, new in [('artifact3-', 'artifact4-'), ('artifacts3.py', 'artifacts4.py')]:
        artifact = artifact.replace(old, new)
    compile(artifact, c.PREFIX + 'artifacts4.py', 'exec')
    assert not (root / (c.PREFIX + 'reference-first.json.gz')).exists()
    shutil.copy2(prior_path, root / (c.PREFIX + 'reference-first.json.gz'))
    shutil.copy2(root / '.linkedspec-data/verification/pipeline-reference-preserve.py', root / (c.PREFIX + 'reference-preserve.py'))
    shutil.copy2(Path(__file__), root / (c.PREFIX + 'reference-correct.py'))
    with (root / (c.PREFIX + 'artifacts4.py')).open('x') as output:
        output.write(artifact)
    for path, text in after.items():
        (root / path).write_text(text)
    c.write_new('reference-correction.json.gz', dict(before=before,
        after={path: c.read(path) for path in names}, producer=c.read(c.PREFIX + 'reference-correct.py'),
        scope='Only evidence/reference bookkeeping changes. Runtime/test/book bytes and observations remain unchanged. Publication2 and every earlier artifact epoch are frozen; fresh publication3/artifact4 follows.'))
    print('Task-tree reference corrected; whole second publication retained; publication3/artifact4 selected without changing runtime/test/book')


if __name__ == '__main__':
    main()
