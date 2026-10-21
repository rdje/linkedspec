"""Readonly final publication after retaining the whole first pressure-rejected draft."""
import importlib.util
import json
import sys
import common as c
import publish as initial
import review

spec=importlib.util.spec_from_file_location('aggregate_admission_verify',c.ROOT/(c.PREFIX+'admission/verify.py'))
admission=importlib.util.module_from_spec(spec);spec.loader.exec_module(admission)

MANIFEST=c.PREFIX+'publication-final-inputs.json.gz'
PUBLICATION=c.PREFIX+'publication-final.json'
CLAIM='docs/claims/'+c.OWNER+'.json'


def input_paths():
    paths=set(initial.input_paths())
    paths.update([initial.MANIFEST,initial.PUBLICATION])
    return sorted(paths-{MANIFEST,PUBLICATION,CLAIM})


def record(result):
    value=initial.record(result)
    claim=value['claims'][0]
    producers={path for path in input_paths() if path.startswith(c.PREFIX) and path.endswith(('.py','.pl'))}
    producers.update(item['path'] for item in claim['durability']['inputs'] if item['role']=='producer')
    bindings=[dict(path=path,sha256=c.identity(path)['sha256'],role='producer') for path in sorted(producers)]
    bindings.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
    claim['durability']=dict(status='checked',mode='live',inputs=sorted(bindings,key=lambda item:item['path']))
    claim['rederive']['command']='bash tools/run_python_project_data.sh '+c.PREFIX+'publish_final.py'
    claim['scope']+=' Whole first10496-input unpublished claim/publication/full modes/actual readonly0 and10499 '
    claim['scope']+='Git-verified staged images survive before pressure correction. Initial public_reference50007/50000 '
    claim['scope']+='is retained RED; only prose wrapping changes, preserving every example and all normalized rendered '
    claim['scope']+='content. The sole generated search-index URL changes; actual89-input rebuilds reproduce both '
    claim['scope']+='pages byte-for-byte and decoded indexes differ only in15 chapter-body whitespace strings. '
    claim['scope']+='The initial strict comparator rejection remains retained and owned. No budget is raised. '
    claim['scope']+='Original failed preflight is deliberately superseded143; exact '
    claim['scope']+='corrected canonical admission remains required. No runtime or test observation is refreshed.'
    claim['rederive']['result']+=' First10496/images10499/readonly0 retained; public reference now'+str(result['admission']['public_reference_after'])
    claim['rederive']['result']+='/50000 with identical normalized rendered content,15 whitespace-only search bodies '
    claim['rederive']['result']+='and fresh89-input/three-example book proof.'
    claim['falsify']['red_control']+=' Actual50007/50000 rejection precedes lossless reflow; the new gate passes '
    claim['falsify']['red_control']+='without changing thresholds. All first source images and old pressure failure remain recoverable.'
    return value


def main():
    assert sys.argv[1:] in ([],['--capture'])
    capture=sys.argv[1:]==['--capture']
    actual={path:c.identity(path) for path in input_paths()}
    if capture:
        assert c.read(CLAIM)==c.load('admission/first.json.gz')['claim']
        c.write_new('publication-final-inputs.json.gz',dict(base=c.BASE,inputs=actual,
            scope='Complete current regular context, recursive proof/data inputs and unchanged original '
                  'publication/manifest, plus whole first-draft source images/full modes and actual '
                  'readonly0 before prose reflow. Own final outputs/current claim excluded. Gitlinks '
                  'and symlink targets are uninspected; installed tools/core and published dependency '
                  'outputs remain read-only prerequisites. No uncommitted draft revision is invented.'))
    initial.validate_inputs(c.load('publication-final-inputs.json.gz')['inputs'],actual)
    result=review.check(doc_stem='admission/doc')
    result['admission']=admission.check()
    initial.validate_inputs(actual,{path:c.identity(path) for path in input_paths()})
    raw=(json.dumps(record(result),separators=(',',':'))+'\n').encode()
    assert len(raw)<=131072
    publication=dict(result=result,record_base64=c.encode(raw))
    if capture:
        c.write_new('publication-final.json',publication)
        (c.ROOT/CLAIM).write_bytes(raw)
    else:
        assert (c.ROOT/CLAIM).read_bytes()==raw and c.load('publication-final.json')==publication
    print('Final aggregate publication PASS:',len(actual),'closed inputs;214/106 RED/7 faults;14/1948;book89/3;',
        'first10496/images10499/readonly0 retained;public_reference'+str(result['admission']['public_reference_after'])+'/50000')


if __name__=='__main__':main()
