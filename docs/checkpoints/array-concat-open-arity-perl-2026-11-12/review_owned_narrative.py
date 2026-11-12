"""Independent exact current-leaf narrative routing recovery; no SDK execution."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-concat-open-arity-perl-2026-11-12')
OUT = BASE / 'landing-pressure'
PART = 'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'
MARK = '- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.80.1`'


def verify(before, after):
    b, a = before.decode(), after.decode()
    assert b.count(MARK) == a.count(MARK) == 1
    s, t = b.index(MARK), a.index(MARK)
    e, u = b.index('\n- ID:', s+1), a.index('\n- ID:', t+1)
    assert b[:s] == a[:t] and b[e:] == a[u:]
    old, new = b[s:e], a[t:u]
    assert old.splitlines()[:5] == new.splitlines()[:5]
    for field in ('Verification tier', 'Focused checks', 'Canonical trigger', 'Claim verification'):
        select = lambda text: [line for line in text.splitlines() if line.startswith('  '+field+':')]
        assert len(select(old)) == 1 and select(old) == select(new)
    check = lambda text: [line for line in text.splitlines() if line.startswith('  - [x] **')]
    assert len(check(old)) == 6 and check(old) == check(new)
    assert len(new.encode()) <= 4500 and len(old.encode()) - len(new.encode()) >= 10500
    assert 'Narrative:' in new and 'landing-pressure/' in new
    return old.encode(), len(before)-len(after)


def failure(raw):
    assert b'FAIL: surface task_evidence exceeds control: aggregate bytes 12590016/12582912' in raw
    assert raw.count(b'  PASS  ') == 9 and raw.count(b'  FAIL  README-STABILITY') == 1


def main():
    rows = json.loads((ROOT / OUT / 'input-identities.json').read_bytes())
    inputs = {}
    with tarfile.open(ROOT / OUT / 'inputs-before-route.tar.gz') as archive:
        for member in archive:
            assert member.isfile() and member.name not in inputs and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            raw = archive.extractfile(member).read(); row = rows[member.name]
            assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
            inputs[member.name] = raw
    assert inputs.keys() == rows.keys()
    for name in ('route_owned_narrative.py', 'review_owned_narrative.py'):
        path = str(BASE / name)
        assert (ROOT / path).read_bytes() == inputs[path]
    before = gzip.decompress((ROOT / OUT / 'part-before.md.gz').read_bytes())
    after = gzip.decompress((ROOT / OUT / 'part-after.md.gz').read_bytes())
    assert before == inputs[PART]
    old, routed = verify(before, after)
    assert old == gzip.decompress((ROOT / OUT / 'leaf-before.md.gz').read_bytes())
    log = gzip.decompress((ROOT / OUT / 'complete-first-hook.log.gz').read_bytes())
    assert log == inputs['.linkedspec-data/array-concat-open-arity-perl-commit.log']
    failure(log)
    report = json.loads((ROOT / OUT / 'result.json').read_bytes())
    assert report['bytes_routed'] == routed and report['excess_bytes'] == 7104 and report['observed_commit_exit'] == 1
    controls = []

    def reject(name, operation):
        try:
            operation()
        except (AssertionError, ValueError):
            controls.append(name)
        else:
            raise AssertionError('ineffective control: '+name)

    assert after.startswith(b'# TYPE-REFERENCE-BOOK')
    reject('outside own leaf changed', lambda: verify(before, b'!' + after[1:]))
    source = after.decode(); s = source.index(MARK); e = source.index('\n- ID:', s+1)
    leaf = source[s:e]
    for field in ('Goal:', 'Acceptance:', 'Focused checks:', 'Claim verification:'):
        assert field in leaf
        changed = source[:s] + leaf.replace(field, field+' changed', 1) + source[e:]
        reject(field+' lost', lambda changed=changed: verify(before, changed.encode()))
    assert b'TYPE-REFERENCE-BOOK.1.2.23.3.80.2' in after
    reject('future frontier changed', lambda: verify(before, after.replace(b'TYPE-REFERENCE-BOOK.1.2.23.3.80.2',b'changed-future')))
    reject('original failure hidden', lambda: failure(b''))
    assert len(controls) == 7
    return dict(recovery='PASS', bytes_routed=routed, contracts_and_other_nodes='EXACT', effective_corruptions=controls,
        scope='Own80.1 narrative only; retained source/log/candidate, no SDK replay or cap change. Broader headroom29 precedes Rust.')


if __name__ == '__main__':
    print(json.dumps(main(), indent=2))
