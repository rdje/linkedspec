"""One-shot lexical observation. Immutable input images are reused, not duplicated."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import stat
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PRIOR = Path('docs/checkpoints/perl-variable-literal-qualification-2026-11-17')
ACTIVATION = '3442fcd34318043d67e8523a2db2fd84b44148b6'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'before.tar.gz').exists(), 'capture is one-shot'


def identity(path):
    body = path.read_bytes()
    return dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))


references = json.loads((PRIOR / 'reused-inputs.json').read_bytes())
for path in (PRIOR / 'plan.json', Path('docs/checkpoints/perl-literal-open-qualification-2026-11-17/commands/consumers-stdout.gz')):
    references[str(path)] = identity(path)
(BASE / 'references.json').write_text(json.dumps(references, sort_keys=True, indent=2) + '\n')
names = list(BASE.glob('*.py')) + list(BASE.glob('*.pl')) + list(BASE.glob('*.json'))
names += [Path('tools') / n for n in ('project_data_run.sh', 'project_data_env.sh', 'run_python_project_data.sh')]
identities = {}
with tarfile.open(BASE / 'before.tar.gz', 'x:gz') as packed:
    for path in names:
        assert path.stat().st_dev == Path.cwd().stat().st_dev and not path.is_symlink()
        identities[str(path)] = identity(path)
        packed.add(path, arcname=str(path), recursive=False)
(BASE / 'before-identities.json').write_text(json.dumps(identities, sort_keys=True, indent=2) + '\n')
spec = importlib.util.spec_from_file_location('other_io_reader', BASE / 'review.py')
review = importlib.util.module_from_spec(spec)
spec.loader.exec_module(review)
plan, sources, retained = review.recover()
for name, (body, mode) in sources.items():
    assert Path(name).read_bytes() == body and stat.S_IMODE(Path(name).stat().st_mode) == mode
(BASE / 'commands').mkdir()
argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perl', str(BASE / 'lexer.pl')]


def run(label, documents):
    data = json.dumps(dict(ppi_version=plan['ppi_version'], documents=documents), ensure_ascii=False, sort_keys=True).encode()
    folder = BASE / 'commands'
    (folder / (label + '.json')).write_text(json.dumps(dict(argv=argv, cwd='.', stdin_bytes=len(data), stdin_sha256=review.sha(data)), indent=2) + '\n')
    child = subprocess.run(argv, input=data, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (folder / (label + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(child, channel), mtime=0))
    (folder / (label + '-exit.txt')).write_text(str(child.returncode) + '\n')
    assert child.returncode == 0 and not child.stderr
    return json.loads(child.stdout)


specimens = json.loads((BASE / 'specimens.json').read_bytes())
documents = [dict(path='specimen:' + r['id'], source=r['source'], sha256=review.sha(r['source'].encode())) for r in specimens]
assert review.oracle(specimens, run('specimens', documents)), 'independent specimen expectations'
changed = specimens[0]['source'].replace('\\$output', '$output', 1)
assert changed != specimens[0]['source']
assert not review.oracle([specimens[0]], run('reference-removed', [dict(path='specimen:' + specimens[0]['id'], source=changed, sha256=review.sha(changed.encode()))]))
run('corpus', [dict(path=n, source=sources[n][0].decode(), sha256=review.sha(sources[n][0])) for n in plan['sources']])
tree = subprocess.run(['git', 'ls-tree', '-rz', ACTIVATION, '--', *sorted(set(sources) | set(references))], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('activation-tree-' + channel + '.gz')).write_bytes(gzip.compress(getattr(tree, channel), mtime=0))
assert tree.returncode == 0 and not tree.stderr
result = review.report(True)
(BASE / 'inventory.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
result.pop('non_open')
print(json.dumps(result, sort_keys=True))
