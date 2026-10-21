"""Bind the distinct post-repair count/first observation without changing runtime behavior."""
import common as c

def main():
    paths=[c.PREFIX+'review.py',c.PREFIX+'custody.py',c.PREFIX+'README.md',c.PREFIX+'findings.md','docs/tasks/TYPE-REFERENCE-BOOK.md']
    before={p:c.read(p) for p in paths};after={p:c.decode(packet['base64']).decode() for p,packet in before.items()}
    path=c.PREFIX+'review.py';text=after[path]
    marker="    sources=custody.verify()\n";assert text.count(marker)==1
    text=text.replace(marker,"    followup=c.load('followup-confirmation.json.gz')\n    assert followup['inputs_unchanged'] and followup['source']==c.read(c.SOURCE)\n    assert not oracle.failures(followup['run'],followup['plan'])\n"+marker,1)
    after[path]=text
    path=c.PREFIX+'custody.py';text=after[path]
    marker="'doc-inputs.json.gz','doc2-inputs.json.gz')"
    assert text.count(marker)==1
    after[path]=text.replace(marker,"'doc-inputs.json.gz','doc2-inputs.json.gz','followup-inputs.json.gz')",1)
    after[c.PREFIX+'README.md']+='\nfollowup-confirmation.json.gz separately executes count/first after sorted/take is repaired: two ordinary values and two exact deferred unknown-helper causes pass. The earlier baseline stopped at sorted and is not misrepresented as a later dispatch observation. followup-inputs.json.gz retains the complete actual context.\n'
    after[c.PREFIX+'findings.md']+='\nCount/first confirmation at the final9 source is in followup-confirmation.json.gz: ordinary2/1; deferred unknown_helper:count/first. The older baseline stopped earlier at sorted.\n'
    path='docs/tasks/TYPE-REFERENCE-BOOK.md';text=after[path]
    text=text.replace('**FIX** — Only sorted/take availability and supported compatible chains.','**FIX** — Sorted/take availability and canonical fluent-argument validation.',1)
    old='Reproduce/impact: sorted().take(2).count()/first() work outside but deferred raises unknown_helper. baseline-run.json.gz retains the actual cases.'
    new='Reproduce/impact: Final9 separately confirms ordinary count2/first1 and deferred unknown_helper:count/first after sorted/take succeeds. followup-confirmation.json.gz and its full context retain all four actual routes; the original baseline stopped at sorted.'
    assert text.count(old)==1;text=text.replace(old,new,1);after[path]=text
    c.write_new('followup-binding.json.gz',dict(before=before,after={p:c.encode(t.encode()) for p,t in after.items()},producer=c.read(c.PREFIX+'bind_followups.py')))
    for p,t in after.items():(c.ROOT/p).write_text(t)
    print('Confirmed count/first epoch bound; runtime/tests/book unchanged')

if __name__=='__main__':main()
