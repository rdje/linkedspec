"""Migrate two complete owned subtests after independent public value proof."""
import json
import subprocess
import common as c

TEST = 't/phase0_regression.t'


def subtest(raw, name):
    anchor = ("subtest '"+name+"' => sub {\n").encode()
    assert raw.count(anchor) == 1
    start = raw.index(anchor)
    end = raw.index(b'\n};\n', start)+4
    return raw[start:end]


def main():
    before = c.read(TEST)
    raw = c.decode(before['base64'])
    assert raw == subprocess.check_output(['git','show',c.BASE+':'+TEST],cwd=c.ROOT)
    run = c.load('phase0-before2-run.json.gz')
    assert run['inputs_unchanged'] and run['run']['returncode'] != 0
    changes = []
    for name in ('emit_context_lowers_value_layer_emptiness_helpers','emit_context_lowers_drop_keys_value_helpers'):
        old = subtest(raw,name)
        new = old
        for keys in ('"debug"','"debug", "span"'):
            needle = ('delete @__ls_drop{'+keys+'};').encode()
            members = ', '.join('do { my @__ls_evaluated_values = ('+key+'); @__ls_evaluated_values }'
                                for key in keys.split(', '))
            replacement = ('my @__ls_drop_keys = ('+members+'); delete @__ls_drop{@__ls_drop_keys};').encode()
            new = new.replace(needle,replacement)
        warning = b'"warnings":["Scalar value @__ls_drop{\\"debug\\"} better written as $__ls_drop{\\"debug\\"}"]'
        assert new.count(warning) == 1
        new = new.replace(warning,b'"warnings":[]',1)
        if name == 'emit_context_lowers_drop_keys_value_helpers':
            assert new.count(b'    plan tests => 4;\n') == 1
            new = new.replace(b'    plan tests => 4;\n',b'    plan tests => 6;\n',1)
            addition = b'''    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');
my $result = do './t/drop_keys_generated.t';
die $@ if $@;
die "drop-key regression did not load: $!" unless defined $result;
PERL
    is($exit_code, 0, 'permanent drop-key native/generated warning and key evaluation regression passes') or diag($err || $out);
    like($out, qr/^1\\.\\.18$/m, 'all eighteen standalone drop-key assertions actually ran');
'''
            new = new[:-3]+addition+b'};\n'
        assert new != old and new.count(b'my @__ls_drop_keys = (') >= 1
        changes.append(dict(id=name,before=old.decode(),after=new.decode()))
    after = raw
    for change in changes:
        assert after.count(change['before'].encode()) == 1
        after = after.replace(change['before'].encode(),change['after'].encode(),1)
    c.write_new('phase0-migration.json.gz',dict(owner=c.OWNER,before=before,
        after_base64=c.encode(after),changes=changes,producer=c.read(c.PREFIX+'migrate_phase0.py'),
        scope='Only two complete drop-containing subtests: three exact emitted-source assertions, '
              'two obsolete warning goldens and the permanent eighteen-assertion public regression. '
              'All other Phase0 bytes are unchanged. Independent fixed public values precede this migration.'))
    (c.ROOT/TEST).write_bytes(after)
    print('Migrated two exact subtests; eighteen permanent public assertions are now in ordinary Phase0')


if __name__ == '__main__':
    main()
