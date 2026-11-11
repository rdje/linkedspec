"""Independent retained-data reader; no SDK, census helper or retirement imports."""
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
BASE = HERE.relative_to(ROOT)
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.26'
ACTIVATION = 'e5f2cb78ab99192974178ea04177b6cabf283e1e'
LOGS = {
    'callable-pipeline-dart-commit-qualified.log': 'c97b864fe9e9de16eaff5bcc840e46e97afe1699',
    'task-headroom-rust-commit.log': '580fe233a7d0299d177ecbd442ad8ba027bbe6da',
    'callable-pipeline-julia-commit.log': '9a6b229ce3f944ef3822e71935b1c40c109f74b9',
    'callable-pipeline-lua-commit.log': 'e5f2cb78ab99192974178ea04177b6cabf283e1e',
}
SCOPES = ('.', 'rust/target/release', 'rust/target/debug/incremental',
          'rust/target/debug/deps', 'target/release', 'target/debug/incremental',
          'target/debug/deps', '.linkedspec-data/logs')


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def raw_channel(tag, channel):
    return gzip.decompress((HERE / (tag + '-' + channel + '.log.gz')).read_bytes())


def source_images(tag):
    images = json.loads(gzip.decompress((HERE / (tag + '-inputs.json.gz')).read_bytes()))
    for name, row in images.items():
        assert not Path(name).is_absolute() and '..' not in Path(name).parts
        raw = base64.b64decode(row['base64'], validate=True)
        assert len(raw) == row['bytes'] and digest(raw) == row['sha256'], 'source image'
        assert (ROOT / name).read_bytes() == raw, 'source changed'
        assert (ROOT / name).stat().st_mode & 0o777 == row['mode'], 'source mode'
    assert str(BASE / 'run.py') in images and str(BASE / 'review.py') in images
    return images


def channels(tag, tail):
    row = dict(command=json.loads((HERE / (tag + '-command.json')).read_bytes()),
        exit=(HERE / (tag + '-exit.txt')).read_text(),
        stdout=raw_channel(tag, 'stdout'), stderr=raw_channel(tag, 'stderr'))
    check_channels(row, tail)
    return row


def check_channels(row, tail):
    expected = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P',
                str(BASE / tail[0]), *tail[1:]]
    assert row['command'] == dict(argv=expected, cwd='.'), 'command identity'
    assert row['exit'] == '0\n', 'actual exit'
    assert row['stderr'] == b'', 'unexpected stderr'
    result = json.loads(row['stdout'])
    assert result['result'] == 'PASS', 'stdout result'
    return result


def metadata(report):
    assert report['owner'] == OWNER and report['activation_commit'] == ACTIVATION
    assert report['configured_cargo_target'] == 'rust/target'
    assert tuple(report['scopes']) == SCOPES and report['removed'] == []
    for name, row in report['scopes'].items():
        assert row['primary'] == row['independent'], 'metadata population'
        paths = [item['path'] for item in row['primary']]
        assert paths == sorted(set(paths)), 'metadata paths'
        for item in row['primary']:
            assert not Path(item['path']).is_absolute() and '..' not in Path(item['path']).parts
            assert item['suffix'] in ('.log', '.bin', '.DS_Store')
            assert type(item['bytes']) is int and item['bytes'] >= 0
    for image in (*report['producers'].values(), *report['messages'].values(), report['git_index']):
        assert digest(base64.b64decode(image['base64'], validate=True)) == image['sha256'], 'packet identity'


def logs(manifest, bodies):
    assert manifest['owner'] == OWNER and manifest['activation_commit'] == ACTIVATION
    expected = {'.linkedspec-data/' + name for name in LOGS}
    assert {row['path'] for row in manifest['records']} == expected and len(manifest['records']) == len(expected), 'log population'
    assert set(bodies) == expected, 'archive population'
    for row in manifest['records']:
        name = Path(row['path']).name
        assert row['archive'] == str(BASE / 'combined-logs' / (name + '.gz')), 'archive path'
        assert row['commit'] == LOGS[name], 'commit identity'
        assert row['metadata']['mode'] in (0o600, 0o644) and row['metadata']['links'] == 1, 'log mode'
        body = bodies[row['path']]
        assert len(body) == row['metadata']['bytes'] and digest(body) == row['sha256'], 'log body identity'
        git = subprocess.check_output(['git', 'show', '-s', '--format=%H%n%P%n%s', row['commit']], cwd=ROOT).decode()
        assert git == row['git'], 'Git record'
        commit, parents, subject = git.splitlines()
        parent = parents.split()[0]
        text = body.decode()
        assert text.count('doctrines: ALL 10 enforced doctrines PASS.') == 1, 'complete hook marker'
        assert ('post-commit activation_commit ' + parent + ' resolves to first parent HEAD^1 ' + parent[:8]) in text, 'post-pointer marker'
        commits = re.findall(r'^\[main ([0-9a-f]+)\] (.+)$', text, re.M)
        assert len(commits) == 1 and commit.startswith(commits[0][0]) and commits[0][1] == subject, 'completed commit marker'


def reject(label, function, expected, rejected):
    try:
        function()
    except (AssertionError, ValueError, KeyError) as error:
        assert str(error) == expected, (label, str(error), expected)
        rejected.append(dict(control=label, observed_red=expected))
    else:
        raise AssertionError('ineffective control: ' + label)


