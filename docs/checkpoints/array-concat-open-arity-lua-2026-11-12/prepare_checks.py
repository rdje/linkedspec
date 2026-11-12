"""Prepare unused host epoch checker from the accepted finite Lua checker."""
import gzip
from pathlib import Path
import subprocess
BASE=Path(__file__).resolve().parent
ROOT=BASE.parents[2]
old=ROOT/'docs/checkpoints/array-transform-callable-lua-2026-11-12/check_epoch.py'
body=old.read_bytes()
assert body==subprocess.check_output(['git','show','HEAD:'+str(old.relative_to(ROOT))])
(BASE/'check-template.py.gz').write_bytes(gzip.compress(body,mtime=0))
text=body.decode().replace('CALLABLE_TRANSFORM','ARRAY_CONCAT').replace('== 312','== 508').replace('== 624','== 1016').replace('== 281','== 484').replace('== 104','== 80').replace('programs=312','programs=508').replace('supported_targets=28','supported_targets=20').replace('separate_initial_compatibility=3','separate_legacy_operand_compatibility=4').replace('preserved=281','preserved=484').replace('initial_policies_exact=104','initial_policies_exact=80').replace('actual_parsed_module_pairs_exact=312','actual_parsed_module_pairs_exact=508').replace("assert b'take_receiver_hash_guard' in stderr","assert b'function_1_free_hash' in stderr")
compile(text,'check_epoch.py','exec')
(BASE/'check_epoch.py').write_text(text)
print('Prepared own508 full observation/native/artifact epoch checker; SDK unchanged')
