"""Register the exact two-subtest inverse ahead of all previous historical stages."""
import gzip
import json
import subprocess
import common as c

AUDIT='tests/language-readiness/verify_objectives.py'
PROOF='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
TABLE='tests/language-readiness/drop-generated-regression-evolution.json.gz'


def main():
    before={path:c.read(path) for path in (AUDIT,PROOF)}
    for path,packet in before.items():
        assert c.decode(packet['base64'])==subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
    migration=c.load('phase0-migration.json.gz')
    original=c.decode(migration['before']['base64'])
    after=c.decode(migration['after_base64'])
    assert after==(c.ROOT/'t/phase0_regression.t').read_bytes()
    assert original==subprocess.check_output(['git','show',c.BASE+':t/phase0_regression.t'],cwd=c.ROOT)
    hunks=migration['changes']
    assert len(hunks)==len({item['id'] for item in hunks})==2
    rebuilt=original
    for item in hunks:
        old,new=item['before'].encode(),item['after'].encode()
        assert rebuilt.count(old)==after.count(new)==1
        rebuilt=rebuilt.replace(old,new,1)
    assert rebuilt==after
    table=dict(version=1,owner=c.OWNER,source='t/phase0_regression.t',before_revision=c.BASE,
        before_sha256=c.sha(original),after_sha256=c.sha(after),hunks=hunks,
        scope='Two exact complete drop-containing subtests only; prior observations, inverses and all other source bytes remain unchanged.')
    raw=gzip.compress((json.dumps(table,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0)
    text=c.decode(before[AUDIT]['base64']).decode()

    def replace(old,new):
        nonlocal text
        assert text.count(old)==1,old
        text=text.replace(old,new,1)

    anchor="SCALAR_NUMERIC_MARKER = b'    my $numeric_setup = q{'\n"
    replace(anchor,anchor+f"DROP_GENERATED_OWNER = '{c.OWNER}'\nDROP_GENERATED_TABLE = '{TABLE}'\n"
        +f"DROP_GENERATED_TABLE_SHA256 = '{c.sha(raw)}'\nDROP_GENERATED_BEFORE = '{c.BASE}'\n"
        +"DROP_GENERATED_MARKER = b'my @__ls_drop_keys = ('\n")
    addition='''def drop_generated_table(source):
    raw = read_relative(DROP_GENERATED_TABLE)
    require(digest(raw) == DROP_GENERATED_TABLE_SHA256,
            "drop inverse table identity mismatch: " + source)
    table = json.loads(gzip.decompress(raw))
    require(table["version"] == 1 and table["owner"] == DROP_GENERATED_OWNER and
            table["source"] == source == "t/phase0_regression.t" and
            table["before_revision"] == DROP_GENERATED_BEFORE and
            len(table["hunks"]) == len({item["id"] for item in table["hunks"]}) == 2,
            "drop inverse owner/population mismatch: " + source)
    rebuilt = git("show", f"{DROP_GENERATED_BEFORE}:{source}")
    require(digest(rebuilt) == table["before_sha256"], "drop inverse base mismatch: " + source)
    for item in table["hunks"]:
        old, new = item["before"].encode(), item["after"].encode()
        require(old and new and old != new and rebuilt.count(old) == 1,
                "drop inverse reconstruction mismatch: " + source)
        rebuilt = rebuilt.replace(old, new, 1)
    require(digest(rebuilt) == table["after_sha256"], "drop inverse reconstruction mismatch: " + source)
    return table


def restore_drop_generated_regressions(source, contents):
    # Earlier-stage falsifiers deliberately supply pre-drop source. The final
    # historical byte/hash comparison still rejects every unregistered edit.
    if DROP_GENERATED_MARKER not in contents:
        return contents
    table = drop_generated_table(source)
    for item in reversed(table["hunks"]):
        old, new = item["before"].encode(), item["after"].encode()
        require(contents.count(new) == 1, "drop regression registration mismatch: " + source)
        contents = contents.replace(new, old, 1)
    return contents


'''
    replace('def scalar_numeric_table(source):\n',addition+'def scalar_numeric_table(source):\n')
    replace('    contents = restore_scalar_numeric_regressions(source, contents)\n',
        '    contents = restore_drop_generated_regressions(source, contents)\n'
        '    contents = restore_scalar_numeric_regressions(source, contents)\n')
    replace('            "scalar_numeric_owner": SCALAR_NUMERIC_OWNER,\n',
        '            "drop_generated_owner": DROP_GENERATED_OWNER,\n'
        '            "drop_generated_input": DROP_GENERATED_TABLE,\n'
        '            "drop_generated_table_sha256": DROP_GENERATED_TABLE_SHA256,\n'
        '            "drop_generated_before_revision": DROP_GENERATED_BEFORE,\n'
        '            "scalar_numeric_owner": SCALAR_NUMERIC_OWNER,\n')
    replace('            numeric_current = current\n',
        '            drop_current = current\n'
        '            current = restore_drop_generated_regressions(source, current)\n'
        '            numeric_current = current\n')
    replace('            verify = verify_signature_regression_evolution\n','''            # All644 previous controls retain their exact pre-drop source stage.
            # The two complete new subtests get omission/duplication/corruption.
            for drop_hunk in drop_generated_table(source)["hunks"]:
                fragment = drop_hunk["after"].encode()
                require(drop_current.count(fragment) == 1,
                        "drop control registration mismatch: " + source)
                changed = bytes([fragment[0] ^ 1]) + fragment[1:]
                altered += (drop_current.replace(fragment, b"", 1),
                            drop_current.replace(fragment, fragment * 2, 1),
                            drop_current.replace(fragment, changed, 1))
            verify = verify_signature_regression_evolution
''')
    replace('                       "numeric regression registration mismatch:")\n',
        '                       "numeric regression registration mismatch:",\n'
        '                       "drop regression registration mismatch:")\n')
    proof=c.decode(before[PROOF]['base64']).decode()
    old='                   audit.EVALUATED_VALUES_TABLE, audit.SCALAR_NUMERIC_TABLE))\n'
    assert proof.count(old)==1
    proof=proof.replace(old,'                   audit.EVALUATED_VALUES_TABLE, audit.SCALAR_NUMERIC_TABLE, audit.DROP_GENERATED_TABLE))\n',1)
    after_sources={AUDIT:text.encode(),PROOF:proof.encode()}
    for path,value in after_sources.items():compile(value,path,'exec')
    c.write_new('historical-implementation.json.gz',dict(before=before,
        after={path:c.encode(value) for path,value in after_sources.items()},
        table=dict(path=TABLE,sha256=c.sha(raw),base64=c.encode(raw)),
        migration=c.read(c.PREFIX+'phase0-migration.json.gz'),producer=c.read(c.PREFIX+'register_history.py'),
        scope='The two exact subtests restore before numeric22/evaluated70 and all older stages. '
              'All644 prior reason-sensitive controls remain; six new rejection controls are added. '
              'The isolated proof explicitly retains the actual new table input.'))
    with (c.ROOT/TABLE).open('xb') as output:output.write(raw)
    for path,value in after_sources.items():(c.ROOT/path).write_bytes(value)
    print('Exact drop inverse2 before numeric22; retain644 plus6 new controls; new table explicitly closed')


if __name__=='__main__':main()
