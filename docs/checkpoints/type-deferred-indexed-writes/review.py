"""Read-only independent review of retained typed writes, controls and source epochs."""
import json,re,subprocess
import common as c
import book7 as book
import verify

def check():
 prior=c.load('prior-accepted.json.gz')
 assert prior['base']==c.BASE and prior['readonly']['returncode']==0
 for path,packet in prior['claims'].items():
  original=c.decode(packet['base64'])
  assert c.sha(original)==packet['sha256']
  assert subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)==original
 old=json.loads(c.decode(prior['claims']['docs/claims/TYPE-REFERENCE-BOOK.1.2.11.json']['base64']))
 frozen=json.loads((c.ROOT/'docs/claims/TYPE-REFERENCE-BOOK.1.2.11.json').read_bytes())
 for claim in old['claims']:claim['durability'].update(mode='historical',revision=c.BASE)
 assert frozen==old
 plan=json.loads((c.ROOT/'tests/numeric-codeblocks/indexed-writes.json').read_bytes())
 actual=c.load('attribution7.json.gz')
 assert actual['restored'] and actual['plan']==plan
 before=c.failures(actual['before'],plan)
 assert before and not c.failures(actual['after'],plan)
 for row in json.loads(c.decode(actual['after']['stdout_base64']))['rows']:
  for route in ('descriptor','native','generated'):assert not row[route]['warnings'],(row['id'],route)
 # Native typed failures intentionally retain the documented level-zero trace.

 for path,packet in actual['sources'].items():assert c.read(path)==packet,path
 original=c.load('attribution7-before.json.gz')['original']
 for path,packet in original.items():
  assert c.decode(packet['base64'])==subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
 returned=c.load('caller-inventory-repair.json.gz')
 assert not c.failures(returned['run'],returned['plan'])
 assert c.read(c.SOURCES[1])==returned['sources'][c.SOURCES[1]]
 compat=c.load('compat-fragment-after.json.gz')
 for path in c.SOURCES[1:]:assert c.read(path)==compat['sources'][path],path
 allocated=c.load('missing-slot-flag-repair.json.gz')
 for path,packet in allocated['sources'].items():assert c.read(path)==packet,path
 assert not c.failures(allocated['run'],allocated['plan'])
 assert json.loads(c.decode(compat['run']['stdout_base64']))==compat['expected']
 forwarded=c.load('forwarded-presence.json.gz')
 assert set(c.failures(forwarded['run'],forwarded['plan']))=={'forwarded/present-null'}
 operands=c.load('operand-validation2.json.gz')
 assert operands['source']==c.read(c.SOURCES[0])
 rows=json.loads(c.decode(operands['run']['stdout_base64']))
 assert all(row['seen']=='' and row['code']=='invalid_codeblock_body' for row in rows)
 direct=c.load('focused6.json.gz')
 assert direct['run']['returncode']==0 and direct['suites']==verify.SUITES
 for path in c.SOURCES+verify.SUITES+['tests/numeric-codeblocks/indexed-writes.json']:
  assert direct['context']['inputs'][path]==c.identity(path),'direct producer drift: '+path
 match=re.search(rb'Files=(\d+), Tests=(\d+),',c.decode(direct['run']['stdout_base64']))
 assert match and int(match[1])==len(verify.SUITES)
 faults=c.load('faults7.json')
 assert faults['restored']
 for name in faults['faults']:
  observed=c.load('fault7-'+name+'.json.gz')
  if 'plan' in observed:
   assert set(c.failures(observed['red'],observed['plan']))==set(faults['faults'][name])
   assert not c.failures(observed['green'],observed['plan'])
   assert observed['original']==c.read(observed['path'])
  else:
   assert observed['red']['returncode']==observed['green']['returncode']==0
   assert json.loads(c.decode(observed['red']['stdout_base64']))!=observed['expected']
   assert json.loads(c.decode(observed['green']['stdout_base64']))==observed['expected']
   assert observed['original']==c.read(observed.get('path',c.SOURCES[0]))
 rendered=c.load('book7.json.gz')
 prior_book=c.load('book4.json.gz')
 assert rendered['prior_render']['page_base64']==prior_book['healthy']['page_base64']
 assert book.signature(rendered['healthy'])==book.signature(rendered['prior_render'])
 assert book.signature(rendered['prose_changed'])!=book.signature(rendered['prior_render'])
 assert book.search_data.canonical(rendered['healthy']['search'])==book.search_data.canonical(rendered['prior_render']['search'])
 assert book.search_data.canonical(rendered['prose_changed']['search'])!=book.search_data.canonical(rendered['prior_render']['search'])
 assert book.search_data.canonical(rendered['url_control'])!=book.search_data.canonical(rendered['prior_render']['search'])
 native=c.load('native-search-json.json.gz')
 for name,run in [('old',rendered['prior_render']),('new',rendered['healthy'])]:
  observation=native['results'][name]
  assert observation['asset']==run['search']
  assert observation['run']['returncode']==0 and not c.decode(observation['run']['stderr_base64'])
  assert json.loads(c.decode(observation['run']['stdout_base64']))==book.search_data.decode_asset(run['search'])
 for path in ('search_data.py','check-search-json.js'):
  key='decoder' if path.endswith('.py') else 'javascript'
  assert native[key]==c.read(c.PREFIX+path)

 assert not c.failures(rendered['public'],rendered['plan'])
 for path in c.SOURCES+[c.PREFIX+'probe.pl',c.PREFIX+'common.py']:
  assert rendered['context']['inputs'][path]==c.identity(path),'book producer drift: '+path
 assert rendered['version']['returncode']==0
 book.validate(rendered['healthy'],rendered['plan'])
 assert rendered['control']==dict(rejected=True,reason='indexed-write anchor')
 try:book.validate(rendered['changed'],rendered['plan'])
 except AssertionError as error:assert str(error)=='indexed-write anchor'
 else:raise AssertionError('missing book denial')
 for path,packet in rendered['inputs'].items():assert c.read(path)==packet,'book drift: '+path
 intake=c.load('deferred-with-intake.json.gz')
 row=json.loads(c.decode(intake['run']['stdout_base64']))['rows'][0]
 assert row['native']['runtime_detail']['fields']['code']=='unknown_helper'
 assert row['native']['runtime_detail']['fields']['name']=='with'
 return dict(cases=len(plan['cases']),accepted_red=len(before),accepted_controls=len(plan['cases'])-len(before),faults=len(faults['faults']),direct_suites=int(match[1]),direct_tap=int(match[2]),book_inputs=len(rendered['inputs']),book_examples=len(rendered['plan']['cases']))
if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
