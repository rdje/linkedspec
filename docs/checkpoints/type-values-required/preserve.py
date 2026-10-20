"""Preserve the whole823 draft and failed canonical3 source candidate before consumer edits."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-required/'
V = '.linkedspec-data/verification/type-values-'
assert sys.argv[1:] in ([], ['--baseline'])
claim = json.loads((ROOT / c.CLAIM).read_bytes())
bindings = claim['claims'][0]['durability']['inputs']
assert len(bindings) == 823
modes = json.loads((ROOT / (c.PREFIX + 'publication-signature.json')).read_bytes())['input_modes']
inputs = {}
for row in bindings:
    item = c.read(row['path'])
    assert item['sha256'] == row['sha256'] and item['mode'] == modes[row['path']], row['path']
    inputs[row['path']] = {key: item[key] for key in ('sha256', 'mode')}
if sys.argv[1:]:
    assert (ROOT / (V + 'required-readonly.status')).read_text().strip() == '0'
    c.write_new(P + 'baseline.json', dict(command=['bash', 'tools/run_python_project_data.sh', c.PREFIX + 'publish.py'],
        returncode=0, combined_output=c.read(V + 'required-readonly.log'),
        status=c.read(V + 'required-readonly.status'), claim=c.read(c.CLAIM),
        inputs=inputs, producer=c.read(P + 'preserve.py')))
    print('Actual whole823 default readonly baseline0 retained')
else:
    assert (ROOT / (V + 'canonical3.status')).read_text().strip() == '1'
    result = c.run(['git', 'diff', '--cached', '--name-status', '-z'])
    assert result['returncode'] == 0
    fields = c.decode(result['stdout_base64']).decode().split('\0')[:-1]
    assert len(fields) == 458 and all(kind in ('A', 'M') for kind in fields[::2])
    candidate = {}
    for kind, path in zip(fields[::2], fields[1::2]):
        blob = c.run(['git', 'show', ':' + path])
        assert blob['returncode'] == 0
        raw, actual = c.decode(blob['stdout_base64']), c.read(path)
        item = dict(status=kind, sha256=c.sha(raw), mode=actual['mode'])
        if path in inputs:
            assert item['sha256'] == inputs[path]['sha256'], path
            item['retained_path'] = path
        else:
            item['base64'] = c.encode(raw)
        candidate[path] = item
    names = ('method_general_return', 'array_receiver_required', 'scalar_receiver_required',
        'hash_receiver_required', 'array_end_required', 'hash_index_required', 'dropped_trim',
        'small_kind', 'method_kind', 'source_assignment_kind', 'ast_optional', 'formal_trim')
    paths = ['t/actionir_' + name + '_capture.t' for name in names]
    paths += ['docs/knowledge/perl-method-assignment-required-capture.md',
        'docs/linkedspec-book/src/development/documentation-workflow.md', 'KNOWLEDGE_MAP.md',
        c.PREFIX + 'publish.py', c.PREFIX + 'README.md']
    c.write_new(P + 'preservation.json.gz', dict(original_claim=c.read(c.CLAIM), inputs=inputs,
        before={path: c.read(path) for path in paths}, producer=c.read(P + 'preserve.py'),
        failed_candidate=dict(base_commit=c.BASE, changes=candidate),
        canonical=dict(command=['bash', 'tools/run_ci_local.sh'], returncode=1,
            combined_output=c.read(V + 'canonical3.log'), status=c.read(V + 'canonical3.status')),
        scope='Complete823/full129835 uncommitted draft and exact229-file staged source delta. '
              'Immutable bound artifacts retain their tracked bytes/hash/modes; mutable '
              'continuity/claim bytes are inline and every planned changed input has full '
              'before bytes. Canonical3 passes all earlier contracts and fails202 assertions '
              'across12 private consumers in its91-file/32235-assertion supplied population. '
              'No prior observation or historical Git identity is refreshed.'), packed=True)
    print('Whole823 publication and exact229-file failed candidate preserved')
