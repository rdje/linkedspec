"""Freeze new instruments, qualify controlled sources, then inspect the corpus."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import stat
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def module(name, leaf):
    spec = importlib.util.spec_from_file_location(name, BASE / leaf)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def run(label, argv, data=None):
    folder = BASE / 'commands'
    folder.mkdir(exist_ok=True)
    with (folder / (label + '.json')).open('x') as stream:
        json.dump(dict(argv=argv, cwd='.'), stream, indent=2)
        stream.write(chr(10))
    if data is not None:
        (folder / (label + '-stdin.gz')).write_bytes(gzip.compress(data, mtime=0))
    child = subprocess.run(argv, input=data, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (folder / (label + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(child, channel), mtime=0))
    (folder / (label + '-exit.txt')).write_text(str(child.returncode) + chr(10))
    return child


def freeze(label, names):
    identities = {}
    with tarfile.open(BASE / (label + '.tar.gz'), 'x:gz') as archive:
        for name in sorted(set(names)):
            path = Path(name)
            assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
            assert path.resolve().is_relative_to(Path.cwd()) and path.stat().st_dev == Path.cwd().stat().st_dev
            body = path.read_bytes()
            identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            archive.add(path, arcname=name, recursive=False)
    (BASE / (label + '-identities.json')).write_text(json.dumps(identities, indent=2, sort_keys=True) + chr(10))


def main():
    plan = json.loads((BASE / 'plan.json').read_bytes())
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == plan['activation']
    own = {str(path) for path in BASE.iterdir() if path.suffix in ('.py', '.pl', '.json')}
    own |= {'tools/project_data_run.sh', 'tools/run_python_project_data.sh'}
    own |= {str(path) for path in (BASE / 'documentation').iterdir() if path.is_file()}
    freeze('before', own)
    library = module('variable_source_recovery', 'sources.py')
    reviewer = module('variable_source_reader', 'review.py')
    references = json.loads((BASE / 'reused-inputs.json').read_bytes())
    sources, retained = library.reused(references, plan)
    for name, (body, mode) in sources.items():
        path = Path(name)
        assert not path.is_symlink() and path.read_bytes() == body and stat.S_IMODE(path.stat().st_mode) == mode
    argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perl', str(BASE / 'lexer.pl')]
    specimens = json.loads((BASE / 'specimens.json').read_bytes())
    documents = [dict(path='specimen:' + row['id'], source=row['source'], sha256=library.sha(row['source'].encode())) for row in specimens]
    request = dict(ppi_version=plan['ppi_version'], documents=documents)
    child = run('specimens', argv, json.dumps(request, ensure_ascii=False, sort_keys=True).encode())
    assert child.returncode == 0 and not child.stderr
    assert reviewer.specimen_oracle(specimens, json.loads(child.stdout))['result'] == 'PASS', 'controlled grammar qualification'
    changed = specimens[0]['source'].replace("open my $fh", "$path='tests/changed.json'; open my $fh", 1)
    assert changed != specimens[0]['source']
    request = dict(ppi_version=plan['ppi_version'], documents=[dict(path='specimen:adjacent-read-write', source=changed, sha256=library.sha(changed.encode()))])
    child = run('intervening-write', argv, json.dumps(request, ensure_ascii=False, sort_keys=True).encode())
    assert child.returncode == 0 and not child.stderr
    assert reviewer.specimen_oracle([specimens[0]], json.loads(child.stdout))['result'] == 'RED', 'actual changed-source rejection'
    documents = [dict(path=name, source=sources[name][0].decode(), sha256=library.sha(sources[name][0])) for name in plan['sources']]
    request = dict(ppi_version=plan['ppi_version'], documents=documents)
    child = run('corpus', argv, json.dumps(request, ensure_ascii=False, sort_keys=True).encode())
    assert child.returncode == 0 and not child.stderr
    observed = json.loads(child.stdout)
    targets = {site['binding']['path'] for row in observed['documents'] for site in row['sites']
        if site['matched'] and site['binding']['role'] == 'declared-input-read'}
    freeze('targets', targets)
    tree = run('activation-tree', ['git', 'ls-tree', '-rz', plan['activation'], '--',
        *sorted(set(sources) | set(references) | targets | {'tools/project_data_run.sh', 'tools/run_python_project_data.sh'})])
    assert tree.returncode == 0 and not tree.stderr
    recovered, identities = reviewer.recover()
    report = reviewer.report(recovered, identities)
    (BASE / 'inventory.json').write_text(json.dumps(report, indent=2, sort_keys=True) + chr(10))
    child = run('review', ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review.py'), '--current'])
    assert child.returncode == 0, child.stderr.decode()
    print(child.stdout.decode(), end='')


if __name__ == '__main__':
    main()
