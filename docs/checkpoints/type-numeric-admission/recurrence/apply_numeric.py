"""Register only the exact reviewed numeric Phase0 inverse before the older inverse."""
import gzip
import json
import subprocess
import sys
from pathlib import Path
sys.path.insert(1, str(Path(__file__).resolve().parents[2] / 'type-numeric-codeblocks'))
import common as c
PREFIX = 'docs/checkpoints/type-numeric-admission/recurrence/'
AUDIT = 'tests/language-readiness/verify_objectives.py'
TABLE = 'tests/language-readiness/scalar-numeric-regression-evolution.json.gz'
PROOF = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'


def main():
    saved=json.loads(gzip.decompress((c.ROOT/(PREFIX+'canonical2.json.gz')).read_bytes()))
    assert all(c.read(path)==packet for path,packet in saved['before'].items())
    before={path:c.read(path) for path in (AUDIT,PROOF)}
    assert {key:before[PROOF][key] for key in ('sha256','mode')} == {key:saved['images'][PROOF][key] for key in ('sha256','mode')}
    migration=c.load('phase0-migration.json.gz')
    original=c.decode(migration['before']['base64'])
    after=c.decode(migration['after'])
    assert original==subprocess.check_output(['git','show',c.BASE+':t/phase0_regression.t'],cwd=c.ROOT)
    assert after==(c.ROOT/'t/phase0_regression.t').read_bytes()
    hunks=[dict(id=row['id'],before=row['before'],after=row['after']) for row in migration['changes']]
    assert len(hunks)==21 and len({row['id'] for row in hunks})==21
    setup=c.load('phase0-golden-inputs.json')['corrected']['setup']
    anchor="subtest 'emit_context_lowers_method_contracts_for_capture_and_structured_return_values' => sub {\n    plan tests => 79;\n"
    insertion='\n    # Independent finite frame; goldens come from accepted frozen fragments.\n    my $numeric_setup = q{'+setup+'};\n'
    hunks.append(dict(id='numeric-independent-frame',before=anchor,after=anchor+insertion))
    rebuilt=original.decode()
    for row in hunks:
        assert rebuilt.count(row['before'])==1 and after.decode().count(row['after'])==1,row['id']
        rebuilt=rebuilt.replace(row['before'],row['after'],1)
    assert rebuilt.encode()==after
    table=dict(version=1,owner=c.OWNER,source='t/phase0_regression.t',before_revision=c.BASE,
        before_sha256=c.sha(original),after_sha256=c.sha(after),hunks=hunks,
        scope='Exactly21 already verified numeric value assertions plus their one shared finite frame; '
              'original malformed fixture remains in the inverse before image. No historical observation refresh.')
    raw=gzip.compress((json.dumps(table,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0)
    text=c.decode(before[AUDIT]['base64']).decode()
    assert text.count('import hashlib\n')==1
    text=text.replace('import hashlib\n','import gzip\nimport hashlib\n',1)
    marker="EVALUATED_VALUES_BEFORE = 'c053c9dcf24a78cc8b551187f47cdb7aefb03eb3'\n"
    assert text.count(marker)==1
    constants=("SCALAR_NUMERIC_OWNER = '"+c.OWNER+"'\nSCALAR_NUMERIC_TABLE = '"+TABLE+"'\n"
        "SCALAR_NUMERIC_TABLE_SHA256 = '"+c.sha(raw)+"'\nSCALAR_NUMERIC_BEFORE = '"+c.BASE+"'\n"
        "SCALAR_NUMERIC_MARKER = b'    my $numeric_setup = q{'\n")
    text=text.replace(marker,marker+constants,1)
    anchor='def restore_evaluated_value_regressions(source, contents):\n'
    addition='''def scalar_numeric_table(source):
    raw = read_relative(SCALAR_NUMERIC_TABLE)
    require(digest(raw) == SCALAR_NUMERIC_TABLE_SHA256,
            "numeric inverse table identity mismatch: " + source)
    table = json.loads(gzip.decompress(raw))
    require(table["version"] == 1 and table["owner"] == SCALAR_NUMERIC_OWNER and
            table["source"] == source == "t/phase0_regression.t" and
            table["before_revision"] == SCALAR_NUMERIC_BEFORE and
            len(table["hunks"]) == len({row["id"] for row in table["hunks"]}) == 22,
            "numeric inverse owner/population mismatch: " + source)
    rebuilt = git("show", f"{SCALAR_NUMERIC_BEFORE}:{source}")
    require(digest(rebuilt) == table["before_sha256"],
            "numeric inverse base mismatch: " + source)
    for row in table["hunks"]:
        old, new = row["before"].encode(), row["after"].encode()
        require(old and new and old != new and rebuilt.count(old) == 1,
                "numeric inverse reconstruction mismatch: " + source)
        rebuilt = rebuilt.replace(old, new, 1)
    require(digest(rebuilt) == table["after_sha256"],
            "numeric inverse reconstruction mismatch: " + source)
    return table


def restore_scalar_numeric_regressions(source, contents):
    # Older-stage falsifiers deliberately supply pre-numeric source. The complete
    # historical comparison still rejects every unregistered older-stage edit.
    if SCALAR_NUMERIC_MARKER not in contents:
        return contents
    table = scalar_numeric_table(source)
    for row in reversed(table["hunks"]):
        old, new = row["before"].encode(), row["after"].encode()
        require(contents.count(new) == 1,
                "numeric regression registration mismatch: " + source)
        contents = contents.replace(new, old, 1)
    return contents


'''
    assert text.count(anchor)==1
    text=text.replace(anchor,addition+anchor,1)
    anchor='    contents = restore_evaluated_value_regressions(source, contents)\n'
    assert text.count(anchor)==1
    text=text.replace(anchor,'    contents = restore_scalar_numeric_regressions(source, contents)\n'+anchor,1)
    anchor='            "evaluated_values_owner": EVALUATED_VALUES_OWNER,\n'
    assert text.count(anchor)==1
    text=text.replace(anchor,'            "scalar_numeric_owner": SCALAR_NUMERIC_OWNER,\n'
        '            "scalar_numeric_input": SCALAR_NUMERIC_TABLE,\n'
        '            "scalar_numeric_table_sha256": SCALAR_NUMERIC_TABLE_SHA256,\n'
        '            "scalar_numeric_before_revision": SCALAR_NUMERIC_BEFORE,\n'+anchor,1)
    anchor='        elif source == "t/phase0_regression.t":\n'
    assert text.count(anchor)==1
    text=text.replace(anchor,anchor+'            numeric_current = current\n'
        '            current = restore_scalar_numeric_regressions(source, current)\n',1)
    anchor='            verify = verify_signature_regression_evolution\n'
    assert text.count(anchor)==1
    text=text.replace(anchor,'''            # Keep every older reason-sensitive control on its original source
            # stage, then exercise each new numeric registration on current bytes.
            for row in scalar_numeric_table(source)["hunks"]:
                fragment = row["after"].encode()
                require(numeric_current.count(fragment) == 1,
                        "numeric control registration mismatch: " + source)
                changed = bytes([fragment[0] ^ 1]) + fragment[1:]
                altered += (numeric_current.replace(fragment, b"", 1),
                            numeric_current.replace(fragment, fragment * 2, 1),
                            numeric_current.replace(fragment, changed, 1))
'''+anchor,1)
    anchor='                       "evaluated-value regression registration mismatch:")\n'
    assert text.count(anchor)==1
    text=text.replace(anchor,'                       "evaluated-value regression registration mismatch:",\n'
                             '                       "numeric regression registration mismatch:")\n',1)
    proof=c.decode(before[PROOF]['base64']).decode()
    anchor='                   audit.EVALUATED_VALUES_TABLE))\n'
    assert proof.count(anchor)==1
    proof=proof.replace(anchor,'                   audit.EVALUATED_VALUES_TABLE, audit.SCALAR_NUMERIC_TABLE))\n',1)
    for path,source in ((AUDIT,text),(PROOF,proof)):
        compile(source,path,'exec')
    value=dict(before=before,after={AUDIT:c.encode(text.encode()),PROOF:c.encode(proof.encode())},
        table=dict(path=TABLE,base64=c.encode(raw),sha256=c.sha(raw)),
        producer=c.read(PREFIX+'apply_numeric.py'), migration=c.read(c.PREFIX+'phase0-migration.json.gz'),
        scope='Exact22-fragment numeric inverse precedes the old70-fragment inverse. Original reason-sensitive '
              'controls use their pre-numeric stage;66 new numeric omission/duplication/corruption controls are added. '
              'The isolated producer explicitly closes the new table. Runtime, original hashes and old inverse table unchanged.')
    with (c.ROOT/(PREFIX+'implementation.json.gz')).open('xb') as out:
        out.write(gzip.compress((json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0))
    with (c.ROOT/TABLE).open('xb') as out:
        out.write(raw)
    (c.ROOT/AUDIT).write_text(text)
    (c.ROOT/PROOF).write_text(proof)
    print('Numeric inverse22 registered before prior70; existing controls preserved;66 new controls; table explicitly closed')


if __name__=='__main__':
    main()
