"""Retain the exact failed candidate and documented harness-prerequisite controls."""
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/knowledge-fields'))
import common as c

PREFIX = 'docs/checkpoints/knowledge-fields-canonical2/'
ROOT_DOCS = ['MEMORY.md', 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md', 'docs/TASK_TREE.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'docs/ARTIFACT_CLEANUP.md']
assert sys.argv[1:] in (['--snapshot'], ['--restricted-control'], ['--host-control'], ['--review'])

if sys.argv[1:] == ['--snapshot']:
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == c.BASE
    staged = {}
    paths = subprocess.check_output(['git', 'diff', '--cached', '--name-only', '-z'], cwd=ROOT).split(b'\0')
    for raw in filter(None, paths):
        path = raw.decode()
        entry = subprocess.check_output(['git', 'ls-files', '--stage', '--', path], cwd=ROOT).decode().strip()
        mode, oid, remainder = entry.split(' ', 2)
        assert remainder.startswith('0\t')
        value = subprocess.check_output(['git', 'show', ':' + path], cwd=ROOT)
        actual = c.read(path)
        assert c.decode(actual['base64']) == value, ('exact failed staged candidate', path)
        staged[path] = dict(git_mode=mode, git_oid=oid, sha256=c.sha(value), bytes=len(value), filesystem_mode=actual['mode'])
    assert len(staged) == 121
    claim = c.read(c.CLAIM)
    preflight = c.read(c.HOME + 'publication-preflight.json')
    parsed = json.loads(c.decode(preflight['base64']))
    assert len(c.decode(claim['base64'])) == parsed['bytes'] == 39111
    assert c.decode(parsed['draft_base64']) == c.decode(claim['base64'])
    inputs = json.loads(c.decode(claim['base64']))['claims'][0]['durability']['inputs']
    assert len(inputs) == parsed['input_count'] == 208
    modes = parsed['input_modes']
    for item in inputs:
        actual = c.read(item['path'])
        assert actual['sha256'] == item['sha256'] and actual['mode'] == modes[item['path']]
    diff = subprocess.Popen(['git', 'diff', '--cached', '--binary', '--full-index'], cwd=ROOT, stdout=subprocess.PIPE)
    digest, size = hashlib.sha256(), 0
    for chunk in iter(lambda: diff.stdout.read(1048576), b''):
        digest.update(chunk)
        size += len(chunk)
    assert diff.wait() == 0
    record = dict(version=1, owner=c.OWNER, base_commit=c.BASE,
        state='uncommitted exact121-file staged candidate; no invented Git revision',
        staged=staged, staged_binary_full_index_diff=dict(sha256=digest.hexdigest(), bytes=size),
        claim=claim, preflight=preflight, before_root_docs={path: c.read(path) for path in ROOT_DOCS},
        canonical_command=['bash', 'tools/run_ci_local.sh'], observed_exit=1,
        execution='restricted harness; nested macOS sandbox initialization denied',
        complete_log=c.read('.linkedspec-data/verification/knowledge-fields-canonical-attempt2.log'),
        canonical_producer=c.read('tools/run_ci_local.sh'), process_oracle=c.read('tools/test_project_data_process_locality.sh'),
        existing_authority=c.read('docs/knowledge/project-data-process-locality-proof.md'),
        capture_producer=c.read(PREFIX + 'retain.py'))
    packed = gzip.compress((json.dumps(record, sort_keys=True) + '\n').encode(), mtime=0)
    parts = []
    for offset in range(0, len(packed), 33554432):
        name = PREFIX + 'candidate-' + str(len(parts) + 1) + '.part'
        value = packed[offset:offset + 33554432]
        with (ROOT / name).open('xb') as output:
            output.write(value)
        parts.append(dict(path=name, bytes=len(value), sha256=c.sha(value)))
    c.write_new(PREFIX + 'snapshot.json', dict(result='CAPTURED', encoding='gzip-json', parts=parts,
        packed_bytes=len(packed), packed_sha256=c.sha(packed), input_count=208, staged_files=121,
        claim_bytes=39111, log_bytes=len(c.decode(record['complete_log']['base64']))))
    print('Failed canonical2 retained: exact121 candidate;208/full39111;whole channels;',len(packed),'packed bytes')
elif sys.argv[1:] in (['--restricted-control'], ['--host-control']):
    context = 'restricted' if sys.argv[1:] == ['--restricted-control'] else 'host'
    command = ['/usr/bin/sandbox-exec', '-p', '(version 1) (allow default)', '/usr/bin/true']
    result = c.run(command)
    c.write_new(PREFIX + 'control-' + context + '.json', dict(context=context, command=result,
        producer_sha256=c.sha(Path(__file__).read_bytes()),
        sandbox_executable_sha256=c.sha(Path('/usr/bin/sandbox-exec').read_bytes())))
    assert result['returncode'] == (71 if context == 'restricted' else 0), result
    print(context, 'sandbox initialization control:', result['returncode'])
else:
    manifest = json.loads((ROOT / (PREFIX + 'snapshot.json')).read_bytes())
    packed = b''
    for item in manifest['parts']:
        value = (ROOT / item['path']).read_bytes()
        assert len(value) == item['bytes'] <= 33554432 and c.sha(value) == item['sha256']
        packed += value
    assert len(packed) == manifest['packed_bytes'] and c.sha(packed) == manifest['packed_sha256']
    record = json.loads(gzip.decompress(packed))
    assert c.decode(record['capture_producer']['base64']) == Path(__file__).read_bytes()
    assert record['base_commit'] == c.BASE and len(record['staged']) == 121
    assert len(c.decode(record['claim']['base64'])) == 39111
    assert len(json.loads(c.decode(record['claim']['base64']))['claims'][0]['durability']['inputs']) == 208
    for path, entry in record['staged'].items():
        if path in record['before_root_docs']:
            value = c.decode(record['before_root_docs'][path]['base64'])
        else:
            value = (ROOT / path).read_bytes()
        assert len(value) == entry['bytes'] and c.sha(value) == entry['sha256'], path
        assert hashlib.sha1(('blob ' + str(len(value)) + '\0').encode() + value).hexdigest() == entry['git_oid']
    log = c.decode(record['complete_log']['base64'])
    assert c.sha(log) == record['complete_log']['sha256'] and len(log) == manifest['log_bytes']
    assert record['observed_exit'] == 1 and b'doctrines: ALL 10 enforced doctrines PASS.' in log
    assert b'Files=91, Tests=32235,' in log and b'sandbox_apply: Operation not permitted' in log
    assert b'representative relocated driver failed with status 71' in log
    for path in ('canonical_producer', 'process_oracle', 'existing_authority'):
        assert c.sha(c.decode(record[path]['base64'])) == record[path]['sha256']
    for context, expected in [('restricted', 71), ('host', 0)]:
        data = json.loads((ROOT / (PREFIX + 'control-' + context + '.json')).read_bytes())
        assert data['producer_sha256'] == c.sha(Path(__file__).read_bytes())
        assert data['command']['returncode'] == expected
        if context == 'restricted':
            assert b'sandbox_apply: Operation not permitted' in c.decode(data['command']['stderr_base64'])
        else:
            assert not c.decode(data['command']['stdout_base64']) and not c.decode(data['command']['stderr_base64'])
    print('Canonical2 custody PASS:121 staged files;208/full39111;whole failed log;restricted71/host0 controls')
