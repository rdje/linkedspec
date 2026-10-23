"""Exercise actual manifest validation and omission detection, including bypasses."""
import copy,json
import common as c
import publish

def parsed(run):
 assert run['returncode']==0 and not c.decode(run['stderr_base64']),run
 return json.loads(c.decode(run['stdout_base64']))

def main():
 path=c.PREFIX+'publish.py'
 original=c.read(path);text=c.decode(original['base64']).decode()
 target=publish.TARGET
 actual={target:c.identity(target)}
 cases={name:copy.deepcopy(actual) for name in ('missing','bytes','mode')}
 cases['missing'].pop(target)
 cases['bytes'][target]['sha256']='0'*64
 cases['mode'][target]['mode']^=0o100
 c.save('artifact2-inputs.json.gz',dict(actual=actual,cases=cases,producer=c.read(c.PREFIX+'artifacts2.py')))
 command=['bash','tools/run_python_project_data.sh',path,'--controls']
 healthy=c.run(command)
 needle='def validate_identity(declared,actual):\n'
 assert text.count(needle)==1
 faulty=text.replace(needle,needle+' return\n',1)
 try:
  (c.ROOT/path).write_text(faulty)
  fault=c.read(path);bypass=c.run(command)
 finally:(c.ROOT/path).write_bytes(c.decode(original['base64']))
 restored=c.run(command)
 red=parsed(healthy);green=parsed(restored);admitted=parsed(bypass)
 exact=c.read(path)==original
 c.save('artifact2-run.json.gz',dict(original=original,fault=fault,healthy=healthy,bypass=bypass,restored_run=restored,restored=exact,denials=len(red),producer=c.read(c.PREFIX+'artifacts2.py')))
 packet=c.load('artifact2-run.json.gz')
 assert packet['restored'] and all(item['rejected'] for item in red.values())
 assert green==red and all(not item['rejected'] for item in admitted.values())
 command=['bash','tools/run_python_project_data.sh',path,'--scope-control']
 healthy=c.run(command)
 needle=' return sorted(set(c.paths())-{MANIFEST,PUBLICATION,CLAIM})\n'
 assert text.count(needle)==1
 omitted_text=text.replace(needle,' return sorted(set(c.paths())-{MANIFEST,PUBLICATION,CLAIM,TARGET})\n',1)
 marker='def validate_scope(actual):\n'
 assert omitted_text.count(marker)==1
 bypass_text=omitted_text.replace(marker,marker+' return\n',1)
 observations={};sources={}
 try:
  for name,source in [('omitted',omitted_text),('bypass',bypass_text),('validator_restored',omitted_text)]:
   (c.ROOT/path).write_text(source);sources[name]=c.read(path);observations[name]=c.run(command)
 finally:(c.ROOT/path).write_bytes(c.decode(original['base64']))
 green=c.run(command)
 exact=c.read(path)==original
 c.save('scope2-run.json.gz',dict(original=original,target=target,healthy=healthy,green=green,restored=exact,sources=sources,producer=c.read(c.PREFIX+'artifacts2.py'),**observations))
 assert parsed(healthy)==parsed(green)==dict(rejected=False,reason='')
 assert parsed(observations['omitted'])==parsed(observations['validator_restored'])==dict(rejected=True,reason='measurement input: '+target)
 assert parsed(observations['bypass'])==dict(rejected=False,reason='')
 assert exact
 print('Identity denials3/bypass/restoration and actual named fixture omission/scope bypass/restoration PASS')
if __name__=='__main__':main()
