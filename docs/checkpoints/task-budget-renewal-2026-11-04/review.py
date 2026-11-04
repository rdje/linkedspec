"""Capture/review exact extraction inputs and actual focused outcomes; no migration on replay."""
import argparse
import base64
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OUTPUT = HERE / 'evidence.json.gz'
BASE = '659f19d748ddc9ddd6bc1c40c2c7b2d63107b138'
SOURCE = 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md'
EPOCH = 'docs/history/task-narrative-epochs/TYPE-REFERENCE-BOOK.1.2.20.2.json'


def require(value, reason):
    if not value:
        raise ValueError(reason)


def packet(raw):
    return {'sha256': hashlib.sha256(raw).hexdigest(), 'base64': base64.b64encode(raw).decode()}


def decode(image):
    raw = base64.b64decode(image['base64'])
    require(packet(raw) == image, 'evidence packet identity')
    return raw


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def source_image(name):
    cursor = ROOT
    for part in Path(name).parts:
        cursor /= part
        require(not cursor.is_symlink() and cursor.stat().st_dev == ROOT.stat().st_dev,
                'repository input boundary')
    raw = (ROOT / name).read_bytes()
    tracked = subprocess.run(['git', 'rev-parse', BASE + ':' + name], cwd=ROOT, capture_output=True)
    if tracked.returncode == 0:
        blob = tracked.stdout.decode().strip()
        if git('cat-file', 'blob', blob) == raw:
            return {'blob': blob, 'sha256': hashlib.sha256(raw).hexdigest(), 'bytes': len(raw)}
    return {'image': packet(raw)}


def recover(item):
    if 'image' in item:
        return decode(item['image'])
    raw = git('cat-file', 'blob', item['blob'])
    require(len(raw) == item['bytes'] and hashlib.sha256(raw).hexdigest() == item['sha256'],
            'retained Git input identity')
    return raw


def inputs():
    names = {'tools/task_narrative.py', 'tools/read_task_narrative.py',
             'tools/migrate_task_narrative.py', 'tools/test_task_narrative.py',
             'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
             'doctrine/readme_stability/routes.jsonl'}
    names.update(str(path.relative_to(ROOT)) for path in (ROOT / 'docs/tasks').glob('*.md'))
    names.update(str(path.relative_to(ROOT)) for path in (ROOT / 'docs/tasks').glob('*.index.jsonl'))
    for directory in ('docs/history/task-narrative', 'docs/history/task-narrative-epochs'):
        names.update(str(path.relative_to(ROOT)) for path in (ROOT / directory).rglob('*') if path.is_file())
    for tree in ('TYPE-REFERENCE-BOOK', 'SPEC-LANGUAGE-SELF-CONTAINMENT', 'SPEC-FORMAT-TERSE'):
        for direction in ('input', 'output'):
            names.add(f'docs/checkpoints/document-pressure-restoration/{tree}-task-{direction}.md.gz')
    return {name: source_image(name) for name in sorted(names)}


