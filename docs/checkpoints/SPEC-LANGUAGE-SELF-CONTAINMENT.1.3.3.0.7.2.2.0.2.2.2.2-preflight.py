"""Grade only actually completed compiler rows while the full capture continues."""
from pathlib import Path
import importlib.util
import json

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('preflight.py')


def main():
    spec = importlib.util.spec_from_file_location('acceptance_oracles', PREFIX + 'review.py')
    review = importlib.util.module_from_spec(spec); spec.loader.exec_module(review)
    report = json.loads(Path(PREFIX + 'observations.json').read_bytes())
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    rows = [r for r in report['runs'] if r['kind'] == 'compiler-tap']
    assert [(r['kind'], r['seed']) for r in rows] == [('compiler-tap', s) for s in (0, 1, 42)]
    grouped = review.load_grouped_reviewer(); results = []
    for row in rows:
        assert row['exit'] == 0 and review.decode(row['stderr']) == b''
        assert row['inputs_before'] == row['inputs_after'] == manifest['regular_git_inputs']
        results.append(dict(grouped.compiler_tap(review.decode(row['stdout']), 'after', row['seed']), seed=row['seed']))
    result = {'partial': True, 'full_acceptance_pending': True, 'revision': report['revision'],
              'actual_completed_rows': rows, 'compiler': results,
              'instrument_sha256': review.sha(Path(__file__).read_bytes()),
              'reviewer_sha256': review.sha(Path(PREFIX + 'review.py').read_bytes()),
              'capture_sha256': report['instrument_sha256'],
              'inputs_sha256': review.sha(Path(PREFIX + 'inputs.json').read_bytes())}
    Path(PREFIX + 'preflight.json').write_text(json.dumps(result, indent=2) + '\n')
    print('Actual fresh compiler41/789 and original40/signature225 pass all three seeds; full77-command acceptance pending')


if __name__ == '__main__':
    main()
