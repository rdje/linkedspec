"""Explicit provisional/final namespace sealing; never called by readonly review."""
import json
import sys
import common as c

assert sys.argv[1:] in (['provisional'],['final'])
provisional=sys.argv[1]=='provisional'
path=c.ROOT/c.PREFIX/'publication.json'
if provisional:assert not path.exists()
else:
    assert c.load('publication.json')['provisional']
    assert (c.ROOT/c.PREFIX/'input-controls.json.gz').is_file()
files={file.name:c.identity(c.PREFIX+file.name) for file in sorted((c.ROOT/c.PREFIX).iterdir())
    if file.is_file() and file.name!='publication.json'}
value=dict(version=1,owner=c.OWNER,base=c.BASE,provisional=provisional,inputs=files,
    scope='Exact physical publication namespace. Historical executable/source epochs '
        'are retained inside packets; no recapture or whole-environment replay. '
        'All capture/seal/control writers are retired after final acceptance.')
path.write_text(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n')
print('Provisional' if provisional else 'Final','namespace:',len(files),'whole files.')
