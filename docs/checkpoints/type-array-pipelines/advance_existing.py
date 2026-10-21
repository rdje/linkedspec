"""Advance only the earlier intentional sorted-unknown expectation now repaired."""
import json
import common as c

def main():
    path='tests/numeric-codeblocks/cases.json';before=c.read(path)
    fixture=json.loads(c.decode(before['base64']))
    selected=[case for case in fixture['cases'] if case['id']=='aggregate7/deferred/chain']
    assert len(selected)==1 and selected[0]['error']==dict(code='unknown_helper',name='sorted')
    del selected[0]['error'];selected[0]['expected']=4
    raw=(json.dumps(fixture,sort_keys=True,separators=(',',':'))+'\n').encode()
    (c.ROOT/path).write_bytes(raw)
    c.write_new('existing-expectation-change.json.gz',dict(producer=c.read(c.PREFIX+'advance_existing.py'),path=path,before=before,after=c.read(path),advanced=['aggregate7/deferred/chain'],
        reason='Actual focused1 all14 runs:13 pass; scalar suite rejects only its old expected unknown_helper. Fixed public case/book independently establish4. Preserve the failed1948-TAP epoch whole; final14 suite rerun includes this one expectation and the separate argument guard.'))
    print('Advanced exactly one previously intentional pipeline failure to value4')

if __name__=='__main__':main()
