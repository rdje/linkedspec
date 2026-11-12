"""Independently validate the actual pack and distinguish corrupt size/ref receipts."""
import copy
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
launch = BASE / 'launches/measure'
assert (launch / 'exit.txt').read_text() == '0\n'
assert gzip.decompress((launch / 'stderr.log.gz').read_bytes()) == b''
report = json.loads(gzip.decompress((launch / 'stdout.log.gz').read_bytes()))
directory = Path(report['evidence'])
assert not directory.is_absolute() and '..' not in directory.parts and directory.parent == Path('.linkedspec-data/push-monitor')
assert directory.is_dir() and not directory.is_symlink() and directory.stat().st_dev == ROOT.stat().st_dev
saved = BASE / 'measurement'
saved.mkdir()
for path in directory.iterdir():
    if path.is_file() and path.suffix not in ('.pack', '.idx', '.rev', '.log'):
        assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        shutil.copy2(path, saved / path.name)
        assert (saved / path.name).read_bytes() == path.read_bytes()
        assert (saved / path.name).stat().st_mode & 0o777 == path.stat().st_mode & 0o777
out = BASE / 'validation'
out.mkdir()
paths = [p for p in saved.iterdir() if p.is_file()]
paths += [BASE / 'policy.json', Path(__file__).resolve().relative_to(ROOT)]
paths += [Path('tools') / name for name in ('project_data_run.sh', 'project_data_env.sh', 'run_python_project_data.sh')]
rows = {}
with tarfile.open(out / 'inputs-before-use.tar.gz', 'x:gz') as packed:
    for path in sorted(paths):
        body = path.read_bytes()
        rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        packed.add(path, arcname=str(path), recursive=False)
