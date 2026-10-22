"""Remove edits proven redundant by actual ablation and retain precise fact wording."""
import common as c

def main():
    ablation=c.load('ablation-result.json')
    assert not ablation['names']['failures']
    assert set(ablation['names-and-shapes']['failures'])=={'deferred/function/invalid-sort','deferred/function/invalid-take'}
    path=c.SOURCES[0]
    before=c.read(path)
    text=c.decode(before['base64']).decode()
    pieces=c.load('ablation-before.json.gz')['tasks'][0][1]
    for piece in pieces:
        assert text.count(piece)==1
        text=text.replace(piece,'',1)
    fact_path='docs/knowledge/terse-type-method-surface-inventory.md'
    fact_before=c.read(fact_path)
    fact=c.decode(fact_before['base64']).decode()
    old='Registered chains keep DSL names through the existing bridge. length takes no\nargs and terminates; bad shapes/continuations skip effects.12 writes/14 last.'
    new='Array chains reuse the bridge; emitted values avoid DSL reparsing.\nlength takes no args and terminates; bad shapes/continuations skip effects.\n12 writes/14 last.'
    assert fact.count(old)==1
    fact=fact.replace(old,new,1).replace('take defaults1; integers only;', 'take defaults1; integer spelling only;',1)
    fact=fact.replace('Storable caches float iOK.','Storable caches private float iOK.',1)
    fact=fact.replace('Context gates gzip/37','Context hash-gates gzip/37',1)
    accepted=c.run(['git','show',c.BASE+':'+fact_path])
    assert accepted['returncode']==0
    assert len(fact.encode())<=len(c.decode(accepted['stdout_base64']))
    c.write_new('minimal-before.json.gz',dict(source=before,pieces=pieces,context=c.epoch(),fact_before=fact_before,
        fact_after=fact,producer=c.read(c.PREFIX+'minimal.py'),
        explanation='Actual ablation admits omission of the preliminary name/constructor edits, so remove them. The required bridge change consumes already emitted values directly. Sort/take arity omissions still fail the deferred registered-body controls. Restore integer-spelling, private flag and hash-gating precision while containing total fact bytes.'))
    c.source(path).write_text(text)
    c.source(fact_path).write_text(fact)
    c.write_new('minimal.json.gz',dict(before=before,after=c.read(path),fact_before=fact_before,fact_after=c.read(fact_path)))
    print('Minimal source retained; redundant name edits removed; precise fact remains within original bytes')

if __name__=='__main__':main()
