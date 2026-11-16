"""Synchronize roadmap pointers and retain exact public task queries."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
pointer = b'November16 current PNT frontier: Canonical-discovery plan TYPE-REFERENCE-BOOK.1.2.23.4.1.0 is complete. Inventory4.1.1 precedes exact registration/source admission/canonical4.1.2 and publication30.2 after every independent before-push owner. No runner, runtime, fixture or admission change is claimed.\n\n'
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    old = path.read_bytes()
    assert pointer not in old, 'one-shot roadmap pointer'
    if name == 'ROADMAP_V2.md':
        title = b'# ROADMAP V2\n\n'
        assert old.startswith(title)
        new = title + pointer + old[len(title):]
    else:
        new = pointer + old
    path.write_bytes(new)
    assert new.replace(pointer, b'', 1) == old

for suffix in ('4.1', '4.1.0', '4.1.1', '4.1.2'):
    identity = 'TYPE-REFERENCE-BOOK.1.2.23.' + suffix
    command = ['perl', 'tools/read_task_tree.pl', '--tree', 'TYPE-REFERENCE-BOOK', '--id', identity]
    output = BASE / ('query-' + suffix)
    assert not output.with_suffix(output.suffix + '.command.json').exists()
    (BASE / ('query-' + suffix + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (BASE / ('query-' + suffix + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (BASE / ('query-' + suffix + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0 and result.stderr == b''
    assert ('- ID: `' + identity + '`\n').encode() in result.stdout
print('roadmap pointers synchronized and public task queries retained')
