"""Freeze actual Dart source/error policies; prepare and format the ordinary normal."""
import gzip
import json
import os
from pathlib import Path
import subprocess
import traceback

BASE=Path(__file__).resolve().parent.relative_to(Path.cwd())
PROFILE=Path('tests/fixtures/hash_value_result_guard_dart_profiles.json')
NORMAL=Path('dart/test/hash_value_result_guard_composition_test.dart')


def frames(tag,prefix):
    rows={}
    for line in gzip.decompress((BASE/'intake'/(tag+'-stdout.log.gz')).read_bytes()).decode().splitlines():
        if line.startswith(prefix+' '):
            _,key,value=line.split(' ',2)
            assert key not in rows
            rows[key]=json.loads(value)
    return rows


def main():
    cases=json.loads((BASE/'cases.json').read_bytes())
    native=frames('native','HASH_VALUE_DART');fresh=frames('fresh','HASH_VALUE_DART_FRESH')
    assert list(native)==list(fresh)==[case['id'] for case in cases]
    profiles={}
    for case in cases:
        key=case['id']
        assert set(native[key])=={'native','restored','plan'}
        assert native[key]['native']==native[key]['restored']
        assert native[key]['plan']==fresh[key]
        if case.get('expected_error'):
            assert all(case['expected_error'] in row['error'] for row in [*native[key].values(),fresh[key]])
            assert native[key]['native']['class']=='RuntimeInterpreterException'
            assert native[key]['plan']['class']=='GeneratedSourceException'
        else: assert all(row==native[key]['native'] for row in [*native[key].values(),fresh[key]])
        if case.get('profile_only') or case.get('expected_error'):
            profiles[key]=dict(source=case['source'],input=case['input'],profile_only=bool(case.get('profile_only')),**native[key],fresh=fresh[key])
    assert len(profiles)==65 and not PROFILE.exists() and not NORMAL.exists()
    PROFILE.write_text(json.dumps(profiles,indent=2,sort_keys=True)+'\n')
    source=Path('dart/test/hash_view_result_guard_composition_test.dart').read_text()
    source=source.replace('TYPE-REFERENCE-BOOK.1.2.23.3.76.3','TYPE-REFERENCE-BOOK.1.2.23.3.77.3').replace('Hash-view','pure Hash-helper').replace('HASH_VIEW_DART','HASH_VALUE_DART').replace('hash_view_result_guard','hash_value_result_guard').replace('hash-view-result-guard','hash-value-result-guard')
    NORMAL.write_text(source)
    (BASE/'normal-before-format.dart.gz').write_bytes(gzip.compress(NORMAL.read_bytes(),mtime=0))
    command=['bash','../tools/run_dart_project_data.sh','format','test/hash_value_result_guard_composition_test.dart']
    (BASE/'normal-format-command.json').write_text(json.dumps(dict(cwd='dart',argv=command),indent=2)+'\n')
    result=subprocess.run(command,cwd='dart',env=dict(os.environ,TERM='dumb',NO_COLOR='1'),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    for channel in ('stdout','stderr'): (BASE/('normal-format-'+channel+'.log.gz')).write_bytes(gzip.compress(getattr(result,channel),mtime=0))
    (BASE/'normal-format-exit.txt').write_text(str(result.returncode)+'\n')
    assert result.returncode==0
    print('Dart65 actual own profiles frozen; unchanged89 ordinary normal formatted')


try: main()
except BaseException:
    (BASE/'profile-wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(),mtime=0))
    raise
