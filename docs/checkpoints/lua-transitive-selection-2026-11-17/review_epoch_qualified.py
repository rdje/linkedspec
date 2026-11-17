"""Qualify the actual used reader and recover its retained Bash observations."""
import ast
import contextlib
import copy
import gzip
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def epoch(original, expanded):
    old_tree, new_tree = ast.parse(original), ast.parse(expanded)
    old_functions = {node.name: ast.get_source_segment(original, node) for node in old_tree.body if isinstance(node, ast.FunctionDef)}
    new_functions = {node.name: ast.get_source_segment(expanded, node) for node in new_tree.body if isinstance(node, ast.FunctionDef)}
    assert set(new_functions) - set(old_functions) == {'verify_probes'}, 'only readonly support function added'
    for name in old_functions.keys() - {'main'}:
        assert old_functions[name] == new_functions[name], 'used helper bytes: ' + name
    old_module = [ast.dump(node) for node in old_tree.body if not isinstance(node, ast.FunctionDef)]
    new_module = [ast.dump(node) for node in new_tree.body if not isinstance(node, ast.FunctionDef)
        and not (isinstance(node, ast.Import) and len(node.names) == 1 and node.names[0].name == 'ast')]
    assert old_module == new_module, 'module bindings unchanged except ast import'
    return sorted(old_functions.keys() - {'main'})


def main():
    spec = importlib.util.spec_from_file_location('original_lua_selection', BASE / 'review.py')
    original = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(original)
    sources, _ = original.recover()
    record = json.loads((BASE / 'reader-epoch.json').read_bytes())
    archived = {}
    with tarfile.open(BASE / 'reader-epoch-after-use.tar.gz') as archive:
        assert len(archive.getmembers()) == len(record['identities'])
        for member in archive:
            assert member.isfile() and member.name in record['identities'] and member.name not in archived
            body = archive.extractfile(member).read()
            row = record['identities'][member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert stat.S_IMODE(member.mode) == row['mode']
            archived[member.name] = body
    frozen = sources[str(BASE / 'review.py')].decode()
    assert (BASE / 'review.py').read_text() == frozen, 'frozen original restored exactly'
    body = frozen
    for edit in reversed(record['edits']):
        assert body[edit['begin']:edit['end']] == edit['original']
        body = body[:edit['begin']] + edit['replacement'] + body[edit['end']:]
    assert body == record['derived_source']
    assert body.encode() == archived[str(BASE / 'review.py')] == (BASE / 'used_review_expanded.py').read_bytes()
    assert hashlib.sha256(body.encode()).hexdigest() == record['used_sha256']
    helpers = epoch(frozen, body)
    controls = {}
    for name, before, after in [('changed-scan', '    source = sources[\'tools/run_lua_local.sh\'].decode()',
        '    source = ""'), ('changed-command-population-guard', '    assert primary == secondary,', '    assert primary != secondary,')]:
        assert body.count(before) == 1
        changed = body.replace(before, after, 1)
        try:
            epoch(frozen, changed)
        except AssertionError as error:
            assert str(error) == 'used helper bytes: scan'
            controls[name] = 'RED'
        else:
            raise AssertionError('used helper corruption accepted')
    identities = json.loads((BASE / 'completion-identities.json').read_bytes())
    with tarfile.open(BASE / 'completion-inputs.tar.gz') as archive:
        assert len(archive.getmembers()) == len(identities)
        for member in archive:
            assert member.isfile() and member.name in identities
            data = archive.extractfile(member).read()
            row = identities[member.name]
            assert len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256']
            assert stat.S_IMODE(member.mode) == row['mode']
            assert Path(member.name).read_bytes() == data and stat.S_IMODE(Path(member.name).stat().st_mode) == row['mode']
    positive = gzip.decompress((BASE / 'commands/positive-stdout.gz').read_bytes())
    assert (BASE / 'commands/positive-exit.txt').read_text() == '0\n'
    assert gzip.decompress((BASE / 'commands/positive-stderr.gz').read_bytes()) == b''
    plan = json.loads(sources[str(BASE / 'plan.json')])
    assert (plan['activation'] + ':lua/test/run.lua').encode() in positive.split(b'\0'), 'positive literal caller control'
    try:
        assert (plan['activation'] + ':lua/test/run.lua').encode() in b''.split(b'\0'), 'always-empty locator'
    except AssertionError as error:
        assert str(error) == 'always-empty locator'
        controls['always-empty-locator'] = 'RED'
    else:
        raise AssertionError('empty locator accepted')
    module = dict(__file__=str(BASE / 'review.py'), __name__='qualified_used_lua_reader')
    exec(compile(body, str(BASE / 'review.py'), 'exec'), module)
    output = io.StringIO()
    with contextlib.redirect_stdout(output):
        module['main']()
    result = json.loads(output.getvalue())
    result.update(reader_epoch=dict(unchanged_helpers=helpers, after_use_inputs=len(archived), controls=controls,
        missing=record['missing'], repair_owner=record['repair_owner']))
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
