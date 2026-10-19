"""Capture complete current Knowledge after lossless canonical-home consolidation."""
import gzip
import json
import subprocess
from pathlib import Path
import route as r

manifest = r.load()
path = r.ARTIFACTS + 'knowledge-inputs.json.gz'
old_raw = (r.ROOT / path).read_bytes()
assert r.sha(old_raw) == manifest['inputs'][path]['sha256']
old = json.loads(gzip.decompress(old_raw))
before_paths = set(old['before']) | {r.OLD_CARD}
before = {path: old['current'][path] for path in before_paths}
assert len(before) == 1488
paths = sorted(path.relative_to(r.ROOT).as_posix() for directory in ('docs/knowledge', 'docs/decisions')
               for path in (r.ROOT / directory).rglob('*.md') if path.is_file())
assert set(paths) == before_paths - {r.OLD_CARD} and len(paths) == 1487
extra = ['.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
         'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
         'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
         r.SELF, r.MANIFEST, r.PREFIX + 'capture-knowledge.py']
current = {}
for path in paths + extra:
    source = r.ROOT / path
    value = source.read_bytes()
    current[path] = dict(bytes_base64=r.encode(value), sha256=r.sha(value), mode=source.stat().st_mode & 0o7777)
    if path == r.CARD:
        assert value == r.decode(manifest['proposal'][path]['base64'])
    elif path in before:
        assert value == r.decode(before[path]['bytes_base64']) and current[path]['mode'] == before[path]['mode']
total = sum(len(r.decode(current[path]['bytes_base64'])) for path in paths if path.startswith('docs/knowledge/'))
assert total == manifest['knowledge_bytes'] <= 8388608
command = ['bash', 'knowledge-map/scripts/gen_knowledge_map.sh']
generated = subprocess.run(command, cwd=r.ROOT, capture_output=True)
value = (r.ROOT / r.MAP).read_bytes()
current[r.MAP] = dict(bytes_base64=r.encode(value), sha256=r.sha(value), mode=(r.ROOT / r.MAP).stat().st_mode & 0o7777)
gate = ['bash', 'knowledge-map/scripts/check_knowledge_map.sh']
checked = subprocess.run(gate, cwd=r.ROOT, capture_output=True)
unchanged = all(r.sha((r.ROOT / path).read_bytes()) == item['sha256'] and
                (r.ROOT / path).stat().st_mode & 0o7777 == item['mode'] for path, item in current.items())
packed = gzip.compress(json.dumps(dict(before=before, current=current), sort_keys=True).encode(), mtime=0)
with (r.ROOT / (r.PREFIX + 'knowledge-inputs.json.gz')).open('xb') as output: output.write(packed)
report = dict(producer_sha256=r.sha(Path(__file__).read_bytes()), capsule_sha256=r.sha(packed),
    before696_capsule_sha256=r.sha(old_raw), before_markdown=1488, current_markdown=1487,
    facts=1349, question_keys=10453, knowledge_bytes=total, changed_cards=[r.CARD], removed_cards=[r.OLD_CARD],
    inputs_unchanged=unchanged,
    inputs={path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in current.items()},
    generation=dict(command=command, returncode=generated.returncode, stdout_base64=r.encode(generated.stdout), stderr_base64=r.encode(generated.stderr)),
    check=dict(command=gate, returncode=checked.returncode, stdout_base64=r.encode(checked.stdout), stderr_base64=r.encode(checked.stderr)),
    scope='Full actual1488-source before graph stays recoverable from the supplied696 context. '
          'Current1487 source graph consolidates all new questions/evidence/body in the richer '
          'existing canonical card, removes only the redundant new card, and preserves all other '
          'Markdown bytes/modes. Sources precede generation; generated map precedes actual check. '
          'Collection and byte ceilings remain unchanged.')
with (r.ROOT / (r.PREFIX + 'knowledge.json')).open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
assert generated.returncode == checked.returncode == 0 and unchanged
assert not generated.stdout and generated.stderr == b'knowledge-map: wrote KNOWLEDGE_MAP.md (1349 facts, 10453 question keys)\n'
assert not checked.stdout and checked.stderr == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
print('Canonical-home Knowledge PASS:1487/1349/10453;one changed card;unchanged limits;bytes', total)
