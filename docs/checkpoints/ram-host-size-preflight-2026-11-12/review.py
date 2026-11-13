"""Recover the historical RAM proof without rerunning OS or command producers."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REVISION = 'b370de8d31e3f38da6abf8ed4702a523aa3d6d97'


def read(name):
    return (BASE / name).read_bytes()


def decoded(name):
    return gzip.decompress(read(name))


def archive(name, identities=None):
    result = {}
    with tarfile.open(BASE / name) as source:
        for member in source:
            assert member.isfile() and member.name not in result
            raw = source.extractfile(member).read()
            if identities is not None:
                row = identities[member.name]
                assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
                assert member.mode & 0o777 == row['mode']
            result[member.name] = raw
    if identities is not None:
        assert result.keys() == identities.keys()
    return result


def validate(model):
    native = model['native']
    capacity = int(re.search(rb'^The system has ([0-9]+) ', native['pressure'], re.M)[1])
    page = int(re.search(rb'^Mach Virtual Memory Statistics: \(page size of ([0-9]+) bytes\)$', native['vm'], re.M)[1])
    counts = [int(re.findall(rb'^Pages ' + name + rb':\s+([0-9]+)\.$', native['vm'], re.M)[0])
              for name in (b'free', b'inactive', b'speculative')]
    expected = 100 - sum(counts) * page * 100 // capacity
    report = native['result']
    assert (capacity, page, counts, expected, native['output']) == (
        report['capacity_bytes'], report['page_size'], report['available_page_counts'],
        report['observed_used_percent'], expected), 'native snapshot arithmetic'
    assert native['sysctl_exit'] == report['sysctl_exit'] == 1 and native['vm_calls'] == report['vm_stat_calls'] == 1, 'native query routing'
    old = model['legacy']
    assert old['code'] == 0 and old['child_ran'] and old['calls'].count('vm_stat') == 3 and 'RAM 25% used' in old['stdout'], 'original distinguishing RED'
    rows = model['controls']
    codes = [0, 0, 77, 19, 0, 0, 0, 77, 77, 77, 77, 77, 77, 77, 77, 77, 0, 0, 0, 0, 77, 77, 77, 77]
    assert len(rows) == len(codes) and [row['code'] for row in rows] == codes, 'deterministic case outcomes'
    for index, row in enumerate(rows):
        assert row['child_ran'] == (row['code'] != 77), 'child boundary'
        vm = 0 if index in (7, 8) or index >= 18 else 1
        fallback = 0 if index in (1, 17) or index >= 18 else 1
        assert row['calls'].count('vm_stat') == vm and row['calls'].count('memory_pressure') == fallback, 'single snapshot and fallback controls'
    for index, value in {0:50, 1:50, 2:50, 3:50, 4:50, 5:50, 6:50, 15:100, 16:0, 17:67, 18:50, 19:67}.items():
        assert f'RAM {value}% used' in rows[index]['stdout'] + rows[index]['stderr'], 'independent arithmetic cases'
    original = model['original_claim']
    wanted = copy.deepcopy(original)
    selected = next(row for row in wanted['claims'] if row['name'] == 'backend-task-evidence-path-scope')
    assert selected['durability']['mode'] == 'live' and 'revision' not in selected['durability']
    selected['durability'].update(mode='historical', revision=REVISION)
    assert json.dumps(model['preserved_claim'], sort_keys=True) == json.dumps(wanted, sort_keys=True), 'only original mode and revision change'


def main():
    sealed = json.loads(read('sealed-identities.json'))
    for name, row in sealed.items():
        path = BASE / name
        raw = path.read_bytes()
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
        assert path.stat().st_mode & 0o777 == row['mode']
    before = archive('before/inputs-before-use.tar.gz', json.loads(read('before/input-identities.json')))
    original_wrapper = subprocess.check_output(['git', 'show', REVISION + ':tools/ram_guard.sh'], cwd=ROOT)
    assert before['tools/ram_guard.sh'] == original_wrapper
    archive('proofs/source-bound-controls/inputs-before-use.tar.gz', json.loads(read('proofs/source-bound-controls/input-identities.json')))
    native_inputs = archive('native-usage/inputs-before-use.tar.gz', json.loads(read('native-usage/input-identities.json')))
    assert b'17179869184' not in native_inputs['tools/host_ram_usage.sh']
    assert read('before/original-denial-red-exit.txt').strip() == b'1'
    assert b'admission/child exit' in decoded('before/original-denial-red-stderr.gz')
    assert read('proofs/source-bound-controls/exit.txt').strip() == b'0' and not decoded('proofs/source-bound-controls/stderr.gz')
    assert read('native-usage/helper-exit.txt').strip() == b'0' and not decoded('native-usage/helper-stderr.gz')
    assert read('native-usage/memory_pressure.exit.txt').strip() == b'0' and read('native-usage/vm_stat.exit.txt').strip() == b'0'
    model = dict(native=dict(pressure=decoded('native-usage/memory_pressure.stdout.gz'),
        vm=decoded('native-usage/vm_stat.stdout.gz'), result=json.loads(read('native-usage/result.json')),
        output=int(decoded('native-usage/helper-stdout.gz')), sysctl_exit=int(read('native-usage/sysctl.exit.txt')),
        vm_calls=len(list((BASE / 'native-usage').glob('vm_stat.command.json')))),
        legacy=json.loads(decoded('before/original-denial-red-stdout.gz').splitlines()[0]),
        controls=[json.loads(line) for line in decoded('proofs/source-bound-controls/stdout.gz').splitlines() if line.startswith(b'{')],
        original_claim=json.loads(decoded('claim-preservation/original-claim.json.gz')),
        preserved_claim=json.loads(before['docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json']))
    validate(model)
    original = model['original_claim']
    assert original == json.loads(subprocess.check_output(['git', 'show', REVISION + ':docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json'], cwd=ROOT))
    leg = next(row for row in original['claims'] if row['name'] == 'backend-task-evidence-path-scope')['durability']
    for row in leg['inputs']:
        raw = subprocess.check_output(['git', 'show', REVISION + ':' + row['path']], cwd=ROOT)
        assert hashlib.sha256(raw).hexdigest() == row['sha256']
    rejected = []
    controls = [
        ('wrong-native-output', 'native snapshot arithmetic', lambda m: m['native'].update(output=m['native']['output'] + 1)),
        ('wrong-native-capacity', 'native snapshot arithmetic', lambda m: m['native']['result'].update(capacity_bytes=17179869184)),
        ('duplicate-native-snapshot', 'native query routing', lambda m: m['native'].update(vm_calls=2)),
        ('erase-original-admission', 'original distinguishing RED', lambda m: m['legacy'].update(child_ran=False)),
        ('omit-control', 'deterministic case outcomes', lambda m: m['controls'].pop()),
        ('accept-denial', 'deterministic case outcomes', lambda m: m['controls'][2].update(code=0)),
        ('repeat-snapshot', 'single snapshot and fallback controls', lambda m: m['controls'][0]['calls'].append('vm_stat')),
        ('wrong-historical-revision', 'only original mode and revision change', lambda m: m['preserved_claim']['claims'][0]['durability'].update(revision='0' * 40)),
    ]
    for name, reason, change in controls:
        changed = copy.deepcopy(model)
        change(changed)
        try:
            validate(changed)
        except AssertionError as error:
            assert str(error) == reason
            rejected.append(name)
        else:
            raise AssertionError('ineffective control: ' + name)
    print(json.dumps(dict(result='PASS', original_claim_inputs=len(leg['inputs']), rejected_controls=rejected,
        scope='Historical finite controls and actual native availability snapshot, not current identity, physical native closure, live trend or canonical admission.')))


if __name__ == '__main__':
    main()
