"""Fold related receiver facts into their existing canonical card, preserving both bodies."""
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '5bf068c924f190fdc7b9f904b9b9720cc638f2e9'
FOLDER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2/'
ARRAY = 'docs/knowledge/perl-array-receiver-required-capture.md'
SCALAR = 'docs/knowledge/perl-scalar-receiver-required-capture.md'
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def split(raw):
    assert raw.startswith(b'---\n')
    end = raw.index(b'\n---\n', 4)
    return raw[4:end].decode(), raw[end + 5:]


def expected():
    old = subprocess.check_output(['git', 'show', BASE + ':' + ARRAY], cwd=ROOT)
    scalar = (ROOT / (FOLDER + 'original-scalar-card.md')).read_bytes()
    left, left_body = split(old)
    right, right_body = split(scalar)
    old_answers = left.split('answers:\n', 1)[1].split('\ndate:', 1)[0]
    new_answers = right.split('answers:\n', 1)[1].split('\ndate:', 1)[0]
    assert len(old_answers.splitlines()) == 7 and len(new_answers.splitlines()) == 6
    answers = old_answers + '\n' + new_answers
    assert len(set(answers.splitlines())) == 13
    left = left.replace('answers:\n' + old_answers + '\ndate:', 'answers:\n' + answers + '\ndate:', 1)
    left = re.sub(r'^title:.*$', 'title: Required array, number and string receiver callbacks preserve native effects', left, flags=re.M)
    left = re.sub(r'^status:.*$', 'status: focused receiver proof verified; related facts consolidated within the existing card limit', left, flags=re.M)
    evidence = lambda meta: json.loads(next(line.split(': ', 1)[1] for line in meta.splitlines() if line.startswith('evidence: ')))
    left = re.sub(r'^evidence:.*$', lambda match: 'evidence: ' + json.dumps(evidence(left) + ' Number/string boundary: ' + evidence(right)), left, flags=re.M)
    start = left.index('reverify:\n')
    left = left[:start] + ('reverify:\n'
        '  - "bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-publish-claim.py"\n'
        '  - "Earlier array proof requires accepted5bf068c92 Git inputs. Current original-publication replay supplies its exact logical inputs. Capture/freezer/fault/evidence writers are one-shot; native/runtime observations are never refreshed."')
    body = (b'\nThis stable card covers related required receiver callbacks. Earlier array proof\n'
            b'uses its accepted5bf068c92 input boundary; number/string proof and consolidation\n'
            b'have their separately retained instruments and limits.\n\n'
            b'## Array receiver callbacks\n' + left_body +
            b'\n## Number and string receiver callbacks\n' + right_body)
    combined = b'---\n' + left.encode() + b'\n---\n' + body
    assert left_body in combined and right_body in combined
    return old, scalar, combined


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--apply'])
    old, scalar, combined = expected()
    target = ROOT / (FOLDER + 'fold.json')
    if sys.argv[1:]:
        assert not target.exists(), 'one-shot consolidation already applied'
        assert json.loads((ROOT / (FOLDER + 'original-replay.json')).read_bytes())['result'] == 'PASS'
        assert (ROOT / ARRAY).read_bytes() == old and (ROOT / SCALAR).read_bytes() == scalar
        assert not subprocess.check_output(['git', 'ls-tree', BASE, '--', SCALAR], cwd=ROOT), 'new card was not an accepted old file'
        preserved = ROOT / (FOLDER + 'original-array-card.md')
        assert not preserved.exists()
        preserved.write_bytes(old)
        assert preserved.read_bytes() == old
        (ROOT / ARRAY).write_bytes(combined)
        assert (ROOT / ARRAY).read_bytes() == combined
        assert (ROOT / (FOLDER + 'original-scalar-card.md')).read_bytes() == scalar
        (ROOT / SCALAR).unlink()
        report = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
                  'old_array_sha256': sha(old), 'original_scalar_sha256': sha(scalar),
                  'combined_sha256': sha(combined), 'old_questions': 7, 'new_questions': 6,
                  'combined_questions': 13, 'original_scalar_preserved': True, 'new_card_removed': True,
                  'scope': 'Only the existing related receiver card is updated; both original bodies and all13 question rows are preserved. The original array card is also saved byte-exactly. Only the verified newly introduced scalar card is removed after copy/hash verification. Registry limits and runtime/book observations remain unchanged.'}
        target.write_text(json.dumps(report, indent=2) + '\n')
    else:
        report = json.loads(target.read_bytes())
        assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
        assert report['old_array_sha256'] == sha(old) and report['original_scalar_sha256'] == sha(scalar)
        assert report['combined_sha256'] == sha(combined) and report['combined_questions'] == 13
        assert (ROOT / (FOLDER + 'original-array-card.md')).read_bytes() == old
        assert (ROOT / ARRAY).read_bytes() == combined, 'combined receiver card identity'
        assert not (ROOT / SCALAR).exists(), 'redundant new card remains'
    print('Receiver fact consolidation PASS: existing card, both original bodies, all13 questions; no cap increase')
