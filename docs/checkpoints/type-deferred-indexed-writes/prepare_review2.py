"""Version the readonly reviewer and add independent compatibility/rejection checks."""
import common as c
old=c.read(c.PREFIX+'review.py')
text=c.decode(old['base64']).decode()
def replace(needle,replacement,count=1):
 global text
 assert text.count(needle)==count,(needle,text.count(needle),count)
 text=text.replace(needle,replacement)
replace('import book7 as book','import book8 as book')
replace('import verify\n','import verify2 as verify\n')
replace('attribution7','attribution8',2)
replace('focused6.json.gz','focused7.json.gz')
replace('faults7.json','faults8.json')
replace('fault7-','fault8-')
replace('book7.json.gz','book8.json.gz')
replace('native-search-json.json.gz','native-search-json2.json.gz')
replace(" assert c.read(c.SOURCES[1])==returned['sources'][c.SOURCES[1]]",
 " assert rejected_sources[c.SOURCES[1]]==returned['sources'][c.SOURCES[1]]")
replace(" for path in c.SOURCES[1:]:assert c.read(path)==compat['sources'][path],path",
 " for path in c.SOURCES[1:]:assert rejected_sources[path]==compat['sources'][path],path")
replace(" for path,packet in allocated['sources'].items():assert c.read(path)==packet,path",
 " for path,packet in allocated['sources'].items():assert rejected_sources[path]==packet,path")
replace('def check():\n',"def check():\n rejected_sources=check_rejected_epoch()\n check_compatibility()\n")
replace("  if 'plan' in observed:\n",'''  if observed.get('kind')=='suite':
   assert observed['syntax']['returncode']==0
   assert observed['red']['returncode']!=0 and observed['green']['returncode']==0
   assert observed['expected_failed_group'].encode() in c.decode(observed['red']['stderr_base64'])
   assert observed['suite']==c.read('t/multiline_helper_pattern_validation.t')
   assert observed['original']==c.read(observed['path'])
  elif 'plan' in observed:
''')
replace(" assert rendered['prior_render']['page_base64']==prior_book['healthy']['page_base64']",''' assert rendered['original_render']['page_base64']==prior_book['healthy']['page_base64']
 expected=dict(prior_book['inputs'])
 raw=c.decode(expected[book.CHAPTER]['base64'])
 marker=(book.HEADING+'\\n').encode()
 assert raw.count(marker)==1
 note=c.read(c.PREFIX+'book-compatibility-note.txt')
 assert note==rendered['note']
 raw=raw.replace(marker,c.decode(note['base64'])+marker,1)
 expected[book.CHAPTER]=dict(base64=c.encode(raw),sha256=c.sha(raw),mode=expected[book.CHAPTER]['mode'])
 assert rendered['expected_inputs']==expected
 docs=c.load('compatibility-docs.json.gz')
 assert docs['before'][book.CHAPTER]==c.load('book7.json.gz')['inputs'][book.CHAPTER]
 assert docs['after'][book.CHAPTER]==c.read(book.CHAPTER)
 before_raw=c.decode(docs['before'][book.CHAPTER]['base64'])
 assert before_raw.count(marker)==1
 assert before_raw.replace(marker,c.decode(note['base64'])+marker,1)==c.decode(c.read(book.CHAPTER)['base64'])''')
