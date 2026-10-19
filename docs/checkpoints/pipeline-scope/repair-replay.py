"""Retain the failed625 replay; derive distinct supplied-namespace fixture readers."""
import json
from pathlib import Path
from common import ROOT, PREFIX, sha, encode

target = ROOT / (PREFIX + 'replay-repair.json')
assert not target.exists()
originals = {}
for path in [PREFIX + name for name in ('common.py', 'replay.py', 'replay.json')] + [
    '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.6-transport-replay-attempt1.log',
    '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.6-commit.log']:
    source = ROOT / path
    value = source.read_bytes()
    originals[path] = dict(base64=encode(value), sha256=sha(value), mode=source.stat().st_mode & 0o7777)
common = (ROOT / (PREFIX + 'common.py')).read_text()
needle = '    return original\n'
assert common.count(needle) == 1
common = common.replace(needle, '''    standard = json.loads(gzip.decompress((ROOT / (
        'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-standard-verification.json.gz')).read_bytes()))
    claim_source = next(item for item in standard['sources'] if item['path'] == CLAIM)
    assert decode(claim_source['base64']) == claim_raw, 'independent pre-transport claim custody'
    return original
''')
needle = '        (fixture / CLAIM).write_bytes(decode(original[\'claim_base64\']))\n'
assert common.count(needle) == 1
common = common.replace(needle, '''        for path, item in load_namespace(original)['inputs'].items():
            target = fixture / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(decode(item['base64']))
            target.chmod(item['mode'])
''' + needle)
common += '''

def load_namespace(original):
    packed = (ROOT / (PREFIX + 'namespace.json.gz')).read_bytes()
    namespace = json.loads(gzip.decompress(packed))
    assert namespace['result'] == 'PASS' and namespace['base'] == BASE
    assert namespace['original_claim_sha256'] == original['claim_sha256']
    assert decode(namespace['producer_base64']) == (ROOT / (PREFIX + 'supplement.py')).read_bytes()
    names = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE,
                                     '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
    assert namespace['fixed_names'] == names and set(namespace['inputs']) == set(names), 'fixed supplied claim namespace'
    for path, item in namespace['inputs'].items():
        value = decode(item['base64'])
        assert sha(value) == item['sha256']
        old = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
        if path == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.7.json':
            expected = json.loads(old)
            expected['claims'][0]['durability'].update(mode='historical', revision=BASE)
            assert json.loads(value) == expected, 'actual selected claim freeze'
        else:
            assert value == old, ('unchanged fixed namespace member', path)
    assert namespace['returncode'] == 0 and not decode(namespace['stderr_base64'])
    assert decode(namespace['stdout_base64']) == b'Pipeline invocation publication PASS: 625 live inputs; 123401 bytes\\n'
    assert namespace['added_names'] == sorted(set(names) - set(original['inputs']))
    return namespace
'''
replay = (ROOT / (PREFIX + 'replay.py')).read_text()
assert replay.count('from common import ') == 1
replay = replay.replace('from common import ', 'from common_final import ')
replay = replay.replace("PREFIX + 'common.py'", "PREFIX + 'common_final.py'")
replay = replay.replace("PREFIX + 'replay.json'", "PREFIX + 'replay-final.json'")
replay = replay.replace("'namespace. Read-only project '", "'namespace including the actual supplied .7 freeze. Read-only project '")
for name, value in [('common_final.py', common), ('replay-final.py', replay)]:
    with (ROOT / (PREFIX + name)).open('x') as output: output.write(value)
report = dict(result='PASS', originals=originals,
              current={name: sha(value.encode()) for name, value in [('common_final.py', common), ('replay-final.py', replay)]},
              producer_sha256=sha(Path(__file__).read_bytes()),
              cause='Original625 bindings omit raw current fixed-BASE claims. Actual failure is the '
                    'selected .7 freeze at unchanged review-runtime-final.py line67. Supplement the '
                    'entire supplied namespace before bound writes; preserve original failure and readers.')
with target.open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
print('Distinct supplied-namespace replay source prepared; originals retained')
