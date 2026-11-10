"""Read-only replay-boundary review and actual consumer corruption controls."""
import copy
import gzip
import json
from pathlib import Path
import sys
import traceback
import types

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
FACTORY = ROOT / 'docs/checkpoints/document-pressure-restoration'
sys.path.insert(0, str(FACTORY))
sys.path.insert(0, str(HERE))
from factory_boundary import decode, validate


def module(source, name):
    result = types.ModuleType(name)
    result.__file__ = str(FACTORY / (name + '.py'))
    exec(compile(source, result.__file__, 'exec'), result.__dict__)
    return result


def review():
    reports = {stage: json.loads(gzip.decompress((HERE / ('factory-boundary-' + stage + '.json.gz')).read_bytes()))
               for stage in ('before', 'after')}
    for report in reports.values():
        validate(report)
    before, after = (reports[stage] for stage in ('before', 'after'))
    changed = {name for name in before['sources'] if before['sources'][name] != after['sources'][name]}
    expected = {'docs/checkpoints/document-pressure-restoration/' + name for name in
                ('factory_evidence.py', 'factory_reviewer_calibration.py')}
    assert changed == expected, 'unrelated captured project source changed'
    for name in expected:
        assert (ROOT / name).read_bytes() == decode(after['sources'][name])
    old_probe = decode(before['commands']['native']['stdout'])
    new_probe = decode(after['commands']['native']['stdout'])
    # Compare semantic projections; generated implementation text is not the oracle.
    keys = ('id', 'source', 'expected', 'native', 'fresh', 'native_error', 'native_exception', 'error', 'output', 'loaded')
    def projection(raw):
        rows = json.loads(raw)
        return dict(public=[{key: row[key] for key in keys} for row in rows['public']], scope=rows['scope'])
    assert projection(old_probe) == projection(new_probe)
    rejected = []
    reader = decode(after['sources']['docs/checkpoints/document-pressure-restoration/factory_evidence.py'])
    for fault in ('native-kind', 'fresh-effect'):
        rows = json.loads(new_probe)
        if fault == 'native-kind':
            rows['public'][0]['native'][0] = True
        else:
            rows['public'][4]['fresh'][1] = ''
        calls = []
        def run(argv, **kwargs):
            calls.append(argv)
            return types.SimpleNamespace(returncode=0, stderr=b'', stdout=json.dumps(rows).encode())
        current = module(reader, 'factory_evidence')
        current.subprocess = types.SimpleNamespace(run=run)
        try:
            current.review()
        except AssertionError:
            assert len(calls) == 1 and calls[0][:3] == ['perl', '-Iperl', '-e']
            assert 'observations' in traceback.format_exc(), 'control failed before native semantic oracle'
            rejected.append(fault)
        else:
            raise AssertionError('current semantic corruption admitted: ' + fault)
    calibration = module(decode(after['sources']['docs/checkpoints/document-pressure-restoration/factory_reviewer_calibration.py']),
                         'factory_reviewer_calibration')
    calibration.review()
    saved = json.loads(gzip.decompress((FACTORY / 'factory-reviewer-source-calibration.json.gz').read_bytes()))
    primary = json.loads(gzip.decompress((FACTORY / 'factory-evidence.json.gz').read_bytes()))
    left = decode(primary['producers']['docs/checkpoints/document-pressure-restoration/factory_evidence.py'])
    right = decode(saved['after'])
    scanner = decode(primary['after']['tools/check_executable_aggregate_selector_sources.py'])
    try:
        calibration.replay(left, right + b'\n# unrelated historical edit\n', scanner)
    except AssertionError as error:
        assert str(error) == 'unreviewed reviewer edit'
        rejected.append('unrelated-historical-source-edit')
    else:
        raise AssertionError('historical correction boundary weakened')
    return dict(result='PASS', unchanged_current_semantics=True,
                original_runtime_drift_refusal=before['commands']['factory_evidence.py']['exit'],
                corrected_reviewer_exits={name: after['commands'][name]['exit'] for name in
                                          ('factory_evidence.py', 'factory_reviewer_calibration.py')},
                rejected_controls=rejected, limits=after['limits'])


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
