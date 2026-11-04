"""Replay exact storage populations and distinguish identity checks from counts."""
import argparse
import base64
import gzip
import hashlib
from html.parser import HTMLParser
import json
import os
from pathlib import Path
import subprocess

from capture_storage_intake import populations

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
TOOL = 'tools/check_project_storage_inventory.pl'
MANIFESTS = ['doctrine/project_data_storage/' + kind + '.json' for kind in (
    'perl_temporary_owners', 'python_temporary_owners', 'python_entrypoints', 'shell_temporary_owners')]
SCRIPTS = ['tools/test_perl_project_data_storage.sh', 'tools/test_tool_project_data_storage.sh']


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'storage packet identity'
    return raw


def command(args, data=None, env=None):
    result = subprocess.run(args, cwd=ROOT, input=data, capture_output=True, env=env)
    return dict(args=args, exit=result.returncode, stdout=packet(result.stdout), stderr=packet(result.stderr))


def controls():
    rows = []
    for name in MANIFESTS:
        manifest = json.loads((ROOT / name).read_bytes())
        kind, owners = manifest['kind'], manifest['owners']
        args = ['perl', TOOL, '--kind', kind, '--stdin-owners']
        nul = lambda names: b''.join(os.fsencode(n) + b'\0' for n in names)
        cases = dict(healthy=nul(owners), reordered=nul(owners[::-1]),
                     missing=nul(owners[1:]), unexpected=nul(owners + ['tools/unreviewed-owner.py']),
                     replacement=nul(['tools/unreviewed-owner.py'] + owners[1:]),
                     duplicate=nul(owners + owners[:1]), truncated=nul(owners)[:-1],
                     empty_record=nul(owners) + b'\0', empty=b'')
        for label, data in cases.items():
            result = command(args, data)
            assert (result['exit'] == 0) == (label in ('healthy', 'reordered')), (kind, label, result)
            if label not in ('healthy', 'reordered'):
                assert any(marker in decode(result['stderr']) for marker in (
                    b'storage inventory mismatch', b'duplicate inventory path',
                    b'unterminated NUL inventory', b'invalid repository-relative inventory path'))
            rows.append(dict(kind=kind, case=label, input=packet(data), result=result))
        result = command(['perl', TOOL, '--kind', kind])
        assert result['exit'] == 0, result
        rows.append(dict(kind=kind, case='actual-source-census', result=result))
    # Run the actual frozen count-plus-seven-membership predicate on its original
    # population. A same-count replacement outside those seven passes it.
    intake = json.loads(gzip.decompress((HERE / 'storage-intake.json.gz').read_bytes()))
    old = decode(intake['current'][SCRIPTS[0]])
    predicate = old[old.index(b'(( ${#perl_temp_owners'):old.index(b"rg -q 'TMPDIR")]
    owners = intake['populations']['previous']['perl_temporary_owners']
    assert len(owners) == 29 and 't/generated_source_contract.t' in owners
    assert set(intake['populations']['current']['perl_temporary_owners']) == set(owners) | {'t/document_history_catalog.t'}
    replacement = [n if n != 't/generated_source_contract.t' else 't/unreviewed-storage.t' for n in owners]
    args = ['bash', '-c', 'set -euo pipefail\nfail() { exit 1; }\nmapfile -d "" -t perl_temp_owners\n' + predicate.decode()]
    legacy = [command(args, b''.join(n.encode() + b'\0' for n in names)) for names in (owners, replacement)]
    assert all(row['exit'] == 0 for row in legacy), 'frozen count predicate did not accept its same-count substitution'
    # Replay the current validator against the independently frozen old population
    # in a non-Git fixture. No current manifest or tracked source is overwritten.
    scratch = Path(os.environ['TMPDIR']) / ('storage-inventory-' + str(os.getpid()))
    scratch.mkdir()
    try:
        (scratch / 'tools').mkdir()
        (scratch / 'tools/check_project_storage_inventory.pl').write_bytes((ROOT / TOOL).read_bytes())
        directory = scratch / 'doctrine/project_data_storage'
        directory.mkdir(parents=True)
        old_manifest = dict(schema_version=1, kind='perl_temporary_owners', owner=intake['owner'], owners=owners)
        (directory / 'perl_temporary_owners.json').write_text(json.dumps(old_manifest))
        exact = [command(['perl', str((scratch / 'tools/check_project_storage_inventory.pl').relative_to(ROOT)),
                         '--kind', 'perl_temporary_owners', '--stdin-owners'],
                         b''.join(n.encode() + b'\0' for n in names)) for names in (owners, replacement)]
        assert exact[0]['exit'] == 0 and exact[1]['exit'] != 0
        assert b'storage inventory mismatch' in decode(exact[1]['stderr'])
        # An actual nonzero Git producer must fail even if it emits the expected
        # selected paths. The shim is a file, never another Git repository.
        shim = scratch / 'git'
        shim.write_text('#!/bin/sh\nexit 23\n')
        shim.chmod(0o755)
        env = dict(os.environ, PATH=str(scratch) + os.pathsep + os.environ['PATH'])
        git_failure = command(['perl', TOOL, '--kind', 'perl_temporary_owners'], env=env)
        assert git_failure['exit'] != 0 and b'Git storage census failed' in decode(git_failure['stderr'])
    finally:
        import shutil
        shutil.rmtree(scratch)
    return dict(population_controls=rows, frozen_count_predicate=packet(predicate),
                old_manifest=old_manifest, legacy=legacy, exact=exact, git_failure=git_failure)


