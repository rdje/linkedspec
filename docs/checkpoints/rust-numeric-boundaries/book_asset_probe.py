"""Retain actual search assets before explaining the containment difference."""
import common as c
import book_render as b


def main():
    previous=c.load('book3-containment.json.gz')
    assert all(c.read(path)==packet for path,packet in previous['before'].items())
    c.save('book4-probe-inputs.json.gz',dict(before=previous['before'],folded=previous['folded'],
        producers={name:c.read(c.PREFIX+name) for name in
            ['book_asset_probe.py','book_render.py','book_final.py','book_update.py',
             'book_sources.py','common.py']},
        prior_failure=c.read('.linkedspec-data/verification/numeric55-book3.log'),
        version=c.run(['mdbook','--version']),
        scope='The prior selected-page token comparison differs at a generated '
            'search-index URI. Retain every actual output for both supplied whole '
            'input sets before classifying that difference. No source writes or '
            'semantic-equivalence admission by this diagnostic producer.'))
    original=b.render(previous['before']);folded=b.render(previous['folded'])
    c.save('book4-probe-runs.json.gz',dict(original=original,folded=folded))
    assert original['returncode']==folded['returncode']==0
    a,z=original['outputs'],folded['outputs']
    print('Actual output files',len(a),len(z),'; removed',sorted(set(a)-set(z)),
        '; added',sorted(set(z)-set(a)),flush=True)
    print('Same-name changed outputs',*[name for name in a.keys()&z.keys()
        if a[name]!=z[name]],sep='\n',flush=True)


if __name__ == '__main__':
    main()
