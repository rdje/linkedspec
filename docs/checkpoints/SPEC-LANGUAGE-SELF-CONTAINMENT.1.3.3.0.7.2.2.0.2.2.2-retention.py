"""Verify the exact initial publication capsule without refreshing historical inputs."""
from pathlib import Path
import copy
import hashlib
import importlib.util
import io
import json
import tarfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = str(Path(__file__).resolve()).removesuffix('retention.py')
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def load(suffix):
    return json.loads(Path(PREFIX + suffix).read_bytes())


def check(manifest, report, verification):
    capsule = Path(PREFIX + 'initial-book-inputs.tar.gz').read_bytes()
    assert sha(capsule) == manifest['capsule_sha256'], 'exact retained initial capsule'
    files = {}
    with tarfile.open(fileobj=io.BytesIO(capsule), mode='r:gz') as archive:
        for member in archive:
            assert member.isfile() and member.name not in files, 'regular unique historical member'
            path = Path(member.name)
            assert not path.is_absolute() and '..' not in path.parts, 'relative historical member'
            files[member.name] = (archive.extractfile(member).read(), member.mode)
    current = load('book-inputs.json')
    assert sorted(files) == [e['path'] for e in manifest['entries']] == [
        e['path'] for e in current['entries']], 'complete historical publication population'
    changed = []
    for entry in manifest['entries']:
        raw, mode = files[entry['path']]
        assert (len(raw), sha(raw), mode) == (entry['bytes'], entry['sha256'], entry['mode']), 'exact historical publication member'
        if raw != (ROOT / entry['path']).read_bytes():
            changed.append(entry['path'])
    assert changed == ['docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'], 'sole later teaching change'
    source = Path(PREFIX + 'initial-book.py')
    spec = importlib.util.spec_from_file_location('retained_initial_publication', source)
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    module.check(report, manifest)
    assert verification['instrument_sha256'] == sha(source.read_bytes()), 'exact historical publication instrument'
    assert verification['book_inputs'] == 58 and verification['exact_examples'] == 4, 'initial publication scope'
    assert len(verification['controls']) == 7 and all(c['observed_red'] for c in verification['controls']), 'initial observed publication denials'
    return {'publication_inputs': len(files), 'exact_examples': 4,
            'initial_publication_controls': 7, 'later_teaching_changes': changed,
            'initial_capsule_sha256': sha(capsule)}


def main():
    manifest, report, verification = (load(suffix) for suffix in (
        'initial-book-inputs.json', 'initial-book.json', 'initial-book-verification.json'))
    summary = check(manifest, report, verification); controls = []
    for name, target, mutate in (
        ('forged initial capsule', 0, lambda d: d.update(capsule_sha256='0' * 64)),
        ('missing initial member', 0, lambda d: d['entries'].pop()),
        ('refreshed initial member hash', 0, lambda d: d['entries'][0].update(sha256='0' * 64)),
        ('forged original instrument', 1, lambda d: d.update(instrument_sha256='0' * 64)),
        ('lost initial observed denial', 2, lambda d: d['controls'].pop()),
    ):
        candidates = copy.deepcopy([manifest, report, verification]); mutate(candidates[target])
        assert candidates != [manifest, report, verification], 'effective retention control'
        try:
            check(*candidates)
        except AssertionError as error:
            controls.append({'name': name, 'observed_red': str(error)})
        else:
            raise AssertionError('unrejected retention control: ' + name)
    summary.update(complete=True, controls=controls, instrument_sha256=sha(Path(__file__).read_bytes()))
    Path(PREFIX + 'retention.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
