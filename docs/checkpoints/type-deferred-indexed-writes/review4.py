"""Read-only independent review of retained typed writes, controls and source epochs."""
import json,re,subprocess
import common as c
import book9 as book
import verify3 as verify
import compare_tracking


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
 packet=c.load('compatibility3.json.gz')
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

def check_private_compatibility():
 rejected=c.load('rejected-canonical2.json.gz')
 assert rejected['canonical_result']['exit_code']==1 and rejected['readonly']['returncode']==0
 raw=c.decode(rejected['canonical_log']['base64'])
 assert c.sha(raw)==rejected['canonical_log']['sha256']
 assert b'Files=91, Tests=32246,' in raw and b'Failed 26/516 subtests' in raw and b'Result: FAIL' in raw
 import gzip
 manifest=json.loads(gzip.decompress(c.decode(rejected['files'][c.PREFIX+'manifest3.json.gz']['base64'])))
 exclusions={c.PREFIX+'manifest3.json.gz',c.PREFIX+'publication3.json','docs/claims/'+c.OWNER+'.json'}
 context=rejected['context']
 assert set(context['inputs'])-exclusions==set(manifest['inputs'])
 for path,identity in manifest['inputs'].items():
  assert context['inputs'][path]==identity
  image=context['overrides'].get(path)
  if image is not None:
   assert c.sha(c.decode(image['base64']))==identity['sha256'] and image['mode']==identity['mode']
  elif c.identity(path)!=identity:
   assert c.sha(subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT))==identity['sha256'],path
 result=compare_tracking.check()
 assert result==c.load('tracking-full-row-comparison.json.gz')['result']
 path='t/actionir_tracking_predicate_probe.pl'
 assert c.read(path)==rejected['files'][path]
 assert c.decode(c.read(path)['base64'])==subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
 path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-before-native.json'
 assert c.decode(c.read(path)['base64'])==subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
 inverse=c.load('tracking-assignment-inverse.json.gz')
 assert inverse['restored'] and inverse['syntax']['returncode']==0
 assert inverse['red']['returncode']!=0 and inverse['green']['returncode']==0
 assert inverse['original']==c.read(inverse['path'])
 assert b'preserves complete native row with private authority' in c.decode(inverse['red']['stderr_base64'])
 assert b'tracked scalar assignments preserve values and remain quiet in every context' in c.decode(inverse['red']['stderr_base64'])
 for path,image in inverse['suites'].items():assert c.read(path)==image,path
 return dict(private_rows=result['total_rows'],private_changed_rows=len(result['changed_rows']))

def check():
 private=check_private_compatibility()
 rejected_sources=check_rejected_epoch()
 check_compatibility()
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
 actual=c.load('attribution9.json.gz')
 assert actual['restored'] and actual['plan']==plan
 before=c.failures(actual['before'],plan)
 assert before and not c.failures(actual['after'],plan)
 for row in json.loads(c.decode(actual['after']['stdout_base64']))['rows']:
  for route in ('descriptor','native','generated'):assert not row[route]['warnings'],(row['id'],route)
 # Native typed failures intentionally retain the documented level-zero trace.

 for path,packet in actual['sources'].items():assert c.read(path)==packet,path
 original=c.load('attribution9-before.json.gz')['original']
 for path,packet in original.items():
  assert c.decode(packet['base64'])==subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
 returned=c.load('caller-inventory-repair.json.gz')
 assert not c.failures(returned['run'],returned['plan'])
 assert rejected_sources[c.SOURCES[1]]==returned['sources'][c.SOURCES[1]]
 compat=c.load('compat-fragment-after.json.gz')
 for path in c.SOURCES[1:]:assert rejected_sources[path]==compat['sources'][path],path
 allocated=c.load('missing-slot-flag-repair.json.gz')
 for path,packet in allocated['sources'].items():assert rejected_sources[path]==packet,path
 assert not c.failures(allocated['run'],allocated['plan'])
 assert json.loads(c.decode(compat['run']['stdout_base64']))==compat['expected']
 forwarded=c.load('forwarded-presence.json.gz')
 assert set(c.failures(forwarded['run'],forwarded['plan']))=={'forwarded/present-null'}
 operands=c.load('operand-validation2.json.gz')
 assert operands['source']==c.read(c.SOURCES[0])
 rows=json.loads(c.decode(operands['run']['stdout_base64']))
 assert all(row['seen']=='' and row['code']=='invalid_codeblock_body' for row in rows)
 direct=c.load('focused10.json.gz')
 assert direct['run']['returncode']==0 and direct['suites']==verify.SUITES
 assert b'Useless use of private variable in void context' not in c.decode(direct['run']['stderr_base64'])
 for path in c.SOURCES+verify.SUITES+['tests/numeric-codeblocks/indexed-writes.json','t/actionir_tracking_predicate_probe.pl','docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-before-native.json']:
  assert direct['context']['inputs'][path]==c.identity(path),'direct producer drift: '+path
 match=re.search(rb'Files=(\d+), Tests=(\d+),',c.decode(direct['run']['stdout_base64']))
 assert match and int(match[1])==len(verify.SUITES)
 faults=c.load('faults9.json')
 assert faults['restored']
 for name in faults['faults']:
  observed=c.load('fault9-'+name+'.json.gz')
  if observed.get('kind')=='suite':
   assert observed['syntax']['returncode']==0
   assert observed['red']['returncode']!=0 and observed['green']['returncode']==0
   assert observed['expected_failed_group'].encode() in c.decode(observed['red']['stderr_base64'])
   assert observed['suite']==c.read(observed.get('suite_path','t/multiline_helper_pattern_validation.t'))
   assert observed['original']==c.read(observed['path'])
  elif 'plan' in observed:
   assert set(c.failures(observed['red'],observed['plan']))==set(faults['faults'][name])
   assert not c.failures(observed['green'],observed['plan'])
   assert observed['original']==c.read(observed['path'])
  else:
   assert observed['red']['returncode']==observed['green']['returncode']==0
   assert json.loads(c.decode(observed['red']['stdout_base64']))!=observed['expected']
   assert json.loads(c.decode(observed['green']['stdout_base64']))==observed['expected']
   assert observed['original']==c.read(observed.get('path',c.SOURCES[0]))
 rendered=c.load('book9.json.gz')
 prior_book=c.load('book4.json.gz')
 assert rendered['original_render']['page_base64']==prior_book['healthy']['page_base64']
 expected=dict(prior_book['inputs'])
 raw=c.decode(expected[book.CHAPTER]['base64'])
 marker=(book.HEADING+'\n').encode()
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
 assert before_raw.replace(marker,c.decode(note['base64'])+marker,1)==c.decode(c.read(book.CHAPTER)['base64'])
 assert book.signature(rendered['healthy'])==book.signature(rendered['prior_render'])
 assert book.signature(rendered['prose_changed'])!=book.signature(rendered['prior_render'])
 assert book.search_data.canonical(rendered['healthy']['search'])==book.search_data.canonical(rendered['prior_render']['search'])
 assert book.search_data.canonical(rendered['prose_changed']['search'])!=book.search_data.canonical(rendered['prior_render']['search'])
 assert book.search_data.canonical(rendered['url_control'])!=book.search_data.canonical(rendered['prior_render']['search'])
 native=c.load('native-search-json3.json.gz')
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
 result=dict(cases=len(plan['cases']),accepted_red=len(before),accepted_controls=len(plan['cases'])-len(before),faults=len(faults['faults']),direct_suites=int(match[1]),direct_tap=int(match[2]),book_inputs=len(rendered['inputs']),book_examples=len(rendered['plan']['cases']))
 result.update(private)
 return result
if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
