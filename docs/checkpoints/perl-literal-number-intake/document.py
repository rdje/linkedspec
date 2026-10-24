"""Own the newly reproduced scalar-kind defects without pivoting dirty17.2."""
import base64
import gzip
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
TREE = "docs/tasks/TYPE-REFERENCE-BOOK.md"
CARD = "docs/knowledge/write-vivification-perl-reference.md"
BOOK = "docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md"
PATHS = (TREE, CARD, BOOK, "MEMORY.md", "LIVE_ACHIEVEMENT_STATUS.md", "ROADMAP.md", "ROADMAP_V2.md",
    "docs/TASK_TREE.md", "CHANGES.md", "DEVELOPMENT_NOTES.md")


def save(name, value):
    with (HERE / name).open("xb") as output:
        output.write(gzip.compress((json.dumps(value, sort_keys=True) + "\n").encode(), mtime=0))


def put(path, value):
    (ROOT / path).write_text(value)


def main():
    save("document-before.json.gz", dict(before={path: base64.b64encode((ROOT / path).read_bytes()).decode()
        for path in PATHS}, producer_base64=base64.b64encode(Path(__file__).read_bytes()).decode()))
    text = (ROOT / TREE).read_text()
    text = text.replace('`TYPE-REFERENCE-BOOK.1.2.17`, `TYPE-REFERENCE-BOOK.1.2.14`',
        '`TYPE-REFERENCE-BOOK.1.2.17`, `TYPE-REFERENCE-BOOK.1.2.22`, `TYPE-REFERENCE-BOOK.1.2.14`', 1)
    text = text.replace('Goal: Preserve authored floating-number kind through deferred literal evaluation and assignment before continuing signed backend work.',
        'Goal: Preserve authored whole-float and boolean literal kinds through deferred evaluation and assignment before continuing signed backend work.', 1)
    text = text.replace('Root-cause verification: Public Get/dump/scalar flags identify the exact number branch. Accepted-source shadow and independent generated-route reproduction are required in the owned intake before classifying historical scope; do not infer them from current results.',
        'Root-cause verification: Sixteen exact public sources complete descriptor/current native/emitted and accepted-runtime-byte-shadow native/emitted routes. Accepted ed65 sources already return integral-float literals as integer-only scalars and boolean literals as integer0/1; compiled argument twins preserve NV/boolean kinds. _eval_expr number uses0+serialized value and boolean uses native1/0. Actual INC confirms preloaded accepted sources; no historical environment reconstruction is claimed. Intake: docs/checkpoints/perl-literal-number-intake/read.py. No producer repair/admission yet.', 1)
    text = text.replace('Impact: Numerically integral float literals inside deferred bodies become integers, so their assigned values can enter integer-only selector paths inconsistently with literal/compiled-argument twins. The signed runtime-kind contract is implemented, but the preceding number producer needs a separate repair and broader numeric compatibility proof.',
        'Impact: Whole-float and boolean literals inside deferred bodies lose kind before assignment, return or container construction. Assigned1.0/false can incorrectly enter integer-only write selectors, while literal typed-write twins reject. Assigned-1.0 becomes an integer before negative selection. The signed runtime-kind contract is implemented; the preceding scalar producers need separate repair and broader numeric/boolean compatibility proof.', 1)
    text = text.replace('Acceptance: Preserve supported integer/float source kind through deferred literal values, assignments, copied parameters/containers and helper operands;',
        'Acceptance: Preserve supported integer/float/boolean source kind through deferred literal values, assignments, copied parameters/containers and helper operands;', 1)
    boundary = text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.22`')
    text = text[:boundary] + ('  Late issue intake: Current/accepted byte-shadow native/emitted observations prove pre-existing whole-float and boolean literal kind erasure in _eval_expr before selectors. Own P1 repair22 immediately after this clean commit, before Rust17.3. Preserve the sealed118-input finite signed publication unchanged. Canonical1 is deliberately superseded143; exact original129-file candidate/fingerprint and full actual log are retained in perl-literal-number-intake/candidate-before.json.gz. This intake admits no producer repair; child22 owns fresh source-bound signoff. Current book now states the limitation.\n\n') + text[boundary:]
    marker = '| 1 | `TYPE-REFERENCE-BOOK.1.2.17.3`'
    assert marker in text
    text = text.replace(marker, '| 0 | `TYPE-REFERENCE-BOOK.1.2.22` | `pending` | P1 deferred scalar literal kinds before further signed backends. |\n' + marker, 1)
    start = text.index('## Current Frontier')
    end = text.index('\n## ', start + 1)
    rows = text[start:end].splitlines()
    count = 0
    for position, row in enumerate(rows):
        if re.match(r'\| \d+ \|', row):
            count += 1
            rows[position] = re.sub(r'^\| \d+ \|', '| ' + str(count) + ' |', row)
    put(TREE, text[:start] + '\n'.join(rows) + '\n' + text[end:])
    text = (ROOT / BOOK).read_text()
    marker = '#### Existing parameter and effect behavior'
    assert text.count(marker) == 1
    text = text.replace(marker,
        '#### Current callable literal-kind limitation\n\n'
        'A deferred body currently loses the kind of whole-float and boolean literals before assignment, return or container construction. For example, a callable returning `[false,true]` currently returns integer `[0,1]`. A variable assigned `-1.0` inside that body becomes an integer and can then select the last array entry; the direct `[-1.0]` read and a float passed from an ordinary action remain outside the supported negative-integer path. Compiled float/boolean argument controls preserve their kinds. This pre-existing producer defect is scheduled for repair before the next backend slice.\n\n' + marker, 1)
    put(BOOK, text)
    text = (ROOT / CARD).read_text()
    text = text.replace('  - "which Perl readers govern negative array indexes"',
        '  - "which Perl readers govern negative array indexes"\n  - "why do whole floats assigned inside Perl callbacks become integer indexes"\n  - "why do deferred boolean literals become integer zero and one"', 1)
    text += ('\nOwned22: accepted/current native and emitted byte-shadow probes show\n'
        'CodeblockRuntime::_eval_expr erases whole-float and boolean literal kinds\n'
        'before return/assignment: 0+serialized number yields IV; native1/0 loses\n'
        'boolean identity. Compiled argument twins retain NV/boolean kinds. This\n'
        'pre-existing producer defect precedes integer selection. Repair22 is P1\n'
        'after clean17.2, before Rust17.3. Preliminary source/flags/INC review:\n'
        'docs/checkpoints/perl-literal-number-intake/read.py under the project\n'
        'Python wrapper. No repair/admission or historical environment replay.\n')
    put(CARD, text)
    text = (ROOT / "MEMORY.md").read_text()
    text = text.replace('active_work_unit: `TYPE-REFERENCE-BOOK.1.2.17.3`', 'active_work_unit: `TYPE-REFERENCE-BOOK.1.2.22`', 1)
    old = next(line for line in text.splitlines() if line.startswith('- next_action:'))
    text = text.replace(old, '- next_action: From clean Git activate P1 deferred scalar literal-kind repair22 before Rust17.3. Read perl-literal-number-intake/read.py and its16 current/accepted byte-shadow cases; preserve whole-float/boolean kinds with wider numeric/copy/typed-selector proof. Then resume17.3–7.', 1)
    text = text.replace('Canonical receipts and commit hooks remain the Git acceptance authority.',
        'Canonical1 was deliberately superseded143 after late kind intake; fresh exact canonical receipt and hooks remain mandatory.', 1)
    put('MEMORY.md', text)
    for path in ('LIVE_ACHIEVEMENT_STATUS.md', 'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md'):
        text = (ROOT / path).read_text()
        text = text.replace('Rust17.3 is next from clean Git;', 'P1 scalar literal-kind repair22 is next from clean Git, before Rust17.3;', 1)
        text = text.replace('From clean Git activate Rust17.3 under the same frozen signed authority, then17.4–7.',
            'From clean Git activate scalar literal-kind repair22, then Rust17.3 and17.4–7 under the same frozen signed authority.', 1)
        text = text.replace('Rust17.3 then17.4–7 follow clean Git.', 'P1 scalar literal-kind repair22 then Rust17.3 and17.4–7 follow clean Git.', 1)
        text = text.replace('Rust/Dart/Julia/Lua and admission17.3–7, deferred last14/with16',
            'P1 deferred literal-kind repair22, Rust/Dart/Julia/Lua and admission17.3–7, deferred last14/with16', 1)
        text = text.replace('Rust17.3 follows clean Git.', 'P1 scalar literal-kind repair22 precedes Rust17.3 after clean Git.', 1)
        text = text.replace('`active` / next .1.2.17.3', '`active` / next .1.2.22', 1)
        text = text.replace('Rust/Dart/Julia/Lua17.3–6 and independent admission17.7 precede',
            'P1 literal-kind repair22, Rust/Dart/Julia/Lua17.3–6 and independent admission17.7 precede', 1)
        put(path, text)
    text = (ROOT / 'CHANGES.md').read_text()
    marker = '\n## 2026-10-24 — TYPE-REFERENCE-BOOK.1.2.17.2'
    start = text.index(marker)
    end = text.index('\n## ', start + len(marker))
    text = text[:end] + ('\nLate ownership intake:16 current/accepted byte-shadow sources establish pre-existing whole-float/boolean literal kind erasure, independently of signed normalization. P1 repair22 is first after this clean commit, before Rust. The current book states the limitation. Preserve the sealed118-input signed proof and exact original129-file candidate; canonical1 was deliberately superseded143 and earns no success credit. Fresh exact canonical acceptance remains required.\n') + text[end:]
    put('CHANGES.md', text)
    text = (ROOT / 'DEVELOPMENT_NOTES.md').read_text()
    marker = '\n## 2026-10-24 — qualify negative Perl selectors'
    start = text.index(marker)
    end = text.index('\n## ', start + len(marker))
    text = text[:end] + ('\nLate source-bound intake shows a separate earlier producer problem: _eval_expr number uses0+serialized value, erasing an integral float spelling; boolean returns native1/0. Both accepted byte-shadow and current native/emitted routes reproduce lost kinds before selection, while compiled-argument twins retain NV/boolean identity. The signed reader accepts the resulting integer as designed. Repair22 owns these two scalar branches and wider compatibility proof immediately after clean17.2. The superseded canonical candidate and all observed channels remain retained; no prior measurement is retargeted.\n') + text[end:]
    put('DEVELOPMENT_NOTES.md', text)
    save('document-after.json.gz', dict(outputs={path: base64.b64encode((ROOT / path).read_bytes()).decode() for path in PATHS},
        scope='Own and disclose the prior scalar producer defects without a dirty task pivot. The sealed finite signed publication, runtime and permanent consumer stay unchanged. A fresh full book render and exact canonical candidate follow.'))


if __name__ == '__main__':
    main()
