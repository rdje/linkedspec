"""Retain rejected/shortened task narratives under the unchanged collection cap."""
import argparse
import copy
import gzip
import json
from pathlib import Path
import re
import subprocess

import model as m
from capture_runtime import read_local

BEFORE = m.HERE / 'narrative-before.json.gz'
AFTER = m.HERE / 'narrative-after.json.gz'
REGISTRY = 'doctrine/readme_stability/routes.jsonl'
NODE = re.compile(rb'^- ID: `([^`\n]+)`\n(.*?)(?=^- ID:|^## |\Z)', re.M | re.S)


def write(path, value):
    m.require(not path.exists(), 'narrative capture is one-shot')
    raw = json.dumps(value, separators=(',', ':')).encode()
    path.write_bytes(gzip.compress(raw, mtime=0))
    m.require(gzip.decompress(path.read_bytes()) == raw, 'narrative archive recovery')


def capture(before):
    registry = read_local(REGISTRY)
    route, = [json.loads(line) for line in registry.splitlines()
              if json.loads(line).get('id') == 'task_evidence']
    names = sorted({p.relative_to(m.ROOT).as_posix() for pattern in route['members']
                    for p in m.ROOT.glob(pattern) if p.is_file()})
    images = {name: m.packet(read_local(name)) for name in names}
    for name, image in images.items():
        if before:
            m.require(m.git('cat-file', 'blob', ':' + name) == m.decode(image),
                      'rejected candidate differs from its index')
    result = {'producer': m.packet(Path(__file__).read_bytes()),
              'registry': m.packet(registry), 'inputs': images,
              'index_paths': m.packet(subprocess.check_output(['git', 'ls-files', '-z'], cwd=m.ROOT)),
              'limits': 'Task-collection bytes/contracts only; no transitive hook/toolchain closure. '
                        'The first hook attempt was stopped after an actual recorded cap rejection; '
                        'remaining checks from that rejected attempt receive no passing credit.'}
    if before:
        result['hook_log'] = m.packet(read_local('.linkedspec-data/logs/publication-custody-commit.log'))
        result['hook_attempt_exit'] = 143
    write(BEFORE if before else AFTER, result)


def population(record):
    m.require(m.decode(record['producer']) == Path(__file__).read_bytes(), 'narrative producer identity')
    route, = [json.loads(line) for line in m.decode(record['registry']).splitlines()
              if json.loads(line).get('id') == 'task_evidence']
    indexed = {name.decode() for name in m.decode(record['index_paths']).split(b'\0') if name}
    # Every registered pattern here is a top-level filename glob. Path.match
    # agrees with that contract; nested paths cannot enter this population.
    expected = {name for name in indexed if any(Path(name).match(pattern) for pattern in route['members'])}
    m.require(set(record['inputs']) == expected, 'narrative input population')
    raw = {name: m.decode(image) for name, image in record['inputs'].items()}
    contracts = {}
    for name, body in raw.items():
        if not name.endswith('.md'):
            continue
        for match in NODE.finditer(body):
            key = (name, match[1])
            m.require(key not in contracts, 'duplicate narrative node')
            contracts[key] = re.findall(rb'^  (?:Status|Goal|Acceptance|Dependencies):.*$', match[2], re.M)
    return route, raw, contracts


def validate(before, after):
    old_route, old, old_contracts = population(before)
    route, new, contracts = population(after)
    m.require(route == old_route and set(new) == set(old), 'unchanged narrative authority/population')
    m.require(contracts == old_contracts, 'current task contract preservation')
    limit = route['limits']['max_total_bytes']
    old_bytes = sum(map(len, old.values()))
    new_bytes = sum(map(len, new.values()))
    m.require(old_bytes > limit and new_bytes <= limit, 'narrative cap boundary')
    needle = f'aggregate bytes {old_bytes}/{limit}'.encode()
    m.require(needle in m.decode(before['hook_log']) and before['hook_attempt_exit'] == 143,
              'actual rejected hook observation')
    return {'before_bytes': old_bytes, 'after_bytes': new_bytes, 'limit_bytes': limit,
            'current_node_contracts': len(contracts), 'remaining_bytes': limit - new_bytes}


def review():
    before = json.loads(gzip.decompress(BEFORE.read_bytes()))
    after = json.loads(gzip.decompress(AFTER.read_bytes()))
    result = validate(before, after)
    broken = copy.deepcopy(after)
    broken['inputs'].pop(next(iter(broken['inputs'])))
    try:
        validate(before, broken)
    except ValueError as error:
        m.require(str(error) == 'narrative input population', 'unrelated missing-input refusal')
    else:
        raise ValueError('missing narrative input accepted')
    broken = copy.deepcopy(after)
    name = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
    body = m.decode(broken['inputs'][name])
    m.require(b'  Acceptance:' in body, 'acceptance control target')
    broken['inputs'][name] = m.packet(body.replace(b'  Acceptance:', b'  Lost acceptance:', 1))
    try:
        validate(before, broken)
    except ValueError as error:
        m.require(str(error) == 'current task contract preservation', 'unrelated contract refusal')
    else:
        raise ValueError('lost task acceptance accepted')
    result['rejected_controls'] = ['missing-input', 'lost-acceptance']
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture-before', action='store_true')
    parser.add_argument('--capture-after', action='store_true')
    args = parser.parse_args()
    m.require(not (args.capture_before and args.capture_after), 'choose one capture phase')
    if args.capture_before or args.capture_after:
        capture(args.capture_before)
    if not args.capture_before:
        review()
