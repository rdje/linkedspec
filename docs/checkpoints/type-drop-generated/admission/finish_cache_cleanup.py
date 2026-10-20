"""Delete exactly the preserved own cache, then prove ignore and zero residue."""
import subprocess
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[1]))
import common as c

saved=c.load('admission/cache-cleanup-inputs.json.gz')
path=c.PREFIX+'__pycache__/common.cpython-314.pyc'
assert c.read(path)==saved['cache']
assert not subprocess.check_output(['git','ls-files','--stage','--',path],cwd=c.ROOT)
target=c.ROOT/path
target.unlink()
if not list(target.parent.iterdir()):target.parent.rmdir()
ignored=c.run(['git','check-ignore','--no-index','-v','--',path])
source=c.run(['git','check-ignore','--no-index','-v','--',c.PREFIX+'common.py'])
assert ignored['returncode']==0 and b'docs/checkpoints/**/__pycache__/' in c.decode(ignored['stdout_base64'])
assert source['returncode']==1 and not c.decode(source['stdout_base64']) and not c.decode(source['stderr_base64'])
assert not target.exists() and not subprocess.check_output(['git','ls-files','--stage','--',path],cwd=c.ROOT)
for name,raw in saved['after'].items():assert (c.ROOT/name).read_bytes()==c.decode(raw)
c.write_new('admission/cache-cleanup.json.gz',dict(ignored=ignored,source=source,residue_absent=True,
    staged_cache_absent=True,source_kept=c.read(c.PREFIX+'common.py'),
    producer=c.read(c.PREFIX+'admission/finish_cache_cleanup.py'),
    scope='Only the exact already-preserved generated cache and its empty directory were removed. '
          'Original10308 staged images remain recoverable from retained bytes; final source is kept '
          'and unignored. No other cache or repository data was touched.'))
print('Exact generated cache removed; source unignored, checkpoint cache ignored, stage/filesystem residue absent')
