"""Retire only the accepted prior publication after complete preservation."""
import json
import common as c


def main():
    prior = c.load('prior.json.gz')
    claim_path = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.4.json'
    readme_path = 'docs/checkpoints/type-scoped-with/README.md'
    assert c.read(claim_path) == prior['claim']
    original_inputs = json.loads(c.decode(prior['manifest']['base64']))['inputs']
    assert c.unchanged(original_inputs)
    record = json.loads(c.decode(prior['claim']['base64']))
    for entry in record['claims']:
        assert entry['durability']['mode'] == 'live'
        entry['durability'].update(mode='historical', revision=c.BASE)
    raw = (json.dumps(record, separators=(',', ':')) + '\n').encode()
    before = c.read(readme_path)
    notice = ('Historical checkpoint at accepted ' + c.BASE + '. The original readonly\n'
              'publisher describes that revision; current numeric work and proof are owned by\n'
              'docs/checkpoints/type-numeric-codeblocks/README.md. The whole original\n'
              'publication, closed inputs, full modes and actual clean replay survive there.\n\n').encode()
    after_readme = notice + c.decode(before['base64'])
    c.write_new('prior-retirement.json.gz', dict(producer=c.read(c.PREFIX + 'retire_prior.py'),
        claim_before=prior['claim'], claim_after=c.encode(raw), readme_before=before,
        readme_after=c.encode(after_readme),
        scope='Only historical mode/revision changes in the complete prior record. '
              'Every original metric, producer, input and observation is retained at the real accepted base.'))
    (c.ROOT / claim_path).write_bytes(raw)
    (c.ROOT / readme_path).write_bytes(after_readme)
    print('Prior4 retired at its real accepted revision; original whole record and inputs preserved')


if __name__ == '__main__':
    main()
