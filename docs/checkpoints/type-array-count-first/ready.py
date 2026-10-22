"""Repair the unexecuted review syntax and verify its production refusal granularity."""
import ast
import sys
import common as c
import context
import direct as focused


def main():
    focused.validate(c.load('focused-final.json.gz'))
    path = c.PREFIX+'review.py'
    before = c.read(path)
    c.write_new('readiness-inputs.json.gz',context.snapshot())
    command = [sys.executable,'-c',
        "import ast,pathlib; ast.parse(pathlib.Path('docs/checkpoints/type-array-count-first/review.py').read_text())"]
    refused = c.run(command)
    c.write_new('review-syntax-refusal.json.gz',dict(producer=before,run=refused))
    assert refused['returncode'] != 0 and b'SyntaxError: invalid syntax' in c.decode(refused['stderr_base64'])
    text = c.decode(before['base64']).decode()
    old = "dict(files:item['files'],lines:item['lines'],segment:item['entry']['segment_id'])"
    new = "dict(files=item['files'],lines=item['lines'],segment=item['entry']['segment_id'])"
    assert text.count(old) == 1
    text = text.replace(old,new,1)
    old = "    assert c.load('history-old-cap.json.gz')['run']['returncode'] != 0"
    new = '''    refusal = c.load('history-old-cap.json.gz')['run']
    assert refusal['returncode'] != 0
    expected_errors = set()
    for surface in value['rollovers']:
        old,new = value['old'][surface],value['new'][surface]
        family = 'changes' if surface == 'change_history' else 'development-notes'
        manifest = 'docs/history/'+family+'/manifest.jsonl'
        expected_errors.add(f"[readme-routing] FAIL: surface {surface} exceeds control: files {new['limits']['max_files']}/{old['limits']['max_files']}")
        for name,unit in [('max_lines','lines'),('max_bytes','bytes')]:
            expected_errors.add(f"[readme-routing] FAIL: surface {surface} member exceeds control: {unit} {new['member_limits'][manifest][name]}/{old['member_limits'][manifest][name]}")
    actual_errors = {line for line in c.decode(refusal['stderr_base64']).decode().splitlines()
        if line.startswith('[readme-routing] FAIL: ')}
    assert actual_errors == expected_errors
'''.rstrip()
    assert text.count(old) == 1
    text = text.replace(old,new,1)
    text = text.replace('import focused','import direct as focused',1)
    text = text.replace("focused.validate(c.load('focused-run.json.gz'))", "focused.validate(c.load('focused-final.json.gz'))",1)
    text = text.replace("'doc-run.json.gz'","'doc2-run.json.gz'")
    text = text.replace("'doc-inputs.json.gz'","'doc2-inputs.json.gz'")
    ast.parse(text,filename=path)
    c.source(path).write_text(text)
    c.source(path).chmod(before['mode'])
    healthy = c.run(command)
    c.write_new('readiness.json.gz',dict(before=before,after=c.read(path),healthy=healthy,
        scope='The readonly reviewer had not executed. Its keyword typo is corrected after direct proof joins; the actual syntax RED/GREEN and original source survive. The actual old-cap production refusals are now independently checked at all six measured member/manifest fields.'))
    assert healthy['returncode'] == 0 and not c.decode(healthy['stderr_base64'])
    print('Review syntax RED/GREEN retained; six exact production refusals gated')


if __name__ == '__main__':
    main()
