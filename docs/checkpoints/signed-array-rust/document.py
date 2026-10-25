"""Update the current public Rust status without growing the book line budget."""
import common as c

FLOW = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
REFERENCE = 'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'


def main():
    sources = {path: c.read(path) for path in [FLOW, REFERENCE]}
    replacements = {
        FLOW: [
            ('Perl native and independently emitted execution implement tail-relative reads and writes',
             'Perl and Rust native and independently emitted execution implement tail-relative reads and writes'),
            ('#### Signed array selectors in Perl', '#### Signed array selectors in Perl and Rust'),
            ('The extension is available on Perl; it is not yet admitted portably.',
             'The extension is available on Perl and Rust; it is not yet admitted portably.'),
            ('| Rust ordinary/callable read | `10`, from its legacy index coercion |',
             '| Rust ordinary/callable read | `30` |'),
            ('The other-runtime rows retain the dated transition observations until their backend slices land. Perl negative writes now replace existing array entries.',
             'Dart and Lua/Julia rows retain the dated transition observations until their backend slices land. Perl and Rust negative writes replace existing array entries.'),
            ('The ordinary Perl example returns', 'The ordinary example runs on Perl and Rust and returns'),
            ('Perl implements the following rule', 'Perl and Rust implement the following rule'),
            ('A dynamic negative integer works like the literal; a dynamic string or a negative float retains its earlier read coercion behavior and is not promoted to an integer selector.',
             'A dynamic negative integer works like the literal. Perl retains its separate integer/float distinction. Rust uses finite whole `f64` values, so `-1.0` also selects the last entry; fractional negatives and strings retain Rust\'s existing read coercions. This extension does not expand the numeric range or admit portable coercions. Rebuild saved or emitted parsers after updating the runtime.'),
        ],
        REFERENCE: [
            ('later replacement of the binding. Use nonnegative integer indexes for portable',
             'later replacement of the binding. Perl and Rust support existing-position tail reads such as `items[-1]`; see [signed selectors](values-containers-and-flow-helpers.md#signed-array-selectors-in-perl-and-rust). Use nonnegative integer indexes for portable'),
        ],
    }
    updated = {}
    for path, pairs in replacements.items():
        raw = c.decode(sources[path]['base64']).decode()
        for old, new in pairs:
            assert raw.count(old) == 1, old
            raw = raw.replace(old, new, 1)
        data = raw.encode()
        assert len(data.splitlines()) == len(c.decode(sources[path]['base64']).splitlines())
        updated[path] = dict(base64=c.encode(data), sha256=c.sha(data), mode=sources[path]['mode'])
    c.write_new('documentation-inputs.json.gz', dict(producer=c.read(c.PREFIX+'document.py'),
        before=sources, after=updated, scope='Current Rust behavior and four existing executable examples; no source-line budget increase, frozen predecessor evidence untouched.'))
    for path, packet in updated.items():
        c.source(path).write_bytes(c.decode(packet['base64']))
    print('Current signed book status synchronized; source-line count unchanged.')


if __name__ == '__main__':
    main()
