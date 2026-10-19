"""Retain the complete current Knowledge source graph before actual generation."""
import subprocess
import common as c

paths = subprocess.check_output(['git', 'ls-files', 'docs/knowledge', 'docs/decisions'], cwd=c.ROOT, text=True).splitlines()
paths = [path for path in paths if path.endswith('.md')]
paths += ['.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
    'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
    'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
    'docs/checkpoints/knowledge-fields/metadata_oracle.py', c.PREFIX + 'common.py', c.PREFIX + 'capture-graph.py']
inputs = {path: c.read(path) for path in paths}
c.write_new(c.PREFIX + 'graph-inputs.json.gz', dict(inputs=inputs), packed=True)
runs = []
for command in (['bash', 'knowledge-map/scripts/gen_knowledge_map.sh'], ['bash', 'knowledge-map/scripts/check_knowledge_map.sh']):
    runs.append(c.run(command))
    if runs[-1]['returncode']:
        break
mapping = c.read('KNOWLEDGE_MAP.md')
c.write_new(c.PREFIX + 'graph-run.json.gz', dict(runs=runs, mapping=mapping,
    unchanged=c.unchanged(inputs)), packed=True)
print('Current Knowledge generation/check exits:', [run['returncode'] for run in runs])
