"""Finish publication-controller repair under the same owning leaf."""
import common as c
import publish5

def main():
    proof=publish5.review_result()
    paths=['MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','ROADMAP_V2.md','docs/TASK_TREE.md',
        'docs/tasks/TYPE-REFERENCE-BOOK.md','CHANGES.md','DEVELOPMENT_NOTES.md',c.PREFIX+'README.md',
        'docs/knowledge/selected-consumer-proof-input-closure-gap.md']
    before={p:c.read(p) for p in paths}
    after={p:c.decode(packet['base64']).decode().replace('publish4.py','publish5.py').replace('review4.py','review5.py') for p,packet in before.items()}
    tree='docs/tasks/TYPE-REFERENCE-BOOK.md'
    marker='  Final admission: '
    owner=after[tree].index('- ID: `'+c.OWNER+'`\n')
    point=after[tree].index(marker,owner)
    end=after[tree].index('\n',point)
    addition='\n  Controller repair verified: Capture4 writes its manifest then fails on imported review4/unbound review3; no publication/claim write and no normal-entrypoint success is claimed. Whole failed11350 identities, original source/log/status and every planned changed image precede repair; remaining inputs stay exact at their supplied paths. Distinct publisher5 shares review_result between readonly --review and capture and executes it before manifest creation. Current scope5/artifacts5 controls pass, with unchanged runtime and test expectations. The premature staging is superseded by restaging only after successful normal capture and readonly verification.\n'
    after[tree]=after[tree][:end]+addition+after[tree][end:]
    after['MEMORY.md']=after['MEMORY.md'].replace('Whole unpublished714/actual readonly0 and all intermediate source epochs remain retained;', 'Whole unpublished714/readonly0 plus failed capture4/11350 and all planned changed images remain retained;',1)
    after['LIVE_ACHIEVEMENT_STATUS.md']=after['LIVE_ACHIEVEMENT_STATUS.md'].replace('Exact canonical receipt and normal hooks govern admission.', 'The failed capture4 controller and11350 inputs remain preserved; shared normal-entrypoint preflight governs publication. Exact canonical receipt and normal hooks govern admission.',1)
    for path in ('CHANGES.md','DEVELOPMENT_NOTES.md'):
        marker='Other backends, indexed writes12, last14, reducers95, complete references and the wider historical audit stay separate.'
        assert after[path].count(marker)==1,path
        after[path]=after[path].replace(marker,'Capture4 fails before publication/claim write on an imported-module call typo; complete11350-input failed state is retained. Publisher5 checks the same review helper in its readonly and capture entrypoints before any manifest write. Premature staging is superseded after normal capture/readonly proof. '+marker,1)
    after[c.PREFIX+'README.md']+='\nCapture4 writes its manifest then calls unbound review3 after importing review4.\nNo publication/claim write or normal-entrypoint success is claimed. Whole11350\nidentities, the failed source/log/status and every planned changed image remain\nretained in failed-capture4.json.gz. Publisher5 uses one shared review_result for\nreadonly --review and capture, before manifest creation. Scope5/artifacts5 prove\nthe current producer; runtime and test oracles are unchanged.\n'
    c.write_new('continuity5-before.json.gz',dict(before=before,after=after,proof=proof,
        producer=c.read(c.PREFIX+'finalize5.py')))
    for path,text in after.items():c.source(path).write_text(text)
    print('Normal-entrypoint repair and retained failed11350 epoch documented; runtime/oracles unchanged')

if __name__=='__main__':main()
