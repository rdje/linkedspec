"""One finite Lua epoch through published native build and project-data interfaces."""
import gzip,json,os,re,shutil,subprocess,sys,traceback
from pathlib import Path
sys.dont_write_bytecode=True
from proof_io import BASE,ROOT,OWNER,NORMAL,FIXTURE,PROFILE,GRAMMAR,HOSTS,freeze,verify,execute,build_native,artifacts,frames
phase,=sys.argv[1:];assert phase in {'intake','before','after','direct','inverse','restored'}
out=BASE/phase;out.mkdir();private=BASE/'control-owner';is_private=phase in {'inverse','restored'}
try:
    source_paths=[Path(p) for p in subprocess.check_output(['git','ls-files','lua'],text=True).splitlines()]
    source_paths += [NORMAL,FIXTURE,GRAMMAR,Path('tests/fixtures/hash_value_result_guard_cases.json')]
    if PROFILE.exists():source_paths.append(PROFILE)
    prefix=''
    if is_private:
        if phase=='inverse':assert not private.exists();private.mkdir()
        else:assert private.is_dir()
        activation=(BASE/'intake/activation.txt').read_text().strip()
        for p in sorted(set(source_paths)):
            target=private/p;target.parent.mkdir(parents=True,exist_ok=True)
            body=subprocess.check_output(['git','show',activation+':'+str(p)]) if phase=='inverse' and p==OWNER else p.read_bytes()
            target.write_bytes(body);target.chmod(p.stat().st_mode&0o777)
        prefix=str(private)+'/'
    else:activation=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()
    paths=list(source_paths)
    paths += [BASE/p for p in ('prepare.py','capture.py','proof_io.py','freeze_profiles.py','observer.lua','profile-sources.json','cases.json')]
    paths += [Path(p) for p in ('docs/checkpoints/hash-view-result-guard-lua-2026-11-07/observer.lua','lua/test/hash_view_result_guard_composition_test.lua','tests/fixtures/hash_view_result_guard_lua_cases.json','tests/fixtures/hash_view_result_guard_lua_profiles.json','tests/fixtures/value_copy_values.spec','tests/fixtures/value_copy_values.json')]
    paths += [Path('tools')/p for p in ('build_lua_native.sh','run_lua_project_data.sh','project_data_env.sh','project_data_run.sh','run_python_project_data.sh')]
    if (BASE/'baseline-summary.json').exists():paths.append(BASE/'baseline-summary.json')
    if phase=='intake':(out/'cases.json').write_bytes(FIXTURE.read_bytes());paths.append(out/'cases.json')
    if is_private:
        paths += [private/p for p in sorted(set(source_paths))]
        golden_phase='before' if phase=='inverse' else 'after'
        paths += [BASE/golden_phase/host/'normal-stdout.log.gz' for host in HOSTS]
    records=freeze(out,paths);(out/'activation.txt').write_text(activation+'\n')
    for host in HOSTS:
        target=out/host;target.mkdir();(target/'emitted').mkdir();(target/'parsed').mkdir()
        runtime=os.environ.get('LINKEDSPEC_LUA_CMD' if host=='puc' else 'LINKEDSPEC_LUAJIT_CMD','lua' if host=='puc' else 'luajit')
        env=dict(os.environ,LUA_PATH=prefix+'lua/src/?.lua;'+prefix+'lua/src/?/init.lua;;',LUA_CPATH=str(target/'native/?.so')+';;',LINKEDSPEC_LUA_TEST_RUNTIME=runtime,LINKEDSPEC_HASH_VALUE_CAPTURE=str(target),LINKEDSPEC_HASH_VALUE_INPUT_ROOT=prefix)
        native,native_rows=build_native(target,host,env)
        version=execute(target,'version',['bash','tools/project_data_run.sh',runtime,'-v'],env);assert version.returncode==0
        if phase=='intake':args=[str(BASE/'observer.lua'),str(out/'cases.json'),str(target)]
        else:
            tests=[prefix+str(NORMAL)]
            if phase=='direct':tests += ['lua/test/hash_view_result_guard_composition_test.lua','lua/test/constructor_result_composition_test.lua','lua/test/value_copy_test.lua','lua/test/receiver_copy_arity_test.lua']
            args=['-e','; '.join('dofile('+json.dumps(path)+')' for path in tests)]
        result=execute(target,'normal',['bash','tools/project_data_run.sh',runtime,*args],env)
        verify(records);verify(native_rows);artifacts(target)
        rows=frames(result.stdout,'HASH_VALUE_LUA' if phase=='intake' else 'HASH_VALUE_LUA_NORMAL')
        assert all(set(row)=={'native','restored','plan','fresh'} for row in rows.values())
        expected_owner=('@'+prefix+'lua/src/linkedspec/interpreter.lua').encode()
        assert b'HASH_VALUE_LUA_OWNER '+expected_owner+b'\n' in result.stdout
        if is_private:
            expected=gzip.decompress((BASE/golden_phase/host/'normal-stdout.log.gz').read_bytes())
            assert json.dumps(rows,sort_keys=True)==json.dumps(frames(expected),sort_keys=True)
            expected_summary=re.search(rb'HASH_VALUE_LUA_SUMMARY ([0-9]+) checks ([0-9]+) failures',expected)
            actual_summary=re.search(rb'HASH_VALUE_LUA_SUMMARY ([0-9]+) checks ([0-9]+) failures',result.stdout)
            assert expected_summary and actual_summary and expected_summary.groups()==actual_summary.groups()
            assert result.returncode==(1 if int(expected_summary[2]) else 0)
        else:assert result.returncode in ((0,1) if phase=='before' else (0,))
        for p in native_rows:Path(p).unlink()
        native.rmdir()
        print(phase,host,'exit'+str(result.returncode)+'; actual89 frames/native inputs/artifacts/full channels retained',flush=True)
    verify(records)
    if phase=='restored':
        assert set(p for p in private.rglob('*') if p.is_file())=={private/p for p in set(source_paths)}
        shutil.rmtree(private)
    (out/'complete.txt').write_text('Both installed host epochs complete; actual source inputs unchanged.\n')
except BaseException:
    (out/'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(),mtime=0))
    print('epoch failed; inspect retained complete channels/archives and compressed wrapper failure');sys.exit(1)
