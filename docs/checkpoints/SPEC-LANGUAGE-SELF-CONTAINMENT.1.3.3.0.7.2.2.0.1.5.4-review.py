"""Accept all committed dedicated statement producers without runtime overlays."""
from pathlib import Path
import copy
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
REVISION = '7dc393211a12d54d5986c8f6a5462c25615ccbc4'
ORIGINAL = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0-'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.3-'
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
spec = importlib.util.spec_from_file_location('dedicated_repair_review', ROOT / (PREVIOUS + 'review.py'))
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
sha, decode, envelope = prior.sha, prior.decode, prior.envelope
TESTS, PLANS = prior.TESTS[:-1], prior.PLANS[:-1]
CONTRACTS = ['staged_parse_job', 'progressive_span_dispatch', 'observe_recognition',
             'recognition_checkpoint', 'recognize_once', 'recognition_commit', 'recognition_rollback']


def check_inputs(manifest):
    assert manifest['revision'] == REVISION and manifest['overlays'] == [], 'immutable boundary without overlays'
    expected, excluded = {}, []
    for row in filter(None, subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT).split(b'\0')):
        meta, path = row.split(b'\t', 1)
        mode, kind, oid, size = meta.split()
        if kind == b'blob' and mode in (b'100644', b'100755'):
            expected[path.decode()] = (mode.decode(), oid.decode(), int(size))
        else:
            excluded.append({'path': path.decode(), 'mode': mode.decode(), 'kind': kind.decode()})
    entries = {entry['path']: entry for entry in manifest['entries']}
    assert len(entries) == len(manifest['entries']) and entries.keys() == expected.keys(), 'complete unique immutable Git population'
    assert manifest['excluded_metadata'] == excluded, 'exact black-box metadata exclusions'
    proc = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for path, (mode, oid, size) in expected.items():
            entry = entries[path]
            assert (entry['mode'], entry['oid'], entry['bytes']) == (mode, oid, size), 'exact original object and mode'
            proc.stdin.write((oid + '\n').encode()); proc.stdin.flush()
            assert proc.stdout.readline().split() == [oid.encode(), b'blob', str(size).encode()], 'exact original blob header'
            raw = proc.stdout.read(size)
            assert proc.stdout.read(1) == b'\n', 'exact original blob framing'
            assert entry['sha256'] == sha(raw), 'exact immutable Git bytes'
            assert not any(entry.get(key) for key in ('declared_fixture_overlay', 'declared_owner_delta')), 'no declared runtime replacements'
            if path.startswith(('perl/', 'specs/', 't/')):
                assert raw == (ROOT / path).read_bytes(), 'unchanged current production and fixtures'
    finally:
        proc.stdin.close(); proc.stdout.close(); assert proc.wait() == 0


def check_document(document, authored):
    assert authored['contracts'] == CONTRACTS, 'complete original dedicated partition'
    return prior.check_document(document, authored, 'after')


