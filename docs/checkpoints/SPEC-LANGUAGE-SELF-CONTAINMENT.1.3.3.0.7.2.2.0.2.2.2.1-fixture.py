"""Author grouped-role and real-occurrence oracles before production changes."""
from pathlib import Path
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1-'
REVISION = '78012b1e78bb114a41f54873f30ca63c421568c8'
FIXTURE = 't/actionir_compiler_source_membership.t'
PATTERNS = ('/(set(counter,1)).*x/', '/(set(counter,1)),x/')


def cases():
    rows = []
    def add(name, prefix, pattern='', suffix='', real=True):
        source = prefix + pattern + suffix
        ranges = [[len(prefix), len(prefix) + len(pattern)]] if pattern else []
        events = []
        if real:
            source += '; '
            start = len(source)
            source += 'set(counter,2)'
            events = [{'raw': 'set(counter,2)', 'args': {'target': 'counter', 'source': '2'},
                       'source_span': {'start': start, 'end': start + 14}}]
        rows.append({'id': name, 'source': source, 'helper_ranges': ranges, 'events': events})
    for name in ('y', 'tr', 's', 'q', 'qq', 'qx', 'qr', 'm', 'z'):
        for params in ('x,' + name, 'x,...' + name):
            for index, pattern in enumerate(PATTERNS):
                add(params + ':' + str(index), 'cb={|' + params + '| return(matches("setcounter,1,x", ',
                    pattern, ')) }; return(cb("ok","unused"))')
    for index, pattern in enumerate(PATTERNS):
        add('zero:' + str(index), 'cb={|| return(matches("setcounter,1,x", ', pattern, ')) }; return(cb())')
        add('nested:' + str(index), 'cb={|x,y| inner={|a,q| return(matches("setcounter,1,x", ',
            pattern, ')) }; return(inner(x,y)) }; return(cb("ok","unused"))')
        for separator in ('\n', '\r\n'):
            add('line:' + repr(separator) + ':' + str(index), 'cb={|x,y|' + separator + ' return(matches("setcounter,1,x", ',
                pattern, ')) }; return(cb("ok","unused"))')
        add('quoted-header-prefix:' + str(index), 'payload="{|x,y| set(counter,99)}"; cb={|x,y| return(matches("setcounter,1,x", ',
            pattern, ')) }; return(cb("ok","unused"))')
        add('flags:' + str(index), 'cb={|x,y| return(matches("setcounter,1,x", ', pattern + 'i', ')) }')
    for name, prefix, suffix in (
        ('split', 'return(split("setcounter,1,x", ', '))'),
        ('receiver-filter', 'return(["setcounter,1,x"].filter_match(', '))'),
        ('receiver-split-each', 'return(["setcounter,1,x"].split_each(', '))'),
        ('regex-subst', 'regex_subst(text, ', ', "ok", g); return(text)'),
        ('substr', 'substr(text, ', ', "ok", g); return(text)'),
    ):
        for index, pattern in enumerate(PATTERNS):
            add(name + ':' + str(index), 'cb={|x,y| ' + prefix, pattern, suffix + ' }')
    for variable in ('q', 'm', 'qr'):
        add('indexed-' + variable, 'cb={|x,y| return(' + variable + '[matches("setcounter,1,x", ',
            PATTERNS[0], ')]) }')
    for quote in ('"{|x,y| set(counter,1)}"', "'{|x,y| set(counter,1)}'",
                  'q{|x,y| matches("setcounter,1,x", /(set(counter,1)).*x/)}',
                  'qq{|x,y| matches("setcounter,1,x", /(set(counter,1)).*x/)}',
                  'qr{|x,y| matches("setcounter,1,x", /(set(counter,1)).*x/)}',
                  'm{|x,y| matches("setcounter,1,x", /(set(counter,1)).*x/)}',
                  'q|{\\|x,y\\| matches("setcounter,1,x", /(set(counter,1)).*x/)}|'):
        add('host:' + quote, quote)
    add('body-host-quote', 'cb={|x,y| rx=q{matches("setcounter,1,x", /(set(counter,1)).*x/)}; return(x) }')
    add('numeric-call', 'cb={|x,y| return(array(/(14,2), 14/cos)) }')
    add('numeric-quoted-follower', 'cb={|x,y| return(array(/(14,2), "a/)")) }')
    add('all-pattern-data', 'cb={|x,y| return(matches("setcounter,1,x", ', PATTERNS[0], ')) }', real=False)
    assert len({r['id'] for r in rows}) == len(rows)
    return rows


