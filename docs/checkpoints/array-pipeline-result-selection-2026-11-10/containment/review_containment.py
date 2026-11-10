"""Recover exact rejected task bodies and verify only new prose was compacted."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[3]
REL = BASE.relative_to(ROOT)


def validate(before, after, marker, extra_ids=()):
    assert before.split(marker)[0] == after.split(marker)[0]
    ids = lambda body: re.findall(r'^- ID: `([^`]+)`$', body, re.M)
    assert ids(after) == ids(before) + list(extra_ids)
    old_statuses = re.findall(r'^  Status: `([^`]+)`', before, re.M)
    new_statuses = re.findall(r'^  Status: `([^`]+)`', after, re.M)
    assert new_statuses[:len(old_statuses)] == old_statuses


def check():
    packet = json.loads((BASE / 'before.json').read_bytes())
    originals = {}
    for name, row in packet['sources'].items():
        body = gzip.decompress((ROOT / row['capture']).read_bytes())
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        originals[name] = body.decode()
    overview = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
    helpers = 'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'
    selection = '- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.39`\n'
    family = '- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.79`\n'
    after_overview = (ROOT / overview).read_text()
    after_helpers = (ROOT / helpers).read_text()
    validate(originals[overview], after_overview, selection, ('TYPE-REFERENCE-BOOK.1.2.23.4.21',))
    validate(originals[helpers], after_helpers, family)
    old_header = originals[overview].split(selection)[1].split('  Activation:')[0]
    assert after_overview.split(selection)[1].split('  Activation:')[0] == old_header
    result = json.loads((BASE / 'compaction-result.json').read_bytes())
    contract = ROOT / 'docs/checkpoints/type-operation-inventory/array-pipeline-result-guard-composition.md'
    contract_body = contract.read_bytes()
    assert hashlib.sha256(contract_body).hexdigest() == result['unchanged_contract_sha256']
    assert str(contract.relative_to(ROOT)) + ' in full' in after_helpers
    assert after_helpers.count('Acceptance: Parent79 contract in full on ') == 5
    for row in map(json.loads, (ROOT / 'docs/tasks/TYPE-REFERENCE-BOOK.index.jsonl').read_text().splitlines()):
        if row['type'] == 'task_tree_part':
            body = (ROOT / row['path']).read_bytes()
            assert len(body) == row['byte_count'] and hashlib.sha256(body).hexdigest() == row['sha256']
    assert packet['head'] == subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    assert json.loads((BASE / 'stopped-attempt.json').read_bytes())['actual_commit_exit'] == 143
    assert b'aggregate bytes 12586933/12582912' in gzip.decompress((BASE / 'failed-hook.log.gz').read_bytes())
    controls = []

    def reject(name, operation):
        try:
            operation()
        except AssertionError:
            controls.append(name)
        else:
            raise AssertionError('ineffective preservation control: ' + name)

    reject('accepted prefix changed', lambda: validate(originals[helpers], 'X' + after_helpers[1:], family))
    reject('stable ID removed', lambda: validate(originals[helpers], after_helpers.replace('- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.79.5`', '- ID removed', 1), family))
    reject('status changed', lambda: validate(originals[helpers], after_helpers.replace('Status: `pending`', 'Status: `completed`', 1), family))
    def altered_contract():
        assert hashlib.sha256(contract_body + b'\n').hexdigest() == result['unchanged_contract_sha256']
    reject('canonical requirement bytes changed', altered_contract)
    print(json.dumps(dict(preservation='PASS', effective_controls=controls,
        limits='Exact new-prose containment and declared canonical requirements; future lossless headroom renewal remains4.21.')))


if __name__ == '__main__':
    if sys.argv[1:] == ['--check']:
        check()
    else:
        assert not sys.argv[1:]
        target = BASE / 'preservation-command.json'; assert not target.exists()
        source = Path(__file__).read_bytes()
        command = dict(cwd='.', argv=['bash', 'tools/run_python_project_data.sh', str(REL / 'review_containment.py'), '--check'],
            producer_sha256=hashlib.sha256(source).hexdigest())
        target.write_text(json.dumps(command, indent=2) + '\n')
        result = subprocess.run(command['argv'], cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        for channel in ('stdout', 'stderr'):
            (BASE / ('preservation-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
        (BASE / 'preservation-exit.txt').write_text(str(result.returncode) + '\n')
        assert result.returncode == 0 and result.stderr == b''
        assert Path(__file__).read_bytes() == source
        (BASE / 'preservation-result.json').write_bytes(result.stdout)
        print(result.stdout.decode(), end='')
