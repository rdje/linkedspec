"""Verify approved contract edits, exact prose retention and actual public examples."""
import base64
import gzip
import hashlib
from html.parser import HTMLParser
import json
from pathlib import Path
import re

PREFIX=Path(__file__).parent


def decode(row):
    raw=base64.b64decode(row['base64'],validate=True)
    assert hashlib.sha256(raw).hexdigest()==row['sha256'],'book packet identity'
    return raw.decode()


def normal(text):
    return re.sub(r'\s+',' ',text).strip()


def edited(before,edits):
    text=normal(before.split('### Current document-pressure restoration')[0])
    for edit in edits:
        assert set(edit)=={'reason','before','after'} and edit['reason']
        assert text.count(edit['before'])==1,'approved edit input missing/duplicated'
        text=text.replace(edit['before'],edit['after'],1)
    return text


def verify_prose(before,after,edits):
    expected=edited(before,edits)
    actual=normal(after.split('### Current document-pressure restoration')[0])
    assert expected==actual,'unreviewed book word/token change'


class Visible(HTMLParser):
    def __init__(self):
        super().__init__();self.parts=[]
    def handle_data(self,data):self.parts.append(data)


def review():
    saved=json.loads(gzip.decompress((PREFIX/'book-inputs.json.gz').read_bytes()))
    approval=json.loads((PREFIX/'book-edits.json').read_bytes())
    assert approval['schema_version']==1 and set(saved['books'])==set(approval['books'])
    for name,book in saved['books'].items():
        before,after,html=[decode(book[key]) for key in ('before','after','rendered')]
        verify_prose(before,after,approval['books'][name])
        try:verify_prose(before,'UNREVIEWED_LOSS '+after,approval['books'][name])
        except AssertionError:pass
        else:raise AssertionError('unreviewed book change admitted')
        visible=Visible();visible.feed(html);text=normal(''.join(visible.parts))
        markers=('Current document-pressure restoration','bounded ledger records exact paths','Closed task narrative','content-addressed pages') if name.endswith('local-ci-and-regression.md') else ('--catalog-json','exact query archives','task-owned maintained scope')
        for marker in markers:assert marker in text,'contract guidance did not render: '+marker
    for row in saved['producers'].values():decode(row)
    commands=json.loads(gzip.decompress((PREFIX/'book-command-intake.json.gz').read_bytes()))
    assert commands['red']['returncode']!=0 and 'four decimal digits' in decode(commands['red']['stderr'])
    assert commands['green']['args'][-1]=='4932'
    assert decode(commands['green']['stdout'])==decode(commands['expected_segment'])
    for key in ('green','whole_history','historical_node','current_part','live_status_existing'):
        assert commands[key]['returncode']==0 and not decode(commands[key]['stderr'])
        assert decode(commands[key]['stdout'])
    for row in commands['producers'].values():decode(row)
    reconstruction=json.loads(gzip.decompress((PREFIX/'reconstruction-example.json.gz').read_bytes()))
    for run in reconstruction.values():
        for field in ('code','stdout','stderr'):decode(run[field])
    assert reconstruction['before']['returncode']!=0 and "KeyError: 'source_commit'" in decode(reconstruction['before']['stderr'])
    assert reconstruction['after']['returncode']==0 and not decode(reconstruction['after']['stderr'])
    return 'approved current-contract edits only; remaining Markdown words/tokens retained; rendered guidance and actual retrieval/reconstruction examples PASS'

if __name__=='__main__':print(review())
