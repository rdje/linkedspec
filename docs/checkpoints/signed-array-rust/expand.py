"""Add frozen public read/write projections and exact Rust boundary examples."""
import copy
import json
import common as c

FIXTURE = 'tests/signed-array-rust/cases.json'
PUBLIC = 'tests/numeric-codeblocks/signed-array-selectors.json'
BOOK = {
    'examples/negative-array-current-perl.spec': [30, [10, 20, 30]],
    'examples/negative-array-current-callable-perl.spec': [30, [10, 20, 30]],
    'examples/negative-array-write-perl.spec': [30, [10, 99, 30]],
    'examples/negative-array-write-callable-perl.spec': {'rows': [[1], [99, 3]]},
}


def main():
    sources = {path: c.read(path) for path in [FIXTURE, PUBLIC, *BOOK]}
    value = json.loads(c.decode(sources[FIXTURE]['base64']))
    assert len(value['cases']) == 40
    historical = json.loads(c.decode(sources[PUBLIC]['base64']))
    selected = [row for row in historical['cases'] if row['id'].startswith(('read/', 'write/'))]
    assert len(selected) == 86
    for row in selected:
        if 'expected' in row:
            expected = dict(ok=row['expected'])
        else:
            # Perl's statement-relative/source-id projection is not Rust's
            # block-relative span contract. All other fields retain the frozen
            # public target. An exact Rust Unicode span is independently below.
            error = copy.deepcopy(row['error'])
            error.pop('source_span', None)
            expected = dict(error=error)
        value['cases'].append(dict(id='authority/' + row['id'], source=row['source'],
            input=row['input'], expected=expected, authority_case=row['authority_case']))
    for path, expected in BOOK.items():
        value['cases'].append(dict(id='book/' + path, source=c.decode(sources[path]['base64']).decode(),
            input='x', expected=dict(ok=expected)))
    extra = [
        ('distinct-parameter-identity',
         'tree=[10]; edit={|tree| tree[-1]=99; return(tree) }; return(tree.map_leaves!() { return(edit([1])) })',
         dict(ok=[[99]])),
        ('signed-guard-before-expression-failure',
         'tree=[10]; return(tree.map_leaves!() { tree[{ dispatch_span(); -1 }]=dispatch_span(); return(value) })',
         dict(error=dict(code='receiver_mutation_reentrant', attempt='nested_write', binding='tree'))),
        ('value-result-negative',
         'pick={|| return([[10],[20,30]]) }; return(pick()[-1][-2])', dict(ok=20)),
        ('native-float-kind',
         'tree=[10,20]; return([tree[-1.0],tree[-1.5],tree["-1"]])', dict(ok=[20,10,10])),
        ('read-access-receiver-snapshot',
         'tree=[[10],[20,30]]; return([tree[{ tree=[[90],[91,92,93]]; -1 }][-1],tree])',
         dict(ok=[30, [[90],[91,92,93]]])),
        ('detached-public-boundaries',
         'initial=[[1]]; tree=initial; payload=[2]; result=(tree[-1]=payload); initial[-1][0]=11; payload[0]=22; result[-1][0]=33; tree[-1][0]=44; return([initial,payload,result,tree])',
         dict(ok=[[[11]],[22],[[33]],[[44]]])),
    ]
    for name, body, expected in extra:
        value['cases'].append(dict(id=name, source='Top: /x/\n I { ' + body + ' }\n', input='x', expected=expected))
    body = 'tree={"é":[1]}; tree["é"][-2]=99; return(tree)'
    start = len(' ' + body[:body.index('[-2]') + 1])
    error = dict(code='nested_write_array_underflow', operation='nested_write_vivification',
        binding='tree', segment_index=1, path=['é'], index=-2, length=1, resolved_index=-1,
        source_span=dict(start=start, end=start+2, unit='unicode_scalar', provenance='authored'),
        message="nested write segment 1 for binding 'tree' cannot select array index -2 at length 1 (resolved index -1)")
    value['cases'].append(dict(id='unicode-exact-public', source='Top: /x/\n I { ' + body + ' }\n',
        input='x', expected=dict(error=error)))
    value['scope'] += ' Expanded public projections: all14 read cases and29 expression/structural write cases in ordinary/callable contexts; four guard/evaluation/identity cases have separate private/public probes. Perl-specific span projections are deliberately excluded; Rust exact Unicode source geometry is checked independently. The original40 before/after population is unchanged as a retained epoch.'
    assert len({row['id'] for row in value['cases']}) == len(value['cases'])
    raw = (json.dumps(value, ensure_ascii=False, indent=2) + '\n').encode()
    c.write_new('expanded-fixture-inputs.json.gz', dict(producer=c.read(c.PREFIX+'expand.py'),
        sources=sources, updated=dict(base64=c.encode(raw), sha256=c.sha(raw), mode=sources[FIXTURE]['mode'])))
    c.source(FIXTURE).write_bytes(raw)
    print('Expanded fixture:', len(value['cases']), 'authored cases; distinct original40 retained.')


if __name__ == '__main__':
    main()
