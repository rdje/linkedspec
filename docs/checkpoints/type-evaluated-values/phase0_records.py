"""Review the separate proposal chain and recoverable focused-source snapshot."""
import gzip
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path
import common as c

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'


def load(name):
    raw = (c.ROOT / (P + name)).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def current_proposals(inputs, original):
    preserved = load('preservation.json.gz')
    docs = load('docs-proposals-final.json.gz')
    aligned = load('proposals-final.json.gz')
    fixture = load('fixture-proposals.json.gz')
    original_graph = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'graph-inputs.json.gz')).read_bytes()))['inputs']
    target = dict(original['proposals'])
    for path, item in docs['before'].items():
        assert item == target.get(path, preserved['before'].get(path)), path
    target.update(docs['after'])
    for path, item in aligned['before'].items():
        assert item == inputs[path]
    target.update(aligned['after'])
    for path, item in fixture['before'].items():
        assert item == target.get(path, original_graph.get(path)), path
    target.update(fixture['after'])
    assert docs['producer'] == c.read(P + 'docs_final.py')
    assert aligned['producer'] == c.read(P + 'align_final.py')
    assert fixture['producer'] == c.read(P + 'fixture_fix.py')
    assert c.unchanged(target)
    return target


def summary(run):
    output = c.decode(run['stdout_base64'])
    marker = b'# FOCUSED_PHASE0_JSON '
    assert output.count(marker) == 1
    return json.loads(output.split(marker)[1].splitlines()[0])


def focused_result(run, wanted):
    actual = summary(run)
    assert run['returncode'] == 0 and actual['passing'] and actual['complete_selection']
    assert actual['selected'] == actual['wanted'] == 52 and actual['root_tests'] == 1035
    assert actual['skipped'] == 982
    text = c.decode(run['stdout_base64']).decode()
    roots = {int(number): line for line, number in re.findall(r'^(ok (\d+)[^\n]*)$', text, re.M)}
    assert len(roots) == 1035 and not re.search(r'^not ok \d+', text, re.M)
    assert sum(bool(re.search(r'#\s*skip\b', line, re.I)) for line in roots.values()) == 982
    for row in wanted:
        line = roots[row['number']]
        assert line.startswith('ok ' + str(row['number']) + ' - ' + row['name'])
        assert not re.search(r'#\s*skip\b', line, re.I)
    return actual


def verify_focused(fresh):
    snapshot = load('focused-final-inputs.json.gz')
    observed = load('focused-final-run.json.gz')
    record = load('focused-final-review.json')
    raw = (c.ROOT / snapshot['base_capsule']['path']).read_bytes()
    assert c.sha(raw) == snapshot['base_capsule']['sha256']
    supplied = json.loads(gzip.decompress(raw))['inputs']
    supplied.update(snapshot['overrides'])
    assert set(supplied) == set(snapshot['identities'])
    for path, item in supplied.items():
        assert c.sha(c.decode(item['base64'])) == item['sha256']
        assert {key: item[key] for key in ('sha256', 'mode')} == snapshot['identities'][path]
    # Root continuity and the derived map may advance after the frozen observation.
    # Current runtime, test and fixture bytes remain exactly the measured candidate.
    for path, item in supplied.items():
        if path.startswith(('perl/', 't/', 'tests/', 'bin/', 'specs/', 'conf/', 'tablescript/', 'ebnf/', 'capability_conformance/')):
            assert c.read(path) == item, path
    actual = focused_result(observed['run'], snapshot['positive']['selected'])
    assert record['actual'] == actual and record['result'] == 'PASS'
    assert observed['inputs_bytes_modes_unchanged'] and len(supplied) == record['inputs']
    denied = summary(observed['missing_selector'])
    assert observed['missing_selector']['returncode'] != 0
    assert not denied['complete_selection'] and denied['selected'] == 0 and denied['wanted'] == 1
    if fresh:
        with tempfile.TemporaryDirectory(prefix='type-values-focused-', dir=os.environ['TMPDIR']) as directory:
            root = Path(directory)
            assert root.stat().st_dev == c.ROOT.stat().st_dev
            for path, item in supplied.items():
                target = root / path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(c.decode(item['base64']))
                target.chmod(item['mode'])
            temporary = root / '.linkedspec-data/tmp'
            temporary.mkdir(parents=True)
            environment = dict(os.environ, TMPDIR=str(temporary),
                GIT_DIR=subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=c.ROOT, text=True).strip(),
                GIT_WORK_TREE=str(root), GIT_OPTIONAL_LOCKS='0')
            command = ['perl', '-Iperl', P + 'focused.pl']
            result = subprocess.run(command, cwd=root, env=environment,
                input=json.dumps(snapshot['positive']).encode(), capture_output=True)
            run = dict(command=command, returncode=result.returncode,
                       stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr))
            repeated = focused_result(run, snapshot['positive']['selected'])
            loaded = Path(repeated['loaded_method_lowering'])
            if not loaded.is_absolute():
                loaded = root / loaded
            assert loaded.resolve() == (root / 'perl/LinkedSpec/ActionIR/MethodLowering.pm').resolve()
            for path, item in supplied.items():
                assert (root / path).read_bytes() == c.decode(item['base64'])
                assert (root / path).stat().st_mode & 0o7777 == item['mode']
    return dict(result='PASS', selected=52, skipped=982, ordinary_root_plan=1035,
        snapshot_inputs=len(supplied), missing_selector_red=True,
        scope='Frozen complete-input focused snapshot; ordinary all1035 is separately canonical admission.')


def verify_supplement(fresh):
    focused = verify_focused(fresh)
    oracle = load('oracle-observed-review.json')
    raw = load('oracle-observed-run.json.gz')['run']
    assert oracle['result'] == 'PASS' and oracle['value_cases'] == 130
    assert raw['returncode'] == 0 and oracle['actual_raw_advisories'] == 2
    rows = json.loads(c.decode(raw['stdout_base64']))['rows']
    assert len(rows) == 130 and all(row['error'] is None for row in rows)
    assert c.decode(raw['stderr_base64']).decode() == ''.join(w for row in rows for w in row['warnings'])
    public = load('warning-routes-run.json.gz')
    assert public['runtime_inputs_unchanged']
    run = public['run']
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    output = c.decode(run['stdout_base64'])
    marker = b'\nSOURCE_TYPE_MODEL_JSON '
    assert output.count(marker) == 1 and output.startswith(marker)
    row = json.loads(output.split(marker)[1])['rows'][0]
    assert all(row[route]['ok'] for route in ('descriptor', 'live', 'generated'))
    assert row['live']['value'] == row['generated']['value']['value'] == {'kind': 'node'}
    assert set(row['warning_routes']) == {'generated'} and len(row['warning_routes']['generated']) == 1
    advisory = 'Scalar value @__ls_drop{"debug"} better written as $__ls_drop{"debug"}'
    assert row['warning_routes']['generated'][0].startswith(advisory + ' at (eval ')
    assert not row['generated_fatal']['ok'] and row['generated_fatal']['error'].startswith(advisory)
    assert 'delete @__ls_drop{"debug"}' in row['generated']['value']['source']
    return dict(focused=focused, historical_manual_goldens=130, explicit_compiler_advisories=2,
        public_generated_drop_warning=1, fatal_generated_load='RED; separately owned by .1.2.6')
