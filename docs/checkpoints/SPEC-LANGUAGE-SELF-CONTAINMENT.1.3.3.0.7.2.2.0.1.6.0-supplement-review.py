"""Check historical freeze, retained rejected instruments and Knowledge routing."""
from pathlib import Path
import copy
import importlib.util
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('supplement-review.py')
REVISION = '37401f576c517a91f49942893c41af020bcbfda4'
BASE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.'
CLAIM = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.4.json'


def module(name):
    path = PREFIX + name
    spec = importlib.util.spec_from_file_location('supplement_' + name.replace('.', '_'), path)
    result = importlib.util.module_from_spec(spec); spec.loader.exec_module(result)
    return result


book = module('book.py')
sha, decode = book.sha, book.decode


def read(name):
    return json.loads(Path(PREFIX + name).read_bytes())


def check_freeze(before, after, report):
    expected = json.loads(subprocess.check_output(['git', 'show', REVISION + ':' + CLAIM], cwd=ROOT))
    assert before == expected, 'exact original dedicated claim bytes'
    bindings = before['claims'][0]['durability']['inputs']
    assert len(bindings) == len({item['path'] for item in bindings}) == 111, 'complete original dedicated binding population'
    for item in bindings:
        raw = subprocess.check_output(['git', 'show', REVISION + ':' + item['path']], cwd=ROOT)
        assert sha(raw) == item['sha256'], 'original dedicated bound hashes'
    wanted = copy.deepcopy(before)
    for claim in wanted['claims']:
        claim['durability'].update(mode='historical', revision=REVISION)
    assert after == wanted, 'mode revision only historical freeze'
    assert report['revision'] == REVISION and report['bound_inputs'] == report['unique_inputs'] == 111, 'complete actual dedicated freeze report'
    assert report['instrument_sha256'] == sha(Path(PREFIX + 'freeze.py').read_bytes()), 'actual historical freeze instrument'


def check_routing(report):
    assert report['complete'] is True and report['instrument_sha256'] == sha(Path(PREFIX + 'historical-routing.py').read_bytes()), 'actual historical route instrument'
    assert [row['producer'] for row in report['runs']] == [BASE + suffix + '-review.py' for suffix in ('1.2.1', '2.3', '3.3')], 'complete three historical route population'
    for row in report['runs']:
        assert row['producer_sha256'] == sha((ROOT / row['producer']).read_bytes()), 'unchanged historical reviewer producer'
        assert row['command'] == ['bash', 'tools/run_python_project_data.sh', row['producer']], 'actual historical route command'
        assert row['exit'] == 1 and decode(row['stdout']) == b'', 'actual historical guard rejection'
        assert decode(row['stderr']).decode().splitlines()[-1] == 'AssertionError: unchanged current production and tests', 'exact historical current-source rejection'
    for name in ('perl-basic-family-mixed-source-provenance', 'perl-pipeline-statement-source-provenance',
                 'perl-pipeline-regex-source-provenance', 'perl-flow-recursive-source-provenance',
                 'perl-legacy-family-source-acceptance', 'perl-dedicated-family-source-acceptance'):
        text = (ROOT / ('docs/knowledge/' + name + '.md')).read_text()
        assert 'Current composed proof: bash tools/run_python_project_data.sh ' + BASE + '6.0-review.py' in text, 'current Knowledge composed route'
        assert 'Historical accepted input boundary only; do not refresh' in text, 'historical Knowledge boundary retained'


def main():
    before = read('before-dedicated-claim.json')
    after = json.loads((ROOT / CLAIM).read_bytes())
    freeze = read('freeze.json')
    check_freeze(before, after, freeze)
    routing = read('historical-routing.json'); check_routing(routing)
    initial = module('initial-book.py')
    initial_manifest, initial_report = read('initial-book-inputs.json'), read('initial-book.json')
    assert initial_report['exit'] == 0 and initial_report['complete'] is True, 'initial actual render success'
    assert sha(Path(PREFIX + 'initial-book-inputs.tar.gz').read_bytes()) == initial_manifest['capsule_sha256'] == initial_report['capsule_sha256'], 'retained initial render capsule'
    normalization = read('book-normalization.json')
    assert normalization['original_instrument_sha256'] == sha(Path(PREFIX + 'initial-book.py').read_bytes()), 'retained CRLF rejected instrument'
    try: initial.check_report(initial_report, initial_manifest)
    except AssertionError as error:
        assert str(error) == 'composition literal representative example', 'actual retained CRLF rejection'
    else: raise AssertionError('initial display oracle silently accepted')
    correction = read('book-control-correction.json')
    producer = Path(PREFIX + 'before-effectiveness-book.py').read_bytes()
    report = read('before-effectiveness-book.json')
    assert correction['producer_sha256'] == report['instrument_sha256'] == sha(producer), 'retained ineffective mutation producer'
    rendered = decode(report['regression_html'])
    assert rendered.replace(b'original rejected channels remain', b'history removed') == rendered, 'actual initial mutation ineffective'
    assert rendered.replace(b'original rejected channels', b'history removed') != rendered, 'corrected mutation effective'
    controls = []
    def reject(name, target, mutation, validator, reason):
        changed = copy.deepcopy(target); mutation(changed)
        assert changed != target, 'effective supplemental corruption'
        try: validator(changed)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name': name, 'observed': 'RED', 'reason': reason}); return
        raise AssertionError('accepted supplemental corruption: ' + name)
    reject('rewritten historical statement', after, lambda value: value['claims'][0].update(statement='refreshed'),
           lambda value: check_freeze(before, value, freeze), 'mode revision only historical freeze')
    reject('forged prior binding', before, lambda value: value['claims'][0]['durability']['inputs'][0].update(sha256='0' * 64),
           lambda value: check_freeze(value, after, freeze), 'exact original dedicated claim bytes')
    reject('lost freeze population', freeze, lambda value: value.update(bound_inputs=110),
           lambda value: check_freeze(before, after, value), 'complete actual dedicated freeze report')
    reject('forged freeze producer', freeze, lambda value: value.update(instrument_sha256='0' * 64),
           lambda value: check_freeze(before, after, value), 'actual historical freeze instrument')
    reject('lost historical route', routing, lambda value: value['runs'].pop(), check_routing, 'complete three historical route population')
    reject('forged historical route exit', routing, lambda value: value['runs'][0].update(exit=0), check_routing, 'actual historical guard rejection')
    reject('forged historical route producer', routing, lambda value: value['runs'][0].update(producer_sha256='0' * 64), check_routing, 'unchanged historical reviewer producer')
    result = {'complete': True, 'revision': REVISION, 'historical_bound_inputs': 111,
              'historical_current_route_rejections': 3, 'retained_render_rejections': 2,
              'controls': controls, 'instrument_sha256': sha(Path(__file__).read_bytes()),
              'scope': 'Original hashes and statements preserved; only historical mode/revision changes. Current Knowledge routes repaired without refreshing old producers. Initial CRLF display and vacuous mutation are independently retained/rejected; actual corrected full book evidence is reviewed separately.'}
    Path(PREFIX + 'supplement-verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print('111 original hashes/mode-revision-only freeze; three historical route and two retained render rejections; ' + str(len(controls)) + ' supplemental RED')


if __name__ == '__main__': main()
