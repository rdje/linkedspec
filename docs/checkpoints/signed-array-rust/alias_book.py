"""Preserve the existing public fragment and check actual rendered aliases."""
import copy
from html.parser import HTMLParser
import common as c
import book as b

OLD='signed-array-selectors-in-perl'
NEW='signed-array-selectors-in-perl-and-rust'


class Ids(HTMLParser):
    def __init__(self):
        super().__init__();self.ids=[]
    def handle_starttag(self,tag,attrs):
        self.ids += [value for name,value in attrs if name=='id']


def validate(run,packets):
    b.validate(run,packets)
    parser=Ids();parser.feed(c.decode(run['page_base64']).decode())
    assert parser.ids.count(OLD)==1,'old public fragment'
    assert parser.ids.count(NEW)==1,'new signed heading fragment'


def check():
    supplied=c.load('alias-book-inputs.json.gz');runs=c.load('alias-book-runs.json.gz')
    for path,packet in supplied['updated'].items():
        assert c.sha(c.decode(packet['base64']))==packet['sha256'],path
    validate(runs['healthy'],supplied['updated'])
    for run in [c.load('book-runs.json.gz')['healthy'],runs['fault']]:
        assert run['returncode']==0
        try:validate(run,supplied['updated'])
        except AssertionError as error:assert str(error)=='old public fragment'
        else:raise AssertionError('missing/changed public alias admitted')
    return dict(old_fragment=OLD,new_fragment=NEW,denials=2,book_inputs=len(supplied['updated']))


def main():
    packets=b.inputs();assert packets==c.load('book-inputs.json.gz')['inputs']
    raw=c.decode(packets[b.FLOW]['base64'])
    heading=b'#### Signed array selectors in Perl and Rust'
    alias=('<a id="'+OLD+'"></a>\n\n').encode()
    assert raw.count(heading)==1 and alias not in raw
    updated=copy.deepcopy(packets)
    changed=raw.replace(heading,alias+heading,1)
    updated[b.FLOW].update(base64=c.encode(changed),sha256=c.sha(changed))
    c.write_new('alias-book-inputs.json.gz',dict(producer=c.read(c.PREFIX+'alias_book.py'),
        original=packets,updated=updated,
        scope='The original successful full-input render lacks the old public fragment after the heading rename. Add an explicit backwards-compatible alias; two extra source lines fit the unchanged book budget. Retain the complete current source/config/include inputs and actual rendered controls.'))
    c.source(b.FLOW).write_bytes(changed)
    healthy=b.render(updated);validate(healthy,updated)
    faulty=copy.deepcopy(updated)
    wrong=changed.replace(alias,alias.replace(OLD.encode(),b'changed-public-fragment'),1)
    faulty[b.FLOW].update(base64=c.encode(wrong),sha256=c.sha(wrong))
    fault=b.render(faulty);assert fault['returncode']==0
    try:validate(fault,updated)
    except AssertionError as error:assert str(error)=='old public fragment'
    else:raise AssertionError('changed alias admitted')
    c.write_new('alias-book-runs.json.gz',dict(healthy=healthy,fault=fault,fault_input=faulty[b.FLOW],
        current_source_unchanged=c.read(b.FLOW)==updated[b.FLOW]))
    assert c.read(b.FLOW)==updated[b.FLOW]
    print('Public book anchors PASS: old/new present once; original missing and actual changed alias reject.',flush=True)


if __name__=='__main__':main()
