"""One publication capture; all default invocations are read-only dated reviews."""
import json
import sys
import common as c
import review

MANIFEST_NAME = 'publication-inputs.json.gz'
PUBLICATION_NAME = 'publication.json'
MANIFEST = c.PREFIX+MANIFEST_NAME
PUBLICATION = c.PREFIX+PUBLICATION_NAME
CLAIM = 'docs/claims/'+c.OWNER+'.json'
WRAPPERS = ['tools/project_data_env.sh','tools/project_data_run.sh',
    'tools/run_python_project_data.sh','tools/run_cargo_local.sh',
    'tools/run_dart_project_data.sh','tools/run_julia_project_data.sh',
    'tools/build_lua_native.sh','tools/run_mdbook_local.sh']


def input_paths():
    owned = {path.relative_to(c.ROOT).as_posix() for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()}
    return sorted((owned | set(WRAPPERS)) - {MANIFEST,PUBLICATION,CLAIM})


def validate_inputs(declared, actual):
    assert set(declared) == set(actual), 'input population'
    for path,item in actual.items():
        assert declared[path]['sha256'] == item['sha256'], 'input bytes: '+path
        assert declared[path]['mode'] == item['mode'], 'input mode: '+path


def validate_scope(actual):
    """An independently derived floor survives joint manifest/enumerator omission."""
    required = set(WRAPPERS)
    for name in review.EPOCHS:
        required.add(c.PREFIX+name)
        required.update(path for path in c.load(name)['context']['inputs'] if path.startswith(c.PREFIX))
    required.update(c.PREFIX+name for name in (
        'cases.json','review.py','publish.py','artifact_controls.py','control_review.py',
        'README.md','TRANSITION.md',
        'native-completion.json.gz','oracle-runs.json.gz','book-runs.json.gz','book-runtime.json.gz'))
    archives = [c.load('native-rust-artifact.json')]
    for abi in ('puc','luajit'):
        archives.extend(c.load('native-'+abi+'-artifacts.json').values())
    required.update(part['path'] for value in archives for part in value['parts'])
    missing = sorted(required-set(actual))
    assert not missing, 'required input: '+','.join(missing)


def controls():
    value = c.load('artifact-controls-inputs.json.gz')
    result = {}
    for name,declared in value['cases'].items():
        try:
            validate_inputs(declared,value['actual'])
        except AssertionError as error:
            result[name] = dict(rejected=True,reason=str(error))
        else:
            result[name] = dict(rejected=False,reason='')
    return result


def record(result,controls_result):
    bindings = [dict(path=path,sha256=c.identity(path)['sha256'],
        role='producer' if path.endswith(('.py','.pl','.sh')) else 'input') for path in input_paths()+[MANIFEST]]
    claim = dict(name='dated-signed-selector-intake',
        statement='At unchanged runtime sources based on '+c.BASE+', 32 exact sources have 192 native CLI observations plus Perl descriptor/Get/fresh observations. Negative selectors are not admitted; the context-only Perl CLI failure is owned by17.8.',
        scope='Finite literal/dynamic ordinary/deferred array cases, mixed paths, quoted-key/positive/effect controls, retained Rust calibration and public book examples. This is a dated diagnostic baseline and transition plan, not signed-index implementation, backend acceptance, exhaustive type coverage or a repaired CLI claim.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py',
            granularity='Each exact source, every actual separate command channel, eight conservative source epochs, archived executable bytes, prior accepted publication custody and complete rendered-book input population.',
            result=json.dumps(result,sort_keys=True)),
        falsify=dict(status='checked',hypothesis='Host-language indexing, a successful null CLI result or an aggregate count could conceal missing signed behavior, swallowed errors, stale documentation or omitted proof inputs.',
            oracle='Independent director L+index values on13 finite cases, existing invocation-failure protocol on two invalid writes, actual source-sensitive rendered-book validator, byte/mode identities and an independently derived required-input floor.',
            red_control='All eight signed retained-output routes report actual RED; Perl CLI failure oracle RED and five other CLI routes GREEN. Three changed book sources render but fail specific checks. Actual input missing/bytes/mode denials and two enumerator omissions admit only under their actual validator bypasses and reject after restoration. '+json.dumps(controls_result,sort_keys=True)),
        durability=dict(status='checked',mode='live',inputs=bindings))
    return dict(version=1,owner=c.OWNER,claims=[claim])


def main():
    if sys.argv[1:] == ['--identity-controls']:
        print(json.dumps(controls(),sort_keys=True))
        return
    if sys.argv[1:] == ['--scope-check']:
        validate_scope({path:c.identity(path) for path in input_paths()})
        print('Required-input scope PASS')
        return
    assert sys.argv[1:] in ([],['--capture'])
    capture = sys.argv[1:] == ['--capture']
    inputs = {path:c.identity(path) for path in input_paths()}
    validate_scope(inputs)
    if capture:
        assert not (c.ROOT/CLAIM).exists()
        c.write_new(MANIFEST_NAME,dict(base=c.BASE,inputs=inputs,
            scope='Bounded retained intake producers/evidence and actual wrappers. Runtime source images recover from accepted Git plus complete changed/new source packets; book inputs and native products are retained whole. Later mutable continuity and runtime fixes are not live bindings. Other repositories and Gitlinks remain read-only prerequisites.'))
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
        assert c.source(CLAIM).read_bytes() == raw and c.load(PUBLICATION_NAME) == publication
    print('Signed intake PASS:',len(inputs),'bounded inputs;32 sources;192 native observations; no signed admission')


if __name__ == '__main__':
    main()
