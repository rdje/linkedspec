"""Advance three formerly missing reducers and add permanent bounded public recurrence."""
import json
import subprocess
import common as c


def main():
    path='tests/numeric-codeblocks/cases.json'
    before=c.read(path)
    assert c.decode(before['base64'])==subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
    fixture=json.loads(c.decode(before['base64']))
    converted=[]
    for row in fixture['cases']:
        if row['id'].startswith('separate-aggregate/'):
            assert row.pop('error')['code']=='unknown_helper'
            row['expected']=3 if row['id'].endswith('/num_sum') else 1
            converted.append(row['id'])
    assert len(converted)==3
    new=[]
    for source in c.load('cases2.json')['cases']:
        # The established scalar test harness fixes /x/ and runtime diagnostics;
        # full entry-capture and prohibited-definition routes remain in public214.
        if 'source' in source or 'source_error' in source:continue
        row=dict(source);row['id']='aggregate7/'+row['id'];new.append(row)
    assert len(new)==201
    fixture['cases']+=new
    assert len(fixture['cases'])==len({row['id'] for row in fixture['cases']})
    raw=(json.dumps(fixture,sort_keys=True,separators=(',',':'))+'\n').encode()
    c.write_new('test-migration.json.gz',dict(path=path,before=before,after_base64=c.encode(raw),
        converted=converted,added=[row['id'] for row in new],producer=c.read(c.PREFIX+'migrate_tests.py'),
        scope='Old producer/fixture at real accepted efad62 remain recoverable. Three deliberately '
              'unavailable aggregate expectations become values;201 new cases run in the existing '
              'canonical scalar consumer without changing its implementation or historical Phase0 source.'))
    (c.ROOT/path).write_bytes(raw)
    print('Permanent numeric consumer:3 missing expectations advanced;201 fixed cases added')


if __name__=='__main__':main()
