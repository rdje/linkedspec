"""Capture once; verify bounded dated evidence on all later invocations."""
import json
import sys
import common as c
import metadata_review

MANIFEST_NAME = 'publication-inputs.json.gz'
PUBLICATION_NAME = 'publication.json'
MANIFEST = c.PREFIX+MANIFEST_NAME
PUBLICATION = c.PREFIX+PUBLICATION_NAME
CLAIM = 'docs/claims/'+c.OWNER+'.json'


def input_paths():
    owned = {path.relative_to(c.ROOT).as_posix() for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()}
    return sorted((owned | set(metadata_review.PRODUCERS)) - {MANIFEST,PUBLICATION,CLAIM})


def validate_inputs(declared, actual):
    assert set(declared) == set(actual), 'input population'
    for path,item in actual.items():
        assert declared[path]['sha256'] == item['sha256'], 'input bytes: '+path
        assert declared[path]['mode'] == item['mode'], 'input mode: '+path


def controls():
    value = c.load('artifact2-inputs.json.gz')
    result = {}
    for name,declared in value['cases'].items():
        try:
            validate_inputs(declared,value['actual'])
        except AssertionError as error:
            result[name] = dict(rejected=True,reason=str(error))
        else:
            result[name] = dict(rejected=False,reason='')
    return result


def record(result):
    bindings = [dict(path=path,sha256=c.identity(path)['sha256'],
        role='producer' if path.endswith(('.py','.pl','.sh')) else 'input') for path in input_paths()]
    bindings.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
    command = 'bash tools/run_python_project_data.sh '+c.PREFIX+'review.py'
    metadata = result['metadata']
    dated = dict(name='dated-retained-artifact-review',
        statement=f"At {metadata['at_utc']}, the parent review retained {metadata['parent_files']} candidates/{metadata['parent_bytes']} bytes and six explicit Rust locations; zero removals.",
        scope=metadata['scope']+' Default Dart/Julia and Lua wrapper retention conventions are explicit; no live-state or disposability admission.',
        rederive=dict(status='checked',command=command,
            granularity='Every dated candidate row, suffix and Rust location; two actual census channels and independent per-file lstat. Complete supplied book inputs and unchanged scalar core consumer are separately retained.',
            result=json.dumps(metadata,sort_keys=True)+f"; book{result['book_inputs']}/actual marker RED; core PASS."),
        falsify=dict(status='checked',hypothesis='Matching aggregates can conceal wrong file sizes, failed channels, altered producers or missing rendered maintenance teaching.',
            oracle='Independent per-file OS metadata, complete actual channels, producer identities, six non-following traversal controls and rendered example marker.',
            red_control='Four actual reason-sensitive metadata reader denials and healthy/restored observations; actual missing book marker RED. Three missing/byte/mode declaration denials admit only under the actual validator bypass and reject after exact restoration.'),
        durability=dict(status='checked',mode='live',inputs=bindings))
    preserved = dict(name='accepted-deferred-write-publication-custody',
        statement='Whole accepted deferred-write12 publication4 and actual clean readonly0 precede all maintenance tracked writes at real '+c.BASE+'; original observations remain unchanged.',
        scope='Complete original claim/publication/manifest/gateway, every regular Git image with separately captured full permissions, and complete checked-live declaration census. Only original12 durability mode/revision changes. No historical runtime producer rerun.',
        rederive=dict(status='checked',command=command,
            granularity='Every accepted physical image, real Git blob/mode, original watched identity and full source packets, actual baseline exit/channels and mode/revision-only retirement.',
            result=json.dumps(result['custody'],sort_keys=True)+'; four actual custody denials/restoration PASS.'),
        falsify=dict(status='checked',hypothesis='Incomplete image populations, changed executable/other permissions or a failed baseline could be mistaken for complete accepted custody.',
            oracle='Real accepted Git tree/blob identities, independent original hash-object channels, original manifest and complete source packet modes.',
            red_control='Actual missing-image, executable-bit, other-permission and failed-baseline controls reject for their specific reasons; exact healthy/restored observations pass. No chmod of original source occurs.'),
        durability=dict(status='checked',mode='live',inputs=bindings))
    return dict(version=1,owner=c.OWNER,claims=[dated,preserved])


def main():
    if sys.argv[1:] == ['--controls']:
        print(json.dumps(controls(),sort_keys=True))
        return
    assert sys.argv[1:] in ([],['--capture'])
    capture = sys.argv[1:] == ['--capture']
    inputs = {path:c.identity(path) for path in input_paths()}
    if capture:
        assert not (c.ROOT/CLAIM).exists()
        c.write_new(MANIFEST_NAME,dict(base=c.BASE,inputs=inputs,
            scope='Bounded actual producers and retained dated evidence. Original accepted images recover from real Git; changed/new measured sources and complete book inputs retain whole packets. Later mutable continuity is not a live measurement input. Other repositories and Gitlinks remain uninspected.'))
    validate_inputs(c.load(MANIFEST_NAME)['inputs'],inputs)
    import review
    result = review.check()
    validate_inputs(inputs,{path:c.identity(path) for path in input_paths()})
    raw = (json.dumps(record(result),separators=(',',':'))+'\n').encode()
    publication = dict(result=result,record_base64=c.encode(raw))
    if capture:
        c.write_new(PUBLICATION_NAME,publication)
        with (c.ROOT/CLAIM).open('xb') as output:
            output.write(raw)
    else:
        assert c.source(CLAIM).read_bytes() == raw and c.load(PUBLICATION_NAME) == publication
    print('Maintenance21 publication PASS:',len(inputs),'bounded inputs;',metadata_review.validate(c.load('metadata.json.gz'))['parent_files'],'dated parent candidates; zero removals')


if __name__ == '__main__':
    main()
