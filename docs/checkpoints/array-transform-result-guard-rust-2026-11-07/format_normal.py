"""Format the new normal before its first runtime acquisition."""
import gzip
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
normal = Path('rust/linkedspec-runtime/tests/array_transform_result_guard_composition.rs')
assert not (BASE / 'normal-unformatted.rs.gz').exists()
(BASE / 'normal-unformatted.rs.gz').write_bytes(gzip.compress(normal.read_bytes(), mtime=0))
result = subprocess.run(['bash', 'tools/project_data_run.sh', 'rustfmt', '--edition', '2024', str(normal)],
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('normal-format-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'normal-format-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0
print('new normal formatted before first acquisition')
