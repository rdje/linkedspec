"""Capture once; default publication is a bounded, read-only dated CLI review."""
import json
import sys
import common as c
import review
import source_review

MANIFEST_NAME = 'publication-inputs.json.gz'
PUBLICATION_NAME = 'publication.json'
MANIFEST = c.PREFIX+MANIFEST_NAME
PUBLICATION = c.PREFIX+PUBLICATION_NAME
CLAIM = 'docs/claims/'+c.OWNER+'.json'
WRAPPERS = ['tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh']


def input_paths():
    owned = {path.relative_to(c.ROOT).as_posix() for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()}
    return sorted((owned | set(WRAPPERS)) - {MANIFEST,PUBLICATION,CLAIM})


def validate_inputs(declared, actual):
    assert set(declared)==set(actual), 'input population'
    for path,item in actual.items():
        assert declared[path]['sha256']==item['sha256'], 'input bytes: '+path
        assert declared[path]['mode']==item['mode'], 'input mode: '+path


def validate_scope(actual, controls_ready=True):
    required = set(WRAPPERS)
    for name in source_review.EPOCHS:
        required.add(c.PREFIX+name)
        required.update(path for path in c.load(name)['context']['inputs'] if path.startswith(c.PREFIX))
    required.update(c.PREFIX+name for name in (
        'cases.json','cases2.json','baseline.json.gz','baseline2.json.gz','green.json.gz',
        'inverse.json.gz','restored.json.gz','repair-completion.json.gz',
        'oracle.py','oracle2.py','repair.py','source_review.py','review.py','publish.py',
        'artifact_controls.py','control_review.py','README.md','book-runtime.json.gz','book-runs.json.gz'))
    if controls_ready:
        required.update(c.PREFIX+name for name in ('artifact-controls-inputs.json.gz','artifact-controls.json.gz'))
    missing = sorted(required-set(actual))
    assert not missing, 'required input: '+','.join(missing)


def controls():
    value = c.load('artifact-controls-inputs.json.gz')
    result = {}
    for name,declared in value['cases'].items():
        try:
            validate_inputs(declared,value['actual'])
        except AssertionError as error:
            result[name]=dict(rejected=True,reason=str(error))
        else:
            result[name]=dict(rejected=False,reason='')
    return result


def record(result,controls_result):
    bindings = [dict(path=path,sha256=c.identity(path)['sha256'],
        role='producer' if path.endswith(('.py','.pl','.sh')) else 'input') for path in input_paths()+[MANIFEST]]
    claim = dict(name='perl-primary-cli-context-failure-repair',
        statement='The exact retained invocation-predicate overlay on '+c.BASE+' reports context-only failures with the existing exit1/empty-stdout/stable-stderr/error-trace protocol. Eleven source/input cases use ten source texts and22 quiet/routed commands; seven successful controls and the existing thrown-error path remain compatible.',
        scope='Dated public Get/descriptor/dump/fresh and Perl primary CLI proof, permanent regression source inverse/restoration, complete affected book teaching and prior intake custody. No signed-selector, library, trace-schema, exhaustive-error or wider backend admission. Original wrong I-return target/tests/oracles remain qualified separately. Exact canonical workflow governs landing.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py',
            granularity='Each source/input, actual command exit/stdout/stderr/trace, nine conservative source epochs, exact one-condition overlay and permanent consumer, prior82-image custody, complete book inputs and two executed public commands.',
            result=json.dumps(result,sort_keys=True)),
        falsify=dict(status='checked',hypothesis='A successful null or a truthiness-based result check could conceal handler failures or reject valid falsey results; stale rendered teaching and jointly incomplete proof inventories could pass aggregate summaries.',
            oracle='Existing invocation protocol on three independent typed failures versus seven clear-channel controls; explicit matched/no-match twins; actual permanent consumer under the original predicate; source-sensitive rendered teaching; input identity and an independent required-input floor.',
            red_control='Six actual corrected-baseline CLI observations reject, the full fixed population passes, and the exact old predicate restores two permanent failing groups before exact GREEN restoration. Three actual altered book sources render but fail named checks. Three identity and two required-input omissions admit only under actual validator bypass and reject after restoration. The scope bootstrap excludes its own not-yet-written control output; default published scope also requires that output. '+json.dumps(controls_result,sort_keys=True)),
        durability=dict(status='checked',mode='live',inputs=bindings))
    return dict(version=1,owner=c.OWNER,claims=[claim])


def main():
    if sys.argv[1:]==['--identity-controls']:
        print(json.dumps(controls(),sort_keys=True))
        return
    if sys.argv[1:]==['--scope-check']:
        validate_scope({path:c.identity(path) for path in input_paths()},controls_ready=False)
        print('Required-input scope PASS')
        return
    assert sys.argv[1:] in ([],['--capture'])
    capture = sys.argv[1:]==['--capture']
    inputs = {path:c.identity(path) for path in input_paths()}
    validate_scope(inputs)
    if capture:
        assert not (c.ROOT/CLAIM).exists()
        c.write_new(MANIFEST_NAME,dict(base=c.BASE,inputs=inputs,
            scope='Retained actual CLI actors/evidence and wrappers. Main runtime/test sources recover from accepted Git and complete changed/new images; complete book inputs are retained whole. Later mutable continuity/runtime edits do not replace this dated measurement. Other repositories/Gitlinks and installed SDK/OS outputs stay read-only prerequisites.'))
    validate_inputs(c.load(MANIFEST_NAME)['inputs'],inputs)
    result = review.check()
    import control_review
    controls_result = control_review.check()
    validate_inputs(inputs,{path:c.identity(path) for path in input_paths()})
    raw = (json.dumps(record(result,controls_result),separators=(',',':'))+'\n').encode()
    publication = dict(result=result,controls=controls_result,record_base64=c.encode(raw))
    if capture:
        c.write_new(PUBLICATION_NAME,publication)
        with (c.ROOT/CLAIM).open('xb') as output:
            output.write(raw)
    else:
        assert c.source(CLAIM).read_bytes()==raw and c.load(PUBLICATION_NAME)==publication
    print('CLI repair publication PASS:',len(inputs),'bounded inputs;11 cases/10 source texts/22 commands; no signed admission')


if __name__ == '__main__':
    main()