GROUP = r'''
subtest 'callable helper roles preserve grouped-pattern occurrence ownership' => sub {
    my $path = 'PREFIXcases.json';
    open my $file, '<:raw', $path or die $!;
    my $rows = JSON::PP->new->utf8->decode(do { local $/; <$file> });
    close $file or die $!;
    for my $row (@$rows) {
        my $source = $row->{source};
        my $default = LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges($source);
        is_deeply(LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges($source, 0), $default,
            "$row->{id} retains the explicit default query");
        is_deeply(LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges($source, 1), $row->{helper_ranges},
            "$row->{id} retains independently authored compiler helper roles");
        my $contract = {id => 'set_value'};
        my $syntactic = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events($contract, $source, $deps);
        my $snapshot = JSON::PP->new->canonical->encode($syntactic);
        my ($produced, $selected);
        my $original = \&LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance;
        {
            no warnings 'redefine';
            local *LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance = sub {
                $produced = $original->(@_); return $produced;
            };
            $@ = 'grouped caller error';
            $selected = LinkedSpec::RuleIR::EmitContext::_scan_contract_ir_events($contract, $source);
            my $error = $@;
            is($error, 'grouped caller error', "$row->{id} preserves caller error");
        }
        is_deeply([map { {raw => $_->{raw}, args => $_->{args}} } @$selected],
            [map { {raw => $_->{raw}, args => $_->{args}} } @{$row->{events}}],
            "$row->{id} excludes actual pattern data and preserves genuine calls in order");
        is(JSON::PP->new->canonical->encode($syntactic), $snapshot,
            "$row->{id} leaves ordinary syntactic events untouched");
        is_deeply(LinkedSpec::ActionIR::MethodExpr::_helper_pattern_ranges($source), $default,
            "$row->{id} leaves the default query unchanged after compiler selection");
        is($source, $row->{source}, "$row->{id} leaves original source unchanged");
        my %selected = map { refaddr($_) => 1 } @$selected;
        my @origins = grep { $selected{refaddr($_->{event})} } @{$produced->{source_origins}};
        is_deeply([map { {raw => $_->{event}{raw}, args => $_->{event}{args},
                         source_span => $_->{source_span}} } @origins], $row->{events},
            "$row->{id} retains independently authored scalar occurrence authority");
        for my $event (@$selected) {
            ok(grep({ refaddr($_) == refaddr($event) } @{$produced->{events}}),
                "$row->{id} retains the actual producer event reference");
            ok(grep({ refaddr($_->{args}) == refaddr($event->{args}) } @{$produced->{events}}),
                "$row->{id} retains the actual argument reference");
            ok(!exists($event->{source_span}) && !exists($event->{source_origins}),
                "$row->{id} retains the public event schema");
        }
    }
};
'''


def main():
    original = subprocess.check_output(['git', 'show', REVISION + ':' + FIXTURE], cwd=ROOT)
    assert (ROOT / FIXTURE).read_bytes() == original, 'authored before production on unchanged fixture'
    assert original.endswith(b'done_testing();\n')
    rows = cases()
    (ROOT / (PREFIX + 'cases.json')).write_text(json.dumps(rows, indent=2) + '\n')
    fixture = original.removesuffix(b'done_testing();\n') + GROUP.replace('PREFIX', PREFIX).encode() + b'\ndone_testing();\n'
    (ROOT / (PREFIX + 'fixture.t')).write_bytes(fixture)
    (ROOT / FIXTURE).write_bytes(fixture)
    print('Authored', len(rows), 'grouped/default/host/numeric/indexed occurrence cases; original40 groups preserved.')


if __name__ == '__main__':
    main()
