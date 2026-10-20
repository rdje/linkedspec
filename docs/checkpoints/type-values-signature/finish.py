"""Bind the independently isolated original-control baseline into the current publication."""
import ast
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-signature/'
F = c.PREFIX
composed = json.loads(gzip.decompress((ROOT / (P + 'compose-proposals.json.gz')).read_bytes()))
assert c.unchanged(composed['after'])
isolated = json.loads(gzip.decompress((ROOT / (P + 'baseline-isolated-run.json.gz')).read_bytes()))
assert isolated['result'] == 'PASS' and isolated['healthy_guard'] == dict(original_log_attempts=0, tracked_write_attempts=0)
assert isolated['current_inputs_bytes_modes_unchanged'] and isolated['restored_inputs_bytes_modes_unchanged']
assert (ROOT / '.linkedspec-data/verification/type-values-signature-baseline-isolated.status').read_text().strip() == '0'
c.write_new(P + 'baseline-isolated-command.json', dict(
    command=['bash', 'tools/run_python_project_data.sh', P + 'baseline_isolated.py'], returncode=0,
    combined_output=c.read('.linkedspec-data/verification/type-values-signature-baseline-isolated.log'),
    status=c.read('.linkedspec-data/verification/type-values-signature-baseline-isolated.status'),
    instrument=c.read(P + 'baseline_isolated.py'), retention_producer=c.read(P + 'finish.py'),
    scope='Actual joined command/status and complete combined channels. Isolated baseline '
          'source/archive inputs and initial restored file modes precede execution.'))
paths = (F + 'signature_records.py', F + 'publish_signature.py', F + 'README.md')
before = {path: c.read(path) for path in paths}
records = c.decode(before[paths[0]]['base64']).decode()
old = "    assert c.unchanged(composed['after'])\n"
new = """    finished = signature_load('finish-proposals.json.gz')
    assert finished['producer'] == c.read(S + 'finish.py')
    for path, item in finished['before'].items():
        assert composed['after'][path] == item, path
    current_sources = dict(composed['after'], **finished['after'])
    assert c.unchanged(current_sources)
"""
assert records.count(old) == 1
records = records.replace(old, new, 1)
old = "    target[path] = composed['after'][path]\n"
assert records.count(old) == 1
records = records.replace(old, "    target[path] = current_sources[path]\n", 1)
anchor = "    assert grade['original_controls'] == observed['baseline_controls']\n"
new = """    isolated_plan = signature_load('baseline-isolated-inputs.json')
    isolated = signature_load('baseline-isolated-run.json.gz')
    command = signature_load('baseline-isolated-command.json')
    assert isolated_plan['producer'] == isolated['producer'] == c.read(S + 'baseline_isolated.py')
    assert command['instrument'] == c.read(S + 'baseline_isolated.py')
    assert command['retention_producer'] == c.read(S + 'finish.py')
    assert command['returncode'] == 0 and c.decode(command['status']['base64']).strip() == b'0'
    assert isolated['result'] == 'PASS' and isolated['calibration']
    assert isolated['healthy_guard'] == dict(original_log_attempts=0, tracked_write_attempts=0)
    assert isolated['current_inputs_bytes_modes_unchanged'] and isolated['restored_inputs_bytes_modes_unchanged']
    assert isolated['report'] == observed['baseline_report']
    assert isolated['controls'] == observed['baseline_controls']
    assert isolated['restored_inputs'] == 134 and isolated['restored_bytes'] == 84613241
    assert len(isolated_plan['restored']) == 134
    for path, item in isolated_plan['inputs'].items():
        assert all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')), path
""" + anchor
assert records.count(anchor) == 1
records = records.replace(anchor, new, 1)
anchor = '        first_control_key_error_retained=True)'
assert records.count(anchor) == 1
records = records.replace(anchor, '        original_baseline_isolated=True, first_control_key_error_retained=True)', 1)
publisher = c.decode(before[paths[1]]['base64']).decode()
anchor = "    paths.update(records.signature_load('historical-final-inputs.json')['inputs'])\n"
assert publisher.count(anchor) == 1
publisher = publisher.replace(anchor, anchor + "    paths.update(records.signature_load('baseline-isolated-inputs.json')['inputs'])\n", 1)
anchor = "            'proof inputs. Historical runtime observations, hashes and logs are unchanged. '"
assert publisher.count(anchor) == 1
addition = """
            'A separate original-control baseline supplies134 recovered logs under calibrated denial guards, '
            'records initial modes and reproduces all368 controls. The earlier outer baseline remains '
            'supplemental: its original-log locations and missing initial mode/guard observations are disclosed. '"""
publisher = publisher.replace(anchor, anchor + addition, 1)
readme = c.decode(before[paths[2]]['base64']).decode()
readme += ('\nThe first outer original-control baseline delegated historical log reads to\n'
    'their old locations. Its initial mode/denial closure is not invented. A\n'
    'separate baseline-isolated capture supplies all134 logs from the validated\n'
    'archive, records initial hashes/modes, calibrates actual read/write denials\n'
    'and reproduces the exact same report and368 controls with zero attempts.\n'
    'The current comparison uses this isolated baseline; the earlier outer result\n'
    'remains supplemental.\n')
texts = dict(zip(paths, (records, publisher, readme)))
for path in paths[:2]:
    ast.parse(texts[path], filename=path)
root_paths = ('CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
              'MEMORY.md', 'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md')
root_before = {path: c.read(path) for path in root_paths}
for path, item in root_before.items():
    raw = c.decode(item['base64']).decode()
    assert '8387747' in raw, path
    texts[path] = raw.replace('8387747', '8388046')
after = {path: dict(base64=c.encode(source.encode()), sha256=c.sha(source.encode()),
    mode=(before.get(path) or root_before[path])['mode']) for path, source in texts.items()}
c.write_new(P + 'finish-proposals.json.gz', dict(before=before, after={path: after[path] for path in paths},
    root_before=root_before, root_after={path: after[path] for path in root_paths},
    producer=c.read(P + 'finish.py'),
    scope='Separate complete original-control baseline replaces the earlier outer baseline '
          'for current claim evidence. All original reports/actors remain. Root continuity '
          'uses the newly measured8388046 Knowledge bytes; the old values remain in exact '
          'candidate/source snapshots. No historical observation or source hash is refreshed.'), packed=True)
assert c.unchanged(before) and c.unchanged(root_before)
for path, item in after.items():
    (ROOT / path).write_bytes(c.decode(item['base64']))
    (ROOT / path).chmod(item['mode'])
    assert c.read(path) == item
print('Current publication requires isolated original controls; root Knowledge bytes aligned at8388046')
