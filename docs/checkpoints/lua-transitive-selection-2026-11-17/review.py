"""Recover named Lua selection separately from syntax checks and textual mentions."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import shlex
import stat
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def image(label, identities_name):
    identities = json.loads((BASE / identities_name).read_bytes())
    sources = {}
    with tarfile.open(BASE / (label + '.tar.gz')) as archive:
        assert len(archive.getmembers()) == len(identities)
        for member in archive:
            name = PurePosixPath(member.name)
            assert member.isfile() and not name.is_absolute() and '..' not in name.parts and member.name not in sources
            body = archive.extractfile(member).read()
            row = identities[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'archived body'
            assert stat.S_IMODE(member.mode) == row['mode'], 'archived mode'
            if 'oid' in row:
                assert hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest() == row['oid'], 'Git body'
            sources[member.name] = body
    assert set(sources) == set(identities)
    return sources, identities


def recover():
    sources, identities = image('sources', 'source-identities.json')
    extra, modes = image('instruments', 'instrument-identities.json')
    assert not set(extra) & set(sources)
    sources.update(extra)
    identities.update(modes)
    return sources, identities


def blocks(source):
    syntax = source.split('log "syntax-checking Lua source"\n', 1)[1].split('\nlog "running primary PUC Lua tests"', 1)[0]
    primary = source.split('log "running primary PUC Lua tests"\n', 1)[1].split('\nlog "running shared primary CLI contract', 1)[0]
    secondary = source.split(' log "running secondary LuaJIT compatibility tests"\n', 1)[1].split('\n export LINKEDSPEC_LUA_NATIVE_LUAJIT_DIR', 1)[0]
    assert 'assert(loadfile(os.getenv("LINKEDSPEC_LUA_CHECK_FILE")))' in syntax
    assert ')))()' not in syntax
    return dict(syntax=syntax, primary=primary, secondary=secondary)


def command_paths(block):
    lines = block.replace('\\\n', ' ').splitlines()
    result = []
    for line in lines:
        if not line.strip():
            continue
        words = shlex.split(line)
        operands = [word for word in words if word.startswith('lua/test/') and word.endswith('.lua')]
        assert len(operands) == 1, 'bounded direct test command'
        result.append(operands[0])
    return result


def lua_calls(source):
    # Mask quoted/long strings and comments, retaining exact token offsets.
    pattern = r'--\[(?P<comment>=*)\[.*?\](?P=comment)\]|--[^\n]*|\[(?P<long>=*)\[.*?\](?P=long)\]|"(?:\\.|[^"\\])*"|\x27(?:\\.|[^\x27\\])*\x27'
    code = re.sub(pattern, lambda hit: ''.join('\n' if ch == '\n' else ' ' for ch in hit[0]), source, flags=re.S)
    calls, dynamic = [], []
    for hit in re.finditer(r'\bdofile\s*\(', code):
        tail = source[hit.end():]
        literal = re.match(r'\s*([\x27"])([^\x27"\n]+)\1\s*\)', tail)
        location = dict(line=source.count('\n', 0, hit.start()) + 1)
        if literal:
            calls.append(dict(target=literal[2], **location))
        else:
            dynamic.append(location)
    return calls, dynamic


def scan(sources):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    source = sources['tools/run_lua_local.sh'].decode()
    chunks = blocks(source)
    primary, secondary = command_paths(chunks['primary']), command_paths(chunks['secondary'])
    assert primary == secondary, 'primary/secondary named operands'
    assert primary.count('lua/test/run.lua') == 1
    assert 'if command -v "$LUAJIT_CMD" >/dev/null 2>&1; then' in source
    calls, dynamic = lua_calls(sources['lua/test/run.lua'].decode())
    inherited = json.loads(sources[plan['native_roles']])['candidates']
    old = [row for row in inherited if row['backend'] == 'lua']
    unresolved = sorted(row['path'] for row in old if row['route'].startswith('no direct local-driver'))
    assert unresolved == plan['candidates'] and len(unresolved) == 11
    named = {row['target'] for row in calls}
    results = []
    for name in unresolved:
        refs = []
        for path, body in sources.items():
            if path.startswith(tuple(root + '/' for root in plan['roots'])):
                for number, line in enumerate(body.decode('utf-8').splitlines(), 1):
                    if Path(name).name in line:
                        refs.append(dict(source=path, line=number, text=line))
        results.append(dict(candidate=name, direct_primary=primary.count(name),
            direct_secondary=secondary.count(name), shared_runner=name in named,
            references=refs, qualification='Named local-driver and shared-runner selection only; other textual mentions retain exact context without execution credit. Computed/transitive routes remain separately unresolved.'))
    selected_old = sorted(row['path'] for row in old if row['route'].startswith('named dofile'))
    assert all(name in named for name in selected_old), 'independent older named-route population'
    return dict(owner=plan['owner'], candidates=results, primary=primary, secondary=secondary,
        shared_dofile_calls=calls, shared_dynamic_dofile=dynamic, previously_named=selected_old,
        syntax_expression='assert(loadfile(os.getenv("LINKEDSPEC_LUA_CHECK_FILE")))',
        syntax_role='compile-only source expression; Bash recorder selects filenames but executes no Lua compiler/test body',
        secondary_condition='command -v configured LuaJIT succeeds; declared-host identity remains separate',
        limits='Eleven candidates against exact local-driver command blocks, shared-runner dofile vocabulary and scoped literal-reference census. No complete computed/transitive graph, SDK/body execution, actual package/native resolution, registration repair or canonical admission.')


def verify_census(sources):
    plan = json.loads(sources[str(BASE / 'plan.json')])
    census = json.loads((BASE / 'census.json').read_bytes())
    assert census['activation'] == plan['activation'] and census['roots'] == plan['roots']
    reads, matches = set(), []
    needles = [Path(name).name.encode() for name in plan['candidates']]
    for row in census['blob_reads']:
        assert row['path'] not in reads and row['path'].split('/')[0] in plan['roots']
        assert row['exit'] == 0 and row['stderr_hex'] == ''
        body = subprocess.check_output(['git', 'cat-file', 'blob', row['oid']])
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'census Git identity'
        assert hashlib.sha1(b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest() == row['oid']
        if any(needle in body for needle in needles):
            matches.append(row['path'])
            assert sources[row['path']] == body, 'matched source archive'
        reads.add(row['path'])
    assert sorted(matches) == census['matching_files'], 'literal-reference census'
    tree = gzip.decompress((BASE / 'commands/tree-stdout.gz').read_bytes())
    expected = set()
    boundaries = []
    for cell in tree.split(b'\0'):
        if cell:
            metadata, raw_name = cell.split(b'\t', 1)
            mode, kind, oid = metadata.split()
            if kind == b'blob' and mode in (b'100644', b'100755'):
                expected.add(raw_name.decode())
            else:
                boundaries.append(dict(path=raw_name.decode(), mode=mode.decode(), kind=kind.decode(), oid=oid.decode()))
    assert boundaries == census['boundaries'], 'read-only link boundaries'
    assert reads == expected, 'whole named-subtree population'
    return dict(blobs=len(reads), matching_files=matches, limits=census['limits'])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--current', action='store_true')
    args = parser.parse_args()
    sources, identities = recover()
    ledger = scan(sources)
    assert ledger == json.loads((BASE / 'selection.json').read_bytes()), 'retained selection'
    if args.current:
        for name, body in sources.items():
            path = Path(name)
            assert not path.is_symlink() and path.read_bytes() == body, 'current body'
            assert stat.S_IMODE(path.stat().st_mode) == identities[name]['mode'], 'current mode'
    print(json.dumps(dict(result='PASS', current_inputs=len(sources) if args.current else 0,
        retained_inputs=len(sources), candidates=ledger['candidates'], direct_commands=len(ledger['primary']),
        shared_dofile_calls=len(ledger['shared_dofile_calls']), shared_dynamic_dofile=ledger['shared_dynamic_dofile'],
        inherited_named=len(ledger['previously_named']), census=verify_census(sources), limits=ledger['limits']), indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
