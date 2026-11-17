"""One-shot before-use instrument and input capture; only controlled PPI runs."""
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


def run(label, argv, stdin=None):
    folder = BASE / 'commands'
    folder.mkdir(exist_ok=True)
    with (folder / (label + '.json')).open('x') as stream:
        json.dump(dict(argv=argv, cwd='.'), stream, indent=2)
        stream.write('\n')
    if stdin is not None:
        (folder / (label + '-stdin.gz')).write_bytes(gzip.compress(stdin, mtime=0))
    result = subprocess.run(argv, input=stdin, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (folder / (label + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (folder / (label + '-exit.txt')).write_text(str(result.returncode) + '\n')
    return result


def archive(label, names):
    identities = {}
    with tarfile.open(BASE / (label + '.tar.gz'), 'x:gz') as archive:
        for name in sorted(names):
            path = Path(name)
            assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
            assert path.resolve().is_relative_to(Path.cwd()) and path.stat().st_dev == Path.cwd().stat().st_dev
            body = path.read_bytes()
            identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            archive.add(path, arcname=name, recursive=False)
    (BASE / (label + '-identities.json')).write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')


def main():
    plan = json.loads((BASE / 'plan.json').read_bytes())
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == plan['activation']
    prior = Path(plan['prior'])
    fixed = {str(prior / n) for n in ('lexer.pl', 'commands/consumers-stdin.gz', 'commands/consumers-stdout.gz')}
    fixed |= {plan['old_identities'], 'tools/project_data_run.sh', 'tools/run_python_project_data.sh'}
    own = {str(BASE / n) for n in ('plan.json', 'specimens.json', 'classify.py', 'capture.py', 'review.py', 'record_review.py')}
    archive('instruments', fixed | own)
    classifier = module('literal_open_classifier', 'classify.py')
    output = json.loads(gzip.decompress((prior / 'commands/consumers-stdout.gz').read_bytes()))
    matched, remainder = classifier.inventory(output)
    inputs = {r['path'] for r in matched if r['role'] == 'literal-input-read'}
    archive('targets', inputs)
    request = json.loads(gzip.decompress((prior / 'commands/consumers-stdin.gz').read_bytes()))
    consumers = {r['path'] for r in request['documents']}
    tree = run('activation-tree', ['git', 'ls-tree', '-rz', plan['activation'], '--', *sorted(consumers | inputs | fixed)])
    assert tree.returncode == 0 and not tree.stderr
    specimens = json.loads((BASE / 'specimens.json').read_bytes())
    documents = [dict(path='specimen:' + r['id'], source=r['source'], sha256=hashlib.sha256(r['source'].encode()).hexdigest()) for r in specimens]
    payload = dict(ppi_version=plan['ppi_version'], words=['open'], documents=documents)
    argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perl', str(prior / 'lexer.pl')]
    child = run('specimens', argv, json.dumps(payload, ensure_ascii=False, sort_keys=True).encode())
    assert child.returncode == 0 and not child.stderr
    changed = specimens[0]['source'].replace("'<:raw'", "'>:raw'", 1)
    assert changed != specimens[0]['source']
    inverse = dict(ppi_version=plan['ppi_version'], words=['open'], documents=[dict(
        path='specimen:read-write', source=changed, sha256=hashlib.sha256(changed.encode()).hexdigest())])
    child = run('mode-promoted', argv, json.dumps(inverse, ensure_ascii=False, sort_keys=True).encode())
    assert child.returncode == 0 and not child.stderr
    reader = module('literal_open_reader', 'review.py')
    sources, identities = reader.recover()
    report = reader.report(sources, identities)
    (BASE / 'inventory.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
    print(json.dumps(report['summary'], indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
