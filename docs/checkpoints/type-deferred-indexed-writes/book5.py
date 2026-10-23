"""Execute exact authored examples and inspect a complete supplied mdBook render."""
import html,json,os,pathlib,re,subprocess,tempfile
from html.parser import HTMLParser
import common as c
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
  return dict(command=command,returncode=p.returncode,stdout_base64=c.encode(p.stdout),stderr_base64=c.encode(p.stderr),page_base64=c.encode((root/'output'/PAGE).read_bytes()) if p.returncode==0 else '')
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
 parser.feed(c.decode(run['page_base64']).decode())
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
 raw=c.decode(supplied[CHAPTER]['base64'])
 needle=b'Perl callable bodies accept'
 assert raw.count(needle)==1
 poisoned=raw.replace(needle,b'Perl callable bodies reject',1)
 override=dict(base64=c.encode(poisoned),sha256=c.sha(poisoned),mode=supplied[CHAPTER]['mode'])
 prose_inputs={**supplied,CHAPTER:override}
 prose_changed=render(prose_inputs)
 comparison=dict(prior='book4.json.gz',same=signature(healthy)==signature(prior['healthy']),prose_red=signature(prose_changed)!=signature(prior['healthy']))

 try:validate(changed,plan)
 except AssertionError as error:control=dict(rejected=True,reason=str(error))
 else:control=dict(rejected=False,reason='')
 c.save('book5.json.gz',dict(context=context,inputs=supplied,plan=plan,public=public,comparison=comparison,prose_override={CHAPTER:override},prose_changed=prose_changed,healthy=healthy,changed=changed,control=control,producer=c.read(c.PREFIX+'book5.py'),observer=c.read(c.PREFIX+'probe.pl'),version=c.run(['mdbook','--version'])))
 assert not c.failures(public,plan),c.failures(public,plan)
 assert comparison['same'] and comparison['prose_red'],comparison
 validate(healthy,plan)
 assert control==dict(rejected=True,reason='indexed-write anchor')
 assert all(c.read(path)==packet for path,packet in supplied.items())
 print('Book:',len(supplied),'complete inputs;',len(plan['cases']),'exact executed examples; actual anchor RED')
if __name__=='__main__':main()
