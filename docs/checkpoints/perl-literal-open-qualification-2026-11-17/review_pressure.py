"""Recover task-text repair and verify identity/ownership fields; no runtime claim."""
import argparse
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PART = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'


def unpack(label):
    sources = {}
    with tarfile.open(BASE / (label + '.tar.gz')) as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in sources
            sources[member.name] = (archive.extractfile(member).read(), stat.S_IMODE(member.mode))
    return sources


def core(body):
    result = {}
    for match in re.finditer(r'(?m)^- ID: `([^`]+)`\n', body.decode()):
        end = body.decode().find(chr(10) + '- ID:', match.end())
        node = body.decode()[match.start():end if end >= 0 else None]
        assert match[1] not in result
        result[match[1]] = {key: re.findall(r'(?m)^  ' + re.escape(key) + r': (.*)$', node)
            for key in ('Status', 'Verification tier', 'Claim verification')}
    return result


def same(before, after):
    assert set(before) == set(after), 'task ID population'
    assert before == after, 'task status/tier/claim binding'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--current', action='store_true')
    args = parser.parse_args()
    before, after = unpack('pressure-before'), unpack('pressure-after')
    ids = json.loads((BASE / 'pressure-before-identities.json').read_bytes())
    assert set(before) == set(ids)
    for name, (body, mode) in before.items():
        assert len(body) == ids[name]['bytes'] and hashlib.sha256(body).hexdigest() == ids[name]['sha256'] and mode == ids[name]['mode']
    original, current = core(before[PART][0]), core(after[PART][0])
    same(original, current)
    plan = json.loads((BASE / 'plan.json').read_bytes())
    parent = plan['owner'].rsplit('.', 1)[0]
    for key in ('Goal', 'Acceptance'):
        def field(body):
            text = body.decode(); start = text.index('- ID: `' + parent + '`' + chr(10)); end = text.index(chr(10) + '- ID:', start + 1)
            return re.findall(r'(?m)^  ' + key + r': (.*)$', text[start:end])
        assert field(before[PART][0]) == field(after[PART][0]), 'existing parent contract'
    controls = {}
    for label in ('task ID population', 'task status/tier/claim binding'):
        changed = copy.deepcopy(current)
        if label == 'task ID population':
            changed.pop(plan['owner'])
        else:
            changed[plan['owner']]['Status'] = ['`pending`']
        try:
            same(original, changed)
        except AssertionError as error:
            assert str(error) == label
            controls[label] = 'RED'
        else:
            raise AssertionError('task corruption accepted')
    assert b'aggregate bytes 12584262/12582912' in gzip.decompress((BASE / 'pressure-failed-normal.log.gz').read_bytes())
    assert sum(len(before[n][0]) - len(after[n][0]) for n in (PART, 'docs/tasks/TYPE-REFERENCE-BOOK.md')) > 1350
    if args.current:
        for name, (body, mode) in after.items():
            path = Path(name)
            assert not path.is_symlink() and path.read_bytes() == body and stat.S_IMODE(path.stat().st_mode) == mode
    print(json.dumps(dict(result='PASS', retained_original_detail=True, IDs_status_tier_claim_unchanged=True,
        existing_parent_contract_unchanged=True, controls=controls,
        limits='Task representation and source bindings only. This does not prove complete semantic equivalence or budget admission; fresh complete normal hooks remain required. Full native/first-use/per-read/physical closure remains4.2/SESSION5.'), sort_keys=True))


if __name__ == '__main__':
    main()
