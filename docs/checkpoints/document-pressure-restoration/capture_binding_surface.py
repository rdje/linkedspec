"""Retain actual public-surface annotation controls with every reader input."""
import base64
import contextlib
import gzip
import importlib.util
import io
import json
import os
from pathlib import Path
import tempfile

from compact_selector_population import packet

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def observe(module):
    stdout, stderr = io.StringIO(), io.StringIO()
    with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
        try:
            result = module.main()
        except SystemExit as error:
            result = error.code if isinstance(error.code, int) else 1
            if not isinstance(error.code, int):
                print(error.code, file=stderr)
    return dict(returncode=result, stdout=packet(stdout.getvalue().encode()),
                stderr=packet(stderr.getvalue().encode()))


def capture():
    destination = HERE / 'binding-surface-epoch.json.gz'
    if destination.exists():
        raise ValueError('retain existing binding epochs')
    checker = ROOT / 'tools/check_uniform_binding_mutation_result_surface.py'
    teaching_path = ROOT / 'tools/check_mutation_public_surface.py'
    current = load(checker, 'binding_current_inputs')
    teaching = load(teaching_path, 'binding_teaching_inputs')
    names = {path.relative_to(ROOT).as_posix() for path in current.PUBLIC_FILES}
    names.update(current.REQUIRED_ANCHORS)
    names.update('docs/knowledge/'+name for name in current.HISTORICAL_CARDS)
    names.update(path.relative_to(ROOT).as_posix() for path in teaching.public_markdown_paths())
    names.update(teaching.GOVERNED_ANCHORS)
    names.update(teaching.AUTHORITY_PATHS.values())
    sources = {name: (ROOT/name).read_bytes() for name in sorted(names)}
    card = json.loads((HERE/'binding-supersession-inputs.json').read_bytes())
    old = base64.b64decode(card['before']['base64'])
    target_name = card['path']
    cases = {}
    with tempfile.TemporaryDirectory(dir=os.environ['TMPDIR'], prefix='binding-surface-') as directory:
        fixture = Path(directory)
        for name, raw in sources.items():
            path = fixture/name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(raw)
        program = fixture/'tools/check_uniform_binding_mutation_result_surface.py'
        program.parent.mkdir(parents=True, exist_ok=True)
        program.write_bytes(checker.read_bytes())
        module = load(program, 'binding_frozen_fixture')
        target = fixture/target_name
        target.write_bytes(old)
        cases['before'] = observe(module)
        target.write_bytes(sources[target_name])
        cases['after'] = observe(module)
        note = b'Uniform binding supersedes the earlier statement-only array end-mutation result boundary.\n'
        if sources[target_name].count(note) != 1:
            raise ValueError('binding annotation is not unique')
        target.write_bytes(sources[target_name].replace(note, b'', 1))
        cases['lost_annotation'] = observe(module)
        target.write_bytes(sources[target_name])
        readme = fixture/'README.md'
        readme.write_bytes(sources['README.md']+b'\nArray end mutations are statement-only.\n')
        cases['stale_public_claim'] = observe(module)
        readme.write_bytes(sources['README.md'])
        relative = 'docs/knowledge/uniform-binding-array-end-result-supersession.md'
        anchor = b'The current contract is not statement-only'
        (fixture/relative).write_bytes(sources[relative].replace(anchor, b'The old boundary', 1))
        cases['lost_current_anchor'] = observe(module)
    expected = dict(before=1, after=0, lost_annotation=1, stale_public_claim=1, lost_current_anchor=1)
    if {name: row['returncode'] for name, row in cases.items()} != expected:
        raise ValueError('binding surface controls did not distinguish the repair')
    teaching_result = observe(teaching)
    if teaching_result['returncode'] != 0:
        raise ValueError('direct mutation teaching consumer failed')
    record = dict(schema_version=1, owner='TYPE-REFERENCE-BOOK.1.2.20.1.13',
                  sources={name: packet(raw) for name, raw in sources.items()},
                  checker=packet(checker.read_bytes()), teaching_checker=packet(teaching_path.read_bytes()),
                  producer=packet(Path(__file__).read_bytes()), card=card, cases=cases,
                  teaching=teaching_result,
                  limits='Exact current public reader inputs and finite authored controls; no runtime implementation or portable feature admission.')
    destination.write_bytes(gzip.compress(json.dumps(record, sort_keys=True).encode(), mtime=0))
    print('binding supersession: actual RED/GREEN, three losses rejected and teaching consumer PASS')


if __name__ == '__main__':
    capture()
