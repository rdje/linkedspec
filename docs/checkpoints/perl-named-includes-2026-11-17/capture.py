"""One-shot source archive, followed only by static PPI inspection."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import stat
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


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


def main():
    plan = json.loads((BASE / 'plan.json').read_bytes())
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == plan['activation']
    targets = {e['target'] for e in plan['entries']} | set(plan['context_targets'])
    parents = {e['parent'] for e in plan['entries']}
    prior = Path(plan['prior_census'])
    fixed = {plan[k] for k in ('lexer', 'old_named_ledger', 'old_source_identities', 'old_roles')}
    fixed |= {str(prior / ('commands/consumers-' + c + '.gz')) for c in ('stdin', 'stdout')}
    fixed |= {'tools/project_data_run.sh', 'tools/run_python_project_data.sh'}
    own = {str(BASE / n) for n in ('prepare_plan.py', 'plan.json', 'capture.py', 'review.py', 'record_review.py')}
    identities = {}
    with tarfile.open(BASE / 'inputs.tar.gz', 'x:gz') as archive:
        for name in sorted(targets | parents | fixed | own):
            path = Path(name)
            assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
            assert path.resolve().is_relative_to(Path.cwd()) and path.stat().st_dev == Path.cwd().stat().st_dev
            body = path.read_bytes()
            identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            archive.add(path, arcname=name, recursive=False)
    (BASE / 'identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
    tree = run('activation-tree', ['git', 'ls-tree', '-rz', plan['activation'], '--', *sorted(targets | parents | fixed)])
    assert tree.returncode == 0 and not tree.stderr
    request = dict(ppi_version=plan['ppi_version'], words=plan['words'], documents=[
        dict(path=n, source=Path(n).read_text(), sha256=identities[n]['sha256']) for n in sorted(targets)])
    result = run('targets', ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perl', plan['lexer']],
        json.dumps(request, ensure_ascii=False, sort_keys=True).encode())
    assert result.returncode == 0 and not result.stderr, 'static lexer result retained'
    spec = importlib.util.spec_from_file_location('named_include_reader', BASE / 'review.py')
    reader = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(reader)
    sources, ids = reader.recover()
    report = reader.analyze(sources, ids)
    (BASE / 'roles.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
    print(json.dumps(report['summary'], indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
