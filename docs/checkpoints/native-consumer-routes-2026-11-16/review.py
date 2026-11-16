"""Reconstruct bounded native source routes without starting any SDK or writer."""
import argparse
from collections import Counter
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import stat
import tarfile
import tomllib

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PRIOR = 'docs/checkpoints/canonical-discovery-inventory-2026-11-16/inventory.json.gz'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.0'
BACKENDS = ('rust', 'dart', 'julia', 'lua')
MARKERS = {'rust': r'#\[test\]', 'dart': r'\b(?:void\s+)?main\s*\(',
           'julia': r'@test(?:set|\b)', 'lua': r'\b(?:assert|test|check|eq|assert_equal)\s*\('}


def digest(body):
    return hashlib.sha256(body).hexdigest()


def recover():
    identities = json.loads((BASE / 'identities.json').read_bytes())
    sources = {}
    with tarfile.open(BASE / 'inputs.tar.gz') as archive:
        members = archive.getmembers()
        assert len(members) == len(identities), 'source population'
        for member in members:
            name = PurePosixPath(member.name)
            assert member.isfile() and str(name) == member.name and not name.is_absolute() and '..' not in name.parts
            assert member.name not in sources, 'duplicate archive source'
            body = archive.extractfile(member).read()
            row = identities[member.name]
            assert digest(body) == row['sha256'] and len(body) == row['bytes'], 'source body'
            assert stat.S_IMODE(member.mode) == row['mode'], 'source mode'
            sources[member.name] = body
    assert set(sources) == set(identities), 'source namespace'
    tree = json.loads((BASE / 'activation-tree.json').read_bytes())
    assert tree['exit'] == 0 and tree['stderr_hex'] == '' and tree['activation'] == 'cb8978713452f427823f56e456ddc71ad75f0574'
    entries = bytes.fromhex(tree['stdout_hex']).split(b'\0')
    assert entries.pop() == b''
    bound = set()
    for entry in entries:
        metadata, name = entry.split(b'\t', 1)
        mode, kind, oid = metadata.split()
        name = name.decode()
        assert kind == b'blob' and name in sources and name not in bound, 'activation source set'
        body = sources[name]
        assert hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest() == oid.decode(), 'activation Git body'
        assert identities[name]['mode'] == (int(mode, 8) & 0o777), 'activation Git mode'
        bound.add(name)
    instruments = {str(BASE / name) for name in ('capture.py', 'review.py', 'run_step.py', 'branches.py')}
    assert set(sources) - bound == instruments, 'activation instrument boundary'
    return sources, identities


def line_hits(source, pattern):
    return [dict(line=i, source=line) for i, line in enumerate(source.splitlines(), 1)
            if re.search(pattern, line)]


def optional_block(source):
    start = source.index('if [[ "${LINKEDSPEC_RUN_RUST:-0}" == "1" ]]; then\n')
    end = source.index('\nif [[ "${LINKEDSPEC_RUN_CLI_MATRIX:-0}"', start)
    return source[start:end]


