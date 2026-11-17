"""Recover immutable source references; never replay any earlier producer."""
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import stat
import tarfile


def sha(body):
    return hashlib.sha256(body).hexdigest()


def archive(body, identities):
    result = {}
    with tarfile.open(fileobj=io.BytesIO(body), mode='r:gz') as packed:
        assert len(packed.getmembers()) == len(identities)
        for member in packed:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in result
            value = packed.extractfile(member).read()
            row = identities[member.name]
            assert len(value) == row['bytes'] and sha(value) == row['sha256'], 'archive body'
            assert stat.S_IMODE(member.mode) == row['mode'], 'archive mode'
            result[member.name] = (value, row['mode'])
    assert set(result) == set(identities), 'archive population'
    return result


def reused(references, plan):
    retained = {}
    for name, row in references.items():
        path = Path(name)
        assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        value = path.read_bytes()
        assert len(value) == row['bytes'] and sha(value) == row['sha256'], 'reused body'
        assert stat.S_IMODE(path.stat().st_mode) == row['mode'], 'reused mode'
        retained[name] = (value, row['mode'])
    prior, named = Path(plan['prior']), Path(plan['named'])
    request = json.loads(gzip.decompress(retained[str(prior / 'commands/consumers-stdin.gz')][0]))
    old_ids = json.loads(retained['docs/checkpoints/perl-consumer-roles-2026-11-16/identities.json'][0])
    sources = {}
    for row in request['documents']:
        name, body = row['path'], row['source'].encode()
        assert name not in sources and sha(body) == row['sha256'] == old_ids[name]['sha256']
        sources[name] = (body, old_ids[name]['mode'])
    assert sorted(sources) == plan['original_consumers'] and len(sources) == 145
    named_bodies = archive(retained[str(named / 'inputs.tar.gz')][0], json.loads(retained[str(named / 'identities.json')][0]))
    for name in plan['named_context']:
        value = named_bodies[name]
        assert name not in sources or sources[name] == value
        sources[name] = value
    assert sorted(sources) == plan['sources'] and len(sources) == 159
    return sources, retained
