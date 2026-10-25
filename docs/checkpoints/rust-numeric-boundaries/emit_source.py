"""Build and retain the real public source-emitter producer before execution."""
import json
import os
from pathlib import Path
import stat
import common as c

MAIN=r'''
use linkedspec_core::{compiler::compile,validation::validate};
use linkedspec_runtime::{spec_parser::parse_spec_with_user_functions,source_emitter::emit_rust_source_v2};
use serde_json::{Value,json};
fn main() {
    let fixture:Value=serde_json::from_str(&std::fs::read_to_string("tests/numeric-conversion/programs.json").unwrap()).unwrap();
    let cases:Vec<Value>=fixture["cases"].as_array().unwrap().iter().filter(|case|
        case["pointer_width"].as_u64().is_none_or(|width|width==u64::from(usize::BITS))
    ).cloned().collect();
    let mut source=String::new();
    let mut entries=Vec::new();
    for (index,case) in cases.iter().enumerate() {
        let authored=case["source"].as_str().unwrap();
        assert!(authored.starts_with("Top:"));
        let entry=format!("NumericCase{index}");
        source.push_str(&authored.replacen("Top:",&format!("{entry}:"),1));
        source.push('\n');
        entries.push(json!({"id":case["id"],"input":case["input"],"entry":entry}));
    }
    let parsed=parse_spec_with_user_functions(&source).unwrap();
    validate(&parsed).unwrap();
    let compiled=compile(&parsed).unwrap();
    let module=emit_rust_source_v2(&compiled,"numeric-boundaries.spec").unwrap();
    println!("{}",json!({"pointer_width":usize::BITS,"spec":source,"entries":entries,
        "compiled_json":serde_json::to_string(&compiled).unwrap(),"module":module}));
}
'''


def workspace(name):
    assert name.replace('-','').isalnum()
    parent=c.ROOT/'.linkedspec-data/verification'
    for path in (parent.parent,parent):
        metadata=path.lstat()
        assert stat.S_ISDIR(metadata.st_mode) and not path.is_symlink()
        assert metadata.st_dev==c.ROOT.stat().st_dev and not (path/'.git').exists()
        assert path.resolve().is_relative_to(c.ROOT)
    root=parent/name;root.mkdir()
    (root/'src').mkdir()
    return root


def manifest(root,name,core=False):
    lines=['[package]','name = '+json.dumps(name),'version = "0.0.0"',
        'edition = "2024"','','[dependencies]','serde_json = "1"']
    for package in (['linkedspec-core','linkedspec-runtime'] if core else ['linkedspec-runtime']):
        relative=Path(os.path.relpath(c.ROOT/'rust'/package,root)).as_posix()
        lines.append(package+' = { path = '+json.dumps(relative)+' }')
    (root/'Cargo.toml').write_text('\n'.join(lines)+'\n\n[workspace]\n')


def relative(file):
    return file.relative_to(c.ROOT).as_posix()


def context(root):
    extra=['rust/linkedspec-core/src/numeric.rs',
        'rust/linkedspec-core/tests/numeric_conversion_contract.rs',
        'rust/linkedspec-runtime/tests/numeric_conversion_contract.rs',
        'rust/linkedspec-runtime/tests/numeric_bridge_contract.rs',
        'tests/numeric-conversion/cases.json','tests/numeric-conversion/programs.json',
        'tests/numeric-conversion/functions.json']
    extra += [relative(file) for file in root.rglob('*') if file.is_file()]
    return c.context(extra)


def build(root,name,stem):
    # Resolve offline first so the actual lock is retained before compilation.
    supplied=context(root)
    c.save(stem+'-resolver-inputs.json.gz',dict(context=supplied))
    resolve=c.run(['bash','tools/run_cargo_local.sh','generate-lockfile','--offline',
        '--manifest-path',relative(root/'Cargo.toml')])
    c.save(stem+'-resolver-run.json.gz',resolve)
    assert resolve['returncode']==0 and c.unchanged(supplied['inputs'])
    supplied=context(root)
    c.save(stem+'-inputs.json.gz',dict(context=supplied,
        scope='Whole current first-party Rust/owned producer closure, actual standalone '
            'manifest/source/includes and resolved lock before the locked offline build. '
            'Installed SDK/OS/prepared published RGX products are read-only prerequisites.'))
    build=c.run(['bash','tools/run_cargo_local.sh','build','--offline','--locked',
        '--manifest-path',relative(root/'Cargo.toml'),'--bin',name,'--message-format=json'])
    c.save(stem+'-build.json.gz',build)
    assert build['returncode']==0,'actual build channels retained'
    files=[]
    for line in c.decode(build['stdout_base64']).splitlines():
        item=json.loads(line)
        if item.get('reason')=='compiler-artifact' and item.get('executable') \
                and item['target']['name']==name:files.append(Path(item['executable']))
    assert len(files)==1
    file=files[0];path=relative(file);artifact=c.archive(file,stem)
    c.save(stem+'-binary.json',dict(path=path,artifact=artifact))
    assert c.unchanged(supplied['inputs'])
    return path,artifact,supplied


def execute(path,artifact,supplied,stem):
    run=c.run(['./'+path])
    stable=c.identity(path)=={key:artifact[key] for key in ('sha256','mode')}
    inputs_stable=c.unchanged(supplied['inputs'])
    c.save(stem+'-run.json.gz',dict(run=run,executable_unchanged=stable,
        inputs_unchanged=inputs_stable))
    assert run['returncode']==0 and stable and inputs_stable
    return run


def main():
    root=workspace('numeric55-emission-producer')
    name='linkedspec-numeric-emission-producer'
    manifest(root,name,core=True)
    (root/'src/main.rs').write_text(MAIN)
    path,artifact,supplied=build(root,name,'emission-producer')
    run=execute(path,artifact,supplied,'emission-producer')
    result=json.loads(c.decode(run['stdout_base64']))
    assert result['pointer_width'] in (32,64)
    assert len(result['entries'])==len({row['id'] for row in result['entries']})
    c.save('emission-result.json.gz',result)
    print('Actual public emitter producer retained/executed;',len(result['entries']),
        'merged entries and complete generated source retained.',flush=True)


if __name__ == '__main__':
    main()
