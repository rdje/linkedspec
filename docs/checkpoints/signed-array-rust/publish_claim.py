"""Write one bounded dated claim after actual publication/input controls pass."""
import json
import common as c
import publish


def main():
    result=publish.check()
    controls=c.load('input-controls.json.gz')
    assert controls['inputs_restored'] and set(controls['cases'])=={'missing','bytes','mode','required-omission'}
    for item in controls['cases'].values():
        assert item['red']['returncode']!=0 and item['bypass']['returncode']==0
        assert item['restored_rejection']['returncode']!=0
    files=sorted(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file())
    record=dict(version=1,owner=c.OWNER,claims=[dict(
        name='rust-signed-array-selectors',
        statement='Rust native, reconstructed and generated execution selects existing tail-relative array positions and applies signed writes after expression effects, retaining exact typed underflow diagnostics and existing state boundaries.',
        scope='Dated64-bit Rust source/executable epochs on the declared activation base. Original40-case baseline and corrected137-case target population are distinct; all14 frozen reads and29 write projections run in ordinary/callable contexts, with separate private arithmetic/evaluation/guard/copy checks. Only declared error fields are compared except the exact Unicode payload case. Existing callable prefixes/coercions/read order remain. Initial fixture, generic Value, digest-build, invalid guard/context and padded-span instruments retain explicit qualifications and earn no extra product RED. The initial compatibility driver correctly rejects a Cargo-rebuilt binary after its no-run archive; that188-test output is provisional. A fresh direct runner retains actual pre/post executable identities for all eight complete suites. Earlier bounded epochs inherit unchanged first-party includes from accepted Git; complete bytes are retained by a late independently Git-verified closure, without inventing earlier full-mode observations. Final epochs explicitly capture those inputs. Both old/new public book fragments remain; actual missing/changed aliases reject. SDK/OS and prepared public RGX outputs remain prerequisites. No whole-SDK replay, arbitrary-precision DSL arithmetic,32-bit execution, broad numeric55.1 repair or portable admission. Exact staged canonical CI governs landing.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh docs/checkpoints/signed-array-rust/publish.py',
            granularity='Exact authored program/route/value or declared diagnostic field, original raw integer token, private state boundary, actual physical runtime fault, executable/source/input epoch, complete supplied book and physical publication input.',
            result=json.dumps(result,sort_keys=True)+'; four actual input denials each admit under a physically discarded validator and reject after exact restoration; complete source/input epoch restored.'),
        falsify=dict(status='checked',
            hypothesis='Legacy negative coercion/rejection, invented missing arrays, normalized authored paths, rounded underflow arithmetic, guard bypass, wrong book selectors or an incomplete/altered input population passes the selected checks.',
            oracle='Frozen signed-selector authority and independent original targets; independent Python exact JSON integers; explicit copy/effect/guard values and public action-source geometry; actual before/runtime inverses and rendered executable examples. Rust generic Value is not the wide-integer oracle.',
            red_control='Original160 observations distinguish104 mismatches/56 controls. Five actual physical runtime variants fail with '+json.dumps(result['runtime_fault_mismatches'],sort_keys=True)+'. Each source restores exactly and the complete six-route137-case consumer passes again. Three rendered-source denials and an executed wrong selector reject. Four physical input faults reject; an actual validator removal admits each; exact restoration rejects each and returns healthy0. All provisional instrument failures remain separately classified.'),
        durability=dict(status='checked',mode='live',inputs=[dict(path=path,sha256=c.identity(path)['sha256'],
            role='producer' if path.endswith('.py') else 'input') for path in files]))])
    path=c.ROOT/'docs/claims/TYPE-REFERENCE-BOOK.1.2.17.3.json'
    with path.open('x') as output:
        output.write(json.dumps(record,sort_keys=True,separators=(',',':'))+'\n')
    assert path.stat().st_size<=128*1024
    print('Dated claim written:',len(files),'tracked-after-staging physical source/evidence inputs.')


if __name__=='__main__':main()
