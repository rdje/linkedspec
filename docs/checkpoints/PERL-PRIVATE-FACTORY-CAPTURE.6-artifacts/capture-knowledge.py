"""Capture the complete1488-source current map after the one new artifact fact."""
import gzip
import json
import subprocess
from pathlib import Path
import artifact as a

manifest = a.load_manifest()
old_path = a.PREFIX + 'knowledge-inputs.json.gz'
old_raw = (a.ROOT / old_path).read_bytes()
assert a.sha(old_raw) == manifest['inputs'][old_path]['sha256']
old = json.loads(gzip.decompress(old_raw))
before = {path: old['current'][path] for path in old['original']}
assert len(before) == 1487
paths = sorted(path.relative_to(a.ROOT).as_posix() for directory in ('docs/knowledge', 'docs/decisions')
               for path in (a.ROOT / directory).rglob('*.md') if path.is_file())
assert set(paths) == set(before) | {a.CARD} and len(paths) == 1488
extra = ['.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
         'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
         'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
         a.HOME + 'capture-knowledge.py', a.MANIFEST, a.HOME + 'reader-projection.json.gz']
current = {}
for path in paths + extra:
    source = a.ROOT / path
    value = source.read_bytes()
    current[path] = dict(bytes_base64=a.encode(value), sha256=a.sha(value), mode=source.stat().st_mode & 0o7777)
    if path == a.CARD:
        assert value == a.decode(manifest['proposal'][path]['base64'])
    elif path in before:
        assert value == a.decode(before[path]['bytes_base64']) and current[path]['mode'] == before[path]['mode']
total = sum(len(a.decode(current[path]['bytes_base64'])) for path in paths if path.startswith('docs/knowledge/'))
assert total == manifest['knowledge_bytes'] <= 8388608
command = ['bash', 'knowledge-map/scripts/gen_knowledge_map.sh']
generated = subprocess.run(command, cwd=a.ROOT, capture_output=True)
value = (a.ROOT / a.MAP).read_bytes()
current[a.MAP] = dict(bytes_base64=a.encode(value), sha256=a.sha(value), mode=(a.ROOT / a.MAP).stat().st_mode & 0o7777)
gate = ['bash', 'knowledge-map/scripts/check_knowledge_map.sh']
checked = subprocess.run(gate, cwd=a.ROOT, capture_output=True)
unchanged = all(a.sha((a.ROOT / path).read_bytes()) == item['sha256'] and
                (a.ROOT / path).stat().st_mode & 0o7777 == item['mode'] for path, item in current.items())
packed = gzip.compress(json.dumps(dict(before=before, current=current), sort_keys=True).encode(), mtime=0)
with (a.ROOT / (a.HOME + 'knowledge-inputs.json.gz')).open('xb') as output: output.write(packed)
report = dict(producer_sha256=a.sha(Path(__file__).read_bytes()), capsule_sha256=a.sha(packed),
    original669_capsule_sha256=a.sha(old_raw), original_markdown=1487, current_markdown=1488,
    facts=1350, question_keys=10453, knowledge_bytes=total, added_cards=[a.CARD], inputs_unchanged=unchanged,
    inputs={path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in current.items()},
    generation=dict(command=command, returncode=generated.returncode, stdout_base64=a.encode(generated.stdout), stderr_base64=a.encode(generated.stderr)),
    check=dict(command=gate, returncode=checked.returncode, stdout_base64=a.encode(checked.stdout), stderr_base64=a.encode(checked.stderr)),
    scope='Full1487 source graph from the actual uncommitted669 context remains exact. One new '
          'artifact fact is added; all current Markdown/config bytes precede generation, generated '
          'map precedes the actual check, and every byte/mode is guarded after both commands. '
          'The old graph is supplied archival data, not a falsely named Git revision.')
with (a.ROOT / (a.HOME + 'knowledge.json')).open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
assert generated.returncode == checked.returncode == 0 and unchanged
assert not generated.stdout and generated.stderr == b'knowledge-map: wrote KNOWLEDGE_MAP.md (1350 facts, 10453 question keys)\n'
assert not checked.stdout and checked.stderr == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
print('Current artifact Knowledge PASS:1488/1350/10453;one new fact;bytes', total)
