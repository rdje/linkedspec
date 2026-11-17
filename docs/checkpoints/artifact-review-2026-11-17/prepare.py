"""Compose a new dated capture, reusing the clean Git input by exact identity."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PRIOR = Path('docs/checkpoints/artifact-review-2026-11-16')
ACTIVATION = '36428fa1288d9da3fe00628ca0ab734b940bc023'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'review.py').exists()
(BASE / 'prepare-before.py.gz').write_bytes(gzip.compress(Path(__file__).read_bytes(), mtime=0))
templates = {}
for name in ('review.py', 'run.py'):
    path = PRIOR / name
    body = path.read_bytes()
    assert subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)]) == body
    (BASE / ('template-' + name + '.gz')).write_bytes(gzip.compress(body, mtime=0))
    templates[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
    source = body.decode().replace('2026-11-16', '2026-11-17').replace('1.2.23.4.33', '1.2.23.4.37')
    if name == 'run.py':
        (BASE / name).write_text(source)
        continue
    changes = []

    def replace(old, new):
        global source
        assert source.count(old) == 1, old
        source = source.replace(old, new)
        changes.append(dict(old=old, new=new))

    replace('import os\n', 'import os\nimport re\n')
    replace("'docs/checkpoints/artifact-review-2026-11-17/run.py')", "'docs/checkpoints/artifact-review-2026-11-17/run.py',\n             'docs/checkpoints/artifact-review-2026-11-17/prepare.py')")
    tree_reader = r'''def index_from_tree(revision):
    assert re.fullmatch(r'(?:[0-9a-f]{40}|[0-9a-f]{64})', revision)
    raw = subprocess.check_output(['git', 'ls-tree', '-r', '-z', revision], cwd=ROOT)
    rows = []
    for row in raw.split(b'\0'):
        if not row:
            continue
        header, name = row.split(b'\t', 1)
        mode, kind, blob = header.split()
        assert kind in (b'blob', b'commit')
        rows.append((name, mode + b' ' + blob + b' 0\t' + name + b'\0'))
    return b''.join(row for name, row in sorted(rows))


'''
    replace('def validate(report):\n', tree_reader + 'def validate(report):\n')
    replace("for image in (*report['producers'].values(), *report['messages'].values(), report['git_index']):", "for image in (*report['producers'].values(), *report['messages'].values()):")
    replace("        assert packet(base64.b64decode(image['base64'])) == image, 'retained packet identity'", """        assert packet(base64.b64decode(image['base64'])) == image, 'retained packet identity'
    reference = report['git_index']
    assert reference['revision'] == report['activation_commit'], 'git index revision'
    raw_index = index_from_tree(reference['revision'])
    assert len(raw_index) == reference['bytes'] and hashlib.sha256(raw_index).hexdigest() == reference['sha256'], 'git index reconstruction'
    assert reference == json.loads((HERE / 'index-input-before.json').read_bytes()), 'git index before-use reference'
    control = json.loads((HERE / 'index-source-control.json').read_bytes())
    altered = raw_index.replace(b' 0\\t', b' 1\\t', 1)
    assert altered != raw_index and hashlib.sha256(altered).hexdigest() == control['altered_sha256']
    assert control['healthy_sha256'] == reference['sha256'] and control['observed'] == 'RED'
""")
    replace("('missing-row', 'wrong-size', 'duplicate-row', 'outside-path', 'producer-byte')", "('missing-row', 'wrong-size', 'duplicate-row', 'outside-path', 'producer-byte', 'index-identity')")
    replace("        else:\n            image = next(iter(changed['producers'].values()))\n            image['sha256'] = '0' * 64", "        elif name == 'producer-byte':\n            image = next(iter(changed['producers'].values()))\n            image['sha256'] = '0' * 64\n        else:\n            changed['git_index']['sha256'] = '0' * 64")
    replace("('independent metadata mismatch:', 'retained packet identity')", "('independent metadata mismatch:', 'retained packet identity', 'git index reconstruction')")
    replace("    index = subprocess.check_output(['git', 'ls-files', '--stage', '-z'], cwd=ROOT)\n", '')
    before = r'''    # The exact logical index stream is recoverable from the retained clean base.
    revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    index = subprocess.check_output(['git', 'ls-files', '--stage', '-z'], cwd=ROOT)
    recovered = index_from_tree(revision)
    if recovered != index:
        (HERE / 'failed-index-input.gz').write_bytes(gzip.compress(index, mtime=0))
    assert recovered == index, 'actual index stream differs from clean-base tree'
    index_ref = dict(revision=revision, bytes=len(index), sha256=hashlib.sha256(index).hexdigest(),
        index_argv=['git', 'ls-files', '--stage', '-z'], tree_argv=['git', 'ls-tree', '-r', '-z', revision], cwd='.')
    (HERE / 'index-input-before.json').write_text(json.dumps(index_ref, indent=2) + '\n')
    altered = index.replace(b' 0\t', b' 1\t', 1)
    assert altered != index and altered != recovered
    (HERE / 'index-source-control.json').write_text(json.dumps(dict(observed='RED',
        healthy_sha256=hashlib.sha256(index).hexdigest(), altered_sha256=hashlib.sha256(altered).hexdigest(),
        alteration='First stage0 byte changed to stage1 in the actual source stream; actual Git index unchanged.'), indent=2) + '\n')
'''
    replace("    spec = importlib.util.spec_from_file_location('artifact_census', ROOT / HELPER)", before + "    spec = importlib.util.spec_from_file_location('artifact_census', ROOT / HELPER)")
    replace("'git_index': packet(index),", "'git_index': index_ref,")
    (BASE / name).write_text(source)
(BASE / 'composition.json').write_text(json.dumps(dict(activation=ACTIVATION, templates=templates, substitutions=changes,
    limits='New dated checkpoint format only; original November16 producer/observations unchanged. Git-tree inverse gates actual logical stream; no physical index/native custody.'), indent=2) + '\n')
print('Prepared dated metadata capture with exact clean-base index input reuse')
