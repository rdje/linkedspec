"""Execute exact authored examples and inspect a complete supplied mdBook render."""
import html,json,os,pathlib,re,subprocess,tempfile
from html.parser import HTMLParser
import common as c
import search_data
CHAPTER='docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
HEADING='### Deferred indexed writes in Perl'
ANCHOR='deferred-indexed-writes-in-perl'
PAGE='dsl/values-containers-and-flow-helpers.html'

def inputs():
 tracked=set(subprocess.check_output(['git','ls-files','-z'],cwd=c.ROOT).decode().split('\0'))
 paths={p for p in tracked if p.startswith('docs/linkedspec-book/src/') or p=='docs/linkedspec-book/book.toml'}
 pending=list(paths)
 while pending:
  path=pending.pop()
  for match in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}',c.decode(c.read(path)['base64'])):
   target=((c.ROOT/path).parent/match.decode().split(':',1)[0]).resolve().relative_to(c.ROOT).as_posix()
   assert target in tracked
   if target not in paths:paths.add(target);pending.append(target)
 return {p:c.read(p) for p in sorted(paths)}
def render(supplied,changed=False):
 with tempfile.TemporaryDirectory(prefix='indexed-write-book-',dir=os.environ['TMPDIR']) as folder:
  root=pathlib.Path(folder)
  assert root.stat().st_dev==c.ROOT.stat().st_dev
  for path,packet in supplied.items():
   raw=c.decode(packet['base64']);assert c.sha(raw)==packet['sha256']
   if changed and path==CHAPTER:
    assert raw.count(HEADING.encode())==1
    raw=raw.replace(HEADING.encode(),b'### Removed indexed write heading',1)
   target=root/path;target.parent.mkdir(parents=True,exist_ok=True)
   target.write_bytes(raw);target.chmod(packet['mode'])
  command=['mdbook','build','docs/linkedspec-book','-d','output']
  env={key:value for key,value in os.environ.items() if not key.startswith('MDBOOK_')}
  p=subprocess.run(command,cwd=root,env=env,capture_output=True)
  result=dict(command=command,returncode=p.returncode,stdout_base64=c.encode(p.stdout),stderr_base64=c.encode(p.stderr),page_base64='',search=None)
  if p.returncode==0:
   output=(root/'output').resolve();page=(output/PAGE).read_bytes()
   found=re.findall(rb'window\.path_to_searchindex_js = "([^"]+)";',page)
   assert len(found)==1
   asset=(output/pathlib.Path(PAGE).parent/found[0].decode()).resolve()
   relative=asset.relative_to(output).as_posix();raw=asset.read_bytes()
   assert re.fullmatch(r'searchindex-[0-9a-f]{8}\.js',relative)
   result.update(page_base64=c.encode(page),search=dict(path=relative,base64=c.encode(raw),sha256=c.sha(raw),mode=asset.stat().st_mode&0o7777))
  return result
def validate(run,plan):
 assert run['returncode']==0,'book build'
 page=c.decode(run['page_base64']).decode()
 assert 'id="'+ANCHOR+'"' in page,'indexed-write anchor'
 for case in plan['cases']:assert (case['source'] if 'source' in case else case['body']).rstrip() in html.unescape(page),'executed example'

class PageSignature(HTMLParser):
 def __init__(self):
  super().__init__(convert_charrefs=True)
  self.tokens=[]
  self.literal=0
 def handle_starttag(self,tag,attrs):
  self.tokens.append(('open',tag,sorted(attrs)))
  if tag in ('pre','code','script','style'):self.literal+=1
 def handle_endtag(self,tag):
  self.tokens.append(('close',tag))
  if tag in ('pre','code','script','style'):self.literal-=1
  assert self.literal>=0
 def handle_data(self,data):
  self.tokens.append(('text',data if self.literal else re.sub(r'[ \t\r\n\f]+',' ',data)))
 def handle_comment(self,data):self.tokens.append(('comment',data))
 def handle_decl(self,data):self.tokens.append(('declaration',data))
 def handle_pi(self,data):self.tokens.append(('instruction',data))
