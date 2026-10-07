"""Grade the completed bounded subpopulation while complete consumers are pending."""
from pathlib import Path
import hashlib
import importlib.util
import json
import traceback

ROOT = Path(__file__).resolve().parents[2]
PREFIX = str(Path(__file__).resolve()).removesuffix('preflight.py')
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def main():
    spec = importlib.util.spec_from_file_location('grouped_repair_preflight_review', PREFIX + 'review.py')
    review = importlib.util.module_from_spec(spec); spec.loader.exec_module(review)
    before, after = [review.read(PREFIX + e + '-observations.json') for e in ('before', 'after')]
    result = {'complete_subpopulation': False, 'consumers_pending': not after['complete'],
        'reviewer_sha256': sha(Path(PREFIX + 'review.py').read_bytes()),
        'instrument_sha256': sha(Path(__file__).read_bytes())}
    try:
        population = review.original_population()
        counts = {e: review.check_inputs(review.read(PREFIX + e + '-inputs.json'), e, population)
                  for e in ('before', 'after')}
        review.check_delta((ROOT / review.METHOD).read_bytes(), (ROOT / review.SOURCE).read_bytes(), (ROOT / review.FIXTURE).read_bytes())
        original = json.loads(review.committed(review.PREVIOUS + 'cause-observations.json'))
        original_public = {r['seed']: json.loads(review.decode(r['stdout'])) for r in original['runs']}
        default_before = review.decode(before['runs'][-1]['stdout'])
        capture = review.module('grouped_preflight_capture', PREFIX + 'capture.py')
        result['before'] = review.check_report(before, 'before', counts['before'], capture, original_public, default_before)
        expected = [('compiler-tap', s) for s in (0, 1, 42)] + [('public', s) for s in (0, 1, 42)] + [('default-query', 0)]
        assert [(r['kind'], r['seed']) for r in after['runs'][:7]] == expected, 'completed actual seven-command subpopulation'
        assert after['instrument_sha256'] == before['instrument_sha256'] == sha(Path(PREFIX + 'capture.py').read_bytes())
        assert after['revision'] == review.REVISION and after['epoch'] == 'after'
        corrected = []
        for run in after['runs'][:7]:
            assert run['exit'] == 0 and review.decode(run['stderr']) == b'', 'actual quiet corrected command'
            assert run['inputs_before'] == run['inputs_after'] == counts['after']
            stdout = review.decode(run['stdout'])
            if run['kind'] == 'compiler-tap':
                corrected.append(dict(review.compiler_tap(stdout, 'after', run['seed']), seed=run['seed']))
            elif run['kind'] == 'public':
                review.public(json.loads(stdout), 'after', original_public[run['seed']])
            else:
                assert stdout == default_before, 'all72 original default query/view/numeric/syntactic channels exact'
        result.update(complete_subpopulation=True, after_compiler=corrected,
            actual_completed_commands=14, default_query_sources=72, successful_corrected_native_fresh_values=36)
    except Exception:
        result['observed_rejection'] = traceback.format_exc()
        Path(PREFIX + 'preflight.json').write_text(json.dumps(result, indent=2) + '\n')
        raise
    Path(PREFIX + 'preflight.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
