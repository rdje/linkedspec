"""Capture once, then review the scoped publication without source writes."""
import json
import subprocess
import sys
import common as c
import book
import focused

MANIFEST=c.PREFIX+'publication2-inputs.json.gz'
PUBLICATION=c.PREFIX+'publication2.json'
CLAIM='docs/claims/'+c.OWNER+'.json'

def input_paths():
    owned={p.relative_to(c.ROOT).as_posix() for p in (c.ROOT/c.PREFIX).iterdir() if p.is_file()}
    tracked=subprocess.check_output(['git','ls-files','-z'],cwd=c.ROOT).decode().split('\0')
    source={p for p in tracked if p.startswith(('perl/','specs/','conf/','tablescript/','ebnf/','t/','tests/numeric-codeblocks/','capability_conformance/')) and (c.ROOT/p).is_file()}
    source.update(focused.SUITES)
    source.update(c.load('book-inputs.json.gz')['inputs'])
    source.update(['tests/numeric-codeblocks/registered-pipelines.json',
        'docs/knowledge/terse-type-method-surface-inventory.md','tools/project_data_run.sh',
        'tools/project_data_env.sh','tools/run_python_project_data.sh'])
    return sorted((owned|source)-{MANIFEST,PUBLICATION,CLAIM})

def validate_inputs(declared, actual):
    assert set(declared)==set(actual),'input population'
    for path,item in actual.items():
        assert declared[path]['sha256']==item['sha256'],'input bytes: '+path
        assert declared[path]['mode']==item['mode'],'input mode: '+path

def controls():
    supplied=c.load('artifact2-inputs.json.gz')
    result={}
    for name,declared in supplied['cases'].items():
        try:
            validate_inputs(declared,supplied['actual'])
        except AssertionError as error:
            result[name]=dict(rejected=True,reason=str(error))
        else:
            result[name]=dict(rejected=False,reason='')
    return result

def record(result):
    producers={p for p in input_paths() if p.startswith(c.PREFIX) and p.endswith(('.py','.pl'))}
    producers.update(c.SOURCES+focused.SUITES+['tools/project_data_run.sh','tools/project_data_env.sh','tools/run_python_project_data.sh'])
    bindings=[dict(path=p,sha256=c.identity(p)['sha256'],role='producer') for p in sorted(producers)]
    bindings.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
    claim=dict(name='perl-registered-array-pipelines-and-length',
        statement='Registered Perl functions execute sorted/take receiver pipelines over parameter, local and rest array values; ordinary array pipelines continue to terminal length. Compiled and deferred length reject invalid receiver arity/continuations before effects; existing count/first receiver shapes remain protected.',
        scope='Bounded native and fresh emitted Perl values, lexical scalar kinds, empty/nonarray selection, registered/free/nested calls, copying and effect order. No other-backend, complete operation inventory, deferred indexed-write12, last14 or reducer95 admission. Runtime/spec/test inputs and complete supplied book inputs are bound; mutable continuity is not a gratuitous live dependency. Dated whole source epochs recover from real accepted Git and supplied overrides without rerunning historical writers.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish2.py',
            granularity='Each predeclared case through public descriptor/Get-dump/native/fresh emitted execution, actual typed values and effect traces; permanent fixture/direct tests and complete rendered book with executed examples.',
            result=f"{result['cases']} cases;{result['accepted_red']} accepted RED/{result['accepted_controls']} controls;{len(result['faults'])} necessary restored source faults;{result['direct_suites']}/{result['direct_tap']} TAP;book{result['book_inputs']}/{result['book_examples']};{result['artifact_denials']} actual artifact denials;{result['compatibility_controls']} unchanged selector controls;{result['inline_examples']} exact inline routes. Exact staged canonical receipt and normal hooks govern landing."),
        falsify=dict(status='checked',hypothesis='A helper-name change can hide nested parameter arrays, dropped computed values, invalid call diagnostics or eager effects on rejected terminal shapes.',
            oracle='Fixed independent lexical values and scalar kinds, accepted ordinary terminal behavior, source preservation, explicit effect traces and loaded final producer identities. Actual ablation identifies redundant preliminary name edits and required shape guards. A single bridge rollback/reapply attributes the two original-selector regressions; untouched old fixture oracles govern their repair.',
            red_control='Accepted source fails the fixed plan. Bridge omission, array-length omission, compiled length shape, registered sorted/take shape and deferred length arity/terminal and existing selector-shape faults reject and restore. Actual rendered anchor displacement rejects. Missing/byte/mode declarations reject, admit under an actual return-only validator fault and reject after exact restoration. Incorrect initial callable syntax, rejected candidate1 and fact-budget preflight remain retained without successful-proof credit.'),
        durability=dict(status='checked',mode='live',inputs=bindings))
    return dict(version=1,owner=c.OWNER,claims=[claim])

def main():
    if sys.argv[1:]==['--controls']:
        print(json.dumps(controls(),sort_keys=True))
        return
    assert sys.argv[1:] in ([],['--capture'])
    capture=sys.argv[1:]==['--capture']
    actual={p:c.identity(p) for p in input_paths()}
    if capture:
        assert not (c.ROOT/CLAIM).exists()
        c.write_new('publication2-inputs.json.gz',dict(base=c.BASE,inputs=actual,
            scope='Scoped actual producers, runtime/spec/test inputs, all owned retained observations and complete current book inputs. Dated whole-epoch manifests are retained observations rather than future mutable-continuity bindings. Other repositories/Gitlinks stay read-only black boxes.'))
    validate_inputs(c.load('publication2-inputs.json.gz')['inputs'],actual)
    import review2 as review
    result=review.check()
    validate_inputs(actual,{p:c.identity(p) for p in input_paths()})
    raw=(json.dumps(record(result),separators=(',',':'))+'\n').encode()
    publication=dict(result=result,record_base64=c.encode(raw))
    if capture:
        c.write_new('publication2.json',publication)
        with (c.ROOT/CLAIM).open('xb') as stream:stream.write(raw)
    else:
        assert c.source(CLAIM).read_bytes()==raw
        assert c.load('publication2.json')==publication
    print('Pipeline11 publication PASS:',len(actual),'scoped inputs;',result['cases'],'cases')

if __name__=='__main__':main()