def signature(run):
 parser=PageSignature()
 page=c.decode(run['page_base64']).decode()
 reference='window.path_to_searchindex_js = \"../'+run['search']['path']+'\";'
 assert page.count(reference)==1
 parser.feed(page.replace(reference,'window.path_to_searchindex_js = \"<verified-search-index>\";',1))
 parser.close()
 assert parser.literal==0
 return parser.tokens

def main():
 plan=c.load('book-cases2.json')
 text=(c.ROOT/CHAPTER).read_text()
 section=re.split(r'\n#{1,3} ',text.split(HEADING+'\n',1)[1],maxsplit=1)[0]
 bodies=re.findall(r'^```text\n(.*?)^```\s*$',section,re.M|re.S)
 assert bodies==[case['source'] if 'source' in case else case['body'] for case in plan['cases']]
 context=c.epoch()
 supplied=inputs();public=c.observe(plan)
 healthy=render(supplied);changed=render(supplied,True)
 prior=c.load('book4.json.gz')
 original_render=render(prior['inputs'])
 assert original_render['page_base64']==prior['healthy']['page_base64']
 note=c.read(c.PREFIX+'book-compatibility-note.txt')
 expected_inputs=dict(prior['inputs'])
 expected_raw=c.decode(expected_inputs[CHAPTER]['base64'])
 marker=(HEADING+'\n').encode()
 assert expected_raw.count(marker)==1
 expected_raw=expected_raw.replace(marker,c.decode(note['base64'])+marker,1)
 expected_inputs[CHAPTER]=dict(base64=c.encode(expected_raw),sha256=c.sha(expected_raw),mode=expected_inputs[CHAPTER]['mode'])
 prior_render=render(expected_inputs)
 raw=c.decode(supplied[CHAPTER]['base64'])
 needle=b'Perl callable bodies accept'
 assert raw.count(needle)==1
 poisoned=raw.replace(needle,b'Perl callable bodies reject',1)
 override=dict(base64=c.encode(poisoned),sha256=c.sha(poisoned),mode=supplied[CHAPTER]['mode'])
 prose_inputs={**supplied,CHAPTER:override}
 prose_changed=render(prose_inputs)
 url_control=search_data.corrupt_url(healthy['search'])
 comparison=dict(prior='book4.json.gz',same=signature(healthy)==signature(prior_render),prose_red=signature(prose_changed)!=signature(prior_render),search_same=search_data.canonical(healthy['search'])==search_data.canonical(prior_render['search']),search_prose_red=search_data.canonical(prose_changed['search'])!=search_data.canonical(prior_render['search']),search_url_red=search_data.canonical(url_control)!=search_data.canonical(prior_render['search']))

 try:validate(changed,plan)
 except AssertionError as error:control=dict(rejected=True,reason=str(error))
 else:control=dict(rejected=False,reason='')
 c.save('book8.json.gz',dict(context=context,inputs=supplied,plan=plan,public=public,comparison=comparison,prior_render=prior_render,original_render=original_render,expected_inputs=expected_inputs,note=note,url_control=url_control,prose_override={CHAPTER:override},prose_changed=prose_changed,healthy=healthy,changed=changed,control=control,producer=c.read(c.PREFIX+'book8.py'),observer=c.read(c.PREFIX+'probe.pl'),version=c.run(['mdbook','--version'])))
 assert not c.failures(public,plan),c.failures(public,plan)
 assert all(comparison[key] for key in ('same','prose_red','search_same','search_prose_red','search_url_red')),comparison
 validate(healthy,plan)
 assert control==dict(rejected=True,reason='indexed-write anchor')
 assert all(c.read(path)==packet for path,packet in supplied.items())
 print('Book:',len(supplied),'complete inputs;',len(plan['cases']),'exact executed examples; actual anchor RED')
if __name__=='__main__':main()
