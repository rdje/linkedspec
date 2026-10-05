"""Review original Legacy effects against authored intervals and immutable Git bytes."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import importlib.util
import json
import re
import subprocess

ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('review.py')
REVISION='da3d34945d5067410b79f51782395f15b5184ff4'
TESTS=['t/actionir_helper_source_provenance.t','t/actionir_statement_source_frames.t','t/actionir_ast_parser.t','t/canonical_event_occurrence_order.t','t/actionir_nested_block_source_spans.t','t/trace_actionir_method_lowering.t']
PLANS=[13,28,23,15,20,4]
spec=importlib.util.spec_from_file_location('flow_literal_oracle',PREFIX+'oracle.py')
oracle=importlib.util.module_from_spec(spec);spec.loader.exec_module(oracle)


def sha(raw):return hashlib.sha256(raw).hexdigest()


def decode(e):
    assert e['encoding']=='gzip-base64','channel encoding'
    raw=gzip.decompress(base64.b64decode(e['data'],validate=True))
    assert len(raw)==e['bytes'] and sha(raw)==e['sha256'],'complete channel bytes'
    return raw


def check_inputs(m):
    assert m['revision']==REVISION,'activation revision'
    rows=subprocess.check_output(['git','ls-tree','-rlz',REVISION],cwd=ROOT).split(b'\0')
    original={};excluded=[]
    for row in filter(None,rows):
        meta,path=row.split(b'\t',1);mode,kind,oid,size=meta.split()
        if kind==b'blob' and mode in (b'100644',b'100755'):
            original[path.decode()]=(mode.decode(),oid.decode(),int(size))
        else:excluded.append({'path':path.decode(),'mode':mode.decode(),'kind':kind.decode()})
    entries={e['path']:e for e in m['entries']}
    assert len(entries)==len(m['entries']) and entries.keys()==original.keys(),'complete unique original Git population'
    assert m['excluded_metadata']==excluded,'black-box metadata exclusion'
    proc=subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    try:
        for path,identity in original.items():
            e=entries[path];assert (e['mode'],e['oid'],e['bytes'])==identity,'Git metadata'
            proc.stdin.write((e['oid']+'\n').encode());proc.stdin.flush()
            assert proc.stdout.readline().split()==[e['oid'].encode(),b'blob',str(e['bytes']).encode()],'blob header'
            raw=proc.stdout.read(e['bytes']);assert proc.stdout.read(1)==b'\n','blob framing'
            assert sha(raw)==e['sha256'],'original input bytes'
            if path.startswith(('perl/','specs/','t/')):assert raw==(ROOT/path).read_bytes(),'unchanged production and fixtures'
    finally:
        proc.stdin.close();proc.stdout.close();assert proc.wait()==0
    expected=[Path(PREFIX+n).relative_to(ROOT).as_posix() for n in ('cases.json','probe.pl','oracle.py')]
    assert [e['path'] for e in m['overlays']]==expected,'exact overlay population'
    for e in m['overlays']:
        raw=(ROOT/e['path']).read_bytes()
        assert e['mode']=='100644' and e['bytes']==len(raw) and e['sha256']==sha(raw),'authored overlay bytes'

def check_report(report, manifest, cases):
    assert report['complete'] is True and report['revision'] == REVISION, 'complete diagnosis boundary'
    assert report['instrument_sha256'] == sha(Path(PREFIX+'capture.py').read_bytes()), 'actual capture producer'
    stream = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
    assert report['stream_instrument_sha256'] == sha((ROOT/stream).read_bytes()), 'actual stream producer'
    assert [(r['kind'], r['seed']) for r in report['runs']] == [('fixtures', 0), ('legacy', 0), ('legacy', 1), ('legacy', 42)], 'complete command population'
    total = len(manifest['entries']) + len(manifest['overlays'])
    channels = []
    for row in report['runs']:
        tail = ['prove', '-v', '-Iperl'] + TESTS if row['kind'] == 'fixtures' else ['perl', '-Iperl', Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix()]
        assert row['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'actual command identity'
        assert row['exit'] == 0 and row['inputs_before'] == row['inputs_after'] == total, 'complete runtime guards'
        assert decode(row['stderr']) == b'', 'empty outer stderr'
        raw = decode(row['stdout'])
        if row['kind'] == 'legacy':
            oracle.check(json.loads(raw), cases)
            channels.append(raw)
        else:
            text = raw.decode()
            assert not re.search(r'^\s*not ok\b', text, re.M), 'all nested fixture assertions pass'
            for test, plan in zip(TESTS, PLANS):
                part = text.split(test + ' ..', 1)[1].split('\n1..' + str(plan), 1)[0]
                assert re.findall(r'^ok (\d+)\b', part, re.M) == [str(i) for i in range(1, plan+1)], 'complete ordered positive fixture reach'
            assert re.findall(r'^1\.\.(\d+)\s*$', text, re.M) == [str(n) for n in PLANS], 'complete original fixture plans'
    assert channels[0] == channels[1] == channels[2], 'full original channels identical across seeds'

def main():
    manifest = json.loads(Path(PREFIX+'inputs.json').read_bytes())
    report = json.loads(Path(PREFIX+'observations.json').read_bytes())
    cases = json.loads(Path(PREFIX+'cases.json').read_bytes())
    inventory = json.loads(Path(PREFIX+'inventory.json').read_bytes())
    owner = ROOT/'perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm'
    assert inventory['sha256'] == sha(owner.read_bytes()), 'actual current Legacy owner'
    contracts = [c['contract'] for c in inventory['contracts']]
    assert len(contracts) == len(set(contracts)) == 112, 'complete unique original dispatch'
    assert sorted(sum(inventory['families'].values(), [])) == sorted(contracts), 'complete exact safe partition'
    assert [c['id'] for c in cases[:112]] == contracts, 'literal every-contract fixtures'
    check_inputs(manifest)
    check_report(report, manifest, cases)
    controls = []
    def reject(name, target, mutation, validator):
        bad = copy.deepcopy(target)
        mutation(bad)
        try:
            validator(bad)
        except (AssertionError, KeyError, ValueError, IndexError) as error:
            controls.append({'name': name, 'observed': 'RED', 'reason': str(error) or type(error).__name__})
            return
        raise AssertionError('accepted corruption: ' + name)
    rows = json.loads(decode(report['runs'][1]['stdout']))
    for index, case in enumerate(cases[:112]):
        reject(case['id']+' omitted event', rows, lambda x, i=index: x[i]['rows'][0]['public_events'].pop(), lambda x: oracle.check(x, cases))
    return_index = contracts.index('return_general')
    for key in ('origin_event', 'constructed_event', 'constructed_args'):
        reject('forged '+key, rows, lambda x, k=key: x[return_index]['rows'][0]['identity'][0].update({k: False}), lambda x: oracle.check(x, cases))
    reject('invented uninstrumented origin', rows, lambda x: x[0]['rows'][0]['private_result']['source_origins'].append({'event': {}}), lambda x: oracle.check(x, cases))
    reject('lost original return origin', rows, lambda x: x[return_index]['rows'][0]['private_result']['source_origins'].pop(), lambda x: oracle.check(x, cases))
    reject('lost command', report, lambda x: x['runs'].pop(), lambda x: check_report(x, manifest, cases))
    reject('lost guard', report, lambda x: x['runs'][1].pop('inputs_after'), lambda x: check_report(x, manifest, cases))
    reject('forged channel', report, lambda x: x['runs'][1]['stdout'].update(sha256='0'*64), lambda x: check_report(x, manifest, cases))
    reject('forged producer', report, lambda x: x.update(instrument_sha256='0'*64), lambda x: check_report(x, manifest, cases))
    reject('lost Git input', manifest, lambda x: x['entries'].pop(), check_inputs)
    reject('lost overlay', manifest, lambda x: x['overlays'].pop(), check_inputs)
    result = {'complete': True, 'revision': REVISION, 'regular_inputs': len(manifest['entries']),
              'overlays': 3, 'commands': 4, 'contracts': 112, 'cases': 115, 'seeds': 3,
              'events_per_seed': 227, 'source_origins_per_seed': 2, 'fixture_suites': 6,
              'fixture_groups': sum(PLANS), 'compiler_cases_per_seed': sum(c['toolbox'] for c in cases),
              'families': {k: len(v) for k, v in inventory['families'].items()},
              'controls': controls, 'instrument_sha256': sha(Path(__file__).read_bytes()),
              'scope': 'Original internal compatibility dispatcher population, not new public admission; only existing return_general records origins. Quoted comma defect retained and separately owned. Complete supplied Git superset is not minimal observed IO; membership/global audits remain separate.'}
    Path(PREFIX+'verification.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='controls'}))
    print(str(len(controls))+' reason-specific evidence controls RED')

if __name__ == '__main__':
    main()
