"""Acquire complete command channels for one bounded metadata capture or replay."""
import gzip
import json
from pathlib import Path
import subprocess
import sys
import traceback

BASE=Path(__file__).resolve().parent.relative_to(Path.cwd())
mode=sys.argv[1]
assert mode in ('capture','review')


def main():
    assert not (BASE/(mode+'-exit.txt')).exists(), 'one-shot channel acquisition'
    command=['bash','tools/run_python_project_data.sh',str(BASE/'review.py')]
    if mode=='capture': command.append('--capture')
    (BASE/(mode+'-command.json')).write_text(json.dumps(dict(argv=command,cwd='.'),indent=2)+'\n')
    result=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    for channel in ('stdout','stderr'):
        (BASE/(mode+'-'+channel+'.log.gz')).write_bytes(gzip.compress(getattr(result,channel),mtime=0))
    (BASE/(mode+'-exit.txt')).write_text(str(result.returncode)+'\n')
    assert result.returncode==0, 'full command channels retained'
    parsed=json.loads(result.stdout)
    (BASE/('capture-result.json' if mode=='capture' else 'result.json')).write_bytes(result.stdout)
    assert result.stderr==b''
    print(json.dumps(parsed,sort_keys=True))


try:
    main()
except BaseException:
    (BASE/(mode+'-wrapper-failure.log.gz')).write_bytes(gzip.compress(traceback.format_exc().encode(),mtime=0))
    raise
