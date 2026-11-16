"""Qualify Rust custody root selection by its actual archive locator."""
import argparse
import contextlib
import gzip
import importlib.util
import io
import json
from pathlib import Path
import types

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
OLD = "if row['tag'] == 'root'"
NEW = "if row['archive'] == str(PurePosixPath(plan['historical']).parent / 'root-inputs.tar.gz')"


def first_qualification():
    spec = importlib.util.spec_from_file_location('first_rust_plan_qualification', BASE / 'review_qualified.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def derive(first, sources):
    body = first.derive(sources)
    assert gzip.decompress((BASE / 'qualified-source.py.gz').read_bytes()) == body
    assert body.count(OLD.encode()) == 2, 'comparison and inverse use the same original selector'
    return body.replace(OLD.encode(), NEW.encode())


def first_refusal(first):
    sources, _ = first.preparation()
    module = first.engine(first.derive(sources))
    sources, identities = module.recover()
    ledger = json.loads((BASE / 'loaders.json').read_bytes())
    assert ledger == module.scan(sources)
    try:
        module.historical(sources, identities, ledger)
    except KeyError as error:
        assert error.args == ('tag',)
        plan = json.loads(sources[str(BASE / 'plan.json')])
        packets = json.loads(sources[plan['historical']])
        assert len(packets) == 4 and all(set(row) == {'archive', 'files'} for row in packets)
        roots = [row for row in packets if row['archive'] == str(Path(plan['historical']).parent / 'root-inputs.tar.gz')]
        assert len(roots) == 1
        return dict(result='RED', exception='KeyError', missing_key='tag', packets=len(packets),
            packet_keys=['archive', 'files'], root_archive=roots[0]['archive'], root_file_count=len(roots[0]['files']),
            limits='Pure first-qualified historical-reader reconstruction; original child exit1/channels remain exact.')
    raise AssertionError('first historical reader unexpectedly accepted')


def engine(body):
    module = types.ModuleType('rust_archive_locator_qualification')
    module.__file__ = str(BASE / 'review.py')
    exec(compile(body, str(BASE / 'qualified2-source.py'), 'exec'), module.__dict__)
    return module


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--current', action='store_true')
    parser.parse_args()
    first = first_qualification()
    sources, _ = first.preparation()
    body = derive(first, sources)
    assert gzip.decompress((BASE / 'qualified2-source.py.gz').read_bytes()) == body
    original = first.original_refusal(sources)
    assert json.loads((BASE / 'original-reader-refusal.json').read_bytes()) == original
    failure = first_refusal(first)
    assert json.loads((BASE / 'first-qualified-refusal.json').read_bytes()) == failure
    output = io.StringIO()
    with contextlib.redirect_stdout(output):
        engine(body).main()
    result = json.loads(output.getvalue())
    result['original_reader_refusal'] = original
    result['first_qualified_refusal'] = failure
    result['qualification'] = 'Original plan-argument substitutions plus two exact archive-locator selectors; source graph and all earlier epochs/channels remain exact.'
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