helpers='''
def check_rejected_epoch():
 rejected=c.load('rejected-canonical1.json.gz')
 assert rejected['canonical_result']['exit_code']==1
 log=rejected['canonical_combined_log']
 raw=c.decode(log['base64'])
 assert c.sha(raw)==log['sha256']
 assert b'1..1035' in raw and b'Failed tests:  800, 1034' in raw and b'Result: FAIL' in raw
 assert rejected['readonly_publication']['returncode']==0
 assert not c.decode(rejected['readonly_publication']['stderr_base64'])
 first={path:packet for path,packet in rejected['publication'].items()}
 for packet in first.values():assert c.sha(c.decode(packet['base64']))==packet['sha256']
 import gzip
 manifest=json.loads(gzip.decompress(c.decode(first[c.PREFIX+'manifest.json.gz']['base64'])))
 exclusions={c.PREFIX+'manifest.json.gz',c.PREFIX+'publication.json','docs/claims/'+c.OWNER+'.json'}
 context=rejected['context']
 assert set(context['inputs'])-exclusions==set(manifest['inputs'])
 for path,identity in manifest['inputs'].items():
  assert context['inputs'][path]==identity
  packet=context['overrides'].get(path)
  if packet is not None:
   assert c.sha(c.decode(packet['base64']))==identity['sha256']
   assert packet['mode']==identity['mode']
  elif c.identity(path)!=identity:
   original=subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
   assert c.sha(original)==identity['sha256'],'unrecoverable rejected input: '+path
 return context['overrides']

def check_compatibility():
 packet=c.load('compatibility2.json.gz')
 assert packet['restored'] and not any(packet['failures'].values())
 for path,image in packet['sources'].items():assert c.read(path)==image,path
 public=json.loads((c.ROOT/'tests/numeric-codeblocks/indexed-writes.json').read_bytes())
 selected=[case for case in public['cases'] if case['id'].startswith('compiled-assignment/')]
 assert packet['plans']['lifecycle']==dict(cases=selected) and len(selected)==10
 assert not c.failures(packet['runs']['lifecycle'],packet['plans']['lifecycle'])
 for path,run in packet['accepted'].items():
  assert run['returncode']==0
  assert c.decode(run['stdout_base64'])==subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
 for run in (packet['runs']['regex'],packet['baseline']['regex']):
  assert run['returncode']==0 and not c.decode(run['stderr_base64'])
  rows=json.loads(c.decode(run['stdout_base64']))['rows']
  assert [row['id'] for row in rows]==[case['id'] for case in packet['plans']['regex']['cases']]
  for row in rows:
   expected=None if row['id'].endswith('/unescaped') else 7
   for route in ('native','generated'):
    value=row[route]
    assert value['completed'] and value['exception'] is None and value['last_error'] is None
    assert not value['warnings'] and not value['stdout'] and value['value']==expected,(row['id'],route)
 assert packet['legacy_probe']==c.read(c.PREFIX+'probe_legacy_regex.pl')
 oracle=packet['runs']['oracle']
 assert oracle['returncode']==0 and not c.decode(oracle['stderr_base64'])
 expected=[dict(id='payload-original',authored=1,inserted_semicolon=0),
  dict(id='payload-inserted-semicolon',authored=0,inserted_semicolon=1)]
 assert json.loads(c.decode(oracle['stdout_base64']))==dict(rows=expected)
 assert packet['oracle_producer']==c.read(c.PREFIX+'raw_regex_oracle.pl')
 for run in (packet['runs']['intake'],packet['baseline']['intake']):
  assert run['returncode']==0 and not c.decode(run['stderr_base64'])
  rows=json.loads(c.decode(run['stdout_base64']))['rows']
  assert [row['id'] for row in rows]==[row['id'] for row in expected]
  for row,witness in zip(rows,expected):
   for route in ('native','generated'):
    value=row[route]
    assert value['completed'] and value['exception'] is None and value['last_error'] is None
    assert not value['warnings'] and not value['stdout']
    assert value['value'] in ('',1)
    assert bool(value['value'])==bool(witness['inserted_semicolon'])
    assert bool(value['value'])!=bool(witness['authored'])

'''
text=text.replace('\ndef check():','\n'+helpers+'def check():',1)
compile(text,c.PREFIX+'review2.py','exec')
with (c.ROOT/c.PREFIX/'review2.py').open('x') as stream:stream.write(text)
c.save('review2-preparation.json.gz',dict(original=old,current=c.read(c.PREFIX+'review2.py'),
 producer=c.read(c.PREFIX+'prepare_review2.py')))
print('Distinct readonly reviewer prepared; rejected epochs stay independently recoverable.')
