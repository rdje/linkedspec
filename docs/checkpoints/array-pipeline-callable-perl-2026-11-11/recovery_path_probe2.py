"""Controlled failure/import probe; reads data but never executes the SDK."""
import gzip
import json
from pathlib import Path
import subprocess
import sys
import sysconfig

assert sys.argv[1:] in (['fail'], ['inspect'])


def audit(event, args):
    if event != 'import' or not args or args[0] != 'inspect':
        return
    stack = []
    frame = sys._getframe().f_back
    while frame is not None:
        stack.append(dict(module=frame.f_globals.get('__name__'), function=frame.f_code.co_name,
            line=frame.f_lineno, file=frame.f_code.co_filename))
        frame = frame.f_back
    print('INSPECT_IMPORT_STACK ' + json.dumps(stack), flush=True)


sys.addaudithook(audit)
if sys.argv[1:] == ['fail']:
    raise AssertionError('controlled exception formatter probe; no SDK operation')
import inspect

result = dict(safe_path=sys.flags.safe_path,
    inspect_is_stdlib=Path(inspect.__file__).resolve().parent == Path(sysconfig.get_path('stdlib')).resolve(),
    inspect_has_signature=hasattr(inspect, 'signature'))
print('RECOVERY_PATH ' + json.dumps(result), flush=True)
assert result['inspect_is_stdlib'] and result['inspect_has_signature'], 'checkpoint inspect.py shadows the standard library'
