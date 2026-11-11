"""Acquire fixed/variadic source boundaries before result-role production."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert not subprocess.check_output(['git', 'diff', '--name-only', '--', 'perl', 'specs']).strip()
cases = []
definitions = {
    'variadic_empty': ('fn all_values(...values) {return(values)}', 'all_values()', [[], ''], 'valid'),
    'variadic_multi': ('fn all_values(...values) {return(values)}', 'all_values({order=cat(order,"S");" head "}," tail ")', [['head', 'tail'], 'S'], 'valid'),
    'fixed_missing': ('fn pair(left,right) {return([left,right])}', 'pair({order=cat(order,"S");"head"})', None, 'invalid-signature'),
    'fixed_extra': ('fn pair(left,right) {return([left,right])}', 'pair("head","tail",{order=cat(order,"X");"extra"})', None, 'invalid-signature'),
    'variadic_missing': ('fn collect(head,...rest) {return([head])}', 'collect()', None, 'invalid-signature'),
}
for name, (definition, call, expected, role) in definitions.items():
    for form in ('terminal', 'composed'):
        expression = call + '.trim_each()'
        if form == 'composed':
            expression += '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")}'
        body = 'order="";out=' + expression + ';return([out,order])'
        cases.append(dict(id='signature_' + name + '_' + form, body=body,
            source=definition + '\n\nValue:: I {' + body + '}\n', rule='Value', input='x',
            question=role, form=form, authored_expected=(expected if form == 'terminal' else [None, expected[1]]) if role == 'valid' else None))
assert len(cases) == len({case['id'] for case in cases}) == 10
fixture = BASE / 'signature-cases.json'; assert not fixture.exists()
fixture.write_text(json.dumps(cases, indent=2) + '\n')
source = (BASE / 'observer.pl').read_bytes()
recorded = json.loads((BASE / 'intake/input-identities.json').read_bytes())[str(BASE / 'observer.pl')]
assert hashlib.sha256(source).hexdigest() == recorded['sha256']
old = 'docs/checkpoints/array-pipeline-callable-perl-2026-11-11/cases.json'
assert source.decode().count(old) == 1
observer = BASE / 'signature_observer.pl'; assert not observer.exists()
observer.write_text(source.decode().replace(old, str(fixture)))
OUT = BASE / 'signatures'; OUT.mkdir()
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl', 'specs'], text=True).splitlines()]
paths += [p for p in BASE.iterdir() if p.is_file()]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
paths += [Path('capability_conformance/callable_signature_contract.json'), Path('capability_conformance/outward_descriptor_contract.json')]
rows = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        assert path.is_file() and path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        rows[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=path, recursive=False)
with tarfile.open(OUT / 'inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == set(rows)
    for member in archive:
        raw = archive.extractfile(member).read(); row = rows[member.name]
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', str(observer), str(fixture), str(OUT)]
(OUT / 'run-command.json').write_text(json.dumps(dict(cwd='.', argv=argv), indent=2) + '\n')
result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / ('run-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'run-exit.txt').write_text(str(result.returncode) + '\n')
for name, row in rows.items():
    assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == row['sha256'], name
    assert Path(name).stat().st_mode & 0o777 == row['mode'], name
assert result.returncode == 0 and not result.stderr, 'Actual failed signature acquisition retained'
print('Ten existing fixed/variadic boundary questions acquired; actual0/empty outer stderr/input stability')
