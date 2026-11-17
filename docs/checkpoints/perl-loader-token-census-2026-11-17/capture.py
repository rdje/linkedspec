"""Freeze source and instruments before controlled and consumer PPI subprocesses."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import stat
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
PRIOR = Path('docs/checkpoints/perl-consumer-roles-2026-11-16')


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


def archive(paths):
    identities = {}
    with tarfile.open(BASE / 'preparation.tar.gz', 'x:gz') as packed:
        for name in sorted(paths):
            path = Path(name)
            assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
            assert path.resolve().is_relative_to(ROOT) and path.stat().st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            packed.add(path, arcname=name, recursive=False)
    (BASE / 'preparation-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')


def request(plan, documents):
    return json.dumps(dict(ppi_version=plan['ppi_version'], words=plan['words'], documents=documents),
        ensure_ascii=False, sort_keys=True).encode('utf-8')


def main():
    plan = json.loads((BASE / 'plan.json').read_bytes())
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == plan['activation']
    assert not (BASE / 'preparation.tar.gz').exists(), 'one-shot capture'
    references = {}
    for leaf in ('review.py', 'inputs.tar.gz', 'identities.json', 'git-tree.json.gz'):
        path = PRIOR / leaf
        references[str(path)] = dict(sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
    (BASE / 'reused-inputs.json').write_text(json.dumps(references, indent=2, sort_keys=True) + '\n')
    own = {str(BASE / name) for name in ('plan.json', 'capture.py', 'review.py', 'lexer.pl', 'specimens.json')}
    development = {str(path) for path in (BASE / 'documentation').iterdir()}
    archive(own | development | set(plan['fixed_inputs']))
    spec = importlib.util.spec_from_file_location('perl_token_review', BASE / 'review.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    sources, modes = module.prior_sources()
    for name in plan['consumers']:
        body = sources[name]
        path = Path(name)
        assert not path.is_symlink() and path.read_bytes() == body and stat.S_IMODE(path.stat().st_mode) == modes[name]
    tree = run('activation-tree', ['git', 'ls-tree', '-rz', plan['activation'], '--',
        *sorted(set(plan['consumers']) | set(references) | set(plan['fixed_inputs']))])
    assert tree.returncode == 0 and not tree.stderr
    specimens = json.loads((BASE / 'specimens.json').read_bytes())
    docs = [dict(path='specimen:' + row['id'], source=row['source'], sha256=hashlib.sha256(row['source'].encode()).hexdigest()) for row in specimens]
    argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perl', str(BASE / 'lexer.pl')]
    controlled = run('specimens', argv, request(plan, docs))
    assert controlled.returncode == 0, 'controlled lexer failure retained before consumer use'
    parsed = json.loads(controlled.stdout)
    assert module.specimen_oracle(specimens, parsed)['result'] == 'PASS', 'controlled lexical qualification'
    sentinel = next(row['source'] for row in specimens if row['id'] == 'mixed-sentinel')
    compiler = run('compiler-sentinel', ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perl', '-c'], sentinel.encode())
    assert compiler.returncode != 0 and b'EXECUTION_SENTINEL' in compiler.stderr, 'compiler must distinguish executed BEGIN'
    quoted = next(row for row in specimens if row['id'] == 'quoted-only')
    promoted = quoted['source'] + "open my $added, '<', 'added.json';\n"
    inverse = run('quote-promoted', argv, request(plan, [dict(path='specimen:quoted-only', source=promoted,
        sha256=hashlib.sha256(promoted.encode()).hexdigest())]))
    assert inverse.returncode == 0
    assert module.specimen_oracle([quoted], json.loads(inverse.stdout))['result'] == 'RED', 'changed executable site must reject old oracle'
    documents = [dict(path=name, source=sources[name].decode('utf-8'), sha256=hashlib.sha256(sources[name]).hexdigest()) for name in plan['consumers']]
    observed = run('consumers', argv, request(plan, documents))
    assert observed.returncode == 0, 'actual consumer lexer failure retained'
    all_sources, identities = module.recover()
    report = module.report(all_sources, identities)
    (BASE / 'census.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
    print(json.dumps(dict(result='PASS', consumers=len(report['consumers']), qualified=len(report['qualified']),
        needs_qualification=report['needs_qualification'], controls=report['controls']), sort_keys=True))


if __name__ == '__main__':
    main()
