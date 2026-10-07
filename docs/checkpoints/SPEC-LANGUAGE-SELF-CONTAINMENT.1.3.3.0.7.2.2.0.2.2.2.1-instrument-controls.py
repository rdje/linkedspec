"""Recur the exact initial metadata-oracle rejection and preserve original bytes."""
from pathlib import Path
import gzip
import hashlib
import importlib.util
import json

ROOT = Path(__file__).resolve().parents[2]
PREFIX = str(Path(__file__).resolve()).removesuffix('instrument-controls.py')
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def main():
    archive = Path(PREFIX + 'initial-preflight.json.gz')
    original_report = Path(PREFIX + 'initial-preflight.json')
    if original_report.exists():
        raw = original_report.read_bytes()
        assert not archive.exists(), 'retain original rejection once'
        archive.write_bytes(gzip.compress(raw, mtime=0))
        assert gzip.decompress(archive.read_bytes()) == raw, 'exact original rejection retention'
        original_report.unlink()
    rejection_raw = gzip.decompress(archive.read_bytes()); rejection = json.loads(rejection_raw)
    assert not rejection['complete_subpopulation'] and 'only false assignment/canonical event counters corrected' in rejection['observed_rejection']
    source = Path(PREFIX + 'initial-review.py').read_bytes()
    namespace = {'__file__': PREFIX + 'review.py', '__name__': 'retained_initial_grouped_review'}
    exec(compile(source, namespace['__file__'], 'exec'), namespace)
    spec = importlib.util.spec_from_file_location('corrected_grouped_public_review', PREFIX + 'review.py')
    corrected = importlib.util.module_from_spec(spec); spec.loader.exec_module(corrected)
    actual = corrected.read(PREFIX + 'after-observations.json')
    original = json.loads(corrected.committed(corrected.PREVIOUS + 'cause-observations.json'))
    controls = []
    for seed in (0, 1, 42):
        after = json.loads(corrected.decode(next(r for r in actual['runs'] if r['kind'] == 'public' and r['seed'] == seed)['stdout']))
        before = json.loads(corrected.decode(next(r for r in original['runs'] if r['seed'] == seed)['stdout']))
        try:
            namespace['public'](after, 'after', before)
        except AssertionError as error:
            assert str(error) == 'only false assignment/canonical event counters corrected', 'exact initial reviewer rejection'
            controls.append({'seed': seed, 'observed_original_rejection': str(error)})
        else:
            raise AssertionError('original reviewer no longer rejects the actual corrected metadata')
        corrected.public(after, 'after', before)
    result = {'complete': True, 'controls': controls,
        'original_reviewer_sha256': sha(source), 'original_rejection_bytes': len(rejection_raw),
        'original_rejection_sha256': sha(rejection_raw), 'original_rejection_archive_sha256': sha(archive.read_bytes()),
        'corrected_reviewer_sha256': sha(Path(PREFIX + 'review.py').read_bytes()),
        'instrument_sha256': sha(Path(__file__).read_bytes()),
        'correction': 'Exclude only the actual false set_value event from helper/canonical event arrays and adjust both ASSIGN hits/counts. Every other metadata/public channel, including substitution/emitted/dump/fresh, remains exact.'}
    Path(PREFIX + 'instrument-controls.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
