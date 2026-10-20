"""Actual auditor mutations with exact restoration and distinguishing source controls."""
import gzip
import json
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[2]/'type-numeric-codeblocks'))
import common as c
PREFIX='docs/checkpoints/type-numeric-admission/recurrence/'
AUDIT='tests/language-readiness/verify_objectives.py'


def load(name):
    return json.loads(gzip.decompress((c.ROOT/(PREFIX+name)).read_bytes()))


def put(name,value):
    raw=(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
    with (c.ROOT/(PREFIX+name)).open('xb') as out:out.write(gzip.compress(raw,mtime=0))


def main():
    assert load('historical-final-review.json.gz')['result']=='PASS'
    paths=set(load('historical-final-inputs.json.gz')['inputs'])
    paths.update((PREFIX+'source_faults.py',PREFIX+'probe_signature.py',PREFIX+'historical-final-review.json.gz'))
    inputs={path:c.identity(path) for path in sorted(paths)}
    original=c.read(AUDIT)
    raw=c.decode(original['base64'])
    hook=b'    contents = restore_scalar_numeric_regressions(source, contents)\n'
    assert raw.count(hook)==1
    start=raw.index(b'def restore_scalar_numeric_regressions(source, contents):\n')
    end=raw.index(b'def restore_evaluated_value_regressions(source, contents):\n',start)
    blind=(b'def restore_scalar_numeric_regressions(source, contents):\n'
           b'    if SCALAR_NUMERIC_MARKER not in contents:\n        return contents\n'
           b'    return git("show", f"{SCALAR_NUMERIC_BEFORE}:{source}")\n\n\n')
    tasks=[dict(name='missing-numeric-inverse',before=hook,after=b'',args=[],
                reason=b'evaluated-value regression registration mismatch: t/phase0_regression.t'),
           dict(name='blind-numeric-restore',before=raw[start:end],after=blind,args=['--new-control'],
                reason=b'numeric current-source mutation accepted')]
    put('source-fault-inputs.json.gz',dict(inputs=inputs,source=original,producer=c.read(PREFIX+'source_faults.py'),
        tasks=[dict(**{k:v for k,v in row.items() if k not in ('before','after','reason')},
                    before=c.encode(row['before']),after=c.encode(row['after']),reason=c.encode(row['reason'])) for row in tasks],
        scope='Actual maintained auditor faults. The independent old historical hash and a current fragment '
              'omission distinguish skipped and blind inverses. Every mutation restores exact source/mode in finally.'))
    effects={}
    for row in tasks:
        assert raw.count(row['before'])==1
        altered=raw.replace(row['before'],row['after'],1)
        command=['python3','-B',PREFIX+'probe_signature.py']+row['args']
        try:
            (c.ROOT/AUDIT).write_bytes(altered)
            run=c.run(command)
            put('source-fault-'+row['name']+'-observed.json.gz',dict(run=run,mutant=c.identity(AUDIT)))
        finally:
            (c.ROOT/AUDIT).write_bytes(raw)
            (c.ROOT/AUDIT).chmod(original['mode'])
        restored=c.run(command)
        put('source-fault-'+row['name']+'.json.gz',dict(run=run,restored=restored,
            source_restored=c.read(AUDIT)==original,inputs_restored=c.unchanged(inputs)))
        assert run['returncode']!=0 and row['reason'] in c.decode(run['stderr_base64'])
        assert restored['returncode']==0 and not c.decode(restored['stderr_base64'])
        assert c.read(AUDIT)==original and c.unchanged(inputs)
        effects[row['name']]=True
        print('Actual auditor fault/restoration:',row['name'],flush=True)
    put('source-fault-review.json.gz',dict(result='PASS',faults=effects,source_restored=True,inputs_restored=True))
    print('Both actual historical-auditor faults reject and restore exact bytes/mode')


if __name__=='__main__':
    main()
