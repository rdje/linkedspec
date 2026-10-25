"""Four function-source controls using exact retained post-repair CLI bytes."""
import gzip
import json
import common as c
from execute_emitted import matches

binary=c.load('current-cli-binary.json')['artifact']
raw=gzip.decompress(b''.join(c.source(part['path']).read_bytes() for part in binary['parts']))
assert c.sha(raw)==binary['sha256'] and len(raw)==binary['bytes']
path='.linkedspec-data/verification/numeric55-function-cli'
with (c.ROOT/path).open('xb') as file:file.write(raw)
(c.ROOT/path).chmod(binary['mode'])
fixture=json.loads(c.source('tests/numeric-conversion/functions.json').read_text())
c.save('function-cli-inputs.json.gz',dict(fixture=c.read('tests/numeric-conversion/functions.json'),
    producer=c.read(c.PREFIX+'function_cli.py'),observer=c.read(c.PREFIX+'execute_emitted.py'),
    binary=binary,original_epoch=c.load('current-cli-inputs.json.gz'),
    scope='Exact already-measured post-repair CLI bytes, restored to a new owned '
        'path. Four actual definition-AST sources; no fresh build is claimed.'))
runs=[]
for case in fixture['cases']:
    run=c.run(['./'+path,'--inline-spec',case['source'],'--input',case['input'],'--trace','none'])
    actual=json.loads(c.decode(run['stdout_base64'])) if run['returncode']==0 else None
    correct=run['returncode']==0 and matches(actual,case['expected']['ok'])
    runs.append(dict(id=case['id'],run=run,actual=actual,matches=correct))
stable=c.identity(path)=={key:binary[key] for key in ('sha256','mode')}
c.save('function-cli-runs.json.gz',dict(runs=runs,executable_unchanged=stable))
assert stable and all(row['matches'] for row in runs)
print('Four definition-AST CLI controls pass against exact current archived executable bytes.')
