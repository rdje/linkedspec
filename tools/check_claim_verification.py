#!/usr/bin/env python3
"""Read-only claim evidence/identity check. Never execute recorded commands."""
import argparse
import copy
from collections import OrderedDict
from functools import lru_cache
import hashlib
import json
import re
import subprocess
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parent.parent
ID = re.compile(r"[A-Z][A-Z0-9-]*(?:\.[0-9]+)+\Z")
SHA = re.compile(r"[0-9a-f]{64}\Z")
REVISION = re.compile(r"[0-9a-f]{40}\Z")
MAX_RECORD_BYTES = 131072


def require(condition, message):
    if not condition:
        raise ValueError(message)


def text(value, label):
    require(isinstance(value, str) and bool(value.strip()), f"{label}: nonempty text required")


def keys(value, expected, label):
    require(isinstance(value, dict) and set(value) == set(expected), f"{label}: expected keys {expected}")


def path(value):
    text(value, 'path')
    parsed = PurePosixPath(value)
    require(not parsed.is_absolute() and str(parsed) == value
            and all(part not in ('', '.', '..', '.git') for part in parsed.parts)
            and not any(ord(c) < 32 for c in value), f"unsafe repository-relative path: {value!r}")
    return value


def git(*args):
    return subprocess.run(['git', '-C', str(ROOT), *args], check=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout


def strict_json(raw):
    require(len(raw) <= MAX_RECORD_BYTES, 'claim record exceeds its 128 KiB bound')

    def pairs(items):
        result = {}
        for key, value in items:
            require(key not in result, f'duplicate JSON key: {key}')
            result[key] = value
        return result

    def constant(value):
        raise ValueError(f'non-finite JSON value: {value}')

    return json.loads(raw, object_pairs_hook=pairs, parse_constant=constant)


def validate(record, record_path, read_input, check_owner):
    keys(record, ['version', 'owner', 'claims'], 'record')
    require(type(record['version']) is int and record['version'] == 1, 'unsupported record version')
    require(isinstance(record['owner'], str) and ID.fullmatch(record['owner']), 'invalid owner ID')
    require(record_path == f"docs/claims/{record['owner']}.json", 'record path/owner mismatch')
    require(isinstance(record['claims'], list) and record['claims'], 'record requires at least one claim')
    names = set()
    gaps = 0
    for claim in record['claims']:
        keys(claim, ['name', 'statement', 'scope', 'rederive', 'falsify', 'durability'], 'claim')
        for field in ('name', 'statement', 'scope'):
            text(claim[field], field)
        require(claim['name'] not in names, 'duplicate claim name')
        names.add(claim['name'])
        for leg in ('rederive', 'falsify', 'durability'):
            value = claim[leg]
            require(isinstance(value, dict), f'{leg}: object required')
            status = value.get('status')
            require(status in ('checked', 'gap'), f'{leg}: status must be checked or gap')
            if status == 'gap':
                keys(value, ['status', 'reason', 'repair_owner'], leg)
                text(value['reason'], f'{leg}.reason')
                check_owner(value['repair_owner'])
                gaps += 1
                continue
            if leg == 'rederive':
                fields = ['status', 'command', 'granularity', 'result']
            elif leg == 'falsify':
                fields = ['status', 'hypothesis', 'oracle', 'red_control']
            else:
                fields = ['status', 'mode', 'inputs']
                if value.get('mode') == 'historical':
                    fields.append('revision')
            keys(value, fields, leg)
            if leg != 'durability':
                for field in fields[1:]:
                    text(value[field], f'{leg}.{field}')
                continue
            require(value['mode'] in ('live', 'historical'), 'invalid durability mode')
            revision = value.get('revision')
            if revision is not None:
                require(isinstance(revision, str) and REVISION.fullmatch(revision), 'invalid historical revision')
            inputs = value['inputs']
            require(isinstance(inputs, list) and inputs, 'durability requires artifact inputs')
            paths = set()
            producers = 0
            for item in inputs:
                keys(item, ['path', 'sha256', 'role'], 'input')
                source = path(item['path'])
                require(source != record_path and source not in paths, 'self-referential or duplicate input')
                paths.add(source)
                require(item['role'] in ('producer', 'input'), 'invalid input role')
                producers += item['role'] == 'producer'
                require(isinstance(item['sha256'], str) and SHA.fullmatch(item['sha256']), 'invalid input SHA256')
                raw = read_input(source, revision)
                require(hashlib.sha256(raw).hexdigest() == item['sha256'],
                        f'stale input: {source}; remeasure or preserve an explicitly historical capture')
            require(producers > 0, 'checked durability requires a tracked producer input')
    return len(record['claims']), gaps


def index_files():
    result = {}
    for row in git('ls-files', '--stage', '-z').split(b'\0'):
        if not row:
            continue
        header, name = row.split(b'\t', 1)
        mode, blob, stage = header.decode('ascii').split()
        require(stage == '0', 'unmerged index cannot verify claims')
        result[name.decode('utf-8')] = (mode, blob)
    return result


class InputSnapshot:
    """Reuse immutable blobs and current owner identities within one index view."""

    def __init__(self, files, git_reader=None, cache_bytes=32 * 1024 * 1024):
        self.files = dict(files)
        self.git = git_reader or git
        self.cache_bytes = cache_bytes
        self.blobs = OrderedDict()
        self.blob_bytes = 0
        self.owners = None
        self.resolve = lru_cache(maxsize=4096)(self._resolve)

    def _resolve(self, source, revision):
        path(source)
        if revision is None:
            require(source in self.files, f'untracked input: {source}')
            mode, blob = self.files[source]
        else:
            rows = self.git('ls-tree', '-z', revision, '--', source).split(b'\0')
            require(len(rows) == 2 and rows[0], f'missing historical input: {source}')
            header, name = rows[0].split(b'\t', 1)
            mode, kind, blob = header.decode('ascii').split()
            require(kind == 'blob' and name.decode('utf-8') == source, 'historical input is not a file')
        require(mode in ('100644', '100755'), f'input is not a tracked regular file: {source}')
        return blob

    def read(self, source, revision=None):
        blob = self.resolve(source, revision)
        if blob in self.blobs:
            self.blobs.move_to_end(blob)
            return self.blobs[blob]
        raw = self.git('cat-file', 'blob', blob)
        if len(raw) <= self.cache_bytes:
            while self.blobs and self.blob_bytes + len(raw) > self.cache_bytes:
                _, removed = self.blobs.popitem(last=False)
                self.blob_bytes -= len(removed)
            self.blobs[blob] = raw
            self.blob_bytes += len(raw)
        return raw

    def check_owner(self, owner):
        require(isinstance(owner, str) and ID.fullmatch(owner), 'invalid gap repair owner')
        if self.owners is None:
            self.owners = self._current_owners()
        matches = self.owners.get(owner, [])
        require(len(matches) == 1 and matches[0], f'gap repair owner is not open: {owner}')

    def _current_owners(self):
        # Current task identity excludes only index-registered immutable parts.
        immutable = set()
        for source in self.files:
            if source.startswith('docs/tasks/') and source.endswith('.index.jsonl'):
                for line in self.read(source).splitlines():
                    part = json.loads(line)
                    if part.get('type') == 'task_tree_part' and part.get('mutable') is False:
                        immutable.add(part['path'])
        owners = {}
        for source in self.files:
            if source.startswith('docs/tasks/') and source.endswith('.md') and source not in immutable:
                raw = self.read(source).decode('utf-8')
                for node in re.finditer(r'^- ID: `([^`\n]+)`\n(.*?)(?=^- ID:|^## |\Z)', raw, re.M | re.S):
                    owners.setdefault(node[1], []).append(bool(re.search(
                        r'^  Status: `(pending|active|blocked)`', node[2], re.M)))
        return owners


def run_check():
    files = index_files()
    snapshot = InputSnapshot(files)
    read_input = snapshot.read
    check_owner = snapshot.check_owner

    policy = read_input('DOCTRINE_ENFORCEMENT.md').decode('utf-8')
    review = read_input('COMMIT.md').decode('utf-8')
    require('## 12. Claim verification — local publishing contract' in policy,
            'local publishing contract is missing')
    require('## Publishing measured claims' in review, 'publishing review template is missing')
    records = {}
    claims = gaps = 0
    for source in sorted(files):
        if source.startswith('docs/claims/'):
            require(re.fullmatch(r'docs/claims/[A-Z][A-Z0-9-]*(?:\.[0-9]+)+\.json', source),
                    f'unknown claim collection member: {source}')
            record = strict_json(read_input(source))
            count, missing = validate(record, source, read_input, check_owner)
            records[source] = record
            claims += count
            gaps += missing
    if git('diff', '--cached', '--name-only', '-z'):
        owner = subprocess.run(['perl', str(ROOT / 'tools/check_task_verification_fields.pl'), '--owner'],
                               check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout.decode().strip()
        node_sources = [name for name in files if name.startswith('docs/tasks/') and name.endswith('.md')
                        and name in git('diff', '--cached', '--name-only', '-z').decode().split('\0')]
        declarations = []
        for source in node_sources:
            raw = read_input(source).decode('utf-8')
            for node in re.finditer(r'^- ID: `' + re.escape(owner) + r'`\n(.*?)(?=^- ID:|^## |\Z)', raw, re.M | re.S):
                declarations.extend(re.findall(r'^  Claim verification: (.+)$', node[1], re.M))
        require(len(declarations) == 1, f'{owner}: exactly one Claim verification declaration required')
        declaration = declarations[0]
        if declaration.startswith('none: '):
            text(declaration[6:], 'no measured claims explanation')
        else:
            match = re.fullmatch(r'`([^`]+)`', declaration)
            require(match is not None, 'Claim verification must name a record or none: reason')
            source = match[1]
            require(source in records and records[source]['owner'] == owner, 'owning claim record is missing')
    require(index_files() == files, 'index changed during claim verification; finish staging before checking')
    print(f'claim-verification: PASS {len(records)} records / {claims} claims / {gaps} disclosed leg gaps')


def self_test():
    producer = b'actual producer bytes\n'
    fixture = {'version': 1, 'owner': 'EXAMPLE.1', 'claims': [{
        'name': 'identity', 'statement': 'The declared producer bytes are watched.', 'scope': 'fixture only',
        'rederive': {'status': 'checked', 'command': 'identity command', 'granularity': 'file bytes', 'result': 'match'},
        'falsify': {'status': 'checked', 'hypothesis': 'Stale bytes pass.', 'oracle': 'SHA256', 'red_control': 'changed bytes reject'},
        'durability': {'status': 'checked', 'mode': 'live', 'inputs': [{
            'path': 'tools/example.py', 'sha256': hashlib.sha256(producer).hexdigest(), 'role': 'producer'}]}}]}

    def reader(source, revision):
        require(source == 'tools/example.py', 'untracked fixture input')
        require(revision is None or revision == 'a' * 40, 'missing fixture revision')
        return producer

    def owner(value):
        require(value == 'EXAMPLE.2', 'gap owner not open')

    validate(fixture, 'docs/claims/EXAMPLE.1.json', reader, owner)
    historical = copy.deepcopy(fixture)
    historical['claims'][0]['durability'].update(mode='historical', revision='a' * 40)
    validate(historical, 'docs/claims/EXAMPLE.1.json', reader, owner)
    gap = copy.deepcopy(fixture)
    gap['claims'][0]['durability'] = {'status': 'gap', 'reason': 'instrument unavailable', 'repair_owner': 'EXAMPLE.2'}
    validate(gap, 'docs/claims/EXAMPLE.1.json', reader, owner)
    controls = [
        ('missing leg', lambda r: r['claims'][0].pop('falsify')),
        ('empty hypothesis', lambda r: r['claims'][0]['falsify'].update(hypothesis='')),
        ('unknown field', lambda r: r.update(unreviewed=True)),
        ('wrong owner', lambda r: r.update(owner='OTHER.1')),
        ('stale bytes', lambda r: r['claims'][0]['durability']['inputs'][0].update(sha256='0' * 64)),
        ('untracked producer', lambda r: r['claims'][0]['durability']['inputs'][0].update(path='.linkedspec-data/ignored.py')),
        ('escaping path', lambda r: r['claims'][0]['durability']['inputs'][0].update(path='../producer.py')),
        ('duplicate input', lambda r: r['claims'][0]['durability']['inputs'].append(copy.deepcopy(r['claims'][0]['durability']['inputs'][0]))),
        ('no producer', lambda r: r['claims'][0]['durability']['inputs'][0].update(role='input')),
        ('self input', lambda r: r['claims'][0]['durability']['inputs'][0].update(path='docs/claims/EXAMPLE.1.json')),
        ('bad revision', lambda r: r['claims'][0]['durability'].update(mode='historical', revision='HEAD')),
        ('missing revision object', lambda r: r['claims'][0]['durability'].update(mode='historical', revision='b' * 40)),
        ('hidden gap', lambda r: r['claims'][0].update(durability={'status': 'gap', 'reason': 'missing'})),
        ('closed owner', lambda r: r['claims'][0].update(durability={'status': 'gap', 'reason': 'missing', 'repair_owner': 'EXAMPLE.3'})),
    ]
    for name, mutate in controls:
        broken = copy.deepcopy(fixture)
        mutate(broken)
        try:
            validate(broken, 'docs/claims/EXAMPLE.1.json', reader, owner)
        except ValueError:
            continue
        raise ValueError(f'self-test failed to reject {name}')
    for raw in (b'{"version":1,"version":1}', b'{"value":NaN}'):
        try:
            strict_json(raw)
        except ValueError:
            continue
        raise ValueError('strict JSON control unexpectedly passed')
    print(f'claim-verification: self-test PASS 3 positive / {len(controls) + 2} rejected controls')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--self-test', action='store_true')
    args = parser.parse_args()
    try:
        self_test()
        if not args.self_test:
            run_check()
    except (ValueError, subprocess.CalledProcessError, OSError) as error:
        parser.exit(1, f'claim-verification: FAIL: {error}\n')
