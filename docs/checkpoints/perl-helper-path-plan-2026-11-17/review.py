"""Readonly recovery of the plan's Git inputs and preserved parent obligations."""
import hashlib
import json
from pathlib import Path
import re
import stat
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PARENT = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.1.1.2'
PART = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
frozen = {}
with tarfile.open(BASE / 'before.tar.gz') as archive:
    for member in archive:
        assert member.isfile() and member.name not in frozen
        assert not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
        frozen[member.name] = archive.extractfile(member).read()
        if member.name.endswith('publish.py'):
            assert frozen[member.name] == Path(member.name).read_bytes() and stat.S_IMODE(Path(member.name).stat().st_mode) == member.mode
original = {}
for name, row in json.loads((BASE / 'git-inputs.json').read_bytes()).items():
    actual = subprocess.check_output(['git', 'ls-tree', '-z', row['revision'], '--', name]).split(b'\0')[0]
    header, encoded = actual.split(b'\t', 1)
    mode, kind, blob = header.decode().split()
    assert encoded.decode() == name and mode == row['mode'] and kind == 'blob' and blob == row['blob']
    body = subprocess.check_output(['git', 'cat-file', 'blob', blob])
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
    original[name] = body


def node(text, owner):
    matches = list(re.finditer(r'(?m)^- ID: `' + re.escape(owner) + r'`\n', text))
    assert len(matches) == 1, 'unique plan node'
    start = matches[0].start(); end = text.find('\n- ID:', matches[0].end())
    return text[start:end if end >= 0 else None]


current = Path(PART).read_text()
for field in ('Goal', 'Acceptance', 'Continuation'):
    expression = r'(?m)^  ' + field + r': (.*)$'
    assert re.findall(expression, node(original[PART].decode(), PARENT)) == re.findall(expression, node(current, PARENT))
    assert re.findall(expression, node(frozen[PART].decode(), PARENT)) == re.findall(expression, node(current, PARENT))
assert '  Status: `active`' in node(current, PARENT)
assert '  Status: `completed`' in node(current, PARENT + '.0')
for suffix in ('.1', '.2', '.3', '.4'):
    assert '  Status: `pending`' in node(current, PARENT + suffix)
assert '| 1 | `' + PARENT + '.1` | `pending`' in Path('docs/tasks/TYPE-REFERENCE-BOOK.md').read_text()
assert 'latest_completed_leaf: `' + PARENT + '.0`' in Path('MEMORY.md').read_text()
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
assert size['head'] == '7354d156f40c492e84c7992578a699e2e77ad7ba'
assert size['early_push_trigger_bytes'] - size['estimated_non_thin_pack_bytes'] == size['remaining_to_trigger_bytes']
print(json.dumps(dict(result='PASS', parent_obligations_preserved=True, bounded_children_ordered=True,
    current_frontier_agrees=True, git_inputs_recover=True,
    limits='Plan and retained telemetry consistency only. No new source/runtime classification, independent pack-size/native/physical closure or admission.'), sort_keys=True))
