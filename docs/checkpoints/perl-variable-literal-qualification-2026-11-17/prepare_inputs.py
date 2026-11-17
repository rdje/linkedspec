"""Gate reused immutable source images and retain the new population plan."""
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import stat
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PRIOR = Path('docs/checkpoints/perl-loader-token-census-2026-11-17')
NAMED = Path('docs/checkpoints/perl-named-includes-2026-11-17')
ACTIVATION = '9a6c66131dfe13140f8d637ca294a2a3c49be97a'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.1.1.1.1'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
with tarfile.open(BASE / 'preparer-before.tar.gz', 'x:gz') as archive:
    archive.add(BASE / 'prepare_inputs.py', arcname=str(BASE / 'prepare_inputs.py'), recursive=False)
paths = [PRIOR / 'commands/consumers-stdin.gz', PRIOR / 'commands/consumers-stdout.gz',
    Path('docs/checkpoints/perl-consumer-roles-2026-11-16/identities.json'),
    Path('docs/checkpoints/perl-consumer-roles-2026-11-16/roles.json'),
    NAMED / 'plan.json', NAMED / 'inputs.tar.gz', NAMED / 'identities.json', NAMED / 'roles.json']
references = {}
for path in paths:
    assert not path.is_symlink() and path.stat().st_dev == Path.cwd().stat().st_dev
    body = path.read_bytes()
    references[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
with (BASE / 'reused-inputs.json').open('x') as stream:
    json.dump(references, stream, indent=2, sort_keys=True)
    stream.write(chr(10))
request = json.loads(gzip.decompress((PRIOR / 'commands/consumers-stdin.gz').read_bytes()))
old_ids = json.loads(paths[2].read_bytes())
sources = {}
for row in request['documents']:
    body = row['source'].encode()
    assert hashlib.sha256(body).hexdigest() == row['sha256'] == old_ids[row['path']]['sha256']
    sources[row['path']] = (body, old_ids[row['path']]['mode'])
assert len(sources) == 145
named_plan = json.loads((NAMED / 'plan.json').read_bytes())
names = {row['target'] for row in named_plan['entries']} | set(named_plan['context_targets'])
named_ids = json.loads((NAMED / 'identities.json').read_bytes())
found = set()
with tarfile.open(NAMED / 'inputs.tar.gz') as archive:
    for member in archive:
        path = PurePosixPath(member.name)
        assert member.isfile() and not path.is_absolute() and '..' not in path.parts
        if member.name not in names:
            continue
        body = archive.extractfile(member).read()
        row = named_ids[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert stat.S_IMODE(member.mode) == row['mode'] and member.name not in found
        value = (body, row['mode'])
        if member.name in sources:
            assert sources[member.name] == value
        sources[member.name] = value
        found.add(member.name)
assert found == names and len(names) == 15 and len(sources) == 159
for name, (body, mode) in sources.items():
    path = Path(name)
    assert not path.is_symlink() and path.read_bytes() == body and stat.S_IMODE(path.stat().st_mode) == mode
plan = dict(owner=OWNER, activation=ACTIVATION, ppi_version='1.270', prior=str(PRIOR), named=str(NAMED),
    sources=sorted(sources), original_consumers=sorted(row['path'] for row in request['documents']),
    named_context=sorted(names), support_added=sorted(set(sources) - {row['path'] for row in request['documents']}),
    limits='Only bounded adjacent single-my/simple quoted ASCII initializer and same-PPI-parent three-argument open bindings. All159 original/named sources and all unmatched sites remain; no evaluation, actual IO reachability, callee/alias/full semantic/native or canonical admission.')
with (BASE / 'plan.json').open('x') as stream:
    json.dump(plan, stream, indent=2, sort_keys=True)
    stream.write(chr(10))
print(json.dumps(dict(result='PASS', original=145, named_context=15, added=14, unique_sources=159,
    reused_artifacts=len(references), limits=plan['limits']), sort_keys=True))
