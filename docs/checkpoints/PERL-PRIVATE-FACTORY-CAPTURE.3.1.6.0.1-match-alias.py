"""Retain a project-independent Perl oracle for match-argument flag versus writable behavior."""
import base64
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-'
PROBE='t/perl_match_alias_writability_probe.pl'
target=ROOT/(PREFIX+'match-alias.json')
assert not target.exists(), 'one-shot oracle already retained'
raw=(ROOT/PROBE).read_bytes()
digest=lambda value: hashlib.sha256(value).hexdigest()
with tempfile.TemporaryDirectory(prefix='perl-match-alias-',dir=os.environ['TMPDIR']) as temporary:
    directory=Path(temporary)
    assert directory.stat().st_dev==ROOT.stat().st_dev
    probe=directory/PROBE
    probe.parent.mkdir(parents=True)
    probe.write_bytes(raw)
    command=['perl',PROBE]
    result=subprocess.run(command,cwd=directory,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=False)
    row={'producer_sha256':digest(Path(__file__).read_bytes()),'inputs':{PROBE:digest(raw)},
         'command':command,'returncode':result.returncode,
         'stdout_base64':base64.b64encode(result.stdout).decode(),
         'stderr_base64':base64.b64encode(result.stderr).decode(),
         'unchanged':probe.read_bytes()==raw}
    target.write_text(json.dumps(row,indent=2)+'\n')
    assert result.returncode==0 and not result.stderr and row['unchanged']
    observed=json.loads(result.stdout)
    by_name={entry['name']:entry for entry in observed['rows']}
    assert list(by_name)==['lexical','literal','match','copied-match']
    assert [entry['readonly_flag'] for entry in observed['rows']]==[0,1,0,0]
    assert [entry['actual_slot'] for entry in observed['rows']]==[1,0,1,1]
    for name in ('lexical','copied-match'):
        assert by_name[name]['after']=='meta!' and by_name[name]['result']=='completed' and 'error' not in by_name[name]
    for name in ('literal','match'):
        assert 'Modification of a read-only value attempted' in by_name[name]['error']
        assert 'result' not in by_name[name] and 'after' not in by_name[name]
    print('Pure Perl match alias oracle PASS: flag0 retains actual match slot and rejects writes; copied slot accepts writes')
