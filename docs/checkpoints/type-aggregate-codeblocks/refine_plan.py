"""Retain the exact rejected root-size proposal and shorten only new narrative."""
import common as c


def main():
    path=c.PREFIX+'plan_repairs.py'
    before=c.read(path)
    run=c.run(['bash','tools/run_python_project_data.sh',path])
    assert run['returncode']!=0 and b'AssertionError: 65744' in c.decode(run['stderr_base64'])
    raw=c.decode(before['base64']).decode()
    old='  Reproduce/owner: baseline176 retains42 deferred and6 ordinary fixed-value failures; corrected public dump identifies runtime dispatch. Ordinary receiver excess arity emits a host tick call/warning; repair here. Deferred sorted pipeline fails at sorted; next9 owns it. Initial missing dump flag and quietness assumptions remain retained.'
    new='  Intake: baseline176/dump3 retain42 deferred and6 ordinary arity failures; fix dispatch/shapes here. Next9 owns sorted. Rejected instruments and exact sources survive in the checkpoint.'
    assert raw.count(old)==1
    after=raw.replace(old,new,1).replace(
        '  Reproduce/impact: ordinary items.sorted().take(2).sum() returns4 for [3,1,8]; the deferred twin raises typed unknown_helper:sorted. Public source/error is in type-aggregate-codeblocks/inspection.json.gz; no general pipeline completeness is inferred.',
        '  Reproduce/impact: items.sorted().take(2).sum() yields4 for [3,1,8] outside; deferred raises unknown_helper:sorted. Source/error: type-aggregate-codeblocks/inspection.json.gz.')
    c.write_new('planning-size-preparation.json.gz',dict(before=before,run=run,after_base64=c.encode(after.encode()),
        scope='Size guard rejected before writes; shorten only new7/9 narrative, retain budget65536.'))
    (c.ROOT/path).write_text(after)


if __name__=='__main__':main()
