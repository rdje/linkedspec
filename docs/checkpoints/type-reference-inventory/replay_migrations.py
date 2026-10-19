"""Replay the whole accepted migration publication in its supplied readonly context."""
import gzip
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
import common as c


def replay():
    preserved = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes()))
    original = preserved['original']
    record = json.loads(c.decode(original['base64']))
    supplied = {}
    modes = json.loads(c.decode(preserved['preflight']['base64']))['input_modes']
    for binding in record['claims'][0]['durability']['inputs']:
        path = binding['path']
        raw = subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
        assert c.sha(raw) == binding['sha256']
        supplied[path] = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=modes[path])
    assert len(supplied) == 396 and len(c.decode(original['base64'])) == 68960
    # The old graph reviewer reads the materialized files as well as its capsule.
    graph = json.loads(gzip.decompress(c.decode(supplied['docs/checkpoints/type-reference-migrations/graph-inputs.json.gz']['base64'])))['inputs']
    for path, item in graph.items():
        assert c.sha(c.decode(item['base64'])) == item['sha256']
        if path in supplied:
            assert supplied[path] == item, path
        supplied[path] = item
    supplied[c.OLD_CLAIM] = original
    with tempfile.TemporaryDirectory(prefix='type-inventory-prior-', dir=os.environ['TMPDIR']) as directory:
        fixture = Path(directory)
        assert fixture.stat().st_dev == c.ROOT.stat().st_dev
        for path, item in supplied.items():
            target = fixture / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(c.decode(item['base64']))
            target.chmod(item['mode'])
        temporary = fixture / '.linkedspec-data/tmp'
        temporary.mkdir(parents=True)
        environment = dict(os.environ,
            GIT_DIR=subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=c.ROOT, text=True).strip(),
            GIT_WORK_TREE=str(fixture), GIT_OPTIONAL_LOCKS='0', TMPDIR=str(temporary), PYTHONDONTWRITEBYTECODE='1')
        command = ['python3', c.OLD_PUBLISHER]
        result = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
        run = dict(command=command, returncode=result.returncode,
                   stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr))
        assert run == json.loads((c.ROOT / (c.PREFIX + 'baseline.json')).read_bytes())['run'], run
        for path, item in supplied.items():
            target = fixture / path
            assert target.read_bytes() == c.decode(item['base64'])
            assert target.stat().st_mode & 0o7777 == item['mode']
        for target in fixture.rglob('*'):
            if target.is_file() and target.relative_to(fixture).as_posix() not in supplied:
                assert target.relative_to(fixture).as_posix().startswith('.linkedspec-data/tmp/')
    return dict(result='PASS', run=run, whole_original_inputs=396, whole_original_bytes=68960,
                supplied_context=len(supplied), bytes_modes_unchanged=True)


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--capture'])
    result = replay()
    if sys.argv[1:]:
        c.write_new(c.PREFIX + 'migration-replay.json', result)
    print('Whole original migration396/full68960 supplied readonly replay PASS')
