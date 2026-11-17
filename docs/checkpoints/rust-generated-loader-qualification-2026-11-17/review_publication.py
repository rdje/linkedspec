"""Recover bounded publication inputs and selected prior operational evidence."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def verify(sources, identities):
    assert set(sources) == set(identities), 'publication population'
    for name, body in sources.items():
        row = identities[name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'publication body'
        assert row['mode'] == stat.S_IMODE(row['archive_mode']), 'publication mode'


def main():
    sources = {}
    identities = json.loads((BASE / 'publication-before-identities.json').read_bytes())
    with tarfile.open(BASE / 'publication-before.tar.gz') as archive:
        assert len(archive.getmembers()) == len(identities)
        for member in archive:
            name = Path(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts and member.name not in sources
            sources[member.name] = archive.extractfile(member).read()
            identities[member.name]['archive_mode'] = member.mode
    verify(sources, identities)
    controls = {}
    selected = str(BASE / 'qualified-stdout.gz')
    for label in ('publication-body', 'publication-mode', 'publication-population'):
        changed, modes = dict(sources), copy.deepcopy(identities)
        if label == 'publication-body':
            changed[selected] += b'\n'
        elif label == 'publication-mode':
            modes[selected]['mode'] ^= 0o100
        else:
            changed.pop(selected)
        try:
            verify(changed, modes)
        except AssertionError as error:
            assert str(error) == label.replace('-', ' ')
            controls[label] = 'RED'
        else:
            raise AssertionError('publication inverse accepted')
    bindings = json.loads((BASE / 'publication-bindings.json').read_bytes())
    assert all(row['mode'] == 'historical' for row in bindings), 'old live bindings'
    for label in ('preceding-normal', 'qualifier-outer'):
        body = gzip.decompress((BASE / (label + '.log.gz')).read_bytes())
        row = json.loads((BASE / (label + '.json')).read_bytes())
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
    for row in json.loads((BASE / 'telemetry-copies.json').read_bytes()):
        path = Path(row['target'])
        body = path.read_bytes()
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert stat.S_IMODE(path.stat().st_mode) == row['mode']
    print(json.dumps(dict(result='PASS', publication_inputs=len(sources), historical_bindings=len(bindings),
        controls=controls, limits='Bounded original publication image, binding metadata and after-use operational copies only; complete claim/toolchain/OS/native/outer-first-use custody remains4.2/SESSION5.'), sort_keys=True))


if __name__ == '__main__':
    main()