def controls(report, manifest, bodies, channel):
    rejected = []
    chosen = next(name for name, row in report['scopes'].items() if row['primary'])
    for label in ('missing-row', 'wrong-size', 'duplicate-row', 'outside-path', 'producer-byte'):
        changed = copy.deepcopy(report)
        rows = changed['scopes'][chosen]['primary']
        if label == 'missing-row': rows.pop()
        elif label == 'wrong-size': rows[0]['bytes'] += 1
        elif label == 'duplicate-row': rows.append(copy.deepcopy(rows[0]))
        elif label == 'outside-path': rows[0]['path'] = '../outside.log'
        else: next(iter(changed['producers'].values()))['sha256'] = '0' * 64
        reject(label, lambda: metadata(changed), 'packet identity' if label == 'producer-byte' else 'metadata population', rejected)
    for label, reason in (('missing-log', 'log population'), ('altered-log', 'log body identity'),
                          ('executable-mode', 'log mode'), ('invented-commit', 'commit identity'),
                          ('missing-hook-marker', 'complete hook marker')):
        changed, changed_bodies = copy.deepcopy(manifest), dict(bodies)
        row = changed['records'][0]
        if label == 'missing-log': changed['records'].pop()
        elif label == 'altered-log': changed_bodies[row['path']] += b'changed'
        elif label == 'executable-mode': row['metadata']['mode'] = 0o777
        elif label == 'invented-commit': row['commit'] = '0' * 40
        else:
            raw = changed_bodies[row['path']].replace(b'doctrines: ALL 10 enforced doctrines PASS.', b'no complete hook evidence')
            changed_bodies[row['path']] = raw
            row['sha256'], row['metadata']['bytes'] = digest(raw), len(raw)
        reject(label, lambda: logs(changed, changed_bodies), reason, rejected)
    for label, reason in (('wrong-command', 'command identity'), ('wrong-exit', 'actual exit'),
                          ('unexpected-stderr', 'unexpected stderr'), ('wrong-stdout', 'stdout result')):
        changed = copy.deepcopy(channel)
        if label == 'wrong-command': changed['command']['argv'][-1] = '--not-capture'
        elif label == 'wrong-exit': changed['exit'] = '1\n'
        elif label == 'unexpected-stderr': changed['stderr'] = b'diagnostic\n'
        else: changed['stdout'] = b'{"result":"FAIL"}'
        reject(label, lambda: check_channels(changed, ['census.py', '--capture']), reason, rejected)
    return rejected


def review(before_delete):
    report = json.loads(gzip.decompress((HERE / 'observation.json.gz').read_bytes()))
    metadata(report)
    for name, image in report['producers'].items():
        assert (ROOT / name).read_bytes() == base64.b64decode(image['base64'], validate=True)
    composition = json.loads((HERE / 'composition.json').read_bytes())
    template = gzip.decompress((HERE / 'composition-input.json.gz').read_bytes())
    assert digest(template) == composition['sha256'] and len(template) == composition['bytes']
    assert (ROOT / composition['template']).read_bytes() == template
    assert digest((HERE / 'census.py').read_bytes()) == composition['output_sha256']
    captured = channels('census-capture', ['census.py', '--capture'])
    replayed = channels('census-review', ['census.py'])
    expected_result = dict(date=report['at_utc'],
        scoped_rows=sum(len(row['primary']) for row in report['scopes'].values()),
        removed=0, rejected_controls=report['rejected_controls'], result='PASS')
    assert json.loads(captured['stdout']) == json.loads(replayed['stdout']) == expected_result
    for tag in ('prepare', 'census-capture', 'census-review', 'retire'):
        source_images(tag)
    manifest = json.loads((HERE / 'archive-manifest.json').read_bytes())
    bodies = {row['path']: gzip.decompress((ROOT / row['archive']).read_bytes()) for row in manifest['records']}
    logs(manifest, bodies)
    tracked = set(gzip.decompress((HERE / 'tracked-before.gz').read_bytes()).decode().split('\0'))
    assert not set(bodies) & tracked
    reference = json.loads((HERE / 'references-command.json').read_bytes())
    reference_argv = ['git', 'grep', '-n', '-F']
    for name in LOGS: reference_argv += ['-e', name]
    reference_argv += ['--', 'docs/claims', 'docs/checkpoints', 'docs/knowledge']
    assert reference == dict(argv=reference_argv, cwd='.')
    assert (HERE / 'references-exit.txt').read_text() == '1\n'
    assert raw_channel('references', 'stdout') == raw_channel('references', 'stderr') == b''
    rejected = controls(report, manifest, bodies, captured)
    for row in manifest['records']:
        path = ROOT / row['path']
        if before_delete:
            assert path.read_bytes() == bodies[row['path']]
            assert path.stat().st_mode & 0o777 == row['metadata']['mode']
        else:
            assert not path.exists(), 'plain duplicate residue'
    if not before_delete:
        receipt = json.loads((HERE / 'retirement.json').read_bytes())
        assert receipt['result'] == 'PASS' and receipt['removed_plain_files'] == len(bodies)
        assert set(receipt['absent']) == set(bodies)
        assert receipt['archived_content_bytes'] == sum(len(raw) for raw in bodies.values())
        assert receipt['predelete_actual_exit'] == 0
        assert json.loads(channels('retire', ['retire.py'])['stdout']) == receipt
        prior = channels('predelete', ['review.py', '--before-delete'])
        prior_result = json.loads(prior['stdout'])
        assert prior_result['phase'] == 'before-delete' and prior_result['rejected_controls'] == rejected
    return dict(result='PASS', phase='before-delete' if before_delete else 'readonly',
        census_date=report['at_utc'], scoped_rows=expected_result['scoped_rows'],
        archived_files=len(bodies), archived_content_bytes=sum(len(raw) for raw in bodies.values()),
        rejected_controls=rejected,
        limits='Retained named-scope metadata and exact four combined logs; no whole-project, original channel separation, global liveness, allocated/free-space or complete native/OS custody claim.')


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--before-delete'])
    print(json.dumps(review(bool(sys.argv[1:])), sort_keys=True))
