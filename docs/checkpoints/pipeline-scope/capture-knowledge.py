"""Capture full current Knowledge with pre-run source custody and actual synchronization."""
import gzip
import json
import subprocess
from pathlib import Path
from common_final import ROOT, PREFIX, OLD, CARD, load, sha, encode, decode

original = load()
projection = json.loads((ROOT / (PREFIX + 'projection-preflight.json')).read_bytes())
old_capsule = json.loads(gzip.decompress(decode(
    original['inputs'][OLD + 'knowledge-inputs.json.gz']['base64'])))
paths = sorted(path.relative_to(ROOT).as_posix() for directory in ('docs/knowledge', 'docs/decisions')
               for path in (ROOT / directory).rglob('*.md') if path.is_file())
assert set(paths) == set(old_capsule['original']) and len(paths) == 1487
cards = projection['changed_cards']
extra = ['.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
         'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
         'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
         PREFIX + 'capture-knowledge.py', PREFIX + 'projection-preflight.json']
current = {}
for path in paths + extra:
    source = ROOT / path
    value = source.read_bytes()
    current[path] = dict(bytes_base64=encode(value), sha256=sha(value), mode=source.stat().st_mode & 0o7777)
    if path in cards:
        assert value == decode(projection['proposed'][path]['base64'])
    elif path in paths:
        assert value == decode(old_capsule['current'][path]['bytes_base64']), ('unchanged Markdown', path)
total = sum(len(decode(current[path]['bytes_base64'])) for path in paths if path.startswith('docs/knowledge/'))
assert total == projection['knowledge_bytes'] == 8384959 <= 8388608
generation = ['bash', 'knowledge-map/scripts/gen_knowledge_map.sh']
generated = subprocess.run(generation, cwd=ROOT, capture_output=True)
value = (ROOT / 'KNOWLEDGE_MAP.md').read_bytes()
current['KNOWLEDGE_MAP.md'] = dict(bytes_base64=encode(value), sha256=sha(value),
                                  mode=(ROOT / 'KNOWLEDGE_MAP.md').stat().st_mode & 0o7777)
gate = ['bash', 'knowledge-map/scripts/check_knowledge_map.sh']
checked = subprocess.run(gate, cwd=ROOT, capture_output=True)
unchanged = all(sha((ROOT / path).read_bytes()) == item['sha256'] and
                (ROOT / path).stat().st_mode & 0o7777 == item['mode'] for path, item in current.items())
capsule = gzip.compress(json.dumps(dict(original=old_capsule['original'], current=current), sort_keys=True).encode(), mtime=0)
with (ROOT / (PREFIX + 'knowledge-inputs.json.gz')).open('xb') as output: output.write(capsule)
changed_bodies = [path for path in cards if decode(current[path]['bytes_base64']).split(b'\n---\n', 1)[1] !=
                  decode(old_capsule['current'][path]['bytes_base64']).split(b'\n---\n', 1)[1]]
report = dict(producer_sha256=sha(Path(__file__).read_bytes()), capsule_sha256=sha(capsule),
              original_capsule_sha256=original['inputs'][OLD + 'knowledge-inputs.json.gz']['sha256'],
              markdown=1487, facts=1349, question_keys=10450, knowledge_bytes=total,
              changed_cards=cards, changed_bodies_from_draft=changed_bodies, inputs_unchanged=unchanged,
              inputs={path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in current.items()},
              generation=dict(command=generation, returncode=generated.returncode,
                  stdout_base64=encode(generated.stdout), stderr_base64=encode(generated.stderr)),
              check=dict(command=gate, returncode=checked.returncode,
                  stdout_base64=encode(checked.stdout), stderr_base64=encode(checked.stderr)),
              scope='Whole original1487 Markdown remains at real activation64b66167c. Full current '
                    'Markdown/config sources are captured before generation, generated map before '
                    'the actual check, and every current byte/mode is guarded after both commands. '
                    'Fifteen current routes and one body differ from the saved625 draft; all other '
                    'current Markdown matches that independently reverified original source graph.')
with (ROOT / (PREFIX + 'knowledge.json')).open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
assert generated.returncode == checked.returncode == 0 and unchanged
assert not generated.stdout and generated.stderr == b'knowledge-map: wrote KNOWLEDGE_MAP.md (1349 facts, 10450 question keys)\n'
assert not checked.stdout and checked.stderr == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert changed_bodies == [CARD]
print('Current Knowledge PASS:1487/1349/10450;15 routes/one body;8384959 bytes')
