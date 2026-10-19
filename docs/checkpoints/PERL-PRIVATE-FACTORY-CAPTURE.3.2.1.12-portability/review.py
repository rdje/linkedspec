"""Read-only custody and lossless transport review; never replay native writers."""
import gzip
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/knowledge-fields'))
import common as c

HOME = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12-portability/'
ANCHOR = '73873a928b1e85cb080a19777a8a712e869ca0cb8781796a8aa35b18371e3cfe'
CHANGED = {c.HOME + 'publish.py', c.HOME + 'render-build.json'}


def original():
    record = json.loads(gzip.decompress((ROOT / (HOME + 'original.json.gz')).read_bytes()))
    raw = c.decode(record['claim']['base64'])
    assert c.sha(raw) == record['claim']['sha256'] == ANCHOR and len(raw) == 35922, 'whole original draft identity'
    claim = json.loads(raw)
    bindings = claim['claims'][0]['durability']['inputs']
    assert len(bindings) == len(record['inputs']) == 196, 'complete original196 bindings'
    assert {row['path']: row['sha256'] for row in bindings} == {path: item['sha256'] for path, item in record['inputs'].items()}, 'complete original196 bindings'
    preflight = json.loads(c.decode(record['preflight']['base64']))
    assert c.sha(c.decode(record['preflight']['base64'])) == record['preflight']['sha256']
    assert c.decode(preflight['draft_base64']) == raw and preflight['draft_sha256'] == ANCHOR
    assert (preflight['bytes'], preflight['input_count']) == (35922, 196)
    assert preflight['input_modes'] == {path: item['mode'] for path, item in record['inputs'].items()}
    assert set(record['before_images']) == CHANGED
    for path, item in record['before_images'].items():
        assert c.sha(c.decode(item['base64'])) == item['sha256'] == record['inputs'][path]['sha256']
        assert item['mode'] == record['inputs'][path]['mode']
    return record


def transport(record):
    raw = c.decode(record['before_images'][c.HOME + 'render-build.json']['base64'])
    view = (ROOT / (c.HOME + 'render-build.json')).read_bytes()
    assert view == raw.replace(b'/', b'\\/'), 'exact standard solidus transport'
    assert view.replace(b'\\/', b'/') == raw, 'exact inverse original bytes'
    assert json.loads(view) == json.loads(raw), 'decoded render record unchanged'
    actual = json.loads(gzip.decompress((ROOT / (c.HOME + 'render-final.json.gz')).read_bytes()))
    assert json.loads(view) == actual['command'], 'actual captured render command unchanged'


def recover(record, path):
    if path in record['before_images']:
        item = record['before_images'][path]
        value = c.decode(item['base64'])
    elif path in record['inputs']:
        item = record['inputs'][path]
        value = (ROOT / path).read_bytes()
        assert (ROOT / path).stat().st_mode & 0o7777 == item['mode'], ('unchanged original input mode', path)
    else:
        item = record['staged_supplement'][path]
        value = c.decode(item['base64'])
    if path in record['inputs']:
        assert c.sha(value) == record['inputs'][path]['sha256'], ('recover exact original input', path)
    return value


