"""Supply the whole accepted inventory and its complete nested source/graph context."""
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
    modes = json.loads(c.decode(preserved['preflight']['base64']))['input_modes']
    supplied = {}
    for binding in record['claims'][0]['durability']['inputs']:
        path = binding['path']
        raw = subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
        assert c.sha(raw) == binding['sha256']
        supplied[path] = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=modes[path])
    assert len(supplied) == 388 and len(c.decode(original['base64'])) == 68814
    old_prefix = 'docs/checkpoints/type-reference-inventory/'

    def nested(name):
        return json.loads(gzip.decompress(c.decode(supplied[old_prefix + name]['base64'])))

    proposals = nested('docs-proposals.json.gz')
    # The original reviewer materializes its complete1300 selection, not only the388 bindings.
    for path, item in nested('source-inputs.json.gz')['inputs'].items():
        assert c.sha(c.decode(item['base64'])) == item['sha256']
        if path in supplied and supplied[path] != item:
            assert path in proposals['before'] and item == proposals['before'][path]
            assert supplied[path] == proposals['proposals'][path]
        else:
            supplied[path] = item
    for graph in (nested('graph-inputs.json.gz')['inputs'], proposals['proposals']):
        for path, item in graph.items():
            assert c.sha(c.decode(item['base64'])) == item['sha256']
            if path in supplied:
                assert supplied[path] == item, path
            supplied[path] = item
    supplied[c.OLD_CLAIM] = original
    with tempfile.TemporaryDirectory(prefix='type-values-prior-', dir=os.environ['TMPDIR']) as directory:
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
    return dict(result='PASS', run=run, whole_original_inputs=388, whole_original_bytes=68814,
                supplied_context=len(supplied), bytes_modes_unchanged=True)


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--capture'])
    result = replay()
    if sys.argv[1:]:
        c.write_new(c.PREFIX + 'inventory-replay.json', result)
    print('Whole original inventory388/full68814 supplied readonly replay PASS')
