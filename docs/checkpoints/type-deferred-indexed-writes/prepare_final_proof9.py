"""Prepare the warning-free source epoch without overwriting prior observations."""
import ast
import common as c
created={}
for source,destination,replacements in [
 ('faults8.py','faults9.py',[('faults8','faults9'),('fault8-','fault9-'),("= 1; $\\'.$target.\\' }", "= 1; scalar($\\'.$target.\\') }")]),
 ('attribute8.py','attribute9.py',[('attribution8','attribution9'),('attribute8','attribute9')]),
 ('book8.py','book9.py',[('book8','book9')]),
 ('check_search_native2.py','check_search_native3.py',[('book8','book9'),('native-search-json2','native-search-json3'),('check_search_native2','check_search_native3')]),
 ('review2.py','review3.py',[('book8','book9'),('compatibility2','compatibility3'),('attribution8','attribution9'),('focused8','focused9'),('faults8','faults9'),('fault8-','fault9-'),('native-search-json2','native-search-json3')]),
 ('compare_compatibility2.py','compare_compatibility3.py',[('compatibility-repair.json.gz','assignment-result-repair.json.gz'),('compatibility2','compatibility3')]),
]:
 path=c.PREFIX+source
 raw=c.decode(c.read(path)['base64']).decode()
 for old,new in replacements:
  assert old in raw,(source,old)
  raw=raw.replace(old,new)
 if destination=='faults9.py':
  marker=" c.save('faults9.json',"
  extra=''' path=c.SOURCES[1]
 original=c.decode(saved[path]['base64']).decode()
 marker="= 1; scalar($"+"'.$target.'"+") }'"
 assert original.count(marker)==1
 faulty=original.replace(marker,"= 1; $"+"'.$target.'"+" }'",1)
 command=['bash','tools/project_data_run.sh','prove','-q','-Iperl','t/callable_codeblock_literal_contract.t']
 try:
  (c.ROOT/path).write_text(faulty)
  actual=c.read(path)
  syntax=c.run(['bash','tools/project_data_run.sh','perl','-Iperl','-c',path])
  assert syntax['returncode']==0
  red=c.run(command)
 finally:(c.ROOT/path).write_bytes(c.decode(saved[path]['base64']))
 green=c.run(command)
 group='tracked scalar assignments preserve values and remain quiet in every context'
 c.save('fault9-statement-warning.json.gz',dict(kind='suite',path=path,original=saved[path],fault=actual,
  syntax=syntax,red=red,green=green,command=command,expected_failed_group=group,
  suite_path='t/callable_codeblock_literal_contract.t',suite=c.read('t/callable_codeblock_literal_contract.t'),producer=c.read(c.PREFIX+'faults9.py')))
 assert red['returncode']!=0 and green['returncode']==0
 assert group.encode() in c.decode(red['stderr_base64'])
 assert c.read(path)==saved[path]
 reports['statement-warning']=['void/value/list assignment values and quietness']
'''
  assert raw.count(marker)==1
  raw=raw.replace(marker,extra+marker,1)
 if destination=='review3.py':
  raw=raw.replace("c.read('t/multiline_helper_pattern_validation.t')", "c.read(observed.get('suite_path','t/multiline_helper_pattern_validation.t'))")
  marker=" assert direct['run']['returncode']==0 and direct['suites']==verify.SUITES\n"
  assert raw.count(marker)==1
  raw=raw.replace(marker,marker+" assert b'Useless use of private variable in void context' not in c.decode(direct['run']['stderr_base64'])\n")
 ast.parse(raw)
 target=c.PREFIX+destination
 with (c.ROOT/target).open('x') as stream:stream.write(raw)
 created[target]=c.read(target)
path=c.PREFIX+'publish2.py'
before=c.read(path)
raw=c.decode(before['base64']).decode().replace('import review2 as review','import review3 as review').replace('focused8.json.gz','focused9.json.gz')
raw=raw.replace('assignment result and raw-fragment wrapping','assignment result, void-context warnings and raw-fragment wrapping')
raw=raw.replace('compatibility2.plans.intake','compatibility3.plans.intake')
raw=raw.replace('Complete tracked scalar statements preserve their assigned values;', 'Complete tracked scalar statements preserve their assigned values without void-context warnings;')
ast.parse(raw)
(c.ROOT/path).write_text(raw)
c.save('assignment-result-repair.json.gz',dict(sources={p:c.read(p) for p in c.SOURCES},
 test=c.read('t/callable_codeblock_literal_contract.t'),before=c.load('assignment-result-context-before.json.gz'),
 created=created,publisher_before=before,publisher_after=c.read(path),producer=c.read(c.PREFIX+'prepare_final_proof9.py')))
print('Prepared final source epoch:',len(created),'new producers; prior captures unchanged')
