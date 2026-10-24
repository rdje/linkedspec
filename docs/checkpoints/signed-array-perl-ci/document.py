"""Document the bounded CI registration inverse and preserve the current handoff."""
import base64
import gzip
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
CARD = "docs/knowledge/phase0-compiler-scanner-mock-historical-inverse.md"
BOOK = "docs/linkedspec-book/src/development/local-ci-and-regression.md"
PATHS = (CARD, BOOK, "docs/tasks/TYPE-REFERENCE-BOOK.md", "CHANGES.md", "DEVELOPMENT_NOTES.md", "MEMORY.md")


def save(name, value):
    with (HERE / name).open("xb") as output:
        output.write(gzip.compress((json.dumps(value, sort_keys=True) + "\n").encode(), mtime=0))


def main():
    after = json.loads(gzip.decompress((HERE / "after-runs.json.gz").read_bytes()))
    assert after["inputs_unchanged"] and all(run["returncode"] == 0 for run in after["runs"].values())
    historical = json.loads(base64.b64decode(after["runs"]["historical"]["stdout_base64"]))
    assert (historical["restored_inputs"], historical["restored_bytes"], len(historical["controls"])) == (134, 84613241, 22)
    assert historical["audit_controls"]["governance_mutations_rejected"] == 690
    before = {path: base64.b64encode((ROOT / path).read_bytes()).decode() for path in PATHS}
    save("document-before.json.gz", dict(before=before, producer_base64=base64.b64encode(Path(__file__).read_bytes()).decode()))
    card = (ROOT / CARD).read_text().replace('date: 2026-10-20', 'date: 2026-10-24', 1)
    marker = '  - "how are drop key Phase0 regressions reconciled with historical evidence"'
    assert card.count(marker) == 1
    card = card.replace(marker, marker + '\n  - "why does adding a Perl CI test fail the historical governance registration audit"', 1)
    card += ('\nCI17.2 registers exact signed input/syntax/execution insertions in\n'
        'verify_objectives.py. Strip these first to restore the earlier PUSH\n'
        'adjacency and original CI hash. Missing/duplicate/disabled registrations\n'
        'still reject. Proof: docs/checkpoints/signed-array-perl-ci/read.py.\n')
    total = sum(path.stat().st_size for path in (ROOT / 'docs/knowledge').glob('*.md'))
    assert total - (ROOT / CARD).stat().st_size + len(card.encode()) <= 8388608
    (ROOT / CARD).write_text(card)
    book = (ROOT / BOOK).read_text()
    marker = '### Callable-codeblock five-backend recurring proof'
    assert book.count(marker) == 1
    book = book.replace(marker,
        '### Perl signed-array selector regression\n\n'
        'Canonical CI requires the signed-selector consumer and its public JSON fixture to be tracked, syntax-checks the consumer, and executes its frozen/ordinary/callable native and emitted cases:\n\n'
        '```bash\nprove -Iperl t/signed_array_selector_perl_contract.t\n```\n\n'
        'The historical objective auditor records exact input, syntax and execution insertions for this registration. It removes that later insertion before the earlier callable/push registration, then requires the original historical CI hash. Missing, duplicated, disabled or relocated commands and changed fixture inputs reject; historical observations and hashes stay unchanged. This is a Perl regression extension; portable signed-selector admission remains separate.\n\n' + marker, 1)
    (ROOT / BOOK).write_text(book)
    text = (ROOT / 'docs/tasks/TYPE-REFERENCE-BOOK.md').read_text()
    marker = '- ID: `TYPE-REFERENCE-BOOK.1.2.22`'
    note = ('  CI enrollment closure: Three exact owned insertion pairs cover tracked test/fixture inputs, syntax and execution. The unchanged full isolated recovery producer passes134 inputs/84613241 bytes/22 recovery controls and690 evolution denials. Independent14 CI inputs admit only healthy; inverse verifier source rejects healthy, bypass source admits13 bad inputs, and actual restored source rejects all13 again. Original canonical2 candidate143/fingerprint179d413b1 and full exit1 log remain retained. The sealed118-input signed publication is unchanged; fresh exact canonical proof and normal hooks govern landing.\n\n')
    assert text.count(marker) == 1
    text = text.replace(marker, note + marker, 1)
    (ROOT / 'docs/tasks/TYPE-REFERENCE-BOOK.md').write_text(text)
    for path, heading in (('CHANGES.md', '## 2026-10-24 — TYPE-REFERENCE-BOOK.1.2.17.2'),
            ('DEVELOPMENT_NOTES.md', '## 2026-10-24 — qualify negative Perl selectors')):
        text = (ROOT / path).read_text()
        start = text.index(heading)
        end = text.index('\n## ', start + len(heading))
        paragraph = ('\nCI registration preserves earlier historical anchors: a new exact owner-bound inverse strips signed tracked-input/syntax/execution lines before the existing push insertion. The original historical CI hash remains20d82473d; full isolated134-input/84613241-byte recovery and22 controls pass with690 evolution denials. Independent13 bad registrations and two actual verifier-source faults distinguish the repair and restored protection. Canonical2 original143-file candidate and complete failure channels stay retained; no old measurement/input is refreshed. Current CI teaching and canonical fact card explain this boundary.\n')
        (ROOT / path).write_text(text[:end] + paragraph + text[end:])
    memory = (ROOT / 'MEMORY.md').read_text()
    memory = memory.replace('Canonical1 was deliberately superseded143 after late kind intake; fresh exact canonical receipt and hooks remain mandatory.',
        'Canonical1 superseded143; canonical2 exit1 at the owned CI insertion audit is repaired through exact inverse/13 denials and complete historical recovery. Fresh exact canonical receipt and hooks remain mandatory.', 1)
    (ROOT / 'MEMORY.md').write_text(memory)
    save('document-after.json.gz', dict(outputs={path: base64.b64encode((ROOT / path).read_bytes()).decode() for path in PATHS},
        scope='Intended clean handoff remains22 before Rust; current runtime and sealed118-input publication are unchanged. Complete current book render and fresh exact staged canonical receipt follow.'))
    print('CI teaching/ownership synchronized; historical hashes and the sealed signed proof stay exact.')


if __name__ == '__main__':
    main()
