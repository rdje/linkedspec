"""Use the retained reviewer in its actual original scanner context, then restore the candidate."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import partition_storage as storage

P = storage.P
proposal = storage.load('proposals.json.gz')
scanner = 'tools/check_executable_aggregate_selector_sources.py'
assert c.read(scanner) == proposal['after'][scanner]
original = c.read(P + 'partition_use.py')
source = c.decode(original['base64']).decode()
source = source.replace('partition_use.py', 'partition_use_context_probe.py').replace(
    'partition-use-inputs.json', 'partition-use-context-inputs.json').replace(
    "P + 'partition-use.json'", "P + 'partition-use-context.json'")
needle = "paths = set(baseline['inputs'])\n"
assert source.count(needle) == 1
source = source.replace(needle, needle + "paths.add('tools/check_executable_aggregate_selector_sources.py')\n", 1)
probe_path = P + 'partition_use_context_probe.py'
after = dict(base64=c.encode(source.encode()), sha256=c.sha(source.encode()), mode=0o644)
c.write_new(P + 'partition-context-plan.json.gz', dict(
    producer=c.read(P + 'partition_context.py'), original_probe=original, after={probe_path: after},
    candidate=proposal['after'][scanner], supplied=proposal['before'][scanner],
    first_input_manifest=c.read(P + 'partition-use-inputs.json'),
    first_output=c.read('.linkedspec-data/verification/type-values-selector-partition-use.log'),
    scope='The first retained-use attempt correctly rejects the current scanner delta '
          'against its original1303-source context; that failure is not behavioral RED. '
          'Supply the exact original scanner bytes on disk for the unchanged retained '
          'reviewer, declare that input explicitly, use new output names, and always '
          'restore the current independently tested scanner candidate.'),
    packed=True)
target = ROOT / probe_path
assert not target.exists()
target.write_bytes(source.encode())
target.chmod(after['mode'])
module = ROOT / scanner
run = None
try:
    module.write_bytes(c.decode(proposal['before'][scanner]['base64']))
    module.chmod(proposal['before'][scanner]['mode'])
    run = c.run(['bash', 'tools/run_python_project_data.sh', probe_path])
finally:
    module.write_bytes(c.decode(proposal['after'][scanner]['base64']))
    module.chmod(proposal['after'][scanner]['mode'])
restored = c.read(scanner) == proposal['after'][scanner]
c.write_new(P + 'partition-context.json', dict(run=run, restored=restored,
    producer=c.read(P + 'partition_context.py'), probe=c.read(probe_path),
    scope='New storage-use observation in explicitly supplied original scanner context; '
          'the candidate is restored byte for byte. Original runtime/native measurements '
          'and the genuine default837 baseline stay unchanged.'))
assert run and run['returncode'] == 0 and restored
assert storage.load('partition-use-context.json')['result'] == 'PASS'
print('Exact prior review uses partitions in original scanner context; candidate restored')
