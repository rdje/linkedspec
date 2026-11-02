"""Retain and review the fail-fast canonical execution prerequisite."""
import argparse
import base64
import copy
import gzip
import hashlib
from html.parser import HTMLParser
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
SOURCE = 'tools/run_ci_local.sh'
ORACLE = 'tools/test_project_data_process_locality.sh'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
BLOCK = b'''if [[ "$(uname -s)" == Darwin ]]; then
 log "checking macOS sandbox initialization required by process locality"
 /usr/bin/sandbox-exec -p '(version 1) (allow default)' /usr/bin/true ||
  fail "macOS sandbox initialization denied; rerun this complete staged candidate in approved host execution (docs/knowledge/project-data-process-locality-proof.md)"
fi

'''


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'execution packet identity'
    return raw


def validate_source(before, after):
    assert after.count(BLOCK) == 1 and after.replace(BLOCK, b'', 1) == before, 'unreviewed CI source evolution'
    assert after.index(BLOCK) < after.index(b'log "running the general doctrine enforcer'), 'late prerequisite'


def validate_observations(saved):
    assert type(saved['restricted_noop']['exit']) is int and saved['restricted_noop']['exit'] == 71
    assert b'sandbox_apply: Operation not permitted' in decode(saved['restricted_noop']['stderr'])
    assert type(saved['early']['exit']) is int and saved['early']['exit'] == 1
    early = decode(saved['early']['output'])
    assert b'checking macOS sandbox initialization required by process locality' in early
    assert b'macOS sandbox initialization denied' in early
    assert b'running the general doctrine enforcer' not in early, 'expensive checks reached after denial'
    for kind in ('host_noop', 'host_process', 'book_build'):
        assert type(saved[kind]['exit']) is int and saved[kind]['exit'] == 0, kind
    process = decode(saved['host_process']['stdout'])
    assert b'relocated six-family driver passed' in process
    assert b'PASS: relocated Perl/Rust/Dart/Julia/Lua/tool IO is repository-contained' in process
    assert b'HTML book written to' in (decode(saved['book_build']['stdout']) + decode(saved['book_build']['stderr']))


def run(args):
    result = subprocess.run(args, cwd=ROOT, capture_output=True)
    return dict(args=args, exit=result.returncode, stdout=packet(result.stdout), stderr=packet(result.stderr))


def capture():
    destination = HERE / 'execution-evidence.json.gz'
    assert not destination.exists(), 'never overwrite completed execution epochs'
    scratch = ROOT / '.linkedspec-data/normal-hook-restoration'
    host_noop = run(['/usr/bin/sandbox-exec', '-p', '(version 1) (allow default)', '/usr/bin/true'])
    assert host_noop['exit'] == 0, 'capture requires approved host execution'
    host_process = run(['bash', ORACLE])
    assert host_process['exit'] == 0, host_process
    book_build = run(['bash', 'tools/run_mdbook_local.sh'])
    assert book_build['exit'] == 0, book_build
    names = [SOURCE, ORACLE, BOOK, 'docs/linkedspec-book/book.toml', 'tools/run_mdbook_local.sh',
             'TOOLBOX.md', 'SESSION_BOOTSTRAP.md', 'docs/knowledge/project-data-process-locality-proof.md',
             'tools/project_data_run.sh', 'tools/project_data_env.sh', 'tools/run_python_project_data.sh',
             'tests/language-readiness/verify_objectives.py', str(Path(__file__).relative_to(ROOT)),
             'docs/checkpoints/document-pressure-restoration/capture_execution_intake.py']
    saved = dict(owner='TYPE-REFERENCE-BOOK.1.2.20.1.20',
                 inputs={n: packet((ROOT / n).read_bytes()) for n in names},
                 intake_sha256=hashlib.sha256((HERE / 'execution-intake.json.gz').read_bytes()).hexdigest(),
                 restricted_noop=dict(exit=int((scratch / 'execution-restricted-noop.status').read_text()),
                                      stderr=packet((scratch / 'execution-restricted-noop.log').read_bytes())),
                 early=dict(exit=int((scratch / 'execution-early-preflight.status').read_text()),
                            output=packet((scratch / 'execution-early-preflight.log').read_bytes())),
                 staging_preparation=dict(exit=int((scratch / 'execution-staging-preparation.status').read_text()),
                                          output=packet((scratch / 'execution-staging-preparation.log').read_bytes())),
                 host_noop=host_noop, host_process=host_process, book_build=book_build,
                 rendered=packet((ROOT / 'docs/linkedspec-book/book/development/documentation-workflow.html').read_bytes()),
                 limits='Actual restricted initialization and early canonical rejection versus host initialization and unchanged six-family containment oracle. Initial unstaged-candidate trial is rejected setup, without guard or product RED credit. Historical integrity and full canonical receipt remain separate. Observed rendered guidance does not close transitive mdBook-generator inputs or admit broader runtime compatibility.')
    validate_observations(saved)
    destination.write_bytes(gzip.compress(json.dumps(saved, sort_keys=True, separators=(',', ':')).encode(), mtime=0))


