"""Preserve and update the canonical explanation of the exact audit boundary."""
import json
import subprocess
import admission_common as a


def main():
    fact = 'docs/knowledge/phase0-compiler-scanner-mock-historical-inverse.md'
    overview = 'docs/knowledge/three-objective-language-readiness.md'
    book = 'docs/linkedspec-book/src/development/local-ci-and-regression.md'
    ledger = 'docs/language-readiness/objective-reconciliation.md'
    changes = {
        fact: [
            ('date: 2026-10-24', 'date: 2026-10-25'),
            ('  - "why does adding a Perl CI test fail the historical governance registration audit"',
             '  - "why does adding a Perl CI test fail the historical governance registration audit"\n  - "why does the historical objective audit reject Rust engine changes"'),
            ('Its book containment removes12 empty heading separators; all90 output files stay byte/mode-identical.',
             'Its book containment removes12 empty heading separators; all90 output files stay byte/mode-identical.\n\nRust17.3 admits only the exact engine source pair pinned in verify_objectives.py,\nwith its owner recorded separately from unchanged historical hashes/results.\nUnreviewed source bytes reject; actual guard removal admits drift and the original\nrecovery driver catches it. Three source mutations/four direct denials restore.\nFresh unchanged Rust readiness passes parent6 and emitted4/4/3 tests with actual\nsource/executable custody. Dated evidence: docs/checkpoints/signed-array-rust-admission/.')],
        overview: [
            ('date: 2026-10-21', 'date: 2026-10-25'),
            ('It fails on latest executable drift and deliberately corrupted evidence, while\nrecording documentation evolution separately.',
             'It rejects unreviewed executable drift and corrupted evidence; exact reviewed\nsource evolution and documentation changes are reported separately.'),
            ('not an additional automatic runtime admission gate.',
             'run inside canonical artifact recovery, not a fresh runtime objective gate.')],
        book: [
            ('This is a Perl regression extension; portable signed-selector admission remains separate.',
             'This is a Perl regression extension; portable signed-selector admission remains separate. Rust signed-selector admission permits only the exact reviewed before/after runtime source pair. The auditor reports that owner separately, rejects any unreviewed image, and preserves every historical source hash and result. Fresh Rust nesting, context and lossless/child compatibility runs independently; this does not establish portable signed-selector coverage.')],
        ledger: [
            ('latest executable inputs and retained log hashes.',
             'latest executable inputs and retained log hashes. Exact owner-bound Rust signed-selector source evolution is reported separately; the original source identities and runtime results stay historical. Fresh Rust nesting/context/lossless parent and emitted consumers provide the separate compatibility check.')],
    }
    before = {path: a.read(path) for path in changes}
    names = subprocess.check_output(['git', 'ls-files', 'docs/claims'], cwd=a.ROOT, text=True).splitlines()
    live = []
    for name in names:
        if not name.endswith('.json'):
            continue
        for claim in json.loads((a.ROOT/name).read_bytes()).get('claims', []):
            durability = claim.get('durability', {})
            if durability.get('mode') == 'live':
                for item in durability.get('inputs', []):
                    assert item['path'] not in changes, (name, item['path'])
        live.append(dict(path=name, **a.identity(name)))
    a.save('documentation-inputs.json.gz', dict(before=before, producer=a.read(a.PREFIX+'document.py'),
        helper=a.read(a.PREFIX+'admission_common.py'), claim_preflight=live,
        scope='Whole immediately preceding canonical documents, actual updater and live-claim input census. No existing live claim directly binds a changed document. Original wording is retained; dated historical results are not refreshed.'))
    for path, replacements in changes.items():
        text = a.decode(before[path]['base64']).decode()
        for old, new in replacements:
            assert text.count(old) == 1, (path, old)
            text = text.replace(old, new, 1)
        (a.ROOT/path).write_text(text)
    a.save('documentation-after.json.gz', {path: a.read(path) for path in changes})
    print('Canonical audit/source-evolution explanation updated; original documents and live-binding preflight retained.')


if __name__ == '__main__':
    main()