def reconstruct(sources):
    inventory = json.loads(gzip.decompress(sources[PRIOR]))
    candidates = [row for row in inventory['rows'] if row['backend'] in BACKENDS
                  and (row['required'] or row['review_candidate'])]
    rust = tomllib.loads(sources['rust/linkedspec-runtime/Cargo.toml'].decode())
    assert rust['package'].get('autotests', True) is True and 'test' not in rust, 'Rust target discovery configuration'
    workspace = tomllib.loads(sources['rust/Cargo.toml'].decode())
    assert workspace['workspace']['package']['edition'] == '2024', 'Rust edition'
    rust_driver = sources['tools/run_rust_local.sh'].decode()
    dart_driver = sources['tools/run_dart_local.sh'].decode()
    assert '"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime\n' in rust_driver, 'Rust package selector'
    assert 'cd "$REPO_ROOT/dart"\n' in dart_driver and '"${DART_RUN[@]}" test\n' in dart_driver, 'Dart package selector'
    julia_driver = sources['tools/run_julia_local.sh'].decode()
    assert "bash tools/run_julia_project_data.sh --project=julia -e 'import Pkg; Pkg.test()'" in julia_driver, 'Julia package selector'
    julia = sources['julia/test/runtests.jl'].decode()
    lua_driver = sources['tools/run_lua_local.sh'].decode()
    lua = sources['lua/test/run.lua'].decode()
    ci = sources['tools/run_ci_local.sh'].decode()
    block = optional_block(ci)
    routes = []
    for backend in BACKENDS:
        flag = 'LINKEDSPEC_RUN_' + backend.upper()
        command = 'bash "$REPO_ROOT/tools/run_' + backend + '_local.sh"'
        assert block.count('if [[ "${' + flag + ':-0}" == "1" ]]; then') == 1, 'conditional gate'
        assert block.count(command + '\n') == 1, 'conditional command'
        routes.append(dict(backend=backend, flag=flag, default='0', enabled='1', command=command))
    roles = []
    for candidate in candidates:
        name, backend = candidate['path'], candidate['backend']
        source = sources[name].decode()
        assert digest(sources[name]) == candidate['sha256'], 'prior candidate source identity'
        markers = line_hits(source, MARKERS[backend])
        assert markers, 'native harness marker:' + name
        item = dict(path=name, backend=backend, role='native-regression-suite-source',
                    admission_owner='TYPE-REFERENCE-BOOK.1.2.23.4.1.2',
                    prior_required=candidate['required'], prior_review_candidate=candidate['review_candidate'],
                    historical_task_references=candidate['task_references'], harness_markers=markers,
                    activation_sha256=digest(sources[name]), execution='not run',
                    direct_loaders='unqualified; sibling1 owns source interpretation')
        if backend == 'rust':
            assert PurePosixPath(name).parent == PurePosixPath('rust/linkedspec-runtime/tests')
            item['route'] = 'Cargo package test convention; documented, not executed'
            item['route_expressions'] = line_hits(rust_driver, r'^"\$CARGO_CMD" test .* -p linkedspec-runtime$')
        elif backend == 'dart':
            assert name.startswith('dart/test/') and name.endswith('_test.dart')
            item['route'] = 'Dart package test convention; documented, not executed'
            item['route_expressions'] = line_hits(dart_driver, r'^"\$\{DART_RUN\[@\]\}" test$')
        elif backend == 'julia':
            expression = 'include("' + PurePosixPath(name).name + '")'
            item['route_expressions'] = line_hits(julia, '^' + re.escape(expression) + '$')
            assert len(item['route_expressions']) == 1, 'Julia named include'
            item['route'] = 'Pkg.test entrypoint with named include; not executed'
        else:
            item['driver_expressions'] = line_hits(lua_driver, r'^.*"\$LUA(?:JIT)?_CMD" ' + re.escape(name) + '$')
            item['route_expressions'] = line_hits(lua, r'^\s*dofile\("' + re.escape(name) + r'"\)$')
            if item['driver_expressions']:
                item['route'] = 'explicit local driver operand; not executed'
            elif item['route_expressions']:
                item['route'] = 'named dofile inside selected local run.lua; not executed'
            else:
                item['route'] = 'no direct local-driver or named run.lua route; transitive route unqualified'
        item['selection_caveats'] = line_hits(source, r'#\[(?:ignore|cfg)|@Skip|skip:|os\.(?:exit|getenv)|ENV\[')
        roles.append(item)
    return dict(owner=OWNER, candidates=roles, optional_gates=routes,
                limits='Static named candidate source roles and bounded local routes only. Convention eligibility and conditional branch selection are not SDK discovery/execution. Test bodies, conditional/ignored cases, transitive includes/loaders, environment/config/package/source-origin resolution and complete population remain unqualified. Registration4.1.2 and native/per-read/physical4.2/SESSION5 remain open.')


def validate(sources, ledger):
    assert ledger == reconstruct(sources), 'role/route ledger differs from source'


def controls(sources, ledger):
    results = {}
    for label in ('missing', 'duplicate', 'support-promoted', 'owner-removed', 'route-invented', 'conditional-default', 'Julia-include-duplicated'):
        changed = copy.deepcopy(ledger)
        if label == 'missing':
            changed['candidates'].pop()
        elif label == 'duplicate':
            changed['candidates'].append(copy.deepcopy(changed['candidates'][0]))
        elif label == 'support-promoted':
            changed['candidates'][0]['role'] = 'support-only'
        elif label == 'owner-removed':
            changed['candidates'][0].pop('admission_owner')
        elif label == 'route-invented':
            row = next(row for row in changed['candidates'] if row['backend'] == 'lua' and not row['route_expressions'] and not row['driver_expressions'])
            row['route'] = 'selected automatically'
        elif label == 'conditional-default':
            changed['optional_gates'][0]['default'] = '1'
        else:
            row = next(row for row in changed['candidates'] if row['backend'] == 'julia')
            row['route_expressions'] *= 2
        try:
            validate(sources, changed)
        except AssertionError as error:
            assert str(error) == 'role/route ledger differs from source'
            results[label] = dict(result='RED', reason=str(error))
        else:
            raise AssertionError('ineffective control:' + label)
    return results


