"""Record the recurrence in its existing canonical fact without increasing its bytes."""
import re
import common as c

def main():
    path='docs/knowledge/selected-consumer-proof-input-closure-gap.md'
    before=c.read(path)
    old=c.decode(before['base64']).decode()
    assert path not in c.load('publication2-preserved.json.gz')['inputs']
    assert path not in c.load('book-inputs.json.gz')['inputs']
    text=old.replace('date: 2026-10-09','date: 2026-10-22',1)
    text=text.replace('  - "who owns the selected consumer and book proof input closure repair"','  - "who owns the selected consumer and book proof input closure repair"\n  - "why did a scoped runtime claim miss checkpoint fixtures"',1)
    text=re.sub(r'^evidence: .*$', 'evidence: "Original sources/streams remain; finite repairs and pipeline11 recurrence retain complete epochs."',text,count=1,flags=re.M)
    text=re.sub(r'^reverify: .*$', 'reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-registered-array-pipelines/publish4.py; historical boundaries remain in the body."',text,count=1,flags=re.M)
    text+='\nOctober22 pipeline11 preserves whole unpublished714/actual readonly0 before\nrepairing the same live-watchset gap. Its conservative regular-file closure uses\nthe complete measured epoch and actual fixture omission/bypass/restoration. No\nminimal input graph or wider historical-audit closure is inferred.\n'
    old_questions=re.findall(r'^  - "(.*)"$',old,re.M)
    new_questions=re.findall(r'^  - "(.*)"$',text,re.M)
    assert set(old_questions)<=set(new_questions) and len(new_questions)==len(old_questions)+1
    assert len(text.encode())<=len(old.encode()),(len(text.encode()),len(old.encode()))
    c.write_new('knowledge-closure-before.json.gz',dict(path=path,before=before,after=text,
        producer=c.read(c.PREFIX+'knowledge4.py'),old_questions=old_questions,new_questions=new_questions,
        scope='Existing canonical input-closure fact and its entire old body remain; only current header/retrieval and a bounded dated recurrence change. Complete original header/source is retained here. No increased document allowance.'))
    c.source(path).write_text(text)
    print('Canonical closure fact updated; original body/questions retained; bytes delta',len(text.encode())-len(old.encode()))

if __name__=='__main__':main()
