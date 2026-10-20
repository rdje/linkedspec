"""Preserve the actual failed candidate and stop its inner loop shadowing the audit row."""
import gzip
import json
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[2]/'type-numeric-codeblocks'))
import common as c
PREFIX='docs/checkpoints/type-numeric-admission/recurrence/'
AUDIT='tests/language-readiness/verify_objectives.py'


def main():
    before=c.read(AUDIT)
    text=c.decode(before['base64']).decode()
    old='            for row in scalar_numeric_table(source)["hunks"]:\n                fragment = row["after"].encode()\n'
    new='            for numeric_hunk in scalar_numeric_table(source)["hunks"]:\n                fragment = numeric_hunk["after"].encode()\n'
    assert text.count(old)==1
    text=text.replace(old,new,1)
    compile(text,AUDIT,'exec')
    failed=json.loads(gzip.decompress((c.ROOT/(PREFIX+'historical-run.json.gz')).read_bytes()))
    assert failed['run']['returncode']!=0 and b"KeyError: 'historical'" in c.decode(failed['run']['stderr_base64'])
    value=dict(before=before,after=c.encode(text.encode()),producer=c.read(PREFIX+'correct_key.py'),
        failure=c.read(PREFIX+'historical-run.json.gz'),
        scope='Actual current-reader preparation failed after preserving all578 original controls. '
              'The new inner loop had overwritten the outer governance row; keep its own numeric_hunk variable. '
              'No runtime RED or successful new-control count is inferred from the failed attempt.')
    with (c.ROOT/(PREFIX+'key-correction.json.gz')).open('xb') as out:
        out.write(gzip.compress((json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0))
    (c.ROOT/AUDIT).write_text(text)
    print('Numeric control loop preserves outer governance row; actual failed source/run retained')


if __name__=='__main__':
    main()
