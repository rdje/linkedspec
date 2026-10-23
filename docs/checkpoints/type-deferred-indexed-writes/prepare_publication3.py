"""Preserve a verbatim paragraph separator with a path-specific Git exception."""
import ast
import common as c
prior=c.load('publication2-whitespace-boundary.json.gz')
assert prior['readonly']['returncode']==0
for path,image in prior['files'].items():assert c.read(path)==image,path
before={p:c.read(p) for p in ['.gitattributes','MEMORY.md','CHANGES.md',
 'docs/tasks/TYPE-REFERENCE-BOOK.md','docs/knowledge/selected-consumer-proof-input-closure-gap.md',c.PREFIX+'README.md']}
red=c.run(['git','diff','--cached','--check'])
assert red['returncode']!=0 and b'book-compatibility-note.txt:2: new blank line at EOF.' in c.decode(red['stdout_base64'])
path='.gitattributes'
raw=c.decode(before[path]['base64']).decode()
raw+='# Verbatim mdBook paragraph overlay retains its following paragraph separator.\n'
raw+='docs/checkpoints/type-deferred-indexed-writes/book-compatibility-note.txt whitespace=-blank-at-eof\n'
(c.ROOT/path).write_text(raw)
created={}
for old,new,replacements in [
 ('publish2.py','publish3.py',[('manifest2','manifest3'),('publication2.json','publication3.json'),
  ('artifact3-','artifact4-'),('scope3-runs','scope4-runs'),('publish2.py','publish3.py')]),
 ('artifacts3.py','artifacts4.py',[('import publish2 as publish','import publish3 as publish'),
  ('publish2.py','publish3.py'),('artifact3-','artifact4-'),('scope3-runs','scope4-runs'),('artifacts3.py','artifacts4.py')])]:
 raw=c.decode(c.read(c.PREFIX+old)['base64']).decode()
 for source,target in replacements:
  assert source in raw,(old,source)
  raw=raw.replace(source,target)
 if new=='publish3.py':
  source="prior=c.load('rejected-canonical1.json.gz')['publication'][CLAIM]"
  target="prior=c.load('publication2-whitespace-boundary.json.gz')['files'][CLAIM]"
  assert raw.count(source)==1
  raw=raw.replace(source,target)
  marker="claim['scope']+=' Ten fixed lifecycle/value controls"
  assert raw.count(marker)==1
  raw=raw.replace(marker,"claim['scope']+=' Whole publication2 and actual readonly PASS precede a path-specific whitespace attribute for the verbatim paragraph separator; runtime and book bytes are unchanged. Ten fixed lifecycle/value controls",1)
 ast.parse(raw)
 path=c.PREFIX+new
 with (c.ROOT/path).open('x') as stream:stream.write(raw)
 created[path]=c.read(path)
for path in ['MEMORY.md','CHANGES.md','docs/tasks/TYPE-REFERENCE-BOOK.md',
 'docs/knowledge/selected-consumer-proof-input-closure-gap.md',c.PREFIX+'README.md']:
 raw=c.decode(before[path]['base64']).decode().replace(c.PREFIX+'publish2.py',c.PREFIX+'publish3.py')
 if path=='docs/tasks/TYPE-REFERENCE-BOOK.md':
  raw=raw.replace('Durability/limits: publish2 watches','Durability/limits: publish3 watches',1)
  marker='  Acceptance checklist:\n'
  start=raw.index('- ID: `'+c.OWNER+'`');offset=raw.index(marker,start)
  raw=raw[:offset]+('  Final staging hygiene: Git flags the exact paragraph fixture\'s two-newline separator. '
   'publication2-whitespace-boundary.json.gz retains the whole completed second publication, actual readonly PASS and source epoch before any change. '
   'A path-specific blank-at-eof attribute preserves the measured input bytes, matching existing verbatim-delimiter exceptions. '
   'publish3/artifacts4 refresh only publication closure and validator controls; functional/frozen/book/source-fault9 observations remain exact.\n')+raw[offset:]
 if path==c.PREFIX+'README.md':
  raw+='\nWhole publication2/actual readonly PASS precedes the narrow whitespace attribute for book-compatibility-note.txt; its exact paragraph separator and all runtime/book bytes stay unchanged. Publication3/artifacts4 bind the final metadata closure.\n'
 (c.ROOT/path).write_text(raw)
green=c.run(['git','diff','--cached','--check'])
c.save('whitespace-publication-preparation.json.gz',dict(before=before,after={p:c.read(p) for p in before},
 created=created,red=red,green=green,producer=c.read(c.PREFIX+'prepare_publication3.py')))
assert green['returncode']==0,green
print('Exact paragraph bytes retained; actual Git whitespace RED/GREEN; publication3 prepared')
