"""Falsify the final malformed-member guard and restore its exact typed public error."""
import json
import common as c
import context


def typed(run):
    assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    value=json.loads(c.decode(run['stdout_base64']))
    return value['class']=='LinkedSpec::CodeblockRuntime::Error' and value.get('fields',{}).get('code')=='invalid_codeblock_body' and value.get('fields',{}).get('detail')=='invalid fluent call' and value['items']==[3,1,8]


def main():
    change=c.load('guard-change.json.gz')
    original=c.read(c.SOURCE)
    assert original['base64']==change['after'][c.SOURCE]
    raw=c.decode(original['base64'])
    line=b"  next unless ref($calls->[$index]) eq 'HASH';\n"
    assert raw.count(line)==1
    mutant=raw.replace(line,b'',1)
    assert c.sha(mutant)==change['before'][c.SOURCE]['sha256']
    extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    snapshot=context.snapshot(extras)
    snapshot.update(source=original,mutant_base64=c.encode(mutant),
        new_inputs={path:c.read(path) for path in extras if not path.endswith('.gz')})
    c.write_new('guard-proof-inputs.json.gz',snapshot)
    healthy=c.run(['perl','-Iperl',c.PREFIX+'malformed.pl'])
    try:
        (c.ROOT/c.SOURCE).write_bytes(mutant)
        red=c.run(['perl','-Iperl',c.PREFIX+'malformed.pl'])
        c.write_new('guard-fault-observed.json.gz',dict(mutant=c.read(c.SOURCE),run=red))
    finally:
        (c.ROOT/c.SOURCE).write_bytes(raw);(c.ROOT/c.SOURCE).chmod(original['mode'])
    restored=c.run(['perl','-Iperl',c.PREFIX+'malformed.pl'])
    stable=c.unchanged(snapshot['inputs'])
    c.write_new('guard-proof-run.json.gz',dict(healthy=healthy,red=red,restored=restored,inputs_unchanged=stable,
        source_restored=c.read(c.SOURCE)==original))
    assert stable and typed(healthy) and typed(restored) and not typed(red)
    actual=json.loads(c.decode(red['stdout_base64']))
    assert actual['class']=='' and 'as a HASH ref' in actual['text']
    print('Final guard: typed GREEN; exact pre-guard source RED; fresh typed restoration; source/inputs unchanged')


if __name__=='__main__':main()