def verify_custody(record):
    assert record['base_commit'] == c.BASE and len(record['staged']) == 108
    assert set(record['staged_supplement']) == set(record['staged']) - set(record['inputs'])
    for path in record['inputs']:
        recover(record, path)
    for path, entry in record['staged'].items():
        value = recover(record, path)
        assert c.sha(value) == entry['sha256'] and len(value) == entry['bytes']
        header = ('blob ' + str(len(value)) + '\0').encode()
        import hashlib
        assert hashlib.sha1(header + value).hexdigest() == entry['git_oid'], ('original staged Git blob', path)
    baseline = json.loads((ROOT / (HOME + 'baseline.json')).read_bytes())
    assert baseline['original_sha256'] == c.sha((ROOT / (HOME + 'original.json.gz')).read_bytes())
    assert baseline['result'] == 'PASS' and baseline['all196_bytes_modes_unchanged'] and baseline['whole_claim_bytes_mode_unchanged']
    run = baseline['command']
    assert run['returncode'] == 0 and c.decode(run['stderr_base64']) == b''
    assert c.decode(run['stdout_base64']) == b'Metadata publication PASS: 196 inputs; 35922 bytes;1487/1349/10455;897/248\n'
    failure = record['canonical_failure']
    log = c.decode(failure['log']['base64'])
    assert c.sha(log) == failure['log']['sha256'] and failure['observed_exit'] == 1
    assert b'FAIL  REPO-ROOT-PATHS' in log and log.count(b'  PASS  ') == 9
    assert b'docs/checkpoints/knowledge-fields/render-build.json:7:' in log
    assert set(record['root_worktree_reopen']) == {'MEMORY.md', 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md'}
    assert c.decode(record['prior_continuity']['base64']) == recover(record, c.HOME + 'continuity.json')


def replay(record):
    with tempfile.TemporaryDirectory(prefix='knowledge-fields-original196-', dir=os.environ['TMPDIR']) as directory:
        fixture = Path(directory)
        assert fixture.stat().st_dev == ROOT.stat().st_dev
        supplied = dict(record['inputs'])
        supplied[c.CLAIM] = record['claim']
        for path, item in supplied.items():
            value = c.decode(item['base64']) if path == c.CLAIM else recover(record, path)
            target = fixture / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(value)
            target.chmod(item['mode'])
        temporary = fixture / '.linkedspec-data/tmp'
        temporary.mkdir(parents=True)
        environment = dict(os.environ, GIT_DIR=subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=ROOT, text=True).strip(),
            GIT_WORK_TREE=str(fixture), GIT_OPTIONAL_LOCKS='0', TMPDIR=str(temporary))
        command = ['python3', c.HOME + 'publish.py']
        run = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
        result = dict(command=command, returncode=run.returncode, stdout_base64=c.encode(run.stdout), stderr_base64=c.encode(run.stderr))
        assert result == json.loads((ROOT / (HOME + 'baseline.json')).read_bytes())['command'], result
        assert all(c.sha((fixture / path).read_bytes()) == item['sha256'] and
                   (fixture / path).stat().st_mode & 0o7777 == item['mode'] for path, item in supplied.items())
        expected = set(supplied)
        extra = {p.relative_to(fixture).as_posix() for p in fixture.rglob('*') if p.is_file()} - expected
        assert not extra, ('unexpected reader output', sorted(extra))
        return dict(result='PASS', command=result, original_input_count=196,
            whole_claim_bytes=35922, all_supplied_bytes_modes_unchanged=True, no_unexpected_files=True,
            original_sha256=c.sha((ROOT / (HOME + 'original.json.gz')).read_bytes()),
            reader_sha256=record['inputs'][c.HOME + 'publish.py']['sha256'],
            replay_producer_sha256=c.sha(Path(__file__).read_bytes()))


def current_inputs():
    return {path.relative_to(ROOT).as_posix() for path in (ROOT / HOME).iterdir()
            if path.is_file() and path.name not in ('publication-preflight.json', 'continuity.json')}


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--transport-only'], ['--capture-replay'])
    record = original()
    transport(record)
    if sys.argv[1:] == ['--transport-only']:
        print('Original196 transport PASS: exact draft;decoded record and inverse bytes unchanged')
        raise SystemExit(0)
    verify_custody(record)
    if sys.argv[1:] == ['--capture-replay']:
        c.write_new(HOME + 'replay.json', replay(record))
    else:
        report = json.loads((ROOT / (HOME + 'replay.json')).read_bytes())
        assert report['result'] == 'PASS' and report['original_input_count'] == 196 and report['whole_claim_bytes'] == 35922
        assert report['original_sha256'] == c.sha((ROOT / (HOME + 'original.json.gz')).read_bytes())
        assert report['reader_sha256'] == record['inputs'][c.HOME + 'publish.py']['sha256']
        assert report['replay_producer_sha256'] == c.sha(Path(__file__).read_bytes())
        assert report['command'] == json.loads((ROOT / (HOME + 'baseline.json')).read_bytes())['command']
        assert report['all_supplied_bytes_modes_unchanged'] and report['no_unexpected_files']
    print('Original196/full35922 custody and retained actual original-reader replay PASS;exact failed108 staged candidate recoverable')
