"""Compose fresh bounded cleanup instruments from explicit accepted inputs."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OLD = Path('docs/checkpoints/artifact-review-2026-11-11')
ACTIVATION = 'a3faaf97292550ba1e3001604e1e379d478bcdd4'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'census.py').exists()
sources, identities = {}, {}
for name in ('census.py', 'retire.py', 'review.py', 'run.py'):
    path = OLD / name
    body = path.read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    image = BASE / ('template-' + name + '.gz')
    image.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(image.read_bytes()) == body
    sources[name] = body
    identities[str(path)] = dict(image=str(image), bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
(BASE / 'template-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')


def adapt(body):
    return (body.decode().replace(str(OLD), str(BASE))
        .replace('TYPE-REFERENCE-BOOK.1.2.23.4.26', 'TYPE-REFERENCE-BOOK.1.2.23.4.31')
        .replace('e5f2cb78ab99192974178ea04177b6cabf283e1e', ACTIVATION)
        .replace(str(BASE / 'run.py'), str(BASE / 'run_stage.py')))


census = adapt(sources['census.py'])
(BASE / 'composition-input.json.gz').write_bytes(gzip.compress(sources['census.py'], mtime=0))
assert gzip.decompress((BASE / 'composition-input.json.gz').read_bytes()) == sources['census.py']
(BASE / 'census.py').write_text(census)
(BASE / 'composition.json').write_text(json.dumps(dict(template=str(OLD / 'census.py'),
    bytes=len(sources['census.py']), sha256=hashlib.sha256(sources['census.py']).hexdigest(),
    output_sha256=hashlib.sha256(census.encode()).hexdigest()), indent=2) + '\n')
logs = '''LOGS = {
    'array-concat-open-arity-dart-commit-qualified.log': '102ec3446407543c5ef64f3222bd0fffb5eb3064',
    'publication-size-monitor-commit-qualified.log': '952f8a022c59a478614ba1413e0e36e49e7e14e8',
    'array-concat-open-arity-julia-commit.log': 'a3faaf97292550ba1e3001604e1e379d478bcdd4',
}'''
for name in ('retire.py', 'review.py'):
    text = adapt(sources[name])
    start = text.index('LOGS = {')
    end = text.index('\n}', start) + 2
    text = text[:start] + logs + text[end:]
    text = text.replace('four completed', 'three completed').replace('Four exact combined', 'Three exact combined').replace('exact four combined', 'exact three combined')
    text = text.replace("['git', 'grep', '-n', '-F']", "['git', 'grep', '--no-recurse-submodules', '--threads=1', '-n', '-F']")
    text = text.replace("['--', 'docs/claims', 'docs/checkpoints', 'docs/knowledge']", "['--', '.']")
    if name == 'retire.py':
        text = text.replace("dict(argv=command, cwd='.')", "dict(argv=command, cwd='.', environment={})")
    else:
        text = text.replace('import sys\n', 'import sys\nimport tarfile\n')
        start = text.index('def raw_channel(')
        end = text.index('\n\ndef check_channels(', start)
        text = text[:start] + '''def raw_channel(tag, channel):
    if tag in ('predelete', 'references'):
        path = HERE / (tag + '-' + channel + '.log.gz')
    else:
        path = HERE / 'launches' / tag / (channel + '.log.gz')
    return gzip.decompress(path.read_bytes())


def source_images(tag):
    folder = HERE / 'launches' / tag
    rows = json.loads((folder / 'identities.json').read_bytes())
    with tarfile.open(folder / 'inputs.tar.gz') as archive:
        assert len(archive.getnames()) == len(rows) and set(archive.getnames()) == rows.keys()
        for member in archive:
            raw = archive.extractfile(member).read()
            row = rows[member.name]
            assert len(raw) == row['bytes'] and digest(raw) == row['sha256'], 'source image'
            assert member.mode & 0o777 == row['mode'], 'source mode'
            if Path(member.name).suffix in ('.py', '.sh'):
                assert (ROOT / member.name).read_bytes() == raw, 'source changed'
    assert str(BASE / 'run_stage.py') in rows and str(BASE / 'prepare.py') in rows
    if tag != 'prepare':
        assert str(BASE / 'review.py') in rows
    return rows


def channels(tag, tail):
    folder = HERE if tag == 'predelete' else HERE / 'launches' / tag
    prefix = tag + '-' if tag == 'predelete' else ''
    row = dict(command=json.loads((folder / (prefix + 'command.json')).read_bytes()),
        exit=(folder / (prefix + 'exit.txt')).read_text(),
        stdout=raw_channel(tag, 'stdout'), stderr=raw_channel(tag, 'stderr'))
    check_channels(row, tail)
    return row
''' + text[end:]
        text = text.replace("dict(argv=expected, cwd='.')", "dict(argv=expected, cwd='.', environment={})")
    compile(text, name, 'exec')
    (BASE / name).write_text(text)

# Check native Git's public no-submodule/one-thread query spelling before the
# later complete tracked-file reference query. No dependency implementation read.
command = ['git', 'grep', '--no-recurse-submodules', '--threads=1', '-q', '-F', 'Agent bootstrap', '--', 'AGENTS.md']
(BASE / 'grep-preflight-command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('grep-preflight-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'grep-preflight-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b''
(BASE / 'git-grep-contract.txt').write_text('Public Git grep contract: https://git-scm.com/docs/git-grep\nThe query searches tracked working-tree files, explicitly disables submodule recursion and uses one worker. No textconv or untracked-file option is enabled.\n')

# This exact current mutable task image includes the already-owned new leaf.
task = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
before = task.read_bytes()
needle = b'`TYPE-REFERENCE-BOOK.1.2.23.4.29`; remaining admission leaves split at activation.'
replacement = b'`TYPE-REFERENCE-BOOK.1.2.23.4.29`, `TYPE-REFERENCE-BOOK.1.2.23.4.30`, `TYPE-REFERENCE-BOOK.1.2.23.4.31`; remaining admission leaves split at activation.'
assert before.count(needle) == 1
after = before.replace(needle, replacement, 1)
mode = task.stat().st_mode & 0o777
for tag, body in (('before', before), ('after', after)):
    image = BASE / ('task-parent-' + tag + '.md.gz')
    image.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(image.read_bytes()) == body
    (BASE / ('task-parent-' + tag + '.json')).write_text(json.dumps(dict(path=str(task), bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=mode), indent=2) + '\n')
task.write_bytes(after)
assert task.read_bytes() == after and task.stat().st_mode & 0o777 == mode

monitor = Path('.linkedspec-data/push-monitor/20261112T151818.046462Z')
receipt = json.loads((monitor / 'result.json').read_bytes())
assert receipt['head'] == ACTIVATION and receipt['estimated_non_thin_pack_bytes'] == 1287859376
target = BASE / 'push-monitor-current'
target.mkdir()
retained = {}
for path in sorted(monitor.iterdir()):
    if path.is_file() and path.suffix not in ('.pack', '.idx', '.rev', '.log'):
        body = path.read_bytes()
        destination = target / path.name
        destination.write_bytes(body)
        assert destination.read_bytes() == body
        retained[path.name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), original_mode=path.stat().st_mode & 0o777)
(target / 'retention-identities.json').write_text(json.dumps(retained, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(result='PASS', templates=len(sources), fresh_instruments=['census.py', 'retire.py', 'review.py'],
    parent_child_links=[30, 31], scope='Own accepted source composition; exact completed logs only, all native/cache/physical custody gaps remain.')))