def review():
    # Historical evidence uses its accepted capture. Actual census/control calls
    # below still exercise today's tool, manifests and owned source population.
    from book_count import storage_read, capture_read
    intake = json.loads(gzip.decompress((HERE / 'storage-intake.json.gz').read_bytes()))
    current = {n: decode(row) for n, row in intake['current'].items()}
    previous = {n: decode(row) for n, row in intake['previous'].items()}
    assert populations(current) == intake['populations']['current']
    assert populations(previous) == intake['populations']['previous']
    assert b'inventory drifted from 29 to 30' in decode(intake['failures']['canonical-ci.log'])
    assert b'Python temporary-owner inventory drifted' in decode(intake['failures']['storage-tool-before.log'])
    evidence = json.loads(gzip.decompress((HERE / 'storage-evidence-accepted.json.gz').read_bytes()))
    assert decode(evidence['prior_epoch']) == (HERE / 'storage-evidence-final.json.gz').read_bytes()
    assert b'AssertionError: book-storage-build.log' in decode(evidence['reader_rejection'])
    for name, row in evidence['inputs'].items():
        assert storage_read(name) == decode(row), 'storage evidence input drift: ' + name
    for name, row in evidence['channels'].items():
        raw = decode(row)
        marker = b'HTML book written to' if name == 'book-storage-build.log' else b'PASS'
        assert marker in raw and b'ERROR' not in raw, name
    for name in MANIFESTS:
        manifest = json.loads(capture_read(name))
        assert manifest['owners'] == intake['populations']['current'][manifest['kind']]
    class Visible(HTMLParser):
        def __init__(self):
            super().__init__()
            self.parts = []
        def handle_data(self, data):
            self.parts.append(data)
    visible = Visible()
    visible.feed(decode(evidence['rendered']).decode())
    text = ' '.join(''.join(visible.parts).split())
    for marker in ('Storage checks compare exact reviewed file populations',
                   'a matching count alone cannot detect a substituted file',
                   'hostile-path probes remain required'):
        assert marker in text, 'storage guidance did not render: ' + marker
    from book_review import verify_prose
    original_book = json.loads(gzip.decompress((HERE / 'book-inputs.json.gz').read_bytes()))
    approval = json.loads((HERE / 'book-edits.json').read_bytes())
    book = 'docs/linkedspec-book/src/development/local-ci-and-regression.md'
    verify_prose(decode(original_book['books'][book]['before']).decode(),
                 storage_read(book).decode(), approval['books'][book])
    result = controls()
    # Commands include current scratch paths; compare stable outcomes and inputs.
    saved = evidence['controls']
    assert [(r['kind'], r['case'], r['result']['exit']) for r in result['population_controls']] == [
        (r['kind'], r['case'], r['result']['exit']) for r in saved['population_controls']]
    assert result['old_manifest'] == saved['old_manifest']
    assert decode(result['frozen_count_predicate']) == decode(saved['frozen_count_predicate'])
    print('storage inventory: four exact populations; missing/unexpected/same-count/duplicate/truncated/empty controls PASS; frozen predicate accepts replacement, exact predicate rejects; Git failure rejects')


def capture():
    destination = HERE / 'storage-evidence-accepted.json.gz'
    assert not destination.exists(), 'never overwrite a completed storage epoch'
    inputs = [TOOL, *SCRIPTS, *MANIFESTS, str(Path(__file__).relative_to(ROOT)),
              'docs/checkpoints/document-pressure-restoration/capture_storage_intake.py',
              'docs/linkedspec-book/src/development/local-ci-and-regression.md',
              'docs/linkedspec-book/book.toml', 'tools/run_mdbook_local.sh',
              'docs/knowledge/tool-project-data-ssd-storage.md',
              'docs/knowledge/project-data-ssd-storage-locality.md']
    channels = {name: packet((ROOT / '.linkedspec-data/normal-hook-restoration' / name).read_bytes())
                for name in ['storage-perl-after.log', 'storage-tool-after.log', 'book-storage-build.log']}
    evidence = dict(owner='TYPE-REFERENCE-BOOK.1.2.20.1.19', inputs={n: packet((ROOT / n).read_bytes()) for n in inputs},
                    channels=channels, controls=controls(),
                    prior_epoch=packet((HERE / 'storage-evidence-final.json.gz').read_bytes()),
                    reader_rejection=packet((ROOT / '.linkedspec-data/normal-hook-restoration/storage-reader-rejected.log').read_bytes()),
                    rendered=packet((ROOT / 'docs/linkedspec-book/book/development/local-ci-and-regression.html').read_bytes()),
                    limits='Four file populations in declared tracked source scopes, import-based Python coverage and actual focused storage probes. Current guidance is retained with observed HTML and build log; this does not close all transitive mdBook generator inputs. The earlier passing code-only epoch and its reader stay recoverable. No transitive allocator completeness, leak absence outside those probes, or whole CI pass inferred.')
    destination.write_bytes(gzip.compress(json.dumps(evidence, sort_keys=True, separators=(',', ':')).encode(), mtime=0))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    if args.capture:
        capture()
    review()
