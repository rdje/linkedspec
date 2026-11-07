"""Retain the candidate authoring image and format it before SDK execution."""
import gzip,json,os,subprocess
from pathlib import Path
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd())
paths={'owner':Path('dart/lib/src/runtime/interpreter.dart'),'normal':Path('dart/test/hash_value_result_guard_composition_test.dart'),'probe':Path('dart/tool/probe_hash_value_results.dart')}
for tag,path in paths.items():
    output=BASE/('candidate-'+tag+'-before-format.dart.gz')
    assert not output.exists()
    output.write_bytes(gzip.compress(path.read_bytes(),mtime=0))
command=['bash','../tools/run_dart_project_data.sh','format',*[str(p.relative_to('dart')) for p in paths.values()]]
(BASE/'candidate-format-command.json').write_text(json.dumps(dict(cwd='dart',argv=command),indent=2)+'\n')
r=subprocess.run(command,cwd='dart',env=dict(os.environ,TERM='dumb',NO_COLOR='1'),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
for channel in ('stdout','stderr'): (BASE/('candidate-format-'+channel+'.log.gz')).write_bytes(gzip.compress(getattr(r,channel),mtime=0))
(BASE/'candidate-format-exit.txt').write_text(str(r.returncode)+'\n')
assert r.returncode==0
for tag in ('normal','probe'):
    assert paths[tag].read_bytes()==gzip.decompress((BASE/('candidate-'+tag+'-before-format.dart.gz')).read_bytes())
print('candidate formatted before SDK use; unchanged normal/probe bytes')
