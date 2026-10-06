"""Review actual nested-boundary streams against literal independent controls."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
REVISION = 'b2156813fffed53622e640583a46a4ca94186a08'
OWNERS = ['perl/LinkedSpec/ActionIR/MethodLowering.pm','perl/LinkedSpec/ActionIR/BoundaryLabels.pm','t/capture_boundary_quoted_labels.t','t/phase0_regression.t']
FIXTURE = 't/nested_boundary_quoted_labels.t'
TESTS = [FIXTURE,'t/capture_boundary_quoted_labels.t','t/typed_source_location_perl_contract.t','t/actionir_helper_source_provenance.t','t/actionir_statement_source_frames.t','t/actionir_ast_parser.t','t/canonical_event_occurrence_order.t','t/actionir_nested_block_source_spans.t','t/trace_actionir_method_lowering.t','t/phase0_regression.t']
PLANS = [28,18,4,23,28,23,15,20,4,1035]
REPAIRED = ['assignment','return-hash','return-direct','spaced','repeated','single-unknown','unicode-crlf']
RED = [1,2,3,6,7,15,16,18,19,27,28]
LABELS = {name:[r'a\,b','end'] for name in REPAIRED + ['standalone','block']}
LABELS.update({'unicode-crlf':[r'界\,b','end'],'keyword-number':['true','false','undef','007','end'],'empty-quotes':['end']})


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def decode(value):
    assert value['encoding'] == 'gzip-base64', 'channel encoding'
    raw = gzip.decompress(base64.b64decode(value['data'],validate=True))
    assert len(raw) == value['bytes'] and sha(raw) == value['sha256'], 'complete channel bytes'
    return raw


def envelope(raw):
    return dict(encoding='gzip-base64',bytes=len(raw),sha256=sha(raw),data=base64.b64encode(gzip.compress(raw,mtime=0)).decode())


def check_inputs(manifest):
    epoch=manifest['epoch']
    assert epoch in ('before','after') and manifest['revision']==REVISION, 'input boundary'
    original={};excluded=[]
    for row in filter(None,subprocess.check_output(['git','ls-tree','-rlz',REVISION],cwd=ROOT).split(b'\0')):
        metadata,path=row.split(b'\t',1);mode,kind,oid,size=metadata.split()
        if kind==b'blob' and mode in (b'100644',b'100755'):
            original[path.decode()]=(mode.decode(),oid.decode(),int(size))
        else: excluded.append(dict(path=path.decode(),mode=mode.decode(),kind=kind.decode()))
    entries={e['path']:e for e in manifest['entries']}
    assert len(entries)==len(manifest['entries']) and entries.keys()==original.keys(), 'complete unique original inputs'
    assert manifest['excluded_metadata']==excluded, 'black-box metadata exclusions'
    process=subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    try:
        for path,identity in original.items():
            e=entries[path]
            assert (e['mode'],e['oid'],e.get('baseline_bytes',e['bytes']))==identity, 'original Git identity'
            process.stdin.write((e['oid']+'\n').encode());process.stdin.flush()
            assert process.stdout.readline().split()==[e['oid'].encode(),b'blob',str(identity[2]).encode()], 'blob header'
            raw=process.stdout.read(identity[2]);assert process.stdout.read(1)==b'\n', 'blob framing'
            assert sha(raw)==e.get('baseline_sha256',e['sha256']), 'original content identity'
            changed=epoch=='after' and path in OWNERS
            assert bool(e.get('declared_owner_delta'))==changed, 'exact owner replacements'
            if changed:
                current=(ROOT/path).read_bytes()
                assert e['bytes']==len(current) and e['sha256']==sha(current), 'owner replacement bytes'
            elif path.startswith(('perl/','specs/','t/')) and path not in OWNERS:
                assert raw==(ROOT/path).read_bytes(), 'unchanged existing consumers'
    finally:
        process.stdin.close();process.stdout.close();assert process.wait()==0
    paths=[Path(PREFIX+n).relative_to(ROOT).as_posix() for n in ('cases.json','probe.pl')]+[FIXTURE]
    assert [e['path'] for e in manifest['overlays']]==paths, 'exact overlays'
    for e in manifest['overlays']:
        raw=(ROOT/e['path']).read_bytes()
        assert e['mode']=='100644' and e['bytes']==len(raw) and e['sha256']==sha(raw), 'overlay bytes'


def label_assignment(labels):
    quote=lambda label: "'"+label.replace('\\','\\\\').replace("'","\\'")+"'"
    return 'my @__ls_boundary_labels = ('+', '.join(quote(label) for label in labels)+');'


def check_rows(rows,cases,epoch):
    assert [r['id'] for r in rows]==[c['id'] for c in cases] and len(cases)==28, 'complete literal case order'
    for row,case in zip(rows,cases):
        assert 'failure' not in row and row['stderr']=='', 'complete probe channels'
        if 'node' in case:
            assert row['source']==case['before_source' if epoch=='before' else 'expected_source'], 'structural lexical authority'
            assert row['node_before']==row['node_after']==case['node'], 'immutable typed node'
            assert row['stdout']=='', 'quiet serializer'
            continue
        assert row['built']=='CODE' and isinstance(row['parser_source'],str) and isinstance(row['substitution'],str), 'complete compiler channels'
        error=row['runtime_error']
        if case.get('failure_stage'):
            assert row['value'] is None and error['type']=='runtime_handler' and error['stage']==case['failure_stage'], 'explicit exclusions and quoted-source owner'
            if not case.get('known_defect'):
                assert 'Undefined subroutine &LinkedSpec::SpecEntry::capture_until_boundary' in error['detail'], 'excluded grammar stays unresolved'
            continue
        if epoch=='before' and case['id'] in REPAIRED:
            assert row['value'] is None and error['stage']=='rule_handler_eval' and 'Undefined subroutine &LinkedSpec::SpecEntry::capture_until_boundary' in error['detail'], 'actual original runtime RED'
        else:
            assert row['value']==case['expected'] and error is None and row['stdout']=='', 'literal successful boundary effects'
            assert row['action_rewriter']['unresolved_helper_count']==0, 'no unresolved runtime helper'
            assignment=label_assignment(LABELS[case['id']])
            assert assignment in row['parser_source'] and assignment in row['substitution'], 'actual emitted whole labels'
        events=[e for e in row['action_rewriter']['helper_action_ir_events'] if e['contract_id']=='capture_until_boundary']
        count=2 if case['id'] in ('repeated','unicode-crlf') else 1
        assert len(events)==count and all(e['args']=={'boundaries':LABELS[case['id']]} for e in events), 'whole original label discovery'
        if case['id']=='assignment':
            assert 'contract_id=capture_until_boundary' in row['trace'], 'scoped boundary trace'
            missing='source_span_missing => TAKEN' in row['trace']
            assert missing==(epoch=='before'), 'actual normalization source-span mechanism'
            assert row['traced_substitution']==row['substitution'], 'traced actual lowering result'


def stable_row(row):
    # Complete raw bytes remain retained and hash-checked. Only clock headers in
    # the NONE-level runtime failure trace vary across processes/epochs.
    value=copy.deepcopy(row);value.pop('trace',None)
    value['stdout']=re.sub(r'\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]', '[TIMESTAMP]', value['stdout'])
    return value


def check_report(report,manifest,cases):
    epoch=manifest['epoch']
    assert report['complete'] is True and report['epoch']==epoch and report['revision']==REVISION, 'complete runtime boundary'
    assert report['instrument_sha256']==sha(Path(PREFIX+'capture.py').read_bytes()), 'actual capture producer'
    stream='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
    assert report['stream_instrument_sha256']==sha((ROOT/stream).read_bytes()), 'actual guard producer'
    assert [(r['kind'],r['seed']) for r in report['runs']]==[('regression' if epoch=='before' else 'fixtures',0),('boundary',0),('boundary',1),('boundary',42)], 'complete command population'
    population=len(manifest['entries'])+len(manifest['overlays']);channels=[]
    for run in report['runs']:
        fixture=run['kind']!='boundary'
        command=['prove','-v','-Iperl']+([FIXTURE] if epoch=='before' else TESTS) if fixture else ['perl','-Iperl',Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix()]
        assert run['command']==['bash','tools/project_data_run.sh']+command, 'actual command identity'
        assert run['exit']==(1 if fixture and epoch=='before' else 0) and run['inputs_before']==run.get('inputs_after')==population, 'actual exits and complete guards'
        raw=decode(run['stdout']);stderr=decode(run['stderr'])
        if not fixture:
            assert stderr==b'', 'quiet outer channel'
            rows=json.loads(raw);check_rows(rows,cases,epoch);channels.append(rows)
        else:
            text=raw.decode()
            if epoch=='before':
                assert list(map(int,re.findall(r'^not ok (\d+)\b',text,re.M)))==RED, 'actual distinguishing RED groups'
                assert re.findall(r'^1\.\.(\d+)$',text,re.M)==['28'], 'original complete TAP reach'
                assert b'Failed test' in stderr, 'actual RED stderr'
            else:
                assert stderr==b'' and not re.search(r'^not ok ',text,re.M), 'quiet complete GREEN TAP'
                assert list(map(int,re.findall(r'^1\.\.(\d+)$',text,re.M)))==PLANS, 'complete focused TAP reach'
                assert 'All tests successful.' in text and 'Files=10, Tests='+str(sum(PLANS)) in text, 'actual focused suite totals'
    stable=[]
    for rows in channels:
        stable.append([stable_row(row) for row in rows])
    assert stable[0]==stable[1]==stable[2], 'seed stable complete nontrace channels'
    return channels[0]


def source_scope(sources=None):
    sources=sources or {p:(ROOT/p).read_text() for p in OWNERS}
    original=lambda p:subprocess.check_output(['git','show',REVISION+':'+p],cwd=ROOT).decode()
    path=OWNERS[0];s=sources[path]
    s=s.replace('use LinkedSpec::ActionIR::BoundaryLabels ();\n','')
    start=s.index('# A later compatibility rewrite still selects');end=s.index('sub _actionir_ast_value_source_expr {',start);s=s[:start]+s[end:]
    fragment="  if ($name eq 'capture_until_boundary') {\n   my $source = _actionir_ast_boundary_call_source($node);\n   return $source if defined($source);\n  }\n"
    assert s.count(fragment)==1, 'exact serializer branch'
    assert s.replace(fragment,'')==original(path), 'unchanged dispatcher and ordinary serialization'
    path=OWNERS[1];s=sources[path];start=s.index('\nsub _decode_recognized_labels {');s=s[:start]+'\n1;\n'
    s=s.replace('sub _decode_recognized_label_atoms {','sub _decode_recognized_labels {').replace('  push @labels, $label;','  push @labels, $label if length($label);')
    assert s==original(path), 'unchanged atom unescape and grammar consumer'
    path=OWNERS[2];s=sources[path];s=s.replace('        is_deeply($parser->',"        SKIP: {\n        skip 'nested unknown-escape normalization is owned by .1.4.0.1.1; scanner/direct lowering covered here', 2\n            if $case->{id} eq 'escaped-comma';\n        is_deeply($parser->").replace("        ok(!defined($runtime_ctx{last_error}), 'runtime has no error');\n", "        ok(!defined($runtime_ctx{last_error}), 'runtime has no error');\n        }\n")
    assert s==original(path), 'only previous runtime skips removed'
    path=OWNERS[3];s=sources[path];start=s.index("subtest 'quoted_boundary_atoms_survive_nested_value_serialization'");end=s.index("subtest 'anonymous_capture_take_until_cursor_helper",start)
    assert s[:start]+s[end:]==original(path), 'only recurring public regression added'


def verify(reports,manifests,cases,inputs=True):
    if inputs:
        for m in manifests:check_inputs(m)
        source_scope()
    before,after=[check_report(r,m,cases) for r,m in zip(reports,manifests)]
    for b,a,c in zip(before,after,cases):
        if 'node'in c or c['id'] in REPAIRED:continue
        assert stable_row(b)==stable_row(a), 'exact unaffected public channels except clock headers'
    return before,after


def main():
    cases=json.loads(Path(PREFIX+'cases.json').read_bytes())
    reports=[json.loads(Path(PREFIX+e+'-observations.json').read_bytes()) for e in ('before','after')]
    manifests=[json.loads(Path(PREFIX+e+'-inputs.json').read_bytes()) for e in ('before','after')]
    verify(reports,manifests,cases)
    controls=[]
    def reject(name,change,reason):
        rr=copy.deepcopy(reports);mm=copy.deepcopy(manifests);change(rr,mm)
        try:verify(rr,mm,cases,False)
        except AssertionError as error:
            assert str(error)==reason,(name,str(error),reason)
            controls.append(dict(name=name,observed='RED',reason=reason))
        else:raise AssertionError('accepted corruption '+name)
    def mutate_rows(rr,change):
        for run in rr[1]['runs'][1:]:
            rows=json.loads(decode(run['stdout']));change(rows);run['stdout']=envelope(json.dumps(rows,ensure_ascii=False).encode())
    for name in REPAIRED:
        reject('restore original failure '+name,lambda rr,mm,n=name:mutate_rows(rr,lambda rows:next(r for r in rows if r['id']==n).update(value=None)), 'literal successful boundary effects')
    for name in ('fake-call-source','inconsistent-source','dropped-slot-node','zero-borrows-empty','ordinary-string','ordinary-call'):
        reject('borrow rejected lexical source '+name,lambda rr,mm,n=name:mutate_rows(rr,lambda rows:next(r for r in rows if r['id']==n).update(source='borrowed')), 'structural lexical authority')
    for name in LABELS:
        reject('lose emitted labels '+name,lambda rr,mm,n=name:mutate_rows(rr,lambda rows:next(r for r in rows if r['id']==n).update(parser_source='emission removed')), 'actual emitted whole labels')
    reject('lose original case',lambda rr,mm:mutate_rows(rr,lambda rows:rows.pop()),'complete literal case order')
    reject('hide grammar failure',lambda rr,mm:mutate_rows(rr,lambda rows:next(r for r in rows if r['id']=='dropped-slot').update(value='xx ',runtime_error=None)), 'explicit exclusions and quoted-source owner')
    reject('hide quoted marker debt',lambda rr,mm:mutate_rows(rr,lambda rows:next(r for r in rows if r['id']=='quoted-marker').update(value='capture_until_boundary(end)',runtime_error=None)), 'explicit exclusions and quoted-source owner')
    reject('mutate typed node',lambda rr,mm:mutate_rows(rr,lambda rows:next(r for r in rows if r['id']=='native-node')['node_after'].update(name='other')), 'immutable typed node')
    reject('restore missing source span',lambda rr,mm:mutate_rows(rr,lambda rows:next(r for r in rows if r['id']=='assignment').update(trace='contract_id=capture_until_boundary source_span_missing => TAKEN')), 'actual normalization source-span mechanism')
    reject('missing command',lambda rr,mm:rr[1]['runs'].pop(),'complete command population')
    reject('missing guard',lambda rr,mm:rr[1]['runs'][0].update(inputs_after=0),'actual exits and complete guards')
    reject('failed green command',lambda rr,mm:rr[1]['runs'][0].update(exit=1),'actual exits and complete guards')
    reject('forged producer',lambda rr,mm:rr[1].update(instrument_sha256='0'*64),'actual capture producer')
    reject('forged channel',lambda rr,mm:rr[1]['runs'][0]['stdout'].update(sha256='0'*64),'complete channel bytes')
    reject('lost TAP reach',lambda rr,mm:rr[1]['runs'][0].update(stdout=envelope(decode(rr[1]['runs'][0]['stdout']).replace(b'1..1035\n',b'1..1034\n'))),'complete focused TAP reach')
    for name,change,reason in [
        ('lost input',lambda m:m['entries'].pop(),'complete unique original inputs'),
        ('forged input hash',lambda m:m['entries'][0].update(sha256='0'*64),'original content identity'),
        ('lost overlay',lambda m:m['overlays'].pop(),'exact overlays'),
    ]:
        candidate=copy.deepcopy(manifests[1]);change(candidate)
        try:check_inputs(candidate)
        except AssertionError as error:
            assert str(error)==reason,(name,str(error),reason)
            controls.append(dict(name=name,observed='RED',reason=reason))
        else:raise AssertionError('accepted corruption '+name)
    candidate={p:(ROOT/p).read_text() for p in OWNERS};candidate[OWNERS[0]]+='\n# unrelated serializer drift\n'
    try:source_scope(candidate)
    except AssertionError as error:
        assert str(error)=='unchanged dispatcher and ordinary serialization',str(error)
        controls.append(dict(name='unrelated serializer drift',observed='RED',reason=str(error)))
    else:raise AssertionError('accepted unrelated serializer drift')
    result=dict(complete=True,revision=REVISION,regular_inputs=len(manifests[0]['entries']),overlays=3,owner_replacements=4,cases=28,public_cases=17,serializer_cases=11,runtime_successes=11,repaired_runtime_routes=7,grammar_exclusions=5,quoted_source_defect='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2',before_red_groups=len(RED),after_green_groups=28,fixture_suites=10,fixture_groups=sum(PLANS),phase0=1035,seeds=3,commands=8,controls=controls,instrument_sha256=sha(Path(__file__).read_bytes()))
    Path(PREFIX+'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='controls'},ensure_ascii=False));print(str(len(controls))+' reason-specific RED controls')


if __name__=='__main__':main()