def branch_proof(sources):
    """Check actual retained Bash channels against a separate flag/path oracle."""
    block = optional_block(sources['tools/run_ci_local.sh'].decode())
    preamble = 'set -euo pipefail\nREPO_ROOT=.\nlog(){ :; }\nrequire_tracked_file(){ :; }\nbash(){ printf "%s\\n" "$1"; }\n'
    rows = json.loads((BASE / 'branches.json').read_bytes())
    assert [row['name'] for row in rows] == ['default', 'all', *BACKENDS, 'missing', 'duplicate', 'disabled'], 'branch cases'
    for row in rows:
        name = row['name']
        flags = {f'LINKEDSPEC_RUN_{backend.upper()}': ('0' if name == 'default' or name in BACKENDS and name != backend else '1')
                 for backend in BACKENDS}
        source = block
        rust_command = 'bash "$REPO_ROOT/tools/run_rust_local.sh"'
        if name == 'missing':
            source = source.replace(rust_command, ':', 1)
        elif name == 'duplicate':
            source = source.replace(rust_command, rust_command + '\n ' + rust_command, 1)
        elif name == 'disabled':
            source = source.replace('${LINKEDSPEC_RUN_RUST:-0}" == "1"', '${LINKEDSPEC_RUN_RUST:-0}" == "never"', 1)
        stem = BASE / 'branches' / name
        command = json.loads(stem.with_suffix('.json').read_bytes())
        assert command == dict(argv=['bash', '--noprofile', '--norc', '-s'], cwd='.', flags=flags), 'branch command'
        assert gzip.decompress(stem.with_suffix('.stdin.gz').read_bytes()) == (preamble + source).encode(), 'branch source'
        assert stem.with_suffix('.exit.txt').read_text() == '0\n', 'branch exit'
        assert gzip.decompress(stem.with_suffix('.stderr.gz').read_bytes()) == b'', 'branch stderr'
        actual = gzip.decompress(stem.with_suffix('.stdout.gz').read_bytes()).decode().splitlines()
        expected = ['./tools/run_' + backend + '_local.sh' for backend in BACKENDS if flags['LINKEDSPEC_RUN_' + backend.upper()] == '1']
        assert row['expected'] == expected and row['actual'] == actual, 'branch channels'
        assert row['result'] == ('RED' if name in ('missing', 'duplicate', 'disabled') else 'PASS'), 'branch outcome'
        if row['result'] == 'RED':
            assert actual != expected, 'effective branch control'
            assert actual == ([*expected[:1], *expected] if name == 'duplicate' else expected[1:]), 'distinguishing branch difference'
        else:
            assert actual == expected, 'healthy branch selection'
    return dict(healthy=6, observed_red=['missing', 'duplicate', 'disabled'], sdk_executed=False)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--current', action='store_true')
    args = parser.parse_args()
    sources, identities = recover()
    ledger = json.loads((BASE / 'roles.json').read_bytes())
    validate(sources, ledger)
    result = dict(result='PASS', candidates=len(ledger['candidates']),
                  backends=dict(sorted(Counter(row['backend'] for row in ledger['candidates']).items())),
                  routes=dict(sorted(Counter(row['route'] for row in ledger['candidates']).items())),
                  controls=controls(sources, ledger), branch_selection=branch_proof(sources),
                  source_inputs=len(sources), limits=ledger['limits'])
    if args.current:
        for name, row in identities.items():
            path = Path(name)
            assert path.is_file() and not path.is_symlink(), 'current source type:' + name
            assert digest(path.read_bytes()) == row['sha256'] and stat.S_IMODE(path.stat().st_mode) == row['mode'], 'current source identity:' + name
        result['current_inputs'] = len(sources)
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
