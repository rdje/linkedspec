"""Adopt clean accepted13 custody and activate owned count/first10 before code edits."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-sort-copy-kinds'))
import common as c

BASE = 'a8bd8620a4e545b3e472561bfea90c656ab69923'
PREFIX = 'docs/checkpoints/type-array-count-first/'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.10'


def load_alias(name):
    return json.loads(gzip.decompress(c.source('.linkedspec-data/verification/type-count-first-'+name).read_bytes()))


def main():
    actor = Path(__file__).resolve().relative_to(ROOT).as_posix()
    producer = c.read(actor)
    assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip() == BASE
    status = c.run(['git','status','--porcelain'])
    assert status['returncode'] == 0 and not c.decode(status['stdout_base64'])
    prior = load_alias('prior.json.gz')
    baseline = load_alias('baseline.json.gz')
    assert prior['base'] == baseline['base'] == BASE
    assert baseline['inputs_unchanged'] and not baseline['failures']
    assert prior['baseline']['returncode'] == 0 and not c.decode(prior['baseline']['stderr_base64'])
    assert all(c.identity(path) == {key:item[key] for key in ('sha256','mode')}
        for path,item in prior['images'].items())
    paths = ['docs/tasks/TYPE-REFERENCE-BOOK.md','MEMORY.md','ROADMAP_V2.md',
        'LIVE_ACHIEVEMENT_STATUS.md','docs/TASK_TREE.md',
        'docs/knowledge/terse-type-method-surface-inventory.md',
        'docs/claims/TYPE-REFERENCE-BOOK.1.2.13.json',
        'docs/checkpoints/type-sort-copy-kinds/README.md','KNOWLEDGE_MAP.md']
    before = {path:c.read(path) for path in paths}
    text = {path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    tree = text[paths[0]]
    start = tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.10`')
    end = tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.11`',start)
    tree = tree[:start]+'''- ID: `TYPE-REFERENCE-BOOK.1.2.10`
  Status: `active` / activationa8bd8620a
  Goal: Execute deferred count/first array receiver helpers.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.13`
  Owned paths: docs/checkpoints/type-array-count-first/; CodeblockRuntime count/first dispatch, permanent consumers, worked book/fact and continuity. Registered sorted/ordinary length11 and indexed writes12 remain separate.
  Verification tier: `canonical`
  Focused checks: Public descriptor/Get-dump/native/fresh values and typed errors; free/receiver shape, empty/kind/continuation/effects, copy/index/source controls; direct consumers, book/Knowledge/history/doctrines.
  Canonical trigger: Observable Perl callable helper availability; exact staged canonical receipt before normal landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.10.json`
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Fresh accepted13 four-case public probe: ordinary2/1; native/fresh typed unknown_helper:count/first. Every10860 full-mode input stays unchanged.
  - [ ] **ROOT CAUSE (WHY + WHERE)** — Get dump invokes CodeblockRuntime; identify the missing helper dispatch and accepted argument/continuation contract before edits.
  - [ ] **FIX** — Implement only the measured count/first contract without absorbing11/12.
  - [ ] **ADDRESSED (verified)** — Fixed typed value/effect population and distinguishing source faults/restoration.
  - [ ] **NO REGRESSION** — Mandatory tests/direct consumers and exact canonical receipt.
  - [ ] **LOCKSTEP** — Worked book, canonical fact, roadmap and clean handoff.
  Pre-write custody: Whole accepted13 physical10857/logical3/images10860/full modes, independently Git-verified images and actual clean readonly0 survive at real a8bd8620a. Exact old intake/oracle and current public observer remain committed inputs.
  Schedule: Finish10 before11/12, then inventory1/mapping2/layout3. Detailed proof lives in the checkpoint.

'''+tree[end:]
    tree = tree.replace('`active` / next deferred count/first .1.2.10; before enumeration',
        '`active` / deferred count/first .1.2.10; before enumeration',1)
    tree = tree.replace('| `TYPE-REFERENCE-BOOK.1.2.10` | `pending` | Deferred count/first after13. |',
        '| `TYPE-REFERENCE-BOOK.1.2.10` | `active` | Fresh accepted13 four-case RED retained; define contract before dispatch repair. |',1)
    old = 'No director input required. Kind13 selected proof is complete; exact canonical/normal landing is mandatory. Activate10 only after clean handoff; then11/12 before inventory1. No dirty pivot.'
    assert old in tree
    tree = tree.replace(old,'No director input required. Kind13 is accepted at a8bd8620a after canonical/normal hooks. Active10 owns count/first; then11/12 before inventory1. No dirty pivot.',1)
    assert len(tree.encode()) <= 65536,len(tree.encode())
    text[paths[0]] = tree
    text['MEMORY.md'] = f'''# MEMORY

- activation_commit: `{BASE}` — clean count/first10 base; derive current identity from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.13` — committed a8bd8620a after canonical CI, Phase0 1035/private91-32240 and normal hooks.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.10`; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: Probe ordinary/deferred count/first shape, empty/kind, effects and continuation contracts, then inspect the public-identified CodeblockRuntime dispatch before its bounded fix.
- in_flight_uncommitted: Leaf10 custody/intake and active metadata only; runtime and book behavior are unchanged. The book still accurately marks deferred count/first unsupported.
- custody: docs/checkpoints/type-array-count-first/prior.json.gz retains whole accepted13 physical10857/logical3/images10860/full modes/actual clean readonly0 at real a8bd8620a. Claim13 is historical only there.
- diagnosis: Fresh four-case descriptor/Get-dump/native/emitted proof retains ordinary2/1 and both native/generated typed unknown_helper:count/first. All10860 inputs stay unchanged.
- owners: CodeblockRuntime dispatch;11 registered sorted/ordinary length and12 deferred indexed writes remain separate. Then inventory1/mapping2/layout3/legacy8/private metadata QA/references. Reducer95 remains separately owned.
- limits: No whole pipeline, inventory or cross-backend admission. Other repositories and RGX/PGEN remain read-only black boxes. Project data stays on the repository volume. No push until PNT is exhausted.
- cleanup: Latest2026-10-20T19:45:58.736082+00:00; frozen proof/chunks remain retained.
'''
    roadmap = text['ROADMAP_V2.md'].splitlines()
    roadmap[2] = 'October21 current PNT boundary: TYPE-REFERENCE-BOOK.1.2.13 is accepted at a8bd8620a after canonical CI, Phase0 1035/private91-32240 and normal hooks. Active10 owns deferred count/first: fresh four-case public probes retain ordinary2/1 and native/generated unknown_helper causes. Whole accepted13 physical10857/logical3/images10860/full modes/actual clean readonly0 precedes changes. Then11/12 before inventory; no full pipeline/reference admission.'
    roadmap[4] = roadmap[4].replace('After kind13 landing, continue the owned10/11/12 repairs',
        'Continue active10 and the owned11/12 repairs')
    text['ROADMAP_V2.md'] = '\n'.join(roadmap)+'\n'
    live = text['LIVE_ACHIEVEMENT_STATUS.md']
    start,end = live.index('## Current Activity\n\n'),live.index('\n## Latest Completed Slice')
    live = live[:start]+'## Current Activity\n\nActive TYPE-REFERENCE-BOOK.1.2.10: deferred count/first. Whole accepted13 custody and fresh public RED precede runtime edits; arity/kind/effect/continuation semantics require fresh probes.\n'+live[end:]
    start,end = live.index('## Next Action\n\n'),live.index('\n## Recent Completions')
    live = live[:start]+'## Next Action\n\nMeasure the count/first contract and identify missing dispatch through the public tools, then repair only10 with permanent tests, worked book and canonical admission.11/12 remain next before inventory.\n'+live[end:]
    live = live.replace('TYPE-REFERENCE-BOOK.1.2.13 preserves numeric/string kinds',
        'Accepted a8bd8620a after canonical CI, Phase0 1035/private91-32240 and normal hooks: TYPE-REFERENCE-BOOK.1.2.13 preserves numeric/string kinds',1)
    text['LIVE_ACHIEVEMENT_STATUS.md'] = live
    lines = text['docs/TASK_TREE.md'].splitlines()
    for index,line in enumerate(lines):
        if line.startswith('| `TYPE-REFERENCE-BOOK` |'):
            lines[index] = '| `TYPE-REFERENCE-BOOK` | `active` / count-first .1.2.10 | `.spec documentation / per-type reference` | Accepted13 a8bd8620a after canonical/normal hooks; active10 has fresh ordinary2/1 and typed deferred count/first RED. Whole prior custody retained. Then11/12 before inventory1/mapping2/layout3/legacy8; complete reference pending. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |'
    text['docs/TASK_TREE.md'] = '\n'.join(lines)+'\n'
    fact = text['docs/knowledge/terse-type-method-surface-inventory.md']
    fact = fact.replace('status: bounded Perl helpers; kind13 fixed; inventory pending',
        'status: bounded Perl helpers;10 active; inventory pending')
    fact = fact.replace('13 verifies scalar kinds.10/11/12 remain owned.','13 verifies kinds;10 active,11/12 owned.')
    fact = fact.replace('reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-sort-copy-kinds/publish.py"',
        'reverify: "At a8bd8620a: bash tools/run_python_project_data.sh docs/checkpoints/type-sort-copy-kinds/publish.py"')
    text['docs/knowledge/terse-type-method-surface-inventory.md'] = fact
    original_claim = json.loads(text['docs/claims/TYPE-REFERENCE-BOOK.1.2.13.json'])
    assert c.read('docs/claims/TYPE-REFERENCE-BOOK.1.2.13.json') == prior['claim']
    for claim in original_claim['claims']:
        assert claim['durability']['mode'] == 'live'
        claim['durability'].update(mode='historical',revision=BASE)
    text['docs/claims/TYPE-REFERENCE-BOOK.1.2.13.json'] = json.dumps(original_claim,separators=(',',':'))+'\n'
    text['docs/checkpoints/type-sort-copy-kinds/README.md'] += '\nHistorical boundary: accepted at a8bd8620a4e545b3e472561bfea90c656ab69923. Claim13 is frozen only there; after count/first10 activation the old readonly gateway requires complete accepted13 inputs. Current work follows MEMORY.md.\n'
    assert not (ROOT/PREFIX).exists()
    # The existing leaf becomes active before any other tracked write.
    c.source(paths[0]).write_text(text[paths[0]])
    c.source(paths[0]).chmod(before[paths[0]]['mode'])
    target = ROOT/PREFIX
    target.mkdir()
    aliases = {}
    for name,alias in {
        'preserve.py':'preserve.py','baseline.py':'baseline.py',
        'prior-baseline.json.gz':'prior-baseline.json.gz','prior.json.gz':'prior.json.gz',
        'baseline-observed.json.gz':'baseline-observed.json.gz','baseline.json.gz':'baseline.json.gz',
        'activate.py':'activate.py',
    }.items():
        original = '.linkedspec-data/verification/type-count-first-'+alias
        packet = c.read(original)
        with (target/name).open('xb') as output:
            output.write(c.decode(packet['base64']))
        (target/name).chmod(packet['mode'])
        aliases[original] = dict(path=PREFIX+name,sha256=packet['sha256'],mode=packet['mode'])
    for name in ('context.py','probe.pl'):
        packet = c.read(c.PREFIX+name)
        with (target/name).open('xb') as output:
            output.write(c.decode(packet['base64']))
        (target/name).chmod(packet['mode'])
    common = c.source(c.PREFIX+'common.py').read_text()
    common = common.replace(c.BASE,BASE).replace(c.PREFIX,PREFIX).replace(c.OWNER,OWNER)
    old_sources = "SOURCES = ['perl/LinkedSpec/ActionIR/MethodLowering.pm', 'perl/LinkedSpec/BindingRuntime.pm']"
    assert common.count(old_sources) == 1
    common = common.replace(old_sources,"SOURCE = 'perl/LinkedSpec/CodeblockRuntime.pm'\nSOURCES = [SOURCE, 'perl/LinkedSpec/ActionIR/MethodLowering.pm', 'perl/LinkedSpec/BindingRuntime.pm']",1)
    with (target/'common.py').open('x') as output:
        output.write(common)
    with (target/'README.md').open('x') as output:
        output.write('''# Deferred count and first — active bounded Perl repair

Owner: TYPE-REFERENCE-BOOK.1.2.10. Activation: a8bd8620a4e545b3e472561bfea90c656ab69923.
This is intake, not admission. MEMORY.md owns the precise next action.

prior.json.gz preserves whole accepted13 claim/publication/10857 physical inputs,
three logical aliases/10860 full-mode Git-verified images and actual clean readonly0.
Fresh four-case descriptor/Get-dump/native/fresh-emitted observations retain
ordinary count2/first1 and both typed deferred unknown_helper causes. All10860 inputs
remain unchanged. Original ignored actors/outputs are adopted byte-for-byte;
activation.json.gz maps every original alias to its committed recovery path.

Runtime code and public behavior are unchanged by activation. Probe shape, empty/kind,
effects and continuation before fixing the public-identified CodeblockRuntime dispatch.
Registered sorted/ordinary length11, indexed writes12 and reducer95 stay separate.
Gitlinks/other repositories are read-only black boxes; project data stays local.
''')
    for path,value in text.items():
        if path != paths[0] and path != 'KNOWLEDGE_MAP.md':
            c.source(path).write_text(value)
            c.source(path).chmod(before[path]['mode'])
    knowledge = c.run(['bash','knowledge-map/scripts/gen_knowledge_map.sh'])
    changed = set(paths)
    stable = all(c.identity(path) == {key:item[key] for key in ('sha256','mode')}
        for path,item in prior['images'].items() if path not in changed)
    value = dict(owner=OWNER,base=BASE,producer=producer,aliases=aliases,before=before,
        after={path:c.read(path) for path in paths},knowledge=knowledge,
        unaffected_inputs_unchanged=stable,
        scope='Whole accepted13 and fresh four-case intake precede the first tracked write. Only live metadata, derived map and mode/revision retirement change; runtime/book behavior remains unchanged. Every adopted original actor/output keeps exact bytes/full mode. No broad inventory or runtime admission.')
    raw = (json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
    with (target/'activation.json.gz').open('xb') as output:
        output.write(gzip.compress(raw,mtime=0))
    assert stable and knowledge['returncode'] == 0
    print('Count/first10 active; whole accepted13 and fresh four-case intake adopted; runtime unchanged')


if __name__ == '__main__':
    main()
