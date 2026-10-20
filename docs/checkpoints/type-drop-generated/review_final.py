"""Compose original runtime proof with the separately retained fact/cache admission."""
import json
import sys
from pathlib import Path
import common as c
import review
sys.path.insert(1,str(Path(__file__).resolve().parent/'admission'))
import verify as admission


def check(fresh=True):
    original=review.check(fresh=fresh)
    final=admission.first_image()
    assert final['first_staged_images']==10308
    result=dict(original,admission=final)
    result['limits']=original['limits']+' Final review preserves whole first10304-input unpublished drop '
    result['limits']+='claim/publication/actual readonly0 and10308 exact staged images before correcting '
    result['limits']+='the historical fact route and recording drop2. Its canonical143 was deliberately '
    result['limits']+='superseded before bound changes. Current history reverify uses the composed producer, '
    result['limits']+='decoupled from frozen whole-project publishers. One staged generated common.pyc is '
    result['limits']+='preserved byte/mode exactly, unstaged/removed with zero residue; checkpoint ignore '
    result['limits']+='and source negative control pass. No code/runtime/test observation is refreshed. '
    result['limits']+='Final artifact/fact source controls and current Knowledge proof are separate.'
    fact=c.load('admission/fact-run.json.gz')
    assert fact['result']=='PASS' and fact['source_restored'] and len(fact['artifact_controls'])==3
    assert fact['actual_old_route_red'] and fact['fact_pointer_fault']['returncode']!=0
    assert b'current historical reverify must use composed producer' in c.decode(fact['fact_pointer_fault']['stderr_base64'])
    review.passed(fact['restored'])
    review.passed(fact['composed_history'])
    actual=json.loads(c.decode(fact['composed_history']['stdout_base64']))
    assert actual['audit_controls']['governance_mutations_rejected']==650
    assert actual['restored_inputs']==134 and actual['restored_bytes']==84613241 and len(actual['controls'])==22
    assert actual['healthy_audit_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
    review.passed(fact['knowledge'],False)
    assert c.decode(fact['knowledge']['stderr_base64'])==b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
    inputs=c.load('admission/fact-inputs.json.gz')
    for path in (admission.FACT,admission.TYPE,'KNOWLEDGE_MAP.md'):
        assert c.identity(path)==inputs['inputs'][path]
    assert (c.ROOT/(c.PREFIX+'admission/verify.py')).read_bytes()==c.decode(c.load('admission/image-review-refinement.json.gz')['after_base64'])
    return result


if __name__=='__main__':print(json.dumps(check(fresh=False),sort_keys=True))
