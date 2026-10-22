"""Close the portable final candidate after distinct current proof succeeds."""
from pathlib import Path
import subprocess
import sys

ROOT = Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
PREFIX = 'docs/checkpoints/type-array-count-first/'
sys.path.insert(0,str(ROOT/PREFIX))
import common as c
import context
import review


def main():
    result = review.check(fresh=False)
    draft = c.load('final-docs2.json.gz')
    assert result['cases'] == 232 and result['historical_controls'] == 680
    paths = list(draft['after'])
    before = {path:c.read(path) for path in paths}
    c.write_new('final-docs3-inputs.json.gz',context.snapshot())
    values = {path:c.decode(packet['base64']).decode() for path,packet in draft['after'].items()}
    tree = c.decode(before['docs/tasks/TYPE-REFERENCE-BOOK.md']['base64']).decode()
    tree = tree.replace('- Status: `active` / count/first10 final portability repair; before enumeration',
        '- Status: `active` / next registered pipeline .1.2.11; before enumeration',1)
    start,end = tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.10`'),tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.11`')
    leaf = tree[start:end].replace('Status: `active` / final published-summary portability repair',
        'Status: `done` / selected proof; exact canonical admission required',1)
    leaf = leaf.replace('- [ ] **NO REGRESSION','- [x] **NO REGRESSION',1).replace('- [ ] **LOCKSTEP','- [x] **LOCKSTEP',1)
    leaf += '  Portability defect verified fixed: both published Phase0 loader paths are repository-relative; exact raw outputs and original summaries remain in frozen draft2. The actual production path checker rejects the old candidate and passes the repair. Distinct doc4 re-renders89 inputs/executes five bodies with heading RED; artifact3 rejects missing/byte/mode declarations, admits them under an actual validator fault, and restores. Publication3 governs the resulting tree; prior publications stay immutable. Exact canonical receipt and normal hooks remain mandatory.\n\n'
    values['docs/tasks/TYPE-REFERENCE-BOOK.md'] = tree[:start]+leaf+tree[end:]
    values['MEMORY.md'] = values['MEMORY.md'].replace('- historical:',
        '- portability: Two published loader summaries are relative; raw observations and actual failed draft2 survive. Production path check and distinct doc4/artifact3 pass; publication3 owns this candidate.\n- historical:',1)
    readme = values[PREFIX+'README.md']
    readme = readme.replace('publication2.json and its manifest govern the final candidate.',
        'publication2.json and its manifest remain frozen; publication3.json and its manifest govern the final candidate.',1)
    readme += '''
Draft2 also remains whole:11074 physical inputs/full modes, actual readonly0,
original plain summaries/producer and the actual production portability RED.
Canonical attempt1 was stopped143 after its reported path denial, without a
success receipt. Two new summary fields had copied absolute loader paths.
Only their published representation is normalized; the exact original raw
observations, original assertions and all historical counts remain retained.
The production path checker passes after repair and runs again in fresh review.
Distinct doc4 and artifact3 prove the current book and actual publication
validator. Publication3 governs this candidate; exact canonical/normal landing
remains required. Earlier publication files and manifests are unchanged.
'''
    values[PREFIX+'README.md'] = readme
    for path,value in values.items():
        c.source(path).write_text(value)
        c.source(path).chmod(before[path]['mode'])
    c.write_new('final-docs3.json.gz',dict(before=before,after={path:c.read(path) for path in paths},result=result,
        scope='Intended clean post-landing handoff. The partial canonical143 path failure is preserved; a fresh exact staged receipt and normal hooks govern admission. No original runtime or raw observation is rewritten.'))
    print('Portable continuity closed; current book/artifacts and actual path check GREEN')


if __name__ == '__main__':
    main()
