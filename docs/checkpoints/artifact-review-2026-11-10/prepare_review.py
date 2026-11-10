"""Compose the next dated review from the accepted bounded scanner and channel runner."""
from pathlib import Path

HERE = Path(__file__).parent
PRIOR = HERE.parent / 'artifact-review-2026-11-07'
review = (PRIOR / 'review.py').read_text()
review = review.replace('TYPE-REFERENCE-BOOK.1.2.23.4.15', 'TYPE-REFERENCE-BOOK.1.2.23.4.19')
review = review.replace('artifact-review-2026-11-07/run.py', 'artifact-review-2026-11-10/run.py')
review = review.replace("             'docs/checkpoints/REPO-HYGIENE.22/census.py',\n", '')
needle = "    spec = importlib.util.spec_from_file_location('artifact_census', ROOT / HELPER)"
prefix = """    # Retain all project observation producers before loading the census helper.
    sources = (*PRODUCERS, Path(__file__).relative_to(ROOT).as_posix())
    producers = {name: packet((ROOT / name).read_bytes()) for name in sources}
    for name in sources:
        info = (ROOT / name).lstat()
        assert stat.S_ISREG(info.st_mode) and info.st_dev == ROOT.lstat().st_dev
"""
assert review.count(needle) == 1
review = review.replace(needle, prefix + needle)
review = review.replace("    sources = (*PRODUCERS, Path(__file__).relative_to(ROOT).as_posix())\n    report =", '    report =')
review = review.replace("'producers': {name: packet((ROOT / name).read_bytes()) for name in sources},", "'producers': producers,")
needle = "    raw = json.dumps(report, separators=(',', ':')).encode()"
assert review.count(needle) == 1
review = review.replace(needle, "    for name, image in producers.items():\n        assert packet((ROOT / name).read_bytes()) == image, 'producer changed during observation'\n" + needle)
for name, body in (('review.py', review), ('run.py', (PRIOR / 'run.py').read_text())):
    destination = HERE / name
    assert not destination.exists(), 'one-shot composition'
    destination.write_text(body)
