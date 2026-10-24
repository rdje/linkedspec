"""One-shot actual supplied-byte/mode/scope denials and physical validator controls."""
import copy
import json
import os
from pathlib import Path
import tempfile
import common as c
import context

READER = c.PREFIX + 'read.py'
OBSERVER = c.PREFIX + 'observe_inputs.py'


def main():
    names = [READER, c.PREFIX + 'common.py', c.PREFIX + 'verified-after-runs.json.gz']
    supplied = {path:c.read(path) for path in names}
    expected = {path:{key:item[key] for key in ('sha256','mode')} for path,item in supplied.items()}
    cases = [dict(id='healthy', supplied=supplied, expected_accepted=True)]
    for name in ('missing-input','changed-bytes','changed-mode','omitted-producer','omitted-artifact'):
        altered = copy.deepcopy(supplied)
        if name in ('missing-input','omitted-producer','omitted-artifact'):
            key = names[1] if name == 'missing-input' else names[0] if name == 'omitted-producer' else names[2]
            del altered[key]
        elif name == 'changed-bytes':
            raw = c.decode(altered[names[1]]['base64']) + b'\n# supplied byte control\n'
            altered[names[1]].update(base64=c.encode(raw), sha256=c.sha(raw))
        else:
            altered[names[1]]['mode'] = 0o755
        cases.append(dict(id=name,supplied=altered,expected_accepted=False))
    plan = dict(expected=expected, required=names, cases=cases)
    source = c.source(READER).read_bytes()
    guard = b'assert set(supplied) == set(expected), "inventory scope"'
    assert source.count(guard) == 1
    left, right = source.index(b'def verify_inventory('), source.index(b'\ndef packet(')
    inverse = source[:left] + b'def verify_inventory(expected, supplied, required):\n    raise AssertionError("inverse validator rejects supplied inputs")\n\n' + source[right:]
    bypass = source[:left] + b'def verify_inventory(expected, supplied, required):\n    return True\n\n' + source[right:]
    physical = dict(healthy=source,inverse=inverse,bypass=bypass,restored=source)
    epoch = context.snapshot()
    c.write_new('input-controls-inputs.json.gz', dict(context=epoch,producer=c.read(c.PREFIX+'input_controls.py'),
        observer=c.read(OBSERVER),reader=c.read(READER),plan=plan,
        physical_sources={name:c.encode(raw) for name,raw in physical.items()},
        scope='Three concrete actual proof inputs exercise byte/mode binding and producer/artifact scope; this is not exhaustive validator testing. The whole conservative main-repository epoch is retained separately.'))
    runs = {}
    with tempfile.TemporaryDirectory(prefix='literal-input-validator-',dir=os.environ['TMPDIR']) as folder:
        assert Path(folder).stat().st_dev == c.ROOT.stat().st_dev
        for name, raw in physical.items():
            target=Path(folder)/(name+'.py')
            target.write_bytes(raw)
            run=c.run(['bash','tools/project_data_run.sh','python3',OBSERVER,str(target)],input=json.dumps(plan).encode())
            runs[name]=run
            assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
            observed=json.loads(c.decode(run['stdout_base64']))
            assert observed['validator_sha256'] == c.sha(raw)
            rows=observed['rows']
            assert [row['id'] for row in rows] == [case['id'] for case in cases]
            if name in ('healthy','restored'):
                assert [row['accepted'] for row in rows] == [case['expected_accepted'] for case in cases]
            elif name == 'inverse':
                assert rows[0]['accepted'] is False
            else:
                assert all(row['accepted'] for row in rows)
    unchanged=c.unchanged(epoch['inputs'])
    c.write_new('input-controls-runs.json.gz',dict(runs=runs,inputs_unchanged=unchanged))
    assert unchanged
    print('Actual input controls: three byte/mode/missing denials, two scope denials; physical inverse/bypass/restoration effective.',flush=True)


if __name__ == '__main__':
    main()
