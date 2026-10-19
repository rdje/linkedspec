"""Retain the actual existing projection-size denial before format containment."""
import gzip
import json
import subprocess
from pathlib import Path
import common as c

epoch_raw = (c.ROOT / (c.HOME + 'after.json.gz')).read_bytes()
epoch = json.loads(gzip.decompress(epoch_raw))
mapping = c.decode(epoch['map_base64'])
assert c.sha(mapping) == epoch['map_sha256'] and len(mapping.splitlines()) == 22596
assert c.read('knowledge-map/scripts/gen_knowledge_map.sh')['sha256'] == epoch['inputs']['knowledge-map/scripts/gen_knowledge_map.sh']['sha256']
assert not subprocess.check_output(['git', 'diff', '--cached', '--name-only'], cwd=c.ROOT)
before = c.read('KNOWLEDGE_MAP.md')
assert c.decode(before['base64']) == subprocess.check_output(['git', 'show', c.BASE + ':KNOWLEDGE_MAP.md'], cwd=c.ROOT)
paths = ['scripts/check_readme_stability.sh', 'scripts/check_readme_routing_pressure.pl',
         'doctrine/readme_stability/routes.jsonl', 'README.md', 'README_POLICY.md',
         'tools/project_data_env.sh', 'tools/project_data_run.sh',
         c.HOME + 'capture-pressure.py', c.HOME + 'common.py', c.HOME + 'after.json.gz',
         c.HOME + 'review-epoch.py', c.HOME + 'review-epoch.json']
inputs = {path: c.read(path) for path in paths}
registry = [json.loads(line) for line in c.decode(inputs['doctrine/readme_stability/routes.jsonl']['base64']).decode().splitlines()]
limits = next(row['limits'] for row in registry if row.get('id') == 'knowledge_map')
assert limits == dict(max_bytes=8388608, max_lines=22500)
proposal = dict(result='PASS', base=c.BASE, original_map=before,
                candidate_map_base64=c.encode(mapping), candidate_map_sha256=c.sha(mapping),
                candidate_lines=22596, candidate_bytes=len(mapping), unchanged_limits=limits,
                inputs=inputs, producer_base64=c.encode(Path(__file__).read_bytes()),
                scope='The exact captured successful first epoch remains immutable. This installs '
                      'its actual generated value to exercise the unchanged real pressure gate; '
                      'complete tracked working-tree differences from real activation Git recover '
                      'the gate candidate. No policy, registry or old source measurement changes.')
c.write_new(c.HOME + 'pressure-preparation.json.gz', proposal, packed=True)
(c.ROOT / 'KNOWLEDGE_MAP.md').write_bytes(mapping)
command = ['git', 'diff', '--binary', '--full-index', c.BASE, '--']
tracked_diff = subprocess.check_output(command, cwd=c.ROOT)
gate = c.run(['bash', 'scripts/check_readme_stability.sh'])
unchanged = c.unchanged(inputs) and (c.ROOT / 'KNOWLEDGE_MAP.md').read_bytes() == mapping
assert subprocess.check_output(command, cwd=c.ROOT) == tracked_diff
record = dict(result='observed RED', command=gate, tracked_diff_base64=c.encode(tracked_diff),
              tracked_diff_sha256=c.sha(tracked_diff), candidate_sha256=c.sha(mapping),
              candidate_lines=22596, limits=limits, inputs_unchanged=unchanged,
              preparation_sha256=c.sha((c.ROOT / (c.HOME + 'pressure-preparation.json.gz')).read_bytes()),
              producer_sha256=c.sha(Path(__file__).read_bytes()),
              scope='Actual existing full pressure checker observes the candidate in worktree '
                    'mode with no staged variant. Complete actual channels and exact tracked '
                    'candidate difference are retained; registered sources/limits and every '
                    'tracked candidate byte remain unchanged during the command.')
c.write_new(c.HOME + 'pressure-red.json.gz', record, packed=True)
assert unchanged and gate['returncode'] != 0
channels = c.decode(gate['stdout_base64']) + c.decode(gate['stderr_base64'])
assert b'knowledge_map exceeds control:' in channels and b'22596/22500' in channels, gate
print('Actual unchanged pressure RED retained:knowledge_map22596/22500;exact candidate unchanged')
