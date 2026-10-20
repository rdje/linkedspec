"""Retain each actual current-reader preparation and all changed producer versions."""
import gzip
import json
import re
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[2]/'type-numeric-codeblocks'))
import common as c
PREFIX='docs/checkpoints/type-numeric-admission/recurrence/'


def main():
    assert len(sys.argv)==2 and re.fullmatch('[1-9][0-9]*',sys.argv[1])
    paths=[c.PREFIX+name for name in ('review_numeric_recurrence.py','review_recurrence.py','publish_recurrence.py')]
    paths+=[PREFIX+name for name in ('prior_admission.py','verify_recurrence.py','prepare_review.py')]
    producers={path:c.read(path) for path in paths}
    run=c.run(['python3','-B',c.PREFIX+'review_recurrence.py','--retained'])
    value=dict(producers=producers,run=run,scope='Actual retained-epoch current-reader preparation; no fresh runtime execution is claimed here.')
    raw=(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
    with (c.ROOT/(PREFIX+'review-preparation'+sys.argv[1]+'.json.gz')).open('xb') as out:out.write(gzip.compress(raw,mtime=0))
    print(c.decode(run['stdout_base64']).decode(),end='')
    print(c.decode(run['stderr_base64']).decode(),end='',file=sys.stderr)
    raise SystemExit(run['returncode'])


if __name__=='__main__':
    main()
