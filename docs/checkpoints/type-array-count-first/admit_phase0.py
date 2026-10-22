"""Update exactly ten guard goldens and layer their exact inverse before older history."""
import ast
import json
import common as c
import context

PHASE0 = 't/phase0_regression.t'
AUDITOR = 'tests/language-readiness/verify_objectives.py'
DRIVER = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
TABLE = 'tests/language-readiness/count-first-regression-evolution.json'


def replace_once(text,old,new):
    assert text.count(old) == 1,(old,text.count(old))
    return text.replace(old,new,1)


def main():
    baseline = c.load('phase0-accepted-result.json')
    assert len(baseline['failed']) == len(c.load('phase0-plan.json.gz')['plan']['selected'])
    c.write_new('phase0-admission-inputs.json.gz',context.snapshot())
    before = {path:c.read(path) for path in (PHASE0,AUDITOR,DRIVER)}
    text = c.decode(before[PHASE0]['base64']).decode()
    lines = text.splitlines(keepends=True)
    hunks = []
    for index,line in enumerate(lines):
        for helper in ('count','first'):
            old = 'defined($__ls_'+helper+')'
            if old not in line:
                continue
            assert line.count(old) == 1
            if line.lstrip().startswith('q{'):
                new = "ref($__ls_"+helper+") eq 'ARRAY'"
            else:
                assert line.lstrip().startswith("'")
                new = "ref($__ls_"+helper+") eq \\'ARRAY\\'"
            after = line.replace(old,new,1)
            hunks.append(dict(id=helper+'-'+str(index+1),before=line,after=after))
            lines[index] = after
    assert len(hunks) == 10 and text.count('ref($__ls_count)') == 0
    phase0 = ''.join(lines)
    table = dict(version=1,owner=c.OWNER,source=PHASE0,before_revision=c.BASE,
        before_sha256=c.sha(text.encode()),after_sha256=c.sha(phase0.encode()),hunks=hunks)
    raw_table = (json.dumps(table,sort_keys=True,indent=1)+'\n').encode()
    verifier = c.decode(before[AUDITOR]['base64']).decode()
    marker = "DROP_GENERATED_MARKER = b'my @__ls_drop_keys = ('\n"
    constants = (f"COUNT_FIRST_OWNER = {c.OWNER!r}\nCOUNT_FIRST_TABLE = {TABLE!r}\n"
        f"COUNT_FIRST_TABLE_SHA256 = {c.sha(raw_table)!r}\nCOUNT_FIRST_BEFORE = {c.BASE!r}\n"
        "COUNT_FIRST_MARKER = b'ref($__ls_count)'\n")
    verifier = replace_once(verifier,marker,marker+constants)
    functions = '''def count_first_table(source):
    raw = read_relative(COUNT_FIRST_TABLE)
    require(digest(raw) == COUNT_FIRST_TABLE_SHA256,
            "count/first inverse table identity mismatch: " + source)
    table = json.loads(raw)
    require(table["version"] == 1 and table["owner"] == COUNT_FIRST_OWNER and
            table["source"] == source == "t/phase0_regression.t" and
            table["before_revision"] == COUNT_FIRST_BEFORE and
            len(table["hunks"]) == len({item["id"] for item in table["hunks"]}) == 10,
            "count/first inverse owner/population mismatch: " + source)
    rebuilt = git("show", f"{COUNT_FIRST_BEFORE}:{source}")
    require(digest(rebuilt) == table["before_sha256"],
            "count/first inverse base mismatch: " + source)
    for item in table["hunks"]:
        old, new = item["before"].encode(), item["after"].encode()
        require(old and new and old != new and rebuilt.count(old) == 1,
                "count/first inverse reconstruction mismatch: " + source)
        rebuilt = rebuilt.replace(old, new, 1)
    require(digest(rebuilt) == table["after_sha256"],
            "count/first inverse reconstruction mismatch: " + source)
    return table


def restore_count_first_regressions(source, contents):
    # Older falsifiers intentionally supply their original pre-selection stage.
    # The final historical comparison still rejects every unregistered edit.
    if COUNT_FIRST_MARKER not in contents:
        return contents
    for item in reversed(count_first_table(source)["hunks"]):
        old, new = item["before"].encode(), item["after"].encode()
        require(contents.count(new) == 1,
                "count/first regression registration mismatch: " + source)
        contents = contents.replace(new, old, 1)
    return contents


'''
    marker = 'def restore_drop_generated_regressions(source, contents):\n'
    verifier = replace_once(verifier,marker,functions+marker)
    marker = '    current_hash = digest(contents)\n    contents = restore_drop_generated_regressions(source, contents)\n'
    verifier = replace_once(verifier,marker,'    current_hash = digest(contents)\n    contents = restore_count_first_regressions(source, contents)\n    contents = restore_drop_generated_regressions(source, contents)\n')
    marker = '        elif source == "t/phase0_regression.t":\n            drop_current = current\n'
    verifier = replace_once(verifier,marker,'        elif source == "t/phase0_regression.t":\n            count_first_current = current\n            current = restore_count_first_regressions(source, current)\n            drop_current = current\n')
    controls = '''            # Preserve all650 previous falsifiers at their original source stages.
            # Each new complete guard line has independent absence/duplication/change.
            for count_first_hunk in count_first_table(source)["hunks"]:
                fragment = count_first_hunk["after"].encode()
                require(count_first_current.count(fragment) == 1,
                        "count/first control registration mismatch: " + source)
                changed = bytes([fragment[0] ^ 1]) + fragment[1:]
                altered += (count_first_current.replace(fragment, b"", 1),
                            count_first_current.replace(fragment, fragment * 2, 1),
                            count_first_current.replace(fragment, changed, 1))
'''
    marker = '            verify = verify_signature_regression_evolution\n'
    verifier = replace_once(verifier,marker,controls+marker)
    marker = '                       "drop regression registration mismatch:")'
    verifier = replace_once(verifier,marker,'                       "drop regression registration mismatch:",\n                       "count/first regression registration mismatch:")')
    marker = '            "drop_generated_owner": DROP_GENERATED_OWNER,\n'
    verifier = replace_once(verifier,marker,'            "count_first_owner": COUNT_FIRST_OWNER,\n            "count_first_input": COUNT_FIRST_TABLE,\n            "count_first_table_sha256": COUNT_FIRST_TABLE_SHA256,\n            "count_first_before_revision": COUNT_FIRST_BEFORE,\n'+marker)
    verifier = replace_once(verifier,'"scope": "exact owner-bound evaluated-value test inverse,',
        '"scope": "exact count/first guard-golden inverse followed by owner-bound evaluated-value test inverse,')
    driver = c.decode(before[DRIVER]['base64']).decode()
    marker = 'audit.EVALUATED_VALUES_TABLE, audit.SCALAR_NUMERIC_TABLE, audit.DROP_GENERATED_TABLE))'
    driver = replace_once(driver,marker,'audit.EVALUATED_VALUES_TABLE, audit.SCALAR_NUMERIC_TABLE, audit.DROP_GENERATED_TABLE,\n                   audit.COUNT_FIRST_TABLE))')
    ast.parse(verifier,filename=AUDITOR)
    ast.parse(driver,filename=DRIVER)
    tree = c.source('docs/tasks/TYPE-REFERENCE-BOOK.md').read_text()
    marker = '  Final pre-CI source search owns ten stale Phase0 emitted-source expectations'
    assert tree.count(marker) == 1
    tree = tree.replace(marker,'  Additional owned paths: t/phase0_regression.t guard literals, tests/language-readiness/count-first-regression-evolution.json, verify_objectives.py and the read-denied audit driver input closure. Canonical tier covers this exact inverse admission; older tables and runtime source stay unchanged.\n'+marker,1)
    c.source('docs/tasks/TYPE-REFERENCE-BOOK.md').write_text(tree)
    memory = c.source('MEMORY.md').read_text()
    memory = memory.replace('- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.10` — subject `TYPE-REFERENCE-BOOK.1.2.10 - execute callable count and first`.',
        '- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.13` — accepted a8bd8620a;10 is still in final admission.')
    c.source('MEMORY.md').write_text(memory)
    for path,value in ((PHASE0,phase0),(AUDITOR,verifier),(DRIVER,driver)):
        c.source(path).write_text(value)
        c.source(path).chmod(before[path]['mode'])
    with (c.ROOT/TABLE).open('xb') as output:
        output.write(raw_table)
    syntax = c.run(['perl','-c','-Iperl',PHASE0])
    c.write_new('phase0-admission.json.gz',dict(before=before,
        after={path:c.read(path) for path in before},table=c.read(TABLE),syntax=syntax,
        producer=c.read(c.PREFIX+'admit_phase0.py'),
        scope='Exactly eight count/two first expected emitted-source guard literals. A separate hash-gated inverse reconstructs the real accepted Phase0 source before unchanged older layers; the read-denied driver explicitly retains the new input. Existing650 falsifiers keep their original stages;30 new per-hunk controls are added. Runtime source and all older tables stay exact.'))
    assert syntax['returncode'] == 0
    print('Ten Phase0 goldens and exact dedicated inverse admitted; Perl/Python syntax GREEN')


if __name__ == '__main__':
    main()
