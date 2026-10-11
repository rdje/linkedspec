"""Retain the exact scanner refusal and all flagged diagnostic inputs once."""
import base64
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
TARGET = HERE / 'scanner-before.json.gz'
CHECKER = 'tools/check_executable_aggregate_selector_sources.py'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert not TARGET.exists(), 'one-shot scanner boundary'
spec = importlib.util.spec_from_file_location('scan', ROOT / CHECKER)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
err = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0/book-selector-final.stderr.log').read_bytes()
paths = sorted({line.split(':', 1)[0] for line in err.decode().splitlines() if line.startswith(('docs/checkpoints/', 't/'))})
positive, classified = module.scan_files(paths)
assert len(paths) == 17 and len(positive) == 27 and classified == 0
packet = {'producer_sha256': digest(Path(__file__).read_bytes()),
          'scanner_base64': base64.b64encode((ROOT / CHECKER).read_bytes()).decode(),
          'inputs': {p: {'sha256': digest((ROOT / p).read_bytes()),
                         'data': base64.b64encode((ROOT / p).read_bytes()).decode()} for p in paths},
          'positive': positive, 'classified': classified,
          'stderr_base64': base64.b64encode(err).decode(), 'actual_exit_code': 1,
          'scope': 'Exact original scanner and17 flagged file bytes/27 lines; complete redirected failed composed-check stderr. Exit1 transcribed from tool completion, not an original transport envelope. Initial inline capture incorrectly expected28 lines and refused before writing; actual scan derives27. Later proof rederives every classification.'}
TARGET.write_bytes(gzip.compress((json.dumps(packet, indent=2) + '\n').encode(), mtime=0))
print('Original scanner refusal retained:', len(paths), 'files;', len(positive), 'lines')
