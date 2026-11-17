"""Recover bounded original publication images and after-use log/telemetry copies."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def validate(sources, identities):
    assert set(sources) == set(identities), 'publication population'
    for name, body in sources.items():
        row = identities[name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'publication body'
        assert row['mode'] == row['archive_mode'], 'publication mode'


def main():
    identities = json.loads((BASE / 'publication-before-identities.json').read_bytes())
    sources = {}
    with tarfile.open(BASE / 'publication-before.tar.gz') as archive:
        assert len(archive.getmembers()) == len(identities)
        for member in archive:
            path = Path(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in sources
            sources[member.name] = archive.extractfile(member).read()
            identities[member.name]['archive_mode'] = stat.S_IMODE(member.mode)
    validate(sources, identities)
    controls = {}
    name = str(BASE / 'commands/qualified-stdout.gz')
    for label in ('publication population', 'publication body', 'publication mode'):
        changed, modes = dict(sources), copy.deepcopy(identities)
        if label == 'publication population':
            changed.pop(name)
        elif label == 'publication body':
            changed[name] += b'\n'
        else:
            modes[name]['mode'] ^= 0o100
        try:
            validate(changed, modes)
        except AssertionError as error:
            assert str(error) == label
            controls[label] = 'RED'
        else:
            raise AssertionError('publication corruption accepted')
    bindings = json.loads((BASE / 'publication-bindings.json').read_bytes())
    assert all(row['mode'] == 'historical' for row in bindings)
    for row in json.loads((BASE / 'log-copies.json').read_bytes()):
        body = gzip.decompress(Path(row['target']).read_bytes())
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
    for row in json.loads((BASE / 'telemetry-copies.json').read_bytes()):
        path = Path(row['target'])
        body = path.read_bytes()
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert stat.S_IMODE(path.stat().st_mode) == row['mode']
    print(json.dumps(dict(result='PASS', publication_inputs=len(sources), historical_bindings=len(bindings), controls=controls,
        limits='Bounded original publication image and after-use copies only. Missing reader first-use/first setup raw channels/separate outer producer exit remain explicit; full closure4.2/SESSION5.'), sort_keys=True))


if __name__ == '__main__':
    main()
