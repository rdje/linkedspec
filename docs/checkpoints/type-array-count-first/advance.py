"""Prepare a distinct second publication without overwriting the preserved first draft."""
import ast
import common as c
import context
from admit_phase0 import TABLE,PHASE0,AUDITOR,DRIVER,replace_once
from phase0 import ACTOR


def main():
    c.write_new('publication2-preparation-inputs.json.gz',context.snapshot())
    paths = [c.PREFIX+'publish.py',c.PREFIX+'review.py']
    before = {path:c.read(path) for path in paths}
    publisher = c.decode(before[paths[0]]['base64']).decode()
    publisher = replace_once(publisher,"MANIFEST_NAME = 'publication-inputs.json.gz'","MANIFEST_NAME = 'publication2-inputs.json.gz'")
    publisher = replace_once(publisher,"PUBLICATION_NAME = 'publication.json'","PUBLICATION_NAME = 'publication2.json'")
    publisher = publisher.replace("'artifact-inputs.json.gz'","'artifact2-inputs.json.gz'")
    publisher = replace_once(publisher,'        assert not (c.ROOT/CLAIM).exists()',
        "        assert c.source(CLAIM).read_bytes() == c.decode(c.load('draft1.json.gz')['packets']['claim']['base64'])")
    publisher = replace_once(publisher,"        with (c.ROOT/CLAIM).open('xb') as output:\n            output.write(raw)",
        '        c.source(CLAIM).write_bytes(raw)')
    marker = "    bindings = [dict(path=path,sha256=c.identity(path)['sha256'],role='producer')"
    assert publisher.count(marker) == 1
    publisher = publisher.replace(marker,'    producers += '+repr([PHASE0,AUDITOR,DRIVER,ACTOR])+'\n'+marker,1)
    marker = "    bindings.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))"
    publisher = replace_once(publisher,marker,"    bindings.append(dict(path="+repr(TABLE)+",sha256=c.identity("+repr(TABLE)+")['sha256'],role='input'))\n"+marker)
    marker = "    continuity = dict(name='finite-selection-history-continuity',"
    extra = '''    runtime['rederive']['result'] += (f" Phase0:{result['phase0']['selected']} focused roots/"
        f"{result['phase0']['goldens']} exact guard goldens; retained historical audit "
        f"{result['phase0']['previous']} prior+{result['phase0']['added']} new="
        f"{result['phase0']['current']} denials. Focused roots retain explicit skips; canonical full Phase0 remains required.")
    runtime['falsify']['red_control'] += (' Actual old Phase0 expectations reject all selected roots; ten exact guard literals pass after repair. '
        'The independent hash-gated inverse restores real accepted bytes before unchanged older layers. '
        'Actual inverse-call removal rejects; an inert table byte rejects, a real hash-check bypass admits it, '
        'and exact source/table restoration restores rejection and healthy observations. '
        'Whole unpublished draft1 and its actual readonly baseline survive before these bound edits.')
'''
    publisher = replace_once(publisher,marker,extra+marker)
    review = c.decode(before[paths[1]]['base64']).decode()
    review = review.replace('artifact-','artifact2-').replace("'doc2-run.json.gz'","'doc3-run.json.gz'").replace("'doc2-inputs.json.gz'","'doc3-inputs.json.gz'")
    function = '''def verify_phase0():
    plan = c.load('phase0-plan.json.gz')['plan']
    summaries = {}
    for stem in ('phase0-accepted','phase0-candidate'):
        run = c.load(stem+'-run.json.gz')
        result = c.load(stem+'-result.json')
        assert run['inputs_unchanged'] and run['plan'] == plan
        marker = b'# FOCUSED_PHASE0_JSON '
        out = c.decode(run['run']['stdout_base64'])
        assert out.count(marker) == 1
        actual = json.loads(out.split(marker)[1].splitlines()[0])
        assert actual == result['summary'] and actual['complete_selection']
        assert actual['selected'] == len(plan['selected']) and actual['root_tests'] == plan['ordinary_root_tests']
        assert run['run']['returncode'] == (1 if stem.endswith('accepted') else 0)
        if stem.endswith('accepted'):
            assert set(result['failed']) == {row['number'] for row in plan['selected']}
        else:
            assert not result['failed'] and actual['passing'] and not c.decode(run['run']['stderr_base64'])
        summaries[stem] = actual
    assert summaries['phase0-accepted']['skipped'] == summaries['phase0-candidate']['skipped']
    admission = c.load('phase0-admission.json.gz')
    for path,packet in admission['after'].items():
        assert c.read(path) == packet
    table_path = 'tests/language-readiness/count-first-regression-evolution.json'
    assert c.read(table_path) == admission['table']
    table = json.loads(c.source(table_path).read_bytes())
    before = subprocess.check_output(['git','show',c.BASE+':'+table['source']],cwd=c.ROOT)
    rebuilt = before
    for row in table['hunks']:
        old,new = row['before'].encode(),row['after'].encode()
        assert rebuilt.count(old) == 1 and old != new
        rebuilt = rebuilt.replace(old,new,1)
    assert c.sha(before) == table['before_sha256'] and c.sha(rebuilt) == table['after_sha256']
    assert rebuilt == c.source(table['source']).read_bytes()
    current = c.load('history-final-run.json.gz')
    assert current['inputs_unchanged'] and current['run']['returncode'] == 0
    assert not c.decode(current['run']['stderr_base64'])
    historical = json.loads(c.decode(current['run']['stdout_base64']))
    result = c.load('history-final-result.json')
    assert result['added'] == 3*len(table['hunks']) and result['current'] == result['previous']+result['added']
    assert historical['audit_controls']['governance_mutations_rejected'] == result['current']
    assert historical['healthy_audit_guard'] == dict(original_log_attempts=0,tracked_write_attempts=0)
    assert historical['tracked_inputs'][table_path] == c.identity(table_path)['sha256']
    faults = c.load('history-faults-result.json')
    assert all(faults[key] for key in ('inverse_bypass_rejected','table_byte_change_rejected',
        'actual_hash_bypass_admitted','restored_hash_rejected','sources_restored'))
    values = {}
    for stem in ('healthy','inverse-fault','inverse-restored','table-red','hash-fault','hash-restored','final'):
        run = c.load('history-unit-'+stem+'-run.json.gz')
        assert run['inputs_unchanged'] and not c.decode(run['run']['stderr_base64'])
        value = json.loads(c.decode(run['run']['stdout_base64']))
        assert run['run']['returncode'] == (0 if value['completed'] else 1)
        supplied = c.load('history-unit-'+stem+'-inputs.json.gz')['inputs']
        assert all(identity == supplied[path] for path,identity in value['identities'].items())
        values[stem] = value
    assert values['healthy'] == values['inverse-restored'] == values['final']
    assert values['healthy']['completed'] and values['hash-fault']['completed']
    assert not any(values[key]['completed'] for key in ('inverse-fault','table-red','hash-restored'))
    assert values['table-red']['error'] == values['hash-restored']['error']
    draft = c.load('draft1.json.gz')
    assert draft['inputs_unchanged'] and draft['baseline']['returncode'] == 0
    assert not c.decode(draft['baseline']['stderr_base64'])
    assert c.source(c.PREFIX+'publication.json').read_bytes() == c.decode(draft['packets']['publication']['base64'])
    assert c.source(c.PREFIX+'publication-inputs.json.gz').read_bytes() == c.decode(draft['packets']['manifest']['base64'])
    return dict(result,selected=len(plan['selected']),skipped=summaries['phase0-candidate']['skipped'],goldens=len(table['hunks']))


'''
    review = replace_once(review,'def check(fresh=True,artifacts=True):\n',function+'def check(fresh=True,artifacts=True):\n')
    review = replace_once(review,'    continuity = history()\n','    continuity = history()\n    phase0 = verify_phase0()\n')
    review = replace_once(review,"historical_controls=direct['historical_controls'],book_inputs=len(inputs['book']),",
        "historical_controls=phase0['current'],phase0=phase0,book_inputs=len(inputs['book']),")
    ast.parse(publisher,filename=paths[0]); ast.parse(review,filename=paths[1])
    artifact = c.source(c.PREFIX+'artifacts.py').read_text().replace('artifact-','artifact2-')
    artifact = replace_once(artifact,'    target = c.SOURCES[0]','    target = '+repr(TABLE))
    ast.parse(artifact)
    for path,value in zip(paths,(publisher,review)):
        c.source(path).write_text(value)
        c.source(path).chmod(before[path]['mode'])
    with (c.ROOT/c.PREFIX/'artifacts2.py').open('x') as output:
        output.write(artifact)
    c.write_new('publication2-preparation.json.gz',dict(before=before,after={path:c.read(path) for path in paths},
        artifact_producer=c.read(c.PREFIX+'artifacts2.py'),
        scope='First publication/manifest and whole original claim remain preserved as an unpublished draft. Second publication uses distinct outputs and replaces only the active claim after checking its exact preserved original bytes. New inverse, focused roots, actual historical controls and producer/input identities are explicitly reviewed; new actual artifact controls target the inverse table.'))
    print('Distinct publication2 and source/table/Phase0 reviewer prepared')


if __name__ == '__main__':
    main()
