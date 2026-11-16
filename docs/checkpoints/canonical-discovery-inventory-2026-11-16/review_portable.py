"""Recover preparation and explicit portable command aliases without replay."""
import contextlib
import gzip
import hashlib
import importlib.util
import io
import json
from pathlib import Path, PurePosixPath

BASE = Path(__file__).resolve().parent


def verify(meta, actual, row, script):
    assert meta['cwd'] == actual['cwd'] == '.', 'command cwd'
    assert meta['argv'][:3] == actual['argv'][:3] == ['bash', '--noprofile', '--norc'], 'command arguments'
    assert len(meta['argv']) == len(actual['argv']) == 4, 'command arguments'
    operand = PurePosixPath(meta['argv'][-1])
    assert not operand.is_absolute() and '..' not in operand.parts and str(operand) == row['script'], 'portable operand'
    assert PurePosixPath(actual['argv'][-1]).is_absolute(), 'actual argv identity'
    assert actual['argv'][-1].endswith('/' + str(operand)), 'argv mapping'
    assert meta['original_actual_command'] == row['actual_archive'], 'actual record'
    raw_hash = hashlib.sha256(json.dumps(actual, indent=2).encode() + b'\n').hexdigest()
    assert raw_hash == row['actual_sha256'] == meta['original_actual_sha256'], 'actual record'
    assert hashlib.sha256(script).hexdigest() == row['script_sha256'] == meta['script_sha256'], 'script bytes'
    assert all(token not in script for token in (b'$0', b'${0', b'BASH_SOURCE', b'PWD', b'$_')), 'script invocation identity'
    assert meta['representation'] == 'Portable logical equivalent; original actual argv is archived without alteration.', 'command representation'


def main():
    spec = importlib.util.spec_from_file_location('retained_source_epoch', BASE / 'verify_epoch.py')
    epoch = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(epoch)
    output = io.StringIO()
    with contextlib.redirect_stdout(output):
        epoch.main()
    result = json.loads(output.getvalue())
    qualification = json.loads((BASE / 'command-portability/result.json').read_bytes())
    assert qualification['result'] == 'PASS' and qualification['selector_replayed'] is False
    records = qualification['rows']
    assert len(records) == 5 and len({row['command'] for row in records}) == 5
    prefixes = set()
    for row in records:
        path = Path(row['command'])
        raw = gzip.decompress(Path(row['actual_archive']).read_bytes())
        assert hashlib.sha256(raw).hexdigest() == row['actual_sha256']
        assert path.stat().st_mode & 0o777 == row['actual_file_mode']
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['portable_sha256']
        actual, meta = json.loads(raw), json.loads(path.read_bytes())
        verify(meta, actual, row, Path(row['script']).read_bytes())
        prefixes.add(actual['argv'][-1][:-len(row['script'])])
    assert len(prefixes) == 1, 'original command root identity'
    row = records[0]
    meta = json.loads(Path(row['command']).read_bytes())
    actual = json.loads(gzip.decompress(Path(row['actual_archive']).read_bytes()))
    script = Path(row['script']).read_bytes()
    rejected = []
    for label in ('absolute-operand', 'cwd', 'actual-digest', 'script-byte', 'argv-mapping'):
        changed = dict(meta, argv=list(meta['argv']))
        changed_actual = dict(actual, argv=list(actual['argv']))
        body = script
        if label == 'absolute-operand':
            changed['argv'][-1] = actual['argv'][-1]
        elif label == 'cwd':
            changed['cwd'] = 'elsewhere'
        elif label == 'actual-digest':
            changed['original_actual_sha256'] = '0' * 64
        elif label == 'script-byte':
            body += b' '
        else:
            changed_actual['argv'][-1] = '/outside/not-the-script'
        try:
            verify(changed, changed_actual, row, body)
        except AssertionError as error:
            assert str(error) in ('portable operand', 'command cwd', 'actual record', 'script bytes', 'argv mapping')
            rejected.append(label)
        else:
            raise AssertionError('ineffective portable-command control:' + label)
    result['portable_commands'] = dict(records=len(records), original_actual_records_retained=True,
        selector_replayed=False, rejected=rejected,
        representation='Logical replay metadata only; actual original argv remains archived.')
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
