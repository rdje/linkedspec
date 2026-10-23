"""Create distinct proof producers; original epochs and writers remain unchanged."""
import common as c

created={}
originals={}
def version(source,target,replacements):
 original=c.read(c.PREFIX+source)
 text=c.decode(original['base64']).decode()
 for needle,replacement,count in replacements:
  assert text.count(needle)==count,(source,needle,text.count(needle),count)
  text=text.replace(needle,replacement)
 with (c.ROOT/c.PREFIX/target).open('x') as stream:stream.write(text)
 originals[source]=original
 created[target]=c.read(c.PREFIX+target)

version('attribute7.py','attribute8.py',[
 ('attribution7','attribution8',2),('attribute7.py','attribute8.py',2)])
version('verify.py','verify2.py',[
 ('SUITES=[',"SUITES=['t/multiline_helper_pattern_validation.t',",1),
 ("c.PREFIX+'verify.py'","c.PREFIX+'verify2.py'",1)])

statement_healthy=' return \'do { $\'.$target.\' = \'.$value_expr.\'; $__ls_binding_presence{"\'.$target.\'"} = 1; $\'.$target.\' }\''
statement_fault=' return \'do { $\'.$target.\' = \'.$value_expr.\'; $__ls_binding_presence{"\'.$target.\'"} = 1 }\''
assert c.decode(c.read(c.SOURCES[1])['base64']).decode().count(statement_healthy)==1
ids=['compiled-assignment/'+name for name in
 ['lifecycle-dot','lifecycle-bare','lifecycle-plain','lifecycle-zero','lifecycle-null','lifecycle-array','lifecycle-harray']]
addition=' tasks.append('+repr(('statement-result',c.SOURCES[1],statement_healthy,statement_fault,ids))+')\n'
suite_fault=''' path=c.SOURCES[1]
 original=c.decode(saved[path]['base64']).decode()
 marker=' if (!$returns_value && $value_expr =~ /\\\\A(\\\\s*)\\\\//o) {'
 assert original.count(marker)==1
 faulty=original.replace(marker,marker.replace('if (','if (0 && ',1),1)
 command=['bash','tools/project_data_run.sh','prove','-q','-Iperl','t/multiline_helper_pattern_validation.t']
 try:
  (c.ROOT/path).write_text(faulty)
  actual=c.read(path)
  syntax=c.run(['bash','tools/project_data_run.sh','perl','-Iperl','-c',path])
  assert syntax['returncode']==0
  red=c.run(command)
 finally:(c.ROOT/path).write_bytes(c.decode(saved[path]['base64']))
 green=c.run(command)
 group='full-source slash retry preserves regexes and publishes only selected diagnostics'
 c.save('fault8-raw-regex-fragment.json.gz',dict(kind='suite',path=path,original=saved[path],fault=actual,
  syntax=syntax,red=red,green=green,command=command,expected_failed_group=group,
  suite=c.read('t/multiline_helper_pattern_validation.t'),producer=c.read(c.PREFIX+'faults8.py')))
 assert red['returncode']!=0 and green['returncode']==0
 assert group.encode() in c.decode(red['stderr_base64'])
 assert c.read(path)==saved[path]
 reports['raw-regex-fragment']=['unchanged multiline suite and independently emitted compatibility controls']
'''
version('faults7.py','faults8.py',[
 ('faults7.py','faults8.py',3),('fault7-','fault8-',3),('faults7.json','faults8.json',1),
 (' reports={}\n',addition+' reports={}\n',1),
 (" c.save('faults8.json'",suite_fault+" c.save('faults8.json'",1)])

overlay=''' original_render=render(prior['inputs'])
 assert original_render['page_base64']==prior['healthy']['page_base64']
 note=c.read(c.PREFIX+'book-compatibility-note.txt')
 expected_inputs=dict(prior['inputs'])
 expected_raw=c.decode(expected_inputs[CHAPTER]['base64'])
 marker=(HEADING+'\\n').encode()
 assert expected_raw.count(marker)==1
 expected_raw=expected_raw.replace(marker,c.decode(note['base64'])+marker,1)
 expected_inputs[CHAPTER]=dict(base64=c.encode(expected_raw),sha256=c.sha(expected_raw),mode=expected_inputs[CHAPTER]['mode'])
 prior_render=render(expected_inputs)
'''
version('book7.py','book8.py',[
 (" prior_render=render(prior['inputs'])\n assert prior_render['page_base64']==prior['healthy']['page_base64']\n",overlay,1),
 ("comparison=comparison,prior_render=prior_render,","comparison=comparison,prior_render=prior_render,original_render=original_render,expected_inputs=expected_inputs,note=note,",1),
 ('book7.json.gz','book8.json.gz',1),('book7.py','book8.py',1)])
version('check_search_native.py','check_search_native2.py',[
 ("supplied = c.load('search-inspection.json.gz')","book = c.load('book8.json.gz')\n    supplied = dict(old=book['prior_render'], new=book['healthy'])",1),
 ('native-search-json.json.gz','native-search-json2.json.gz',1),
 ('check_search_native.py','check_search_native2.py',1),
 ('search-inspection.json.gz','book8.json.gz',1)])
c.save('repair-proof-preparation.json.gz',dict(originals=originals,created=created,
 producer=c.read(c.PREFIX+'prepare_repair_proof.py')))
print('Created distinct producers:',', '.join(created))