def review():
    intake_raw = (HERE / 'execution-intake.json.gz').read_bytes()
    intake = json.loads(gzip.decompress(intake_raw))
    saved = json.loads(gzip.decompress((HERE / 'execution-evidence.json.gz').read_bytes()))
    assert hashlib.sha256(intake_raw).hexdigest() == saved['intake_sha256']
    for name, row in saved['inputs'].items():
        observed, retained = (ROOT / name).read_bytes(), decode(row)
        if name == 'tests/language-readiness/verify_objectives.py' and observed != retained:
            from phase0_evidence import validate_auditor_evolution
            validate_auditor_evolution(retained, observed)
        elif name == str(Path(__file__).relative_to(ROOT)):
            from phase0_evidence import validate_execution_reader_evolution
            validate_execution_reader_evolution(retained, observed)
        else:
            assert observed == retained, 'execution input drift: ' + name
    before, after = decode(intake['inputs'][SOURCE]), decode(saved['inputs'][SOURCE])
    validate_source(before, after)
    assert decode(intake['inputs'][ORACLE]) == decode(saved['inputs'][ORACLE]), 'containment oracle changed'
    baseline = decode(intake['failure'])
    assert b'doctrines: ALL 10 enforced doctrines PASS' in baseline
    assert b'[tool-project-data-test] PASS' in baseline
    assert b'sandbox-exec: sandbox_apply: Operation not permitted' in baseline
    assert saved['staging_preparation']['exit'] != 0
    assert b'unstaged tracked changes exist' in decode(saved['staging_preparation']['output'])
    validate_observations(saved)
    for candidate in (after.replace(BLOCK, b'', 1), after.replace(BLOCK, BLOCK * 2, 1),
                      after.replace(b'== Darwin', b'== Linux', 1), after + b'# unreviewed\n'):
        assert candidate != after
        try:
            validate_source(before, candidate)
        except AssertionError:
            pass
        else:
            raise AssertionError('CI source mutation admitted')
    for kind in ('restricted_noop', 'early', 'host_noop', 'host_process', 'book_build'):
        changed = copy.deepcopy(saved)
        changed[kind]['exit'] = 99
        try:
            validate_observations(changed)
        except AssertionError:
            pass
        else:
            raise AssertionError('execution outcome corruption admitted: ' + kind)
    old_book, new_book = decode(intake['inputs'][BOOK]), decode(saved['inputs'][BOOK])
    assert new_book.startswith(old_book) and new_book[len(old_book):].startswith(b'\n### Canonical execution prerequisites on macOS\n')
    class Visible(HTMLParser):
        def __init__(self):
            super().__init__()
            self.parts = []
        def handle_data(self, data):
            self.parts.append(data)
    visible = Visible()
    visible.feed(decode(saved['rendered']).decode())
    text = ' '.join(''.join(visible.parts).split())
    assert 'Canonical execution prerequisites on macOS' in text
    assert 'CI runs this control before doctrines.' in text
    return dict(restricted_noop=71, host_noop=0, denied_canonical_stops_before_doctrines=True,
                unchanged_host_process_oracle='six-family PASS; original containment denials retained',
                source_mutations_rejected=4, outcome_mutations_rejected=5,
                rejected_staging_preparation='retained; no product RED credit', limits=saved['limits'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    if args.capture:
        capture()
    print(json.dumps(review(), sort_keys=True))
