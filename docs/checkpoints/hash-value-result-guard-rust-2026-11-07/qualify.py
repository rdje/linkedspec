"""Prepare a separate prospective producer after the omitted-help control failure."""
from pathlib import Path
BASE=Path(__file__).resolve().parent
source=(BASE/'capture.py').read_text()
def replace(old,new):
    global source
    assert source.count(old)==1,old
    source=source.replace(old,new)
replace('import os\n','import os\nimport re\n')
replace("assert phase in ('intake', 'after-intake', 'normal-before', 'normal-after', 'direct', 'format')","assert phase in ('qualified-old','qualified-fixed','qualified-direct','qualified-format')")
replace('custody = []','''custody = []
CONTROL=BASE/'control-owner'
OWNER=Path('rust/linkedspec-runtime/src/engine.rs')
HELP=Path('cli_conformance/cases/help/stdout.txt')
ACTIVATION='4eeb2de5dbe3c6a602bd756a41eb51c0b457692d'
SDK=CONTROL/'rust' if mode=='routes' else Path('rust')''')
replace("    paths += [Path('specs')/name for name in ('spec.spec','user_function_definition.spec','pplugin.spec')]","""    paths += [Path('specs')/name for name in ('spec.spec','user_function_definition.spec','pplugin.spec')]
    paths += [HELP]
    assert HELP.read_bytes()==subprocess.check_output(['git','show',ACTIVATION+':'+str(HELP)])
    if mode=='routes':
        assert CONTROL.is_dir() and not CONTROL.is_symlink()
        if phase=='qualified-old':
            prior=json.loads((BASE/'private-restored/input-identities.json').read_bytes())
        else:
            prior=json.loads((BASE/'qualified-old/custody.json').read_bytes())[0]['files']
        for name,row in prior.items():
            if name.startswith(str(CONTROL)+'/'):
                path=Path(name)
                assert hashlib.sha256(path.read_bytes()).hexdigest()==row['sha256']
                assert path.stat().st_mode & 0o777==row['mode']
        if phase=='qualified-old':
            (CONTROL/HELP).parent.mkdir(parents=True)
            shutil.copy2(HELP,CONTROL/HELP)
        image=subprocess.check_output(['git','show',ACTIVATION+':'+str(OWNER)]) if phase=='qualified-old' else OWNER.read_bytes()
        (CONTROL/OWNER).write_bytes(image)
        paths += [p for p in CONTROL.rglob('*') if p.is_file()]
""")
replace("dependency = 'linkedspec-core = { path = \"../../../../../rust/linkedspec-core\" }\\n' if directory == native else ''","""core=os.path.relpath(ROOT/SDK/'linkedspec-core',ROOT/directory)
            runtime=os.path.relpath(ROOT/SDK/'linkedspec-runtime',ROOT/directory)
            dependency = 'linkedspec-core = { path = "'+core+'" }\\n' if directory == native else ''""")
replace("'linkedspec-runtime = { path = \"../../../../../rust/linkedspec-runtime\" }\\nserde_json = \"1\"\\n'","'linkedspec-runtime = { path = \"'+runtime+'\" }\\nserde_json = \"1\"\\n'")
replace("        verify()\n        for directory in (native,fresh):","""        command=['test','--manifest-path',str(SDK/'Cargo.toml'),'--locked','--offline','-j','1','-p','linkedspec-runtime','--test','hash_value_result_guard_composition','--','--nocapture','--test-threads=1']
        cargo('normal',command,(101,) if phase=='qualified-old' else (0,))
        stdout=gzip.decompress((OUT/'normal-stdout.log.gz').read_bytes()).decode()
        stderr=gzip.decompress((OUT/'normal-stderr.log.gz').read_bytes()).decode()
        frames=[line for line in stderr.splitlines() if line.startswith('HASH_VALUE_RUST_NORMAL ')]
        assert len(frames)==89 and len({line.split(' ',2)[1] for line in frames})==89
        expected='76 passed; 13 failed' if phase=='qualified-old' else '89 passed; 0 failed'
        assert expected in stdout and '0 ignored; 0 measured; 0 filtered out' in stdout
        verify()
        for directory in (native,fresh):""")
replace("            shutil.rmtree(directory)\n    elif mode == 'test':","""            shutil.rmtree(directory)
        if phase=='qualified-fixed':
            assert CONTROL.parent==BASE and not CONTROL.is_symlink()
            shutil.rmtree(CONTROL)
            assert not CONTROL.exists()
    elif mode == 'test':""")
replace("if phase == 'direct' else", "if phase == 'qualified-direct' else")
replace("(0,101) if phase=='normal-before' else (0,)","(0,)")
output=BASE/'capture_qualified.py'
assert not output.exists()
output.write_text(source)
print('Separate qualified writer prepared; original producers/epochs unchanged')
