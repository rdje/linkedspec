"""Final readonly publication, preserving the complete first unpublished epoch."""
import json
import sys
import common as c
import publish as initial
import review_final as review

MANIFEST=c.PREFIX+'publication-final-inputs.json'
PUBLICATION=c.PREFIX+'publication-final.json'
CLAIM='docs/claims/'+c.OWNER+'.json'


def input_paths():
    paths=set(c.load('focused-inputs.json.gz')['inputs'])
    paths.update(c.load('doc-inputs.json.gz')['book'])
    paths.update(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT/c.PREFIX).rglob('*')
                 if path.is_file() and '__pycache__' not in path.parts)
    paths.update(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT/'tests/drop-generated').rglob('*') if path.is_file())
    paths.update(['t/drop_keys_generated.t','tests/language-readiness/drop-generated-regression-evolution.json.gz'])
    return sorted(paths-{MANIFEST,PUBLICATION,CLAIM})


def record(result):
    value=initial.record(result)
    claim=value['claims'][0]
    producers={path for path in input_paths() if path.startswith(c.PREFIX) and path.endswith(('.py','.pl'))}
    producers.update([c.SOURCE,'t/drop_keys_generated.t','tests/language-readiness/verify_objectives.py',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py',
        'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-focused.pl'])
    bindings=[dict(path=path,sha256=c.identity(path)['sha256'],role='producer') for path in sorted(producers)]
    bindings.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
    claim['durability']=dict(status='checked',mode='live',inputs=sorted(bindings,key=lambda item:item['path']))
    claim['rederive']['command']='bash tools/run_python_project_data.sh '+c.PREFIX+'publish_final.py'
    claim['rederive']['result']+=' Whole first10304-input draft/actual readonly0 and10308 independently Git-verified '
    claim['rederive']['result']+='staged images survive; stale historical fact route corrected after actual RED; '
    claim['rederive']['result']+='actual pointer source fault/restoration and3 artifact denials; one generated '
    claim['rederive']['result']+='cache preserved/removed with ignore/source/residue controls; composed650/current Knowledge pass.'
    claim['falsify']['red_control']+=' Actual stale current-fact route RED; reverting the corrected fact source '
    claim['falsify']['red_control']+='pointer rejects and restores;3 first-draft baseline/index/mode denials. The '
    claim['falsify']['red_control']+='first canonical143 was intentionally superseded before bound corrections.'
    return value


def main():
    assert sys.argv[1:] in ([],['--capture'])
    capture=sys.argv[1:]==['--capture']
    if capture:assert c.read(CLAIM)==c.load('admission/first.json.gz')['original'][CLAIM]
    inputs={path:c.identity(path) for path in input_paths()}
    if capture:
        c.write_new('publication-final-inputs.json',dict(inputs=inputs,
            scope='Every regular actual focused context input, all recursive new proof/data producers and '
                  'records, current whole book/Knowledge and exact full modes. First publication/10304 '
                  'inputs/10308 stage images/actual readonly0 remain intact; whole changed source before '
                  'packets and real accepted Git recover every epoch. Own final outputs excluded. The '
                  'unused generated cache is retained as historical bytes and absent from final source/stage. '
                  'Gitlinks/symlink targets are uninspected; installed core tools are read-only prerequisites.'))
    assert c.load('publication-final-inputs.json')['inputs']==inputs
    result=review.check()
    assert c.unchanged(inputs)
    raw=(json.dumps(record(result),separators=(',',':'))+'\n').encode()
    assert len(raw)<=131072
    publication=dict(result=result,record_base64=c.encode(raw))
    if capture:
        c.write_new('publication-final.json',publication)
        (c.ROOT/CLAIM).write_bytes(raw)
    else:
        assert (c.ROOT/CLAIM).read_bytes()==raw and c.load('publication-final.json')==publication
    print('Current final drop publication PASS:',len(inputs),
          'closed inputs;34 values/14 diagnostics;4 producer faults;9 suites/1322; historical644+6;book89/3;first10304/stage10308 retained')


if __name__=='__main__':main()
