"""Specialize the prior same-path Dart control with this leaf's actual targets."""
import gzip
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
template = ROOT / 'docs/checkpoints/hash-value-result-guard-dart-2026-11-07/private_control.py'
body = template.read_bytes()
(BASE / 'private-control-template.py.gz').write_bytes(gzip.compress(body, mtime=0))
source = body.decode().replace('hash_value_result_guard', 'array_transform_result_guard')
source = source.replace('HASH_VALUE_DART', 'ARRAY_TRANSFORM_DART')
source = source.replace('a36f5893b6876865895ff653cd8342ed144bf593', '155f5f6444b30319a278a78e53265e4e3adda699')
source = source.replace('==89', '==141').replace('+76 -13:', '+122 -19:').replace('+89:', '+141:')
source = source.replace('actual89', 'actual141')
source = source.replace("BASE/'private_control.py']", "BASE/'private_control.py',BASE/'prepare_private.py',BASE/'private-control-template.py.gz']")
target = BASE / 'private_control.py'
assert not target.exists()
target.write_text(source)
print('Authored same-path old/current Dart inverse for unchanged141 actual cases')