def oracle():
    sys.path.insert(0, str(ROOT / 'tools'))
    spec = importlib.util.spec_from_file_location('narrative_oracle', ROOT / 'tools/test_task_narrative.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def validate(record):
    require(record['owner'] == 'TYPE-REFERENCE-BOOK.1.2.20.2' and record['activation_commit'] == BASE,
            'extraction evidence identity')
    require(record['inputs_unchanged'], 'repo artifact inputs changed during focused proof')
    material = {name: recover(item) for name, item in record['inputs'].items()}
    for name in ('tools/task_narrative.py', 'tools/read_task_narrative.py',
                 'tools/migrate_task_narrative.py', 'tools/test_task_narrative.py'):
        require(material[name] == (ROOT / name).read_bytes(), 'reviewed producer changed')
    require(decode(record['review_source']) == Path(__file__).read_bytes(), 'review instrument changed')
    row = json.loads(material[EPOCH])
    before = git('cat-file', 'blob', row['source_blob'])
    require(before == git('cat-file', 'blob', BASE + ':' + SOURCE), 'exact accepted predecessor')
    after = material[SOURCE]
    independent = oracle()
    require(independent.contracts(before) == independent.contracts(after), 'independent contract preservation')
    old_nodes = independent.subject.nodes(before)[1]
    new_nodes = independent.subject.nodes(after)[1]
    require(set(old_nodes) == set(new_nodes), 'stable ID preservation')
    selected = set(row['selected'])
    require(all(old_nodes[key] == new_nodes[key] for key in old_nodes if key not in selected),
            'unselected/open body preservation')
    actual = record['focused']
    stdout, stderr = decode(actual['stdout']), decode(actual['stderr'])
    require(actual['returncode'] == 0 and not stderr, 'focused command outcome')
    match = re.search(rb'^task-narrative-epoch-controls: (.+)$', stdout, re.M)
    require(match is not None, 'observed epoch control names')
    denied = json.loads(match[1])
    require(len(denied) == len(set(denied)) and denied, 'observed epoch control population')
    expected = (f'task-narrative-epoch: {len(old_nodes)} IDs; {len(selected)} closed; '
                f'{len(old_nodes) - len(selected)} unaltered open/unselected bodies; {len(denied)} specific denials; '
                f'{len(before) - len(after)} bytes renewed').encode()
    require(expected in stdout, 'measured extraction versus actual test output')
    route, = [json.loads(line) for line in material['doctrine/readme_stability/routes.jsonl'].splitlines()
              if json.loads(line).get('id') == 'task_evidence']
    current_bytes = sum(len(raw) for name, raw in material.items()
                        if any(Path(name).match(pattern) for pattern in route['members']))
    require(current_bytes <= route['limits']['max_total_bytes'], 'unchanged task collection cap')
    return {'result': 'PASS', 'IDs': len(old_nodes), 'closed_narratives': len(selected),
            'unchanged_open_or_unselected': len(old_nodes) - len(selected),
            'renewed_bytes': len(before) - len(after), 'specific_denials': denied,
            'dated_collection_bytes': current_bytes, 'collection_limit': route['limits']['max_total_bytes'],
            'dated_remaining_bytes': route['limits']['max_total_bytes'] - current_bytes}


def capture():
    require(not OUTPUT.exists(), 'extraction evidence is one-shot')
    before = inputs()
    command = ['bash', 'tools/run_python_project_data.sh', 'tools/test_task_narrative.py']
    actual = subprocess.run(command, cwd=ROOT, capture_output=True)
    after = inputs()
    record = {'owner': 'TYPE-REFERENCE-BOOK.1.2.20.2', 'activation_commit': BASE,
              'inputs': before, 'review_source': packet(Path(__file__).read_bytes()),
              'inputs_unchanged': before == after,
              'focused': {'command': command, 'returncode': actual.returncode,
                          'stdout': packet(actual.stdout), 'stderr': packet(actual.stderr)},
              'limits': 'Dated direct repository producers/artifact inputs, retained Git content identities '
                        'and actual focused command channels. Unchanged inputs recover from the fixed Git source; '
                        'changed input bytes are retained. Temporary fixtures derive from these retained inputs. '
                        'OS/Python/Git implementation, process scheduling, concurrent adversaries, complete '
                        'canonical producer closure and runtime feature admission are not claimed. '
                        'The committed-manifest refusal uses an explicitly modeled prior Git manifest boundary.'}
    # Retain an actual failed run too; never overwrite its source/input epoch.
    raw = json.dumps(record, separators=(',', ':')).encode()
    try:
        result = validate(record)
    except Exception:
        ordinal = 1
        while (HERE / f'evidence-rejected-{ordinal:02}.json.gz').exists():
            ordinal += 1
        (HERE / f'evidence-rejected-{ordinal:02}.json.gz').write_bytes(gzip.compress(raw, mtime=0))
        raise
    OUTPUT.write_bytes(gzip.compress(raw, mtime=0))
    require(gzip.decompress(OUTPUT.read_bytes()) == raw, 'extraction evidence recovery')
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--record', action='store_true')
    args = parser.parse_args()
    result = capture() if args.record else validate(json.loads(gzip.decompress(OUTPUT.read_bytes())))
    print(json.dumps(result, sort_keys=True))
