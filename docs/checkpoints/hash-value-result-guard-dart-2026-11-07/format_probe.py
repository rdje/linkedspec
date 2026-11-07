"""Format the new observer before any LinkedSpec SDK execution; retain full channels."""
import gzip,json,os,subprocess
from pathlib import Path
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd())
probe=Path('dart/tool/probe_hash_value_results.dart')
assert not (BASE/'probe-before-format.dart.gz').exists()
(BASE/'probe-before-format.dart.gz').write_bytes(gzip.compress(probe.read_bytes(),mtime=0))
command=['bash','../tools/run_dart_project_data.sh','format','tool/probe_hash_value_results.dart']
(BASE/'probe-format-command.json').write_text(json.dumps(dict(cwd='dart',argv=command),indent=2)+'\n')
r=subprocess.run(command,cwd='dart',env=dict(os.environ,TERM='dumb',NO_COLOR='1'),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
for channel in ('stdout','stderr'): (BASE/('probe-format-'+channel+'.log.gz')).write_bytes(gzip.compress(getattr(r,channel),mtime=0))
(BASE/'probe-format-exit.txt').write_text(str(r.returncode)+'\n')
assert r.returncode==0
print('new observer formatted before SDK use')
