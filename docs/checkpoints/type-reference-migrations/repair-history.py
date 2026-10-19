"""Retain and reproduce the historical-reader EOF failure before a distinct fix."""
import os
import subprocess
import tempfile
from pathlib import Path
import common as c

original_path = c.PREFIX + 'history-supplement.py'
original = c.read(original_path)
helper = c.read(c.PREFIX + 'common.py')
source = c.decode(original['base64']).decode()
needle = "        assert end > start\n"
assert source.count(needle) == 1
final_source = source.replace(needle, "        if end < 0:\n            end = len(value)\n" + needle, 1)
final_source = final_source.replace("c.PREFIX + 'history-supplement.json.gz'", "c.PREFIX + 'history-supplement-final.json.gz'")
final_source = final_source.replace('Retain the owned historical lowerers referenced by the retirement table.',
    'Retain historical lowerers with an explicit final-function EOF boundary.')
blobs = {}
for revision in ('fff219840212c26d78d75cda0ac9356f5f8d257c', '4e9250390785b9a36ae3c48abc17fabc97b75ac0'):
    path = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
    value = subprocess.check_output(['git', 'show', revision + ':' + path], cwd=c.ROOT)
    blobs[revision] = dict(path=path, base64=c.encode(value), sha256=c.sha(value))
prepared = dict(original=original, helper=helper, historical_inputs=blobs,
    final_source_base64=c.encode(final_source.encode()), producer=c.read(c.PREFIX + 'repair-history.py'),
    original_observation='Tool session44355 reported the full assert-end/start traceback after the freezer PASS. '
        'The combined shell then updated pointers and exited0. Separate original inner channels/status '
        'were not retained and are unavailable; the recurrence below is a distinct observation.')
c.write_new(c.PREFIX + 'history-repair-inputs.json.gz', prepared, packed=True)
with tempfile.TemporaryDirectory(prefix='type-history-eof-', dir=os.environ['TMPDIR']) as directory:
    fixture = Path(directory)
    assert fixture.stat().st_dev == c.ROOT.stat().st_dev
    supplied = {original_path: original, c.PREFIX + 'common.py': helper}
    for path, item in supplied.items():
        target = fixture / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(c.decode(item['base64']))
        target.chmod(item['mode'])
    temporary = fixture / '.linkedspec-data/tmp'
    temporary.mkdir(parents=True)
    environment = dict(os.environ, GIT_DIR=subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=c.ROOT, text=True).strip(),
        GIT_WORK_TREE=str(fixture), GIT_OPTIONAL_LOCKS='0', TMPDIR=str(temporary))
    command = ['python3', original_path]
    result = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
    run = dict(command=command, returncode=result.returncode, stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr))
    unchanged = all(c.sha((fixture / path).read_bytes()) == item['sha256'] and
                    (fixture / path).stat().st_mode & 0o7777 == item['mode'] for path, item in supplied.items())
    assert unchanged and result.returncode != 0 and b'assert end > start' in result.stderr
    assert b'AssertionError' in result.stderr and result.stdout == b''
    assert not (fixture / (c.PREFIX + 'history-supplement.json.gz')).exists()
for revision, item in blobs.items():
    assert subprocess.check_output(['git', 'show', revision + ':' + item['path']], cwd=c.ROOT) == c.decode(item['base64'])
assert c.read(original_path) == original and c.read(c.PREFIX + 'common.py') == helper
final_path = c.PREFIX + 'history-supplement-final.py'
with (c.ROOT / final_path).open('x') as output:
    output.write(final_source)
c.write_new(c.PREFIX + 'history-repair.json', dict(result='PASS', exact_original_recurrence=run,
    all_supplied_bytes_modes_unchanged=unchanged, no_original_output_created=True,
    inputs_sha256=c.sha((c.ROOT / (c.PREFIX + 'history-repair-inputs.json.gz')).read_bytes()),
    final_producer=c.read(final_path), producer_sha256=c.sha(Path(__file__).read_bytes()),
    scope='Exact original writer/helper and full immutable Git input blobs precede the distinct supplied '
          'recurrence. Original source and original unsaved-channel limitation remain unchanged. '
          'The separate final producer adds only EOF fallback and a distinct output namespace.'))
print('Historical reader EOF RED reproduced; exact sources/inputs unchanged; distinct corrected producer prepared')
