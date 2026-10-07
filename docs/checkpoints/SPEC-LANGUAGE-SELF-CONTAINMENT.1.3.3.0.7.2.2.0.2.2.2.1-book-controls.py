"""Retain the actual initial ineffective publication control and exact source."""
from pathlib import Path
import argparse
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1-'
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def main():
    parser = argparse.ArgumentParser(); parser.add_argument('--capture-initial', action='store_true')
    args = parser.parse_args(); output = ROOT / (PREFIX + 'initial-book-review.json')
    if args.capture_initial:
        assert not output.exists(), 'capture the original publication rejection once'
        source = ROOT / (PREFIX + 'book.py'); original = source.read_bytes()
        command = ['bash', 'tools/run_python_project_data.sh', PREFIX + 'book.py', '--review']
        actual = subprocess.run(command, cwd=ROOT, capture_output=True)
        assert source.read_bytes() == original, 'unchanged actual initial publication producer'
        assert actual.returncode == 1 and b'AssertionError: effective control' in actual.stderr, 'actual ineffective initial control rejection'
        for suffix in ('book.py', 'book-inputs.json', 'book-inputs.tar.gz', 'book.json'):
            before = ROOT / (PREFIX + suffix); retained = ROOT / (PREFIX + 'initial-' + suffix)
            assert not retained.exists(); raw = before.read_bytes(); retained.write_bytes(raw)
            assert retained.read_bytes() == raw
        report = {'complete': True, 'command': command, 'exit': actual.returncode,
            'stdout': envelope(actual.stdout), 'stderr': envelope(actual.stderr),
            'instrument_sha256': sha(original), 'retention_producer_sha256': sha(Path(__file__).read_bytes())}
        output.write_text(json.dumps(report, indent=2) + '\n')
        print('Exact initial publication producer/render inputs and observed ineffective-control rejection retained.')
        return
    original = json.loads(output.read_bytes())
    assert original['complete'] and original['exit'] == 1
    assert original['instrument_sha256'] == sha((ROOT / (PREFIX + 'initial-book.py')).read_bytes())
    source = (ROOT / (PREFIX + 'book.py')).read_bytes()
    old = b"('hidden membership boundary', lambda r: r.update(html=envelope(decode(r['html']).replace(\n            b'Compiler membership acceptance', b'membership boundary removed')))),"
    new = b"('hidden membership boundary', lambda r: r.update(html=envelope(re.sub(\n            br'Compiler membership\\s+acceptance', b'membership boundary removed', decode(r['html']), count=1)))),"
    assert source.count(new) == 1 and source.replace(new, old, 1) == (ROOT / (PREFIX + 'initial-book.py')).read_bytes(), 'sole newline-aware publication control correction'
    verification = json.loads((ROOT / (PREFIX + 'book-verification.json')).read_bytes())
    assert verification['book_inputs'] == 58 and verification['exact_examples'] == 5 and len(verification['controls']) == 9
    assert verification['instrument_sha256'] == sha(source)
    assert any(c['name'] == 'hidden membership boundary' and c['observed_red'] for c in verification['controls'])
    result = {'complete': True, 'original_observed_rejection': 'AssertionError: effective control',
        'corrected_effective_controls': 9, 'book_inputs': 58, 'exact_examples': 5,
        'original_capture_sha256': sha(output.read_bytes()), 'corrected_instrument_sha256': sha(source),
        'instrument_sha256': sha(Path(__file__).read_bytes())}
    (ROOT / (PREFIX + 'book-controls.json')).write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
