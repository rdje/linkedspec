"""Retain the misloaded shadow, then use actual accepted bytes with guaranteed restoration."""
import json
import subprocess
import common as c
import context


def main():
    original=c.read(c.SOURCE)
    old=subprocess.check_output(['git','show',c.BASE+':'+c.SOURCE],cwd=c.ROOT)
    extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    snapshot=context.snapshot(extras)
    snapshot.update(current=original,accepted_base64=c.encode(old),
        new_inputs={path:c.read(path) for path in extras if not path.endswith('.gz')},
        scope='Earlier shadow loaded current Runtime, as its raw loaded path proves; that comparison '
              'is rejected preparation. This installs the real accepted owner only and restores it exactly.')
    c.write_new('malformed-accepted-inputs.json.gz',snapshot)
    try:
        (c.ROOT/c.SOURCE).write_bytes(old)
        run=c.run(['perl','-Iperl',c.PREFIX+'malformed.pl'])
        c.write_new('malformed-accepted-observed.json.gz',dict(source=c.read(c.SOURCE),run=run))
    finally:
        (c.ROOT/c.SOURCE).write_bytes(c.decode(original['base64']));(c.ROOT/c.SOURCE).chmod(original['mode'])
        c.write_new('malformed-accepted-restoration.json.gz',dict(restored=c.read(c.SOURCE)==original))
    assert c.unchanged(snapshot['inputs']) and run['returncode']==0 and not c.decode(run['stderr_base64'])
    value=json.loads(c.decode(run['stdout_base64']))
    assert value['class']=='LinkedSpec::CodeblockRuntime::Error'
    assert value['fields']['code']=='invalid_codeblock_body' and value['fields']['detail']=='invalid fluent call'
    print('Actual accepted Runtime rejects malformed call with typed invalid_codeblock_body; candidate restored')


if __name__=='__main__':main()
