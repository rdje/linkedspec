"""Correct only the intended fixture consumer; retain the failed adapter epoch."""
import common as c
paths=['t/callable_codeblock_literal_contract.t',c.PREFIX+'review2.py',c.PREFIX+'prepare_publication2.py']
before={path:c.read(path) for path in paths}
assert all(c.read(path)==image for path,image in c.load('compatibility2.json.gz')['sources'].items())
path=paths[0]
text=(c.ROOT/path).read_text()
plain='my $source = ($case->{functions} // \'\') . "Top: /x/\\n I { $case->{body} }\\n";'
full='my $source = $case->{source} // ($case->{functions} // \'\') . "Top: /x/\\n I { $case->{body} }\\n";'
def replace_in_node(text,heading,old,new):
 start=text.index("subtest '"+heading+"' => sub {")
 end=text.index('\nsubtest ',start+1)
 node=text[start:end]
 assert node.count(old)==1,(heading,node.count(old))
 return text[:start]+node.replace(old,new,1)+text[end:]
text=replace_in_node(text,'with exposes the current scoped value to callable dispatch',full,plain)
text=replace_in_node(text,'indexed writes execute through native and independently emitted public parsers',plain,full)
assert text.count(full)==1
(c.ROOT/path).write_text(text)
path=paths[1]
text=(c.ROOT/path).read_text()
assert text.count('focused7.json.gz')==1
(c.ROOT/path).write_text(text.replace('focused7.json.gz','focused8.json.gz',1))
path=paths[2]
text=(c.ROOT/path).read_text()
for needle,replacement in [
 ("replace('manifest.json.gz','manifest2.json.gz',2)","replace('manifest.json.gz','manifest2.json.gz',3)"),
 ("replace('publication.json','publication2.json',2)","replace('publication.json','publication2.json',3)"),
 ("replace('focused6.json.gz','focused7.json.gz')","replace('focused6.json.gz','focused8.json.gz')")]:
 assert text.count(needle)==1,needle
 text=text.replace(needle,replacement,1)
(c.ROOT/path).write_text(text)
c.save('fixture-adapter-repair.json.gz',dict(before=before,after={path:c.read(path) for path in paths},
 failed_run=c.read(c.PREFIX+'focused7.json.gz'),sources=c.load('compatibility2.json.gz')['sources'],
 producer=c.read(c.PREFIX+'repair_fixture_adapter.py'),
 scope='The wrong with-fixture loop was edited; new full-source cases were interpreted as empty I bodies by the indexed-write fixture consumer. Toolbox source-plan execution was already GREEN. This corrects test plumbing without changing production or weakening values.'))
print('Indexed-write source adapter corrected; unrelated with-fixture edit reverted; fresh proof selects focused8.')
