"""One-shot claim publication after final readonly custody review."""
import json
import common as c
import publish


def main():
    result=publish.check()
    files=sorted(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file())
    record=dict(version=1,owner=c.OWNER,claims=[dict(
        name='dart-signed-array-selectors-and-exact-source-admission',
        statement='Dart integer negative selectors address existing array positions through native, reconstructed, validated-plan, emitted and primary CLI carriers, with post-expression atomic writes and exact typed diagnostics on supported embedding routes.',
        scope='Dated Dart17.4 interpreter image9f0ee763 at clean activation4e6ece603. Frozen signed authority and original write-v1/map/composition authorities stay unchanged. Actual public113/452, private51+arithmetic12, emitted113 and CLI107/214 have separate typed/effect/error/state oracles; private inspection uses exact41-library copies plus an observer suffix, without production exports. All16 actual AOT executables, first-party producers, package resolution and declared artifact inputs are retained before execution. Original package636/CLI66x2/corpus105/storage25 channels are separate compatibility proof; transient package kernels and installed locked hosted packages/SDK/OS/Python/mdBook are read-only prerequisites, not whole-environment replay. Existing SDK non-writing format1/analysis2 debt is not waived or called a complete component PASS. Historical134 streams/84613241 bytes/22 controls and Rust source/support admissions remain exact; only the reviewed whole Dart source image gains an owner-bound exception. Original accepted Git objects remain prerequisites. Book95/90 and four source denials preserve exact examples/fragments. No old checkpoint refresh, dependency change, broader numeric coercion, Julia/Lua or portable signed admission. Canonical receipt and normal hooks govern landing; director-requested hygiene23 follows clean Git before Julia17.5.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py',
            granularity='Actual original Git byte/executable class, guarded full filesystem mode, full source/fixture packet, typed result/effect/diagnostic/path/span, private binding presence/identity/atomicity/copy, actual emitted library/executable, raw CLI channel, complete historical byte stream, rendered book source and closed physical publication input.',
            result=json.dumps(result,sort_keys=True)),
        falsify=dict(status='checked',
            hypothesis='Negative selectors are rejected, normalize before operand effects, create missing state, rewrite authored paths, bypass active identity guards, or hide unregistered runtime/proof input changes while a matching positive control survives.',
            oracle='Independent frozen12 arithmetic/14 read/33 write targets plus declared source projections, exact typed public/private results and effects, authored Unicode geometry, detached mutations, unchanged source/control cases, original historical identities/archive bytes and literal book boundaries.',
            red_control='Actual clean baseline21 targets gives12 signed RED and9 controls. Five physical whole-production runtime inverses give244/32/36/24/8 mismatches; exact bytes/mode restore452/0. Unregistered/old-auditor candidates reject; actual hash-guard removal admits an unreviewed image and the original driver rejects it; restoration returns identical healthy134-stream recovery. Nine primary/five Rust support mutations and four direct Dart denials reject. Four actual book source faults reject. Four physical missing/byte/mode/required-omission publication faults reject, a discarded actual validator admits each, exact restoration rejects each and restores identical healthy channels. Provisional compile/observer/namespace/mode failures are retained and earn no product RED credit.'),
        durability=dict(status='checked',mode='live',inputs=[dict(path=name,sha256=c.identity(name)['sha256'],
            role='producer' if name.endswith(('.py','.dart')) else 'input') for name in files]))])
    path=c.ROOT/'docs/claims/TYPE-REFERENCE-BOOK.1.2.17.4.json'
    raw=(json.dumps(record,sort_keys=True,separators=(',',':'))+'\n').encode()
    assert len(raw)<=128*1024
    with path.open('xb') as output:output.write(raw)
    print('Dart17.4 claim inputs:',len(files),'bytes:',len(raw))


if __name__=='__main__':main()
