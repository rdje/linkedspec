"""Readonly final aggregate publication after both retained containment admissions."""
import json
import sys
import common as c
import publish as initial
import publish_final as second
import review
from admission.collection import verify

MANIFEST=c.PREFIX+'publication-admitted-inputs.json.gz'
PUBLICATION=c.PREFIX+'publication-admitted.json'
CLAIM='docs/claims/'+c.OWNER+'.json'


def input_paths():
    paths=set(second.input_paths())
    paths.update([second.MANIFEST,second.PUBLICATION])
    return sorted(paths-{MANIFEST,PUBLICATION,CLAIM})


def record(result):
    value=second.record(result)
    claim=value['claims'][0]
    producers={path for path in input_paths() if path.startswith(c.PREFIX) and path.endswith(('.py','.pl'))}
    producers.update(item['path'] for item in claim['durability']['inputs'] if item['role']=='producer')
    bindings=[dict(path=path,sha256=c.identity(path)['sha256'],role='producer') for path in sorted(producers)]
    bindings.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
    claim['durability']=dict(status='checked',mode='live',inputs=sorted(bindings,key=lambda item:item['path']))
    claim['rederive']['command']='bash tools/run_python_project_data.sh '+c.PREFIX+'publish_admitted.py'
    claim['scope']+=' Complete second10522-input unpublished claim/publication/full modes/actual readonly0 '
    claim['scope']+='and10525 Git-verified staged images precede the fact consolidation. Canonical1 exposed '
    claim['scope']+='knowledge_cards1351/1350 and was deliberately joined143. Merge the complete new finding '
    claim['scope']+='and both questions into its existing fact owner; no budget change or runtime observation '
    claim['scope']+='refresh. Corrected exact canonical admission remains a separate required landing gate.'
    claim['scope']+=' The provisional4959 rollover and its failed49/48 archive-capacity epoch survive '
    claim['scope']+='whole; final notes compact only this new record and restore the old manifest. Actual '
    claim['scope']+='old snapshots contain114 whole gzip overrides; the corrected loaded context producer '
    claim['scope']+='retains their full byte/mode identities with zero gzip overrides. Every existing gzip '
    claim['scope']+='artifact remains unchanged and hash-gated; any later gzip change requires a before packet.'
    claim['rederive']['result']+=' Collection pressure passes1350/1350 files, '+str(result['collection']['knowledge_bytes'])
    claim['rederive']['result']+='/8388608 bytes; original and second source epochs remain recoverable.'
    claim['rederive']['result']+=' Snapshot repair:114 observed old gzip copies/0 current gzip overrides; '
    claim['rederive']['result']+=str(result['collection']['admitted_snapshot_bytes'])+' actual compressed snapshot bytes.'
    claim['falsify']['red_control']+=' Actual1351/1350 failure precedes whole-finding consolidation and '
    claim['falsify']['red_control']+='a passing report at unchanged thresholds; failed canonical143 is never reported as success.'
    claim['falsify']['red_control']+=' Old actual gzip overrides fail the independent no-recursive-copy '
    claim['falsify']['red_control']+='contract; the fresh loaded producer passes while retaining every old gzip byte/mode identity.'
    return value


def main():
    assert sys.argv[1:] in ([],['--capture'],['--check'])
    if sys.argv[1:]==['--check']:
        result=review.check(False,doc_stem='admission/doc')
        result['admission']=second.admission.check()
        result['collection']=verify.check()
        print(json.dumps(result,sort_keys=True))
        return
    capture=sys.argv[1:]==['--capture']
    actual={path:c.identity(path) for path in input_paths()}
    if capture:
        assert c.read(CLAIM)==c.load('admission/collection/second.json.gz')['claim']
        c.write_new('publication-admitted-inputs.json.gz',dict(base=c.BASE,inputs=actual,
            scope='Complete current regular context/recursive proof inputs, both immutable earlier '
                  'publication stages and whole draft source images/full modes/actual readonly0. '
                  'Own final outputs/current claim excluded; no unpublished Git revision invented. '
                  'Gitlinks/symlink targets remain uninspected; installed tools/core and published '
                  'dependency outputs are explicit read-only prerequisites.'))
    initial.validate_inputs(c.load('publication-admitted-inputs.json.gz')['inputs'],actual)
    result=review.check(doc_stem='admission/doc')
    result['admission']=second.admission.check()
    result['collection']=verify.check()
    initial.validate_inputs(actual,{path:c.identity(path) for path in input_paths()})
    raw=(json.dumps(record(result),separators=(',',':'))+'\n').encode()
    assert len(raw)<=131072
    publication=dict(result=result,record_base64=c.encode(raw))
    if capture:
        c.write_new('publication-admitted.json',publication)
        (c.ROOT/CLAIM).write_bytes(raw)
    else:
        assert (c.ROOT/CLAIM).read_bytes()==raw and c.load('publication-admitted.json')==publication
    print('Admitted aggregate publication PASS:',len(actual),'closed inputs;214/106 RED/7 faults;14/1948;book89/3;',
        'prior10496/10522 retained;public_reference49836/50000;knowledge1350/1350')


if __name__=='__main__':main()
