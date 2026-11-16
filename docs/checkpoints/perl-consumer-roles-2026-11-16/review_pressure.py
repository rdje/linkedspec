"""Recover the task-pressure repair against the immutable activation Git source."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import stat
import subprocess

BASE = Path(__file__).resolve().parent
PARENT = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1'
TASK = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')


def require(value, reason):
    if not value:
        raise ValueError(reason)


def validate(old, after, mode, record):
    require(hashlib.sha256(old).hexdigest() == record['activation_sha256'], 'activation identity')
    require(hashlib.sha256(after).hexdigest() == record['after_sha256'], 'after identity')
    require(mode == record['mode'] == 0o644, 'task mode')
    start = old.index(('- ID: `' + PARENT + '`\n').encode())
    end = old.index(b'\n- ID:', start + 1)
    parent = old[start:end].replace(b'Status: `pending`', b'Status: `active`', 1)
    parent = parent.replace(b'  Status: `active`\n', b'  Status: `active`\n  Children: `.0`, `.1` (ID suffixes).\n', 1)
    require(bytes.fromhex(record['original_parent']) == parent, 'original parent contract')
    nodes = bytes.fromhex(record['new_node']) + bytes.fromhex(record['pending_node'])
    require(after == old[:start] + parent + b'\n' + nodes + old[end:], 'older bytes preserved')
    require(len(after) - len(old) == record['added_task_bytes'] <= 700, 'bounded own delta')
    for suffix in ('.0', '.1'):
        require(after.count(('- ID: `' + PARENT + suffix + '`\n').encode()) == 1, 'new node uniqueness')


def main():
    record = json.loads((BASE / 'pressure.json').read_bytes())
    old = gzip.decompress((BASE / 'task-activation.gz').read_bytes())
    before = gzip.decompress((BASE / 'task-before.gz').read_bytes())
    after = gzip.decompress((BASE / 'task-after.gz').read_bytes())
    actual_old = subprocess.check_output(['git', 'show', '3f619e9c2aa74d0f3f8d9d64c2c90e82d11d81e0:' + str(TASK)])
    require(old == actual_old, 'immutable Git source')
    require(hashlib.sha256(before).hexdigest() == record['before_sha256'], 'rejected body retained')
    require(b'aggregate bytes 12588670/12582912' in gzip.decompress((BASE / 'first-normal.gz').read_bytes()), 'actual pressure refusal')
    validate(old, after, record['mode'], record)
    require(TASK.read_bytes() == after and stat.S_IMODE(TASK.stat().st_mode) == record['mode'], 'current task identity')
    controls = {}
    for kind in ('older-prefix', 'parent-contract', 'new-node', 'mode'):
        changed, metadata, mode = after, copy.deepcopy(record), record['mode']
        if kind == 'older-prefix':
            changed = b'!' + after[1:]
        elif kind == 'parent-contract':
            changed = after.replace(b'Goal: Complete remaining consumer/support/dormant/fixture roles', b'Goal: Omit remaining consumer/support/dormant/fixture roles', 1)
            require(changed != after, 'effective parent control')
        elif kind == 'new-node':
            changed = after.replace(b'Goal: Qualify Perl roles.', b'Goal: Unqualified roles.', 1)
        else:
            mode = 0o755
        metadata['after_sha256'] = hashlib.sha256(changed).hexdigest()
        try:
            validate(old, changed, mode, metadata)
        except ValueError as error:
            controls[kind] = dict(result='RED', reason=str(error))
        else:
            raise ValueError('control accepted: ' + kind)
    print(json.dumps(dict(result='PASS', added_task_bytes=record['added_task_bytes'],
                          original_contract_and_other_bytes='preserved', controls=controls), sort_keys=True))


if __name__ == '__main__':
    main()
