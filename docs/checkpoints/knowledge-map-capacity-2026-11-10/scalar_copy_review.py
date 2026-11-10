"""Readonly legacy snapshot source/identity/effect proof, including the actual test helper."""
import argparse
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
TEST = 't/actionir_receiver_scalar_copy.t'
METHOD = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
NORMAL = HERE / 'scalar-copy-normal-oracle.json.gz'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert packet(raw) == row, 'packet identity'
    return raw


def same(a, b):
    return json.dumps(a, sort_keys=True, separators=(',', ':')) == json.dumps(b, sort_keys=True, separators=(',', ':'))


def focused(metadata, stdout, stderr, source):
    assert metadata['argv'] == ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'prove', '-Iperl', TEST]
    assert metadata['cwd'] == '.' and type(metadata['observed_exit']) is int and metadata['observed_exit'] == 0
    assert metadata['digest_domain'] == 'physical-gzip'
    assert re.search('^' + re.escape(TEST) + r' \.+ ok$', stdout, re.M)
    assert re.search(r'^Files=1, Tests=487,', stdout, re.M) and stdout.endswith('Result: PASS\n')
    assert 'Failed test' not in stderr
    lines = [line.removeprefix('# RECEIVER_COPY_OBSERVATIONS ') for line in stderr.splitlines() if line.startswith('# RECEIVER_COPY_OBSERVATIONS ')]
    assert len(lines) == 1, 'missing native observation frame'
    observation = json.loads(lines[0])
    value_hash = dict(k='v', nested=[1, 2])
    expected = [value_hash, value_hash, value_hash, [1, 2], [1, 2], [1, 2], {}, {}, [], [], 2, 2, 'abc', 0]
    assert same(observation['live'], expected) and same(observation['standalone'], expected)
    assert observation['live_error'] is None and observation['legacy_source'] == source
    for route in ('live_identity', 'standalone_identity'):
        assert set(observation[route]) == {'hash_distinct', 'hash_nested_shared', 'function_hash_distinct', 'function_hash_nested_shared', 'array_distinct', 'function_array_distinct'}
        assert all(type(value) is int and value == 1 for value in observation[route].values()), 'copy identity changed'


