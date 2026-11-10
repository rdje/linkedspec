"""Readonly review of the completed dated capture/replay and their source bodies."""
import base64
import copy
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def validate_commands(rows):
    results = []
    for mode in ('capture', 'review'):
        row = rows[mode]
        command = ['bash', 'tools/run_python_project_data.sh',
                   (HERE / 'review.py').relative_to(ROOT).as_posix()]
        if mode == 'capture':
            command.append('--capture')
        assert row['command'] == dict(argv=command, cwd='.')
        assert row['exit'] == '0\n' and row['stderr'] == b''
        assert row['stdout'] == row['result']
        result = json.loads(row['result'])
        assert result['result'] == 'PASS' and result['removed'] == 0
        results.append(result)
    assert results[0] == results[1]
    return results[0]


def review():
    census = load_module('dated_artifact_review', HERE / 'review.py')
    report = json.loads(gzip.decompress((HERE / 'observation.json.gz').read_bytes()))
    census.validate(report)
    assert census.controls(report) == report['rejected_controls']
    assert report['activation_commit'] == '41ba410bbb03fe8e7e4dc1412331d069e258d70b'
    assert report['configured_cargo_target'] == 'rust/target'
    for name, image in report['producers'].items():
        raw = base64.b64decode(image['base64'], validate=True)
        assert hashlib.sha256(raw).hexdigest() == image['sha256']
        assert (ROOT / name).read_bytes() == raw, 'captured producer changed: ' + name
    rows = {}
    for mode, target in (('capture', 'capture-result.json'), ('review', 'result.json')):
        rows[mode] = dict(command=json.loads((HERE / (mode + '-command.json')).read_bytes()),
            exit=(HERE / (mode + '-exit.txt')).read_text(),
            stdout=gzip.decompress((HERE / (mode + '-stdout.log.gz')).read_bytes()),
            stderr=gzip.decompress((HERE / (mode + '-stderr.log.gz')).read_bytes()),
            result=(HERE / target).read_bytes())
    result = validate_commands(rows)
    assert result['date'] == report['at_utc']
    assert result['scoped_rows'] == sum(len(row['primary']) for row in report['scopes'].values())
    rejected = []
    for label in ('wrong-command', 'wrong-exit', 'missing-stdout', 'unexpected-stderr'):
        changed = copy.deepcopy(rows)
        if label == 'wrong-command': changed['capture']['command']['argv'][-1] = '--not-capture'
        elif label == 'wrong-exit': changed['capture']['exit'] = '1\n'
        elif label == 'missing-stdout': changed['review']['stdout'] = b''
        else: changed['review']['stderr'] = b'unexpected diagnostic\n'
        try:
            validate_commands(changed)
        except AssertionError:
            rejected.append(label)
        else:
            raise AssertionError('channel corruption admitted: ' + label)
    preservation = load_module('accepted_claim_preservation', HERE / 'preserve_prior_claim.py').review()
    return dict(result='PASS', date=result['date'], scoped_rows=result['scoped_rows'], removed=0,
        metadata_controls=report['rejected_controls'], channel_controls=rejected,
        preservation=preservation,
        limits='Dated retained metadata/source/channel consistency and accepted physical Git identities; no fresh census, deletion authority or complete native/OS first-use closure.')


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
