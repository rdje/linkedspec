"""Readonly dated preservation proof, including actual first legacy-tail RED."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = ROOT / 'docs/checkpoints/task-headroom-lua-2026-11-07'
ACTIVATION = '2286c6606a9fb86290801e1c8a0053e59d342a1f'
SOURCE = 'docs/tasks/LUA-BACKEND-PARITY.md'
MANIFEST = 'docs/history/task-narrative-epochs/TYPE-REFERENCE-BOOK.1.2.23.4.16.json'
EPOCH = 'TYPE-REFERENCE-BOOK.1.2.23.4.16'
CORE = ('Status', 'Goal', 'Acceptance', 'Dependencies', 'Children', 'Parent',
        'Verification tier', 'Focused checks', 'Canonical trigger', 'Claim verification',
        'Commit', 'Commit subject', 'Planned verification tier', 'Planned focused checks',
        'Planned canonical trigger', 'Planned claim verification', 'Superseded by')


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def recover(path, identities=None):
    found = {}
    with tarfile.open(path) as archive:
        for member in archive:
            name = member.name
            assert member.isfile() and not name.startswith('/') and '..' not in Path(name).parts and name not in found
            raw = archive.extractfile(member).read()
            if identities is not None:
                expected = identities[name]
                assert len(raw) == expected['bytes'] and digest(raw) == expected['sha256'], 'artifact identity'
                assert member.mode & 0o777 == expected['mode']
            found[name] = raw
    if identities is not None:
        assert found.keys() == identities.keys()
    return found


def sections(raw):
    # Deliberately independent line-state oracle: both legacy and canonical
    # frontier casing are semantic boundaries, unlike the frozen producer.
    prefix, nodes, tail = b'', {}, b''
    current = None
    for line in raw.splitlines(keepends=True):
        if tail or line.lower() == b'## current frontier\n':
            tail += line
            current = None
            continue
        match = re.fullmatch(rb'- ID: `([^`]+)`\n', line)
        if match:
            current = match[1].decode()
            assert current not in nodes
            nodes[current] = line
        elif current is None:
            prefix += line
        else:
            nodes[current] += line
    assert prefix + b''.join(nodes.values()) + tail == raw
    return prefix, nodes, tail


def fields(raw):
    result, label = {}, None
    for line in raw.splitlines(keepends=True)[1:]:
        match = re.match(rb'  ([A-Za-z][A-Za-z /()-]*):', line)
        if match:
            label = match[1].decode()
            if label in CORE:
                assert label not in result
                result[label] = line
        elif label in CORE and line.startswith((b'    ', b'\t')):
            result[label] += line
        else:
            label = None
    return result


def validate(original, current, manifest):
    assert isinstance(manifest, dict) and manifest['epoch'] == EPOCH
    assert manifest['source_commit'] == ACTIVATION and manifest['source_path'] == SOURCE
    assert manifest['sha256'] == digest(original) and manifest['bytes'] == len(original), 'source identity'
    assert manifest['lines'] == original.count(b'\n')
    old_prefix, before, old_tail = sections(original)
    new_prefix, after, new_tail = sections(current)
    assert old_tail and new_tail == old_tail, 'exact legacy current tail'
    assert old_prefix == new_prefix, 'prefix preservation'
    assert list(before) == list(after), 'stable ID preservation'
    selected = manifest['selected']
    assert isinstance(selected, list) and selected == sorted(set(selected)) and set(selected) <= before.keys()
    for key, old in before.items():
        assert fields(old) == fields(after[key]), 'complete CORE preservation'
        if key not in selected:
            assert old == after[key], 'short unselected body preservation'
            continue
        assert fields(old)['Status'].startswith(b'  Status: `done`')
        pointer = (f'  Narrative epoch: `{EPOCH}`; exact accepted source via '
                   f'`bash tools/run_python_project_data.sh tools/read_task_narrative.py '
                   f'--tree LUA-BACKEND-PARITY --epoch {EPOCH} --id {key}`.\n\n').encode()
        expected = old.splitlines(keepends=True)[0] + b''.join(fields(old).values()) + pointer
        assert after[key] == expected, 'exact selected current body'
    return before, after, old_tail


def main():
    for name, expected in json.loads((BASE / 'sealed-identities.json').read_bytes()).items():
        raw = (ROOT / name).read_bytes()
        assert len(raw) == expected['bytes'] and digest(raw) == expected['sha256'], 'sealed artifact identity'
    first_ids = json.loads((BASE / 'first/input-identities.json').read_bytes())
    inputs = recover(BASE / 'first/inputs-before-first-migration.tar.gz', first_ids)
    first = recover(BASE / 'first/actual-migrated-images.tar.gz', json.loads((BASE / 'first/migrated-identities.json').read_bytes()))
    qualified_inputs = recover(BASE / 'qualified/inputs-before-first-restoration.tar.gz', json.loads((BASE / 'qualified/input-identities.json').read_bytes()))
    qualified = recover(BASE / 'qualified/actual-qualified-images.tar.gz')
    original, initial, current = inputs[SOURCE], first[SOURCE], qualified[SOURCE]
    assert original == subprocess.check_output(['git', 'show', ACTIVATION + ':' + SOURCE], cwd=ROOT)
    for name in ('tools/task_narrative.py', 'tools/migrate_task_narrative.py', 'tools/read_task_narrative.py'):
        assert inputs[name] == qualified_inputs[name] == subprocess.check_output(['git', 'show', ACTIVATION + ':' + name], cwd=ROOT)
    assert qualified_inputs[SOURCE] == initial
    assert first[MANIFEST] == qualified_inputs[MANIFEST] == qualified[MANIFEST]
    manifest = json.loads(first[MANIFEST])
    assert manifest['source_blob'] == subprocess.check_output(['git', 'rev-parse', ACTIVATION + ':' + SOURCE], cwd=ROOT).decode().strip()
    before, after, tail = validate(original, current, manifest)
    assert current == initial + tail, 'qualified restoration only'
    denials = []

    def deny(name, action, reason):
        try:
            action()
        except AssertionError as error:
            assert reason in str(error), (name, 'unrelated failure', str(error))
            denials.append(name)
        else:
            raise AssertionError('corruption accepted: ' + name)

    deny('actual-first-tail-loss', lambda: validate(original, initial, manifest), 'exact legacy current tail')
    deny('changed-Goal', lambda: validate(original, current.replace(b'  Goal:', b'  Goal: LOST', 1), manifest), 'complete CORE preservation')
    key = manifest['selected'][0]
    deny('missing-current-ID', lambda: validate(original, current.replace(after[key], b'', 1), manifest), 'stable ID preservation')
    short = next(k for k in before if k not in manifest['selected'])
    changed = current.replace(after[short], after[short] + b'  Evidence: CHANGED\n', 1)
    deny('changed-short-body', lambda: validate(original, changed, manifest), 'short unselected body preservation')
    wrong_manifest = copy.deepcopy(manifest)
    wrong_manifest['sha256'] = '0' * 64
    deny('forged-source-hash', lambda: validate(original, current, wrong_manifest), 'source identity')
    original_generic_last = original[original.index(b'- ID: `LUA-BACKEND-PARITY.8.4`\n'):]

    def query_values(whole, node):
        assert whole == original, 'complete source query'
        assert node == original_generic_last, 'retained legacy node-query limitation'

    for directory in ('first', 'qualified'):
        root = BASE / directory
        commands = json.loads((root / 'commands.json').read_bytes())
        for name, command in commands.items():
            expected = 1 if name == 'before-query' else 0
            assert int((root / (name + '-exit.txt')).read_text()) == expected == command['expected_exit']
            stderr = gzip.decompress((root / (name + '-stderr.log.gz')).read_bytes())
            assert stderr == (b'epoch input is missing\n' if expected else b'')
        for name, prefix in (('narrative', b'task-narrative: PASS '),
                             ('unicode-owner', b'unicode-case-contract: OK '),
                             ('capability-owners', b'capability-conformance: OK '),
                             ('closure-owners', b'language closure structure/policy: ')):
            assert gzip.decompress((root / (name + '-stdout.log.gz')).read_bytes()).startswith(prefix)
        whole = gzip.decompress((root / 'whole-query-stdout.log.gz').read_bytes())
        node = gzip.decompress((root / 'node-query-stdout.log.gz').read_bytes())
        query_values(whole, node)
    deny('truncated-full-query', lambda: query_values(original[:-1], original_generic_last), 'complete source query')
    semantic_last = before['LUA-BACKEND-PARITY.8.4']
    deny('rewritten-historical-node-query', lambda: query_values(original, semantic_last), 'retained legacy node-query limitation')
    assert tail in original_generic_last and len(semantic_last) < len(original_generic_last)
    red = json.loads((BASE / 'qualified/boundary-before.json').read_bytes())
    green = json.loads((BASE / 'qualified/boundary-after.json').read_bytes())
    assert red['result'] == 'RED' and red['actual_tail_present'] is False
    assert green['result'] == 'GREEN' and green['restored_tail']['sha256'] == digest(tail)
    assert green['source_bytes_renewed'] == len(original) - len(current)
    first_stdout = gzip.decompress((BASE / 'first/migration-stdout.log.gz').read_bytes())
    assert first_stdout == (f'LUA-BACKEND-PARITY retained {len(before)} IDs; {len(manifest["selected"])} closed narratives; '
                            f'{len(original)-len(initial)} bytes renewed; source {ACTIVATION}\n').encode()
    for name, expected in json.loads((BASE / 'qualified/dependency-identities.json').read_bytes()).items():
        raw = (ROOT / name).read_bytes()
        assert len(raw) == expected['bytes'] and digest(raw) == expected['sha256']
    return dict(result='PASS', current_ids=len(before), archived_closed=len(manifest['selected']),
                unchanged_short_bodies=len(before)-len(manifest['selected']),
                legacy_tail_bytes=len(tail), qualified_bytes_renewed=len(original)-len(current),
                effective_denials=denials, original_phase='semantic RED despite passing metadata',
                limit='Generic legacy node-query/boundary repair remains TYPE-REFERENCE-BOOK.1.2.23.4.17; no runtime/Lua5.4 admission')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
