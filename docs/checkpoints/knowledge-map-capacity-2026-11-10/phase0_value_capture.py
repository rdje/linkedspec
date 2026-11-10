"""Acquire original/current lowering against the pre-authored Phase0 oracles."""
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OUTPUT = HERE / 'phase0-values-qualified.json.gz'
METHOD = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


assert not OUTPUT.exists(), 'one-shot source/value/effect acquisition'
bundle_path = HERE / 'factory-boundary-after.json.gz'
bundle = json.loads(gzip.decompress(bundle_path.read_bytes()))
sources = {name: row for name, row in bundle['sources'].items()
           if name.startswith(('perl/', 'specs/', 'conf/', 'tablescript/', 'ebnf/'))}
old = gzip.decompress((HERE / 'codeblock-method-before.pm.gz').read_bytes())
current = (ROOT / METHOD).read_bytes()
assert base64.b64decode(sources[METHOD]['base64']) == old
for name, row in sources.items():
    assert (ROOT / name).read_bytes() == (current if name == METHOD else base64.b64decode(row['base64']))
assert (ROOT / 't/phase0_regression.t').read_bytes() == gzip.decompress((HERE / 'phase0-before.t.gz').read_bytes())
names = ('t/phase0_regression.t', str(Path(__file__).relative_to(ROOT)),
         str((HERE / 'phase0_value_probe.pl').relative_to(ROOT)),
         str((HERE / 'phase0-oracle-cases.json').relative_to(ROOT)),
         'tools/project_data_env.sh', 'tools/project_data_run.sh')
record = dict(inputs={name: packet((ROOT / name).read_bytes()) for name in names},
              methods=dict(activation=packet(old), repaired=packet(current)), commands={},
              source_bundle=dict(path=bundle_path.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(bundle_path.read_bytes()).hexdigest()),
              source_members={name: row['sha256'] for name, row in sources.items()},
              limits='Finite20 source/value/effect cases and executable wrong-value/warning controls. No original canonical first-use or complete native/cache/OS/transitive custody credit;4.2/SESSION5 own that closure.')


def save():
    OUTPUT.write_bytes(gzip.compress(json.dumps(record, sort_keys=True, separators=(',', ':')).encode(), mtime=0))


save()
with tempfile.TemporaryDirectory(prefix='phase0-source-', dir=ROOT / '.linkedspec-data/normal-hook-restoration') as temporary:
    overlay = Path(temporary)
    path = overlay / 'LinkedSpec/ActionIR/MethodLowering.pm'
    path.parent.mkdir(parents=True); path.write_bytes(old)
    assert path.stat().st_dev == ROOT.stat().st_dev
    for stage in ('activation', 'repaired'):
        argv = ['perl', '-Iperl']
        if stage == 'activation':
            argv.extend(['-Mlib=' + overlay.relative_to(ROOT).as_posix(), '-MLinkedSpec::ActionIR::MethodLowering'])
        argv.extend([str((HERE / 'phase0_value_probe.pl').relative_to(ROOT)),
                     str((HERE / 'phase0-oracle-cases.json').relative_to(ROOT)), 't/phase0_regression.t'])
        result = subprocess.run(argv, cwd=ROOT, env=dict(os.environ, PERL5LIB='', PERL5OPT=''), capture_output=True)
        row = dict(argv=argv, cwd='.', exit=result.returncode, stdout=packet(result.stdout), stderr=packet(result.stderr))
        record['commands'][stage] = row; save()
        assert result.returncode == 0
        parsed = json.loads(result.stdout.splitlines()[-1])
        assert parsed['module_sha256'] == record['methods'][stage]['sha256'], 'wrong lowering image'
        row['frame'] = packet(result.stdout.splitlines(keepends=True)[-1]); save()
for name, row in record['inputs'].items():
    assert (ROOT / name).read_bytes() == base64.b64decode(row['base64'])
for name, row in sources.items():
    assert (ROOT / name).read_bytes() == (current if name == METHOD else base64.b64decode(row['base64']))
print(json.dumps(dict(result='captured', commands={name: row['exit'] for name, row in record['commands'].items()}), sort_keys=True))
