"""Qualify exactly one positional control without changing its original epoch."""
import argparse
import contextlib
import copy
import gzip
import importlib.util
import io
import json
from pathlib import Path
import sys
import types

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
OLD = "elif label=='runtime-exclusion-erased': changed['execution_qualifications'].pop(0)"
NEW = "elif label=='runtime-exclusion-erased': changed['execution_qualifications']=[row for row in changed['execution_qualifications'] if row['role']!='invalid-build compile-only branch and named runtime exclusions']"
ROLE = 'invalid-build compile-only branch and named runtime exclusions'


def retained_reader():
    spec = importlib.util.spec_from_file_location('original_julia_loader_reader', BASE / 'review.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def derive(sources):
    original = sources[str(BASE / 'review.py')]
    assert original == (BASE / 'review.py').read_bytes(), 'original reader remains exact'
    assert original.count(OLD.encode()) == 1
    return original.replace(OLD.encode(), NEW.encode(), 1)


def victim_oracle(ledger):
    original = ledger['execution_qualifications']
    changed = copy.deepcopy(original)
    victim = changed.pop(0)
    assert victim['role'] == 'existing non-Perl expected-value fallback; no portable-policy admission'
    assert sum(row['role'] == ROLE for row in changed) == 1, 'old control still retains runtime exclusions'
    qualified = [row for row in original if row['role'] != ROLE]
    assert len(original) == 3 and len(qualified) == 2
    assert all(row['role'] != ROLE for row in qualified)
    return dict(original_label='runtime-exclusion-erased', original_result='RED: victim is Count fallback and runtime exclusions remain',
        original_victim=victim, qualified_victim=[row for row in original if row['role'] == ROLE],
        qualified_result='PASS: exactly the runtime-exclusion role removed; both expectation qualifications remain')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--current', action='store_true')
    args = parser.parse_args()
    original = retained_reader()
    sources, _ = original.recover()
    ledger = json.loads((BASE / 'loaders.json').read_bytes())
    assert ledger == original.scan(sources)
    oracle = victim_oracle(ledger)
    assert json.loads((BASE / 'control-victim.json').read_bytes()) == oracle
    body = derive(sources)
    assert gzip.decompress((BASE / 'qualified-source.py.gz').read_bytes()) == body
    module = types.ModuleType('qualified_julia_control')
    module.__file__ = str(BASE / 'review.py')
    exec(compile(body, module.__file__, 'exec'), module.__dict__)
    output = io.StringIO()
    with contextlib.redirect_stdout(output):
        module.main()
    result = json.loads(output.getvalue())
    result['control_qualification'] = oracle
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