def check_report(report, manifest, authored):
    assert report['complete'] is True and report['revision'] == REVISION, 'complete fresh capture'
    assert report['instrument_sha256'] == sha(Path(PREFIX + 'capture.py').read_bytes()), 'actual capture producer'
    assert report['stream_instrument_sha256'] == sha((ROOT / STREAM).read_bytes()), 'actual stream producer'
    assert [(r['kind'], r['seed']) for r in report['runs']] == [('fixtures', 0)] + [('dedicated', s) for s in (0, 1, 42)], 'complete command population'
    previous = json.loads((ROOT / (PREVIOUS + 'after-observations.json')).read_bytes())
    channels = []
    for row in report['runs']:
        tail = ['prove', '-v', '-Iperl'] + TESTS if row['kind'] == 'fixtures' else ['perl', '-Iperl', ORIGINAL + 'probe.pl']
        assert row['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'actual committed producer command'
        assert row['exit'] == 0 and row.get('inputs_before') == row.get('inputs_after') == len(manifest['entries']), 'complete runtime guards'
        assert decode(row['stderr']) == b'', 'empty actual stderr'
        raw = decode(row['stdout'])
        if row['kind'] == 'dedicated':
            check_document(json.loads(raw), authored)
            old = next(r for r in previous['runs'] if r['kind'] == 'dedicated' and r['seed'] == row['seed'])
            assert raw == decode(old['stdout']), 'complete prior compiler callback and origin recurrence'
            channels.append(raw)
        else:
            text = raw.decode()
            assert not re.search(r'^\s*not ok\b', text, re.M), 'no nested fixture failure'
            sections = re.split(r'^([^\n]+\.t) \.{2,}[ \t]*\n', text, flags=re.M)
            assert sections[1::2] == TESTS, 'complete ordered fixture population'
            for body, plan in zip(sections[2::2], PLANS, strict=True):
                assert re.findall(r'^1\.\.(\d+)\s*$', body, re.M) == [str(plan)], 'complete fixture plan'
                assert [int(n) for n in re.findall(r'^ok (\d+)\b', body, re.M)] == list(range(1, plan + 1)), 'complete ordered positive TAP reach'
            assert 'All tests successful.' in text and 'Result: PASS' in text, 'complete fixture success'
    assert channels[0] == channels[1] == channels[2], 'complete three-seed channel equality'


def main():
    authored = json.loads((ROOT / (ORIGINAL + 'cases.json')).read_bytes())
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    report = json.loads(Path(PREFIX + 'observations.json').read_bytes())
    check_inputs(manifest); check_report(report, manifest, authored)
    document = json.loads(decode(report['runs'][1]['stdout']))
    _, measured = check_document(document, authored)
    assert measured == {'events':42, 'statement_frames':63, 'source_origins':42, 'cases':22, 'compiler_cases':4}, 'complete original population'
    controls = []
    def reject(name, target, mutation, validator, reason):
        changed = copy.deepcopy(target); mutation(changed)
        assert changed != target, 'effective corruption: ' + name
        try:
            validator(changed)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name':name, 'observed':'RED', 'reason':reason}); return
        raise AssertionError('accepted corruption: ' + name)
    validate = lambda value: check_document(value, authored)
    for i, case in enumerate(authored['cases']):
        for j, row in enumerate(case['rows']):
            if not row['expected_events']: continue
            prefix = case['id'] + '/' + row['contract']
            reject(prefix + ' omitted event', document, lambda v,i=i,j=j:v['cases'][i]['rows'][j]['public']['result'].pop(), validate, 'literal original events and arguments')
            for label, change in (
                ('lost origin', lambda o:o.pop()),
                ('swapped interval', lambda o:o[1].update(source_span=o[0]['source_span'])),
                ('changed argument', lambda o:o[0]['event']['args'].update(target='forged')),
                ('foreign source', lambda o:o[0].update(source='foreign')),
            ):
                reject(prefix + '/' + label, document, lambda v,i=i,j=j,c=change:c(v['cases'][i]['rows'][j]['private']['result']['source_origins']), validate, 'exact selected annotation source origins')
    for i, contract in enumerate(CONTRACTS):
        index = i * 2
        for channel in ('public','private'):
            for key in ('event','args'):
                reject(contract + '/' + channel + '/' + key, document, lambda v,i=index,c=channel,k=key:v['cases'][i]['rows'][0][c]['identity'][0].update({k:False}), validate, 'actual dispatcher event and argument identities')
            reject(contract + '/' + channel + '/array', document, lambda v,i=index,c=channel:v['cases'][i]['rows'][0][c].update(returned_array=False), validate, 'actual dispatcher returned-array identity')
        reject(contract + '/callback', document, lambda v,i=index:v['cases'][i]['rows'][0]['private']['calls'].pop(), validate, 'exact original callback channels')
    for i, row in enumerate(document['toolbox']):
        node, spelling = prior.old.MARKERS[row['id']]
        reject(row['id'] + '/node', document, lambda v,i=i,n=node:v['toolbox'][i]['descriptor']['canonical_action_ir_nodes'].remove(n), validate, 'dedicated compiler node')
        for channel, reason in (('substitution','dedicated substitution constructor'),('dump','dedicated emitted constructor')):
            reject(row['id'] + '/' + channel, document, lambda v,i=i,c=channel,s=spelling:v['toolbox'][i].update({c:v['toolbox'][i][c].replace(s,'omitted_constructor')}), validate, reason)
    report_check = lambda value: check_report(value, manifest, authored)
    for channel in ('substitution','descriptor','dump'):
        def change(v, channel=channel):
            doc = json.loads(decode(v['runs'][1]['stdout']))
            if channel == 'descriptor': doc['toolbox'][0][channel]['forged_extra'] = True
            else: doc['toolbox'][0][channel] += '\nforged_extra'
            v['runs'][1]['stdout'] = envelope(json.dumps(doc).encode())
        reject('changed full ' + channel, report, change, report_check, 'complete prior compiler callback and origin recurrence')
    for name, mutation, reason in (
        ('incomplete capture',lambda v:v.update(complete=False),'complete fresh capture'),
        ('lost command',lambda v:v['runs'].pop(),'complete command population'),
        ('forged command',lambda v:v['runs'][1]['command'].append('invented'),'actual committed producer command'),
        ('failed exit',lambda v:v['runs'][0].update(exit=1),'complete runtime guards'),
        ('lost guard',lambda v:v['runs'][1].pop('inputs_after'),'complete runtime guards'),
        ('forged capture',lambda v:v.update(instrument_sha256='0'*64),'actual capture producer'),
        ('forged stream',lambda v:v.update(stream_instrument_sha256='0'*64),'actual stream producer'),
        ('forged channel',lambda v:v['runs'][1]['stdout'].update(sha256='0'*64),'complete channel bytes'),
        ('noisy stderr',lambda v:v['runs'][0].update(stderr=envelope(b'forged stderr')),'empty actual stderr'),
    ): reject(name, report, mutation, report_check, reason)
    tap = decode(report['runs'][0]['stdout'])
    reject('lost positive TAP reach', report, lambda v:v['runs'][0].update(stdout=envelope(tap.replace(b'ok 143 - ',b'ok 144 - ',1))), report_check, 'complete ordered positive TAP reach')
    reject('hidden nested TAP failure', report, lambda v:v['runs'][0].update(stdout=envelope(tap.replace(b'    ok 1 - ',b'    not ok 1 - ',1))), report_check, 'no nested fixture failure')
    for name, mutation, reason in (
        ('lost original input',lambda v:v['entries'].pop(),'complete unique immutable Git population'),
        ('runtime overlay',lambda v:v['overlays'].append({}),'immutable boundary without overlays'),
        ('forged input bytes',lambda v:v['entries'][0].update(sha256='0'*64),'exact immutable Git bytes'),
        ('lost black-box exclusion',lambda v:v['excluded_metadata'].pop(),'exact black-box metadata exclusions'),
    ): reject(name, manifest, mutation, check_inputs, reason)
    result = {'complete':True,'revision':REVISION,'regular_inputs':len(manifest['entries']),
              'runtime_overlays':0,'commands':len(report['runs']),'contracts':7,'seeds':3,
              **measured,'fixture_suites':len(TESTS),'fixture_groups':sum(PLANS),
              'controls':controls,'instrument_sha256':sha(Path(__file__).read_bytes()),
              'scope':'Fresh committed dedicated annotation acceptance without overlays; complete original event/argument/scalar and preceding channel proof. Constructor and custom callback cases are recurring fixture observations; probe references are at dispatcher return. Required Phase0 is reserved for the exact staged canonical gate. No code/test/policy/admission changes, all-producer composition, membership/replacement or separate runtime-defect closure.'}
    Path(PREFIX + 'verification.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='controls'}))
    print(str(len(controls)) + ' effective reason-specific acceptance evidence controls RED')

if __name__ == '__main__': main()
