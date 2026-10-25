"""Retain the actual false mode-equality refusal before applying the known rule."""
import common as c

name='specs/ifelse.spec'
supplied=c.load('before-inputs.json.gz')['context']['sources'][name]
blob=c.run(['git','show',c.BASE+':'+name])
mode=c.run(['git','ls-tree',c.BASE,name])
assert blob['returncode']==mode['returncode']==0
assert c.decode(blob['stdout_base64'])==c.decode(supplied['base64'])
assert supplied['mode']==0o640 and c.decode(mode['stdout_base64']).startswith(b'100644 ')
c.save('review-mode-qualification.json.gz',dict(producer=c.read(c.PREFIX+'qualify_review.py'),
    failed_reader=c.read(c.PREFIX+'review.py'),
    channels=c.read('.linkedspec-data/verification/signed-dart17-review2.log'),
    source=supplied,git_blob=blob,git_mode=mode,
    canonical_rule=c.read('docs/knowledge/project-root-evidence-filesystem-modes.md'),
    qualification='The reader re-derived a known distinction by equating Git permissions with actual '
        'filesystem permissions. The source bytes are identical; Git100644 and actual0640 are separate '
        'representations. Compare committed contents/executable class, then guard actual complete '
        'permissions against their own captured field. No chmod or product/source failure. '
        'The earlier full-type-bit comparison also stopped at identical dart/README.md bytes; '
        'neither diagnostic earns product mismatch or accepted census credit.'))
print('Actual false mode comparison retained; canonical mode rule applies without chmod.')
