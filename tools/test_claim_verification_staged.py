#!/usr/bin/env python3
"""Exercise the actual claim checker against an alternate index in this repository."""
import hashlib
import json
import os
import shutil
import subprocess
import tempfile
import sys
from contextlib import contextmanager
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1'
RECORD = f'docs/claims/{OWNER}.json'
TREE = 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
PRODUCER = 'tools/check_claim_verification.py'
COUNTS = {True: 0, False: 0}


def git(*args, env=None, raw=None):
    return subprocess.run(['git', '-C', str(ROOT), *args], env=env, input=raw,
                          check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout


def check(env, success, label, reason=None):
    result = subprocess.run(['bash', 'scripts/check_claim_verification.sh'], cwd=ROOT, env=env,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if (result.returncode == 0) != success:
        raise RuntimeError(f'{label}: unexpected exit {result.returncode}\n{result.stdout.decode()}{result.stderr.decode()}')
    if reason is not None and reason not in result.stderr.decode():
        raise RuntimeError(f'{label}: expected rejection reason {reason!r}; got {result.stderr.decode()}')
    COUNTS[success] += 1


def put(env, source, raw, mode='100644'):
    blob = git('hash-object', '-w', '--stdin', env=env, raw=raw).decode().strip()
    git('update-index', '--add', '--cacheinfo', f'{mode},{blob},{source}', env=env)


def put_tree(env, raw):
    """Change the owner fixture while keeping its declared byte identity valid."""
    put(env, TREE, raw)
    record = json.loads(git('show', f':{RECORD}', env=env))
    for claim in record['claims']:
        for item in claim['durability']['inputs']:
            if item['path'] == TREE:
                item['sha256'] = hashlib.sha256(raw).hexdigest()
    put(env, RECORD, json.dumps(record).encode())


def managed_temp_root():
    if os.environ.get('LINKEDSPEC_RUN_ACTIVE') != '1' or not os.environ.get('LINKEDSPEC_RUN_DIR'):
        raise RuntimeError('claim-staged requires the managed project-data wrapper')
    if Path(os.environ.get('LINKEDSPEC_REPO_ROOT', '')).resolve() != ROOT:
        raise RuntimeError('claim-staged initializer belongs to another checkout')
    scratch = Path(os.environ['LINKEDSPEC_RUN_DIR'])
    if not scratch.is_absolute():
        raise RuntimeError('claim-staged managed root must be absolute at runtime')
    for component in (scratch, *scratch.parents):
        if component.is_symlink():
            raise RuntimeError('claim-staged managed root contains a symlink')
    if not scratch.is_dir() or scratch.stat().st_dev != ROOT.stat().st_dev:
        raise RuntimeError('claim-staged managed root is outside the repository filesystem')
    return scratch


@contextmanager
def scratch_directory():
    with tempfile.TemporaryDirectory(prefix='claim-staged-', dir=managed_temp_root()) as directory:
        yield Path(directory)


def storage_self_test():
    with scratch_directory() as directory:
        marker = directory / 'allocation.txt'
        marker.write_text('managed claim allocation\n')
        assert marker.stat().st_dev == ROOT.stat().st_dev
    assert not directory.exists(), 'claim allocation was not removed'
    print('claim-staged-storage: PASS managed allocation and exact cleanup')


def main():
    original = git('rev-parse', '--git-path', 'index').decode().strip()
    original = (ROOT / original).resolve()
    before = original.read_bytes()
    with scratch_directory() as directory:
        alternate = directory / 'index'
        env = dict(os.environ, GIT_INDEX_FILE=str(alternate))
        def restore():
            shutil.copyfile(original, alternate)
        restore()
        check(env, True, 'actual staged baseline')
        # Verify the owner API does not change the existing tier-only API.
        tier = subprocess.check_output(['perl', 'tools/check_task_verification_fields.pl'], cwd=ROOT, env=env).decode().strip()
        owner = subprocess.check_output(['perl', 'tools/check_task_verification_fields.pl', '--owner'], cwd=ROOT, env=env).decode().strip()
        assert tier == 'canonical' and owner == OWNER
        source_bytes = git('show', f':{PRODUCER}', env=env)
        put(env, PRODUCER, source_bytes + b'\n# actual stale-byte control\n')
        check(env, False, 'stale actual producer bytes', f'stale input: {PRODUCER}')
        restore()
        git('update-index', '--force-remove', RECORD, env=env)
        check(env, False, 'missing actual claim record', 'owning claim record is missing')
        restore()
        put(env, PRODUCER, b'elsewhere.py', mode='120000')
        check(env, False, 'actual symlink producer mode', 'input is not a tracked regular file')
        restore()
        tree_bytes = git('show', f':{TREE}', env=env)
        declaration = f'  Claim verification: `{RECORD}`\n'.encode()
        assert tree_bytes.count(declaration) == 1
        put_tree(env, tree_bytes.replace(declaration, b''))
        check(env, False, 'missing actual owner declaration', 'exactly one Claim verification declaration required')
        restore()
        put_tree(env, tree_bytes.replace(declaration, declaration + declaration))
        check(env, False, 'duplicated actual owner declaration', 'exactly one Claim verification declaration required')
        restore()
        put_tree(env, tree_bytes.replace(declaration, b'  Claim verification: none: controlled no-measurement fixture\n'))
        check(env, True, 'actual explicit no-measurement declaration')
        put_tree(env, tree_bytes.replace(declaration, b'  Claim verification: none: \n'))
        check(env, False, 'actual empty no-measurement explanation', 'no measured claims explanation')
        restore()
        check(env, True, 'restored actual staged baseline')
        # Both partitioned and unpartitioned current repair owners use index status.
        record = json.loads(git('show', f':{RECORD}', env=env))
        record['claims'][0]['durability'] = {
            'status': 'gap', 'reason': 'controlled missing instrument',
            'repair_owner': 'SESSION-STARTUP-READING.5'}
        put(env, RECORD, json.dumps(record).encode())
        check(env, True, 'actual open partitioned gap owner')
        record['claims'][0]['durability']['repair_owner'] = 'REPO-HYGIENE.7'
        put(env, RECORD, json.dumps(record).encode())
        check(env, False, 'actual closed unpartitioned gap owner', 'gap repair owner is not open')
        revision = git('rev-parse', 'HEAD', env=env).decode().strip()
        historical_source = 'tools/check_task_verification_fields.pl'
        historical_bytes = git('show', f'{revision}:{historical_source}', env=env)
        record['claims'][0]['durability'] = {
            'status': 'checked', 'mode': 'historical', 'revision': revision,
            'inputs': [{'path': historical_source,
                        'sha256': hashlib.sha256(historical_bytes).hexdigest(), 'role': 'producer'}]}
        put(env, RECORD, json.dumps(record).encode())
        check(env, True, 'actual historical producer blob')
        record['claims'][0]['durability']['revision'] = 'f' * 40
        put(env, RECORD, json.dumps(record).encode())
        check(env, False, 'actual missing historical revision', 'ls-tree')
        restore()
        check(env, True, 'final restored actual staged baseline')
    assert hashlib.sha256(original.read_bytes()).digest() == hashlib.sha256(before).digest(), 'real index changed'
    print(f'claim-staged: PASS {COUNTS[True]} positive / {COUNTS[False]} rejected controls; '
          'default API retained; real index unchanged')


if __name__ == '__main__':
    if sys.argv[1:] == ['--storage-self-test']:
        storage_self_test()
    elif not sys.argv[1:]:
        main()
    else:
        raise SystemExit('usage: test_claim_verification_staged.py [--storage-self-test]')
