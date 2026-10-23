"""One-shot permanent plan extension from the exact retained failing public plan."""
import gzip,json
import common as c
path='tests/numeric-codeblocks/indexed-writes.json'
before=c.read(path)
plan=json.loads(c.decode(before['base64']))
assert len(plan['cases'])==74
image=c.load('rejected-canonical1.json.gz')['toolbox_before']
raw=c.decode(image['base64'])
assert c.sha(raw)==image['sha256']
life=json.loads(gzip.decompress(raw))
added=[dict(case,id='compiled-assignment/'+case['id']) for case in life['plan']['cases']]
for name,literal,expected in [('zero','0',0),('null','undef',None),
 ('array','[1,{"a":"A"}]',[1,{'a':'A'}]),('harray','{"a":[1]}',{'a':[1]})]:
 added.append(dict(id='compiled-assignment/lifecycle-'+name,
  source='Top::\n /x/ I { value = '+literal+' } LX { return(value) }\n',expected=expected))
assert not set(case['id'] for case in plan['cases'])&set(case['id'] for case in added)
plan['cases']+=added
(c.ROOT/path).write_text(json.dumps(plan,indent=2,ensure_ascii=False)+'\n')
old=c.read(c.PREFIX+'probe.pl')
source=c.decode(old['base64']).decode()
needle='    foreach my $route (qw(descriptor native generated)) {\n'
assert source.count(needle)==1
legacy=c.PREFIX+'probe_legacy_regex.pl'
with (c.ROOT/legacy).open('x') as stream:
 stream.write(source.replace(needle,needle+"        # Raw host regex controls explicitly supply Perl's default subject.\n        local $_ = $case->{input} // 'x';\n"))
c.save('compatibility-fixture-extension.json.gz',dict(before=before,after=c.read(path),added=added,
 retained_plan_image=image,original_probe=old,legacy_probe=c.read(legacy),
 producer=c.read(c.PREFIX+'extend_compatibility.py')))
print('Added',len(added),'permanent public compatibility cases;',len(plan['cases']),'total.')
