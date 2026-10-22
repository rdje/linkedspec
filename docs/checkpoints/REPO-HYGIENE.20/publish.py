"""Capture once; otherwise verify this bounded dated evidence without source writes."""
import json
import sys
import common as c
import metadata_review

MANIFEST_NAME = 'publication-inputs.json.gz'
PUBLICATION_NAME = 'publication.json'
MANIFEST = c.PREFIX + MANIFEST_NAME
PUBLICATION = c.PREFIX + PUBLICATION_NAME
CLAIM = 'docs/claims/' + c.OWNER + '.json'


def input_paths():
    owned = {path.relative_to(c.ROOT).as_posix() for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()}
    return sorted((owned | set(metadata_review.PRODUCERS)) - {MANIFEST,PUBLICATION,CLAIM})


def validate_inputs(declared, actual):
    assert set(declared)==set(actual), 'input population'
    for path,item in actual.items():
        assert declared[path]['sha256']==item['sha256'], 'input bytes: '+path
        assert declared[path]['mode']==item['mode'], 'input mode: '+path


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
    bindings = [dict(path=path,sha256=c.identity(path)['sha256'],role='producer' if path.endswith(('.py','.pl','.sh')) else 'input')
        for path in input_paths()]
    bindings.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
    metadata = result['metadata']
    dated = dict(name='dated-retained-artifact-review',
        statement=f"At {metadata['at_utc']}, the scoped parent census retained {metadata['parent_files']} candidates/{metadata['parent_bytes']} bytes and the six explicit Rust locations; zero removals.",
        scope=metadata['scope']+' Retained default Dart/Julia directories and Lua per-run output convention are explicit. This is not content ownership/disposability, purge authorization or a current filesystem census.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'review.py',
            granularity='Each exact candidate row, suffix total and Rust location; two complete actual producer channels, fresh comparison and independent per-file OS metadata. Complete supplied book bytes/configuration/includes and existing scalar core consumer are retained separately.',
            result=json.dumps(metadata,sort_keys=True)+f"; book{result['book_inputs']}/actual marker RED; focused core PASS. Default review checks dated evidence rather than future mutable continuity."),
        falsify=dict(status='checked',hypothesis='An equal aggregate can hide wrong per-file sizes, failed/lost channels, altered producer code or missing maintenance teaching.',
            oracle='Independent per-file lstat, actual complete producer exits/channels, captured source identities, non-following traversal fixtures and rendered maintenance marker.',
            red_control='Four actual reader denials reject aggregate inflation, coherently balanced per-file corruption, a failed producer and changed source identity for named reasons; healthy/restored observations pass. Six traversal controls distinguish boundary/population cases. An actual missing marker fails despite mdBook exit0. Missing/byte/mode declarations reject, an actual validator bypass admits them, and exact restoration rejects them again.'),
        durability=dict(status='checked',mode='live',inputs=bindings))
    preservation = dict(name='accepted-count-first-publication-custody',
        statement='Whole accepted count/first10 publication4 and actual clean readonly0 precede every maintenance tracked write at real79c68715; only claim10 durability mode/revision changes.',
        scope='11129 physical input identities/11132 independently Git-verified blob identities with complete actual filesystem modes; three older logical aliases remain retained through existing chunks. Git identity and full filesystem permissions remain distinct; no chmod or historical runtime rerun.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'review.py',
            granularity='Every regular accepted Git image and original mode, full original claim/publication/manifest/gateway, actual clean readonly result and exact mode/revision-only retirement.',
            result=json.dumps(result['custody'],sort_keys=True)+'; four actual missing-image/executable/other-permission/baseline denials and restoration PASS.'),
        falsify=dict(status='checked',hypothesis='Partial images, changed permission bits or a failed baseline could be presented as whole accepted custody, or Git mode could be confused with complete stat permissions.',
            oracle='Real accepted Git tree/object identities, independently observed hash-object output, complete captured mode fields and original manifest/owned packets.',
            red_control='Distinct actual missing-image, executable-bit, other-permission and failed-baseline controls reject for their named reasons and restore. The original false equality rejects healthy/restored input and remains preserved, without successful-proof credit. All36 mode observations and the overgeneralized preparation failure remain exact. No source permissions change.'),
        durability=dict(status='checked',mode='live',inputs=bindings))
    return dict(version=1,owner=c.OWNER,claims=[dated,preservation])


def main():
    if sys.argv[1:]==['--controls']:
        print(json.dumps(controls(),sort_keys=True))
        return
    assert sys.argv[1:] in ([],['--capture'])
    capture = sys.argv[1:]==['--capture']
    inputs = {path:c.identity(path) for path in input_paths()}
    if capture:
        assert not (c.ROOT/CLAIM).exists()
        c.write_new(MANIFEST_NAME,dict(base=c.BASE,inputs=inputs,
            scope='Bounded actual producers and immutable dated evidence. Supplied book inputs retain complete bytes/modes; source epochs retain whole changed packets and immutable identities, with unchanged bytes recoverable at real79c68715. Mutable future continuity is not a gratuitous live binding. Gitlinks/other repositories remain uninspected read-only boundaries.'))
    validate_inputs(c.load(MANIFEST_NAME)['inputs'],inputs)
    import review
    result = review.check()
    validate_inputs(inputs,{path:c.identity(path) for path in input_paths()})
    raw = (json.dumps(record(result),separators=(',',':'))+'\n').encode()
    publication = dict(result=result,record_base64=c.encode(raw))
    if capture:
        c.write_new(PUBLICATION_NAME,publication)
        with (c.ROOT/CLAIM).open('xb') as output:output.write(raw)
    else:
        assert c.source(CLAIM).read_bytes()==raw and c.load(PUBLICATION_NAME)==publication
    print(f"Maintenance20 publication PASS:{len(inputs)} bounded inputs;{result['metadata']['parent_files']} dated parent candidates;zero removals;metadata4/custody4/book marker controls; source readonly")


if __name__ == '__main__':
    main()
