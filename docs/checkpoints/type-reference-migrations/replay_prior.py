"""Supply the accepted 208-input context and whole original live claim to its reader."""
import gzip
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
import common as c


def replay():
    preservation = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes()))
    original = preservation['original']
    supplied = {}
    for path, identity in preservation['inputs'].items():
        raw = subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
        assert c.sha(raw) == identity['sha256'], ('accepted recoverable input', path)
        supplied[path] = dict(base64=c.encode(raw), **identity)
    assert len(supplied) == 208 and len(c.decode(original['base64'])) == 39111
    supplied[c.PRIOR_CLAIM] = original
    with tempfile.TemporaryDirectory(prefix='type-prior-metadata-', dir=os.environ['TMPDIR']) as directory:
        fixture = Path(directory)
        assert fixture.stat().st_dev == c.ROOT.stat().st_dev
        for path, item in supplied.items():
            target = fixture / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(c.decode(item['base64']))
            target.chmod(item['mode'])
        temporary = fixture / '.linkedspec-data/tmp'
        temporary.mkdir(parents=True)
        environment = dict(os.environ, GIT_DIR=subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=c.ROOT, text=True).strip(),
            GIT_WORK_TREE=str(fixture), GIT_OPTIONAL_LOCKS='0', TMPDIR=str(temporary))
        command = ['python3', c.PRIOR_PUBLISHER]
        result = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
        run = dict(command=command, returncode=result.returncode, stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr))
        baseline = json.loads((c.ROOT / (c.PREFIX + 'baseline.json')).read_bytes())['command']
        assert run == baseline, ('whole original accepted reader channels', run)
        assert all((fixture / path).read_bytes() == c.decode(item['base64']) and
                   (fixture / path).stat().st_mode & 0o7777 == item['mode'] for path, item in supplied.items())
        generated = {}
        for target in fixture.rglob('*'):
            if not target.is_file():
                continue
            relative = target.relative_to(fixture).as_posix()
            if relative not in supplied:
                assert relative.startswith('.linkedspec-data/tmp/'), ('unexpected source output', relative)
                raw = target.read_bytes()
                generated[relative] = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=target.stat().st_mode & 0o7777)
    return dict(result='PASS', run=run, supplied_inputs=208, original_claim_bytes=39111,
                source_bytes_modes_unchanged=True, runtime_temporary_files=generated,
                scope='Exact original live target is restored only in a same-volume supplied context. '
                      'Current main claim stays historical at real accepted BASE; no original native epoch is refreshed.')


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--capture'])
    result = replay()
    if sys.argv[1:]:
        c.write_new(c.PREFIX + 'prior-replay.json.gz', result, packed=True)
    print('Prior accepted metadata208/full39111 readonly supplied replay PASS')
