"""One-shot syntax-valid semantic source faults against the exact public regression."""
import base64
import hashlib
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0-'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_receiver_scalar_copy.t'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
fixture = json.loads((ROOT / (PREFIX + 'fixture.json')).read_bytes())
assert fixture['returncode'] == 0 and fixture['unchanged'] is True
files = {p: (ROOT / p).read_bytes() for p in fixture['inputs']}
assert {p: digest(raw) for p, raw in files.items()} == fixture['inputs']
source = files[MODULE].decode()
start = source.index("  my $first_args = $calls->[0]{args} || [];\n")
end = source.index('  if (_is_tree_traversal_receiver_method($first_method))', start)
change = source[start:end]
assert change.count("$first_method eq 'copy'") == 1
dispatch = "   return $lower_ast_aggregate_call_node->({\n    kind => 'call', name => 'copy', args => [$receiver],\n    source_span => $node->{source_span},\n   });"
assert change.count(dispatch) == 1
variants = {
    'remove-fix': source[:start] + source[end:],
    'ignore-tail': source[:start] + change.replace(" && @$calls == 1", '', 1) + source[end:],
    'borrow-reference': source[:start] + change.replace(dispatch, "   return '$'.$receiver->{name};", 1) + source[end:],
}
assert len(set(variants.values())) == 3 and all(v != source for v in variants.values())
environment = dict(os.environ, PERL5LIB='', PERL5OPT='',
                   LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)


def census(directory):
    return {p.relative_to(directory).as_posix(): digest(p.read_bytes())
            for p in sorted(directory.rglob('*')) if p.is_file()}


def run(directory, command):
    r = subprocess.run(command, cwd=directory, env=environment,
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    return {'command': command, 'returncode': r.returncode,
            'stdout_base64': base64.b64encode(r.stdout).decode(),
            'stderr_base64': base64.b64encode(r.stderr).decode()}, r


index = []
with tempfile.TemporaryDirectory(prefix='receiver-copy-faults-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        p = supplied / path
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(raw)
    for name, variant in variants.items():
        target = ROOT / (PREFIX + 'inverse-' + name + '.json')
        assert not target.exists(), 'one-shot fault already exists'
        raw = variant.encode()
        (supplied / MODULE).write_bytes(raw)
        inputs = dict(fixture['inputs'], **{MODULE: digest(raw)})
        assert census(supplied) == inputs
        syntax, syntax_result = run(supplied, ['perl', '-c', '-Iperl', MODULE])
        tap, result = run(supplied, ['perl', '-Iperl', TEST])
        unchanged = census(supplied) == inputs
        record = {'producer_sha256': digest(Path(__file__).read_bytes()), 'name': name,
                  'fixture_sha256': digest((ROOT / (PREFIX + 'fixture.json')).read_bytes()),
                  'source_base64': base64.b64encode(raw).decode(), 'inputs': inputs,
                  'syntax': syntax, 'tap': tap, 'unchanged': unchanged,
                  'scope': 'Exact full source mutant/184 inputs and syntax/TAP channels; same immutable public regression/probe. No original channel is refreshed.'}
        target.write_text(json.dumps(record, indent=2) + '\n')
        plans = re.findall(rb'^1\.\.(\d+)$', result.stdout, re.MULTILINE)
        numbers = re.findall(rb'^(?:not )?ok (\d+)', result.stdout, re.MULTILINE)
        failures = re.findall(rb'^not ok \d+ - (.*)$', result.stdout, re.MULTILINE)
        assert syntax_result.returncode == 0 and b'syntax OK' in syntax_result.stderr
        assert plans == [b'50'] and [int(n) for n in numbers] == list(range(1, 51))
        assert result.returncode != 0 and failures and unchanged
        index.append({'name': name, 'path': target.relative_to(ROOT).as_posix(),
                      'sha256': digest(target.read_bytes()),
                      'semantic_failures': [f.decode() for f in failures]})
target = ROOT / (PREFIX + 'inverses.json')
assert not target.exists()
target.write_text(json.dumps({'producer_sha256': digest(Path(__file__).read_bytes()),
                             'rows': index}, indent=2) + '\n')
print('Three effective source faults retained:', [(r['name'], len(r['semantic_failures'])) for r in index])
