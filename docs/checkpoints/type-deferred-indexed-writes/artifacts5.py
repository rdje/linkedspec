"""Actual identity and three named population omissions, with bypass/restoration."""
import copy,json
import common as c
import publish4 as publish

def parsed(run):
 assert run['returncode']==0 and not c.decode(run['stderr_base64']),run
 return json.loads(c.decode(run['stdout_base64']))

def main():
 path=c.PREFIX+'publish4.py'
 original=c.read(path)
 source=c.decode(original['base64']).decode()
 target=publish.TARGET
 actual={target:c.identity(target)}
 cases={name:copy.deepcopy(actual) for name in ('missing','bytes','mode')}
 cases['missing'].pop(target)
 cases['bytes'][target]['sha256']='0'*64
 cases['mode'][target]['mode']^=0o100
 c.save('artifact5-inputs.json.gz',dict(actual=actual,cases=cases,producer=c.read(c.PREFIX+'artifacts5.py')))
 command=['bash','tools/run_python_project_data.sh',path,'--controls']
 healthy=c.run(command)
 marker='def validate_identity(declared,actual):\n'
 assert source.count(marker)==1
 try:
  (c.ROOT/path).write_text(source.replace(marker,marker+' return\n',1))
  fault=c.read(path)
  bypass=c.run(command)
 finally:(c.ROOT/path).write_bytes(c.decode(original['base64']))
 restored=c.run(command)
 red=parsed(healthy)
 assert len(red)==3 and all(item['rejected'] for item in red.values())
 assert parsed(restored)==red
 assert all(not item['rejected'] for item in parsed(bypass).values())
 assert c.read(path)==original
 c.save('artifact5-run.json.gz',dict(original=original,fault=fault,healthy=healthy,bypass=bypass,
  restored_run=restored,restored=True,denials=len(red),producer=c.read(c.PREFIX+'artifacts5.py')))
 command=['bash','tools/run_python_project_data.sh',path,'--scope-control']
 marker=' return sorted(set(c.paths())-{MANIFEST,PUBLICATION,CLAIM})\n'
 assert source.count(marker)==1
 validator='def validate_scope(actual):\n'
 assert source.count(validator)==1
 observations={}
 for target in publish.TARGETS:
  healthy=c.run(command)
  omitted=source.replace(marker,' return sorted(set(c.paths())-{MANIFEST,PUBLICATION,CLAIM,'+repr(target)+'})\n',1)
  bypass=omitted.replace(validator,validator+' return\n',1)
  runs={}
  images={}
  try:
   for name,variant in [('omitted',omitted),('bypass',bypass),('validator_restored',omitted)]:
    (c.ROOT/path).write_text(variant)
    images[name]=c.read(path)
    runs[name]=c.run(command)
  finally:(c.ROOT/path).write_bytes(c.decode(original['base64']))
  green=c.run(command)
  observations[target]=dict(healthy=healthy,green=green,sources=images,**runs)
  assert parsed(healthy)==parsed(green)==dict(rejected=False,reason='')
  for name in ('omitted','validator_restored'):
   assert parsed(runs[name])==dict(rejected=True,reason='measurement input: '+target)
  assert parsed(runs['bypass'])==dict(rejected=False,reason='')
  assert c.read(path)==original
 c.save('scope5-runs.json.gz',dict(original=original,targets=publish.TARGETS,runs=observations,
  restored=c.read(path)==original,producer=c.read(c.PREFIX+'artifacts5.py')))
 print('Actual identity denials3 and named omissions3, with bypasses and exact restoration PASS')

if __name__=='__main__':main()
