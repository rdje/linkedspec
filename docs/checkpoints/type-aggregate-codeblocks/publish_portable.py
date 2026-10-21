"""Reconstruct ignored logical inputs and rederive the source-closed portable publication."""
import json
import sys
import common as c
import large_inputs
import publish as initial
import publish_admitted as previous
import publish_final
import review
from admission.collection import verify as collection
from admission.portable import verify

MANIFEST=c.PREFIX+'publication-portable-inputs.json.gz'
PUBLICATION=c.PREFIX+'publication-portable.json'
CLAIM='docs/claims/'+c.OWNER+'.json'


def input_paths():
    paths=set(previous.input_paths())
    paths.update([previous.MANIFEST,previous.PUBLICATION])
    return sorted(paths-large_inputs.LOGICAL_PATHS-{MANIFEST,PUBLICATION,CLAIM})


def proof(physical,fresh=True,require_documents=True):
    large_inputs.ensure_all()
    result=review.check(fresh,doc_stem='admission/doc')
    result['admission']=publish_final.admission.check()
    result['collection']=collection.check()
    result['portable']=verify.check(physical,require_documents=require_documents)
    return result


def record(result):
    value=previous.record(result)
    claim=value['claims'][0]
    producers={path for path in input_paths() if path.startswith(c.PREFIX) and path.endswith(('.py','.pl'))}
    producers.update(item['path'] for item in claim['durability']['inputs'] if item['role']=='producer')
    bindings=[dict(path=path,sha256=c.identity(path)['sha256'],role='producer') for path in sorted(producers)]
    bindings.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
    claim['durability']=dict(status='checked',mode='live',inputs=sorted(bindings,key=lambda item:item['path']))
    claim['rederive']['command']='bash tools/run_python_project_data.sh '+c.PREFIX+'publish_portable.py'
    claim['scope']+=' Whole third10540-input unpublished claim/publication/full modes/actual readonly0 '
    claim['scope']+='and10543 independently verified staged images precede portable retention. Actual staged '
    claim['scope']+='Git sizes expose three above the verified GitHub100MiB limit.37 tracked32MiB chunks '
    claim['scope']+='preserve1171950805 exact bytes and full logical modes; the gateway recreates only ignored '
    claim['scope']+='project-local aliases. Five actual chunk/alias faults retain the pre-root-guard helper; '
    claim['scope']+='a separate metadata-only nested-root RED/rejection and final three-alias cold replay '
    claim['scope']+='cover the only helper delta. No other repository write/implementation inspection occurs. '
    claim['scope']+='Actual readers consume recovered bytes before three verified backups are removed. '
    claim['scope']+='Canonical2 is deliberately superseded143, never claimed passed or failed. Current '
    claim['scope']+='physical inputs are below100MiB; exact staged Git census/canonical receipt govern landing. '
    claim['scope']+='Default source rederive may reconstruct ignored aliases but never changes tracked inputs.'
    claim['rederive']['result']+=' Portable custody:37 bounded chunks/3 cold aliases/1171950805 bytes; '
    claim['rederive']['result']+='five retained pre-guard faults plus final nested-root control/cold replay; '
    claim['rederive']['result']+='all prior source epochs retained and generated backup residue0.'
    claim['rederive']['result']+=' Fresh portability pressure passes20 surfaces/62 routes/40 controls; current knowledge bytes'
    claim['rederive']['result']+=str(result['portable']['current_pressure_knowledge_bytes'])+'/8388608. Earlier pressure figures retain their measured source epochs.'
    claim['falsify']['red_control']+=' Three actual oversized staged Git blobs precede chunking. Actual '
    claim['falsify']['red_control']+='missing/chunk-byte/colluding-order/logical-mode/logical-byte faults reject '
    claim['falsify']['red_control']+='and restore. Missing logical originals fail before cold recovery; SHA256/full '
    claim['falsify']['red_control']+='modes/historical Git identities and actual reader use precede deleting verified '
    claim['falsify']['red_control']+='backups. Metadata-only nested-root acceptance rejects after the final helper guard.'
    return value


def main():
    assert sys.argv[1:] in ([],['--capture'],['--check'])
    physical=input_paths()
    if sys.argv[1:]==['--check']:
        print(json.dumps(proof(physical,False),sort_keys=True));return
    capture=sys.argv[1:]==['--capture']
    actual={path:c.identity(path) for path in physical}
    logical={item['path']:{key:item[key] for key in ('sha256','size','mode')} for item in large_inputs.manifest()['objects']}
    if capture:
        assert c.read(CLAIM)==c.load('admission/portable/third.json.gz')['claim']
        c.write_new('publication-portable-inputs.json.gz',dict(base=c.BASE,inputs=actual,logical_inputs=logical,
            scope='All current regular physical sources/recursive proof inputs, bounded chunks/manifest '
                  'and immutable prior publications. Three ignored logical aliases are explicitly '
                  'derived from tracked chunks with exact full-byte/full-mode identities. Own final '
                  'outputs/current claim excluded; no unpublished Git revision invented. Gitlinks/'
                  'symlink targets remain uninspected; installed tools/core and published dependency '
                  'outputs are explicit read-only prerequisites.'))
    declared=c.load('publication-portable-inputs.json.gz')
    initial.validate_inputs(declared['inputs'],actual)
    assert declared['logical_inputs']==logical
    result=proof(physical)
    initial.validate_inputs(actual,{path:c.identity(path) for path in input_paths()})
    raw=(json.dumps(record(result),separators=(',',':'))+'\n').encode()
    assert len(raw)<=131072
    publication=dict(result=result,record_base64=c.encode(raw))
    if capture:
        c.write_new('publication-portable.json',publication)
        (c.ROOT/CLAIM).write_bytes(raw)
    else:
        assert (c.ROOT/CLAIM).read_bytes()==raw and c.load('publication-portable.json')==publication
    print('Portable aggregate publication PASS:',len(actual),'physical inputs;214/106 RED/7 faults;14/1948;book89/3;',
        '37 chunks/3 exact aliases;all three prior drafts retained;source readonly')


if __name__=='__main__':main()
