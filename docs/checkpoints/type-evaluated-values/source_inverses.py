"""Falsify the actual producer with independent emitted-boundary omissions in supplied contexts."""
import gzip
import json
import os
import subprocess
import tempfile
from pathlib import Path
import common as c


def load(name):
    return json.loads(gzip.decompress((c.ROOT / (c.PREFIX + name)).read_bytes()))


def observed(run):
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    output = c.decode(run['stdout_base64'])
    assert output.count(b'\nSOURCE_TYPE_MODEL_JSON ') == 1
    prelude, raw = output.split(b'\nSOURCE_TYPE_MODEL_JSON ')
    assert not prelude
    return json.loads(raw)


def mismatches(run, cases):
    data = observed(run)
    expected = {case['id']: case['expected'] for case in cases}
    assert len(data['rows']) == len(expected) and {row['id'] for row in data['rows']} == set(expected)
    failed = []
    encode = lambda value: json.dumps(value, sort_keys=True, separators=(',', ':'))
    for row in data['rows']:
        assert all(row[route]['ok'] is True for route in ('descriptor', 'live', 'generated')), row['id']
        assert row['warnings'] == []
        assert row['descriptor']['value']['canonical_action_ir_fallback_count'] == 0
        wanted = encode(expected[row['id']])
        native = encode(row['live']['value'])
        generated = encode(row['generated']['value']['value'])
        assert native == generated, row['id']
        if native != wanted:
            failed.append(row['id'])
    return failed


prepared = load('final-inputs.json.gz')
green = load('final-green.json.gz')
assert all(run['returncode'] == 0 for run in green['syntax'] + green['runs']) and green['inputs_unchanged']
inputs = dict(prepared['inputs'])
inputs[c.PREFIX + 'source_inverses.py'] = c.read(c.PREFIX + 'source_inverses.py')
assert c.unchanged(inputs)
module = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
source = c.decode(inputs[module]['base64']).decode()
proposal = load('candidate-proposal.json.gz')
changes = {change['scope']: change for change in proposal['exact_changes']}
cases = prepared['cases']
healthy_controls = {'rvalue-control', 'saved-binding-control', 'named-function-control', 'nested-codeblock-body'}
all_bad = {case['id'] for case in cases} - healthy_controls
array_bad = all_bad - {'array-constructor', 'codeblock-arguments', 'hash-literal-values',
    'hash-constructor-values', 'hash-dynamic-key'}
variants = []
needle = "return 'do { my @__ls_evaluated_values = ('.$expr.'); @__ls_evaluated_values }'"
assert source.count(needle) == 1
variants.append(('identity-template', source.replace(needle, 'return $expr', 1), all_bad))
for name, scopes, expected in (
    ('array-members', ('typed and legacy shape array members',), array_bad),
    ('hash-members', ('typed and legacy shape hash keys/values',), {'hash-literal-values', 'hash-dynamic-key'}),
    ('array-constructors', ('typed multi-argument array constructor', 'legacy array constructor'), {'array-constructor'}),
    ('hash-constructors', ('typed hash constructor pairs', 'legacy hash constructor pairs'), {'hash-constructor-values'}),
    ('callable-arguments', ('bound callable arguments',), {'codeblock-arguments'}),
):
    changed = source
    for scope in scopes:
        change = changes[scope]
        assert changed.count(change['new']) == change['occurrences'], scope
        changed = changed.replace(change['new'], change['old'])
    variants.append((name, changed, expected))
variant_inputs = {name: dict(base64=c.encode(text.encode()), sha256=c.sha(text.encode()),
    mode=inputs[module]['mode'], expected_mismatches=sorted(expected)) for name, text, expected in variants}
c.write_new(c.PREFIX + 'inverse-inputs.json.gz', dict(inputs=inputs, variants=variant_inputs,
    cases=cases, scope='Six actual producer faults are retained before commands. Omit a value '
    'boundary or turn the shared template into identity; all other source, cases and expected '
    'values stay exact. These are finite effective controls, not exhaustive branch coverage.'), packed=True)
runs = []
with tempfile.TemporaryDirectory(prefix='type-value-source-inverses-', dir=os.environ['TMPDIR']) as directory:
    root = Path(directory)
    assert root.stat().st_dev == c.ROOT.stat().st_dev
    for path, item in inputs.items():
        target = root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(c.decode(item['base64']))
        target.chmod(item['mode'])
    temporary = root / '.linkedspec-data/tmp'
    temporary.mkdir(parents=True)
    environment = dict(os.environ,
        GIT_DIR=subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=c.ROOT, text=True).strip(),
        GIT_WORK_TREE=str(root), GIT_OPTIONAL_LOCKS='0', TMPDIR=str(temporary))

    def run(name, item):
        target = root / module
        target.write_bytes(c.decode(item['base64']))
        target.chmod(item['mode'])
        command = ['perl', '-Iperl', c.PREFIX + 'probe.pl']
        result = subprocess.run(command, cwd=root, env=environment, capture_output=True, input=json.dumps(cases).encode())
        actual = dict(command=command, returncode=result.returncode,
                      stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr))
        rows = mismatches(actual, cases)
        loaded = observed(actual)['inc']['LinkedSpec/ActionIR/MethodLowering.pm']
        loaded_path = Path(loaded) if Path(loaded).is_absolute() else root / loaded
        assert loaded_path.resolve() == target.resolve()
        assert c.sha(loaded_path.read_bytes()) == item['sha256']
        for path, expected in inputs.items():
            current = item if path == module else expected
            assert (root / path).read_bytes() == c.decode(current['base64'])
            assert (root / path).stat().st_mode & 0o7777 == current['mode']
        row = dict(name=name, run=actual, mismatched_cases=rows, source_sha256=item['sha256'],
                   all_supplied_bytes_modes_unchanged=True)
        runs.append(row)
        return set(rows)

    assert not run('healthy-before', inputs[module])
    for name, item in variant_inputs.items():
        assert run(name, item) == set(item['expected_mismatches'])
    assert not run('healthy-restored', inputs[module])
c.write_new(c.PREFIX + 'inverse-run.json.gz', dict(runs=runs, main_inputs_unchanged=c.unchanged(inputs)), packed=True)
assert c.unchanged(inputs)
print('Six effective producer inverses reject distinct case sets; exact healthy source restores all cases')
