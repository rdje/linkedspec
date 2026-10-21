"""Activate kind13 only after complete clean accepted9 preservation and public RED."""
import gzip
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(subprocess.check_output(['git', 'rev-parse', '--show-toplevel']).decode().strip())
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-array-pipelines'))
import common as c

BASE = 'eff23e4894727205dc12b209baab7065180a08e5'
PREFIX = 'docs/checkpoints/type-sort-copy-kinds/'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.13'


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == BASE
    status = c.run(['git', 'status', '--porcelain'])
    assert status['returncode'] == 0 and not c.decode(status['stdout_base64'])
    local = ROOT / '.linkedspec-data/verification'
    prior = json.loads(gzip.decompress((local / 'type-sort-kind-prior.json.gz').read_bytes()))
    baseline = json.loads(gzip.decompress((local / 'type-sort-kind-baseline.json.gz').read_bytes()))
    assert prior['base'] == baseline['base'] == BASE and baseline['inputs_unchanged']
    assert prior['baseline']['returncode'] == baseline['flags']['returncode'] == baseline['public']['returncode'] == 0
    assert c.read('docs/claims/TYPE-REFERENCE-BOOK.1.2.9.json') == prior['claim']
    names = ['docs/tasks/TYPE-REFERENCE-BOOK.md', 'MEMORY.md', 'ROADMAP_V2.md',
        'LIVE_ACHIEVEMENT_STATUS.md', 'docs/TASK_TREE.md',
        'docs/checkpoints/type-array-pipelines/README.md', 'docs/claims/TYPE-REFERENCE-BOOK.1.2.9.json',
        'docs/knowledge/terse-type-method-surface-inventory.md', 'KNOWLEDGE_MAP.md']
    before = {path: c.read(path) for path in names}
    after = {path: c.decode(packet['base64']).decode() for path, packet in before.items()}
    path = 'docs/tasks/TYPE-REFERENCE-BOOK.md'
    text = after[path]
    start = text.index('- ID: `' + OWNER + '`\n')
    end = text.index('\n- ID:', start + 1)
    assert 'Status: `pending` / P1 defect owned' in text[start:end]
    node = '''- ID: `TYPE-REFERENCE-BOOK.1.2.13`
  Status: `active` / activationeff23e489
  Goal: Preserve numeric kinds through lexical sorting and container copies.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.9`
  Owned paths: docs/checkpoints/type-sort-copy-kinds/; MethodLowering sorted emitters, BindingRuntime sorted comparator, permanent numeric/kind tests, public book/fact and normal continuity. CodeblockRuntime cloning remains a direct consumer; reducer95 is separate.
  Verification tier: `canonical`
  Focused checks: Fixed native/Get-dump/descriptor/fresh values and typed-index errors; independent B flags, JSON and clone kinds; numeric-looking strings, null/boolean and lexical order; source/result independence, ordinary/deferred and implicit-accumulator paths; direct consumers, book/Knowledge/history/doctrines.
  Canonical trigger: Observable Perl scalar-kind and pure-sort correction; exact staged canonical receipt required before normal landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.13.json`
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Clean accepted9:16 flag/value routes and8 descriptor/Get/dump/emitted cases reproduce numeric-to-string clones and failed numeric indexes.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Generated sorted comparators compare aliased operands; BindingRuntime array_transform does the same on copied elements. String flags then change Storable clone and typed nested-write behavior.
  - [ ] **FIX** — Preserve operand kinds without changing lexical/null ordering or coercing legitimate strings.
  - [ ] **ADDRESSED (verified)** — Fixed kind/index/copy population and distinguishing actual source faults/restoration.
  - [ ] **NO REGRESSION** — Permanent tests, direct consumers and exact canonical receipt.
  - [ ] **LOCKSTEP** — Worked book, canonical fact, roadmap and clean handoff; no inventory/backend admission.
  Pre-write custody: Whole accepted9 physical10743/logical3/images10746/full modes, actual clean source-readonly0 and independently verified committed Git images survive at real eff23e489 before changes. All10746 inputs remain unchanged through the new16/8 public baseline.
  Continuity intake owned/fixed here: The tree header still named numeric5/October20 and the parent child list omitted9/13/10/11/12. Align current metadata and child order during activation; detailed dated child evidence stays unchanged.
  Schedule: Finish13 before deferred count/first10, registered sorted/ordinary length11 and deferred indexed-write12. Keep reducer95 and complete operation inventory separately owned.
'''
    text = text[:start] + node + text[end:]
    text = text.replace('- Status: `active` / numeric .1.2.5 follows completed scoped-callable repair; before enumeration',
        '- Status: `active` / sorted-copy kind .1.2.13; before enumeration', 1)
    text = text.replace('- Last updated: `2026-10-20`', '- Last updated: `2026-10-21`', 1)
    parent_start = text.index('- ID: `TYPE-REFERENCE-BOOK.1.2`\n')
    parent_end = text.index('\n- ID:', parent_start + 1)
    child_ids = re.findall(r'^- ID: `(TYPE-REFERENCE-BOOK\.1\.2\.[0-9]+)`$', text, re.M)
    parent = text[parent_start:parent_end]
    parent, count = re.subn(r'^  Children: .+$', '  Children: ' + ', '.join('`' + item + '`' for item in child_ids) + '.', parent, count=1, flags=re.M)
    assert count == 1
    text = text[:parent_start] + parent + text[parent_end:]
    old = '| 7 | `TYPE-REFERENCE-BOOK.1.2.13` | `pending` | P1 sorted/copy scalar-kind repair next after9. |'
    assert text.count(old) == 1
    text = text.replace(old, '| 7 | `TYPE-REFERENCE-BOOK.1.2.13` | `active` | P1 sorted/copy scalar-kind repair after accepted9; clean baseline retained. |', 1)
    assert len(text.encode()) <= 65536
    after[path] = text
    after['MEMORY.md'] = '''# MEMORY

- activation_commit: `eff23e4894727205dc12b209baab7065180a08e5` — clean leaf13 base; derive current identity from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.9` — committed sorting/take availability; canonical CI and normal hooks passed.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.13`; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: Declare the fixed kind/copy/index population, including generated implicit accumulators; verify accepted RED before implementing the bounded comparator repair.
- in_flight_uncommitted: Leaf13 activation/evidence custody and current metadata alignment. Runtime code is unchanged; no admission yet.
- custody: docs/checkpoints/type-sort-copy-kinds/prior.json.gz retains whole accepted9 physical10743/logical3/images10746/full modes/actual clean readonly0 at real eff23e489. Its claim is historical only there.
- diagnosis: baseline.json.gz reruns16 B-flag/value/clone routes and8 descriptor/Get/dump/fresh cases with all10746 inputs unchanged. Both actual native and generated numeric-index causes are structured nested_write_kind_conflict.
- owners: MethodLowering emits two direct lexical comparators; BindingRuntime array_transform compares copied elements. Compare scalar copies to preserve kinds. CodeblockRuntime cloning is a direct consumer; reducer95 remains separate.
- next_owned:13 -> count/first10 -> registered sorted/ordinary length11 -> indexed-write12 -> inventory1/mapping2/layout3/legacy8/private metadata QA/references.
- limits: No complete type/operation inventory, whole pipeline or cross-backend admission. Other repositories and RGX/PGEN stay read-only black boxes; project data stays on the repository volume. No push until PNT is exhausted.
- cleanup: Latest2026-10-20T19:45:58.736082+00:00; required frozen proof/chunks are retained.
'''
    path = 'ROADMAP_V2.md'
    lines = after[path].splitlines()
    indices = [i for i, line in enumerate(lines) if line.startswith('October21 current PNT boundary:')]
    assert len(indices) == 1
    lines[indices[0]] = 'October21 current PNT boundary: TYPE-REFERENCE-BOOK.1.2.9 is accepted at eff23e489 after canonical CI, Phase0 1035 and normal hooks. Active P1 kind13 preserves numeric values through lexical sorting/copying. Whole accepted9 physical10743/logical3/images10746/full modes and actual clean readonly0 precede changes; fresh16/8 public diagnosis retains numeric-index and clone failures. Then10/11/12 precede inventory. No complete pipeline/reference admission.'
    after[path] = '\n'.join(lines) + '\n'
    path = 'LIVE_ACHIEVEMENT_STATUS.md'
    text = after[path]
    text, count = re.subn(r'(?<=## Current Activity\n\n).*?(?=\n\n## Latest Completed Slice)',
        'Active TYPE-REFERENCE-BOOK.1.2.13: sorted/copy scalar-kind P1. Accepted9 is committed at eff23e489 after exact canonical CI, Phase0 1035 and normal hooks. Whole accepted custody and fresh public RED precede changes.', text, count=1, flags=re.S)
    assert count == 1
    text, count = re.subn(r'(?<=## Next Action\n\n).*?(?=\n\n## Recent Completions)',
        'Declare the fixed numeric/string/copy/index population and implicit-accumulator route, then repair the two generated comparator paths and deferred runtime path. Keep book/roadmap/fact aligned, verify and commit13 before10. No push yet.', text, count=1, flags=re.S)
    assert count == 1
    after[path] = text
    path = 'docs/TASK_TREE.md'
    old = '`active` / kind .1.2.13 next clean'
    assert after[path].count(old) == 1
    after[path] = after[path].replace(old, '`active` / kind .1.2.13', 1)
    after['docs/checkpoints/type-array-pipelines/README.md'] += '\nHistorical boundary: pipeline9 is accepted at eff23e4894727205dc12b209baab7065180a08e5. Its source-readonly gateway requires those complete accepted Git inputs after kind13 begins. Whole claim/publication/physical10743/logical3/full-mode images10746 and actual clean readonly0 are retained by docs/checkpoints/type-sort-copy-kinds/prior.json.gz before changes.\n'
    path = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.9.json'
    record = json.loads(after[path])
    for claim in record['claims']:
        assert claim['durability']['mode'] == 'live'
        claim['durability'].update(mode='historical', revision=BASE)
    after[path] = json.dumps(record, separators=(',', ':')) + '\n'
    path = 'docs/knowledge/terse-type-method-surface-inventory.md'
    old = 'reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-array-pipelines/publish.py"'
    assert after[path].count(old) == 1
    after[path] = after[path].replace(old, 'reverify: "At eff23e489: bash tools/run_python_project_data.sh docs/checkpoints/type-array-pipelines/publish.py"', 1)
    after[path] = after[path].replace('status: bounded Perl helpers; sorted-kind13 and inventory pending', 'status: bounded Perl helpers; kind13 active; inventory pending', 1)
    target = ROOT / PREFIX
    assert not target.exists()
    target.mkdir()
    for stem in ('preserve', 'baseline', 'activate'):
        shutil.copy2(local / ('type-sort-kind-' + stem + '.py'), target / (stem + '.py'))
    for source, destination in [('type-sort-kind-prior.json.gz', 'prior.json.gz'),
        ('type-sort-kind-prior-baseline.json.gz', 'prior-baseline.json.gz'),
        ('type-sort-kind-baseline.json.gz', 'baseline.json.gz')]:
        shutil.copy2(local / source, target / destination)
    # The existing task owns the first tracked write; implementation remains untouched.
    (ROOT / 'docs/tasks/TYPE-REFERENCE-BOOK.md').write_text(after['docs/tasks/TYPE-REFERENCE-BOOK.md'])
    for path, text in after.items():
        if path not in ('docs/tasks/TYPE-REFERENCE-BOOK.md', 'KNOWLEDGE_MAP.md'):
            (ROOT / path).write_text(text)
    (target / 'README.md').write_text('''# Sorted and copied numeric kinds — active Perl repair

Owner: TYPE-REFERENCE-BOOK.1.2.13. Clean activation: eff23e4894727205dc12b209baab7065180a08e5.
This is an in-progress repair, not an admission. MEMORY.md owns the current next action.

prior.json.gz preserves whole accepted9 claim/publication/10743 physical inputs,
three logical identities, full modes and10746 independently verified committed Git images.
Its actual clean source-readonly0 and exact preserver survive; unchanged inputs recover
from real accepted Git and tracked chunks. No recursive binary copying or dependency
implementation inspection is involved.

baseline.json.gz reruns16 native/fresh B-flag/value/clone observations and8 separate
descriptor/Get/dump/emitted probes before tracked writes. Every10746 input remains
unchanged. Numeric literals remain numeric controls; sorted values acquire string
flags, clones emit strings and numeric indexes fail. The separate public observer
retains both native and generated structured causes; the older flag observer's
generated-error stringification is not presented as typed evidence.

preserve.py and baseline.py are exact one-shot pre-write actors, archived with their
original ignored aliases and captured inputs; do not run them against a changed tree.
activate.py adopts their outputs, retires claim9 only at its actual accepted commit,
and aligns current task/roadmap/memory metadata. Runtime code is unchanged by activation.
The historic pipeline publisher requires complete accepted9 inputs after this boundary.
''')
    generated = c.run(['bash', 'knowledge-map/scripts/gen_knowledge_map.sh'])
    value = dict(base=BASE, owner=OWNER, producer=c.read(PREFIX + 'activate.py'), before=before,
        after={path: c.read(path) for path in names}, knowledge=generated,
        scope='Task13 activation only, after clean accepted9 preservation and actual public RED. No runtime/test/book behavior changes. Claim9 retirement changes mode/revision only at its real accepted Git state; current metadata and historical reverify routing are aligned.')
    raw = (json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n').encode()
    with (target / 'activation.json.gz').open('xb') as output:
        output.write(gzip.compress(raw, mtime=0))
    assert generated['returncode'] == 0
    print('Kind13 activated after complete accepted9 custody/public RED; stale tree metadata aligned; runtime unchanged')


if __name__ == '__main__':
    main()
