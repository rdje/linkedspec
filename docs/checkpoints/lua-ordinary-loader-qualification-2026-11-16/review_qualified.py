"""Recover the original Lua ledger with one explicit EOF-only landing normalization."""
import argparse
import contextlib
import gzip
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import stat
import sys

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())


def main():
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--current',action='store_true'); args=parser.parse_args()
    spec=importlib.util.spec_from_file_location('normalized_lua_reader',BASE/'review.py')
    module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    sources, identities=module.recover(); record=json.loads((BASE/'reader-normalization.json').read_bytes())
    name=str(BASE/'review.py'); original=sources[name]; current=Path(name).read_bytes()
    assert record['path']==name and record['mode']==identities[name]['mode']==stat.S_IMODE(Path(name).stat().st_mode)
    assert current==original.rstrip(b'\n')+b'\n' and current!=original, 'exact EOF-only normalization'
    for label,body in [('original',original),('normalized',current)]:
        assert record[label]==dict(bytes=len(body),sha256=hashlib.sha256(body).hexdigest())
    red=json.loads((BASE/'whitespace-red-command.json').read_bytes())
    assert red['argv']==['git','diff','--cached','--check'] and red['exit']!=0
    assert b'review.py:252: new blank line at EOF.' in gzip.decompress((BASE/'whitespace-red-stdout.gz').read_bytes())
    assert gzip.decompress((BASE/'whitespace-red-stderr.gz').read_bytes())==b''
    old_argv=sys.argv; sys.argv=[name]; output=io.StringIO()
    try:
        with contextlib.redirect_stdout(output): module.main()
    finally: sys.argv=old_argv
    result=json.loads(output.getvalue())
    if args.current:
        for path,row in identities.items():
            file=Path(path); assert file.is_file() and not file.is_symlink()
            expected=current if path==name else sources[path]
            assert file.read_bytes()==expected and stat.S_IMODE(file.stat().st_mode)==row['mode'], 'qualified current input:'+path
        result['current_inputs']=len(identities)
    result['reader_normalization']='one EOF LF removed; original image/result retained; all other input bodies/modes exact'
    print(json.dumps(result,sort_keys=True))


if __name__=='__main__':main()
