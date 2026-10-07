"""Execute distinguishing bad producer variants against the unchanged oracle."""
from pathlib import Path
import importlib.util
import json
import re

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('mutants.py')
spec = importlib.util.spec_from_file_location('membership_mutant_capture', Path(PREFIX + 'capture.py'))
capture = importlib.util.module_from_spec(spec); spec.loader.exec_module(capture)
original = (ROOT / capture.OWNER).read_text()


def replace_once(source, old, new):
    assert source.count(old) == 1 and old != new
    return source.replace(old, new)


variants = [
    ('inclusive_opener', replace_once(original, '$start > $range->[0]', '$start >= $range->[0]'),
     'literal_receiver'),
    ('numeric_slash_as_pattern', replace_once(original,
        '!LinkedSpec::ActionIR::MethodExpr::_looks_like_slash_symbol_call_at($source, $pos, 1)', '1'),
     'numeric_slash_call_code_interval'),
    ('equal_raw_authority', replace_once(replace_once(original,
        'Scalar::Util::refaddr($origin->{event})', '$origin->{event}{raw}'),
        'Scalar::Util::refaddr($event)', '$event->{raw}'),
     'copied origin event cannot authorize an equal raw event'),
    ('lost_caller_error', replace_once(replace_once(original,
        'return LinkedSpec::OwnerDispatch::call_preserving_err(sub {', 'return (sub {'),
        '    });', '    })->();'),
     'active classification restores caller error after lexical helper work'),
]
report = {'complete': False, 'revision': capture.REVISION,
          'producer_sha256': capture.streams.sha(Path(__file__).read_bytes()), 'variants': []}
for name, source, target in variants:
    artifact = Path(PREFIX + 'mutant-' + name + '.pm')
    artifact.write_text(source)
    relative = artifact.relative_to(ROOT).as_posix()
    tree, manifest = capture.make_tree('after', {capture.OWNER: relative})
    input_path = Path(PREFIX + 'mutant-' + name + '-inputs.json')
    input_path.write_text(json.dumps(manifest, indent=2) + '\n')
    observation = capture.run(tree, manifest, 'membership-tap', 0,
                              ['prove', '-v', '-Iperl', capture.FIXTURE], 'after')
    raw = capture.streams.gzip.decompress(capture.streams.base64.b64decode(observation['stdout']['data']))
    text = raw.decode()
    failures = re.findall(r'^not ok \d+ - (.+)$', text, re.M)
    assert observation['exit'] == 1 and target in failures, (name, target, failures)
    assert re.findall(r'^1\.\.(\d+)$', text, re.M) == ['41'], 'complete bad producer reach'
    assert [int(n) for n in re.findall(r'^(?:not )?ok (\d+) - ', text, re.M)] == list(range(1, 42))
    assert observation['inputs_before'] == observation['inputs_after'] == len(manifest['entries'])
    report['variants'].append({'name': name, 'artifact': relative,
        'sha256': capture.streams.sha(source.encode()), 'expected_red_group': target,
        'observed_red_groups': failures, 'input_manifest': input_path.relative_to(ROOT).as_posix(),
        'observation': observation})
    Path(PREFIX + 'mutants.json').write_text(json.dumps(report, indent=2) + '\n')
    print(name + ': distinguishing actual producer RED', flush=True)
assert (ROOT / capture.OWNER).read_text() == original
report['complete'] = True
Path(PREFIX + 'mutants.json').write_text(json.dumps(report, indent=2) + '\n')
