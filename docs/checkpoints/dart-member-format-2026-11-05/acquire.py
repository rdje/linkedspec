"""One-shot acquisition for TYPE-REFERENCE-BOOK.1.2.23.3.73.8.

Run from the repository root with tools/run_python_project_data.sh. Retains
declared direct inputs; complete native/transitive custody remains23.4.2-owned.
"""
import difflib
import gzip
import json
from pathlib import Path
import re
import subprocess
import tarfile

ROOT = Path.cwd()
OUT = Path(__file__).parent
OWNER = Path('dart/lib/src/runtime/interpreter.dart')
TESTS = ['test/free_default_result_composition_test.dart',
         'test/set_result_composition_test.dart']


def retain(name, data):
    (OUT / name).write_bytes(gzip.compress(data, mtime=0))


def run(name, args, expected=0):
    result = subprocess.run(['bash', '../tools/run_dart_project_data.sh', *args],
                            cwd=ROOT / 'dart', capture_output=True)
    retain(name + '-stdout.log.gz', result.stdout)
    retain(name + '-stderr.log.gz', result.stderr)
    (OUT / (name + '-command.json')).write_text(json.dumps({
        'cwd': 'dart', 'argv': ['bash', '../tools/run_dart_project_data.sh', *args],
        'exit': result.returncode}, indent=2) + '\n')
    assert result.returncode == expected, (name, result.returncode)
    return result


def main():
    assert not (OUT / 'before.dart.gz').exists(), 'One-shot capture already exists'
    before = OWNER.read_bytes()
    retain('before.dart.gz', before)
    run('version', ['--version'])
    run('before-format', ['format', '--output=none', '--set-exit-if-changed',
                          'lib/src/runtime/interpreter.dart'], expected=1)
    assert OWNER.read_bytes() == before
    run('apply-format', ['format', 'lib/src/runtime/interpreter.dart'])
    after = OWNER.read_bytes()
    retain('after.dart.gz', after)
    retain('formatter.diff.gz', ''.join(difflib.unified_diff(
        before.decode().splitlines(True), after.decode().splitlines(True),
        fromfile=str(OWNER), tofile=str(OWNER))).encode())
    members = r'  bool (_isFreeDefaultResultSource|_isCanonicalSetResultSource)\(ActionExpr expression\) \{\n.*?\n  \}'
    old_members = list(re.finditer(members, before.decode(), re.S))
    new_members = list(re.finditer(members, after.decode(), re.S))
    assert len(old_members) == len(new_members) == 2
    assert re.sub(members, '<owned member>', before.decode(), flags=re.S) == re.sub(
        members, '<owned member>', after.decode(), flags=re.S)
    for old, new in zip(old_members, new_members):
        def normalize(value):
            # The formatter adds optional trailing commas before close-parens.
            return re.sub(r'\s+', '', re.sub(r',\s*\)', ')', value))
        assert old.group(1) == new.group(1)
        assert normalize(old.group()) == normalize(new.group())
    run('after-format', ['format', '--output=none', '--set-exit-if-changed',
                         'lib/src/runtime/interpreter.dart'])
    direct = sorted(Path('dart/lib').rglob('*.dart')) + [Path('dart') / p for p in TESTS]
    direct += [Path('dart/pubspec.yaml'), Path('dart/pubspec.lock'),
               Path('dart/.dart_tool/package_config.json')]
    with tarfile.open(OUT / 'before-first-proof.tar.gz', 'w:gz') as archive:
        for path in direct:
            archive.add(path, arcname=path.as_posix(), recursive=False)
    # Capture precedes analysis/test compilation. This is declared direct custody.
    run('analysis', ['analyze', '--fatal-infos', '--fatal-warnings',
                    'lib/src/runtime/interpreter.dart', *TESTS])
    run('preservation', ['test', '--reporter', 'expanded', '--concurrency=1',
                         *TESTS, '--name',
                         '^(container_guards|lazy_order_and_snapshot|direct_incompatible_consumers_skip_operands|source_once_before_consumer_rebinding_and_local_returns)$'])
    with tarfile.open(OUT / 'before-first-proof.tar.gz') as archive:
        for path in direct:
            assert archive.extractfile(path.as_posix()).read() == path.read_bytes()
    (OUT / 'result.json').write_text(json.dumps({
        'scope': 'two formatter-owned members; four authored preservation controls',
        'outside_members_identical': True,
        'member_tokens_preserved_except_optional_trailing_commas': True,
        'direct_inputs_unchanged_after_proof': True,
        'limits': 'No emitted-host execution, complete transitive/native custody, performance or full admission claim.'
    }, indent=2) + '\n')


if __name__ == '__main__':
    main()
