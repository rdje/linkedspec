"""Select the exact stale guard roots from accepted TAP, then observe the real Phase0 file."""
import json
from pathlib import Path
import re
import sys
import common as c
import context

SOURCE = 't/phase0_regression.t'
ACTOR = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-focused.pl'
LOG = '.linkedspec-data/verification/type-sort-kind-canonical.log'


def prepare():
    draft = c.load('draft1.json.gz')
    assert draft['baseline']['returncode'] == 0 and draft['inputs_unchanged']
    c.write_new('phase0-preparation-inputs.json.gz',context.snapshot())
    source = c.read(SOURCE)
    assert {key:source[key] for key in ('sha256','mode')} == {
        key:c.load('prior.json.gz')['images'][SOURCE][key] for key in ('sha256','mode')}
    text = c.decode(source['base64']).decode()
    names = set()
    root = None
    counts = dict(count=0,first=0)
    for line in text.splitlines():
        match = re.match(r"subtest '([^']+)' => sub \{",line)
        if match:
            root = match[1]
        for helper in counts:
            if 'defined($__ls_'+helper+')' in line:
                assert root
                names.add(root)
                counts[helper] += 1
    assert counts == dict(count=8,first=2)
    log = c.read(LOG)
    tap = c.decode(log['base64']).decode()
    selected = []
    for name in names:
        matches = re.findall(r'^ok (\d+) - '+re.escape(name)+r'$',tap,re.M)
        assert len(matches) == 1,(name,matches)
        selected.append(dict(number=int(matches[0]),name=name))
    selected.sort(key=lambda row:row['number'])
    assert len(re.findall(r'^1\.\.1035$',tap,re.M)) == 1
    plan = dict(selected=selected,ordinary_root_tests=1035)
    c.write_new('phase0-plan.json.gz',dict(plan=plan,log=log,source=source,counts=counts,
        actor=c.read(ACTOR),producer=c.read(c.PREFIX+'phase0.py'),
        scope='Exact accepted canonical TAP root numbers/names select every current guard-golden line in the unchanged accepted Phase0 source. The real test file/imports/helpers execute; other roots are explicit skips. This is focused evidence, never full Phase0 admission.'))
    path = 'docs/tasks/TYPE-REFERENCE-BOOK.md'
    tree = c.source(path).read_text()
    start,end = tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.10`'),tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.11`')
    leaf = tree[start:end].replace('Status: `done` / selected proof; exact canonical admission required',
        'Status: `active` / final Phase0 guard-golden/inverse admission',1)
    leaf += '  Final pre-CI source search owns ten stale Phase0 emitted-source expectations (eight count/two first). Reproduce through the exact selected real roots, update only guard literals, and admit a separate hash-gated inverse before the unchanged historical layers. Preserve old tables, all650 controls and add omission/duplication/corruption controls for every new hunk. Whole unpublished draft1/11015 inputs/full modes/actual readonly0 survives; no acceptance revision is fabricated.\n\n'
    tree = tree[:start]+leaf+tree[end:]
    tree = tree.replace('- Status: `active` / next registered pipeline .1.2.11; before enumeration',
        '- Status: `active` / final count/first .1.2.10 admission; before enumeration',1)
    tree = tree.replace('| `TYPE-REFERENCE-BOOK.1.2.10` | `done` |232/107 RED/eight faults; direct consumers/book and finite history0137; canonical admission mandatory. |',
        '| `TYPE-REFERENCE-BOOK.1.2.10` | `active` | Final ten Phase0 source-golden and exact historical inverse admission; draft1 preserved. |',1)
    c.source(path).write_text(tree)
    memory = c.source('MEMORY.md').read_text()
    memory = re.sub(r'^- next_action:.*$', '- next_action: Complete focused Phase0 guard-golden RED/GREEN and the owned historical inverse, then close publication2 and exact canonical/normal landing before activating11.',memory,flags=re.M)
    memory = re.sub(r'^- in_flight_uncommitted:.*$', '- in_flight_uncommitted: Final Phase0 source-golden/inverse admission within10; whole unpublished draft1/11015 inputs/full modes/actual readonly0 is preserved in the checkpoint.',memory,flags=re.M)
    memory = memory.replace('`TYPE-REFERENCE-BOOK.1.2.10` (completed)','`TYPE-REFERENCE-BOOK.1.2.10` (final admission active)')
    c.source('MEMORY.md').write_text(memory)
    print('Focused Phase0 plan:',len(selected),'roots;',counts,'stale guard expectations')


def observe(stem):
    plan = c.load('phase0-plan.json.gz')['plan']
    supplied = context.snapshot()
    c.write_new(stem+'-inputs.json.gz',supplied)
    run = c.run(['perl','-Iperl',ACTOR],input=json.dumps(plan).encode())
    stable = c.unchanged(supplied['inputs'])
    c.write_new(stem+'-run.json.gz',dict(plan=plan,run=run,inputs_unchanged=stable))
    out = c.decode(run['stdout_base64'])
    marker = b'# FOCUSED_PHASE0_JSON '
    assert out.count(marker) == 1
    result = json.loads(out.split(marker)[1].splitlines()[0])
    assert stable and result['complete_selection'] and result['selected'] == len(plan['selected'])
    assert result['root_tests'] == plan['ordinary_root_tests']
    assert Path(result['loaded_method_lowering']).resolve() == c.ROOT/c.SOURCES[1]
    assert c.identity(c.SOURCES[1]) == supplied['inputs'][c.SOURCES[1]]
    wanted = {row['number'] for row in plan['selected']}
    failed = {int(value) for value in re.findall(rb'^not ok (\d+) - ',out,re.M)}
    if stem == 'phase0-accepted':
        assert run['returncode'] == 1 and failed == wanted
    else:
        assert run['returncode'] == 0 and result['passing'] and not failed
        assert not c.decode(run['stderr_base64'])
    result['loaded_method_lowering'] = Path(result['loaded_method_lowering']).resolve().relative_to(c.ROOT).as_posix()
    c.write_new(stem+'-result.json',dict(summary=result,failed=sorted(failed),
        scope='Focused selected roots with explicit skips only; ordinary full Phase0 remains a canonical requirement.'))
    print(stem,'exit',run['returncode'],'selected',len(wanted),'failed',len(failed),flush=True)


if __name__ == '__main__':
    assert len(sys.argv) == 2
    if sys.argv[1] == 'prepare':
        prepare()
    else:
        assert sys.argv[1] in ('phase0-accepted','phase0-candidate')
        observe(sys.argv[1])
