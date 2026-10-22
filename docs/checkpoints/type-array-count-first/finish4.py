"""Close the separately verified private count admission for exact canonical staging."""
from pathlib import Path
import subprocess
import sys
ROOT = Path(subprocess.check_output(['git', 'rev-parse', '--show-toplevel']).decode().strip())
PREFIX = 'docs/checkpoints/type-array-count-first/'
sys.path.insert(0, str(ROOT / PREFIX))
import common as c
import context
import review


def main():
    result = review.check(fresh=False)
    assert result['private']['assertions'] == 236
    paths = ['MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','ROADMAP_V2.md','docs/TASK_TREE.md','docs/tasks/TYPE-REFERENCE-BOOK.md']
    before = {path:c.read(path) for path in paths}
    c.write_new('final-docs4-inputs.json.gz', dict(context=context.snapshot(),
        producer=c.read(Path(__file__).resolve().relative_to(ROOT).as_posix())))
    with (ROOT / PREFIX / 'finish4.py').open('xb') as stream:
        stream.write(Path(__file__).read_bytes())
    memory = c.decode(c.load('draft3.json.gz')['context']['overrides']['MEMORY.md']['base64']).decode()
    memory = memory.replace('doc4/artifact3 pass; publication3 owns this candidate.',
        'doc5/artifact4 pass; publication4 owns this candidate.')
    memory = memory.replace('Unpublished draft1 remains whole; publication2 owns the final tree.',
        'Unpublished drafts1/2/3 remain whole; publication4 owns the final tree.')
    memory = memory.replace('- custody:', '- private: Three current count expectations retain native records;236 assertions, actual omission and matched old-guard semantic RED/restoration pass. Canonical2 failed1; current exact admission remains required.\n- custody:', 1)
    c.source('MEMORY.md').write_text(memory)
    tree = c.decode(before['docs/tasks/TYPE-REFERENCE-BOOK.md']['base64']).decode()
    tree = tree.replace('- Status: `active` / count/first10 private fixture repair; before enumeration',
        '- Status: `active` / next registered pipeline .1.2.11; before enumeration', 1)
    tree = tree.replace('Status: `active` / private generated-source expectation repair',
        'Status: `done` / selected proof; exact canonical admission required', 1)
    marker = '- ID: `TYPE-REFERENCE-BOOK.1.2.11`'
    assert tree.count(marker) == 1
    tree = tree.replace(marker,
        '  Private guard compatibility verified: three current expectations change only their reviewed count guards. Original native captures stay exact.236 assertions pass, including seven independent execution inputs per row. Actual expectation omission rejects; matched old guard/source expectations reject solely in behavior checks; exact production/test restoration passes. Draft3 retains11100 inputs/full modes, actual readonly0 and the completed canonical2 failure. Distinct doc5/artifact4/publication4 bind this candidate; all earlier publications remain immutable. Exact canonical receipt and normal hooks govern landing.\n\n' + marker, 1)
    c.source('docs/tasks/TYPE-REFERENCE-BOOK.md').write_text(tree)
    for path in ['LIVE_ACHIEVEMENT_STATUS.md','ROADMAP_V2.md','docs/TASK_TREE.md']:
        text = c.decode(before[path]['base64']).decode()
        marker = 'history680;book89/5 and actual heading RED'
        assert marker in text
        text = text.replace(marker, marker + ';private236', 1)
        c.source(path).write_text(text)
    c.write_new('final-docs4.json.gz', dict(before=before,after={path:c.read(path) for path in paths},result=result,
        scope='Intended clean post-landing handoff. Canonical2 failure and original native captures survive; exact staged canonical receipt and normal hooks govern admission.'))
    print('Private admission continuity closed; intended clean post-landing pointer and publication4 selected')


if __name__ == '__main__':
    main()
