"""Independent finite task-contract preservation; no migration or SDK replay."""
import argparse
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import stat
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.34'
TREE = 'NONCURRENT-HELPER-CODE-PURGE'
TARGET = 'docs/tasks/' + TREE + '.md'
MANIFEST = 'docs/history/task-narrative-epochs/' + OWNER + '.json'
CORE = ('Status', 'Goal', 'Acceptance', 'Dependencies', 'Children', 'Parent',
        'Verification tier', 'Focused checks', 'Canonical trigger', 'Claim verification',
        'Commit', 'Commit subject', 'Planned verification tier', 'Planned focused checks',
        'Planned canonical trigger', 'Planned claim verification', 'Superseded by')


def require(value, reason):
    if not value:
        raise ValueError(reason)


def recover(stem):
    identities = json.loads((BASE / (stem + '-identities.json')).read_bytes())
    inputs = {}
    with tarfile.open(BASE / (stem + '.tar.gz')) as archive:
        for member in archive:
            path = PurePosixPath(member.name)
            require(member.isfile() and not path.is_absolute() and '..' not in path.parts
                    and str(path) == member.name and member.name not in inputs, 'archive namespace')
            body = archive.extractfile(member).read()
            row = identities[member.name]
            require(len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'archive body')
            require(member.mode == row['mode'], 'archive mode')
            inputs[member.name] = (body, member.mode)
    require(inputs.keys() == identities.keys(), 'archive population')
    return inputs


def split(body):
    require(body.count(b'\n## Current Frontier\n') == 1, 'exact current frontier')
    first, last = body.split(b'## Current Frontier\n', 1)
    matches = list(re.finditer(rb'^- ID: `([^`\n]+)`\n', first, re.M))
    require(matches, 'task nodes')
    rows = {}
    for index, match in enumerate(matches):
        key = match[1].decode()
        require(key not in rows, 'unique ordered IDs')
        rows[key] = first[match.start():matches[index + 1].start() if index + 1 < len(matches) else len(first)]
    return first[:matches[0].start()], rows, b'## Current Frontier\n' + last


def fields(body):
    # This state machine is independent of the production regex parser.
    result, current = {}, None
    for line in body.splitlines(keepends=True)[1:]:
        label = re.match(rb'^  ([A-Za-z][A-Za-z /()-]*):', line)
        if label:
            current = label[1].decode()
            require(current not in result or current not in CORE, 'duplicate core field')
            result[current] = line
        elif current is not None and (line.startswith(b'    ') or line.startswith(b'\t')):
            result[current] += line
        else:
            current = None
    return result


def validate(before, after, manifest, mode):
    require(mode == 0o644, 'target mode')
    require(manifest['tree'] == TREE and manifest['epoch'] == OWNER, 'epoch identity')
    require(manifest['source_commit'] == 'e476d208dcee58f67ca4d0d7a950d5aa8bdcab00'
            and manifest['source_path'] == TARGET, 'source identity')
    require(manifest['sha256'] == hashlib.sha256(before).hexdigest()
            and manifest['bytes'] == len(before) and manifest['lines'] == before.count(b'\n'), 'source body identity')
    require(hashlib.sha1(b'blob ' + str(len(before)).encode() + b'\0' + before).hexdigest() == manifest['source_blob'], 'source Git address')
    prefix, old, tail = split(before)
    after_prefix, now, after_tail = split(after)
    require(prefix == after_prefix, 'complete prefix')
    require(tail == after_tail, 'complete frontier and trailing bytes')
    require(list(old) == list(now), 'ordered current IDs')
    selected = set(manifest['selected'])
    require(manifest['selected'] == sorted(selected) and selected <= old.keys(), 'selected population')
    expected_selected = set()
    for key, node in old.items():
        values, current = fields(node), fields(now[key])
        for label in CORE:
            require(values.get(label) == current.get(label), 'CORE field:' + key + '/' + label)
        pointer = (f'  Narrative epoch: `{OWNER}`; exact accepted source via '
                   f'`bash tools/run_python_project_data.sh tools/read_task_narrative.py '
                   f'--tree {TREE} --epoch {OWNER} --id {key}`.\n\n').encode()
        rendered = node.splitlines(keepends=True)[0] + b''.join(value for label, value in values.items() if label in CORE) + pointer
        eligible = bool(re.match(rb'  Status: `(done|completed|closed|superseded)`', values.get('Status', b'')))
        eligible = eligible and b'  Narrative:' not in node and b'  Narrative epoch:' not in node and len(rendered) < len(node)
        if eligible:
            require('Scope' not in values, 'selected scope field loss')
            expected_selected.add(key)
        if key in selected:
            require(now[key] == rendered, 'exact selected contract and pointer')
        else:
            require(now[key] == node, 'complete unselected body')
    require(selected == expected_selected, 'independent exact selected set')
    return dict(ids=len(old), selected=len(selected), unselected=len(old) - len(selected),
                before_bytes=len(before), after_bytes=len(after), saved_bytes=len(before) - len(after), tail_bytes=len(tail))


