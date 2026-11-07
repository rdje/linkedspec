"""Choose the exact old/current source at one controlled private load path."""
import gzip
from pathlib import Path
import sys

BASE = Path(__file__).resolve().parent
assert len(sys.argv) == 2 and sys.argv[1] in ('old', 'current')
body = gzip.decompress((BASE / 'owner-before.pm.gz').read_bytes()) if sys.argv[1] == 'old' else Path('perl/LinkedSpec/ActionIR/MethodLowering.pm').read_bytes()
(BASE / 'control-owner.pm').write_bytes(body)
print('Selected exact private source image:', sys.argv[1])
