"""Read-only review of the dated CLI repair, qualified controls and book evidence."""
import copy
import gzip
import json
import common as c
import source_review as source
import oracle2
import book
import document


def parsed(run,code=0):
    assert run['returncode']==code and not c.decode(run['stderr_base64'])
    return json.loads(c.decode(run['stdout_base64']))


def permanent(packet,success):
    assert packet['inputs_unchanged']
    run = packet['permanent']
    assert run['returncode']==(0 if success else 1)
    stdout = c.decode(run['stdout_base64'])
    assert b'Files=1, Tests=6,' in stdout
    if success:
        assert b'Result: PASS' in stdout and not c.decode(run['stderr_base64'])
    else:
        assert b'Failed 2/6 subtests' in stdout and b'Failed tests:  4-5' in stdout
        assert b"Failed test 'context-reported handler failures use the invocation-failure protocol'" in c.decode(run['stderr_base64'])
        assert b"Failed test 'context failure has the canonical routed error trace'" in c.decode(run['stderr_base64'])


def check():
    epochs = source.source_epochs()
    activation = c.load('activation.json.gz')
    assert activation['base']==c.BASE and not activation['direct_intersections']
    assert activation['status']['returncode']==0 and not c.decode(activation['status']['stdout_base64'])
    assert activation['baseline']['returncode']==0 and not c.decode(activation['baseline']['stderr_base64'])
    old_manifest = json.loads(gzip.decompress(source.packet(activation['manifest'])))['inputs']
    assert old_manifest==activation['inputs']
    assert len(activation['images'])==len(old_manifest)+3==82
    tree = source.regular_tree()
    before_inputs = c.load('baseline-inputs.json.gz')['context']['inputs']
    for path,image in activation['images'].items():
        assert {key:image[key] for key in ('sha256','mode')}==before_inputs[path]
        assert image['git']==tree[path]
    proof = activation['git_verification']
    assert proof['returncode']==0 and not c.decode(proof['stderr_base64'])
    assert c.decode(proof['stdout_base64']).decode().splitlines()==[
        activation['images'][path]['git']['oid'] for path in sorted(activation['images'])]
    old_claim = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.17.0.json'
    assert c.read(old_claim)==activation['claim']
    assert json.loads(source.packet(activation['publication']))['record_base64']==activation['claim']['base64']
    for path,entry in activation['live_claims'].items():
        assert c.read(path)==entry['packet'], 'unrelated live claim changed'
    for name,fields in {
        'baseline-inputs.json.gz':dict(producer='baseline.py',probe='perl_probe.pl',plan='cases.json'),
        'baseline2-inputs.json.gz':dict(producer='baseline2.py',probe='perl_probe.pl',plan='cases2.json'),
        'qualification-inputs.json.gz':dict(producer='qualify.py',original_oracle='oracle.py',original_plan='cases.json'),
        'pre-repair-inputs.json.gz':dict(producer='repair.py',oracle='oracle2.py'),
        'green-inputs.json.gz':dict(producer='repair.py',oracle='oracle2.py',collector='baseline2.py'),
        'inverse-inputs.json.gz':dict(producer='repair.py',oracle='oracle2.py',collector='baseline2.py'),
        'restored-inputs.json.gz':dict(producer='repair.py',oracle='oracle2.py',collector='baseline2.py'),
    }.items():
        supplied = c.load(name)
        for key,filename in fields.items():
            assert supplied[key]==c.read(c.PREFIX+filename), 'actual producer: '+filename
    original = c.load('baseline.json.gz')
    assert original['inputs_unchanged']
    assert original['permanent']['returncode']==1
    assert b'Failed 3/6 subtests' in c.decode(original['permanent']['stdout_base64'])
    old_plan = c.load('cases.json')['cases']
    assert len(old_plan)==9
    old_control = next(row for row in old_plan if row['id']=='no-match')
    assert old_control['value'] is None and old_control['input']=='y'
    assert old_control['source']=='Top: /x/\n I { return(42) }\n'
    original_rows = parsed(original['library'])['rows']
    row = next(row for row in original_rows if row['id']=='no-match')
    for route in ('native','generated'):
        value = row[route]
        assert value['completed'] and value['value']==42 and not value['exception'] and not value['last_error']
        assert 'return 42' in (value.get('dump') or value['source'])
    original_checks = c.load('original-oracle-runs.json.gz')
    old_red = parsed(original_checks['cli'],1)
    assert len(old_red['failures'])==8
    assert sum(row['id']=='no-match' for row in old_red['failures'])==2
    assert original_checks['library']['returncode']==1
    assert b'AssertionError' in c.decode(original_checks['library']['stderr_base64'])
    qualification = c.load('control-qualification.json.gz')
    assert qualification['original_control']==old_control
    assert qualification['original_plan']==c.read(c.PREFIX+'cases.json')
    assert qualification['original_oracle']==c.read(c.PREFIX+'oracle.py')
    assert qualification['producer']==c.read(c.PREFIX+'prepare2.py')
    assert qualification['before_test']==c.load('qualification-inputs.json.gz')['original_test']
    assert b'Selecting a rule starts that rule' in source.packet(qualification['canonical'])
    probes = c.load('no-match-probes.json.gz')
    assert probes['inputs_unchanged']
    for row,expected in zip(parsed(probes['run'])['rows'],[0,None,42]):
        for route in ('native','generated'):
            value = row[route]
            assert value['completed'] and not value['exception'] and not value['last_error']
            assert json.dumps(value['value'])==json.dumps(expected)
    cases = c.load('cases2.json')['cases']
    expected = copy.deepcopy(old_plan)
    expected[-1].update(id='initializer-return',value=42)
    assert cases[:9]==expected and len(cases)==11
    assert len({case['source'] for case in cases})==10
    assert [case['id'] for case in cases[-2:]]==['no-match','matched-control']
    assert cases[-2]['source']==cases[-1]['source']==probes['plan']['cases'][1]['source']
    assert [(case['input'],case['value']) for case in cases[-2:]]==[('y',None),('x',42)]
    revised = c.load('control-revision.json.gz')
    assert revised['test']==c.load('green-inputs.json.gz')['test']
    assert revised['plan']==c.read(c.PREFIX+'cases2.json')
    assert revised['oracle']==c.read(c.PREFIX+'oracle2.py')
    assert revised['baseline_producer']==c.read(c.PREFIX+'baseline2.py')
    baseline = c.load('baseline2.json.gz')
    permanent(baseline,False)
    assert oracle2.library(baseline['library'])['successful_controls']==7
    checks = c.load('pre-repair-checks.json.gz')
    assert checks['inputs_unchanged']
    red = parsed(checks['cli'],1)
    assert red==oracle2.cli(baseline['cli']) and len(red['failures'])==6
    assert {row['id'] for row in red['failures']}=={'fractional-write','callable-fractional-write','wrong-container'}
    assert parsed(checks['library'])==oracle2.library(baseline['library'])
    repair = c.load('repair.json.gz')
    before,after = source.packet(repair['before']),source.packet(repair['after'])
    assert before.count(b'if ($parse_error) {\n')==1
    assert after==before.replace(b'if ($parse_error) {\n',b'if ($parse_error || $runtime_ctx{last_error}) {\n',1)
    assert repair['before']['mode']==repair['after']['mode'] and repair['after']['mode'] & 0o100
    assert repair['producer']==c.read(c.PREFIX+'repair.py') and repair['accepted_base']==c.BASE
    green = c.load('green.json.gz')
    permanent(green,True)
    checks = c.load('green-checks.json.gz')
    assert parsed(checks['cli'])==oracle2.cli(green['cli'])==dict(observations=22,failures=[])
    assert parsed(checks['library'])==oracle2.library(green['library'])
    for phase,packet in (('baseline2',baseline),('green',green)):
        assert set(packet['cli'])=={case['id'] for case in cases}
        for case in cases:
            for route,entry in packet['cli'][case['id']].items():
                run = entry['run']
                prefix = ['perl','-Iperl','bin/linkedspec','--inline-spec',case['source'],'--input',case['input']]
                assert run['command'][:7]==prefix
                if route=='quiet':
                    assert run['command']==prefix
                else:
                    tail = run['command'][7:]
                    assert tail[:3]==['--trace','low','--trace-file']
                    assert tail[3].endswith('/trace.log') and tail[4:]==['--trace-mode','route','--trace-reset']
    permanent(c.load('inverse.json.gz'),False)
    permanent(c.load('restored.json.gz'),True)
    for phase,version in [('baseline2','before'),('green','after'),('inverse','before'),('restored','after')]:
        actual = c.load(phase+'-inputs.json.gz')['context']['inputs']['bin/linkedspec']
        assert actual=={key:repair[version][key] for key in ('sha256','mode')}
    completion = c.load('repair-completion.json.gz')
    assert completion['source_restored'] and completion['source']==repair['after']
    assert (completion['full_cases'],completion['distinct_sources'],completion['full_cli_observations'])==(11,10,22)
    docs = c.load('documentation.json.gz')
    supplied = c.load('documentation-inputs.json.gz')
    assert supplied['producer']==c.read(c.PREFIX+'document.py') and not supplied['direct_intersections']
    assert supplied['prior_readonly']['returncode']==0 and not c.decode(supplied['prior_readonly']['stderr_base64'])
    for value in (docs['before'],docs['after']):
        for packet in value.values():
            source.packet(packet)
    old = source.packet(docs['before'][document.CARD]).decode()
    new = source.packet(docs['after'][document.CARD]).decode()
    assert old.split('answers:\n',1)[1].split('\ndate:',1)[0]==new.split('answers:\n',1)[1].split('\ndate:',1)[0]
    assert old.split('# Original operational rollout (July10)',1)[1]==new.split('# Original operational rollout (July10)',1)[1]
    assert docs['knowledge_byte_delta']==len(new.encode())-len(old.encode())
    book_inputs = c.load('book-inputs.json.gz')
    assert book_inputs['producer']==c.read(c.PREFIX+'book.py')
    for packet in book_inputs['inputs'].values():
        source.packet(packet)
    runs = c.load('book-runs.json.gz')
    assert runs['inputs_unchanged']
    book.validate(runs['healthy'],docs['commands'])
    reasons = dict(heading='CLI heading',command='CLI executable source',protocol='CLI failure protocol')
    assert runs['denials']==reasons
    for name,run in runs['faults'].items():
        try:
            book.validate(run,docs['commands'])
        except AssertionError as error:
            assert run['returncode']==0 and str(error)==reasons[name]
        else:
            raise AssertionError('changed source/render admitted')
    examples = c.load('book-runtime.json.gz')
    assert set(examples)=={'fractional-write','valid-null'}
    assert examples['fractional-write']['returncode']==1 and not c.decode(examples['fractional-write']['stdout_base64'])
    assert c.decode(examples['fractional-write']['stderr_base64'])==b'linkedspec: parser invocation failed\n'
    assert examples['valid-null']['returncode']==0 and c.decode(examples['valid-null']['stdout_base64'])==b'null\n'
    assert not c.decode(examples['valid-null']['stderr_base64'])
    return dict(source=epochs,prior_custody_images=82,cases=11,distinct_sources=10,cli_observations=22,
        baseline_cli_red=6,successful_controls=7,permanent_groups=6,inverse_failed_groups=2,
        exact_restoration=True,book_inputs=len(book_inputs['inputs']),book_commands=2,book_source_denials=3,
        knowledge_byte_delta=docs['knowledge_byte_delta'],
        limits='Dated accepted329cee31c plus exact retained CLI overlay and complete instrument epochs. Original nine-case wrong-target rows/tests/oracles remain qualified, without product RED credit. Full CLI/Get/fresh scope belongs to green; inverse/restored scope is the actual permanent consumer. SDK/OS/published dependency outputs are read-only prerequisites. No selector/library/trace-schema or wider backend admission; canonical workflow governs landing.')


if __name__ == '__main__':
    print(json.dumps(check(),sort_keys=True))
