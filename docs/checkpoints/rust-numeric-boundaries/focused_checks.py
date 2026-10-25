"""Retain focused formatting and unchanged neutral authority checks."""
import common as c

extra=['rust/linkedspec-core/src/numeric.rs',
    'rust/linkedspec-core/tests/numeric_conversion_contract.rs',
    'rust/linkedspec-runtime/tests/numeric_conversion_contract.rs',
    'rust/linkedspec-runtime/tests/numeric_bridge_contract.rs',
    'tools/check_write_vivification_contract.py','tools/check_signed_array_selector_contract.py']
extra += [file.relative_to(c.ROOT).as_posix() for file in
    (c.ROOT/'tests/numeric-conversion').glob('*') if file.is_file()]
supplied=c.context(extra)
c.save('focused-check-inputs.json.gz',dict(context=supplied))
commands={
    'format':['bash','tools/run_cargo_local.sh','fmt','--manifest-path','rust/Cargo.toml',
        '-p','linkedspec-core','-p','linkedspec-runtime','--','--check'],
    'write':['bash','tools/run_python_project_data.sh','tools/check_write_vivification_contract.py'],
    'signed':['bash','tools/run_python_project_data.sh','tools/check_signed_array_selector_contract.py'],
}
runs={name:c.run(command) for name,command in commands.items()}
stable=c.unchanged(supplied['inputs'])
c.save('focused-check-runs.json.gz',dict(runs=runs,inputs_unchanged=stable))
assert stable and all(run['returncode']==0 for run in runs.values())
print('Focused format/write/signed authority checks PASS; actual source and channels retained.')
