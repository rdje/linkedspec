"""Retain the failed reader and qualify its known Git/full-permission confusion."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
images = json.loads(gzip.decompress((BASE / 'review_first-final-launch/producer-images.json.gz').read_bytes()))
for name in ('review.py', 'review_model.py', 'seal.py'):
    path = BASE / name
    retained = base64.b64decode(images[str(REL / name)]['base64'])
    assert path.read_bytes() == retained and hashlib.sha256(retained).hexdigest() == images[str(REL / name)]['sha256']
assert (BASE / 'review_first-final-launch/exit.txt').read_text().strip() == '1'
assert b'AssertionError: SDK origin' in gzip.decompress((BASE / 'review_first-final-launch/stderr.log.gz').read_bytes())
model = (BASE / 'review_model.py').read_text()
changes = [
    ("        need(images[name] == expected, 'SDK origin')", "        need(images[name][0] == expected[0], 'SDK origin')\n        need(bool(images[name][1] & 0o111) == bool(expected[1] & 0o111), 'SDK executable class')"),
    ("        need(images[PRIVATE] == (owner, history.files[OWNER][1]), 'private source input')", "        declared = json.loads(images[str(REL / 'owner-images.json')][0])['images']['old' if phase == 'private_old' else 'current']\n        need(images[PRIVATE] == (owner, declared['mode']), 'private source input')"),
    ("        need(images[name] == history.files[name], 'direct original consumer')", "        need(images[name][0] == history.files[name][0], 'direct original consumer')\n        need(bool(images[name][1] & 0o111) == bool(history.files[name][1] & 0o111), 'direct executable class')"),
]
for old, new in changes:
    assert model.count(old) == 1, old
    model = model.replace(old, new)
assert not (BASE / 'review_model_qualified.py').exists()
(BASE / 'review_model_qualified.py').write_text(model)

# The census is limited to already-declared SDK inputs in the retained intake.
ids = json.loads((BASE / 'intake/input-identities.json').read_bytes())
tree = subprocess.check_output(['git', 'ls-tree', '-r', '-z', '09bad87aa19304486f836cf6dff44b499a8ea5ec', '--', 'perl', 'specs'])
git_modes = {}
for item in tree.split(b'\0'):
    if item:
        header, name = item.split(b'\t', 1)
        git_modes[name.decode()] = int(header.split()[0], 8) & 0o777
differences = []
with tarfile.open(BASE / 'intake/inputs-before-sdk.tar.gz') as archive:
    for name in sorted(git_modes):
        row, git_mode = ids[name], git_modes[name]
        if row['mode'] != git_mode:
            raw = archive.extractfile(name).read()
            differences.append(dict(path=name, filesystem_mode=row['mode'], git_mode=git_mode,
                sha256=hashlib.sha256(raw).hexdigest(), executable_class_equal=bool(row['mode'] & 0o111) == bool(git_mode & 0o111)))
assert len(differences) == 12 and all(row['executable_class_equal'] for row in differences)
(BASE / 'mode-diagnostic.json').write_text(json.dumps(differences, indent=2) + '\n')

review = (BASE / 'review.py').read_text()
assert review.count("BASE / 'review_model.py'") == 1
review = review.replace("BASE / 'review_model.py'", "BASE / 'review_model_qualified.py'")
assert review.count('review_first-final-launch') == 2
review = review.replace('review_first-final-launch', 'review_qualified_first-final-launch')
needle = "history = m.History()"
assert review.count(needle) == 1
review = review.replace(needle, "original_failure = BASE / 'review_first-final-launch'\nm.need((original_failure / 'exit.txt').read_text().strip() == '1' and b'AssertionError: SDK origin' in gzip.decompress((original_failure / 'stderr.log.gz').read_bytes()), 'original reader qualification')\n\n" + needle)
needle = "baseline = epochs['intake']['rows']"
assert review.count(needle) == 1
review = review.replace(needle, needle + "\nmode_differences = [dict(path=name, filesystem_mode=epochs['intake']['images'][name][1], git_mode=entry[1], sha256=m.sha(entry[0]), executable_class_equal=bool(epochs['intake']['images'][name][1] & 0o111) == bool(entry[1] & 0o111)) for name, entry in sorted(history.sdk.items()) if epochs['intake']['images'][name][1] != entry[1]]\nm.need(m.equal(mode_differences, json.loads((BASE / 'mode-diagnostic.json').read_bytes())) and len(mode_differences) == 12 and all(row['executable_class_equal'] for row in mode_differences), 'retained filesystem-mode qualification')")
needle = "print(json.dumps(dict(result='PASS', groups=312, product_targets=43,"
assert review.count(needle) == 1
extra = """changed = copy.deepcopy(epochs['private_current']['images'])
body, mode = changed['specs/spec.spec']
changed['specs/spec.spec'] = (body, mode | 0o100)
red('change-executable-class', lambda: m.sdk_origin(changed, history, current), 'SDK executable class')
changed = json.loads((BASE / 'private_current/input-identities.json').read_bytes())
changed['specs/spec.spec']['mode'] ^= 0o040
red('change-full-filesystem-mode', lambda: m.read_archive(BASE / 'private_current/inputs-before-sdk.tar.gz', changed), 'archive identity')

"""
review = review.replace(needle, extra + needle)
assert not (BASE / 'review_qualified.py').exists()
(BASE / 'review_qualified.py').write_text(review)
seal = (BASE / 'seal.py').read_text()
assert seal.count('review_first-final-launch') == 1
(BASE / 'seal_qualified.py').write_text(seal.replace('review_first-final-launch', 'review_qualified_first-final-launch'))
(BASE / 'reader-qualification.json').write_text(json.dumps(dict(original_exit=1,
    replacements=changes, mode_card='docs/knowledge/project-root-evidence-filesystem-modes.md',
    declared_sdk_mode_differences=12, source_or_permission_changes=False,
    limits='Source byte origin/Git executable class and exact captured full filesystem modes are separate checks. Original readers/first channels remain; no chmod, SDK edit, new runtime verdict or whole-repository permission census.'), indent=2) + '\n')
print('Qualified the existing mode distinction: twelve declared SDK permissions differ from Git; bytes/executable classes stay guarded, no chmod.')
