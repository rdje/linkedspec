"""Execute exact authored examples and inspect a complete supplied mdBook render."""
import html,json,os,pathlib,re,subprocess,tempfile
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
def main():
 plan=c.load('book-cases2.json')
 text=(c.ROOT/CHAPTER).read_text()
 section=re.split(r'\n#{1,3} ',text.split(HEADING+'\n',1)[1],maxsplit=1)[0]
 bodies=re.findall(r'^```text\n(.*?)^```\s*$',section,re.M|re.S)
 assert bodies==[case['source'] if 'source' in case else case['body'] for case in plan['cases']]
 context=c.epoch()
 supplied=inputs();public=c.observe(plan)
 healthy=render(supplied);changed=render(supplied,True)
 try:validate(changed,plan)
 except AssertionError as error:control=dict(rejected=True,reason=str(error))
 else:control=dict(rejected=False,reason='')
 c.save('book3.json.gz',dict(context=context,inputs=supplied,plan=plan,public=public,healthy=healthy,changed=changed,control=control,producer=c.read(c.PREFIX+'book3.py'),observer=c.read(c.PREFIX+'probe.pl'),version=c.run(['mdbook','--version'])))
 assert not c.failures(public,plan),c.failures(public,plan)
 validate(healthy,plan)
 assert control==dict(rejected=True,reason='indexed-write anchor')
 assert all(c.read(path)==packet for path,packet in supplied.items())
 print('Book:',len(supplied),'complete inputs;',len(plan['cases']),'exact executed examples; actual anchor RED')
if __name__=='__main__':main()
