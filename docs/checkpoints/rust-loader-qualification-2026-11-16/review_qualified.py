"""Recover Rust plan arguments with the original failed reader kept exact."""
import argparse
import contextlib
import gzip
import importlib.util
import io
import json
from pathlib import Path
import re
import types

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
REPLACEMENTS = [
    ("assert re.search(r'execute_generated_parser_v2\\(\\s*&serialized,', source)",
     "plan_input = re.search(r'execute_generated_parser_v2\\(\\s*&(serialized|retained),', source)\n                assert plan_input"),
    ("consumed_by = 'restored route; plan call still names original serialized string'",
     "consumed_by = ('restored route and plan both name retained string' if plan_input[1] == 'retained' else 'restored route; plan call still names original serialized string')"),
    ("timing=timing, lexical_prefix=prefix[1],",
     "timing=timing, plan_argument=plan_input[1] if folder[1] == 'normal-inputs' else None, lexical_prefix=prefix[1],"),
    ("lambda row: 'CompiledSpec deserialization' in row['role'], 'all plan inputs read back'",
     "lambda row: row.get('plan_argument') == 'serialized', 'all plan inputs read back'"),
]


def original_reader():
    spec = importlib.util.spec_from_file_location('original_rust_loader_reader', BASE / 'review.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def preparation():
    module = original_reader()
    sources, identities = module.prior_sources()
    extra, modes = module.image('preparation')
    assert not set(extra) & set(sources)
    sources.update(extra)
    identities.update(modes)
    return sources, identities


def derive(sources):
    body = sources[str(BASE / 'review.py')]
    assert (BASE / 'review.py').read_bytes() == body, 'original failed reader stays exact'
    for before, after in REPLACEMENTS:
        assert body.count(before.encode()) == 1, 'exact qualified substitution'
        body = body.replace(before.encode(), after.encode(), 1)
    return body


def original_refusal(sources):
    module = original_reader()
    try:
        module.scan(sources)
    except AssertionError as error:
        trace = error.__traceback__
        frames = []
        while trace is not None:
            if trace.tb_frame.f_code.co_name == 'scan':
                frames.append((trace.tb_lineno, trace.tb_frame.f_locals))
            trace = trace.tb_next
        assert len(frames) == 1 and str(error) == ''
        line, values = frames[0]
        assert line == 158
        consumer = values['name']
        assert consumer.endswith('/array_concat_open_arity_result_guard_composition.rs')
        actual = re.search(r'execute_generated_parser_v2\(\s*&(serialized|retained),', sources[consumer].decode())
        assert actual and actual[1] == 'retained'
        return dict(result='RED', exception='AssertionError', reader_line=line, consumer=consumer,
            expected_argument='serialized', actual_source_argument=actual[1],
            limits='Pure reconstruction of the retained first reader refusal; no capture or SDK replay.')
    raise AssertionError('original failed reader unexpectedly accepted')


def engine(body):
    module = types.ModuleType('qualified_rust_plan_arguments')
    module.__file__ = str(BASE / 'review.py')
    exec(compile(body, module.__file__, 'exec'), module.__dict__)
    return module


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--current', action='store_true')
    parser.parse_args()
    sources, _ = preparation()
    body = derive(sources)
    assert gzip.decompress((BASE / 'qualified-source.py.gz').read_bytes()) == body
    original = original_refusal(sources)
    assert json.loads((BASE / 'original-reader-refusal.json').read_bytes()) == original
    module = engine(body)
    output = io.StringIO()
    with contextlib.redirect_stdout(output):
        module.main()
    result = json.loads(output.getvalue())
    result['original_reader_refusal'] = original
    result['qualification'] = 'Four exact substitutions derive each plan argument, its consumption role and the serialized-plan control victim; original sources/channels unchanged.'
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
