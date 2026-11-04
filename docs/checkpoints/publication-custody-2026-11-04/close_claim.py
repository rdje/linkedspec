"""Close only the two disclosed planning legs; preserve every other claim field."""
import argparse
import copy
import gzip
import hashlib
import json
from pathlib import Path

import model as m
import review

TARGET = m.ROOT / 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json'
BEFORE = m.HERE / 'preceding-claim.json.gz'


def expected(original):
    result = copy.deepcopy(original)
    claim, = [item for item in result['claims'] if item['name'] == 'publication-transport-plan']
    m.require(claim['falsify']['status'] == claim['durability']['status'] == 'gap', 'original gaps')
    claim['falsify'] = {
        'status': 'checked',
        'hypothesis': 'Raw object bytes equal packed transfer estimates, or a wrong/equal budget or broken range chain is silently admissible.',
        'oracle': 'Actual original counter/flat/thin call-output records versus current opaque Git object lengths; immutable first-parent endpoints independently validate range coverage. Isolated original split-function equality acceptance distinguishes the corrected strict predicate. Actual remote outcomes are separately retained dated observations.',
        'red_control': 'Publication-custody7 retains wrong-budget, equal-budget, Boolean-size, broken-chain, wrong-count and missing-tail refusals, plus actual original equality acceptance/current strict rejection. The recovered wrong raw counter is1173808; corrected actual count is19032710823. Initial pack estimates remain9308545338 non-thin and9304184386 thin, distinct from raw bytes and exact wire size. No oversized server upload was attempted.'}
    names = [m.HERE / name for name in (
        'source_capture.py', 'model.py', 'capture_runtime.py', 'review.py',
        'diagnose_overlap.py', 'preserve_failure.py', 'close_claim.py',
        'original-planner.sh.txt', 'original-planner.py.txt',
        'original-source-records.json.gz', 'capture-failure-01.json.gz',
        'object-overlap-diagnosis.json.gz', 'publication.json.gz')]
    names += [m.ROOT / name for name in ('tools/project_data_env.sh', 'tools/project_data_run.sh',
                                        'tools/run_python_project_data.sh')]
    claim['durability'] = {'status': 'checked', 'mode': 'live', 'inputs': [
        {'path': path.relative_to(m.ROOT).as_posix(),
         'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
         'role': 'producer' if path.suffix in ('.py', '.sh', '.txt') else 'input'}
        for path in sorted(names)]}
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    capture = json.loads(gzip.decompress(review.OUTPUT.read_bytes()))
    review.validate(capture)
    m.require(review.controls(capture) == capture['controls'], 'custody controls')
    if args.write:
        m.require(not BEFORE.exists(), 'claim closeout is one-shot')
        original = m.git('cat-file', 'blob', '1888c1bbfce267b02ea3ed288238ed6778fb5f5a:'
                         + TARGET.relative_to(m.ROOT).as_posix())
        m.require(TARGET.read_bytes() == original, 'preceding claim changed before closeout')
        BEFORE.write_bytes(gzip.compress(original, mtime=0))
        TARGET.write_text(json.dumps(expected(json.loads(original)), indent=2) + '\n')
    original = gzip.decompress(BEFORE.read_bytes())
    m.require(original == m.git('cat-file', 'blob', '1888c1bbfce267b02ea3ed288238ed6778fb5f5a:'
                               + TARGET.relative_to(m.ROOT).as_posix()), 'preceding byte preservation')
    m.require(json.loads(TARGET.read_bytes()) == expected(json.loads(original)),
              'only the two disclosed legs may change')
    print('publication-claim-closeout: PASS; all other original fields preserved')


if __name__ == '__main__':
    main()
