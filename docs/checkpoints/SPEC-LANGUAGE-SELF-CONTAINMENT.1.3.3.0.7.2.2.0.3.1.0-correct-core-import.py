"""Retain incomplete initial after capture and correct Core's standalone import root."""
from pathlib import Path
import importlib.util,json,subprocess
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('correct-core-import.py')
spec=importlib.util.spec_from_file_location('handoff_capture',PREFIX+'capture.py')
capture=importlib.util.module_from_spec(spec);spec.loader.exec_module(capture)
manifest=json.loads(Path(PREFIX+'after-inputs.json').read_bytes())
report=json.loads(Path(PREFIX+'after-observations.json').read_bytes());assert not report['complete']
core=ROOT/'perl/LinkedSpec/ActionIR/CanonicalEvents/Core.pm';raw=core.read_bytes()
item=next(e for e in manifest['entries'] if e['path']==str(core.relative_to(ROOT)))
assert item['sha256']==capture.streams.sha(raw)
command=['bash','tools/project_data_run.sh','env','PERL5LIB=','perl','-c',str(core.relative_to(ROOT))]
red=subprocess.run(command,cwd=ROOT,capture_output=True);assert red.returncode!=0 and b"Can't locate LinkedSpec/ActionIR/SourceOrigins.pm" in red.stderr
for suffix in ('inputs.json','observations.json'):
    Path(PREFIX+'after-initial-'+suffix).write_bytes(Path(PREFIX+'after-'+suffix).read_bytes())
Path(PREFIX+'core-import-initial.pm').write_bytes(raw)
old=b'my $canonical_events_dir = File::Basename::dirname($module_dir);'
new=b'my $canonical_events_dir = $module_dir;'
assert raw.count(old)==1
fixed=raw.replace(old,new);core.write_bytes(fixed)
green=subprocess.run(command,cwd=ROOT,capture_output=True);assert green.returncode==0
result={'complete':True,'producer_sha256':capture.streams.sha(Path(__file__).read_bytes()),'original_sha256':capture.streams.sha(raw),'corrected_sha256':capture.streams.sha(fixed),'command':command,'red':{'exit':red.returncode,'stdout':capture.streams.envelope(red.stdout),'stderr':capture.streams.envelope(red.stderr)},'green':{'exit':green.returncode,'stdout':capture.streams.envelope(green.stdout),'stderr':capture.streams.envelope(green.stderr)},'interrupted_capture_log':capture.streams.envelope((ROOT/'.linkedspec-data/logs/private-origin-after.log').read_bytes()),'scope':'Original Core had no import requiring its derived path; the new import exposed one extra dirname traversal. Start from the actual module directory, preserving existing remaining parent steps. Actual standalone no-I/perl syntax rejects before and succeeds after this sole correction. Initial after tree/runs remain incomplete and are not final acceptance; actual producer stays unchanged for a fresh after capture. No upstream/dependency inspection or pin change.'}
Path(PREFIX+'core-import-correction.json').write_text(json.dumps(result,indent=2)+'\n')
task=ROOT/'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md';text=task.read_text();mark='  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0.json`'
text=text.replace(mark,mark+'\n  Import seam correction: The new Core import exposes its existing extra dirname step during direct no-I syntax. Retain exact initial Core, actual RED/GREEN channels and incomplete first after tree/runs/log; stop that obsolete owned capture. Correct only the module-directory starting point and require fresh final after capture; no completed candidate result is inferred from interrupted observations.')
task.write_text(text)
print('Standalone Core RED/GREEN preserved; incomplete after candidate retained.')
