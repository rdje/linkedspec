"""Clear the localized test glob before installing its observer; keep warnings enabled."""
import ast
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P, F = 'docs/checkpoints/type-values-required/', c.PREFIX
paths = ('t/lib/LinkedSpecTest/EmittedValues.pm', P + 'capsules.py',
         F + 'required_records.py', F + 'publish_required.py', F + 'README.md')
before = {path: c.read(path) for path in paths}
texts = {path: c.decode(item['base64']).decode() for path, item in before.items()}
helper = paths[0]
old = ' local *LinkedSpec::CodeblockRuntime::invoke = sub {\n'
new = ' local *LinkedSpec::CodeblockRuntime::invoke;\n *LinkedSpec::CodeblockRuntime::invoke = sub {\n'
assert texts[helper].count(old) == 1
texts[helper] = texts[helper].replace(old, new, 1)
capsules = texts[paths[1]]
needle = "    item = retained['before'].get(path)\n"
replacement = '''    item = retained['before'].get(path)
    if not item:
        correction = ROOT / (P + 'warning-proposals.json.gz')
        if correction.is_file():
            item = json.loads(gzip.decompress(correction.read_bytes()))['before'].get(path)
'''
assert capsules.count(needle) == 1
texts[paths[1]] = capsules.replace(needle, replacement, 1)
records = texts[paths[2]]
needle = "    current_sources.update(required_composed['after'])\n"
replacement = needle + '''    warning = required_load('warning-proposals.json.gz')
    assert warning['producer'] == c.read(R + 'warning_fix.py')
    old_support = required_load('closure.json')['inputs']
    for path, item in warning['before'].items():
        if path in current_sources:
            assert current_sources[path] == item, path
        elif path == 't/lib/LinkedSpecTest/EmittedValues.pm':
            assert required_load('source-fix.json.gz')['after'][path] == item
        else:
            assert all(item[key] == old_support[path][key] for key in ('sha256', 'mode')), path
    current_sources.update(warning['after'])
'''
assert records.count(needle) == 1
records = records.replace(needle, replacement, 1)
needle = '    assert c.unchanged(target)\n    return target\n'
replacement = '''    path = 't/lib/LinkedSpecTest/EmittedValues.pm'
    assert target[path] == warning['before'][path]
    target[path] = warning['after'][path]
    assert c.unchanged(target)
    return target
'''
assert records.count(needle) == 1
records = records.replace(needle, replacement, 1)
records = records.replace("closure = required_load('closure.json')", "closure = required_load('closure-final.json')", 1)
needle = '    if fresh:\n        repeated = c.run'
replacement = '''    warning_green = required_load('warning-run.json.gz')
    assert warning_green['producer'] == c.read(R + 'warning_capture.py')
    assert warning_green['inputs_bytes_modes_unchanged']
    assert warning_green['run']['returncode'] == 0
    assert not c.decode(warning_green['run']['stderr_base64'])
    assert 'Files=12, Tests=5001,' in c.decode(warning_green['run']['stdout_base64']).decode()
    assert warning_green['syntax']['returncode'] == 0
    assert not c.decode(warning_green['syntax']['stderr_base64'])
    if fresh:
        repeated = c.run'''
assert records.count(needle) == 1
records = records.replace(needle, replacement, 1)
needle = "        assert repeated['returncode'] == 0\n"
assert records.count(needle) >= 1
# Match the unique recurring prove assertion rather than the historical proof.
needle += "        assert 'Files=12, Tests=5001,' in c.decode(repeated['stdout_base64']).decode()\n"
assert records.count(needle) == 1
records = records.replace(needle, needle + "        assert not c.decode(repeated['stderr_base64'])\n", 1)
needle = "                mapper_red=198, frozen_native_inputs=15, prior_direct_inputs=823,\n"
assert records.count(needle) == 1
records = records.replace(needle, needle + "                current_stderr_bytes=0, test_stub_warning_repaired=True,\n", 1)
texts[paths[2]] = records
publisher = texts[paths[3]].replace('publication-required', 'publication-required-final')
publisher = publisher.replace("type-values-required/closure.json", "type-values-required/closure-final.json")
texts[paths[3]] = publisher
texts[paths[4]] = texts[paths[4]].replace('publication-required.json is current.',
                                      'publication-required-final.json is current.', 1)
texts[paths[4]] += ('\nThe first new invocation observer emitted two redefinition advisories. Clearing\n'
    'its localized glob before installation keeps warning settings intact and the\n'
    'current5001 suite has empty stderr. The first publication attempt was stopped\n'
    'before it wrote a claim; its837-input manifest and exit143 remain retained.\n')
for path, text in texts.items():
    if path.endswith('.py'):
        ast.parse(text, filename=path)
after = {path: dict(base64=c.encode(text.encode()), sha256=c.sha(text.encode()), mode=before[path]['mode'])
         for path, text in texts.items()}
claim = c.read(c.CLAIM)
original = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
assert claim == original['original_claim']
c.write_new(P + 'warning-proposals.json.gz', dict(before=before, after=after,
    producer=c.read(P + 'warning_fix.py'), original_claim=claim,
    stopped_manifest=c.read(F + 'publication-required-inputs.json'),
    stopped_output=c.read('.linkedspec-data/verification/type-values-required-publication.log'),
    stopped_status=c.read('.linkedspec-data/verification/type-values-required-publication.status'),
    scope='A new test observer emitted two redefined warnings; frozen5001 runs keep their '
          'actual stderr. Stop the superseded publication143 before bound writes; it never '
          'publishes a837-input claim. A localized empty glob avoids redefinition without '
          'suppressing warnings. New manifest/receipt names and actual quiet5001 proof follow.'),
    packed=True)
assert c.unchanged(before)
for path, item in after.items():
    (ROOT / path).write_bytes(c.decode(item['base64']))
    (ROOT / path).chmod(item['mode'])
print('Observer warning repaired with warning settings unchanged; first attempt retained')