with tarfile.open(out / 'inputs-before-use.tar.gz') as packed:
    assert set(packed.getnames()) == rows.keys()
    for member in packed:
        body = packed.extractfile(member).read(); row = rows[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
(out / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
environment = dict(GIT_OPTIONAL_LOCKS='0', GIT_NO_LAZY_FETCH='1', LC_ALL='C')


def run(tag, command):
    (out / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.', environment=environment), indent=2, sort_keys=True) + '\n')
    actual = subprocess.run(command, cwd=ROOT, env=dict(os.environ, **environment), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (out / (tag + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(actual, channel), mtime=0))
    (out / (tag + '-exit.txt')).write_text(str(actual.returncode) + '\n')
    assert actual.returncode == 0, 'actual independent command failure:' + tag
    return actual.stdout


pack = directory / 'outgoing-estimate.pack'
assert pack.is_file() and not pack.is_symlink() and pack.stat().st_dev == ROOT.stat().st_dev
stat = pack.stat()
algorithm = report['object_format']
assert algorithm in ('sha1', 'sha256')
digest_size = hashlib.new(algorithm).digest_size
sha, checksum, consumed = hashlib.sha256(), hashlib.new(algorithm), 0
with pack.open('rb') as source:
    header = source.read(12)
    source.seek(0); remaining = stat.st_size - digest_size
    while remaining:
        body = source.read(min(4 * 1024 * 1024, remaining)); assert body
        sha.update(body); checksum.update(body); consumed += len(body); remaining -= len(body)
    footer = source.read(digest_size); sha.update(footer); consumed += len(footer)
    assert len(footer) == digest_size and not source.read(1)
assert (pack.stat().st_size, pack.stat().st_mtime_ns, pack.stat().st_ino) == (stat.st_size, stat.st_mtime_ns, stat.st_ino), 'pack changed during independent read'
assert footer == checksum.digest(), 'independent Git checksum'
magic, version, object_count = struct.unpack('>4sII', header)
index = directory / 'independent.idx'
assert not index.exists()
run('index', ['git', 'index-pack', '--threads=1', '-o', str(index), str(pack)])
verified = run('verify', ['git', 'verify-pack', '-v', str(index)])
indexed = {}
for line in verified.decode().splitlines():
    fields = line.split()
    if fields and re.fullmatch(r'[0-9a-f]{40,64}', fields[0]):
        assert fields[0] not in indexed
        indexed[fields[0]] = fields
logical_rows = gzip.decompress((saved / 'objects-stdout.gz').read_bytes()).decode().splitlines()
logical = set(logical_rows)
extra = indexed.keys() - logical
if extra:
    base_objects = set(run('base-objects', ['git', 'rev-list', '--objects', '--no-object-names', report['cached_origin_main']]).decode().splitlines())
    assert extra <= base_objects, 'unexplained extra object requires investigation'
head = run('head', ['git', 'rev-parse', 'HEAD']).decode().strip()
base = run('base', ['git', 'rev-parse', 'refs/remotes/origin/main']).decode().strip()
policy = json.loads((BASE / 'policy.json').read_bytes())
empty = gzip.decompress((saved / 'empty-range-stdout.gz').read_bytes())
assert struct.unpack('>4sII', empty[:12]) == (b'PACK', version, 0)
assert len(empty) == 12 + digest_size and hashlib.new(algorithm, empty[:-digest_size]).digest() == empty[-digest_size:]
facts = dict(stat_bytes=stat.st_size, consumed_bytes=consumed, sha256=sha.hexdigest(), footer=footer.hex(),
    magic=magic.decode(), version=version, header_objects=object_count, indexed_objects=sorted(indexed),
    logical_objects=sorted(logical), logical_rows=len(logical_rows), extra_objects=sorted(extra),
    actual_head=head, actual_cached_origin=base, producer_exit=int((saved / 'pack-exit.txt').read_text()),
    empty_pack_bytes=len(empty), policy=policy)


def validate(receipt, observed):
    assert observed['producer_exit'] == 0, 'producer exit'
    assert observed['magic'] == 'PACK' and observed['version'] in (2, 3), 'PACK header'
    assert receipt['head'] == observed['actual_head'], 'HEAD snapshot'
    assert receipt['cached_origin_main'] == observed['actual_cached_origin'], 'cached origin snapshot'
    assert receipt['estimated_non_thin_pack_bytes'] == observed['stat_bytes'] == observed['consumed_bytes'], 'serialized byte count'
    assert receipt['pack_sha256'] == observed['sha256'], 'serialized SHA256'
    assert receipt['pack_footer'] == observed['footer'], 'Git footer'
    assert receipt['packed_objects'] == observed['header_objects'] == len(observed['indexed_objects']), 'indexed object count'
    assert set(observed['logical_objects']) <= set(observed['indexed_objects']), 'required object coverage'
    assert receipt['object_rows'] == observed['logical_rows'] and receipt['unique_object_ids'] == len(observed['logical_objects']), 'logical object census'
    assert receipt['early_push_trigger_bytes'] == observed['policy']['early_push_trigger_bytes'] == 1_500_000_000, 'director budget'
    assert receipt['preparation_threshold_bytes'] == observed['policy']['preparation_threshold_bytes'] == 1_400_000_000, 'preparation budget'
    assert receipt['remaining_to_trigger_bytes'] == 1_500_000_000 - observed['stat_bytes'], 'byte margin'
    assert receipt['trigger_reached'] == (observed['stat_bytes'] >= 1_500_000_000), 'push decision'
    assert receipt['preparation_due'] == (observed['stat_bytes'] >= 1_400_000_000), 'preparation decision'


validate(report, facts)
controls = []
for label, mutation, reason in (
    ('wrong serialized size', lambda r, f: r.__setitem__('estimated_non_thin_pack_bytes', r['estimated_non_thin_pack_bytes'] + 1), 'serialized byte count'),
    ('wrong HEAD', lambda r, f: r.__setitem__('head', '0' * len(r['head'])), 'HEAD snapshot'),
    ('wrong origin', lambda r, f: r.__setitem__('cached_origin_main', '0' * len(r['cached_origin_main'])), 'cached origin snapshot'),
    ('failed producer', lambda r, f: f.__setitem__('producer_exit', 1), 'producer exit'),
    ('bad header', lambda r, f: f.__setitem__('magic', 'BAD!'), 'PACK header'),
    ('wrong file checksum', lambda r, f: r.__setitem__('pack_sha256', '0' * 64), 'serialized SHA256'),
    ('wrong Git footer', lambda r, f: r.__setitem__('pack_footer', '0' * len(r['pack_footer'])), 'Git footer'),
    ('wrong packed count', lambda r, f: r.__setitem__('packed_objects', r['packed_objects'] + 1), 'indexed object count'),
    ('missing required object', lambda r, f: f.__setitem__('indexed_objects', ['0' * len(f['indexed_objects'][0])] + f['indexed_objects'][1:]), 'required object coverage'),
    ('wrong director budget', lambda r, f: r.__setitem__('early_push_trigger_bytes', 2_000_000_000), 'director budget'),
    ('wrong margin', lambda r, f: r.__setitem__('remaining_to_trigger_bytes', 0), 'byte margin'),
    ('wrong preparation decision', lambda r, f: r.__setitem__('preparation_due', not r['preparation_due']), 'preparation decision'),
):
    corrupted, altered = copy.deepcopy(report), copy.deepcopy(facts)
    mutation(corrupted, altered)
    try:
        validate(corrupted, altered)
    except AssertionError as error:
        assert reason == str(error), 'wrong rejection reason:' + label
        controls.append(dict(control=label, observed_red=str(error)))
    else:
        raise AssertionError('ineffective control:' + label)
(out / 'facts.json').write_text(json.dumps(facts, indent=2, sort_keys=True) + '\n')
result = dict(independent_validation='PASS', head=head, cached_origin_main=base, pack_bytes=stat.st_size,
    packed_objects=len(indexed), logical_objects=len(logical), extra_objects=sorted(extra),
    empty_pack_bytes=len(empty), corruption_controls=controls,
    scope='Actual file stream/stat/checksum plus independent Git index/verify and exact required-object coverage. Controls mutate receipt/fact fields, not a duplicate1.2GB file. Actual native inputs/raw pack/indexes remain ignored; full physical Git/cache/toolchain/OS durability stays4.2/SESSION5. No remote freshness/wire/future-size claim.')
(out / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(result, sort_keys=True))
