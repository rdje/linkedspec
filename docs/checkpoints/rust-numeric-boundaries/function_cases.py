"""Author explicit large-number controls through the real definition AST producer."""
import json
import struct
import common as c

numbers=json.loads(c.source('tests/numeric-conversion/cases.json').read_text())
selected=['small-positive','large-positive','large-negative','i64-high-below']
cases=[]
for index,name in enumerate(selected):
    row=next(row for row in numbers['cases'] if row['id']==name)
    number=struct.unpack('>d',bytes.fromhex(row['bits']))[0]
    literal=str(int(number))
    function='numeric_value_'+str(index)
    cases.append(dict(id='function/'+name,pointer_width=None,input='x',
        source='fn '+function+'() { return('+literal+') }\nTop: /x/\n I { return('+function+'()) }\n',
        expected={'ok':{'binary64':row['bits'],'json_kind':row['json_kind'],'integer':row['integer']}}))
name='tests/numeric-conversion/functions.json'
with (c.ROOT/name).open('x') as output:output.write(json.dumps(dict(version=1,owner=c.OWNER,cases=cases),indent=2)+'\n')
c.save('function-cases-inputs.json.gz',dict(producer=c.read(c.PREFIX+'function_cases.py'),
    numbers=c.read('tests/numeric-conversion/cases.json'),fixture=c.read(name)))
