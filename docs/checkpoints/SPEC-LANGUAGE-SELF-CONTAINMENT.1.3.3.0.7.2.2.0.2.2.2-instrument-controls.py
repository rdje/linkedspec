"""Retain the original abbreviated-report acceptance and verify its correction."""
from pathlib import Path
import contextlib
import copy
import gzip
import hashlib
import importlib.util
import io
import json
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
PREFIX = str(Path(__file__).resolve()).removesuffix('instrument-controls.py')
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def main():
    original_source = Path(PREFIX + 'initial-grouped-review.py').read_bytes()
    original_archive = Path(PREFIX + 'initial-grouped-observations.json.gz').read_bytes()
    original = json.loads(gzip.decompress(original_archive))
    grouped = json.loads(Path(PREFIX + 'grouped-observations.json').read_bytes())
    namespace = {'__file__': PREFIX + 'grouped-review.py', '__name__': 'retained_grouped_instrument'}
    exec(compile(original_source, namespace['__file__'], 'exec'), namespace)
    actual_read = Path.read_bytes
    controls = []
    spec = importlib.util.spec_from_file_location('corrected_grouped_instrument', PREFIX + 'grouped-review.py')
    corrected = importlib.util.module_from_spec(spec); spec.loader.exec_module(corrected)
    for name, mutate in (
        ('truncated original command population', lambda r: r['runs'].pop()),
        ('changed original producer identity', lambda r: r['runs'][0].update(producer_sha256='0' * 64)),
        ('lost original full input guard', lambda r: r['runs'][0].update(inputs_after=0)),
    ):
        candidate = copy.deepcopy(original); mutate(candidate); assert candidate != original
        candidate_raw = json.dumps(candidate).encode(); saved = []
        def read(path):
            if str(path) == PREFIX + 'initial-grouped-observations.json.gz':
                return gzip.compress(candidate_raw, mtime=0)
            if str(path) == PREFIX + 'grouped-review.py':
                return original_source
            return actual_read(path)
        def write(path, content, *args, **kwargs):
            assert str(path) == PREFIX + 'grouped-verification.json', 'isolated instrument output only'
            saved.append(content); return len(content)
        output = io.StringIO()
        with patch.object(Path, 'read_bytes', read), patch.object(Path, 'write_text', write), contextlib.redirect_stdout(output):
            namespace['main']()
        assert len(saved) == 1, 'original instrument accepted the effective corruption'
        try:
            corrected.check_original(candidate, grouped)
        except AssertionError as error:
            controls.append({'name': name, 'original_instrument_accepted': True,
                'corrupted_original_report': corrected.envelope(candidate_raw),
                'original_summary': json.loads(saved[0]),
                'original_stdout': corrected.envelope(output.getvalue().encode()),
                'corrected_observed_red': str(error)})
        else:
            raise AssertionError('corrected instrument accepted: ' + name)
    assert Path(PREFIX + 'initial-grouped-review.py').read_bytes() == original_source
    assert Path(PREFIX + 'initial-grouped-observations.json.gz').read_bytes() == original_archive
    corrected.check_original(original, grouped)
    result = {'complete': True, 'original_instrument_sha256': sha(original_source),
        'original_archive_sha256': sha(original_archive), 'controls': controls,
        'corrected_instrument_sha256': sha(Path(PREFIX + 'grouped-review.py').read_bytes()),
        'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'instrument-controls.json').write_text(json.dumps(result, indent=2) + '\n')
    print('Original retention guard accepted three corruptions; corrected guard rejects all three and accepts the exact original.')


if __name__ == '__main__':
    main()
