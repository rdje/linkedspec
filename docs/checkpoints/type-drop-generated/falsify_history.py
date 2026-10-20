"""Actual auditor faults and a semantically identical table-byte identity denial."""
import gzip
import json
import common as c
import context

AUDIT='tests/language-readiness/verify_objectives.py'
TABLE='tests/language-readiness/drop-generated-regression-evolution.json.gz'
COMMAND=['bash','tools/run_python_project_data.sh',c.PREFIX+'history_oracle.py']


def main():
    source,table=c.read(AUDIT),c.read(TABLE)
    raw=c.decode(source['base64'])
    tasks=[dict(name='omitted-drop-inverse',
        before=b'    contents = restore_drop_generated_regressions(source, contents)\n',after=b'',
        arguments=[],reason=b'evaluated-value regression registration mismatch:'),
        dict(name='blind-drop-base',
        before=b'def restore_drop_generated_regressions(source, contents):\n',
        after=b'def restore_drop_generated_regressions(source, contents):\n    return git("show", f"{DROP_GENERATED_BEFORE}:{source}")\n',
        arguments=['--control'],reason=b'UNREVIEWED_DROP_MUTATION_ACCEPTED')]
    extras=[c.PREFIX+path.name for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    extras+=['tests/drop-generated/cases.json','t/drop_keys_generated.t',TABLE]
    snapshot=context.snapshot(extras)
    c.write_new('historical-fault-inputs.json.gz',dict(inputs=snapshot,source=source,table=table,
        tasks=[dict(task,before=c.encode(task['before']),after=c.encode(task['after']),reason=c.encode(task['reason'])) for task in tasks],
        producer=c.read(c.PREFIX+'falsify_history.py')))
    healthy=c.run(COMMAND)
    assert healthy['returncode']==0 and not c.decode(healthy['stderr_base64'])
    for task in tasks:
        assert raw.count(task['before'])==1
        target=c.ROOT/AUDIT
        try:
            target.write_bytes(raw.replace(task['before'],task['after'],1))
            mutant=c.read(AUDIT)
            run=c.run(COMMAND+task['arguments'])
            c.write_new('historical-fault-'+task['name']+'-observed.json.gz',dict(run=run,mutant=mutant))
        finally:
            target.write_bytes(raw)
            target.chmod(source['mode'])
        assert run['returncode']!=0 and task['reason'] in c.decode(run['stderr_base64'])
        restored=c.run(COMMAND+task['arguments'])
        assert restored['returncode']==0 and not c.decode(restored['stderr_base64'])
        assert c.read(AUDIT)==source and c.unchanged(snapshot['inputs'])
        c.write_new('historical-fault-'+task['name']+'.json.gz',dict(run=run,restored=restored,
            source_restored=True,inputs_restored=True))
        print('Actual historical auditor RED restored:',task['name'],flush=True)
    value=json.loads(gzip.decompress(c.decode(table['base64'])))
    changed=gzip.compress(json.dumps(value,indent=1,ensure_ascii=False).encode(),mtime=0)
    assert changed!=c.decode(table['base64']) and json.loads(gzip.decompress(changed))==value
    target=c.ROOT/TABLE
    try:
        target.write_bytes(changed)
        run=c.run(COMMAND)
        c.write_new('historical-table-observed.json.gz',dict(run=run,changed_base64=c.encode(changed)))
    finally:
        target.write_bytes(c.decode(table['base64']))
        target.chmod(table['mode'])
    assert run['returncode']!=0 and b'drop inverse table identity mismatch:' in c.decode(run['stderr_base64'])
    restored=c.run(COMMAND)
    assert restored['returncode']==0 and not c.decode(restored['stderr_base64'])
    assert c.read(TABLE)==table and c.unchanged(snapshot['inputs'])
    c.write_new('historical-fault-review.json.gz',dict(result='PASS',healthy=healthy,table_restored=restored,
        source_faults=[task['name'] for task in tasks],semantic_table_unchanged=True,inputs_restored=True))


if __name__=='__main__':main()
