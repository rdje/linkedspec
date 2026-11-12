"""Recover historical monitor metadata and qualification; never replay pack producers."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT).as_posix()
ACTIVATION = '102ec3446407543c5ef64f3222bd0fffb5eb3064'


def recover(path, identities):
    result = {}
    with tarfile.open(path) as packed:
        assert len(packed.getnames()) == len(identities), 'archive population'
        for member in packed:
            name = Path(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts and member.name not in result
            body = packed.extractfile(member).read(); row = identities[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'archive bytes'
            assert member.mode & 0o777 == row['mode'], 'archived full mode'
            result[member.name] = body
    assert result.keys() == identities.keys()
    return result


def raw(path):
    return gzip.decompress(path.read_bytes())


def check(report, facts, validation, original_verify_exit):
    assert report['estimated_non_thin_pack_bytes'] == facts['stat_bytes'] == facts['consumed_bytes'] == validation['pack_bytes'], 'serialized byte count'
    assert report['head'] == facts['actual_head'] == validation['head'] == ACTIVATION, 'head identity'
    assert report['cached_origin_main'] == facts['actual_cached_origin'] == validation['cached_origin_main'], 'origin identity'
    assert report['pack_sha256'] == facts['sha256'] and report['pack_footer'] == facts['footer'], 'checksums'
    assert report['packed_objects'] == facts['header_objects'] == len(facts['indexed_objects']) == validation['packed_objects'], 'packed scope'
    assert report['object_rows'] == facts['logical_rows'] and report['unique_object_ids'] == len(facts['logical_objects']) == validation['logical_objects'], 'logical scope'
    assert set(facts['logical_objects']) <= set(facts['indexed_objects']), 'required object coverage'
    assert validation['extra_objects'] == facts['extra_objects'] == sorted(set(facts['indexed_objects']) - set(facts['logical_objects'])), 'extra object scope'
    assert report['early_push_trigger_bytes'] == facts['policy']['early_push_trigger_bytes'] == 1_500_000_000, 'director budget'
    assert report['preparation_threshold_bytes'] == facts['policy']['preparation_threshold_bytes'] == 1_400_000_000, 'preparation budget'
    assert report['remaining_to_trigger_bytes'] == 1_500_000_000 - facts['stat_bytes'], 'byte margin'
    assert report['trigger_reached'] == (facts['stat_bytes'] >= 1_500_000_000), 'push decision'
    assert report['preparation_due'] == (facts['stat_bytes'] >= 1_400_000_000), 'preparation decision'
    assert original_verify_exit == 1, 'original failure custody'
    assert validation['independent_validation'] == 'PASS' and len(validation['corruption_controls']) == 12, 'actual control population'
    assert all(set(row) == {'control', 'observed_red'} and row['observed_red'] for row in validation['corruption_controls'])


for name, row in json.loads((BASE / 'sealed-identities.json').read_bytes()).items():
    path = Path(name)
    assert not path.is_absolute() and '..' not in path.parts
    body = (ROOT / path).read_bytes()
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'sealed artifact bytes'
launches = {}
for tag, code in (('measure', 0), ('validate', 1), ('validate-qualified', 0), ('publication-query', 0), ('review-publication-query', 0)):
    folder = BASE / 'launches' / tag
    inputs = recover(folder / 'inputs.tar.gz', json.loads((folder / 'identities.json').read_bytes()))
    command = json.loads((folder / 'command.json').read_bytes())
    assert command['cwd'] == '.' and command['environment'] == {}
    sources = [name for name in command['argv'] if name.endswith('.py')]
    assert sources and all(name in inputs for name in sources), 'actual source before invocation'
    assert (folder / 'exit.txt').read_text() == str(code) + '\n'
    stderr = raw(folder / 'stderr.log.gz')
    if code:
        assert b'actual independent command failure:verify' in stderr, 'original failure mechanism'
    else:
        assert stderr == b''
    launches[tag] = inputs
m = BASE / 'measurement'
report = json.loads((m / 'result.json').read_bytes())
assert report == json.loads(raw(BASE / 'launches/measure/stdout.log.gz'))
identities = json.loads((m / 'producer-input-identities.json').read_bytes())
producer = recover(m / 'producer-inputs.tar.gz', identities)
source = REL + '/measure.py'
assert producer[source] == launches['measure'][source], 'captured source before first use'
policy = json.loads(producer[REL + '/policy.json'])
original = BASE / 'validation'
qualified = BASE / 'validation-qualified'
before_inputs = recover(original / 'inputs-before-use.tar.gz', json.loads((original / 'input-identities.json').read_bytes()))
after_inputs = recover(qualified / 'inputs-before-use.tar.gz', json.loads((qualified / 'input-identities.json').read_bytes()))
for name in (REL + '/validate_pack.py', REL + '/validate_pack_qualified.py'):
    launch = 'validate-qualified' if 'qualified' in name else 'validate'
    assert after_inputs[name] == launches[launch][name]
assert before_inputs[REL + '/validate_pack.py'] == launches['validate'][REL + '/validate_pack.py']
for name in m.iterdir():
    key = name.relative_to(ROOT).as_posix()
    assert before_inputs[key] == after_inputs[key] == name.read_bytes(), 'exact measurement input handoff'
assert (original / 'index-exit.txt').read_text() == '0\n' and (original / 'verify-exit.txt').read_text() == '1\n'
assert b'independent.pack: bad' in raw(original / 'verify-stdout.gz')
assert b'Cannot open existing pack file' in raw(original / 'verify-stderr.gz')
assert (qualified / 'verify-exit.txt').read_text() == '0\n' and raw(qualified / 'verify-stderr.gz') == b''
reuse = json.loads((qualified / 'reused-index.json').read_bytes())
assert Path(reuse['source']).name == 'independent.idx' and Path(reuse['target']).name == 'outgoing-estimate.idx'
assert reuse['original_native_index_exit'] == 0 and reuse['bytes'] > 0
assert not (qualified / 'index-command.json').exists(), 'completed native index not rerun'
native_verify = json.loads((qualified / 'verify-command.json').read_bytes())
assert native_verify['argv'] == ['git', 'verify-pack', '-v', reuse['target']]
assert raw(original / 'index-stdout.gz').decode().strip() == report['pack_footer']
facts = json.loads((qualified / 'facts.json').read_bytes())
validation = json.loads((qualified / 'result.json').read_bytes())
assert validation == json.loads(raw(BASE / 'launches/validate-qualified/stdout.log.gz'))
assert facts['policy'] == policy and facts['magic'] == 'PACK' and facts['version'] in (2, 3)
check(report, facts, validation, 1)
indexed = []
for line in raw(qualified / 'verify-stdout.gz').decode().splitlines():
    fields = line.split()
    if fields and re.fullmatch(r'[0-9a-f]{40,64}', fields[0]):
        indexed.append(fields[0])
logical = raw(m / 'objects-stdout.gz').decode().splitlines()
assert len(indexed) == len(set(indexed)) and sorted(indexed) == facts['indexed_objects']
assert len(logical) == facts['logical_rows'] and sorted(set(logical)) == facts['logical_objects']
metadata = [line.split() for line in raw(m / 'object-metadata-stdout.gz').decode().splitlines()]
assert len(metadata) == len(logical) and [row[0] for row in metadata] == logical
largest = max((int(row[2]), row[0]) for row in metadata if row[1] == 'blob')
assert largest == (report['largest_outgoing_blob_bytes'], report['largest_outgoing_blob_oid'])
assert (m / 'revisions.txt').read_text() == report['head'] + '\n^' + report['cached_origin_main'] + '\n'
for tag, value in (('head', report['head']), ('head-after', report['head']), ('base', report['cached_origin_main']), ('base-after', report['cached_origin_main'])):
    assert raw(m / (tag + '-stdout.gz')).decode().strip() == value
assert raw(m / 'pack-config-stdout.gz') == raw(m / 'pack-config-after-stdout.gz')
assert (m / 'pack-exit.txt').read_text() == '0\n'
command = json.loads((m / 'pack-command.json').read_bytes())
for flag in ('--no-sparse', '--threads=' + str(policy['threads']), '--window-memory=' + policy['window_memory']):
    assert command['argv'].count(flag) == 1
assert '--thin' not in command['argv'] and '--all' not in command['argv']
assert command['stdin'] == 'revisions.txt' and command['cwd'] == '.'
empty = raw(m / 'empty-range-stdout.gz'); algorithm = report['object_format']; digest_size = hashlib.new(algorithm).digest_size
assert struct.unpack('>4sII', empty[:12]) == (b'PACK', facts['version'], 0)
assert len(empty) == validation['empty_pack_bytes'] == 12 + digest_size
assert hashlib.new(algorithm, empty[:-digest_size]).digest() == empty[-digest_size:]
assert raw(m / 'empty-range-stdin.gz').decode() == report['head'] + '\n^' + report['head'] + '\n'
ahead = subprocess.check_output(['git', 'rev-list', '--count', report['cached_origin_main'] + '..' + report['head']], cwd=ROOT, text=True)
assert int(ahead) == report['ahead'], 'historical Git range'
controls = []
for label, mutation, reason in (
    ('wrong retained byte count', lambda r, f, v, e: r.__setitem__('estimated_non_thin_pack_bytes', 1), 'serialized byte count'),
    ('wrong budget', lambda r, f, v, e: r.__setitem__('early_push_trigger_bytes', 2_000_000_000), 'director budget'),
):
    r, f, v = copy.deepcopy(report), copy.deepcopy(facts), copy.deepcopy(validation)
    mutation(r, f, v, 1)
    try:
        check(r, f, v, 1)
    except AssertionError as error:
        assert str(error) == reason
        controls.append(label)
    else:
        raise AssertionError('ineffective recovery control:' + label)
try:
    check(report, facts, validation, 0)
except AssertionError as error:
    assert str(error) == 'original failure custody'; controls.append('erased original failure')
else:
    raise AssertionError('ineffective original failure control')
print(json.dumps(dict(historical_metadata_recovery='PASS', head=report['head'], cached_origin_main=report['cached_origin_main'],
    pack_bytes=report['estimated_non_thin_pack_bytes'], logical_objects=len(logical), packed_objects=len(indexed),
    original_validator_exit=1, qualified_validator_exit=0, actual_falsification_controls=len(validation['corruption_controls']),
    recovery_controls=controls, trigger_reached=report['trigger_reached'], preparation_due=report['preparation_due'],
    scope='Retained source/input/channel/full-mode metadata recovery, not a replay of the raw pack producer or live-file validator. Native/physical Git/cache/toolchain/OS/raw artifact durability stays4.2/SESSION5. Cached remote only; no current refs, wire size or future freshness claim.'), indent=2, sort_keys=True))
