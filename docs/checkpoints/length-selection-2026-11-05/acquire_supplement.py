"""One-shot supplemental public controls; run from the repository root.

The initial producer remains in before-first-get.tar.gz. This phase additionally
persists each actual emitted module before fresh evaluation. Complete native/
transitive custody and independent-process isolation remain separately owned.
"""
import gzip
import json
from pathlib import Path
import subprocess
import tarfile

HERE = Path(__file__).parent
OUT = HERE / 'supplement'
OUT.mkdir()
(OUT / 'modules').mkdir()
paths = [Path(p) for p in subprocess.check_output(
    ['git', 'ls-files', 'perl', 'specs', 'capability_conformance',
     'tools/project_data_env.sh', 'tools/project_data_run.sh'], text=True).splitlines()]
paths += [HERE / 'probe.pl', HERE / 'supplement.json', Path(__file__)]
with tarfile.open(OUT / 'before-first-get.tar.gz', 'w:gz') as archive:
    for path in paths:
        archive.add(path, arcname=path.as_posix(), recursive=False)
argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
        str(HERE / 'probe.pl'), str(HERE / 'supplement.json'), str(OUT / 'modules')]
(OUT / 'command.json').write_text(json.dumps(argv, indent=2) + '\n')
result = subprocess.run(argv, capture_output=True)
(OUT / 'stdout.json.gz').write_bytes(gzip.compress(result.stdout, mtime=0))
(OUT / 'stderr.log.gz').write_bytes(gzip.compress(result.stderr, mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0, result.stderr.decode()
rows = json.loads(result.stdout)
for row in rows:
    if row.get('module_retained_before_load'):
        assert gzip.decompress(Path(row['module_retained_before_load']).read_bytes()).decode() == row['emitted_before_load']
    print(json.dumps({k: v for k, v in row.items()
                     if k not in ('lowered', 'emitted_before_load', 'body', 'source')}, sort_keys=True))