def review(capture=False):
    record = json.loads(gzip.decompress((HERE / 'scalar-copy-qualified.json.gz').read_bytes()))
    bundle_bytes = (ROOT / record['source_bundle']['path']).read_bytes()
    assert hashlib.sha256(bundle_bytes).hexdigest() == record['source_bundle']['sha256']
    bundle = json.loads(gzip.decompress(bundle_bytes))
    sources = {name: row for name, row in bundle['sources'].items()
               if name.startswith(('perl/', 'specs/', 'conf/', 'tablescript/', 'ebnf/'))}
    assert record['source_members'] == {name: row['sha256'] for name, row in sources.items()}
    old, new = (decode(record['methods'][name]) for name in ('activation', 'repaired'))
    assert old == subprocess.check_output(['git', 'show', '7289836f28e4873463ad1c50d354d8e66c77af8d:' + METHOD], cwd=ROOT)
    assert old == decode(sources[METHOD]) and new == (ROOT / METHOD).read_bytes()
    for name, row in sources.items():
        assert (ROOT / name).read_bytes() == (new if name == METHOD else decode(row)), 'SDK source drift: ' + name
    original = gzip.decompress((HERE / 'scalar-copy-original.t.gz').read_bytes())
    assert original == subprocess.check_output(['git', 'show', '7289836f28e4873463ad1c50d354d8e66c77af8d:' + TEST], cwd=ROOT)
    for name, row in record['inputs'].items():
        assert decode(row) == (original if name == TEST else (ROOT / name).read_bytes())
    frames = {}
    for stage, row in record['commands'].items():
        assert row['exit'] == 0 and decode(row['stderr']) == b''
        assert decode(row['stdout']).splitlines(keepends=True)[-1] == decode(row['frame'])
        value = json.loads(decode(row['frame']))
        assert value['module_sha256'] == record['methods'][stage]['sha256']
        frames[stage] = value
    a, b = frames['activation'], frames['repaired']
    assert a['source'] == b['source'] and same(a['ast'], b['ast'])
    assert same(a['actual'], b['actual']) and same(a['actual'], a['original_oracle'])
    assert same(a['controls'], b['controls'])
    ast = a['ast']
    assert ast['kind'] == 'fluent_chain' and ast['receiver']['kind'] == 'variable' and ast['receiver']['name'] == 'Top'
    assert len(ast['calls']) == 1 and ast['calls'][0]['method'] == 'copy' and ast['calls'][0]['args'] == []
    assert '[@Top]' in a['source'] and '__ls_copy_value' in a['source']
    oracle = a['original_oracle']
    assert same(oracle['before'], [0, '', None, dict(nested=[1]), [2], False])
    assert all(oracle[name] == 1 for name in ('outer_distinct', 'hash_shared', 'array_shared'))
    assert oracle['first_after_source_change'] == 0 and oracle['nested_after_shared_change'] == 7
    assert oracle['source_trace'] == [['size']] + [['fetch', index] for index in range(6)]
    assert set(a['controls']) == {'empty', 'alias', 'lost_nested', 'repeated'}
    for label, value in a['controls'].items():
        assert not same(value, oracle), 'independent executable control admitted: ' + label
    current = (ROOT / TEST).read_text()
    marker = "do './t/actionir_receiver_scalar_copy_probe.pl'"
    assert original.decode().count(marker) == current.count(marker) == 1
    original_prefix, original_tail = original.decode().split(marker, 1)
    prefix, tail = current.split(marker, 1)
    assert prefix.startswith(original_prefix)
    old_assertion = "is($observed->{legacy_source}, 'return [@Top]', 'legacy rule aggregate array snapshot remains exact');"
    new_assertion = "is_deeply(rule_snapshot_observation($observed->{legacy_source}),\n rule_snapshot_observation('return [@Top]'),\n 'legacy rule aggregate copy preserves snapshot values, shallow identity and source reads');"
    assert tail.count(new_assertion) == 1
    assert tail.replace(new_assertion, old_assertion, 1) == original_tail, 'another original control changed'
    assert prefix.count('use Test::More;\n') == 1
    program = prefix.replace('use Test::More;\n', '', 1) + '''
my $input = JSON::PP->new->decode(do {local $/; <STDIN>});
my %output = map {$_ => rule_snapshot_observation($input->{$_})} keys %$input;
print JSON::PP->new->canonical->encode(\\%output), "\\n";
'''
    commands = dict(actual=a['source'], oracle='return [@Top]', empty='return []', alias='return \\@Top',
                    repeated='my @unused = @Top; return [@Top]', lost_nested='return [map {ref($_) eq "HASH" ? {} : $_} @Top]')
    supplied = json.dumps(commands, sort_keys=True).encode()
    argv = ['perl', '-Iperl', '-e', program]
    # Retain the actual consumer prefix and supplied sources before interpreter use.
    observed = dict(argv=argv, cwd='.', input=packet(supplied), consumer=packet(current.encode()))
    if capture:
        assert not NORMAL.exists(), 'one-shot actual consumer-helper observation'
        NORMAL.write_bytes(gzip.compress(json.dumps(observed, sort_keys=True).encode(), mtime=0))
    result = subprocess.run(argv, cwd=ROOT, input=supplied, capture_output=True)
    observed.update(exit=result.returncode, stdout=packet(result.stdout), stderr=packet(result.stderr))
    if capture: NORMAL.write_bytes(gzip.compress(json.dumps(observed, sort_keys=True).encode(), mtime=0))
    assert json.loads(gzip.decompress(NORMAL.read_bytes())) == observed
    assert result.returncode == 0 and result.stderr == b''
    normal = json.loads(result.stdout)
    assert same(normal['actual'], oracle) and same(normal['oracle'], oracle)
    for name in a['controls']:
        assert same(normal[name], a['controls'][name]) and not same(normal[name], normal['oracle']), 'actual normal helper lost denial: ' + name
    metadata = json.loads((HERE / 'scalar-copy-focused-result.json').read_bytes())
    channels = {}
    for channel in ('stdout', 'stderr'):
        row = metadata['channels'][channel]
        path = HERE / ('scalar-copy-focused-' + channel + '.log.gz')
        assert row['path'] == path.relative_to(ROOT).as_posix()
        raw = path.read_bytes()
        assert hashlib.sha256(raw).hexdigest() == row['sha256']
        channels[channel] = gzip.decompress(raw).decode()
    focused(metadata, channels['stdout'], channels['stderr'], a['source'])
    channel_controls = []
    for label in ('wrong-exit', 'missing-pass', 'missing-native-frame', 'changed-native-identity'):
        changed = copy.deepcopy(metadata); out = channels['stdout']; err = channels['stderr']
        if label == 'wrong-exit': changed['observed_exit'] = 1
        elif label == 'missing-pass': out = out.replace('Result: PASS', 'Result: UNKNOWN')
        elif label == 'missing-native-frame': err = ''
        else:
            frame = json.loads(err.removeprefix('# RECEIVER_COPY_OBSERVATIONS ').strip())
            frame['live_identity']['hash_distinct'] = 0
            err = '# RECEIVER_COPY_OBSERVATIONS ' + json.dumps(frame) + '\n'
        try: focused(changed, out, err, a['source'])
        except AssertionError: channel_controls.append(label)
        else: raise AssertionError('focused channel corruption admitted: ' + label)
    return dict(result='PASS', activation_and_repaired_source='identical', original_other_assertion_source='unchanged',
                actual_test_helper_matches_independent_oracle=True, rejected_executable_controls=sorted(a['controls']),
                focused_assertions=487, rejected_channel_controls=channel_controls,
                snapshot_fields=oracle,
                limits='Qualified retained project-source/diagnostic artifact comparison plus the actual extracted test helper. Original canonical first-use and complete native/cache/OS/transitive custody remain4.2/SESSION5. No runtime production change, broad copy or feature admission.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--capture', action='store_true')
    print(json.dumps(review(parser.parse_args().capture), sort_keys=True))
