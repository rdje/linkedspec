"""Retain the complete first numeric draft and actual rejected admission before bound writes."""
import gzip
import json
import subprocess
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'type-numeric-codeblocks'))
import common as c

PREFIX = 'docs/checkpoints/type-numeric-admission/'
MUTABLE = (
    'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'MEMORY.md',
    'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md',
    'docs/tasks/SESSION-STARTUP-READING.50-99.md', 'docs/tasks/SESSION-STARTUP-READING.index.jsonl',
    'docs/checkpoints/type-numeric-codeblocks/README.md', 'docs/claims/TYPE-REFERENCE-BOOK.1.2.5.json',
)


def write(name, value):
    raw = (json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n').encode()
    if name.endswith('.gz'):
        raw = gzip.compress(raw, mtime=0)
    with (c.ROOT / (PREFIX + name)).open('xb') as output:
        output.write(raw)


def main():
    manifest = c.load('publication-inputs.json')
    assert c.unchanged(manifest['inputs'])
    log = '.linkedspec-data/verification/type-numeric-canonical1-readonly.'
    baseline = {name: c.read(log + name) for name in ('log', 'status')}
    assert c.decode(baseline['status']['base64']).strip() == b'0'
    assert b'10142 closed inputs;318 GREEN;169 accepted RED;13 faults' in c.decode(baseline['log']['base64'])
    raw = subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index', c.BASE], cwd=c.ROOT)
    packed = gzip.compress(raw, mtime=0)
    parts = {}
    for index, offset in enumerate(range(0, len(packed), 16 * 1024 * 1024), 1):
        path = PREFIX + 'canonical1-candidate.part%03d.gzpart' % index
        chunk = packed[offset:offset + 16 * 1024 * 1024]
        with (c.ROOT / path).open('xb') as output:
            output.write(chunk)
        parts[path] = dict(**c.identity(path), size=len(chunk))
    recovered = b''.join((c.ROOT / path).read_bytes() for path in parts)
    assert recovered == packed and gzip.decompress(recovered) == raw
    use = c.run(['git', 'apply', '--check', '--reverse', '--binary', '-'], input=gzip.decompress(recovered))
    assert use['returncode'] == 0 and not c.decode(use['stderr_base64'])
    owner = c.run(['perl', 'tools/check_task_verification_fields.pl', '--owner'])
    assert owner['returncode'] != 0
    assert b'found 2 [SESSION-STARTUP-READING.87.3, TYPE-REFERENCE-BOOK.1.2.5]' in c.decode(owner['stderr_base64'])
    assert c.unchanged(manifest['inputs'])
    write('canonical1.json.gz', dict(base=c.BASE, producer=c.read(PREFIX + 'preserve.py'),
        primitives=c.read(c.PREFIX + 'common.py'),
        original={name: c.read(c.PREFIX + name) for name in ('publication-inputs.json', 'publication.json')},
        claim=c.read('docs/claims/TYPE-REFERENCE-BOOK.1.2.5.json'),
        inputs=manifest['inputs'], before={path: c.read(path) for path in MUTABLE}, baseline=baseline,
        canonical={name: c.read('.linkedspec-data/verification/type-numeric-canonical1.' + name)
                   for name in ('log', 'status')}, owner_red=owner,
        candidate=dict(parts=parts, raw_sha256=c.sha(raw), raw_bytes=len(raw), packed_sha256=c.sha(packed),
                       packed_bytes=len(packed), reverse_check=use),
        scope='Whole first uncommitted numeric claim, publication, closed10142 inputs/full modes and actual '
              'default readonly0, plus complete rejected staged binary patch against real203cde315. '
              'New admission preparation files are outside the original fixed input population. '
              'No clean accepted commit or fictional draft revision is claimed. Exact candidate parts '
              'reconstruct and pass the real Git reverse-apply check; no tracked source is changed.'))
    print('First numeric draft preserved:10142 inputs/full modes; readonly0; two-owner RED;',
          len(parts), 'candidate parts;', len(packed), 'packed bytes; reverse check0')


if __name__ == '__main__':
    main()
