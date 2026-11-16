"""Preserve actual command bytes and qualify portable logical replay metadata."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'command-portability'


def guard(command):
    assert command['cwd'] == '.' and command['argv'][:3] == ['bash', '--noprofile', '--norc']
    assert len(command['argv']) == 4
    for word in command['argv']:
        assert not Path(word).is_absolute(), 'nonportable project operand'
    path = Path(command['argv'][-1])
    assert '..' not in path.parts and path.is_file() and not path.is_symlink()
    assert path.resolve().is_relative_to(ROOT)


def main():
    OUT.mkdir()
    controls = json.loads((BASE / 'controls.json').read_bytes())
    spec = importlib.util.spec_from_file_location('retained_selector_source', BASE / 'capture.py')
    capture = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(capture)
    rows = []
    for control in controls['rejected']:
        tag = control['name']
        path = BASE / 'controls' / (tag + '-command.json')
        raw = path.read_bytes()
        assert raw == subprocess.check_output(['git', 'show', ':' + str(path)]), 'original staged command identity'
        actual = json.loads(raw)
        assert set(actual) == {'argv', 'cwd'}
        assert actual['cwd'] == '.' and actual['argv'][:3] == ['bash', '--noprofile', '--norc'] and len(actual['argv']) == 4
        relative = BASE / 'controls' / (tag + '.sh')
        assert Path(actual['argv'][-1]) == ROOT / relative
        script = relative.read_bytes()
        original_source = gzip.decompress((BASE / 'controls' / (tag + '-source.sh.gz')).read_bytes()).decode()
        assert capture.selector_script(original_source)[0].encode() == script
        assert all(token not in script for token in (b'$0', b'${0', b'BASH_SOURCE', b'PWD', b'$_'))
        portable = dict(argv=actual['argv'][:3] + [str(relative)], cwd='.')
        try:
            guard(actual)
        except AssertionError as error:
            assert str(error) == 'nonportable project operand'
        else:
            raise AssertionError('absolute-operand RED ineffective')
        guard(portable)
        original = BASE / 'controls' / (tag + '-command.actual.json.gz')
        assert not original.exists()
        original.write_bytes(gzip.compress(raw, mtime=0))
        assert gzip.decompress(original.read_bytes()) == raw
        mode = path.stat().st_mode & 0o777
        metadata = dict(**portable,
            representation='Portable logical equivalent; original actual argv is archived without alteration.',
            original_actual_command=str(original), original_actual_sha256=hashlib.sha256(raw).hexdigest(),
            script_sha256=hashlib.sha256(script).hexdigest())
        path.write_text(json.dumps(metadata, indent=2) + '\n')
        assert path.stat().st_mode & 0o777 == mode
        rows.append(dict(command=str(path), actual_archive=str(original), actual_sha256=metadata['original_actual_sha256'],
            actual_file_mode=mode, portable_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
            script=str(relative), script_sha256=metadata['script_sha256']))
    log = Path('.linkedspec-data/logs/source-discovery-preparation-2026-11-16-commit.log').read_bytes()
    assert b'current checkout identity:' in log and b'ALL 10 enforced doctrines PASS' not in log
    (OUT / 'first-normal.log.gz').write_bytes(gzip.compress(log, mtime=0))
    claim = Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.1.1.0.json')
    (OUT / 'claim-before.json.gz').write_bytes(gzip.compress(claim.read_bytes(), mtime=0))
    (OUT / 'result.json').write_text(json.dumps(dict(result='PASS', rows=rows, selector_replayed=False,
        limits='Original actual argv/observations remain unchanged in raw historical images. Maintained metadata is explicitly portable, not a new native invocation. No SDK, selector replay or original first-use credit. Interrupted normal hook supplied no all-doctrine report.'), indent=2) + '\n')
    print(json.dumps(dict(result='PASS', qualified_commands=len(rows), actual_records_retained=True, selector_replayed=False), sort_keys=True))


if __name__ == '__main__':
    main()
