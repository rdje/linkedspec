"""Capture public native/emitted diagnostics after binding retained project inputs."""
import argparse
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
BUNDLE = HERE / 'factory-boundary-after.json.gz'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert packet(raw) == row
    return raw


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('stage', choices=('before', 'after'))
parser.add_argument('--changed', action='append', default=[])
args = parser.parse_args()
destination = HERE / ('codeblock-' + args.stage + '.json.gz')
assert not destination.exists(), 'one-shot SDK observation'
bundle = json.loads(gzip.decompress(BUNDLE.read_bytes()))
sources = {name: row for name, row in bundle['sources'].items()
           if name.startswith(('perl/', 'specs/', 'conf/', 'tablescript/', 'ebnf/'))}
overrides = {}
for name, row in sources.items():
    actual = (ROOT / name).read_bytes()
    if actual != decode(row): overrides[name] = packet(actual)
assert set(overrides) == set(args.changed), 'unowned project source drift'
assert args.stage != 'before' or not overrides
instruments = {str(path.relative_to(ROOT)): packet(path.read_bytes()) for path in
               (Path(__file__), HERE / 'codeblock_probe.pl',
                ROOT / 'capability_conformance/callable_codeblock_contract.json',
                ROOT / 'tools/project_data_env.sh', ROOT / 'tools/project_data_run.sh')}
record = dict(stage=args.stage, source_bundle=dict(path=str(BUNDLE.relative_to(ROOT)), sha256=hashlib.sha256(BUNDLE.read_bytes()).hexdigest()),
              source_members={name: row['sha256'] for name, row in sources.items()}, overrides=overrides,
              instruments=instruments, commands=[],
              limits='Public unchanged callable fixture through Get/dump/descriptor and independently loaded emitted source. '
                     'Retained parent-owned project-source/grammar bytes are checked before SDK use; shared runtime/cache/OS/transitive inputs remain TYPE-REFERENCE-BOOK.1.2.23.4.2/SESSION5. No complete native or original canonical first-use custody credit.')
def save():
    destination.write_bytes(gzip.compress(json.dumps(record, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
save()
argv = ['perl', '-Iperl', str((HERE / 'codeblock_probe.pl').relative_to(ROOT))]
result = subprocess.run(argv, cwd=ROOT, env=dict(os.environ, PERL5LIB='', PERL5OPT=''), capture_output=True)
record['commands'].append(dict(argv=argv, cwd='.', exit=result.returncode,
                               stdout=packet(result.stdout), stderr=packet(result.stderr)))
save()
assert result.returncode == 0, 'actual probe channels retained'
observed = json.loads(result.stdout)
for name, row in sources.items():
    assert (ROOT / name).read_bytes() == decode(overrides.get(name, row))
for name, row in instruments.items(): assert (ROOT / name).read_bytes() == decode(row)
print(json.dumps(dict(stage=args.stage, parser_built=observed['parser_built'], loaded=observed['loaded'],
                      native_matches=observed['native'] == observed['expected'],
                      fresh_matches=observed['fresh'] == observed['expected'],
                      load_error=observed['load_error'], result='captured'), sort_keys=True))