def channels(tag):
    folder = BASE / 'commands'
    require((folder / (tag + '-exit.txt')).read_text() == '0\n', 'actual exit:' + tag)
    require(gzip.decompress((folder / (tag + '-stderr.gz')).read_bytes()) == b'', 'actual stderr:' + tag)
    return gzip.decompress((folder / (tag + '-stdout.gz')).read_bytes())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--current', action='store_true')
    args = parser.parse_args()
    before_inputs, after_inputs = recover('before'), recover('after')
    for name, (body, permissions) in before_inputs.items():
        if name.startswith(str(BASE) + '/') and name.endswith('.py'):
            require(Path(name).read_bytes() == body and stat.S_IMODE(Path(name).stat().st_mode) == permissions,
                    'retained checkpoint producer identity')
    before, original_mode = before_inputs[TARGET]
    after, mode = after_inputs[TARGET]
    require(original_mode == mode, 'original/current archived mode')
    manifest = json.loads(after_inputs[MANIFEST][0])
    result = validate(before, after, manifest, mode)
    proposal = json.loads(before_inputs[str(BASE / 'scan.json')][0])
    chosen, = [row for row in proposal['sources'] if row['tree'] == TREE]
    require(chosen['compatible'] and chosen['proposed_saved_bytes'] == result['saved_bytes'], 'preflight and actual capacity')
    require(sorted(row['id'] for row in chosen['selected']) == manifest['selected'], 'preflight selected IDs')
    require(channels('target-source') == before and channels('query-all') == before, 'actual source/whole query')
    require(b'bytes renewed' in channels('migration'), 'actual epoch result')
    nodes = split(before)[1]
    queries = json.loads((BASE / 'queries.json').read_bytes())
    require([row['id'] for row in queries] == list(nodes), 'every public ID query')
    for row in queries:
        value = channels(row['tag'])
        require(value == nodes[row['id']] and hashlib.sha256(value).hexdigest() == row['sha256'], 'exact public node query')
    legacy = BASE / 'commands'
    require((legacy / 'prior-pressure-current-exit.txt').read_text() == '1\n'
            and b'ValueError: current task identity' in gzip.decompress((legacy / 'prior-pressure-current-stderr.gz').read_bytes()), 'dated strict-reader refusal')
    controls = {}
    for kind in ('prefix', 'tail', 'status', 'goal', 'omitted-node', 'unselected-body', 'pointer', 'source', 'selection', 'mode'):
        altered, changed, permissions = after, copy.deepcopy(manifest), mode
        if kind == 'prefix':
            altered = b'!' + after[1:]
        elif kind == 'tail':
            altered = after[:-1]
        elif kind in ('status', 'goal'):
            label = b'  Status: `done`' if kind == 'status' else b'  Goal: '
            altered = after.replace(label, b'  Status: `pending`' if kind == 'status' else b'  Goal: altered ', 1)
        elif kind == 'omitted-node':
            node = next(iter(split(after)[1].values()))
            altered = after.replace(node, b'', 1)
        elif kind == 'unselected-body':
            key = next(key for key in nodes if key not in manifest['selected'])
            node = split(after)[1][key]
            altered = after.replace(node, node + b'changed unselected body\n', 1)
        elif kind == 'pointer':
            altered = after.replace(b'  Narrative epoch:', b'  Wrong epoch:', 1)
        elif kind == 'source':
            changed['source_blob'] = '0' * 40
        elif kind == 'selection':
            changed['selected'].pop()
        else:
            permissions = 0o755
        require(altered != after or changed != manifest or permissions != mode, 'effective control')
        try:
            validate(before, altered, changed, permissions)
        except ValueError as error:
            controls[kind] = dict(result='RED', reason=str(error))
        else:
            raise ValueError('control accepted:' + kind)
    result.update(result='PASS', controls=controls, public_queries=len(queries) + 1,
                  limits='Finite named task preservation only; original measurements, runtime behavior and code are unchanged. No SDK, whole-project reading, physical reclamation or complete native/source-origin custody claim;4.2/SESSION5 remain.')
    normal = gzip.decompress((BASE / 'prior-normal.log.gz').read_bytes())
    normal_record = json.loads((BASE / 'prior-normal.json').read_bytes())
    require(hashlib.sha256(normal).hexdigest() == normal_record['sha256']
            and b'doctrines: ALL 10 enforced doctrines PASS.' in normal and b'[main e476d208d]' in normal,
            'preceding complete normal log')
    telemetry_rows = json.loads((BASE / 'telemetry-identities.json').read_bytes())
    for name, row in telemetry_rows.items():
        path = Path(name)
        require(hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256']
                and stat.S_IMODE(path.stat().st_mode) == row['mode'], 'retained telemetry metadata')
    telemetry = json.loads((BASE / 'telemetry/result.json').read_bytes())
    require(telemetry['head'] == 'e476d208dcee58f67ca4d0d7a950d5aa8bdcab00'
            and telemetry['cached_origin_main'] == '4683555ec51f04b8977812ce4e984c5cc6e6f42c', 'dated operational refs')
    result['operational_estimate_bytes'] = telemetry['estimated_non_thin_pack_bytes']
    result['operational_limits'] = 'Retained primary output only; independent actual-pack falsification30 and complete raw-artifact/native/physical closure4.2 remain. No remote freshness, actual wire or future-size promise.'
    if args.current:
        for name, (body, permissions) in after_inputs.items():
            path = Path(name)
            require(path.read_bytes() == body and stat.S_IMODE(path.stat().st_mode) == permissions, 'current target/manifest')
        result['current_target_and_manifest'] = 'PASS'
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
